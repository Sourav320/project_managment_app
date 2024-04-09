class RemoveTaskStatusFromTasks < ActiveRecord::Migration[6.0]
  def change
    remove_column :tasks, :TaskStatus, :string
  end
end
