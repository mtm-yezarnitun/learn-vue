module Api
  module V1
    class PostsController < ApplicationController
      before_action :set_post, only: [:destroy]

      def index
        posts = Post.all.order(created_at: :desc)
        render json: posts
      end

      def create
        post = Post.new(post_params)
        if post.save
          render json: post, status: :created
        else
          render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @post.destroy
        render json: { message: 'Post deleted' }
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title, :content)
      end
    end
  end
end
