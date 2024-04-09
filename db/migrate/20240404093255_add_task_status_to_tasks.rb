class AddTaskStatusToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :task_status, :string
  end
end
