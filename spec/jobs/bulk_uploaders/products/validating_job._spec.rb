require 'rails_helper'

RSpec.describe(BulkUploaders::Products::ValidationJob, type: :job) do
  it 'enqueues the job' do
    bulk_upload = build(:bulk_upload)
    expect do
      described_class.perform_later(bulk_upload.id)
    end.to(have_enqueued_job(described_class))
  end

  describe '#perform' do
    bulk_upload = FactoryBot.create(:bulk_upload)
    described_class.perform_now(bulk_upload.id)
    bulk_upload.reload

    it 'change the status of bulk upload to staged' do
      expect(bulk_upload.status).to(eq('staged'))
    end

    it 'sucessfully differntiate between valid, invalid' do
      expect(bulk_upload.valid_records.count).to(eq(2))
      expect(bulk_upload.invalid_records.count).to(eq(1))
    end
  end
end
