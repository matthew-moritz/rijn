require "base64"
require "openssl"
require "securerandom"

module Rijn
  # AES-256 requires a 32-byte key.
  KEY_LENGTH = 32

  # Rijn uses a 12-byte nonce for AES-GCM.
  NONCE_LENGTH = 12

  # Rijn stores a 16-byte authentication tag.
  AUTH_TAG_LENGTH = 16

  # Generates a cryptographically secure AES-256 encryption key.
  #
  # @return [String] Base64-encoded 32-byte encryption key
  def self.generate_key
    Base64.strict_encode64(SecureRandom.random_bytes(KEY_LENGTH))
  end

  # Encrypts a value using AES-256-GCM.
  #
  # @param value [String] the plaintext value to encrypt
  # @param key [String] Base64-encoded 32-byte encryption key
  # @return [String] Base64-encoded encrypted value
  # @raise [InvalidKeyError] if the key is invalid
  def self.encrypt(value, key)
    key = decode_key(key)
    validate_key!(key)

    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.encrypt

    nonce = SecureRandom.random_bytes(NONCE_LENGTH)

    cipher.key = key
    cipher.iv = nonce

    ciphertext = cipher.update(value) + cipher.final

    tag = cipher.auth_tag

    Base64.strict_encode64(nonce + ciphertext + tag)
  end

  # Decrypts a value encrypted with AES-256-GCM.
  #
  # @param encrypted_value [String] Base64-encoded encrypted value
  # @param key [String] Base64-encoded 32-byte encryption key
  # @return [String] the decrypted plaintext value
  # @raise [InvalidKeyError] if the key is invalid
  # @raise [AuthenticationError] if the encrypted value fails authentication
  def self.decrypt(encrypted_value, key)
    key = decode_key(key)
    validate_key!(key)

    # Rijn stores encrypted values as:
    #
    #   nonce (12 bytes) + ciphertext + authentication tag (16 bytes)
    #
    # The nonce is not secret and is required for decryption.
    # The authentication tag is used by AES-GCM to verify the ciphertext.
    decoded = Base64.strict_decode64(encrypted_value)

    nonce = decoded.byteslice(0, NONCE_LENGTH)
    ciphertext = decoded.byteslice(NONCE_LENGTH...-AUTH_TAG_LENGTH)
    tag = decoded.byteslice(-AUTH_TAG_LENGTH, AUTH_TAG_LENGTH)

    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.decrypt

    cipher.key = key
    cipher.iv = nonce
    cipher.auth_tag = tag

    begin
      cipher.update(ciphertext) + cipher.final
    rescue OpenSSL::Cipher::CipherError
      raise AuthenticationError, "Unable to decrypt value."
    end
  end

  private

  def self.decode_key(key)
    Base64.strict_decode64(key)
  rescue ArgumentError
    raise InvalidKeyError, "Key is not valid Base64."
  end

  def self.validate_key!(key)
    unless key.bytesize == KEY_LENGTH
      raise InvalidKeyError, "Key must be #{KEY_LENGTH} bytes."
    end
  end
end
