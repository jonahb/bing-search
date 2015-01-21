module BingSearch

  class Model
    # @param [Hash] attrs
    def initialize(attrs = {})
      attrs.each do |k, v|
        public_send "#{k}=", v
      end
    end

    # Sets an attribute via a public instance method on the receiver or its
    # ancestors up to but not including Object
    # @param [Symbol] attr
    # @param value
    # @return [self]
    # @raise [ArgumentError]
    #   No public setter for +attr+ on the receiver or its ancestors up to
    #   Object
    #
    def set(attr, value)
      setter = "#{attr}=".to_sym

      self.class.attr_methods.include?(setter) ?
        public_send(setter, value) :
        raise(ArgumentError, "Can't set attr #{attr} of #{self}")
    end

    private

    def self.attr_methods
      @attr_methods ||= model_ancestors.reduce([]) do |memo, class_|
        memo + class_.public_instance_methods(false)
      end
    end

    def self.model_ancestors
      ancestors.select { |ancestor| ancestor < Model }
    end
  end

  class Result < Model
    # @return [String]
    #   A universally unique identifier (UUID)
    attr_accessor :id
  end

  class WebResult < Result
    # @return [String]
    attr_accessor :title

    # The summary displayed below the title in bing.com search results
    # @return [String]
    attr_accessor :description
    alias_method :summary, :description

    # URL to display to the user. Omits the scheme if HTTP.
    # @return [String]
    attr_accessor :display_url

    # Full URL of the result, including the scheme.
    # @return [String]
    attr_accessor :url
  end

  class ImageResult < Result
    # @return [String]
    attr_accessor :title

    # URL of the image
    # @return [String]
    attr_accessor :media_url
    alias_method :url, :media_url

    # URL of the website that contains the image
    # @return [String]
    attr_accessor :source_url

    # URL to display to the user. Omits the scheme if HTTP.
    # @return [String]
    attr_accessor :display_url

    # In pixels, if available
    # @return [Integer, nil]
    attr_accessor :width

    # In pixels, if available
    # @return [Integer, nil]
    attr_accessor :height

    # In bytes, if available
    # @return [Integer, nil]
    attr_accessor :file_size

    # {http://en.wikipedia.org/wiki/Internet_media_type Internet media type} (MIME type) of the image, if available
    # @return [String]
    attr_accessor :content_type
    alias_method :media_type, :content_type

    # @return [Image]
    attr_accessor :thumbnail
  end

  class VideoResult < Result
    # @return [String]
    attr_accessor :title

    # URL of the video, often a web page containing the video
    # @return [String]
    attr_accessor :media_url
    alias_method :url, :media_url

    # URL of a Bing page that displays the video
    # @return [String]
    attr_accessor :display_url

    # Duration of the video in milliseconds, if available
    # @return [Integer, nil]
    attr_accessor :run_time
    alias_method :duration, :run_time

    # @return [Image]
    attr_accessor :thumbnail
  end

  class NewsResult < Result
    # @return [String]
    attr_accessor :title
    alias_method :headline, :title

    # URL of the article
    # @return [String]
    attr_accessor :url

    # Organization responsible for the article
    # @return [String]
    attr_accessor :source

    # Sample of the article
    # @return [String]
    attr_accessor :description

    # Date on which the article was indexed
    # @return [Date]
    attr_accessor :date
  end

  class RelatedSearchResult < Result
    # The query text of the related search
    # @return [String]
    attr_accessor :title
    alias_method :query, :title

    # The URL of the Bing results page for the related search
    # @return [String]
    attr_accessor :bing_url
  end

  class SpellingSuggestionsResult < Result
    # The suggested spelling
    # @return [String]
    attr_accessor :value
    alias_method :suggestion, :value
  end

  class CompositeSearchResult < Result
    # @!group Instance Attributes for Results

    # @return [Array<WebResult>]
    attr_accessor :web

    # @return [Array<ImageResult>]
    attr_accessor :image

    # @return [Array<VideoResult>]
    attr_accessor :video

    # @return [Array<NewsResult>]
    attr_accessor :news

    # @return [Array<RelatedSearchResult>]
    attr_accessor :related_search

    # @return [Array<SpellingSuggestionsResult>]
    attr_accessor :spelling_suggestions

    # @!endgroup

    # The number of web results in the Bing index
    # @return [Integer, nil]
    attr_accessor :web_total

    # The ordinal of the first web result
    # @return [Integer, nil]
    attr_accessor :web_offset

    # The number of image results in the Bing index
    # @return [Integer, nil]
    attr_accessor :image_total

    # The ordinal of the first image result
    # @return [Integer, nil]
    attr_accessor :image_offset

    # The number of video results in the Bing index
    # @return [Integer, nil]
    attr_accessor :video_total

    # The ordinal of the first video result
    # @return [Integer, nil]
    attr_accessor :video_offset

    # The number of news results in the Bing index
    # @return [Integer, nil]
    attr_accessor :news_total

    # The ordinal of the first news result
    # @return [Integer, nil]
    attr_accessor :news_offset

    # The number of spelling suggestions in the Bing index
    # @return [Integer, nil]
    attr_accessor :spelling_suggestions_total

    # The query text after spelling errors have been corrected
    # @return [String]
    attr_accessor :altered_query

    # Query text that forces the original query, preventing any alterations in {#altered_query}
    # @return [String]
    attr_accessor :alteration_override_query
  end

  class Image < Model
    # URL of the image
    # @return [String]
    attr_accessor :media_url
    alias_method :url, :media_url

    # {http://en.wikipedia.org/wiki/Internet_media_type Internet media type} (MIME type) of the image, if available
    # @return [String]
    attr_accessor :content_type

    # In pixels, if available
    # @return [Integer, nil]
    attr_accessor :width

    # In pixels, if available
    # @return [Integer, nil]
    attr_accessor :height

    # In bytes, if available
    # @return [Integer, nil]
    attr_accessor :file_size
  end
end
