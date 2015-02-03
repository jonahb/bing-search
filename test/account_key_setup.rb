module AccountKeySetup
  ACCOUNT_KEY_ENVIRONMENT_VARIABLE = 'BING_SEARCH_ACCOUNT_KEY'

  attr_reader :account_key

  def setup
    @account_key = ENV[ACCOUNT_KEY_ENVIRONMENT_VARIABLE]

    unless account_key
      raise "Set the #{ACCOUNT_KEY_ENVIRONMENT_VARIABLE} environment variable to" +
        " an Account Key obtained from the Azure Marketplace. The" +
        " Account Key should be authorized for both the Bing Search API" +
        " and the Web-Only Bing Search API."
    end
  end
end
