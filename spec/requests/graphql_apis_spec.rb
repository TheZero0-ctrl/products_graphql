# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL API', type: :request do
  let!(:product1) { create(:product) }
  let!(:product2) { create(:product) }
  let!(:products) { create_list(:product, 10) }

  describe 'POST /graphql list of products' do
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
      expect(products[0]['id']).to eq(product1.id.to_s)
      expect(products[0]['name']).to eq(product1.name)
      expect(products[0]['code']).to eq(product1.code)
      expect(products[0]['images'][0]).to eq(Rails.application.routes.url_helpers.rails_blob_url(product1.images.first))
      expect(products[1]['id']).to eq(product2.id.to_s)
      expect(products[1]['name']).to eq(product2.name)
      expect(products[1]['code']).to eq(product2.code)
      expect(products[1]['images'][0]).to eq(Rails.application.routes.url_helpers.rails_blob_url(product2.images.first))
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

  describe 'POST /graphql show a product' do
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

  describe 'POST /graphql create a product' do
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

  describe 'POST /graphql update a product' do
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

  describe 'POST /graphql delete a product' do
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
        post '/graphql', params: { query: query, variables: { productId: product.id}}

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
        post '/graphql', params: { query: query, variables: {productId: 0} }

        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        errors = json_response['errors']

        expect(errors[0]['message']).to include("Couldn't find Product with 'id'=0")
      end
    end
  end
end
