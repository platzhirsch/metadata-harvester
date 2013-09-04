require 'active_support/all'
require 'curb'
require 'json'
require 'tire'
require 'trollop'
require 'worker'
require 'yaml'

module MetadataHarvester

  def self.load_repositories
    path = File.expand_path('..', File.dirname(__FILE__))
    result = YAML.load_file("#{path}/repositories.yml")
    result.with_indifferent_access
  end

  def self.start
    options = Trollop::options do
      opt :compress, 'Compresses the data with Gzip afterwards'
    end

    for repository in load_repositories[:CKAN]
      catalog = load_repositories()
      catalog.each do |type, repositories|
        repositories.each do |r|
          args = [r[:url], r[:name], r[:limit], options[:archive], r[:import]]
          Worker.perform_async(*args)
        end
      end
    end
  end

end
