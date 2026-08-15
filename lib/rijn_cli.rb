require "rijn"
require "thor"
require "tty-prompt"

PROMPT = TTY::Prompt.new


class RijnCLI < Thor
  def self.exit_on_failure?
    true
  end

  desc "version", "Display the version."
  def version
    puts Rijn::VERSION
  end

  desc "decrypt", "Decrypt an AES-GCM value."
  option :value, aliases: "-v"
  option :key, aliases: "-k"
  def decrypt
    value = options[:value] || PROMPT.ask("What's the value?")
    key = options[:key] || PROMPT.mask("What's the key?")

    puts Rijn.decrypt(value, key)
  rescue Rijn::InvalidKeyError, Rijn::AuthenticationError => e
    $stderr.puts "Error: #{e.message}"
    exit 1
  end

  desc "encrypt", "Encrypt a value using AES-GCM."
  option :value, aliases: "-v"
  option :key, aliases: "-k"
  def encrypt
    value = options[:value] || PROMPT.ask("What's the value?")
    key = options[:key] || PROMPT.mask("What's the key?")

    puts Rijn.encrypt(value, key)
  rescue Rijn::InvalidKeyError, Rijn::AuthenticationError => e
    $stderr.puts "Error: #{e.message}"
    exit 1
  end

  desc "keygen", "Generate a new encryption key."
  option :bits, aliases: "-b", type: :numeric, default: 256, desc: "The number of bits for the key (128, 192, or 256)."
  def keygen
    puts Rijn.generate_key(options[:bits])
  rescue Rijn::InvalidKeyError => e
    $stderr.puts "Error: #{e.message}"
    exit 1
  end
end
