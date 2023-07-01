# frozen_string_literal: true

class BulkUpload < ApplicationRecord
  has_one_attached :csv_file

  validates :csv_file, presence: true, content_type: 'csv', size: { less_than: 100.megabytes }

  enum status: {
    pending: 'pending',
    staging: 'staging',
    staged: 'staged',
    processing: 'processing',
    processed: 'processed',
    failed: 'failed'
  }

  enum resource_type: {
    product: 'product'
  }

  after_create do
    ::BulkUploaders::Products::ValidationJob.perform_later(id)
  end

  after_update do
    ::BulkUploaders::Products::UploadingJob.perform_later(id) if saved_change_to_status? && staged?
  end

  def set_as_staging
    update(
      status: 'staging',
      message: 'Staging uploaded file.'
    )
    save
  end

  def set_as_staged
    update(
      status: 'staged',
      message: 'Successfully staged'
    )
    save
  end

  def set_as_processing
    update(
      status: 'processing',
      message: 'Processing data.'
    )
    save
  end

  def set_as_processed
    update(
      status: 'processed',
      message: "Successfully processed #{valid_records.count} valid rows"
    )
    save
  end

  def set_as_failed(message)
    update(
      status: 'failed',
      message: message
    )
    save(validate: false)
  end


  def valid_records
    data['valid_records'].pluck('record')
  end

  def invalid_records
    data['invalid_records'].pluck('record')
  end
end
