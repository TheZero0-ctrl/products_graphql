# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProduct, type: :request do
  describe 'update product' do
    let!(:product) { create(:product) }

    context 'with valid input' do
      let(:query) do
        <<~GRAPHQL
          mutation($productId: ID!) {
            updateProduct(input: {
              id: $productId,
              name: "New Product Name",
            }) {
              product {
                id
                name
                code
                images
              }
              errors
            }
          }
        GRAPHQL
      end

      it 'updates the product and returns the updated product' do
        post '/graphql', params: { query:, variables: { productId: product.id } }

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        data = json_response['data']['updateProduct']
        product_data = data['product']
        errors = data['errors']

        expect(errors).to be_empty
        expect(product_data).not_to be_nil
        expect(product_data['id']).to eq(product.id.to_s)
        expect(product_data['name']).to eq('New Product Name')
      end
    end

    context 'with invalid input' do
      let(:query) do
        <<~GRAPHQL
          mutation($productId: ID!) {
            updateProduct(input: {
              id: $productId,
              name: "New Product",
            }) {
              product {
                id
                name
                code
                images
              }
              errors
            }
          }
        GRAPHQL
      end

      it 'returns an error when the product is not found' do
        post '/graphql', params: { query:, variables: { productId: 0 } }

        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        errors = json_response['errors']

        expect(errors[0]['message']).to include("Couldn't find Product with 'id'=0")
      end
    end
  end
end
