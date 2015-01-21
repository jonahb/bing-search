require_relative 'setup'

class ClientTest < MiniTest::Test
  include AccessKeySetup

  QUERY = 'cat'

  attr_reader :client

  def setup
    super
    @client = BingSearch::Client.new(access_key: access_key)
  end

  def test_initialize_uses_access_key_if_provided
    access_key = 'hello'
    client = BingSearch::Client.new(access_key: access_key)
    assert_equal access_key, client.access_key
  end

  def test_initialize_uses_static_access_key_if_access_key_not_provided
    BingSearch.access_key = access_key
    client = BingSearch::Client.new
    assert_equal access_key, client.access_key
  end

  def test_web_only_client_returns_web_results
    client = BingSearch::Client.new(access_key: access_key, web_only: true)
    client.web QUERY
  end

  def test_web_only_client_raises_with_non_web_source
    client = BingSearch::Client.new(web_only: true)
    assert_raises(BingSearch::ServiceError) { client.image QUERY }
  end

  def test_open_without_block_leaves_client_open
    begin
      client.open
      assert client.open?
    ensure
      client.close
    end
  end

  def test_open_with_block_opens_client_for_duration_of_block
    client.open do
      assert client.open?
      client.web QUERY
    end
    refute client.open?
  end

  def test_class_open
    client = BingSearch::Client.open(access_key: access_key) do |client|
      assert client.open?
      client.web QUERY
    end
    refute client.open?
  end

  def test_invalid_enum_value_raises
    assert_raises(ArgumentError) { client.image(QUERY, filters: [:invalid]) }
  end

  def test_empty_query_returns_empty_array
    assert_equal [], client.web('')
  end

  def test_web_returns_web_results
    results = client.web(QUERY)
    refute results.empty?
    assert results.all? { |result| result.is_a?(BingSearch::WebResult) }
  end

  def test_web_with_all_options
    client.web(QUERY,
      limit: 10,
      offset: 10,
      adult: :strict,
      latitude: 47.6,
      longitude: 122.1,
      market: 'en-US',
      location_detection: false,
      file_type: :ppt,
      highlighting: true,
      host_collapsing: false,
      query_alterations: false)
  end

  def test_web_limit_option_limits_results
    limit = 5
    results = client.web(QUERY, limit: limit)
    assert_equal limit, results.count
  end

  def test_web_offset_option_alters_first_result
    result1 = client.web(QUERY, limit: 1, offset: 0).first
    result2 = client.web(QUERY, limit: 1, offset: 1).first
    refute_equal result1.url, result2.url
  end

  def test_web_highlighting_option_adds_delimiter_to_descriptions
    results = client.web(QUERY, highlighting: true)
    assert results.first.description =~ /#{BingSearch::HIGHLIGHT_DELIMITER}/
  end

  def test_image_returns_image_results
    results = client.image(QUERY)
    refute results.empty?
    assert results.all? { |result| result.is_a?(BingSearch::ImageResult) }
  end

  def test_image_minimum_dimensions_limit_size
    width = 1024
    height = 768
    results = client.image(QUERY, minimum_width: width, minimum_height: height)
    refute results.empty?
    assert results.all? { |result| result.width >= width && result.height >= height }
  end

  def test_news_returns_news_results
    results = client.news(QUERY)
    refute results.empty?
    assert results.all? { |result| result.is_a?(BingSearch::NewsResult) }
  end

  def test_news_highlighting_option_adds_delimiter_to_descriptions
    results = client.news(QUERY, highlighting: true)
    assert results.first.description =~ /#{BingSearch::HIGHLIGHT_DELIMITER}/
  end

  def test_video_returns_video_results
    results = client.video(QUERY)
    refute results.empty?
    assert results.all? { |result| result.is_a?(BingSearch::VideoResult) }
  end

  def test_video_filter_limits_duration
    results = client.video(QUERY, filters: [:short])
    refute results.empty?
    assert results.all? { |result| result.duration < 300_000 }
  end

  def test_related_search_returns_related_search_results
    results = client.related(QUERY)
    refute results.empty?
    assert results.all? { |result| result.is_a?(BingSearch::RelatedSearchResult) }
  end

  def test_spelling_suggestions_search_returns_spelling_suggestions_results
    results = client.spelling('barak obama')
    assert_equal 1, results.count
    assert_equal 'barack obama', results.first.suggestion
  end

  def test_composite_with_web_and_image_sources_returns_web_and_image_results
    result = client.composite(QUERY, [:web, :image])
    assert result.is_a?(BingSearch::CompositeSearchResult)
    refute result.web.empty?
    refute result.image.empty?
  end

  def test_composite_with_all_sources_and_options
    client.composite(QUERY,
      %i(web image video news spelling_suggestions related_search),
      limit: 10,
      offset: 10,
      adult: :strict,
      latitude: 47.6,
      longitude: 122.1,
      market: 'es-ES',
      location_detection: false,
      highlighting: true,
      web_file_type: :doc,
      web_host_collapsing: false,
      web_query_alterations: false,
      image_minimum_width: 768,
      image_minimum_height: 1024,
      image_filters: [:color, :face],
      video_filters: [:long, :standard_aspect],
      video_sort: :date,
      news_category: :business,
      news_location_override: 'US.WA',
      news_sort: :date)
  end
end
