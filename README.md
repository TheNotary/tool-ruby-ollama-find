# Ollama::Find

This is a CLI tool that allows you to quickly generate a path to a gguf file that's been pulled via Ollama.


## Installation

```bash
gem install ollama-find
```


## Usage

This guide assumes you've already installed [Ollama](https://ollama.com/download) and it's available on your command line.

```bash
# Pull a model to test with
ollama pull codegpt/replit-code-v1_5-3b

# Get the path to that model
ollama-find codegpt/replit-code-v1_5-3b
```
