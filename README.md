# Rijn

![CI](https://github.com/matthew-moritz/rijn/actions/workflows/main.yml/badge.svg)
![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.4-CC342D?logo=ruby&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

A small Ruby library and CLI for AES-GCM encryption.

## Why "Rijn"

In 1998, two Belgian cryptographers entered a contest run by the US government. Their cipher was called Rijndael. It won. The US government renamed it AES, the Advanced Encryption Standard, and it now protects most of the internet.

Rijn takes its name from Rijndael *(say it "Rain-dahl" or "Rhine-dahl" — Rijndael's creators said either works)*. It does not reimplement the cipher. It uses AES through Ruby's own OpenSSL bindings, tested and fast, and wraps it in an API you can actually enjoy using.

## Get started in 60 seconds

Install the gem:

```bash
gem install rijn
```

Generate a key, encrypt something, decrypt it back:

```console
$ rijn keygen
RQ+WWoEXHK+2c0adDvepnxoyaRsF7cvaG9QUTXKPxFk=

$ rijn encrypt -v "Hello, Rijn!" -k "RQ+WWoEXHK+2c0adDvepnxoyaRsF7cvaG9QUTXKPxFk="
tUFnikYpDHYbpaYeyFzaNHAeut5CAjPLdBhUB8mAacFQAgzyrWpKnA==

$ rijn decrypt -v "tUFnikYpDHYbpaYeyFzaNHAeut5CAjPLdBhUB8mAacFQAgzyrWpKnA==" -k "RQ+WWoEXHK+2c0adDvepnxoyaRsF7cvaG9QUTXKPxFk="
Hello, Rijn!
```

That's the whole library. Three commands, three methods, one cipher.

## What you get

- **AES-GCM at 128, 192, or 256 bits.** You choose the size. Rijn picks a safe default.
- **A fresh IV every time.** You never generate or track it yourself.
- **Tamper detection built in.** A changed or truncated ciphertext fails to decrypt. It never silently returns garbage.
- **A three-method Ruby API.** `generate_key`, `encrypt`, `decrypt`. Nothing else to learn.

## Ruby API

```ruby
require "rijn"

key = Rijn.generate_key          # 256 bits by default
key = Rijn.generate_key(128)     # or 128, or 192

encrypted = Rijn.encrypt("Hello, Rijn!", key)
plaintext = Rijn.decrypt(encrypted, key)
# => "Hello, Rijn!"
```

## CLI

```bash
rijn keygen                                    # generate a key
rijn keygen --bits 128                         # or -b, choose a size

rijn encrypt --value "Hello, Rijn!" --key "<key>"   # or -v / -k
rijn decrypt --value "<encrypted-value>" --key "<key>"

rijn encrypt                                   # skip a flag, get prompted for it
rijn decrypt

rijn version                                   # print the installed version
rijn help                                      # list every command
rijn help encrypt                              # help for one command
```

## Key management

Rijn keys are Base64-encoded strings, 128, 192, or 256 bits. `Rijn.generate_key` defaults to 256.

Always generate keys with `Rijn.generate_key`. Never hand-write or edit key material.

Keep keys secret. Anyone holding a key can decrypt anything encrypted with it. Do not commit keys to source control, and do not hardcode them in application code. Store them in an environment variable, a secrets manager, or another secure configuration system.

## Security

AES-GCM gives you two guarantees:

- **Confidentiality** — no one reads an encrypted value without the key.
- **Integrity** — any change to an encrypted value is caught at decryption time.

Rijn generates a fresh IV for every encryption call and stores it alongside the ciphertext. The IV is not secret; it does not need to be. Decryption fails if the value was tampered with, or if the key is wrong.

Rijn does not manage key storage, rotation, distribution, or access control. That responsibility stays with your application. Rijn is a cipher, not a secrets manager.

## Development

```bash
bundle install              # install dependencies
bundle exec rspec           # run the test suite
gem build rijn.gemspec      # build the gem
gem install ./rijn-0.4.0.gem  # install your local build
./bin/rijn                  # run the CLI from source
```

## Requirements

Ruby 3.4 or newer.

## License

MIT. See `LICENSE.md`.
