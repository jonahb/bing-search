module AccessKeySetup
  ACCESS_KEY_ENVIRONMENT_VARIABLE = 'BING_SEARCH_ACCESS_KEY'

  attr_reader :access_key

  def setup
    @access_key = ENV[ACCESS_KEY_ENVIRONMENT_VARIABLE]

    unless access_key
      raise "Set the #{ACCESS_KEY_ENVIRONMENT_VARIABLE} environment variable to" +
        " an Access Key obtained from the Azure Marketplace. The" +
        " Access Key should be authorized for both the Bing Search API" +
        " and the Web-Only Bing Search API."
    end
  end
end
