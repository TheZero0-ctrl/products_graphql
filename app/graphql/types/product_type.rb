# frozen_string_literal: true

module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :code, String, null: false
    field :name, String, null: false
    field :images, [String], null: true

    def images
      if object.images.attached?
        object.images.map do |image|
          Rails.application.routes.url_helpers.rails_blob_url(image)
        end
      else
        []
      end
    end
  end
end
