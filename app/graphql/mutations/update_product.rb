# frozen_string_literal: true

module Mutations
  # represents a GraphQL mutation for updating a product.
  class UpdateProduct < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :code, String, required: false
    argument :images, [ApolloUploadServer::Upload], required: false

    field :product, Types::ProductType, null: true
    field :errors, [String], null: false

    def resolve(id:, name: nil, images: nil, code: nil)
      product = Product.find(id)

      attributes = { name:, code: }.compact
      product.assign_attributes(attributes)
      attach_images(product, images)

      if product.save
        { product:, errors: [] }
      else
        { product: nil, errors: product.errors.full_messages }
      end
    end
  end
end
