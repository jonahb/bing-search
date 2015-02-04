# bing-search

A Ruby client for the [Bing Search API](http://datamarket.azure.com/dataset/bing/search).

[![Gem Version](https://badge.fury.io/rb/bing-search.svg)](http://badge.fury.io/rb/bing-search)
[![Build Status](https://travis-ci.org/jonahb/bing-search.svg?branch=master)](https://travis-ci.org/jonahb/bing-search)

## Getting Started

### Installation

```bash
gem install bing-search
```

### Signup

Sign up for the [Bing Search API](https://datamarket.azure.com/dataset/bing/search) or the [Web-Only Bing Search API](https://datamarket.azure.com/dataset/bing/searchweb) at the Microsoft Azure Marketplace. Then retrieve your Account Key from the [My Account](https://datamarket.azure.com/account) section of the marketplace and provide it as shown below.

### Documentation

This README provides an overview of bing-search. Full documentation is available at [rubydoc.info](http://www.rubydoc.info/gems/bing-search).

## Basics

To use bing-search, first supply your Account Key:

```ruby
BingSearch.account_key = 'hzy9+Y6...'
```

Then, use {BingSearch.web} to search for web pages:

```ruby
results = BingSearch.web('Dirac')
```

Or, use the other {BingSearch} class methods to search for images, news, video, related searches, and spelling suggestions:

```ruby
BingSearch.spelling('Feinman').first.suggestion # => "Feynman"
```

The type of result depends on the kind of search:

```ruby
BingSearch.web('Gell-Mann').class # => WebResult
BingSearch.image('Pauli').class # => ImageResult
BingSearch.video('von Neumann').class # => VideoResult
```

And each result type has its own attributes:

```ruby
web = BingSearch.web('Gell-Mann').first
web.summary # => "Murray Gell-Mann (born September 15, 1929) is an American physicist ..."

image = BingSearch.image('Pauli').first
image.media_type # => "image/jpeg"

video = BingSearch.video('von Neumann').first
video.duration # => 151000
```

See the documentation of the result types for a full list of the attributes.

## Options

The search methods take options that control the number of results returned;

```ruby
BingSearch.web('Dyson', limit: 5).count # => 5
```

the size, orientation, and contents of images;

```ruby
BingSearch.image 'Tesla', filters: [:large, :wide, :photo, :face]
```

whether to {BingSearch::HIGHLIGHT_DELIMITER highlight} query terms in the results;

```ruby
BingSearch.news('Hawking', highlighting: true).first.title # => "How Intel Gave Stephen Hawking a Voice"
```

and many other aspects of the search. Note that "enumeration" options—those whose values are module-level constants—may be provided as underscored symbols:

```ruby
# equivalent searches
BingSearch.news 'Higgs', category: BingSearch::NewsCategory::ScienceAndTechnology
BingSearch.news 'Higgs', category: :science_and_technology
```

See {BingSearch::Client} for exhaustive documentation of the options.

## Composite Searches

To retrieve multiple result types at once, use {BingSearch.composite}:

```ruby
result = BingSearch.composite('Majorana', [:web, :image, :news])
```

The result is a {BingSearch::CompositeSearchResult} ...

```ruby
result.class # => BingSearch::CompositeResult
```

... containing an array for each result type:

```ruby
result.web.first.class # => BingSearch::WebResult
result.image.first.class # => BingSearch::ImageResult
result.news.first.class # => BingSearch::NewsResult
```

All of the single-type search options are supported in composite searches, though the names may have prefixes to specify the type they pertain to:

```ruby
BingSearch.composite 'Fermi', [:image, :video], image_filters: [:small], video_filters: [:short]
```

Composite searches also give you access to more data about the search including the total number of results in the Bing index and whether Bing corrected apparent errors in the query text:

```ruby
result = BingSearch.composite('Feyman', [:web, :image, :news])
result.web_total # => 2400000
result.altered_query # => "feynman"
```

## Web-Only API

To use the less expensive [web-only API](https://datamarket.azure.com/dataset/bing/searchweb), set {BingSearch.web_only}:

```ruby
BingSearch.web_only = true
BingSearch.news 'Newton' # => BingSearch::ServiceError
BingSearch.web 'Newton'
```

## BingSearch::Client

{BingSearch::Client} is the class underlying the {BingSearch} class methods. You can use it on its own to run multiple searches over a single TCP connection:

```ruby
BingSearch::Client.open do |client|
  client.web 'Lee'
  client.web 'Wu'
  client.web 'Yang' 
end
```

Or to override global settings:

```ruby
client = BingSearch::Client.new(account_key: 'hzy9+Y6...', web_only: true)
```

## Tests

To run the tests:

1. Sign up for both the standard and web-only APIs
2. Set the environment variable BING\_SEARCH\_ACCOUNT\_KEY to your Account Key
3. `rake`

## Contributing

Please submit issues and pull requests to [jonahb/bing-search](http://github.com/jonahb/bing-search) on GitHub.

