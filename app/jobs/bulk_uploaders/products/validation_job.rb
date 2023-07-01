# frozen_string_literal: true

require 'csv'

module BulkUploaders
  module Products
    class ValidationJob < ::ApplicationJob
      def perform(bulk_upload_id)
        log('Staging bulk upload')
        @bulk_upload = BulkUpload.find(bulk_upload_id)

        start_staging(@bulk_upload) && validate_upload && complete_staging(@bulk_upload)
        true
      rescue Exception => e
        # any errors will be raised here which fail the bulk upload
        # reload to clear any validation errors
        @bulk_upload.reload

        # log out the full error message
        log(e.message)
        log(e.backtrace.join("\n"))

        # store the failure message
        fail_upload(@bulk_upload, e)
        false
      end

      private

      def validate_upload
        log('Validating bulk upload.')
        ProductValidators.validate(@bulk_upload)
      end
    end
  end
end
