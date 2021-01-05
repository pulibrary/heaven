require "rails_helper"

describe "Visiting in a browser" do
  describe "GET /" do
    it "redirects to github.com" do
      get "/"

      expect(response).to be_redirect
      expect(response.headers["Location"]).to eq(
        "https://github.com/atmos/heaven"
      )
    end
  end
end
