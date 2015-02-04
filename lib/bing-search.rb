%w{
  enums
  client
  errors
  models
  util
  version
}.each do |file|
  require "bing-search/#{file}"
end

module BingSearch

  HIGHLIGHT_DELIMITER = "\u{e001}"

  class << self
    # An Account Key obtained from the Azure Marketplace. You can set this
    # attribute once instead of instantiating each {Client} with an Account Key.
    # @return [String]
    attr_accessor :account_key

    # Whether to use the less expensive web-only API
    # @return [Boolean]
    attr_accessor :web_only

    # Convenience method that creates a {Client} and searches for web pages.
    # Takes the same arguments as {Client#web}. Set {account_key} before calling.
    # @return (see Client#web)
    # @see Client#web
    #
    def web(*args)
      Client.new.web(*args)
    end

    # Convenience method that creates a {Client} and searches for images. Takes
    # the same arguments as {Client#image}. Set {account_key} before calling.
    # @return (see Client#image)
    # @see Client#image
    #
    def image(*args)
      Client.new.image(*args)
    end

    # Convenience method that creates a {Client} and searches for videos. Takes
    # the same arguments as {Client#video}. Set {account_key} before calling.
    # @return (see Client#video)
    # @see Client#video
    #
    def video(*args)
      Client.new.video(*args)
    end

    # Convenience method that creates a {Client} and searches for news. Takes
    # the same arguments as {Client#news}. Set {account_key} before calling.
    # @return (see Client#news)
    # @see Client#news
    #
    def news(*args)
      Client.new.news(*args)
    end

    # Convenience method that creates a {Client} and searches for related
    # queries. Takes the same arguments as {Client#related_search}. Set {account_key}
    # before calling.
    # @return (see Client#related_search)
    # @see Client#related_search
    #
    def related_search(*args)
      Client.new.related_search(*args)
    end
    alias_method :related, :related_search

    # Convenience method that creates a {Client} and corrects spelling in the
    # query text. Takes the same arguments as {Client#related_search}. Set
    # {account_key} before calling.
    # @return (see Client#spelling_suggestions)
    # @see Client#spelling_suggestions
    #
    def spelling_suggestions(*args)
      Client.new.spelling_suggestions(*args)
    end
    alias_method :spelling, :spelling_suggestions

    # Convenience method that creates a {Client} and searches multiple sources.
    # Takes the same arguments as {Client#related_search}. Set {account_key} before
    # calling.
    # @return (see Client#composite)
    # @see Client#composite
    #
    def composite(*args)
      Client.new.composite(*args)
    end
  end
end
