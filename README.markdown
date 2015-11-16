Feedbag
=======

Feedbag is Ruby's favorite auto-discovery tool/library!

### Quick synopsis

    >> require "feedbag"
    => true
    >> Feedbag.find "damog.net/blog"
    => ["http://damog.net/blog/index.rss", "http://damog.net/blog/tags/feed", "http://damog.net/blog/tags/rfeed"]
    >> Feedbag.feed? "perl.org"
    => false
    >> Feedbag.feed?("http://jobs.perl.org/rss/standard.rss")
    => true

### Installation

    $ gem install feedbag

Or just grab feedbag.rb and use it on your own project:

    $ wget http://github.com/damog/feedbag/raw/master/lib/feedbag.rb

You can also use the command line tool for quick queries, if you install the gem:

    $ feedbag http://rubygems.org/profiles/damog
    == http://rubygems.org/profiles/damog:
     - http://feeds.feedburner.com/gemcutter-latest

### Why should you use it?

- Because it only uses [Nokogiri](http://nokogiri.org/) as dependency.
- Because it follows modern feed filename conventions (like those ones used by WordPress blogs, or Blogger, etc).
- Because it's a single file you can embed easily in your application.
- Because it's faster than rfeedfinder.

### Author

[David Moreno](http://damog.net/) <[david@axiombox.com](mailto:david@axiombox.com)>.

### Donations

![Superfeedr](http://damog.net/files/misc/superfeedr_150.png)

[Superfeedr](http://superfeedr.com) has kindly financially [supported](https://github.com/damog/feedbag/issues/9) the development of Feedbag.

### Copyright

This is free software. See [COPYING](https://raw.githubusercontent.com/damog/feedbag/master/COPYING) for more information.
