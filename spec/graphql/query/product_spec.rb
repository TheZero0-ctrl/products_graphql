# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::ProductType, type: :request do
  let!(:product1) { create(:product) }
  let!(:product2) { create(:product) }
  let!(:products) { create_list(:product, 10) }

  describe 'retrive list of products' do
    it 'returns a list of products when provided correct query' do
      # GraphQL query to retrieve products
      query = <<~GRAPHQL
        query {
          products {
            id
            name
            code
            images
          }
        }
      GRAPHQL

      post '/graphql', params: { query: }

      json_response = JSON.parse(response.body)
      products = json_response['data']['products']

      # Assert the response
      expect(response).to have_http_status(:success)
      expect(products[0]['id']).to eq(Product.first.id.to_s)
      expect(products[0]['name']).to eq(Product.first.name)
      expect(products[0]['code']).to eq(Product.first.code)
    end

    it 'returns 10 products per page' do
      query = <<~GRAPHQL
        query {
          products {
            id
            name
            code
            images
          }
        }
      GRAPHQL

      post '/graphql', params: { query: }

      json_response = JSON.parse(response.body)
      products = json_response['data']['products']
      expect(products.size).to eq(10)
    end

    it 'returns an error when provided incorrect query' do
      query = <<~GRAPHQL
        query {
          products {
            hello
          }
        }
      GRAPHQL

      post '/graphql', params: { query: }

      json_response = JSON.parse(response.body)

      expect(json_response['errors'][0]['message']).to eq("Field 'hello' doesn't exist on type 'Product'")
    end
  end

  describe 'retrive product by id' do
    it 'returns the requested product' do
      query = <<~GRAPHQL
        query {
          product(id: "#{product1.id}") {
            id
            name
            code
            images
          }
        }
      GRAPHQL

      post '/graphql', params: { query: }

      json_response = JSON.parse(response.body)
      product_data = json_response['data']['product']

      expect(response).to have_http_status(:success)
      expect(product_data['id']).to eq(product1.id.to_s)
      expect(product_data['name']).to eq(product1.name)
      expect(product_data['code']).to eq(product1.code)
      expect(product_data['images'][0]).to eq(Rails.application.routes.url_helpers.rails_blob_url(product1.images.first))
    end

    it 'returns an error when product does not exist' do
      query = <<~GRAPHQL
        query {
          product(id: 0) {
            id
            name
            code
            images
          }
        }
      GRAPHQL

      post '/graphql', params: { query: }

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:not_found)
      expect(json_response['errors'][0]['message']).to eq("Couldn't find Product with 'id'=0")
    end
  end
end
