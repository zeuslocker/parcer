require 'nokogiri'
require 'open-uri'
require 'json'
require 'pry'
categories = []
categories << open('http://www.citrus.ua/shop/goods/mobile/675/')
categories << open('http://www.citrus.ua/shop/goods/tabletpc/667/')
categories << open('http://www.citrus.ua/shop/goods/smart-watches/2070/')
categories << open('http://www.citrus.ua/shop/goods/notebooks/669/')
categories << open('http://www.citrus.ua/shop/goods/monoblocks/1427/')

documents = categories.map do |category|
  Nokogiri::HTML(category)
end
products = []
documents.each do |doc|
  doc.css('.module_item .el_pic table tr td a').each do |photo|
    products << 'http://www.citrus.ua'+photo.attributes['href'].value
  end
end
productsArr = []
products.each do |product|
product =  Nokogiri::HTML(open(product))
images = []
  product.css('.bb_big_photo_box2 .owl-carousel .item').each do |image|
    str = image.attributes['style'].value
  images << 'http://www.citrus.ua'+str[str.index('/upload'), str.index(')')-str.index('/upload')]
  end
p  product.at_css('h1').text

  productsArr.push(
  images: images,
  )
end
