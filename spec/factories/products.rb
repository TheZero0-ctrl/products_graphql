# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "product #{n}" }
    sequence(:code) { |n| "code#{n}" }

    after(:build) do |product|
      Dir.glob(Rails.root.join('app', 'assets', 'images', 'seeds', 'product1', '*.jpg')) do |file|
        product.images.attach(io: File.open(file), filename: File.basename(file))
      end
    end
  end
end
