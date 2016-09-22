# == Schema Information
#
# Table name: filters
#
#  id         :integer          not null, primary key
#  sid        :string           not null
#  name       :string
#  slug       :string
#  user_id    :integer
#  official   :boolean          default(FALSE), not null
#  filter     :text             default("{}"), not null
#  visits     :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_filters_on_sid      (sid)
#  index_filters_on_slug     (slug)
#  index_filters_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_f53aed9bb6  (user_id => users.id)
#

class Filter < ActiveRecord::Base
  belongs_to :user

  validate :validates_filter_json_object

  def validates_filter_json_object
    begin
      JSON.parse(self.filter)
    rescue JSON::ParserError
      errors.add(:filter, 'Should be a valid filter object')
    end
  end

  before_validation :generate_sid

  def generate_sid
    self.sid = SecureRandom.urlsafe_base64(6, false)
    generate_sid if Filter.find_by_sid(self.sid)
  end
end
