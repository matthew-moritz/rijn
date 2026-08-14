module Rijn
  # Raised when an encryption key is invalid.
  class InvalidKeyError < StandardError
  end

  # Raised when an encrypted value cannot be authenticated during decryption.
  class AuthenticationError < StandardError
  end
end