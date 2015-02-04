require 'date'
require 'json'
require 'net/http'
require 'uri'

module BingSearch
  class Client
    # The Account Key obtained from the Azure Marketplace
    # @return [String]
    attr_reader :account_key

    # Whether to use the less expensive web-only API
    # @return [Boolean]
    attr_reader :web_only


    # @!group Constructors

    # @param [String, nil] account_key
    #   An Account Key obtained from the Azure Marketplace. If nil,
    #   {BingSearch.account_key} is assumed.
    # @param [Boolean, nil] web_only
    #   Whether to use the less expensive web-only API. If nil,
    #   {BingSearch.web_only} is assumed.
    #
    def initialize(account_key: nil, web_only: nil)
      @session = nil
      @account_key = account_key || BingSearch.account_key
      @web_only = web_only.nil? ? BingSearch.web_only : web_only

      unless @account_key
        raise ArgumentError, "Pass an Account Key or set BingSearch.account_key"
      end
    end


    # @!group Sessions

    # Opens a client and yields it to the given block. Takes the same arguments
    # as {#initialize}.
    # @see #initialize
    # @yieldparam [Client] client
    # @return [Client]
    # @see #open
    #
    def self.open(*args)
      raise "Block required" unless block_given?
      client = new(*args)
      client.open { yield client }
      client
    end

    # Opens the client, creating a new TCP connection.
    #
    # If a block is given, yields to the block, closes the client when the
    # block returns, and returns the return value of the block. If a
    # block is not given, returns self and leaves the client open, relying on
    # the caller to close the client with {#close}.
    #
    # Note that opening and closing the client is only required if you want to
    # make several calls under one TCP connection. Otherwise, you can simply
    # call the search methods ({#web}, {#image}, etc.), which call {#open} for
    # you if necessary.
    #
    # @yield
    #   If a block is given, the client is closed when the block returns.
    # @return [Object, self]
    #   If a block is given, the return value of the block; otherwise, +self+.
    # @raise [StandardError]
    #   The client is already open
    #
    def open
      raise "Already open" if open?

      @session = Net::HTTP.new(HOST, Net::HTTP.https_default_port)
      @session.use_ssl = true

      begin
        @session.start
        block_given? ? yield : self
      ensure
        close if block_given?
      end
    end

    # Closes the client. Must be called after {#open} is called without a
    # block.
    # @return [self]
    # @see #open
    #
    def close
      @session.finish if open?
      @session = nil
      self
    end

    # Whether the client is open
    # @return [Boolean]
    # @see #open
    #
    def open?
      @session && @session.started?
    end


    # @!group Searching

    # @!macro general
    #   @param [String] query
    #     The query text; supports the
    #     {http://msdn.microsoft.com/en-us/library/ff795667.aspx Bing Query Language}
    #   @param [Hash{Symbol => Object}] opts
    #   @option opts [Integer] :limit
    #     The maximum number of results to return
    #   @option opts [Integer] :offset
    #     The zero-based ordinal of the first result to return
    #   @option opts [Adult, Symbol] :adult
    #     The level of filtering of sexually explicit content. If omitted, Bing
    #     uses the default level for the market.
    #   @option opts [Float] :latitude
    #     May range from -90 to 90
    #   @option opts [Float] :longitude
    #     May range from -180 to 180
    #   @option opts [String] :market
    #     A language tag specifying the market in which to search (e.g.
    #     +en-US+). If omitted, Bing infers the market from IP address, etc.
    #   @option opts [Boolean] :location_detection (true)
    #     Whether to infer location from the query text
    #   @raise [ServiceError]
    #     The Bing Search service returned an error
    #   @raise [StandardError]
    #     Invalid argument, unable to parse Bing response, networking error,
    #     and other error conditions
    #   @see http://msdn.microsoft.com/en-us/library/ff795667.aspx Bing Query Language reference

    # Searches for web pages
    # @!macro general
    # @option opts [FileType] :file_type
    #   Type of file to return
    # @option opts [Boolean] :highlighting (false)
    #   Whether to surround query terms in {WebResult#description} with the
    #   delimiter {BingSearch::HIGHLIGHT_DELIMITER}.
    # @option opts [Boolean] :host_collapsing (true)
    #   Whether to suppress results from the same 'top-level URL'
    # @option opts [Boolean] :query_alterations (true)
    #   Whether to alter the query in case of, e.g., supposed spelling errors
    # @return [Array<WebResult>]
    #
    def web(query, opts = {})
      invoke 'Web',
        query,
        opts,
        passthrough_opts: %i(file_type),
        enum_opt_to_module: {file_type: FileType},
        param_name_replacements: {file_type: 'WebFileType'},
        params: {web_search_options: web_search_options_from_opts(opts)}
    end

    # Searches for images
    # @!macro general
    # @option opts [Integer] :minimum_height
    #   In pixels; ANDed with other filters
    # @option opts [Integer] :minimum_width
    #   In pixels; ANDed with other filters
    # @option opts [Array<ImageFilter>] :filters
    #   Multiple filters are ANDed
    # @return [Array<ImageResult>]
    #
    def image(query, opts = {})
      invoke 'Image',
        query,
        opts,
        param_name_replacements: {filters: 'ImageFilters'},
        params: {filters: image_filters_from_opts(opts)}
    end

    # Searches for videos
    # @!macro general
    # @option opts [Array<VideoFilter>] :filters
    #   Multiple filters are ANDed. At most one duration is allowed.
    # @option opts [VideoSort] :sort
    # @return [Array<VideoResult>]
    #
    def video(query, opts = {})
      invoke 'Video',
        query,
        opts,
        passthrough_opts: %i(filters sort),
        enum_opt_to_module: {filters: VideoFilter, sort: VideoSort},
        param_name_replacements: {filters: 'VideoFilters', sort: 'VideoSortBy'}
    end

    # Searches for news
    # @!macro general
    # @option opts [Boolean] :highlighting (false)
    #   Whether to surround query terms in {NewsResult#description} with the
    #   delimiter {BingSearch::HIGHLIGHT_DELIMITER}.
    # @option opts [NewsCategory] :category
    #   Only applies in the en-US market. If no news matches the category, Bing
    #   returns results from a mix of categories.
    # @option opts [String] :location_override
    #   Overrides Bing's location detection. Example: +US.WA+
    # @option opts [NewsSort] :sort
    # @return [Array<NewsResult>]
    #
    def news(query, opts = {})
      invoke 'News',
        query,
        opts,
        passthrough_opts: %i(category location_override sort),
        enum_opt_to_module: {category: NewsCategory, sort: NewsSort},
        param_name_replacements: {category: 'NewsCategory', location_override: 'NewsLocationOverride', sort: 'NewsSortBy'}
    end

    # Searches for related queries
    # @!macro general
    # @return [Array<RelatedSearchResult>]
    #
    def related_search(query, opts = {})
      invoke 'RelatedSearch', query, opts
    end
    alias_method :related, :related_search

    # Corrects spelling in the query text
    # @!macro general
    # @return [Array<SpellingSuggestionsResult>]
    #
    def spelling_suggestions(query, opts = {})
      invoke 'SpellingSuggestions', query, opts
    end
    alias_method :spelling, :spelling_suggestions

    # Searches multiple sources. At most 15 news results are returned by
    # a composite query regardless of the +:limit+ option.
    # @macro general
    # @param [Array<Source>] sources
    #   The sources to search
    # @option opts [Boolean] :highlighting (false)
    #   Whether to surround query terms in {NewsResult#description} and
    #   {WebResult#description} with the delimiter {BingSearch::HIGHLIGHT_DELIMITER}.
    # @option opts [FileType] :web_file_type
    #   Type of file to return. Applies to {Source::Web}; also affects
    #   {Source::Image} and {Source::Video} if {Source::Web} is specified.
    # @option opts [Boolean] :web_host_collapsing (true)
    #   Whether to suppress results from the same 'top-level URL.' Applies to {Source::Web}.
    # @option opts [Boolean] :web_query_alterations (true)
    #   Whether to alter the query in case of, e.g., supposed spelling errors. Applies to {Source::Web}.
    # @option opts [Integer] :image_minimum_width
    #   In pixels; ANDed with other filters. Applies to {Source::Image}.
    # @option opts [Integer] :image_minimum_height
    #   In pixels; ANDed with other image filters. Applies to {Source::Image}.
    # @option opts [Array<ImageFilter>] :image_filters
    #   Multiple filters are ANDed. Applies to {Source::Image}.
    # @option opts [Array<VideoFilter>] :video_filters
    #   Multiple filters are ANDed. At most one duration is allowed. Applies to {Source::Video}.
    # @option opts [VideoSort] :video_sort
    #   Applies to {Source::Video}
    # @option opts [NewsCategory] :news_category
    #   Only applies in the en_US market. If no news matches the category, Bing
    #   returns results from a mix of categories. Applies to {Source::News}.
    # @option opts [String] :news_location_override
    #   Overrides Bing's location detection. Example: +US.WA+. Applies to {Source::News}.
    # @option opts [NewsSort] :news_sort
    #   Applies to {Source::News}.
    #
    # @return [CompositeSearchResult]
    #
    def composite(query, sources, opts = {})
      results = invoke('Composite',
        query,
        opts,
        passthrough_opts: %i(
          web_file_type
          video_filters
          video_sort
          news_category
          news_location_override
          news_sort
        ),
        enum_opt_to_module: {
          web_file_type: FileType,
          video_filters: VideoFilter,
          video_sort: VideoSort,
          news_category: NewsCategory,
          news_sort: NewsSort
        },
        param_name_replacements: {
          video_sort: 'VideoSortBy',
          news_sort: 'NewsSortBy'
        },
        params: {
          sources: sources.collect { |source| enum_value(source, Source) },
          web_search_options: web_search_options_from_opts(opts, :web_),
          image_filters: image_filters_from_opts(opts, :image_)
        }
      )

      results.first
    end

    private

    # @param [Hash] opts
    # @param [#to_s] opt_prefix
    # return [Array<String>]
    #
    def web_search_options_from_opts(opts = {}, opt_prefix = nil)
      web_search_options = []
      web_search_options << 'DisableHostCollapsing' if opts["#{opt_prefix}host_collapsing".to_sym] == false
      web_search_options << 'DisableQueryAlterations' if opts["#{opt_prefix}query_alterations".to_sym] == false
      web_search_options
    end

    # @param [Hash] opts
    # @param [#to_s] opt_prefix
    # @return [Array<String>]
    #
    def image_filters_from_opts(opts = {}, opt_prefix = nil)
      filters = (opts["#{opt_prefix}filters".to_sym] || []).map { |filter| enum_value(filter, ImageFilter) }

      height = opts["#{opt_prefix}minimum_height".to_sym]
      width = opts["#{opt_prefix}minimum_width".to_sym]
      filters << "Size:Width:#{width}" if width
      filters << "Size:Height:#{height}" if height

      filters
    end

    # @param [String] operation
    #   The first segment of the invocation URI path (after the base path),
    #   e.g. 'Web'
    # @param [String] query
    #   The query text
    # @param [Hash{Symbol => Object}] opts
    #   The options hash provided by the caller
    # @param [Array<Symbol>] passthrough_opts
    #   Keys of the options to copy to the params hash
    # @param [Hash{Symbol => Module}] enum_opt_to_module
    #   Maps an enum option key to the module containing the enum's values.
    #   Used to translate symbols to enum values. E.g. maps +:web_file_type+
    #   to {FileType}.
    # @param [Hash{Symbol => Object}] params
    #   Parameters for the invocation
    # @return [Object]
    # @raise [ServiceError]
    # @raise [RuntimeError]
    #
    def invoke(operation, query, opts, passthrough_opts: [], enum_opt_to_module: {}, param_name_replacements: {}, params: {})
      options = []
      options << 'DisableLocationDetection' if opts[:location_detection] == false
      options << 'EnableHighlighting' if opts[:highlighting]

      # Works around an apparent bug where Bing treats offsets 0 and 1 the same
      offset = opts[:offset] && opts[:offset] + 1

      opts = opts.each_with_object(Hash.new) do |(key, value), hash|
        module_ = GENERAL_ENUM_OPT_TO_MODULE[key] || enum_opt_to_module[key]
        hash[key] = module_ ? enum_value(value, module_) : value
      end

      params = params.
        merge(Util.slice_hash(opts, *GENERAL_PASSTHROUGH_OPTS, *passthrough_opts)).
        merge(query: query, offset: offset, options: options, format: :JSON).
        delete_if { |_, v| v.nil? || (v.is_a?(Array) && v.empty?) }

      params = format_params(replace_param_names(params, param_name_replacements))
      query = URI.encode_www_form(params)
      base_path = web_only ? WEB_ONLY_BASE_PATH : BASE_PATH

      response = in_session do |session|
        request = Net::HTTP::Get.new("#{base_path}/#{operation}?#{query}")
        request.basic_auth(account_key, account_key)
        session.request request
      end

      unless response.is_a?(Net::HTTPOK)
        raise ServiceError.new(response.code, response.body)
      end

      raw = JSON.parse(response.body)

      unless raw['d'] && raw['d']['results']
        raise "Unexpected response format"
      end

      parse raw['d']['results']
    end

    # @yield [Net::HTTP]
    # @return [Net::HTTPResponse]
    #
    def in_session
      if open?
        yield @session
      else
        open { yield @session }
      end
    end

    # @param [Object] value
    # @param [Module] module_
    # @return [Object]
    #
    def enum_value(value, module_)
      case value
      when Symbol
        enum_from_symbol(value, module_)
      when Array
        value.collect { |element| enum_value(element, module_) }
      else
        value
      end
    end

    # @param [Symbol] symbol
    # @param [Module] module_
    # @return [Object]
    # @raise [ArgumentError]
    #   The module does not contain a constant corresponing to the symbol
    #
    def enum_from_symbol(symbol, module_)
      [Util.camelcase(symbol.to_s), symbol.to_s.upcase].each do |const|
        return module_.const_get(const) if module_.const_defined?(const)
      end
      raise ArgumentError, "#{module_} does not contain a constant corresponding to #{symbol}"
    end

    # @param [Hash{Symbol => Object}] params
    # @return [Hash{String => Object}]
    #
    def replace_param_names(params, replacements)
      params.each_with_object(Hash.new) do |(key, value), hash|
        key = replacements[key] || GENERAL_PARAM_NAME_REPLACEMENTS[key] || Util.camelcase(key.to_s)
        hash[key] = value
      end
    end

    # @param [Hash] params
    # @return [Hash]
    #
    def format_params(params)
      params.each_with_object(Hash.new) do |(key, value), hash|
        hash[key] = format(value)
      end
    end

    # @param [Object] value
    # @return [String]
    #
    def format(value)
      case value
      when String then format_string(value)
      when Array then format_array(value)
      else value
      end
    end

    # @param [String] string
    # @return [String]
    #
    def format_string(string)
      "'#{string}'"
    end

    # @param [Array] array
    # @return [String]
    #
    def format_array(array)
      "'#{array.join '+'}'"
    end

    # @param [Object] raw
    # @param [Symbol, nil] type
    # @return [Object]
    #
    def parse(raw, type = nil)
      if type
        parse_typed raw, type
      elsif raw.is_a?(Array)
        raw.collect { |element| parse element }
      elsif raw_model?(raw)
        parse_model raw
      else
        raw
      end
    end

    # @param [Object] raw
    # @param [Symbol] type
    # @return [Object, nil]
    # @raise [ArgumentError]
    #
    def parse_typed(raw, type)
      case type
      when :datetime
        raw.empty? ? nil : DateTime.parse(raw)
      when :integer
        raw.empty? ? nil : Integer(raw)
      else
        raise ArgumentError, "Can't parse value #{raw} of type #{type}"
      end
    end

    # @param [Object] raw
    # @return [Model]
    #
    def parse_model(raw)
      raw_type = raw['__metadata']['type']
      model = model_class(raw_type).new
      attr_to_type = RAW_MODEL_TYPE_TO_ATTR_TO_TYPE[raw_type] || {}

      for key, value in raw
        next if key == '__metadata'
        attr = Util.underscore(key).to_sym
        model.set attr, parse(value, attr_to_type[attr])
      end

      model
    end

    # @param [Object] raw
    # @return [Boolean]
    #
    def raw_model?(raw)
      raw.is_a?(Hash) && raw['__metadata'] && raw['__metadata']['type']
    end

    # @param [String] raw_type
    # @return [Class]
    # @raise [ArgumentError]
    #
    def model_class(raw_type)
      unless RAW_MODEL_TYPES.include?(raw_type)
        raise ArgumentError, "Invalid model type: #{raw_type}"
      end

      case raw_type
      when 'Bing.Thumbnail'
        Image
      when 'SpellResult'
        SpellingSuggestionsResult
      when 'ExpandableSearchResult'
        CompositeSearchResult
      else
        BingSearch.const_get(raw_type)
      end
    end


    HOST = 'api.datamarket.azure.com'
    private_constant :HOST

    BASE_PATH = '/Bing/Search'
    private_constant :BASE_PATH

    WEB_ONLY_BASE_PATH = '/Bing/SearchWeb'
    private_constant :WEB_ONLY_BASE_PATH

    GENERAL_PASSTHROUGH_OPTS = %i(limit adult latitude longitude market)
    private_constant :GENERAL_PASSTHROUGH_OPTS

    GENERAL_ENUM_OPT_TO_MODULE = {adult: Adult}
    private_constant :GENERAL_ENUM_OPT_TO_MODULE

    GENERAL_PARAM_NAME_REPLACEMENTS = {
      limit: '$top',
      offset: '$skip',
      format: '$format',
    }
    private_constant :GENERAL_PARAM_NAME_REPLACEMENTS

    RAW_MODEL_TYPES = %w{
      WebResult
      ImageResult
      VideoResult
      NewsResult
      RelatedSearchResult
      SpellResult
      ExpandableSearchResult
      Bing.Thumbnail
    }
    private_constant :RAW_MODEL_TYPES

    RAW_MODEL_TYPE_TO_ATTR_TO_TYPE = {
      'ImageResult' => {
        width: :integer,
        height: :integer
      },
      'NewsResult' => {
        date: :datetime
      },
      'VideoResult' => {
        run_time: :integer
      },
      'ExpandableSearchResult' => {
        web_total: :integer,
        web_offset: :integer,
        image_total: :integer,
        image_offset: :integer,
        video_total: :integer,
        video_offset: :integer,
        news_total: :integer,
        news_offset: :integer,
        spelling_suggestions_total: :integer
      }
    }
    private_constant :RAW_MODEL_TYPE_TO_ATTR_TO_TYPE

  end
end