# frozen_string_literal: true

class ProductValidators
  def self.validate(bulk_upload)
    initialize_product(bulk_upload)
  rescue StandardError => e
    raise(e)
  end

  def self.initialize_product(bulk_upload)
    product_attributes = {}
    products = []
    csv_file = CSV.parse(bulk_upload.csv_file.download, headers: true)
    row_count = csv_file.count
    product_attributes['total_row'] = row_count
    invalid_records = []
    valid_records = []
    extract_products_from_csv(csv_file, products)

    products.each_with_index do |row, index|
      check_valid_and_invalid_record(row, index, valid_records, invalid_records)
      product_attributes['invalid_records'] = invalid_records
      product_attributes['valid_records'] = valid_records
      bulk_upload.update!(data: product_attributes)
    end
  end

  def self.extract_products_from_csv(csv_file, products)
    csv_file.each do |row|
      products << row.to_hash
    end
  end

  def self.check_valid_and_invalid_record(product, index, valid_records, invalid_records)
    if product['name'].blank?
      add_invalid_records(product, index, invalid_records, 'name is blank')
    elsif product['code'].blank?
      add_invalid_records(product, index, invalid_records, 'code is blank')
    else
      add_valid_record(product, index, valid_records)
    end
  end

  def self.add_valid_record(product, index, valid_records)
    valid_record = { record: product, row: index + 1 }
    valid_records << valid_record
  end

  def self.add_invalid_records(product, index, invalid_records, message)
    invalid_record = { record: product, row: index + 1, message: }
    invalid_records << invalid_record
  end
end
