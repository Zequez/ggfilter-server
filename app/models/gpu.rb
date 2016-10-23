# == Schema Information
#
# Table name: gpus
#
#  id    :integer          not null, primary key
#  name  :string
#  value :integer          not null
#

class Gpu < Scrapers::Benchmarks::Gpu
  before_save do
    vca = VideoCardAnalyzer.new
    self.tokenized_name = vca.tokens(name).select{ |v| v =~ /intel|amd|nvidia/ }.first
  end
end
