Feedbag
=======
> Do you want me to drag my sack across your face?
>                                 - Glenn Quagmire

Feedbag is a feed auto-discovery Ruby library. You don't need to know more about it. It is said to be:

> Ruby's favorite auto-discovery tool/library!

### Quick synopsis

	>> require "rubygems"
	=> true
	>> require "feedbag"
 	=> true
 	>> Feedbag.find "log.damog.net"
 	=> ["http://feeds.feedburner.com/TeoremaDelCerdoInfinito", "http://log.damog.net/comments/feed/"]
	>> Feedbag.feed?("google.com")
	=> false
	>> Feedbag.feed?("http://planet.debian.org/rss20.xml")
	=> true

### Installation

	$ sudo gem install damog-feedbag -s http://gems.github.com/

Or just grab feedbag.rb and use it on your own project:

	$ wget http://github.com/damog/feedbag/raw/master/lib/feedbag.rb

## Tutorial

So you want to know more about it.

OK, if the URL passed to the find method is a feed itself, that only feed URL will be returned.

	>> Feedbag.find "github.com/damog.atom"
	=> ["http://github.com/damog.atom"]
	>> 

Otherwise, it will always return LINK feeds first, A (anchor tags) feeds later. Between A feeds, the ones hosted on the same URL's host, will have larger priority:

	>> Feedbag.find "http://ve.planetalinux.org"
	=> ["http://feedproxy.google.com/PlanetaLinuxVenezuela", "http://rendergraf.wordpress.com/feed/", "http://rootweiller.wordpress.com/feed/", "http://skatox.com/blog/feed/", "http://kodegeek.com/atom.xml", "http://blog.0x29.com.ve/?feed=rss2&cat=8"]
	>> 

On your application you should only take the very first element of the array, most of the times:

	>> Feedbag.find("planet.debian.org").first(3)
	=> ["http://planet.debian.org/rss10.xml", "http://planet.debian.org/rss20.xml", "http://planet.debian.org/atom.xml"]
	>> 

(Try running that same example without the "first" method. That example's host is a blog aggregator, so it has hundreds of feed URLs:)

	>> Feedbag.find("planet.debian.org").size
	=> 104
	>> 

Feedbag will find them all, but it will return the most important ones on the first elements on the array returned.

	>> Feedbag.find("cnn.com")
	=> ["http://rss.cnn.com/rss/cnn_topstories.rss", "http://rss.cnn.com/rss/cnn_latest.rss", "http://rss.cnn.com/services/podcasting/robinmeade/rss.xml"]
	>> 

### Why should you use it?

- Because it's cool.
- Because it only uses [Hpricot](https://code.whytheluckystiff.net/hpricot/) as dependency.
- Because it follows modern feed filename conventions (like those ones used by WordPress blogs, or Blogger, etc).
- Because it's a single file you can embed easily in your application.
- Because it passes most of the Mark Pilgrim's [Atom auto-discovery test suite](http://diveintomark.org/tests/client/autodiscovery/). It doesn't pass them all because some of those tests are	broken (citation needed).

### Why did I build it?

- Because I liked Benjamin Trott's [Feed::Find](http://search.cpan.org/~btrott/Feed-Find-0.06/lib/Feed/Find.pm).
- Because I thought it would be good to have Feed::Find's functionality in Ruby.
- Because I thought it was going to be easy to maintain.
- Because I was going to use it on [rFeed](http://github.com/damog/rfeed).
- And finally, because I didn't know [rfeedfinder](http://rfeedfinder.rubyforge.org/) existed :-)

### Bugs

Please, report bugs to [rt@support.axiombox.com](rt@support.axiombox.com) or directly to the author.

### Contribute

> git clone git://github.com/damog/feedbag.git

...patch, build, hack and make pull requests. I'll be glad.

### Author

[David Moreno](http://damog.net/) <[david@axiombox.com](mailto:david@axiombox.com)>.

### Copyright

This is free software. See [COPYING](http://github.com/damog/feedbag/master/COPYING) for more information.

### Thanks

[Raquel](http://maggit.net), for making [Axiombox](http://axiombox.com) and most of my dreams possible. Also, [GitHub](http://github.com) for making a nice code sharing service that doesn't suck.

