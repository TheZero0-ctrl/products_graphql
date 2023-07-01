# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteProduct, type: :request do
  describe 'deleteProduct' do
    let!(:product) { create(:product) }
    context 'with valid input' do
      let(:query) do
        <<~GRAPHQL
          mutation($productId: ID!) {
            deleteProduct(input: {
              id: $productId
            }) {
              success
              errors
            }
          }
        GRAPHQL
      end

      it 'deletes the product and returns success' do
        post '/graphql', params: { query:, variables: { productId: product.id } }

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        data = json_response['data']['deleteProduct']
        success = data['success']
        errors = data['errors']

        expect(success).to be_truthy
        expect(errors).to be_empty
        expect(Product.exists?(product.id)).to be_falsey
      end
    end

    context 'with invalid input' do
      let(:query) do
        <<~GRAPHQL
          mutation($productId: ID!) {
            deleteProduct(input: {
              id: $productId
            }) {
              success
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
