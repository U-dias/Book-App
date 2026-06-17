class BooksController < ApplicationController
  before_action :restrict_guest, only: [:destroy]

  def index
    @ownerships = current_user.ownerships.includes(:book)

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
    @series = Series.all

    #書籍の新規登録
    @book = Book.find_or_initialize_by(
      title: book_params[:title],
      author: book_params[:author],
      series_id: book_params[:series_id])

      #シリーズの作成又は既存使用
      series_name = params[:book][:series_name].presence
      series_id   = params[:book][:series_id].presence

      series =
        if series_name.present?
          Series.find_or_create_by(name: series_name.strip)
        elsif series_id.present?
          Series.find_by(id: series_id)
        else
          nil
        end
      # 画像の登録
      if params[:book][:cover_image].present?
        @book.cover_image.attach(params[:book][:cover_image])
      end
      return render :new unless @book.save
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

    # 画像の更新
      if params[:book][:cover_image].present?
        @book.cover_image.purge
        @book.cover_image.attach(params[:book][:cover_image])
      end
      redirect_to @book, notice: "更新しました"
    else
      flash.now[alert] = "更新に失敗しました。"
      render :edit
    end
  end

  def destroy
    @book = current_user.books.find_by(params[:id])
    if current_user.guest?
      redirect_to books_path, notice: "削除しました（ゲストユーザーのため実際には削除されていません）"
    else
      @book.destroy
      redirect_to books_path, notice: "削除しました"
    end
  end

  private
  def book_params
    params.require(:book).permit(
      :title, :author, :series_id, :body, :status, :rating, :cover_image,
    tag_ids: [])
  end

end
