# -*- coding: utf-8 -*-
require 'rest-client'
require 'nokogiri'
require 'uri'


class BookjudgesController < ApplicationController
  before_action :set_bookjudge, only: [:show, :edit, :update, :destroy]

  # GET /bookjudges
  # GET /bookjudges.json
  def index
    @bookjudges = Bookjudge.all
  end

  # GET /bookjudges/1
  # GET /bookjudges/1.json
  def show
  end

  # GET /bookjudges/new
  def new
    @bookjudge = Bookjudge.new
  end

  # GET /bookjudges/1/edit
  def edit
  end

  # POST /bookjudges
  # POST /bookjudges.json
  def create
    @bookjudge = Bookjudge.new(bookjudge_params)

    #共通文字列
    query_str = ""
    api_path = "http://iss.ndl.go.jp/api/opensearch"
    normal_query_str = "?title=" + @bookjudge.title.to_s + "&publisher=" + @bookjudge.author
    isbn_query_str = "?isbn=" + @bookjudge.isbn

    #NDLへの検索文字列の作成
    if @bookjudge.isbn.length > 0
      query_str = api_path + isbn_query_str
    elsif
      query_str = api_path + normal_query_str
    end

    #検索実施
    response = RestClient.get URI.escape(query_str)
    response.headers

    #タイトル単位で配列に入れる
    xml = response.to_str
    puts "query_str = " + query_str
    puts xml
    doc = Nokogiri::XML(xml)
    str = ""
    myarr = Array.new
    doc.xpath('/rss/channel/item/title').each do |item|
      myarr.push(item)
    end


    #結果判定
    if myarr.size < 1 #NDLにない
      @bookjudge.judge_result = 1
    elsif
      @bookjudge.judge_result = 0
    end

    #返却
    respond_to do |format|
      if @bookjudge.judge_result == 1 && @bookjudge.save
        format.html { redirect_to @bookjudge, notice: 'やった！ 国会図書館に納本されていないみたいです！' }
        format.json { render :show, status: :created, location: @bookjudge }
      else
        format.html { redirect_to @bookjudge, notice: '残念、もう国会図書館に所蔵されているようです。' }
        #format.html { render :new }
        format.json { render json: @bookjudge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookjudges/1
  # PATCH/PUT /bookjudges/1.json
  def update
    respond_to do |format|
      if @bookjudge.update(bookjudge_params)
        format.html { redirect_to @bookjudge, notice: 'Bookjudge was successfully updated.' }
        format.json { render :show, status: :ok, location: @bookjudge }
      else
        format.html { render :edit }
        format.json { render json: @bookjudge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookjudges/1
  # DELETE /bookjudges/1.json
  def destroy
    @bookjudge.destroy
    respond_to do |format|
      format.html { redirect_to bookjudges_url, notice: 'Bookjudge was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bookjudge
      @bookjudge = Bookjudge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bookjudge_params
      params.require(:bookjudge).permit(:title, :author, :isbn, :judge_result)
    end

    def judge_by_yunica(bookjudge)
      #共通文字列 ?operation=searchRetrieve&query%3Ddpid%3D%22iss-yunika%22%20AND%20isbn%3D%229784787200532%22
      query_str = ""
      api_path = "http://iss.ndl.go.jp/api/sru"
      normal_query_str = "?title=" + @bookjudge.title.to_s + "&publisher=" + @bookjudge.author
      isbn_query_str = "?operation=searchRetrieve&query%3Ddpid%3D%22iss-yunika%22%20AND%20isbn%3D%22" +  + "%22"

      #NDLへの検索文字列の作成
      if @bookjudge.isbn.length > 0
        query_str = api_path + isbn_query_str
      elsif
        query_str = api_path + normal_query_str
      end

      #検索実施
      response = RestClient.get URI.escape(query_str)
      response.headers

      #タイトル単位で配列に入れる
      xml = response.to_str
      puts "query_str = " + query_str
      puts xml
      doc = Nokogiri::XML(xml)
      str = ""
      myarr = Array.new
      doc.xpath('/rss/channel/item/title').each do |item|
        myarr.push(item)
      end

      #結果判定
      if myarr.size < 1 #NDLにない
        @bookjudge.judge_result = 1
      elsif
        @bookjudge.judge_result = 0
      end
    end

end
