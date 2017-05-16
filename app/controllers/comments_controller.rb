class CommentsController < ApplicationController
  before_action :authenticate_user!, only: :create
  before_action :load_commentable, only: :create
  before_action :build_comment, only: :create

  load_and_authorize_resource
  respond_to :html, :js

  def create
    if @comment.save
      CommentNotifier.new(comment: @comment).process
      add_notification @comment
    else
      render :new
    end
  end

  def show
    @comment = Comment.find(params[:id])
    set_comment_flags(@comment.subtree)
  end

  def vote
    @comment.vote_by(voter: current_user, vote: params[:value])
    respond_with @comment
  end

  def flag
    Flag.flag(current_user, @comment)
    set_comment_flags(@comment)
    respond_with @comment, template: 'comments/_refresh_flag_actions'
  end

  def unflag
    Flag.unflag(current_user, @comment)
    set_comment_flags(@comment)
    respond_with @comment, template: 'comments/_refresh_flag_actions'
  end

  private

    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id, :parent_id, :body, :as_moderator, :as_administrator)
    end

    def build_comment
      @comment = Comment.build(@commentable, current_user, comment_params[:body], comment_params[:parent_id].presence)
      check_for_special_comments
    end

    def check_for_special_comments
      if administrator_comment?
        @comment.administrator_id = current_user.administrator.id
      elsif moderator_comment?
        @comment.moderator_id = current_user.moderator.id
      end
    end

    def load_commentable
      @commentable = Comment.find_commentable(comment_params[:commentable_type], comment_params[:commentable_id])
    end

    def administrator_comment?
      ["1", true].include?(comment_params[:as_administrator]) && can?(:comment_as_administrator, @commentable)
    end

    def moderator_comment?
      ["1", true].include?(comment_params[:as_moderator]) && can?(:comment_as_moderator, @commentable)
    end

    def add_notification(comment)
      if comment.reply?
        notifiable = comment.parent
      else
        notifiable = comment.commentable
      end
      Notification.add(notifiable.author_id, notifiable) unless comment.author_id == notifiable.author_id
   end

end