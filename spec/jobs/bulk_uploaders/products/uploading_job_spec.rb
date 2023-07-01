require 'rails_helper'

RSpec.describe(BulkUploaders::Products::UploadingJob, type: :job) do
  it 'enqueues the job' do
    bulk_upload = build(:bulk_upload)
    expect do
      described_class.perform_later(bulk_upload.id)
    end.to(have_enqueued_job(described_class))
  end

  describe '#perform' do
    bulk_upload = FactoryBot.create(:bulk_upload)
    ::BulkUploaders::Products::ValidationJob.perform_now(bulk_upload.id)
    bulk_upload.reload
    described_class.perform_now(bulk_upload.id)
    bulk_upload.reload
    it 'change the status of bulk upload to processed' do
      expect(bulk_upload.status).to(eq('processed'))
    end

    it 'create valid products from csv file' do
      expect(Product.count).to(eq(2))
    end
  end
end
