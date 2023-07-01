# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::BulkUploadType, type: :request do
  describe 'retrive bulk upload with id' do
    let!(:bulk_upload) { create(:bulk_upload) }

    it 'returns the requested bulkupload' do
      query = <<~GRAPHQL
        query {
          bulkUpload(id: "#{bulk_upload.id}") {
            id
            resourceType
            status
            csvFile
          }
        }
      GRAPHQL

      post '/graphql', params: { query: }

      json_response = JSON.parse(response.body)
      bulk_upload_data = json_response['data']['bulkUpload']

      expect(response).to have_http_status(:success)
      expect(bulk_upload_data['id']).to eq(bulk_upload.id.to_s)
      expect(bulk_upload_data['resourceType']).to eq(bulk_upload.resource_type)
      expect(bulk_upload_data['status']).to eq(bulk_upload.status)
      expect(bulk_upload_data['csvFile']).to eq(Rails.application.routes.url_helpers.rails_blob_url(bulk_upload.csv_file))
    end

    it 'returns an error when bulk upload does not exist' do
      query = <<~GRAPHQL
        query {
          bulkUpload(id: 0) {
            id
            resourceType
            status
            csvFile
          }
        }
      GRAPHQL

      post '/graphql', params: { query: }

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:not_found)
      expect(json_response['errors'][0]['message']).to eq("Couldn't find BulkUpload with 'id'=0")
    end
  end
end
