require 'minitest/autorun'
require 'bing-search'

ACCOUNT_KEY = ENV['BING_SEARCH_ACCOUNT_KEY'] ||
  raise("Set the BING_SEARCH_ACCOUNT_KEY environment variable to" +
    " an Account Key obtained from the Azure Marketplace. The" +
    " Account Key should be authorized for both the Bing Search API" +
    " and the Web-Only Bing Search API.")

Test = defined?(Minitest::Test) ? Minitest::Test : MiniTest::Unit::TestCase
