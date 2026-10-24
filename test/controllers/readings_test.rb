require "test_helper"

# What someone reads is only remembered when they asked for it, and forgotten
# the moment they take it back. On a mental health site that is the whole point.
class ReadingsTest < ActionDispatch::IntegrationTest
  setup do
    @article = Article.create!(title: "El insomnio como mensajero", published_at: 1.day.ago,
                               tag_list: "etiqueta-interna")
    @student = users(:student)
  end

  def consent!
    @student.update!(remember_reading: true)
  end

  test "nothing is remembered for someone who has not said yes" do
    sign_in_as @student

    get reflection_path(id: @article)

    assert_response :success
    assert_equal 0, Reading.count
  end

  test "nothing is remembered for a visitor without an account" do
    get reflection_path(id: @article)

    assert_equal 0, Reading.count
  end

  test "for someone who said yes, opening a piece is remembered once, with the last time" do
    consent!
    sign_in_as @student

    travel_to 2.days.ago do
      get reflection_path(id: @article)
    end
    get reflection_path(id: @article)

    reading = @student.readings.sole
    assert_equal @article, reading.article
    assert_in_delta Time.current, reading.last_read_at, 5.seconds
  end

  test "an administrator proofing a draft is not a reader" do
    draft = Article.create!(title: "Borrador")
    owner = users(:owner)
    owner.update!(remember_reading: true)
    sign_in_as owner

    get reflection_path(id: draft)

    assert_equal 0, Reading.count
  end

  test "the tags never reach the page" do
    get reflection_path(id: @article)

    assert_no_match "etiqueta-interna", response.body
  end

  test "taking the permission back forgets what was read" do
    consent!
    sign_in_as @student
    get reflection_path(id: @article)

    patch preferences_path, params: { user: { remember_reading: "0", wants_news: "0" } }

    assert_not @student.reload.remembers_reading?
    assert_equal 0, @student.readings.count
  end
end
