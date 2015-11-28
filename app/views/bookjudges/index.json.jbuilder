json.array!(@bookjudges) do |bookjudge|
  json.extract! bookjudge, :id, :title, :author, :isbn, :judge_result
  json.url bookjudge_url(bookjudge, format: :json)
end
