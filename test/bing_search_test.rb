require 'setup'

class BingSearchTest < MiniTest::Test
  include AccountKeySetup

  QUERY = 'cat'

  def setup
    super
    BingSearch.account_key = account_key
  end

  %i(web image video news related spelling).each do |method|
    define_method("test_#{method}") do
      BingSearch.send method, QUERY
    end
  end

  def test_composite
    BingSearch.composite QUERY, [:web, :image]
  end
end
