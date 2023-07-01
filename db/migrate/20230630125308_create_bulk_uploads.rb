class CreateBulkUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_uploads do |t|
      t.string :status, nil: false, default: 'pending'
      t.string :resource_type
      t.string :message
      t.jsonb :data

      t.timestamps
    end
  end
end
