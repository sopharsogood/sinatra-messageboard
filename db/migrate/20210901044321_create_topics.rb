class CreateTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :topics do |t|
      t.string :title
    end
  end
end
