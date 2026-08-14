require "base64"
require "securerandom"
require "stringio"
require_relative "../lib/rijn_cli"

def generate_key
  Base64.strict_encode64(SecureRandom.random_bytes(32))
end

RSpec.describe RijnCLI do
  describe "version" do
    it "outputs the current version" do
      expect {
        RijnCLI.start(["version"])
      }.to output("#{Rijn::VERSION}\n").to_stdout
    end

    it "rejects an unknown command" do
      expect {
        RijnCLI.start(["not-a-command"])
      }.to raise_error(SystemExit) { |error|
        expect(error.status).not_to eq(0)
      }
    end
  end

  describe "encrypt" do
    key = generate_key
    value = "Hello, Rijn!"

    it "outputs only the encrypted value" do
      stdout = StringIO.new

      allow($stdout).to receive(:write) { |output| stdout.write(output) }

      RijnCLI.start([
        "encrypt",
        "--value", value,
        "--key", key
      ])

      encrypted = stdout.string.strip

      expect(encrypted).not_to be_empty
      expect(Rijn.decrypt(encrypted, key)).to eq(value)
    end

    it "prompts for missing values" do
      key = generate_key
      value = "Hello, Rijn!"

      allow(PROMPT).to receive(:ask).and_return(value)
      allow(PROMPT).to receive(:mask).and_return(key)

      stdout = StringIO.new
      allow($stdout).to receive(:write) { |output| stdout.write(output) }

      RijnCLI.start(["encrypt"])

      encrypted = stdout.string.strip

      expect(Rijn.decrypt(encrypted, key)).to eq(value)
    end

    it "reports an invalid key" do
      stderr = StringIO.new

      allow($stderr).to receive(:write) { |output| stderr.write(output) }

      expect {
        RijnCLI.start([
          "encrypt",
          "--value", "Hello, Rijn!",
          "--key", "not-a-valid-key"
        ])
      }.to raise_error(SystemExit) { |error|
        expect(error.status).not_to eq(0)
      }

      expect(stderr.string).to include("Key is not valid Base64.")
    end
  end

  describe "decrypt" do
    it "outputs the decrypted value" do
      key = generate_key
      value = "Hello, Rijn!"
      encrypted = Rijn.encrypt(value, key)

      stdout = StringIO.new
      allow($stdout).to receive(:write) { |output| stdout.write(output) }

      RijnCLI.start([
        "decrypt",
        "--value", encrypted,
        "--key", key
      ])

      expect(stdout.string.strip).to eq(value)
    end

    it "prompts for missing values" do
      key = generate_key
      value = "Hello, Rijn!"

      encrypted = Rijn.encrypt(value, key)

      allow(PROMPT).to receive(:ask).and_return(encrypted)
      allow(PROMPT).to receive(:mask).and_return(key)

      stdout = StringIO.new
      allow($stdout).to receive(:write) { |output| stdout.write(output) }

      RijnCLI.start(["decrypt"])

      expect(stdout.string.strip).to eq(value)
    end

    it "reports an authentication failure" do
      key = generate_key
      wrong_key = generate_key
      encrypted = Rijn.encrypt("Hello, Rijn!", key)

      stderr = StringIO.new
      allow($stderr).to receive(:write) { |output| stderr.write(output) }

      expect {
        RijnCLI.start([
          "decrypt",
          "--value", encrypted,
          "--key", wrong_key
        ])
      }.to raise_error(SystemExit) { |error|
        expect(error.status).not_to eq(0)
      }

      expect(stderr.string).to include("Unable to decrypt value.")
    end
  end

  describe "keygen" do
    it "outputs a generated encryption key" do
      key = "test-key"

      allow(Rijn).to receive(:generate_key).and_return(key)

      expect {
        RijnCLI.start(["keygen"])
      }.to output("#{key}\n").to_stdout

      expect(Rijn).to have_received(:generate_key)
    end
  end
end
