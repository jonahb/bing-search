module BingSearch

  class ServiceError < StandardError
    # The error code returned by Bing
    # @return [String]
    attr_reader :code

    # @param [String] code
    #   The error code returned by Bing
    # @param [String] message
    #
    def initialize(code, message = nil)
      super(message)
      @code = code
    end

    # @return [String]
    #
    def to_s
      "Bing error #{code}: #{super}"
    end
  end
end
