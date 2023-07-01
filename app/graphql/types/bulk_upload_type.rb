# frozen_string_literal: true

module Types
  class BulkUploadType < Types::BaseObject
    field :id, ID, null: false
    field :status, String, null: false
    field :resource_type, String, null: false
    field :message, String, null: true
    field :csv_file, String, null: true
    field :data, GraphQL::Types::JSON, null: true

    def csv_file
      if object.csv_file.attached?
        Rails.application.routes.url_helpers.rails_blob_url(object.csv_file)
      end
    end
  end
end
