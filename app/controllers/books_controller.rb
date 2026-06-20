class BooksController < ApplicationController
  before_action :restrict_guest, only: [:destroy]
  require 'net/http'
  require 'json'
  require 'open-uri'

  def index
    @ownerships = current_user.ownerships.includes(:book)
    @total_books = @ownerships.count
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

        @book = Book.find_or_create_by(
          title: book_params[:title].strip,
          author: book_params[:author].strip
        )

        unless @book
          @book = Book.new(book_params)
          @book.series = series if series

          # 画像の登録
          if params[:book][:cover_image].present?
            @book.cover_image.attach(params[:book][:cover_image])
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

  def api_search
    keyword = params[:keyword]
    limit = (params[:limit] || 10).to_i
    page = (params[:page] || 1).to_i
    @total_count = response["totalItems"] 

    start_index = (page - 1) * limit
    if keyword.present?
      response = HTTParty.get(
        "https://www.googleapis.com/books/v1/volumes",
        query: {
          q: keyword,
          key: ENV["GOOGLE_BOOKS_API_KEY"],
          maxResults: limit,
          startIndex: start_index
        }
      )

      if response.code == 200
        @books = response.parsed_response["items"] || []
        @page = page
        @limit = limit
        @keyword = keyword
      else
        @books = []
        flash.now[:alert] = "検索に失敗しました"
      end
    else
      @books = []
    end
  end

  def api_show
  google_id = params[:id]

  api_key = ENV['GOOGLE_BOOKS_API_KEY']

  url = URI("https://www.googleapis.com/books/v1/volumes/#{google_id}?key=#{api_key}")
  response = Net::HTTP.get_response(url)
  data = JSON.parse(response.body)
  @book = data 
  end
  

 def register
    book_params = params[:book]

    author = book_params[:author].presence || "不明"

    book = Book.find_or_create_by(
      title: book_params[:title],
      author: author
    )
    if book.persisted? && book.cover_image.blank?
      if book_params[:image_url].present?
        file = URI.open(book_params[:image_url])
        book.cover_image.attach(io: file, filename: "book.jpg")
      end
    end
    unless book.persisted?
      redirect_to books_path, alert: "本の保存に失敗しました"
      return
    end

    book.update(body: book_params[:description]) if book.body.blank?

    current_user.ownerships.find_or_create_by(book: book)

    redirect_to books_path, notice: "登録しました"
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
