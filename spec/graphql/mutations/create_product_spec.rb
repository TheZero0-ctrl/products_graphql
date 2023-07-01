# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateProduct, type: :request do
  describe 'create product' do
    context 'with valid input' do
      it 'creates a new product and returns it' do
        query = <<~GRAPHQL
          mutation {
            createProduct(input: {
              name: "New Product",
              code: "NEWPRODUCT",
              images: []
            }) {
              product {
                id
                name
                images
              }
              errors
            }
          }
        GRAPHQL

        post '/graphql', params: { query: }

        json_response = JSON.parse(response.body)
        product_data = json_response['data']['createProduct']['product']

        expect(response).to have_http_status(:success)
        expect(product_data['name']).to eq('New Product')
        expect(product_data['images']).to be_an(Array)
        expect(json_response['data']['createProduct']['errors']).to be_empty
      end
    end
  end
end
