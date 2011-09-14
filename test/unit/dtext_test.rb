require "test_helper"

class DTextTest < ActiveSupport::TestCase
  def p(s)
    DText.parse(s)
  end
  
  def test_sanitize
    assert_equal('<p>&lt;</p>', p("<"))
    assert_equal('<p>&gt;</p>', p(">"))
    assert_equal('<p>&amp;</p>', p("&"))
  end
  
  def test_wiki_links
    assert_equal("<p>a <a href=\"/wiki_pages/new?wiki_page%5Btitle%5D=b\">b</a> c</p>", p("a [[b]] c"))
    assert_equal("<p>a <a href=\"/wiki_pages/new?wiki_page%5Btitle%5D=spoiler\">spoiler</a> c</p>", p("a [[spoiler]] c"))
  end
  
  def test_spoilers
    assert_equal("<p>this is</p><div class=\"spoiler\"><p>an inline spoiler</p></div><p>.</p>", p("this is [spoiler]an inline spoiler[/spoiler]."))
    assert_equal("<p>this is</p><div class=\"spoiler\"><p>a block spoiler</p></div><p>.</p>", p("this is\n\n[spoiler]\na block spoiler\n[/spoiler]."))
  end
  
  def test_paragraphs
    assert_equal("<p>a</p>", p("a"))
    assert_equal("<p>abc</p>", p("abc"))
    assert_equal("<p>a<br>b<br>c</p>", p("a\nb\nc"))
    assert_equal("<p>a</p><p>b</p>", p("a\n\nb"))
  end
  
  def test_headers
    assert_equal("<h1>header</h1>", p("h1. header"))
    assert_equal("<h1>header</h1><p>paragraph</p>", p("h1.header\n\nparagraph"))
  end
  
  def test_quote_blocks
    assert_equal('<blockquote><p>test</p></blockquote>', p("[quote]\ntest\n[/quote]"))
    assert_equal("<blockquote>\n<p>a</p>\n<blockquote><p>b</p></blockquote>\n<p>c</p>\n</blockquote>", p("[quote]\na\n[quote]\nb\n[/quote]\nc\n[/quote]"))
  end
  
  def test_urls
    assert_equal('<p>a <a href="http://test.com">http://test.com</a> b</p>', p('a http://test.com b'))
    assert_equal('<p>a <a href="http://test.com/~bob/image.jpg">http://test.com/~bob/image.jpg</a> b</p>', p('a http://test.com/~bob/image.jpg b'))
    assert_equal('<p>a <a href="http://test.com/home.html#toc">http://test.com/home.html#toc</a> b</p>', p('a http://test.com/home.html#toc b'))
    assert_equal('<p>a <a href="http://test.com">http://test.com</a>. b</p>', p('a http://test.com. b'))
    assert_equal('<p>a (<a href="http://test.com">http://test.com</a>) b</p>', p('a (http://test.com) b'))
  end
  
  def test_links
    assert_equal('<p><a href="http://test.com">test</a></p>', p('[url=http://test.com]test[/url]'))
    assert_equal('<p>"1" <a href="http://two.com">2</a></p>', p('"1" [url=http://two.com]2[/url]'))
    assert_equal('<p>"1" <a href="http://three.com">2 &amp; 3</a></p>', p('"1" [url=http://three.com]2 & 3[/url]'))
  end
  
  def test_aliased_urls
    assert_equal('<p>a <a href="http://test.com">bob</a>. b</p>', p('a [url=http://test.com]bob[/url]. b'))
    assert_equal('<p><em><a href="http://test.com">bob</a></em></p>', p('[i][url=http://test.com]bob[/url][/i]'))
  end
  
  def test_lists
    assert_equal('<ul><li>a</li></ul>', p('* a'))
    assert_equal('<ul><li>a</li><li>b</li></ul>', p("* a\n* b").gsub(/\n/, ""))
    assert_equal('<ul><li>a</li><ul><li>b</li></ul></ul>', p("* a\n** b").gsub(/\n/, ""))
    assert_equal('<ul><li><a href="/posts/1">post #1</a></li></ul>', p("* post #1").gsub(/\n/, ""))
  end
  
  def test_inline
    assert_equal('<p><a href="/posts?tags=tag">tag</a></p>', p("{{tag}}"))
    assert_equal('<p><a href="/posts?tags=tag1+tag2">tag1 tag2</a></p>', p("{{tag1 tag2}}"))
    assert_equal('<p><a href="/posts?tags=%3C3">&lt;3</a></p>', p("{{<3}}"))
  end
  
  def test_missing_spoiler_tags
    assert_equal('<div class="spoiler"><p>testing</p></div>', p('[spoiler]testing'))
    assert_equal('<div class="spoiler"><div class="spoiler"><p>testing</p></div></div>', p('[spoiler][spoiler]testing[/spoiler]'))
  end
  
  def test_extra_newlines
    assert_equal('<p>a</p><p>b</p>', p("a\n\n\n\n\n\n\nb\n\n\n\n"))
  end
end