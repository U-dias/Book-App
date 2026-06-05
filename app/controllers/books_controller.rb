class BooksController < ApplicationController
  before_action :restrict_guest, only: [:edit, :update, :destroy]

  def index
    @ownerships = if current_user&.guest?
      Ownership.includes(:book).all
    else
      current_user.ownerships.includes(:book)
    end
    #キーワード検索
    if params[:keyword].present?
    @ownerships = @ownerships.joins(:book)
      .where("books.title LIKE ? OR books.author LIKE ?", "%#{params[:keyword]}%", "%#{params[:keyword]}%")
    end
    #タグ検索
    if params[:tag_ids].present?
    @ownerships = @ownerships.joins(book: :tags).where(tags: { id: params[:tag_ids] })
    end
  end

  def new
    @book = Book.new
    @series = Series.all
  end

  def create
    @book = Book.new(book_params)
    @series = Series.all

    #書籍の新規登録
    @book = Book.find_or_initialize_by(
      title: book_params[:title],
      author: book_params[:author],
      series_id: book_params[:series_id])

    # 登録済みの書籍
    if @book.persisted?
      flash.now[:alert] = "この本はすでに登録されています"
      @series = Series.all
      return render :new, status: :unprocessable_entity
    end

    if @book.new_record?
      @book.assign_attributes(book_params)
      #シリーズの作成又は既存使用
      if params[:book][:series_name].present?
        @book.series = Series.find_or_create_by(name: params[:book][:series_name])
      elsif params[:book][:series_id].present?
        @book.series = Series.find(params[:book][:series_id])
      end
      return render :new unless @book.save
    end
    current_user.ownerships.find_or_create_by(book: @book)
    redirect_to @book
  end

  def show
    @book = Book.find(params[:id])

    @ownership = current_user&.ownerships&.find_by(book_id: @book.id)
    #閲覧履歴の表示
    @ownership = current_user.ownerships.find_by(book: @book)

    history = current_user.read_histories.find_or_create_by(book: @book)
    history.touch

    @histories = current_user.read_histories.order(updated_at: :desc)
    @histories.offset(20).destroy_all if @histories.count > 20

    #続きの書籍を表示
    @ownership = current_user.ownerships.find_by(book_id: params[:id])
    @continuation = current_user.ownerships
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
    if @book.save
      ownership = current_user.ownerships.find_by(book_id: @book.id)
      ownership.update(status: params[:book][:status])
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

  def restrict_guest
    if current_user&.guest?
      redirect_to books_path, alert: "ゲストユーザーは編集・削除できません"
    end
  end

  private
  def book_params
    params.require(:book).permit(
      :title, :author, :series_id, :body, :status, :rating,
    tag_ids: [])
  end

end
