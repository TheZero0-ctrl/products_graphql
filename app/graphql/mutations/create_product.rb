# frozen_string_literal: true

module Mutations
  # represents a GraphQL mutation for creating a product.
  class CreateProduct < Mutations::BaseMutation
    argument :name, String, required: true
    argument :code, String, required: true
    argument :images, [ApolloUploadServer::Upload], required: false

    field :product, Types::ProductType, null: true
    field :errors, [String], null: false

    def resolve(name:, code:, images: nil)
      product = Product.new(name:, code:)
      attach_images(product, images)
      if product.save
        { product:, errors: [] }
      else
        { product: nil, errors: product.errors.full_messages }
      end
    end
  end
end
