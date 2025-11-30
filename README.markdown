Feedbag
=======

[![Tests](https://github.com/damog/feedbag/actions/workflows/test.yml/badge.svg)](https://github.com/damog/feedbag/actions/workflows/test.yml)
[![Gem Version](https://badge.fury.io/rb/feedbag.svg)](https://badge.fury.io/rb/feedbag)
[![Downloads](https://img.shields.io/gem/dt/feedbag.svg)](https://rubygems.org/gems/feedbag)
[![License](https://img.shields.io/github/license/damog/feedbag.svg)](https://github.com/damog/feedbag/blob/master/COPYING)

Feedbag is Ruby's favorite feed auto-discovery tool/library!

### Quick synopsis

```ruby
>> require "feedbag"
=> true
>> Feedbag.find "damog.net/blog"
=> ["http://damog.net/blog/atom.xml"]
>> Feedbag.feed? "google.com"
=> false
>> Feedbag.feed?("https://daringfireball.net/feeds/main")
=> true
```

### Installation

    $ gem install feedbag

Or just grab feedbag.rb and use it on your own project:

    $ wget https://raw.githubusercontent.com/damog/feedbag/master/lib/feedbag.rb

You can also use the command line tool for quick queries, if you install the gem:

    » feedbag https://www.ruby-lang.org/en/
    == https://www.ruby-lang.org/en/:
     - https://www.ruby-lang.org/en/feeds/news.rss
    

### Usage

Feedbag will find RSS, Atom, and JSON feed types:

```ruby
>> Feedbag.find('https://daringfireball.net')
=> ["https://daringfireball.net/feeds/main", "https://daringfireball.net/feeds/json"]
```

#### Custom User-Agent

Feedbag defaults to a User-Agent string of `Feedbag/VERSION`, but you can override it:

```ruby
>> Feedbag.find('https://kottke.org', 'User-Agent' => "My Personal Agent/1.0.1")
=> ["http://feeds.kottke.org/main"]
```

Other options passed to `find` will be forwarded to OpenURI:

```ruby
Feedbag.find("https://example.com", 'User-Agent' => "My Agent/1.0", open_timeout: 10)
```

See [OpenURI options](https://rubyapi.org/o/openuri/openread#method-i-open) for more details.

#### Custom Logger

By default, errors are written to `$stderr`. You can redirect them to a custom logger:

```ruby
# Use Rails logger
Feedbag.logger = Rails.logger

# Or silence all output
Feedbag.logger = Logger.new('/dev/null')
```

#### Non-ASCII URL Support

Feedbag handles internationalized URLs (IRIs) with non-ASCII characters:

```ruby
>> Feedbag.find("https://example.com/中文/feed/")
# Works! URLs are automatically normalized
```

### Why should you use it?

- Because it only uses [Nokogiri](http://nokogiri.org/) and [Addressable](https://github.com/sporkmonger/addressable) as dependencies.
- Because it follows modern feed filename conventions (like those ones used by WordPress blogs, or Blogger, etc).
- Because it's a single file you can embed easily in your application.
- Because it handles international URLs with non-ASCII characters.
- Because it's faster than anything else.

### Author

[David Moreno](http://damog.net/) <[damog@damog.net](mailto:damog@damog.net)>.

### Donations

![Superfeedr](https://raw.githubusercontent.com/damog/feedbag/master/img/superfeedr_150.png)

[Superfeedr](http://superfeedr.com) has kindly financially [supported](https://github.com/damog/feedbag/issues/9) the development of Feedbag.

### Copyright

This is and will always be free software. See [COPYING](https://raw.githubusercontent.com/damog/feedbag/master/COPYING) for more information.
