# == Schema Information
#
# Table name: gpus
#
#  id             :integer          not null, primary key
#  name           :string
#  value          :integer          not null
#  tokenized_name :string
#
# Indexes
#
#  index_gpus_on_tokenized_name  (tokenized_name)
#

class Gpu < ActiveRecord::Base
  before_save do
    vca = VideoCardAnalyzer.new
    self.tokenized_name = vca.tokens(name).select{ |v| v =~ /intel|amd|nvidia/ }.first
  end

  def self.get_tokens_hash
    tokens = {}

    all.pluck(:tokenized_name, :value).each do |tv|
      t, v = tv
      if tokens[t]
        tokens[t] = Array(tokens[t]) + [v]
      else
        tokens[t] = v
      end
    end

    tokens.each_pair do |t, vv|
      tokens[t] = vv.reduce(&:+).to_f / vv.size if tokens[t].is_a? Array
    end

    tokens
  end

  def self.from_scraper!(attrs)
    gpu = find_by_name(attrs[:name]) || new
    gpu.name = attrs[:name]
    gpu.value = attrs[:value]
    gpu.save!
    gpu
  end
end
