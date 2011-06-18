require 'typhoeus'

require 'couchwatcher/database_listener'

module CouchWatcher

  class CouchWatcher
    def initialize()
      @database_listeners = {}
    end
  
    def add_database_watcher(database_url, include_document, &callback_block)
      database_listener(database_url).add_database_callback(callback_block, include_document)
    end
    
    def remove_database_watcher(callback_object)
      database_listener(database_url).remove_database_callback(callback_object)
    end
    
    def add_document_watcher(database_url, document_id, include_document, &callback_block)
      database_listener(database_url).add_document_callback(document_id, callback_block, include_document)
    end
      
    def remove_document_watcher(callback_object)
      database_listener(database_url).remove_document_callback(callback_object)
    end
    
    def start_watching()
      @database_listeners.each {|database_url, database_listener| database_listener.start_watching()}
    end
    
    def stop_watching()
      @database_listeners.each {|database_url, database_listener| database_listener.stop_watching()}
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
    
  end
end
