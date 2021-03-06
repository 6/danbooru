class FavoritesController < ApplicationController
  before_filter :member_only
  
  def index
    if params[:tags]
      redirect_to(posts_path(:tags => params[:tags]))
    else
      @favorite_set = PostSets::Favorite.new(CurrentUser.user, params[:page])
    end
  end
  
  def create
    if CurrentUser.favorite_limit.nil? || CurrentUser.favorite_count < CurrentUser.favorite_limit
      Post.find(params[:post_id]).add_favorite!(CurrentUser.user)
    else
      @error_msg = "You can only keep up to #{CurrentUser.favorite_limit} favorites. Upgrade your account to save more."
    end
  end
  
  def destroy
    Post.find(params[:id]).remove_favorite!(CurrentUser.user)
  end
end
