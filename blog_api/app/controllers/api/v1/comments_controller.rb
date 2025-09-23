module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_post
      before_action :set_comment, only: [:destroy]
      # before_action :authorize_comment_owner!, only: [:destroy]

      def index
        comments = @post.comments.includes(:user)
        render json: comments, include: :user
      end

      def create
        comment = @post.comments.build(comment_params.merge(user: current_user))
        if comment.save
          render json: comment.as_json(include: { user: { only: [:id, :email] } }), status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @comment.destroy
        render json: { message: 'Comment deleted successfully.' },status: :ok
      end

      private

      def set_post
        @post = Post.find_by(id: params[:post_id])
        render json: { error: "Post not found" }, status: :not_found unless @post
      end

      def set_comment
        @comment = @post.comments.find_by(id: params[:id])
        render json: { error: "Comment not found" }, status: :not_found unless @comment
      end

      def authorize_comment_owner!
        unless @comment.user_id == current_user.id || current_user.admin?
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def comment_params
        params.require(:comment).permit(:content)
      end
    end
  end
end