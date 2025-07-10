class CreateCoursesSectionsUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :teacher_name
      t.text :description

      t.timestamps
    end

    create_table :sections do |t|
      t.string :name, null: false
      t.integer :idx, null: false
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end

    create_table :units do |t|
      t.string :name, null: false
      t.text :description
      t.text :content, null: false
      t.integer :idx, null: false
      t.references :section, null: false, foreign_key: true

      t.timestamps
    end
  end
end
