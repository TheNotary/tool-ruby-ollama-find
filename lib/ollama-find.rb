require "ollama-find/version"
require "ollama-find/lookup_gguf_path"


module Ollama
  module Find

    def self.main(model_uri, model_tag = nil)
      lookup_gguf_path(model_uri, model_tag)
    end

    def self.help
      msg = <<-EOF.strip
ollama::find
  A CLI tool that allows you to quickly generate a path to a gguf file that's
  been pulled via Ollama.

Usage:
  $  ollama-find llama3
  ~/.ollama/models/blobs/sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa
  EOF
    end

  end
end
