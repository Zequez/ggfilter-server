# == Schema Information
#
# Table name: filters
#
#  id            :integer          not null, primary key
#  sid           :string           not null
#  name          :string
#  user_slug     :string
#  user_id       :integer
#  filter        :text             default("{}"), not null
#  visits        :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  official_slug :string
#
# Indexes
#
#  index_filters_on_official_slug  (official_slug) UNIQUE
#  index_filters_on_sid            (sid) UNIQUE
#  index_filters_on_user_id        (user_id)
#  index_filters_on_user_slug      (user_slug)
#

class Filter < ActiveRecord::Base
  belongs_to :user

  nilify_blanks only: [:name, :user_slug, :official_slug], before: :validation

  validates :name,
    allow_nil: true,
    allow_blank: false,
    length: { maximum: 140 }
  validates :user_slug,
    allow_nil: true,
    allow_blank: false,
    uniqueness: { scope: :user_id },
    format: { with: /\A[a-zA-Z0-9\-]+\Z/ },
    length: { maximum: 50 }
  validates :user_id,
    presence: true,
    if: :user_slug
  validates :official_slug,
    allow_nil: true,
    allow_blank: false,
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9\-]+\Z/ },
    length: { maximum: 50 }
  validate :validates_filter_json_object

  def validates_filter_json_object
    begin
      JSON.parse(self.filter)
    rescue JSON::ParserError
      errors.add(:filter, 'Should be a valid filter object')
    end
  end

  before_validation :generate_sid, if: :new_record?

  def generate_sid
    self.sid = SecureRandom.urlsafe_base64(6, false)
    generate_sid if Filter.find_by_sid(self.sid)
  end
end
