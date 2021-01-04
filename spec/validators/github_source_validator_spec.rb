require "spec_helper"

describe GithubSourceValidator do
  include MetaHelper

  let(:client_response) { double }
  let(:client) { instance_double(Octokit::Client) }

  before do
    stub_meta

    allow(client_response).to receive(:hooks).and_return(["192.30.252.41", "192.30.252.46"])
    allow(client).to receive(:get).and_return(client_response)
    allow(Octokit::Client).to receive(:new).and_return(client)
  end

  context "verifies IPs" do
    it "returns production" do
      expect(GithubSourceValidator.new("127.0.0.1")).to_not be_valid
      expect(GithubSourceValidator.new("192.30.252.41")).to be_valid
      expect(GithubSourceValidator.new("192.30.252.46")).to be_valid
    end
  end
end
