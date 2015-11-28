require 'test_helper'

class BookjudgesControllerTest < ActionController::TestCase
  setup do
    @bookjudge = bookjudges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bookjudges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bookjudge" do
    assert_difference('Bookjudge.count') do
      post :create, bookjudge: { author: @bookjudge.author, isbn: @bookjudge.isbn, judge_result: @bookjudge.judge_result, title: @bookjudge.title }
    end

    assert_redirected_to bookjudge_path(assigns(:bookjudge))
  end

  test "should show bookjudge" do
    get :show, id: @bookjudge
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bookjudge
    assert_response :success
  end

  test "should update bookjudge" do
    patch :update, id: @bookjudge, bookjudge: { author: @bookjudge.author, isbn: @bookjudge.isbn, judge_result: @bookjudge.judge_result, title: @bookjudge.title }
    assert_redirected_to bookjudge_path(assigns(:bookjudge))
  end

  test "should destroy bookjudge" do
    assert_difference('Bookjudge.count', -1) do
      delete :destroy, id: @bookjudge
    end

    assert_redirected_to bookjudges_path
  end
end
