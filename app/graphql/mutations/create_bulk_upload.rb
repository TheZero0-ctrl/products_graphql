# frozen_string_literal: true

require 'csv'

module Mutations
  # represents a GraphQL mutation for creating a bulk upload.
  class CreateBulkUpload < Mutations::BaseMutation
    argument :resource_type, String, required: true
    argument :csv_file, ApolloUploadServer::Upload, required: true

    field :bulk_upload, Types::BulkUploadType, null: true
    field :errors, [String], null: false

    def resolve(resource_type:, csv_file:)
      headers = CSV.foreach(csv_file).first
      return { bulk_upload: nil, errors: ['Incorrect headers'] } unless correct_header?(headers, resource_type)

      bulk_upload = BulkUpload.new(resource_type:)
      bulk_upload.csv_file.attach(io: csv_file, filename: csv_file.original_filename)
      if bulk_upload.save
        { bulk_upload:, errors: [] }
      else
        { bulk_upload: nil, errors: bulk_upload.errors.full_messages }
      end
    end

    private

    def correct_header?(headers, resource_type)
      case resource_type
      when 'product'
        (headers.map(&:downcase) - %w[code name image]).empty?
      end
    end
  end
end
