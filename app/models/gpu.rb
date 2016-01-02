class Gpu < ActiveRecord::Base
  before_save do
    vca = VideoCardAnalyzer.new
    self.tokenized_name = vca.tokens(name).first
  end
end
