require 'json'

module CouchWatcher

  class DatabaseListener
    
    def initialize(database_url, polling_interval = 3)
      @database_url = database_url
      @polling_interval = polling_interval
      @last_sequence = nil
      @connection_stopped = false
      @thread = nil
      @DatabaseCallback = Struct.new(:callback_proc, :include_document) 
      @database_callbacks = []
      @DocumentCallback = Struct.new(:document_id, :callback_proc, :include_document) 
      @document_callbacks = []
      
      data = get_info()
      if data.nil?
        puts "Error: the database cannnot be watched: #{@database_url}. Check that the couchdb is running, the database exists, and you have adequate permissions."
        @connection_stopped = true
        return
      end 

      @last_sequence = data["update_seq"]
    end

    def add_database_callback(callback_proc, include_document)
      if !@thread.nil?
        puts "Error: cannot add callbacks to a running listener"
        return nil
      end
      
      database_callback = @DatabaseCallback.new(callback_proc, include_document)
      @database_callbacks << database_callback
      return database_callback
    end
    
    def remove_database_callback(database_callback)
      if !@thread.nil?
        puts "Error: cannot remove callbacks from a running listener"
        return
      end

      @database_callbacks.delete(database_callback)
    end

    def add_document_callback(document_id, callback_proc, include_document)
      if !@thread.nil?
        puts "Error: cannot add callbacks to a running listener"
        return nil
      end

      document_callback = @DocumentCallback.new(document_id, callback_proc, include_document)
      @document_callbacks << document_callback
      return document_callback
    end
    
    def remove_document_callback(document_callback)
      if !@thread.nil?
        puts "Error: cannot remove callbacks from a running listener"
        return
      end

      @document_callbacks.delete(document_callback)
    end

    def start_watching
      if !@thread.nil?
        puts "Error: listener is already running listener"
        return
      end

      puts "Database watching started for: #{@database_url}"
      @thread = Thread.new do
        while true

          # stopped the connection
          if @connection_stopped
            return 

          # the sequence number has been returned so start polling
          elsif @last_sequence
            results = get_changes()
          
            # print a message
#            puts "Get changes heartbeat"
            puts "Change detected in database: #{@database_url}" if (results && !results.empty?)
          
            results.each do |result|

              document_id = result["id"]
              document_rev = result["changes"][0]["rev"]
              document = result["doc"]
            
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
        
          sleep @polling_interval 
        end
      end
    end

    def stop_watching
      if @thread.nil?
        puts "Error: listener is is not running"
        return
      end

      # give the thread time to finish
      @connection_stopped = true
      sleep @polling_interval + 2

      @thread.kill
      @thread = nil
      puts "Database watching stopped for: #{@database_url}"
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