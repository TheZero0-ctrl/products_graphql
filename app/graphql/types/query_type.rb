# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :products, [Types::ProductType], null: false, description: 'Retrive list of products' do
      argument :page, Integer, required: false
    end

    field :product, Types::ProductType, null: false, description: 'Retrieve a product by ID' do
      argument :id, ID, required: true
    end

    field :bulk_upload, Types::BulkUploadType, null: false, description: 'Retrieve a bulk upload by ID' do
      argument :id, ID, required: true
    end

    def products(page: 1)
      Product.all.page(page).per(10)
    end

    def product(id:)
      Product.find(id)
    end

    def bulk_upload(id:)
      BulkUpload.find(id)
    end
  end
end
