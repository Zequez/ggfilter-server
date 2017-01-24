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
  def self.find_or_create_by_name(name)
    if ( tag = where('lower(name) = ?', name.downcase).first )
      tag
    else
      create name: name
    end
  end
end
