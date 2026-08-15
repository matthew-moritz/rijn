require "base64"
require "openssl"
require "securerandom"

module Rijn
  KEY_LENGTHS = {
    128 => 16,
    192 => 24,
    256 => 32
  }.freeze

  CIPHERS = {
    16 => "aes-128-gcm",
    24 => "aes-192-gcm",
    32 => "aes-256-gcm"
  }.freeze

  # Rijn uses a 12-byte nonce for AES-GCM.
  NONCE_LENGTH = 12

  # Rijn stores a 16-byte authentication tag.
  AUTH_TAG_LENGTH = 16

  # Generates a cryptographically secure AES-GCM encryption key.
  #
  # @param bits [Integer] key size in bits; must be 128, 192, or 256
  # @return [String] Base64-encoded encryption key
  # @raise [InvalidKeyError] if the key size is unsupported
  def self.generate_key(bits = 256)
    length = KEY_LENGTHS.fetch(bits) do
      raise InvalidKeyError, "Key must be 128, 192, or 256 bits."
    end

    Base64.strict_encode64(SecureRandom.random_bytes(length))
  end

  # Encrypts a value using AES-GCM.
  #
  # @param value [String] the plaintext value to encrypt
  # @param key [String] Base64-encoded encryption key (128, 192, or 256 bits)
  # @return [String] Base64-encoded encrypted value
  # @raise [InvalidKeyError] if the key is invalid
  def self.encrypt(value, key)
    key = decode_key(key)
    validate_key!(key)

    cipher = cipher_for(key)
    cipher.encrypt

    nonce = SecureRandom.random_bytes(NONCE_LENGTH)

    cipher.key = key
    cipher.iv = nonce

    ciphertext = cipher.update(value) + cipher.final

    tag = cipher.auth_tag

    Base64.strict_encode64(nonce + ciphertext + tag)
  end

  # Decrypts a value encrypted with AES-GCM.
  #
  # @param encrypted_value [String] Base64-encoded encrypted value
  # @param key [String] Base64-encoded encryption key (128, 192, or 256 bits)
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

    cipher = cipher_for(key)
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
    unless KEY_LENGTHS.value?(key.bytesize)
      raise InvalidKeyError, "Key must be 128, 192, or 256 bits."
    end
  end

  def self.cipher_for(key)
    OpenSSL::Cipher.new(CIPHERS.fetch(key.bytesize))
  end
end
