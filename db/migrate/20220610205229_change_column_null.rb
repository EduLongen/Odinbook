class ChangeColumnNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :gender, true
    change_column_null :users, :dateOfBirth, true
    change_column_null :users, :surname, true
  end
end
