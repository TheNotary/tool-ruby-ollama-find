require 'yaml'
require 'json'


module Ollama
  module Find
    CLEAN_MODEL_DIR = "~/.ollama/models"
    MODEL_DIR = File.expand_path(CLEAN_MODEL_DIR)

    # Retrieves the file path to the GGUF model based on a given model name and optional tag.
    #
    # @param model_uri [String] Just the name of the model (e.g. "mymodel") or a full
    #                           uri including registry and model (e.g. "registry.com/user/mymodel").
    # @param model_tag [String] (Optional) The model version/tag. Defaults to "latest".
    # @return [String, nil] The absolute path to the GGUF model file, or `nil` if the model digest
    #                       is not found.
    #
    # @raise [RuntimeError] If the manifest file does not exist.
    def self.lookup_gguf_path(model_uri, model_tag = nil)
      model_tag = "latest" if model_tag.nil?
      registry_path, model_name = split_registry_from_model_name(model_uri)
      path_to_manifest = File.join(MODEL_DIR, "manifests", registry_path, model_name, model_tag)

      if file_missing?(path_to_manifest)
        msg = "Error: Manifest for #{model_name} could not be found.  Checked #{clean_path(path_to_manifest)}"
        if it_looks_like_you_needed_to_supply_a_tag_name?(path_to_manifest)
          tagged_file = get_example_tagname(path_to_manifest)
          msg += ".\n\nIf you meant to specify a version, try:\n  $  #{command_name} #{model_uri} #{tagged_file}"
        end
        return msg
      end

      begin
        manifest = JSON.parse(read_manifest(path_to_manifest))
      rescue JSON::ParserError
        return "Error: Unable to parse manifest at #{clean_path(path_to_manifest)}"
      end

      begin
        digest = extract_model_digest(manifest)
      rescue
        return "Error: Unable to extract digest from manifest at #{clean_path(path_to_manifest)} for model_name #{model_name}"
      end

      File.join(CLEAN_MODEL_DIR, "blobs", digest)
    end

    def self.command_name
      "#{File.basename($0)} find"
    end

    def self.get_example_tagname(path)
      dirpath = File.dirname(path)
      File.basename(Dir.glob("#{dirpath}/*").first)
    end

    def self.it_looks_like_you_needed_to_supply_a_tag_name?(path)
      Dir.exist?(File.dirname(path))
    end

    def self.clean_path(absolute_path)
      absolute_path.sub(MODEL_DIR, CLEAN_MODEL_DIR)
    end

    def self.extract_model_digest(manifest)
      manifest["layers"].select do |obj|
        obj["mediaType"] == "application/vnd.ollama.image.model"
      end.first["digest"].sub(':', '-')
    end

    def self.split_registry_from_model_name(model_name)
      if model_name.split("/").first.include?(".")
        return get_private_registry_model_name_and_registry(model_name)
      end
      if model_name.split("/").count > 1
        subcatalog = model_name.split("/").first
        return ["registry.ollama.ai/#{subcatalog}", model_name.sub("#{subcatalog}/", "")]
      end
      ["registry.ollama.ai/library", model_name]
    end

    def self.get_private_registry_model_name_and_registry(model_name)
      folder_array = model_name.split("/")
      model_name = folder_array.pop
      registry_path = folder_array.join("/")
      [registry_path, model_name]
    end

    def self.read_manifest(path_to_manifest)
      File.read(File.expand_path(path_to_manifest))
    end

    def self.file_missing?(path)
      !File.exist?(path)
    end

  end
end
