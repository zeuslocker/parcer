require 'nokogiri'
require 'open-uri'
require 'json'
require 'pry'
require 'net/http'
require 'active_support/core_ext/object/to_query'


def categories()
  categories = []
  categories << [Nokogiri::HTML(open('http://www.citrus.ua/shop/goods/mobile/675/')), 'iPhone']
  categories << [Nokogiri::HTML(open('http://www.citrus.ua/shop/goods/tabletpc/667/')), 'iPad']
  categories << [Nokogiri::HTML(open('http://www.citrus.ua/shop/goods/smart-watches/2070/')), 'Watch']
  categories << [Nokogiri::HTML(open('http://www.citrus.ua/shop/goods/notebooks/669/')), 'MacBook']
  categories << [Nokogiri::HTML(open('http://www.citrus.ua/shop/goods/monoblocks/1427/')), 'Mac']
  categories
end

def product_images(product:)
  images = []
  counter = 0
  product.css('.bb_big_photo_box2 .owl-carousel .item').each do |image|
    str = image.attributes['style'].value
    images << 'http://www.citrus.ua'+str[str.index('/upload'), str.index(')')-str.index('/upload')]
    counter = counter + 1
    break if counter == 4
  end
    str = ''
      images.each{|x| str = str+x+'|'}
      return str
end

def product_price(product:)
  price = nil

    price1 = product.at_css('.price')&.children&.text.delete(' ')
    price1 = price1[1, price1.length-2].to_f
    price2 = product.at_css('.product_price')&.children&.text&.delete(' ').to_f
  if price1 > product.at_css('.product_price')&.text.to_f
    price = price1
  else
    price = price2
  end
  price
end

def product_description(product:)
  product.at_css('p[20]')&.text || 'ttttttrrruuueeee'
end

def product_title(product:)
  product.at_css('h1')&.text
end

def product_property_data(product:)
  str = ''
  product.css('.variations .select_box').each do |x|
     str << x.css('span').children.text.chop+" "
     str << x.css('.active').text+" "
     str << 'current'
     binding.pry
  end
end

def product_show_case(product:)
  show_case = product.at_css('.tabs_content')&.to_html
  return show_case if !show_case
  show_case.gsub!("/upload", "http://www.citrus.ua/upload")
  show_case.gsub!("/images", "http://www.citrus.ua/images")
  return show_case
end

def product_variations(product:)
  all_variations = product.css('.variations .select_box a').map{|x| x.attributes['href'].value }
  active_variations = product.css('.variations .select_box .active').map{|x| x.attributes['href'].value }
  (all_variations - active_variations)
end

def parcer_core
  productsArr = []
  product_group_id = 1
  product_codes = []
  categories.each do |category_doc, category_name|
   category_doc.css('.module_item .el_pic table tr td a').each do |product_block|
     product = 'http://www.citrus.ua'+product_block.attributes['href'].value #open url
     product =  Nokogiri::HTML(open(product)) #open product

     uniq_number = product.at_css('div div span[style="padding:5px; background-color: #fbfdcd; border-radius: 3px; font-size: 14px;"]').
      children.text.tr('^/0-9/', '').to_i
    next if product_codes.include? uniq_number
    product_codes << uniq_number
  #   secondary_parcer(variations:product_variations(product: product),
  #                                                  products_array: productsArr,
  #                                                  group_id: product_group_id,
  #                                                  category_name: category_name,
  #                                                  product_codes: product_codes)

  sc = product_show_case(product: product)
  params = {utf8: "✓",
    product:
      {title: product_title(product: product),
       description: product_description(product: product),
       spec: "superspecs",
       show_case: sc,
       price: product_price(product: product),
       category_type: category_name,
       images_links: product_images(product: product),
       group: 0,
       property_data: product_property_data(product: product),
       subcategory: ""},
       commit: "Create Product",
       controller: "products",
       action: "create"}

   binding.pry
   uri = URI('http://localhost:3000/products')
   http = Net::HTTP.new(uri.host, 3000)
   response = http.post(uri.path, params.to_query)

     product_group_id = product_group_id + 1
   end
  end
end

def secondary_parcer(variations:, products_array: , group_id:, category_name:, product_codes:)
  variations.each do |variation|
    product = 'http://www.citrus.ua'+variation
    product =  Nokogiri::HTML(open(product))

    uniq_number = product.at_css('div div span[style="padding:5px; background-color: #fbfdcd; border-radius: 3px; font-size: 14px;"]').
     children.text.tr('^/0-9/', '').to_i
    next if product_codes.include? uniq_number
    product_codes << uniq_number
  end
end
parcer_core
