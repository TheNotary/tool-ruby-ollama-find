# Ollama::Find

[![Gem Version](https://badge.fury.io/rb/ollama-find.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/ollama-find)
[![Tests](https://github.com/TheNotary/tool-ruby-ollama-find/actions/workflows/test.yml/badge.svg)](https://github.com/TheNotary/tool-ruby-ollama-find/actions/workflows/test.yml)

This is a CLI tool that allows you to quickly generate a path to a `.gguf` file that's been pulled via Ollama.  Also see [tool-go-ollama-find](https://github.com/TheNotary/tool-go-ollama-find) for the go version.


## Installation

```bash
gem install ollama-find
```


## Usage

This guide assumes you've already installed [Ollama](https://ollama.com/download) and it's available on your command line.

```bash
# Pull a model to test with
$  ollama pull llama3

# Get the path to that model
$  ollama-find llama3
~/.ollama/models/blobs/sha256-e5f23238e18e103a64bb1027412f829b4d546f17aed3b42b4401e0dbfa11537c
```
