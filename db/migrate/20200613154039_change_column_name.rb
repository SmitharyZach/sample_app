class ChangeColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :relationships, :follwer_id, :follower_id
  end
end
