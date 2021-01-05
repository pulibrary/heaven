require "spec_helper"

describe WebhookValidations do
  include MetaHelper

  let(:client_response) { double }
  let(:client) { instance_double(Octokit::Client) }

  before do
    stub_meta

    allow(client_response).to receive(:hooks).and_return(["192.30.252.41", "192.30.252.46"])
    allow(client).to receive(:get).and_return(client_response)
    allow(Octokit::Client).to receive(:new).and_return(client)
  end

  class WebhookValidationsTester
    class Request
      def initialize(ip)
        @ip = ip
      end
      attr_accessor :ip
    end
    include WebhookValidations

    def initialize(ip)
      @ip = ip
    end

    def request
      Request.new(@ip)
    end
  end

  it "makes methods available" do
    klass = WebhookValidationsTester.new("192.30.252.41")
    expect(klass).to be_valid_incoming_webhook_address
    klass = WebhookValidationsTester.new("127.0.0.1")
    expect(klass).to_not be_valid_incoming_webhook_address
  end
end
