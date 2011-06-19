require 'typhoeus'
require 'couchwatcher/database_listener'

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

module CouchWatcher

  DEFAULT_POLLING_INTERVAL = 1

  class CouchWatcher
    def initialize()
      @database_listeners = {}
      @verbose = true
    end
  
    def add_database_watcher(database_url, include_document, &callback_block)
      database_listener(database_url).add_database_callback(callback_block, include_document)
    end
    
    def remove_database_watcher(callback_object)
      database_listener(database_url).remove_database_callback(callback_object)
    end
    
    def add_document_watcher(document_url, include_document, &callback_block)
      database_url, document_id = extract_url_components(document_url)
      database_listener(database_url).add_document_callback(document_id, callback_block, include_document)
    end
      
    def remove_document_watcher(callback_object)
      database_listener(database_url).remove_document_callback(callback_object)
    end
    
    def start_watching(verbose=true, polling_interval=nil)
      polling_interval = DEFAULT_POLLING_INTERVAL if (polling_interval.nil? || polling_interval <= 0)
      @verbose = verbose
      @database_listeners.each {|database_url, database_listener| database_listener.start_watching(verbose, polling_interval)}
    end
    
    def stop_watching()
      @database_listeners.each {|database_url, database_listener| database_listener.stop_watching(@verbose)}
    end

    private
    
    def database_listener(database_url)
      # not yet listening, create a new listener
      database_listener = @database_listeners[database_url]
      if database_listener.nil?
        database_listener = ::CouchWatcher::DatabaseListener.new(database_url)
        @database_listeners[database_url] = database_listener
      end
      
      return database_listener
    end

    def extract_url_components(document_url)
      url_elements = document_url.split('/')

      # a special design type
      if url_elements[url_elements.length-2].start_with?("_")
        document_element = url_elements[url_elements.length-2]

      # a normal document type
      else
        document_element = url_elements[url_elements.length-1]
      end

      url_elements = document_url.split(document_element)
      return [url_elements[0].chomp("/"), (url_elements[1].nil? ? document_element : document_element + url_elements[1])]
    end
    
  end
end
