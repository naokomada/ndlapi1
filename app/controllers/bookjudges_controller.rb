# -*- coding: utf-8 -*-
require 'rest-client'
require 'nokogiri'
require 'uri'
require "rexml/document"

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


    ndl_result_hash = judge_by_ndl @bookjudge
    ndl_result = ndl_result_hash[:result]
    yunica_result = judge_by_yunica @bookjudge


    #結果生成
    #judge_result
    # 2 ？ NDLにないし他にもない　存在しない本？
    # 1 O NDLにないが他の場所にある
    # 0 X NDLにある
    if ndl_result #ndlにあった
      @bookjudge.judge_result = 0
    elsif !ndl_result && yunica_result #ndlにはない　他の図書館にある
      @bookjudge.judge_result = 1
    else
      @bookjudge.judge_result = 2
    end

    title = ""
    title = ndl_result_hash[:title] if ndl_result_hash[:title]

    option_str = "NDLの結果: " + title + " -> " + ndl_result.to_s + ""
    option_str += "ゆにかねっとの結果: -> " + yunica_result.to_s + ""

    #返却
    respond_to do |format|
      if @bookjudge.judge_result == 1 && @bookjudge.save
        format.html { redirect_to @bookjudge, notice: ('やった！ 国会図書館に納本されていないみたいです！' + option_str) }
        format.json { render :show, status: :created, location: @bookjudge }
      elsif @bookjudge.judge_result == 2
        format.html { redirect_to @bookjudge, notice: ('すみません、うまく検索できませんでした。もしかしたら存在しない本かもしれません。' + option_str) }
        #format.html { render :new }
        format.json { render json: @bookjudge.errors, status: :unprocessable_entity }
      else
        format.html { redirect_to @bookjudge, notice: ('残念、もう国会図書館に所蔵されているようです。' + option_str) }
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


  def judge_by_ndl(bookjudge)

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
    #puts "query_str = " + query_str
    #puts xml
    doc = Nokogiri::XML(xml)
    str = ""
    myarr = Array.new
    doc.xpath('/rss/channel/item/title').each do |item|
      myarr.push(item.text)
    end

    #結果判定
    judge_r = (myarr.size > 0) ? true : false  #ndlで調べた結果 あったらtrue
    result_hash = {:result => judge_r, :title => myarr.first }
    logger.debug(result_hash.to_s)
    result_hash
  end



  def judge_by_yunica(bookjudge)

      #共通文字列
      query_str = ""
      api_path = "http://iss.ndl.go.jp/api/sru"
      #normal_query_str = "?title=" + @bookjudge.title.to_s + "&publisher=" + @bookjudge.author
      isbn_query_str = "?operation=searchRetrieve&query%3Ddpid%3D%22iss-yunika%22%20AND%20isbn%3D%22" + URI.escape(bookjudge.isbn)  + "%22"

      logger.debug("yunica isbnstr")
      logger.debug(isbn_query_str)
      logger.debug("end")


      #検索文字列の作成
      if @bookjudge.isbn.length > 0
        query_str = api_path + isbn_query_str
#      elsif
#        query_str = api_path + normal_query_str
      end

      #検索実施
      response = RestClient.get query_str
      response.headers

      xdoc = REXML::Document.new(response.to_str)

      #結果判定
      result = xdoc.elements["//searchRetrieveResponse"].elements["numberOfRecords"].text.to_i
      (result == 1) ? true : false  #ゆにかで調べた結果（他の図書館で所蔵があるか）あったらtrue
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
end
