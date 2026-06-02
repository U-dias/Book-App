class BooksController < ApplicationController
  before_action :require_login, only: [:new, :create]
  def index
    @books = Book.all
    #キーワード検索
    if params[:keyword].present?
    @books = Book.where("title LIKE ? OR author LIKE ?", "%#{params[:keyword]}%", "%#{params[:keyword]}%")
    end
    #タグ検索
    if params[:tag_ids].present?
    @books = Book.joins(:tags).where(tags: { id: params[:tag_ids] })
    end
  end

  def new
    @book = Book.new
    @book.user = current_user
    @series = Series.all
  end

  def create
    #シリーズの作成又は既存使用
    @book = Book.new(book_params)
    @book.user = current_user
    if params[:book][:series_name].present?
      @book.series = Series.find_or_create_by(name: params[:book][:series_name])
    elsif params[:book][:series_id].present?
      @book.series = Series.find(params[:book][:series_id])
    end
    if @book.save
      redirect_to book_path(@book)
    else
      @series = Series.all
      render :new
    end
  end

  def show
    #閲覧履歴の表示
    @book = Book.find(params[:id])

    history = current_user.read_histories.find_or_create_by(book: @book)
    history.touch

    @histories = current_user.read_histories.order(updated_at: :desc)
    @histories.offset(20).destroy_all if @histories.count > 20

    #続きの書籍を表示
    @book = Book.find(params[:id])
    @continuation = current_user.books
      .where(status: [:unread, :reading])
      .limit(5)
  end

  def edit
    @book = Book.find(params[:id])
    @tag_name = params[:tag_name]
    @series = Series.all
  end

  def update
    @book = Book.find(params[:id])
    tag_name = params[:book][:tag_name]

    #シリーズの更新
    @book.assign_attributes(book_params)
    if params[:book][:series_name].present?
      @book.series = Series.find_or_create_by(name: params[:book][:series_name])
    elsif params[:book][:series_id].present?
      @book.series = Series.find(params[:book][:series_id])
    end
    #タグの更新
    selected_tags = Tag.where(id: params[:book][:tag_ids])
    
    new_tags = if params[:book][:tag_name].present?
      params[:book][:tag_name].split.map do |name|
        Tag.find_or_create_by(name: name)
      end
    else
      []
    end
    @book.tags = selected_tags + new_tags
    #ステータスの更新
    @book.status = params[:book][:status]
    if @book.save
      redirect_to book_path(@book)
    else
      @series = Series.all
      render :edit
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private
  def book_params
    params.require(:book).permit(
      :title, :author, :series_id, :body, :status, :rating,
    tag_ids: [])
  end

  def require_login
    redirect_to login_path unless current_user
  end
end
