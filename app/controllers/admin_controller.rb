class AdminController < ApplicationController
    before_action :admin_authorize_login, :only => [:login]
    before_action :admin_authorize_logout, :only => [:dashboard]
    layout "admin_app"
    def index
        redirect_to login_admin_index_path
    end

    def login
        # render plain: "Admin Login Page"
    end

    def submit_login
        # binding.pry
        if params[:admin][:email] == "admin@mybasecamp.com" and params[:admin][:password] == "qwazar"
            @user = User.find_by_email(params[:admin][:email])
            if @user && @user.roles.exists?(name: 'Super Admin')
                session[:user_id] = @user.id  # Store the user ID in the session
                session[:admin_logged_in] = true
                flash[:success] = "Welcome Admin, you are logged in successfully!"
                redirect_to dashboard_admin_index_path
            else
                flash[:error] = "Please Provide Correct Admin Email And Password"
                render 'login'
            end
       else
         flash[:error] = "Incorrect email or password"
         render 'login'
       end
    end

    def dashboard
    end

    def new_user
        @user=User.new
    end

    def create_user
        binding.pry
        @user[:userid] = SecureRandom.uuid
        @user=User.new(user_params)
        if @user.save!
            flash[:success]= "User Create Successfully"
            # @project_id = params[:user][:project_id]
            # ProjectUser.create(project_id: @project_id, user_id: @user.id, project_user_id: SecureRandom.uuid)
            @user.update(role_ids: [params[:user][:role_id].to_i])
            redirect_to users_admin_index_path
        else
            flash[:error]= "User Create Unsuccessfully"
            render 'new_user_create'
        end
    end

    def destroy_user
        @user = User.find_by(id: params[:id])
        if @user.destroy
         flash[:success] = "User deleted Successfully"
         redirect_to users_admin_index_path
        else
          flash[:error] = "User deleted Unsuccessfully"
          render 'users'
        end    
    end

    def users_list
        # binding.pry
        @project= Project.find_by(id: params[:id])
        #  @user_id = @user.id
        @project_user = ProjectUser.where(project_id: @project.id).pluck(:user_id)

        # @projects= Project.where(id: @project_ids)
    end

    def new_role
        @role= Role.new
    end

    def create_role
        @role=Role.new(role_params)
        if @role.save!
         flash[:success]= 'Role is create Successfully'
         redirect_to admin_role_list_path
        else
         flash[:error]= 'Role is create Unsuccessfull'
         render 'new_role'
        end  
    end

    def role_list
        @roles = Role.order(name: :desc)
    end

    def add_new_user_project
        @project= Project.find_by(projectid: params[:projectid])
    end

    def add_user
        @project_user = ProjectUser.new(project_user_params)
        # binding.pry
        @project = Project.find_by(projectid: params[:projectid])
        @user = User.find(params[:project_user][:user_id])
        @project_user[:project_user_id] = SecureRandom.uuid
        @project_user[:user_id]= @user.id
        @project_user[:project_id]= @project.id
        if @project_user.save!
           flash[:success]= "Add User Successfully for that project"
            @user.update(role_ids: [params[:project_user][:role_id].to_i])
           redirect_to admin_users_list_path(@project.id)
        else
            flash[:error]= "Add User Unsuccessfull for that project"
            render 'admin_add_user_project'
        end
    end

    def edit_user
        # binding.pry
        @project_user = ProjectUser.find_by(project_id: params[:id])
        # @project_user.write_access
        # @project_user.read_access
        @project = Project.find_by(id: params[:id])
        @user = User.find_by(id: @project_user.user_id)
        # render plain: @project.inspect
        @users = User.pluck(:fullname, :id).to_a.unshift(["Select Name", ""])
    end

   def update_user
    # binding.pry
    @project_user = ProjectUser.find_by(user_id: params[:id])
    @project = Project.find_by(id: @project_user.project_id)
        if @project_user.nil?
            flash[:error] = "Project user not found."
            redirect_to admin_edit_user_path
            return
        end
    project_user = params[:project_user]
    @accesses = ["write_access","read_access","update_access","delete_access"]
    @accesses.each do |access|
        project_user[access] = project_user[access] == "1" ? true : false
    end
        if @project_user.update(project_user_params)
            flash[:success] = "User's access to project updated successfully."
            redirect_to admin_users_list_path(@project.id)

        else
            flash[:error] = "Failed to update user's access to project."
            render 'edit_user'
        end
   end

    def delete_user
        # binding.pry
        @project_user = User.find_by(id: params[:user_id])
        @project_id = ProjectUser.where(user_id: params[:user_id]).pluck(:project_id).first
        
        if @project_user && @project_id
            ProjectUser.find_by(user_id: params[:user_id], project_id: @project_id).destroy
            flash[:success] = "User deleted from project successfully"
        else
            flash[:error] = "Could not find user or project"
        end
        redirect_to admin_users_list_path(id: @project_id)
    end


    def users
        @pagy, @users = pagy(User.all, items: 5)
    end

    def index
     @projects = Project.all
    end

    def new
       @project=Project.new
    end

    def create
        # p params[:user_id]
        
        params[:project][:user_id] = session[:user_id]
        params[:project][:projectid] = SecureRandom.uuid
        @project = Project.new(project_params)
        #  @project.user_id = @user.id
        # else
        #   flash[:error] = "Only super admin can create projects."
        #   redirect_to admin_new_path
        #   return
        # end
        if @project.save!
            ProjectUser.create(project_id: @project.id, user_id: params[:project][:user_id])
            User.find(params[:project][:user_id].to_i).update(role_ids:[params[:project][:role_id].to_i])
            flash[:success] = "Project Created Successfully"
            redirect_to admin_show_project_page_path
        else
            # render plain: @project.inspect
            flash[:error] = "Project Not Created Successfully"
            render 'admin/new'
        end
    end
     
    
    def show
       @projects = Project.all
        # @pagy= pagy(@project.projectid, items: 5)
        @bgs = ["#68428a","#a64791","#855635","#4c7e8a","#323e7a","#943469","#4d2227","#b05638","#4d0b47","#992b59","#1b5780","#046e6e","#254a22","#6d8748","#5d6344"]
    end

    def destroy
        # binding.pr
        @project = Project.find_by(projectid: params[:projectid])
        if @project.nil?
         flash[:error] = "Project not found"
        else
            @project_threads = ProjectThread.where(project_id: @project.id)

            # Delete associated project_threads records
            @project_threads.destroy_all
            
            # Now it should be safe to destroy the project
            @project.destroy
            flash[:success] = "Project Deleted Successfully"
        end
        redirect_to admin_show_project_page_path
    end

    def projects
        @user = User.find_by(userid: params[:userid])
        @pagy, @projects = pagy(@user.projects, items: 5)
        render 'user_projects'
    end

    def edit_project
        @project = Project.find_by(projectid: params[:projectid])
    end

    def update_project
        # binding.pry
        @user_id = session[:user_id]
        # params[:project][:user_id] = session[:id]
        @project = Project.find_by(projectid: params[:projectid])
        params[:project][:user_id] = @user_id
    
        if @project.update(project_params)
            flash[:success] = "Project Updated Successfully"
        else
            flash[:error] = "Project Updated Unsuccessfull"
            render 'edit_project'
        end
        redirect_to admin_show_project_page_path
    end

    def task
        @project = Project.find_by(projectid: params[:projectid])
        # @user_id = Task.find_by(id: )
    end

    def add_new_task
        @task = Task.new
        @project = Project.find_by(projectid: params[:projectid])
        @project_id=Project.find_by(id: @project.id)
        @user_ids=ProjectUser.where(project_id: @project_id.id).pluck(:user_id)
    end

    def create_task
        @task = Task.new(task_params)
        @project = Project.find_by(projectid: params[:projectid])
        @task.project_id = @project[:id]
        @task.user_id = params[:task][:user_id]
        @user = User.find_by(id: params[:task][:user_id])
        @task.task_id = SecureRandom.uuid
        
        if @task.save!
            flash[:success] = "Task created Successfully"
            redirect_to admin_add_task_path
        else
            flash[:error] = "You have some errors there"
            render 'add_new_task'
        end
    end

    def edit_task
        @task = Task.find_by(task_id: params[:task_id])
        @project = Project.find_by(projectid: params[:projectid])
    end

    def update_task
        @task = Task.find_by(task_id: params[:task_id])
        if @task.update(task_params)
            flash[:success] = "Task updated Successfully"
            redirect_to projects_users_path + "/#{params[:projectid]}/tasks"
        else
            flash[:error] = "You have some errors there"
            render 'edit_task'
        end
    end

    def view_task_details
        @task=Task.find_by(id: params[:id])
    end

    def delete_task
        # binding.pry
        @task = Task.find_by(id: params[:id])
        @project = Project.find_by(id: @task.project_id)

        if @task.destroy!
         flash[:success] = "Task deleted Successfully"
        else
            flash[:error] = "Task deleted Unsuccessfully"
            render 'task'
        end
        redirect_to admin_add_task_path(projectid: @project.projectid)
    end

    def projectwise_user
        @user = User.find_by(id: params[:id])         
        @project_ids = ProjectUser.where(user_id: @user.id).pluck(:project_id)
        @projects = Project.where(id: @project_ids)
    end

    def set_admin
        @user = User.find_by(userid: params[:userid])
        @user.isAdmin = 1
        # render plain: @user.inspect
        if (@user.save)
            flash[:success] = "User #{@user.fullname} has been given Admin Privilege"
            redirect_to users_admin_index_path
        else    
            flash[:error] = "User #{@user.fullname} Could not be set as Admin"
            redirect_to users_admin_index_path
        end
    end

    def unset_admin
        @user = User.find_by(userid: params[:userid])
        @user.isAdmin = 0
        # render plain: @user.inspect
        if (@user.save)
            flash[:success] = "User #{@user.fullname} admin privilege has been discarded"
            redirect_to users_admin_index_path
        else    
            flash[:error] = "User #{@user.fullname} admin privilege was not discarded"
            redirect_to users_admin_index_path
        end
    end

    def logout
        session[:admin_logged_in] = nil
        flash[:error] = "You are logged out Successfully!"
        redirect_to login_admin_index_path
    end

    def threads
        @project = Project.find_by(projectid: params[:projectid])
        @user_id = @project.user_id
        @project_threads = ProjectThread.where("project_id = ?",@project[:id])
        # render plain: @project_threads.inspect
    end

    def add_thread
        @project = Project.find_by(projectid: params[:projectid])
        @project_thread = ProjectThread.new
    end

    def edit_thread
        @project = Project.find_by(projectid: params[:projectid])
        @project_thread = ProjectThread.find_by(thread_id: params[:thread_id])
    end

    def project_attachment
        @projects = Project.find_by(projectid: params[:projectid])
    end

    def upload_attachments
        @attachment=Attachment.new
        @project_id=Project.find_by(projectid: params[:projectid])
    end

    def create_attachment
        binding.pry
        @attachment = Attachment.new(attachment_params)
        # @project = Project.find_by(projectid: params[:projectid]).(:id)
        @project = Project.find_by(projectid: params[:projectid])

        
        # @attachment[:project_id] = @project[:id]
        @attachment.project_id = @project.id
        @attachment[:userid] = session[:userid]
        # render plain: params[:attachment][:files].inspect
        if (params[:attachment][:files] == nil)
            flash[:error] = "Please Provide Files"
            render 'projects/upload_attachments'
        else
            @attachment.files.attach(params[:attachment][:files])
            if @attachment.save
                flash[:success] = "Attachment Uploaded Successfully"
            else
                flash[:error] = "Attachment Not Uploaded Successfully"
                render 'upload_attachments'
            end
            redirect_to admin_project_attachment_path(projectid: @project.projectid)
        end
    end

    def delete_attachment
        # binding.pry
        @attachment = Attachment.find(params[:id])
        @project_id= @attachment.project_id
        @project = Project.find_by(id: @project_id)
        if @attachment.destroy
         flash[:success] = "Attachment Deleted Successfully"
        else
            flash[:error] = "Attachment Deleted Unsuccessfully"
        end
        redirect_to admin_project_attachment_path(projectid: @project.projectid)
    #    @attachment = ActiveStorage::Attachment.find(params[:id])
    #    @project_id= @attachment.project_id
    #    @project = Project.find_by(id: @project_id).project_id
    #    if @attachment.purge
    #      flash[:success] = "Attachment Deleted Successfully"
    #    else
    #       flash[:error] = "Attachment Deleted Unsuccessfully"
    #       render 'project_attachment'
    #     end
    #     redirect_to admin_project_attachment_path(projectid: @project)

    end

    private
        def user_params
            params.require(:user).permit(:fullname, :email, :password)
        end

        def project_params
            params.require(:project).permit(:id, :title, :description, :user_id, :projectid)
        end

        def task_params
            params.require(:task).permit(:title, :description, :important_file, :task_id, :project_id, :user_id, :task_status)
        end

        def project_user_params
            params.require(:project_user).permit(:project_user_id,:project_id,:user_id,:read_access,:write_access,:update_access,:delete_access)
        end

        def attachment_params
            params.require(:attachment).permit(:title, :description, :projectid, :user_id, :files)
        end

        def role_params
            params.require(:role).permit(:name)
        end
end