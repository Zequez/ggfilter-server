# == Schema Information
#
# Table name: named_filters
#
#  id         :integer          not null, primary key
#  name       :string
#  columns    :string
#  filters    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NamedFilter < ActiveRecord::Base
end
