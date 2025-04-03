require 'spec_helper'


module Ollama::Find
  describe Ollama::Find do

    it 'has a version number' do
      expect(Ollama::Find::VERSION).not_to be nil
    end

    describe "end-to-end" do

      before :each do
        @model_uri = "llama3"
        @model_tag = "latest"
        @model_home = File.expand_path("./spec/data/ollama/models")

        # Setup the app to look within spec/data/ollama instead of `~/.ollama/models`
        stub_const("Ollama::Find::MODEL_DIR", @model_home)
      end

      it 'it works end-to-end on linuxy platforms' do
        allow(Gem).to receive(:win_platform?).and_return(false)

        output = Ollama::Find.main(@model_uri, @model_tag)

        expect(output).to eq File.join("~", ".ollama", "models", "blobs",
          "sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa")
      end

      it 'it works end-to-end on windows platforms' do
        allow(Gem).to receive(:win_platform?).and_return(true)

        output = Ollama::Find.main(@model_uri, @model_tag)

        expect(output).to eq File.join("#{@model_home}", "blobs",
          "sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa")
      end

    end

  end
end
