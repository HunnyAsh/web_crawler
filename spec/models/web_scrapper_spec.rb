require 'rails_helper'

RSpec.describe WebScrapper, type: :model do
  context 'check for parse' do
    before do
      web_scrapper = WebScrapper.crawl!
      @header_crawl_cnt = 0
    end
    describe '#parse' do
      it 'expects header crawl cnt 0' do
        expect(@header_crawl_cnt).to eql(0)
        expect(WebScrapper.parse!).to receive(:parse_header)
        expect(@header_crawl_cnt).to eql(1)
        expect(web_scrapper).to receive(:crawl_pages).with(:response, :url)
        expect(web_scrapper).to receive(:fetch_assets).with(:response, :url)
      end
    end
  end
end
