class ImagesController < ApplicationController
  before_action :search_images, only: [:index, :show, :select_characters, :search, :line]
  before_action :set_image, only: [:edit, :show, :update]

  def index
  end

  def show
    @image.open_count_increment
  end

  def search 
    @animation = Animation.find_by(id: params[:q][:animation_id_eq])
    @characters = Character.where(id: params[:q][:character_images_character_id_eq_any])
    @line = params[:q][:line_cont]
  end

  def select_animation
    @animations = Animation.all
  end

  def select_characters
    @animation = Animation.find_by(id: params[:animation_id])
    if @animation.present?
      @characters = Character.includes(:animations).where(animations: { id: @animation.id })
    else
      @characters = Character.all
    end
  end

  def new
    @image = Image.new
  end

  def create
    if @image = Image.create(image_params)
      flash[:notice] = 'アップロードしました'
      redirect_to edit_image_path(@image)
    else
      flash[:notice] = 'アップロードに失敗しました'
      render :new
    end
  end

  def edit
  end

  def update
    if @image.update!(update_image_params)
      flash[:notice] = '更新しました'
      redirect_to edit_image_path(@image)
    else
      flash[:notice] = '更新に失敗しました'
      render :new
    end
  end

  private

  def set_params
    @character_ids = params[:character_ids]
    @animation_ids = params[:animation_ids]
    @line = params[:line]
  end
  
  def search_images
    @q = Image.all

    # fackin relation and search
    if params[:q].present? && @character_ids = params[:q][:character_images_character_id_eq_any] 
      if @character_ids.size >= 2
        images = @q.character_ids_and_search(@character_ids)
        @q = Image.where(id: images.map{ |image| image.id })
      end
    end

    @q = @q.ransack(params[:q])

    @q.sorts = 'open_count desc' if @q.sorts.empty?
    @images = @q.result(distinct: true).page(params[:page])
  end

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:image, :image_cache, :remove_image, :animation_id, :line, :description)
  end

  def update_image_params
    params.require(:image).permit(:image, :image_cache, :remove_image, :animation_id, :line, :description, character_ids: [])
  end
end