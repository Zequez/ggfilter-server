# == Schema Information
#
# Table name: gpus
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name           :string
#  value          :integer
#  tokenized_name :string
#

class Gpu < ActiveRecord::Base
  before_save do
    vca = VideoCardAnalyzer.new
    self.tokenized_name = vca.tokens(name).select{ |v| v =~ /intel|amd|nvidia/ }.first
  end
end
