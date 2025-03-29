require 'spec_helper'


# This file ends in _int because it's an integration test and can use the file
# system and network to assert the applications correctness

module Ollama::Find

  describe Ollama::Find do
    it 'does something useful' do
      result = Ollama::Find.main
      expect(result).to eq("test")
    end
  end

end
