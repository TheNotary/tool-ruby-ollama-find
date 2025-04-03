require 'spec_helper'


describe Ollama::Find do
  describe '#lookup_gguf_path' do

    before :each do
      @library_path = File.join("~", ".ollama", "models", "manifests", "registry.ollama.ai", "library")
      allow(Gem).to receive(:win_platform?).and_return(false)

      @valid_manifest = File.read("./spec/data/ollama_manifest.json")
      @key_missing_manifest = File.read("./spec/data/ollama_manifest_missing_keys.json")
      @mangled_manifest = File.read("./spec/data/ollama_manifest_mangled.json")
    end

    it "gets registry path for model in ollama's registry" do
      model_name = "deepseek-r1"

      registry_path, model_name = Ollama::Find.split_registry_from_model_name(model_name)

      expect(registry_path).to eq("registry.ollama.ai/library")
      expect(model_name).to eq("deepseek-r1")
    end

    it "gets registry path for model in external registry" do
      model_name = "hf.co/bartowski/mistralai_Mistral-Small-24B-Base-2501-GGUF"

      registry_path, model_name = Ollama::Find.split_registry_from_model_name(model_name)

      expect(registry_path).to eq("hf.co/bartowski")
      expect(model_name).to eq("mistralai_Mistral-Small-24B-Base-2501-GGUF")
    end

    it "can parse a uri for the codegpt subcatalog" do
      model_name = 'codegpt/replit-code-v1_5-3b'

      registry_path, model_name = Ollama::Find.split_registry_from_model_name(model_name)

      expect(registry_path).to eq("registry.ollama.ai/codegpt")
      expect(model_name).to eq("replit-code-v1_5-3b")
    end

    it "can get_example_tagname" do
      test_file_path = "./spec/data/example_prompt_dsl.rb"
      file_name = Ollama::Find.get_example_tagname(test_file_path)

      expect(file_name).to eq File.basename(test_file_path)
    end

    it "finds gguf paths from ollama" do
      model_name = 'deepseek-r1'
      allow(Ollama::Find).to receive(:file_missing?).and_return(false)
      allow(Ollama::Find).to receive(:read_manifest).and_return(@valid_manifest)

      path = Ollama::Find.lookup_gguf_path(model_name)
      expected_blob_path = File.join("~", ".ollama", "models", "blobs", "sha256-96c415656d377afbff962f6cdb2394ab092ccbcbaab4b82525bc4ca800fe8a49")

      expect(path).to eq(expected_blob_path)
    end

    it "lets you know when it can't find a model's manifest from ollama" do
      model_name = 'sea-biscuit'
      expected_error = "Error: Manifest for sea-biscuit could not be found.  Checked #{File.join(@library_path, model_name, "latest")}"
      allow(Ollama::Find).to receive(:file_missing?).and_return(true)
      allow(Ollama::Find).to receive(:read_manifest).and_return(@mangled_manifest)

      path = Ollama::Find.lookup_gguf_path(model_name)

      expect(path).to include(expected_error)
    end

    it "lets you know when it can't parse a mangled manifest from ollama" do
      model_name = 'mangled-model'
      expected_error = "Error: Unable to parse manifest at #{File.join(@library_path, model_name, "latest")}"
      allow(Ollama::Find).to receive(:file_missing?).and_return(false)
      allow(Ollama::Find).to receive(:read_manifest).and_return(@mangled_manifest)

      path = Ollama::Find.lookup_gguf_path(model_name)

      expect(path).to eq(expected_error)
    end

    it "lets you know when it can't navigate the schema of ollama's manifest" do
      model_name = 'mangled-model'
      expected_error = "Error: Unable to extract digest from manifest at #{File.join(@library_path, model_name, "latest")} for model_name mangled-model"
      allow(Ollama::Find).to receive(:file_missing?).and_return(false)
      allow(Ollama::Find).to receive(:read_manifest).and_return(@key_missing_manifest)

      path = Ollama::Find.lookup_gguf_path(model_name)

      expect(path).to eq(expected_error)
    end

    it "suggests a tag name if it looks like you left that out" do
      model_name = 'mangled-model'
      suggested_tag = "24b-instruct-2501-q4_K_M"
      expected_errorp1 = "Error: Manifest for mangled-model could not be found."
      expected_errorp2 = "If you meant to specify a version, try:\n  $  rspec find mangled-model 24b-instruct-2501-q4_K_M"
      allow(Ollama::Find).to receive(:file_missing?).and_return(true)
      allow(Ollama::Find).to receive(:it_looks_like_you_needed_to_supply_a_tag_name?).and_return(true)
      allow(Ollama::Find).to receive(:get_example_tagname).and_return(suggested_tag)
      allow(Ollama::Find).to receive(:read_manifest).and_return(@key_missing_manifest)

      path = Ollama::Find.lookup_gguf_path(model_name)

      expect(path).to include(expected_errorp1)
      expect(path).to include(expected_errorp2)
    end

  end
end
