module Padrino
  class << self
    # Requires necessary dependencies as well as application files from root lib and models
    def load!
      load_required_gems # load bundler gems
      load_dependencies("#{root}/config/apps.rb", "#{root}/config/database.rb") # load configuration
      load_dependencies("#{root}/lib/**/*.rb", "#{root}/models/*.rb") # load root app dependencies
      reload! # We need to fill our Stat::CACHE but we do that only for development
    end

    # Method for reload required classes
    def reload!
      Stat::reload!
    end

    # Attempts to load/require all dependency libs that we need.
    # If you use this method we can perform correctly a Padrino.reload!
    #
    # @param paths [Array] Path where is necessary require or load a dependency
    # @example For load all our app libs we need to do:
    #   load_dependencies("#{Padrino.root}/lib/**/*.rb")
    def load_dependencies(*paths)
      paths.each do |path|
        Dir[path].each { |file| require(file) }
      end
    end
    alias_method :load_dependency, :load_dependencies

    # Attempts to require all dependencies with bundler; if this fails, uses system wide gems
    def load_required_gems
      return if @loaded
      self.load_bundler_manifest
      self.require_vendored_gems
      @loaded = true
    end

    protected

    # Loads the bundler manifest Gemfile if it exists
    def load_bundler_manifest
      require 'bundler'
      print "=> Locating Gemfile for #{PADRINO_ENV}"
      Bundler::Environment.load(root("Gemfile")).require_env(PADRINO_ENV)
      print "...Loaded!"
    rescue Bundler::ManifestFileNotFound, Bundler::DefaultManifestNotFound => e
      print "...Not Found"
    end

    # Loads bundled gems if they exist
    def require_vendored_gems
      load_dependencies(root('/../vendor', 'gems', PADRINO_ENV))
      puts " (Loading bundled gems)"
    rescue LoadError => e
      puts " (Loading system gems)"
    end
  end
end
