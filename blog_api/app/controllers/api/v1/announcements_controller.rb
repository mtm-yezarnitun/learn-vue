class Api::V1::AnnouncementsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def authorize_admin!
        unless current_user.role == 'admin'
            render json: { error: "Access Denied !"} , status: :forbidden
        end
    end

    def index
        @announcements = Announcement.order(start_time: :desc)
        render json: @announcements
    end
    
    def active 
        active_ones = Announcement.where(active: true)
        render json: active_ones
    end

    def create
        announcement = Announcement.new(announcement_params)
        if announcement.save
        AnnouncementSchedulerJob.set(wait_until: announcement.start_time).perform_async(announcement.id)
        render json: announcement
        else
        render json: { errors: announcement.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update
        announcement = Announcement.find(params[:id])
        if announcement.update(announcement_params)
        render json: announcement
        else
        render json: { errors: announcement.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        announcement = Announcement.find(params[:id])
        announcement.destroy
        head :no_content
    end

    private

    def announcement_params
        params.require(:announcement).permit(:title,:message, :start_time, :end_time)
    end

end
