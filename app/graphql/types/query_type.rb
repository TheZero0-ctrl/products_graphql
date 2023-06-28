# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :products, [Types::ProductType], null: false, description: 'Retrive list of products'

    field :product, Types::ProductType, null: true, description: 'Retrieve a product by ID' do
      argument :id, ID, required: true
    end

    def products
      Product.all
    end

    def product(id:)
      Product.find(id)
    end
  end
end
