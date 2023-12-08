# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.date :date
      t.text :description
      t.boolean :published, default: false, null: false
      t.references :event, foreign_key: true

      t.timestamps
    end
  end
end
