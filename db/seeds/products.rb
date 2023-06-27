# frozen_string_literal: true

product1 = Product.create!(code: 'AABBCC', name: 'main product')
product2 = Product.create!(code: 'B09BRDXB7N', name: 'second product')

# Attach images to the resource
Dir.glob(Rails.root.join('app', 'assets', 'images', 'seeds', 'product1', '*.jpg')) do |file|
  product1.images.attach(io: File.open(file), filename: File.basename(file))
end

Dir.glob(Rails.root.join('app', 'assets', 'images', 'seeds', 'product_2', '*.jpg')) do |file|
  product2.images.attach(io: File.open(file), filename: File.basename(file))
end
