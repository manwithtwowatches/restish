module Restish
  module Repository
    include AdapterSupport

    mattr_accessor :repositories

    self.repositories = []

    # Class methods:

    # Clear memoized values cache from all known repositories.
    def self.clear_cache
      repositories.each &:clear_cache
    end

    # Callback invoked whenever Repository is extended into a class.
    def self.extended(base)
      repositories.push base
    end


    # Instance methods:

    # Clears memoized values from repository.
    def clear_cache
      @all = nil
    end

    # Return all models.
    #
    # @return [Array]
    def all(options = {})
      if options.present?
        adapter(model_class).all(options)
      else
        @all ||= adapter(model_class).all
      end
    end

    # Find the record with given ID.
    #
    # @param [String,Integer] id Model ID
    # @return [Model]
    def find(id_or_options)
      if id_or_options.is_a?(Hash)
        options = id_or_options
        id = nil
      else
        options = {}
        id = id_or_options
      end

      if model = find_locally(id)
        model
      else
        adapter(model_class).find(id, options)
      end
    end

    # Find the record with given ID.
    #
    # @param [String,Integer] id Model ID
    # @return [Model]
    def find_locally(id)
      if @all.present?
        @all.find { |model| model.id == id }
      end
    end

    # Filter all records with query.
    #
    # @param [Hash] query
    # @param [Array]
    def filter(query)
      query.inject(all) do |matching, (key, val)|
        matching.select { |category| category[key] == val }
      end
    end

    def post(id, action)
      adapter(model_class).post(id, action)
    end

    protected

    def model_class
      model_name = name[/^(.*)Repository$/, 1]
      (model_name || name).underscore
    end
  end
end
