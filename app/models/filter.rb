# == Schema Information
#
# Table name: filters
#
#  id               :integer          not null, primary key
#  sid              :string           not null
#  name             :string
#  name_slug        :string
#  user_id          :integer
#  visits           :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  global_slug      :string
#  sorting          :text             default({}), not null
#  secret           :string
#  front_page       :integer
#  controls_list    :text             default([]), not null
#  controls_hl_mode :text             default([]), not null
#  controls_params  :text             default({}), not null
#  columns_list     :text             default([]), not null
#  columns_params   :text             default({}), not null
#  global_config    :text             default({}), not null
#  ip_address       :string
#
# Indexes
#
#  index_filters_on_global_slug  (global_slug) UNIQUE
#  index_filters_on_name_slug    (name_slug)
#  index_filters_on_sid          (sid) UNIQUE
#  index_filters_on_user_id      (user_id)
#

class Filter < ActiveRecord::Base
  belongs_to :user

  serialize :controls_list, JSON
  serialize :controls_hl_mode, JSON
  serialize :controls_params, JSON
  serialize :columns_list, JSON
  serialize :columns_params, JSON
  serialize :sorting, JSON
  serialize :global_config, JSON

  nilify_blanks only: [:name, :name_slug, :global_slug], before: :validation

  validates :name,
    allow_nil: true,
    allow_blank: false,
    length: { maximum: 140 }
  validates :name_slug,
    allow_nil: true,
    allow_blank: false,
    uniqueness: false,
    length: { maximum: 50 }
  validates :global_slug,
    allow_nil: true,
    allow_blank: false,
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9\-]+\Z/ },
    length: { maximum: 50 }
  validates :ip_address, presence: true

  validate :ip_address_flooding

  scope :front_page, ->{ where.not(front_page: nil).order('front_page ASC') }

  def ip_address_flooding
    count = Filter
      .where('ip_address = ? AND created_at > ?', ip_address, 1.hour.ago)
      .count

    if count >= 30
      errors.add(
        :ip_address,
        :too_many_posts,
        message: "You're doing this too much, please wait"
      )
    end
  end

  validate :validates_serialized_objects

  def validates_serialized_objects
    [:controls_list, :columns_list, :controls_hl_mode].each do |attr|
      val = send attr
      unless val.kind_of? Array
        errors.add(attr, message: 'Must be an array')
      end
    end

    [:controls_params,
      :columns_params, :sorting, :global_config].each do |attr|
      val = send attr
      unless val.kind_of? Hash
        errors.add(attr, message: 'Must be a hash')
      end
    end


    # begin
    #   JSON.parse(self.filter)
    # rescue JSON::ParserError
    #   errors.add(:filter, 'Should be a valid filter object')
    # end
  end

  before_validation :generate_sid, if: :new_record?

  def generate_sid
    self.sid = SecureRandom.urlsafe_base64(6, false) # 6 * 4/3
    generate_sid if Filter.find_by_sid(self.sid)
  end

  before_validation :generate_secret, if: :new_record?

  def generate_secret
    self.secret = SecureRandom.urlsafe_base64(37, false) # 37 * 4/3
    generate_sid if Filter.find_by_sid(self.sid)
  end

  before_create do
    if name
      self.name_slug = name.parameterize.strip[0..49]
    end
  end

  def to_json_create
    to_json except: [:id]
  end

  def to_json_normal
    to_json except: [:id, :secret]
  end
end
