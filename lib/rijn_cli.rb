require "rijn"
require "thor"
require "tty-prompt"

PROMPT = TTY::Prompt.new
PASTEL = Pastel.new

class RijnCLI < Thor
  def self.exit_on_failure?
    true
  end

  desc "version", "Display the version."
  def version
    write_info(Rijn::VERSION)
  end

  desc "decrypt", "Decrypt an AES-GCM value."
  option :value, aliases: "-v"
  option :key, aliases: "-k"
  def decrypt
    value = options[:value] || prompt_ask("What's the value?")
    key = options[:key] || prompt_mask("What's the key?")

    write_info(Rijn.decrypt(value, key))
  rescue Rijn::InvalidKeyError, Rijn::AuthenticationError => e
    write_error(e.message)
    exit 1
  end

  desc "encrypt", "Encrypt a value using AES-GCM."
  option :value, aliases: "-v"
  option :key, aliases: "-k"
  def encrypt
    value = options[:value] || prompt_ask("What's the value?")
    key = options[:key] || prompt_mask("What's the key?")

    write_info(Rijn.encrypt(value, key))
  rescue Rijn::InvalidKeyError, Rijn::AuthenticationError => e
    write_error(e.message)
    exit 1
  end

  desc "keygen", "Generate a new encryption key."
  option :bits, aliases: "-b", type: :numeric, default: 256, desc: "The number of bits for the key (128, 192, or 256)."
  def keygen
    write_info(Rijn.generate_key(options[:bits]))
  rescue Rijn::InvalidKeyError => e
    write_error(e.message)
    exit 1
  end

  private

  def prompt_ask(message)
    PROMPT.ask(PASTEL.cyan(message))
  end

  def prompt_mask(message)
    PROMPT.mask(PASTEL.cyan(message))
  end

  def write_info(message)
    puts message
  end

  def write_error(message)
    $stderr.puts PASTEL.red("Error: #{message}")
  end
end
