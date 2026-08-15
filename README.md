# Rijn

A small Ruby library and CLI for AES-GCM encryption. Supports 128-bit, 192-bit, and 256-bit keys.

The name "Rijn" comes from Rijndael, the cipher AES is built from. The library itself uses AES, via Ruby's OpenSSL bindings — not a custom Rijndael implementation.

## Installation

Add Rijn to your application's `Gemfile`:

```ruby
gem "rijn"
```

Then run:
```ruby
bundle install
```

Or install the gem directly:
```ruby
gem install rijn
```

## Ruby API

Require Rijn:
```ruby
require "rijn"
```

Generate an encryption key:
```ruby
key = Rijn.generate_key
```

By default, this makes a 256-bit key. Pass `128`, `192`, or `256` to choose a size:
```ruby
key = Rijn.generate_key(128)
```

Encrypt a value:
```ruby
encrypted = Rijn.encrypt("Hello, Rijn!", key)
```

Decrypt it:
```ruby
plaintext = Rijn.decrypt(encrypted, key)
```

The decrypted value will be:
```ruby
"Hello, Rijn!"
```

## CLI

Generate an encryption key:

```bash
rijn keygen
```

Use `--bits` (or `-b`) to set the key size:
```bash
rijn keygen --bits 128
```

Encrypt a value:
```bash
rijn encrypt --value "Hello, Rijn!" --key "<key>"
```

Or use the short options:
```bash
rijn encrypt -v "Hello, Rijn!" -k "<key>"
```

Decrypt an encrypted value:
```bash
rijn decrypt --value "<encrypted-value>" --key "<key>"
```

Or use the interactive prompts:
```bash
rijn encrypt
rijn decrypt
```

Display the version:
```bash
rijn version
```

Display available commands:
```bash
rijn help
```

Get help for a specific command:
```bash
rijn help encrypt
rijn help decrypt
```

## Key Management

Rijn supports 128-bit, 192-bit, and 256-bit encryption keys, represented as Base64-encoded strings. `Rijn.generate_key` uses 256 bits by default.

Generate a new key with:

```bash
rijn keygen
```

Keep encryption keys secret. Anyone with the key can decrypt values encrypted with it.

Do not commit encryption keys to source control or include them directly in application source code.

For applications, store keys in an appropriate secret-management system such as environment variables, a secrets manager, or another secure configuration mechanism.

Keys should be generated using `Rijn.generate_key` rather than manually creating or modifying key material.

## Security

Rijn uses AES-GCM for authenticated encryption, at 128, 192, or 256 bits.

AES-GCM provides both:

- Confidentiality: encrypted values cannot be read without the encryption key.
- Integrity and authenticity: modifications to an encrypted value are detected during decryption.

Rijn generates a fresh initialization vector (IV) for each encryption operation. The IV does not need to be kept secret and is stored as part of the encrypted value.

Decryption fails if the encrypted value has been modified or the wrong key is supplied.

Rijn does not provide key storage, key rotation, key distribution, or access control. Applications using Rijn are responsible for managing encryption keys securely.

Rijn should not be used as a substitute for a dedicated secrets-management system.

## Development

Clone the repository and install the dependencies:

```rijn
bundle install
```

Run the test suite:
```bash
bundle exec rspec
```

Build the gem:
```bash
gem build rijn.gemspec
```

Install the locally built gem:
```bash
gem install ./rijn-0.1.0.gem
```

Run the CLI directly from the source tree:
```bash
./bin/rijn
```

## Requirements

- Ruby 3.4 or newer

## License

Rijn is released under the MIT License. See `LICENSE.md` for details.
