require_relative "../lib/rijn"

RSpec.describe Rijn do
  describe ".generate_key" do
    it "generates a 256-bit key by default" do
      key = Rijn.generate_key

      expect(Base64.strict_decode64(key).bytesize).to eq(32)
    end

    it "generates a 128-bit key" do
      key = Rijn.generate_key(128)

      expect(Base64.strict_decode64(key).bytesize).to eq(16)
    end

    it "generates a 192-bit key" do
      key = Rijn.generate_key(192)

      expect(Base64.strict_decode64(key).bytesize).to eq(24)
    end

    it "generates a 256-bit key" do
      key = Rijn.generate_key(256)

      expect(Base64.strict_decode64(key).bytesize).to eq(32)
    end

    it "rejects unsupported key sizes" do
      expect { Rijn.generate_key(64) }
        .to raise_error(Rijn::InvalidKeyError)
    end
  end

  describe ".encrypt" do
    [128, 192, 256].each do |bits|
      it "encrypts with a #{bits}-bit key" do
        key = Rijn.generate_key(bits)

        encrypted = Rijn.encrypt("Hello, Ruby!", key)

        expect(encrypted).to be_a(String)
        expect(encrypted).not_to eq("Hello, Ruby!")
      end
    end

    it "rejects an invalid Base64 key" do
      expect {
        Rijn.encrypt("Hello, Ruby!", "not-valid-base64!!!")
      }.to raise_error(Rijn::InvalidKeyError, "Key is not valid Base64.")
    end

    it "rejects a key with the wrong length" do
      key = Base64.strict_encode64("too short")

      expect {
        Rijn.encrypt("Hello, Ruby!", key)
      }.to raise_error(Rijn::InvalidKeyError, "Key must be 128, 192, or 256 bits.")
    end

    it "rejects a key with an unsupported length" do
      key = Base64.strict_encode64(SecureRandom.random_bytes(20))

      expect { Rijn.encrypt("Hello, Ruby!", key) }
        .to raise_error(Rijn::InvalidKeyError)
    end
  end

  describe ".decrypt" do
    [128, 192, 256].each do |bits|
      it "decrypts a value encrypted with a #{bits}-bit key" do
        key = Rijn.generate_key(bits)
        message = "Hello, Ruby!"

        encrypted = Rijn.encrypt(message, key)
        decrypted = Rijn.decrypt(encrypted, key)

        expect(decrypted).to eq(message)
      end
    end

    it "rejects an incorrect key" do
      key = Base64.strict_encode64(SecureRandom.random_bytes(32))
      wrong_key = Base64.strict_encode64(SecureRandom.random_bytes(32))

      encrypted = Rijn.encrypt("Hello, Ruby!", key)

      expect {
        Rijn.decrypt(encrypted, wrong_key)
      }.to raise_error(Rijn::AuthenticationError)
    end

    it "rejects modified encrypted values" do
      key = Base64.strict_encode64(SecureRandom.random_bytes(32))
      encrypted = Rijn.encrypt("Hello, Ruby!", key)

      tampered = Base64.strict_decode64(encrypted)
      tampered.setbyte(12, tampered.getbyte(12) ^ 1)
      tampered = Base64.strict_encode64(tampered)

      expect {
        Rijn.decrypt(tampered, key)
      }.to raise_error(Rijn::AuthenticationError)
    end

    it "rejects a key with an unsupported length" do
      key = Base64.strict_encode64(SecureRandom.random_bytes(20))

      expect { Rijn.decrypt("not a valid encrypted value", key) }
        .to raise_error(Rijn::InvalidKeyError)
    end
  end

  describe "encryption and decryption" do
    [128, 192, 256].each do |bits|
      it "round-trips a message with a #{bits}-bit key" do
        key = Rijn.generate_key(bits)
        encrypted = Rijn.encrypt("Hello, Ruby!", key)

        expect(Rijn.decrypt(encrypted, key)).to eq("Hello, Ruby!")
      end
    end
  end
end
