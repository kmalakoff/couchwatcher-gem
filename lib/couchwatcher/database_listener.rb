require 'json'
require 'thor/shell/basic'

module CouchWatcher

  class DatabaseListener
    
    # shortcut to say
    def say(message, color=nil)
      @shell ||= Thor::Shell::Basic.new
      @shell.say message, color
    end

    def initialize(database_url)
      @database_url = database_url
      @last_sequence = nil
      @thread = nil
      @DatabaseCallback = Struct.new(:callback_proc, :include_document) 
      @database_callbacks = []
      @DocumentCallback = Struct.new(:document_id, :callback_proc, :include_document) 
      @document_callbacks = []
    end

    def add_database_callback(callback_proc, include_document)
      if !@thread.nil?
        say "Error: cannot add callbacks to a running listener", :red
        return nil
      end
      
      database_callback = @DatabaseCallback.new(callback_proc, include_document)
      @database_callbacks << database_callback
      return database_callback
    end
    
    def remove_database_callback(database_callback)
      if !@thread.nil?
        say "Error: cannot remove callbacks from a running listener", :red
        return
      end

      @database_callbacks.delete(database_callback)
    end

    def add_document_callback(document_id, callback_proc, include_document)
      if !@thread.nil?
        say "Error: cannot add callbacks to a running listener", :red
        return nil
      end

      document_callback = @DocumentCallback.new(document_id, callback_proc, include_document)
      @document_callbacks << document_callback
      return document_callback
    end
    
    def remove_document_callback(document_callback)
      if !@thread.nil?
        say "Error: cannot remove callbacks from a running listener", :red
        return
      end

      @document_callbacks.delete(document_callback)
    end

    def start_watching(verbose, polling_interval)
      if !@thread.nil?
        say "Error: listener is already running listener", :red
        return
      end

      say "Database watching started for: #{@database_url}", :green if verbose
      @thread = Thread.new do
        
        # get the sequence
        if @last_sequence.nil?
          data = get_info()
          if data.nil? || data["update_seq"].nil?
            say "Error: the database cannnot be watched: #{@database_url}. Check that the couchdb is running, the database exists, and you have adequate permissions.", :red
            return
          end 

          @last_sequence = data["update_seq"]
        end

        @connection_stopped = false
        while true

          #puts "Checking heartbeat: #{@database_url} sequence: #{@last_sequence} connecte"

          # stopped the connection
          if @connection_stopped
            return 

          # the sequence number has been returned so start polling
          elsif @last_sequence
            results = get_changes()
                    
            #puts "Checking heartbeat: #{@database_url} sequence: #{@last_sequence}"

            results.each do |result|

              document_id = result["id"]
              document_rev = result["changes"][0]["rev"]
              document = result["doc"]
            
              # tell a change
              say "Change detected in database: #{@database_url} document: #{document_id}", :green if verbose

              # call the database watchers
              @database_callbacks.each do |callback| 
                if callback.include_document 
                  callback.callback_proc.call(@database_url, document_id, document_rev, document)
                else
                  callback.callback_proc.call(@database_url, document_id, document_rev)
                end
              end

              # call the document watchers
              @document_callbacks.each do |callback| 
                if (callback.document_id==document_id)
                  if callback.include_document 
                    callback.callback_proc.call(@database_url, document_id, document_rev, document)
                  else
                    callback.callback_proc.call(@database_url, document_id, document_rev)
                  end
                end
              end
            end
          end
        
          sleep polling_interval 
        end
      end
    end

    def stop_watching(verbose)
      if @thread.nil?
        say "Error: cannot stop because listener is is not running", :red
        return
      end

      # give the thread time to finish
      @connection_stopped = true
      @thread.kill
      @thread = nil
      say "Database watching stopped for: #{@database_url}", :green if verbose
    end
    
    private
    
    def get_info
#      puts "GET #{@database_url + "/"}"
      response = Typhoeus::Request.get(@database_url + "/")
#      puts "Response: #{response.code} #{JSON.parse(response.body).inspect}"
      json = response.code == 200 ? JSON.parse(response.body) : nil
    end

    def get_changes
#      puts "GET #{@database_url + "/_changes?since=#{@last_sequence}"}"
      response = Typhoeus::Request.get(@database_url + "/_changes?since=#{@last_sequence}&include_docs=true")
#      puts "Response: #{response.code} #{JSON.parse(response.body).inspect}"
      json = response.code == 200 ? JSON.parse(response.body) : nil
      if !json.nil?
        @last_sequence = json["last_seq"]
        return json["results"]
      end

    end

  end
end