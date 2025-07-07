Async-Feedbag
=======

Async-Feedbag is a fork of Ruby's favorite auto-discovery tool/library, using [async-http](https://github.com/socketry/async-http) for the requests.

### Quick synopsis

```ruby
>> require "async-feedbag"
=> true
>> AsyncFeedbag.find "damog.net/blog"
=> ["http://damog.net/blog/atom.xml"]
>> AsyncFeedbag.feed? "perl.org"
=> false
>> AsyncFeedbag.feed?("https://m.signalvnoise.com/feed")
=> true
```

### Installation

    $ gem install async-feedbag

Or just grab async-feedbag.rb and use it on your own project:

    $ wget https://raw.githubusercontent.com/renatolond/feedbag/main/lib/async-feedbag.rb

You can also use the command line tool for quick queries, if you install the gem:

    » feedbag https://www.ruby-lang.org/en/
    == https://www.ruby-lang.org/en/:
    - https://www.ruby-lang.org/en/feeds/news.rss

### Usage
Feedbag will find all RSS feed types.  Here's an example of finding ATOM and JSON Feed

```ruby
> AsyncFeedbag.find('https://daringfireball.net')
=> ["https://daringfireball.net/feeds/main", "https://daringfireball.net/feeds/json", "https://daringfireball.net/linked/2021/02/17/bookfeed"]
```

Feedbag defaults to a User-Agent string of **AsyncFeedbag/1.10.2**, however you can override this

```ruby
0> AsyncFeedbag.find('https://kottke.org', 'User-Agent' => "My Personal Agent/1.0.1")
=> ["http://feeds.kottke.org/main", "http://feeds.kottke.org/json"]
````

The other options passed to find, will be passed to OpenURI. For example:

```ruby
AsyncFeedbag.find("https://kottke.org", 'User-Agent' => "My Personal Agent/1.0.1", open_timeout: 1000)
```

You can find the other options to OpenURI [here](https://rubyapi.org/o/openuri/openread#method-i-open).


### Why should you use it?

- Because it only uses [Nokogiri](http://nokogiri.org/) as dependency.
- Because it follows modern feed filename conventions (like those ones used by WordPress blogs, or Blogger, etc).
- Because it's a single file you can embed easily in your application.
- Because it's faster than anything else.

### Author

[David Moreno](http://damog.net/) <[damog@damog.net](mailto:damog@damog.net)> is the original author of [feedbag](https://github.com/damog/feedbag).
[Renato "Lond" Cerqueira](https://lond.com.br) is the author of the async fork.

### Donations

![Superfeedr](https://raw.githubusercontent.com/damog/feedbag/master/img/superfeedr_150.png)

[Superfeedr](http://superfeedr.com) has kindly financially [supported](https://github.com/damog/feedbag/issues/9) the development of Feedbag.

### Copyright

This is and will always be free software. See [COPYING](https://raw.githubusercontent.com/renatolond/feedbag/master/COPYING) for more information.
