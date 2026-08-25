require "test_helper"

module Admin
  class InquiriesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as users(:owner)
      @inquiry = Inquiry.create!(name: "Ana", email: "ana@example.com", message: "Quiero saber más.")
    end

    test "index lists messages" do
      get admin_inquiries_path

      assert_response :success
      assert_select "a", text: @inquiry.name
    end

    test "show renders the message" do
      get admin_inquiry_path(@inquiry)

      assert_response :success
      assert_select "p", text: @inquiry.message
    end

    test "marking a message answered and putting it back" do
      post admin_inquiry_handling_path(@inquiry)
      assert @inquiry.reload.handled?

      delete admin_inquiry_handling_path(@inquiry)
      assert_not @inquiry.reload.handled?
    end

    test "destroy removes the message" do
      assert_difference -> { Inquiry.count }, -1 do
        delete admin_inquiry_path(@inquiry)
      end

      assert_redirected_to admin_inquiries_path
    end
  end
end
