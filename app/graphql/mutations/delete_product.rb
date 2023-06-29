# frozen_string_literal: true

module Mutations
  # represents a GraphQL mutation for deleting a product.
  class DeleteProduct < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      product = Product.find(id)

      if product.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: product.errors.full_messages }
      end
    end
  end
end
