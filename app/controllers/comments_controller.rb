class CommentsController < ApplicationController

	before_action :authenticate_user!
  before_action :set_post

  def index
    @comments = Comment.all.order(created_at: :desc)
    @comment = Comment.new
  end

  def new
    @post = Post.find(params[:post_id])
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.create(comment_params)
    @comment.user = current_user
    comment = current_user.comments.build(comment_params)

    if @comment.save
      redirect_to root_path, notice: 'Comment has been created'
    else
      redirect_to root_path, alert: 'Comment has not been created'
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to root_path
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :post_id)
  end

end
