# spec/models/bulk_upload_spec.rb

require 'rails_helper'

RSpec.describe BulkUpload, type: :model do
  describe 'validations' do
    subject(:bulk_upload) { build(:bulk_upload) }

    it 'is valid with valid attributes' do
      expect(bulk_upload).to be_valid
    end

    it 'is not valid without a csv_file' do
      bulk_upload.csv_file = nil
      expect(bulk_upload).not_to be_valid
    end

    it 'is not valid without a resource_type' do
      bulk_upload.resource_type = nil
      expect(bulk_upload).not_to be_valid
    end
  end

  describe 'methods' do
    let(:bulk_upload) { create(:bulk_upload) }

    it 'sets bulk upload as staging' do
      bulk_upload.set_as_staging
      expect(bulk_upload.status).to eq('staging')
      expect(bulk_upload.message).to eq('Staging uploaded file.')
    end

    it 'sets bulk upload as staged' do
      bulk_upload.set_as_staged
      expect(bulk_upload.status).to eq('staged')
      expect(bulk_upload.message).to eq('Successfully staged')
    end

    it 'sets bulk upload as processing' do
      bulk_upload.set_as_processing
      expect(bulk_upload.status).to eq('processing')
      expect(bulk_upload.message).to eq('Processing data.')
    end

    it 'sets bulk upload as processed' do
      data = {
        total_row: 1,
        valid_records: [
          row: 1,
          record: {
            code: 'TESTCODE',
            name: 'TESTNAME'
          }
        ]
      }
      bulk_upload.update(data:)
      bulk_upload.set_as_processed
      expect(bulk_upload.status).to eq('processed')
      expect(bulk_upload.message).to eq('Successfully processed 1 valid rows')
    end

    it 'sets bulk upload as failed' do
      message = 'Error message'
      bulk_upload.set_as_failed(message)
      expect(bulk_upload.status).to eq('failed')
      expect(bulk_upload.message).to eq(message)
    end
  end
end
