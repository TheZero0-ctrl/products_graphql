FactoryBot.define do
  factory :bulk_upload do
    resource_type { 'product' }

    after(:build) do |bulk_upload|
      file_path = Rails.root.join('app', 'assets', 'csv', 'product_lists.csv')
      bulk_upload.csv_file.attach(io: File.open(file_path), filename: 'product_lists.csv')
    end
  end
end
