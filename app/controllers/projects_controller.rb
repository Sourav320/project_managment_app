class ProjectsController < ApplicationController
    before_action :get_project, :only => [:attachments]

    
    def create
        params[:project][:user_id] = session[:id]
        params[:project][:projectid] = SecureRandom.uuid
        # render plain: project_params
        @project = Project.new(project_params)
        # render plain: @project.inspect
        if (@project.save)
            flash[:success] = "Project Created Successfully"
            redirect_to projects_users_path
        else
            # render plain: @project.inspect
            flash[:error] = "Project Not Created Successfully"
            render 'users/create_project'
        end
    end

    def show
        @project = Project.find_by(projectid: params[:projectid])
        # render plain: @project.inspect
    end

    def users
        @project = Project.find_by(projectid: params[:projectid])
        # @project = Project.find_by(id: params[:id])
        @project_users = ProjectUser.where(project_id: @project.id)
        # render plain: @project_users.inspect
    end

    def add_user
        # @project_users = ProjectUser.all
        @project_user = ProjectUser.new
        @project = Project.find_by(projectid: params[:projectid])
        @users = User.pluck(:fullname, :id).to_a.unshift(["Select Name", ""])
        # render plain: @project.inspect
    end

    def create_user
    @project = Project.find_by(projectid: params[:projectid])
    project_user = params[:project_user]
    @accesses = ["write_access","read_access","update_access","delete_access"]
        @accesses.each do |access|
            project_user[access] = project_user[access] == "1" ? true : false
        end
    project_user[:project_id] = @project.id
    project_user[:project_user_id] = SecureRandom.uuid
    @project_user = ProjectUser.new(project_user_params)
    @users = User.pluck(:fullname, :id).to_a.unshift(["Select Name", ""])
    @project_user_details = ProjectUser.find_by(user_id: project_user_params[:user_id], project_id: project_user_params[:project_id])
        if @project_user_details
            flash[:error] = "User has already been added to Project"
            render 'projects/add_user'
        else
            if @project_user.save
                flash[:success] = "User added to Project Successfully"
                redirect_to projects_users_path + "/#{@project.projectid}/users"
            else
                render 'projects/add_user'
            end
        end
    end


    def delete_user
        @project_user = ProjectUser.find_by(project_user_id: params[:projectuserid])
        # render plain: @project_user.inspect
        @project_user.destroy
        flash[:error] = "User Deleted From Project Successfully"
        redirect_to projects_users_path + "/#{params[:projectid]}/users"
    end

    def edit_user
        @project_user = ProjectUser.find_by(project_user_id: params[:projectuserid])
        @project = Project.find_by(projectid: params[:projectid])
        @user = User.find_by(id: @project_user.user_id)
        # render plain: @project.inspect
        @users = User.pluck(:fullname, :id).to_a.unshift(["Select Name", ""])
    end

   def update_user
    @project_user = ProjectUser.find_by(project_user_id: params[:projectuserid])
    @project = Project.find_by(id: @project_user.project_id)
        if @project_user.nil?
            flash[:error] = "Project user not found."
            redirect_to projects_users_path
            return
        end
    project_user = params[:project_user]
    @accesses = ["write_access","read_access","update_access","delete_access"]
    @accesses.each do |access|
        project_user[access] = project_user[access] == "1" ? true : false
    end
        if @project_user.update(project_user_params)
            flash[:success] = "User's access to project updated successfully."
            redirect_to projects_users_path + "/#{@project[:projectid]}/users"

        else
            flash[:error] = "Failed to update user's access to project."
            render 'edit_user'
        end
   end


    def update
        params[:project][:user_id] = session[:id]
        @project = Project.find_by(projectid: params[:projectid])
        params[:project].delete(:user_id)
        # render plain: params.inspect
        if (@project.update(project_params))
            flash[:success] = "Project Updated Successfully"
            redirect_to projects_users_path
        else
            render 'users/edit_project'
        end
    end

    def destroy
        @project = Project.find_by(projectid: params[:projectid])
        @project.destroy
        flash[:error] = "Project Deleted Successfully"
        redirect_to projects_users_path
    end

    def attachments
        @projects = Project.find_by(projectid: params[:projectid])
        # @projects.attachments.each do |attachment|
        #     puts attachment
        # end
        # render plain: @projects.attachments.inspect
    end

    def upload_attachments
        # render plain: 
    end

    def delete_attachment
        @attachment = ActiveStorage::Attachment.find(params[:id])
        @attachment.purge
        flash[:error] = "Attachment Deleted Successfully"
        redirect_to projects_users_path
        # render plain: @attachment.inspect
    end

    def get_project
        @project = Project.find_by(projectid: params[:projectid])
    end

    def threads
        @project = Project.find_by(projectid: params[:projectid])
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

    private
        def project_params
            params.require(:project).permit(:title, :description, :user_id, :projectid)
        end

        def project_user_params
            params.require(:project_user).permit(:project_user_id, :user_id, :project_id, :write_access, :read_access, :update_access, :delete_access)
        end
end
