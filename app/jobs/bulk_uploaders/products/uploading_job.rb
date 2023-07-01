# frozen_string_literal: true

require 'open-uri'

module BulkUploaders
  module Products
    class UploadingJob < ::ApplicationJob
      def perform(bulk_upload_id)
        log('Start processing bulk upload')
        @bulk_upload = ::BulkUpload.find(bulk_upload_id)

        start_processing(@bulk_upload) && apply_upload && complete_processing(@bulk_upload)
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

      def apply_upload
        log('Processing bulk upload.')
        @bulk_upload.data['valid_records'].each do |valid_record|
          attributes = valid_record['record']
          duplicate_product = Product.find_by(code: attributes['code'])
          if duplicate_product
            duplicate_product.update!(name: attributes['name'])
            attach_image(duplicate_product, attributes['image'])
          else
            Product.create!(name: attributes['name'], code: attributes['code'])
          end
        end
      end

      def attach_image(product, image)
        return if image.blank? || !valid_url?(image)

        downloaded_image = URI.parse(image).open
        filename = File.basename(image)
        return unless filename

        product.images.attach(io: downloaded_image, filename:)
      end

      def valid_url?(url)
        uri = URI.parse(url)
        uri.is_a?(URI::HTTP) && !uri.host.nil? && (uri.scheme == 'https' || uri.scheme == 'http')
      rescue URI::InvalidURIError
        false
      end
    end
  end
end
