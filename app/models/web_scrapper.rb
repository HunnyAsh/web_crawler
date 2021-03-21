class WebScrapper < Kimurai::Base
  @name = SPIDER_NAME
  @engine = :mechanize
  @start_urls = START_URLS
  @config = {
    user_agent: CONFIG_USER_AGENT
  }

  attr_accessor :links, :header_crawl_cnt
  @@sitemap = {}

  def parse(response, url:, data: {})
    @header_crawl_cnt = 0
    crawl_pages(response, url)
    fetch_assets(response, url)
  end

  def self.close_spider
    pages_available = @@sitemap.keys
    pages_available.each do |page_available|
      linked_pages = @@sitemap.dig(page_available, :links).pluck(:name)
      puts '==========================================================='
      puts "#{page_available} is linked with #{linked_pages.join(', ')}"
      puts '==========================================================='
    end
  end

  private

  def not_linked?(link)
    link.values.any? { |val| val.include?('https') }
  end

  def parse_header(response)
    @links = []
    header_links = response.xpath('//header[@id="orb-banner"]//a')
    header_links.each do |header_link|
      header_link_value = header_link.attribute('href').value
      @links.push({ name: header_link.name, path: header_link_value }) if valid_link?(header_link)
    end
    @header_crawl_cnt += 1
  end

  def crawl_page(link)
    WebScrapper.parse!(:parse, url: link)
  end

  def fetch_assets(response, url)
    page_title = response.xpath('//title').text
    @@sitemap.merge!({ page_title.to_s => {
                       page_url: url,
                       assets: {
                         css_fonts: static_assets(response),
                         js: js_assets(response)
                       },
                       links: page_links(response)
                     } })
  end

  def asset_type(asset)
    asset_type = asset.attribute('type')
    asset_type.present? ? asset_type.value : asset.attribute('rel').value
  end

  def js_asset_value(asset)
    attribute_src = asset.attribute('src')
    attribute_src.present? ? attribute_src.value : 'Compiled JS'
  end

  def homepage?(url)
    WebScrapper.start_urls.include?(url)
  end

  def valid_link?(link)
    link.attribute('href').value.include?('https') if link.attribute('href').present?
  end

  def static_assets(response)
    # CSS Assets
    assets = []
    static_assets = response.xpath('//head//link')
    static_assets.each do |asset|
      assets.push({ asset_type: asset_type(asset), url: asset.attribute('href').value })
    end
    assets
  end

  def js_assets(response)
    # JS Assets
    assets_js = []
    js_assets = response.xpath('//head//script')
    js_assets.each do |asset|
      assets_js.push({ name: asset.name, value: js_asset_value(asset) })
    end
    assets_js
  end

  def page_links(response)
    # Page Links
    page_links = []
    pg_links = response.xpath('//body//a')
    pg_links.each do |link|
      page_links.push({ name: link.text, value: link.attribute('href').value }) if valid_link?(link)
    end
    page_links
  end

  def crawl_pages(response, url)
    parse_header(response) if homepage?(url)
    @links.each { |link| crawl_page(link[:path]) } if @header_crawl_cnt == 1
  end
end
