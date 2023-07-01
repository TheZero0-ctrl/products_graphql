class ApplicationJob < ActiveJob::Base
  def start_staging(bulk_upload)
    log('Started staging bulk upload.')
    bulk_upload.set_as_staging
  end

  def complete_staging(bulk_upload)
    log('Completed staging bulk upload.')
    bulk_upload.set_as_staged
  end

  def start_processing(bulk_upload)
    log('Started processing bulk upload.')
    bulk_upload.set_as_processing
  end

  def complete_processing(bulk_upload)
    log('Completed processing bulk upload.')
    bulk_upload.set_as_processed
  end

  def fail_upload(bulk_upload, error)
    log('Failed to stage bulk upload.')
    return unless bulk_upload

    bulk_upload.set_as_failed(
      Rails.env.production? ? error.message : "#{error.message}\n#{error.backtrace.join("\n")}"
    )
  end

  def log(message)
    Rails.logger.debug { message } if Rails.env.development?
    logger.info(message)
  end

  def logger
    if defined?(Rails)
      Rails.logger
    else
      Logger.new($stdout)
    end
  end
end

