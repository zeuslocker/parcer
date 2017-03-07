require 'nokogiri'
require 'open-uri'
require 'json'
require 'pry'
categories_names=['iPhone', 'iPad', 'Watch', 'MacBook', 'Mac']
categories = []
categories << open('http://www.citrus.ua/shop/goods/mobile/675/')
categories << open('http://www.citrus.ua/shop/goods/tabletpc/667/')
categories << open('http://www.citrus.ua/shop/goods/smart-watches/2070/')
categories << open('http://www.citrus.ua/shop/goods/notebooks/669/')
categories << open('http://www.citrus.ua/shop/goods/monoblocks/1427/')
productsArr = []
documents = categories.map do |category|
  Nokogiri::HTML(category)
end
products = []
product_group_id = 1
secondary_products = []
documents.each_with_index do |doc, index|
  doc.css('.module_item .el_pic table tr td a').each do |photo|
    product = 'http://www.citrus.ua'+photo.attributes['href'].value
    product =  Nokogiri::HTML(open(product))
    images = []

    product.css('.bb_big_photo_box2 .owl-carousel .item').each do |image|
      str = image.attributes['style'].value
      images << 'http://www.citrus.ua'+str[str.index('/upload'), str.index(')')-str.index('/upload')]
    end

    price = nil
    if product.at_css('.price').text.to_f > product.at_css('.product_price').text.to_f
      price = product.at_css('.price').text.to_f
    else
      price = product.at_css('.product_price').text.to_f
    end

  description = product.at_css('p[20]')&.text || 'ttttttrrruuueeee'
  show_case = product.at_css('.tabs_content')&.to_html
  productsArr.push(
  title: product.at_css('h1').text,
  description: description,
  price: price,
  category_type: categories_names[index],
  subcategory: '',
  images_links: images,
  show_case: show_case,
  product_group_id: product_group_id
  )




  all_variations = product.css('.variations .select_box a').map{|x| x.attributes['href'].value }
  active_variations = product.css('.variations .select_box .active').map{|x| x.attributes['href'].value }
  secondary_products = (all_variations - active_variations)

  secondary_products.each do |prod|
    prod = Nokogiri::HTML(open('http://www.citrus.ua'+prod))
    secondary_images = []
    prod.css('.bb_big_photo_box2 .owl-carousel .item').each do |img|
      secondary_str = img.attributes['style'].value
      secondary_images << 'http://www.citrus.ua'+secondary_str[secondary_str.index('/upload'), secondary_str.index(')')-secondary_str.index('/upload')]
    end

    secondary_price = nil
    if prod.at_css('.price').text.to_f > prod.at_css('.product_price').text.to_f
      secondary_price = prod.at_css('.price').text.to_f
    else
      secondary_price = prod.at_css('.product_price').text.to_f
    end

    secondary_description = prod.at_css('p[20]')&.text || 'ttttttrrruuueeee'

    secondary_show_case = prod.at_css('.tabs_content')&.to_html

    productsArr.push(
    title: prod.at_css('h1').text,
    description: secondary_description,
    price: secondary_price,
    category_type: categories_names[index],
    subcategory: '',
    images_links: secondary_images,
    show_case: secondary_show_case,
    product_group_id: product_group_id
    )
    product_group_id = product_group_id + 1
    pp productsArr
  end
end
end
