require_relative "../lib/rijn"

RSpec.describe Rijn do
  describe ".generate_key" do
    it "generates a valid Base64-encoded 32-byte key" do
      key = Rijn.generate_key
      decoded = Base64.strict_decode64(key)

      expect(decoded.bytesize).to eq(32)
    end
  end

  describe ".encrypt" do
    it "encrypts a message" do
      key = Base64.strict_encode64(SecureRandom.random_bytes(32))

      encrypted = Rijn.encrypt("Hello, Ruby!", key)

      expect(encrypted).not_to eq("Hello, Ruby!")
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
      }.to raise_error(Rijn::InvalidKeyError, "Key must be 32 bytes.")
    end
  end

  describe ".decrypt" do
    it "can decrypt an encrypted message" do
      key = Base64.strict_encode64(SecureRandom.random_bytes(32))
      message = "Hello, Ruby!"

      encrypted = Rijn.encrypt(message, key)
      decrypted = Rijn.decrypt(encrypted, key)

      expect(decrypted).to eq(message)
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
  end
end
