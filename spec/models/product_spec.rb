# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    subject(:product) { described_class.new(name: 'Product Name', code: '12345') }

    it 'is valid with valid attributes' do
      expect(product).to be_valid
    end

    it 'is not valid without a name' do
      product.name = nil
      expect(product).not_to be_valid
    end

    it 'is not valid without a code' do
      product.code = nil
      expect(product).not_to be_valid
    end

    it 'is not valid with a duplicate code' do
      existing_product = create(:product, code: '12345')
      product.code = existing_product.code
      expect(product).not_to be_valid
      expect(product.errors[:code]).to include('has already been taken')
    end
  end
end
