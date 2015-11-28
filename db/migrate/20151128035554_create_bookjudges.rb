class CreateBookjudges < ActiveRecord::Migration
  def change
    create_table :bookjudges do |t|
      t.string :title
      t.string :author
      t.string :isbn
      t.integer :judge_result

      t.timestamps null: false
    end
  end
end
