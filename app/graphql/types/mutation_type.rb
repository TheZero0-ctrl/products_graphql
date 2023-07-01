# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_product, mutation: Mutations::CreateProduct
    field :update_product, mutation: Mutations::UpdateProduct
    field :delete_product, mutation: Mutations::DeleteProduct

    field :create_bulk_upload, mutation: Mutations::CreateBulkUpload
  end
end
