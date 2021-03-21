class WebScrappersController < ApplicationController
  def index
    @result = WebScrapper.crawl!
    flash[:notice] = @result.present? ? t('scrapping.success') : t('scrapping.error')
  end
end
