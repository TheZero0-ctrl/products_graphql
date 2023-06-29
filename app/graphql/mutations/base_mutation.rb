module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def attach_images(product, images)
      return unless images

      images.each do |image|
        product.images.attach(io: image, filename: image.original_filename)
      end
    end
  end
end
