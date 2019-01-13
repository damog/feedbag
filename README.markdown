Feedbag
=======

Feedbag is Ruby's favorite auto-discovery tool/library!

### Quick synopsis

```ruby
>> require "feedbag"
=> true
>> Feedbag.find "damog.net/blog"
=> ["http://damog.net/blog/atom.xml"]
>> Feedbag.feed? "perl.org"
=> false
>> Feedbag.feed?("https://m.signalvnoise.com/feed")
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

### Why should you use it?

- Because it only uses [Nokogiri](http://nokogiri.org/) as dependency.
- Because it follows modern feed filename conventions (like those ones used by WordPress blogs, or Blogger, etc).
- Because it's a single file you can embed easily in your application.
- Because it's faster than anything else.

### Author

[David Moreno](http://damog.net/) <[damog@damog.net](mailto:damog@damog.net)>.

### Donations

![Superfeedr](https://raw.githubusercontent.com/damog/feedbag/master/img/superfeedr_150.png)

[Superfeedr](http://superfeedr.com) has kindly financially [supported](https://github.com/damog/feedbag/issues/9) the development of Feedbag.

### Copyright

This is and will always be free software. See [COPYING](https://raw.githubusercontent.com/damog/feedbag/master/COPYING) for more information.
