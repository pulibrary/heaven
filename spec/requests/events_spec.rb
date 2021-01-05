require "rails_helper"

describe "Receiving GitHub hooks", type: :request do
  let(:params) do
    content = File.read(fixture_path)
    JSON.parse(content)
  end

  before do
    allow(Octokit).to receive(:api_endpoint).and_return("http://localhost")
  end

  describe "POST /events" do
    context "when requesting with an invalid host" do
      let(:client_response) { double }
      let(:client) { instance_double(Octokit::Client) }

      before do
        allow(client_response).to receive(:hooks).and_return(["192.30.252.41", "192.30.252.46"])
        allow(client).to receive(:get).and_return(client_response)
        allow(Octokit::Client).to receive(:new).and_return(client)

        allow(Octokit).to receive(:api_endpoint).and_call_original
      end

      it "returns a forbidden error" do
        post "/events", params: "{}", headers: { "X-Github-Event" => "ping", "X-Github-Delivery" => SecureRandom.uuid }

        expect(response).to be_forbidden
        expect(response.status).to eql(403)
      end
    end

    context "when requesting with an invalid event" do
      it "returns a unprocessable error for invalid events" do
        post "/events", params: "{}", headers: { "X-Github-Event" => "invalid", "X-Github-Delivery" => SecureRandom.uuid }

        expect(response.status).to eql(422)
      end
    end

    context "when requesting the creation of a deployment resource" do
      let(:fixture_path) do
        Rails.root.join("spec", "fixtures", "ping.json")
      end

      it "handles ping events from valid hosts" do
        post "/events", params: params, headers: { "X-Github-Event" => "ping", "X-Github-Delivery" => SecureRandom.uuid }

        expect(response).to be_successful
        expect(response.status).to eql(201)
      end
    end

    context "when requesting the creation of a deployment resource" do
      let(:fixture_path) do
        Rails.root.join("spec", "fixtures", "deployment.json")
      end

      let(:client_response) { double }
      let(:gist) { Octokit::Gist.new("deadbeef") }
      let(:client) { instance_double(Octokit::Client) }

      before do
        allow(client).to receive(:update).and_return(gist)
        allow(client).to receive(:edit_gist)
        allow(client).to receive(:create_gist).and_return(gist)
        allow(client).to receive(:create).and_return(gist)
        allow(Octokit::Client).to receive(:new).and_return(client)
      end

      it "handles deployment events from valid hosts" do
        post "/events", params: params, headers: { "X-Github-Event" => "deployment", "X-Github-Delivery" => SecureRandom.uuid }

        expect(response).to be_successful
        expect(response.status).to eql(201)
      end
    end

    context "when requesting the deployment status" do
      let(:fixture_path) do
        Rails.root.join("spec", "fixtures", "deployment_staging.json")
      end

      it "handles deployment status events from valid hosts" do
        post "/events", params: params, headers: { "X-Github-Event" => "deployment_status", "X-Github-Delivery" => SecureRandom.uuid }

        expect(response).to be_successful
        expect(response.status).to eql(201)
      end
    end
  end
end
