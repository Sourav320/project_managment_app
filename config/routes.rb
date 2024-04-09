Rails.application.routes.draw do
  resources :messages
  resources :project_threads
  resources :attachments
  resources :users do
    resources :projects
    get 'logout', :on => :collection
    get 'login', :on => :collection
    post 'login' => 'users#submit_login', :on => :collection
    get 'dashboard', :on => :collection
    get 'profile', :on => :collection
    patch 'profile' => 'users#submit_profile', :on => :collection
    get 'projects', :on => :collection
    get 'projects/shared' => "users#shared_projects", :on => :collection
    get 'projects/create' => 'users#create_project', :on => :collection
    post 'projects/create' => 'projects#create', :on => :collection
    get 'projects/view/:projectid' => 'projects#show', :on => :collection
    get 'projects/edit/:projectid' => 'users#edit_project', :on => :collection
    post 'projects/edit/:projectid' => 'projects#update', :on => :collection
    get 'projects/delete/:projectid' => 'projects#destroy', :on => :collection 
    get 'projects/:projectid/attachments/delete/:id' => 'projects#delete_attachment', :on => :collection
    get 'projects/attachments/:projectid' => 'projects#attachments', :on => :collection
    get 'projects/attachments/create/:projectid' => 'projects#upload_attachments', :on => :collection
    post 'projects/attachments/create/:projectid' => 'attachments#create', :on => :collection
    # post 'projects/create' => 'projects#create', :on => :collection

    # Users Routes
    get 'projects/:projectid/users' => 'projects#users', :on => :collection
    get 'projects/:projectid/user/add' => 'projects#add_user', :on => :collection
    # post 'projects/:projectid/user/add' => 'projects#create_user', :on => :collection
    # get 'projects/:projectid/user/edit/:projectuserid' => 'projects#edit_user', :on => :collection
    # post 'projects/:projectid/user/edit/:projectuserid' => 'projects#update_user', :on => :collection
    # get 'projects/:projectid/user/delete/:projectuserid' => 'projects#delete_user', :on => :collection

    # Tasks Routes
    get 'projects/:projectid/tasks' => 'users#tasks', :on => :collection
    get 'projects/:projectid/task/add' => 'users#add_task', :on => :collection
    post 'projects/:projectid/task/add' => 'users#create_task', :on => :collection
    get 'projects/:projectid/task/edit/:task_id' => 'users#edit_task', :on => :collection
    post 'projects/:projectid/task/edit/:task_id' => 'users#update_task', :on => :collection
    get 'projects/:projectid/task/delete/:task_id' => 'users#delete_task', :on => :collection

    # Thread Routes
    get 'projects/:projectid/threads/:thread_id' => 'users#threads', :on => :collection
    get 'projects/:projectid/threads/:thread_id/message/edit/:message_id' => 'messages#edit', :on => :collection
    post 'projects/:projectid/threads/:thread_id/message/edit/:message_id' => 'messages#update', :on => :collection
    post 'projects/:projectid/threads/:thread_id' => 'messages#create', :on => :collection
    delete 'projects/:projectid/threads/:thread_id/message/:message_id' => 'messages#destroy', :on => :collection
    get 'projects/threads/:projectid' => 'projects#threads', :on => :collection
    get 'projects/thread/create/:projectid' => 'projects#add_thread', :on => :collection
    post 'projects/thread/create/:projectid' => 'project_threads#create', :on => :collection
    get 'projects/threads/:projectid/:thread_id/update' => 'projects#edit_thread', :on => :collection
    post 'projects/threads/:projectid/:thread_id/update' => 'project_threads#update', :on => :collection
    get 'projects/threads/:projectid/:thread_id/delete' => 'project_threads#destroy', :on => :collection
  end

  resources :admin do
    get 'logout', :on => :collection
    get 'login', :on => :collection
    get 'dashboard', :on => :collection
    get 'users' => 'admin#users', :on => :collection
    get 'users/projects/:userid' => 'admin#projects', :on => :collection
    get 'users/set_admin/:userid' => 'admin#set_admin', :on => :collection
    get 'users/unset_admin/:userid' => 'admin#unset_admin', :on => :collection
    get 'delete/:projectid' => 'admin#destroy', :on => :collection 
    get 'new_user' => 'admin#new_user', :on => :collection
    post 'create_user' => 'admin#create_user', :on => :collection
    post 'login' => 'admin#submit_login', :on => :collection

  end
  root 'users#index', as: 'home'
  # post 'admin/create', to:'admin#create'
  # get 'admin/new_project', to: 'admin#new_project'
  get 'admin', to: 'admin#index'
  get 'admin/new', to: 'admin#new'
  post 'admin/create', to: 'admin#create'

  get 'admin/show', to: 'admin#show', as: 'admin_show_project_page'
 
  get 'admin/projectwise_user/:id', to: 'admin#projectwise_user', as: 'admin_projectwise_user'
  get 'admin/destroy_project/:projectid', to: 'admin#destroy', as: 'admin_project_delete'

  get 'admin/destroy_user/:id', to: 'admin#destroy_user', as: 'admin_delete_user'

  get 'admin/add_new_task/:projectid', to: 'admin#add_new_task', as: 'admin_add_new_task'
  post 'admin/create_task/:projectid', to: 'admin#create_task', as: 'admin_add_create_task'
  
  get 'admin/task/:projectid', to: 'admin#task', as: 'admin_add_task'
  get 'admin/users_list/:id', to: 'admin#users_list', as: 'admin_users_list'
  get 'admin/add_new_user_project/:projectid', to: 'admin#add_new_user_project', as: 'admin_add_user_project'
  post 'admin/add_user/:projectid', to: 'admin#add_user', as: 'admin_add_user'
  get 'admin/edit_user/:id', to: 'admin#edit_user', as: 'admin_edit_user'
  post 'admin/update_user/:id', to: 'admin#update_user', as: 'admin_update_user'
  get 'admin/delete_user/:user_id', to: 'admin#delete_user', as: 'admin_delete_user_project'
  
  get 'admin/threads/:projectid', to: 'admin#threads', as: 'admin_threads'
  get 'admin/add_thread/:projectid', to: 'projects#add_thread', as: 'admin_add_threads'
  get 'admin/delete_task/:id', to:'admin#delete_task', as: 'admin_delete_task'
  get 'admin/project_attachment/:projectid', to: 'admin#project_attachment', as: 'admin_project_attachment'
  get 'admin/upload_attachments/:projectid', to: 'admin#upload_attachments', as: 'admin_upload_attachments'
  post 'admin/create_attachment/:projectid', to: 'admin#create_attachment', as: 'admin_create_attachment'
  get 'admin/delete_attachment/:id', to: 'admin#delete_attachment', as: 'admin_delete_attachment'
  get 'admin/edit_project/:projectid', to: 'admin#edit_project', as: 'admin_edit_project'
  post 'admin/update_project/:projectid', to: 'admin#update_project', as: 'admin_update_project'
  get 'admin/view_task_details/:id', to: 'admin#view_task_details', as: 'admin_view_task_details'
  get 'admin/new/new_role', to: 'admin#new_role', as: 'admin_new_role'
  post 'admin/create_role', to: 'admin#create_role', as: 'admin_create_role'
  get 'admin/role/role_list', to: 'admin#role_list', as: 'admin_role_list'
  # get 'admin/new_user', to: 'admin#new_user', as: 'admin_new_user_create'
  # post 'admin/create_new', to: 'admin#create_new', as: 'admin_create_new_user'
  


  namespace 'api' do
    namespace 'v1' do
      resources :users
      resources :projects do
        post 'user/:projectid/update' => 'projects#update_user', :on => :collection
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end