# == Schema Information
#
# Table name: tags
#
#  id   :integer          not null, primary key
#  name :string           not null
#
# Indexes
#
#  index_tags_on_name  (name)
#

class Tag < ActiveRecord::Base
end
