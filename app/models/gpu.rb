class Gpu < ActiveRecord::Base
  before_save do
    vca = VideoCardAnalyzer.new
    self.tokenized_name = vca.tokens(name).select{ |v| v =~ /intel|amd|nvidia/ }.first
  end
end
