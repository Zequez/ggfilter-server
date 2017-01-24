# == Schema Information
#
# Table name: oculus_games
#
#  id                :integer          not null, primary key
#  oculus_id         :integer          not null
#  name              :string           not null
#  price             :integer          not null
#  price_regular     :integer
#  summary           :text
#  version           :string
#  category          :string
#  genres            :string           default([]), not null
#  languages         :string           default([]), not null
#  age_rating        :string
#  developer         :string
#  publisher         :string
#  vr_mode           :integer          default(0), not null
#  vr_tracking       :integer          default(0), not null
#  vr_controllers    :integer          default(0), not null
#  players           :integer          default(0), not null
#  comfort           :integer          default(0), not null
#  internet          :integer          default(0), not null
#  win10_required    :boolean          default(FALSE), not null
#  sysreq_hdd        :string
#  sysreq_cpu        :string
#  sysreq_gpu        :string
#  sysreq_ram        :string
#  website_url       :string
#  rating_1          :integer          default(0), not null
#  rating_2          :integer          default(0), not null
#  rating_3          :integer          default(0), not null
#  rating_4          :integer          default(0), not null
#  rating_5          :integer          default(0), not null
#  thumbnail         :string
#  screenshots       :text             default([]), not null
#  trailer_video     :string
#  trailer_thumbnail :string
#  released_at       :datetime
#
# Indexes
#
#  index_oculus_games_on_name       (name) UNIQUE
#  index_oculus_games_on_oculus_id  (oculus_id) UNIQUE
#

require 'json-schema'
require 'simple_flaggable_column'

class OculusGame < ApplicationRecord
  include SimpleFlaggableColumn

  flag_column :vr_mode, {
    "SITTING" =>    0b1,
    "STANDING" =>   0b10,
    "ROOM_SCALE" => 0b010,
  }

  flag_column :vr_tracking, {
    "DEGREE_360" =>   0b1,
    "FRONT_FACING" => 0b10,
  }

  flag_column :vr_controllers, {
    "OCULUS_TOUCH" =>   0b1,
    "OCULUS_REMOTE" =>  0b10,
    "GAMEPAD" =>        0b100,
    "KEYBOARD_MOUSE" => 0b1000,
    "FLIGHT_STICK" =>   0b10000,
    "RACING_WHEEL" =>   0b100000,
    "HYDRA" =>          0b1000000,
  }

  flag_column :players, {
    "SINGLE_USER" => 0b1,
    "MULTI_USER" =>  0b10,
    "CO_OP" =>       0b100,
  }

  serialize :genres, JSON
  serialize :languages, JSON
  serialize :screenshots, JSON

  def self.validation_errors
    JSON::Validator.fully_validate(Scrapers::Oculus::SCHEMA, attributes)
  end

  def self.from_scraper!(attributes)
    JSON::Validator.validate!(Scrapers::Oculus::SCHEMA, attributes)
    OculusGame.new attributes
  end

  # after_create :find_game_or_create_one

  def propagate_to_game
    game = Game.find_or_build_from_name name
    game.oculus_game = self
    game.compute_all
    game.save!
    game
  end

  def ratings
    [rating_1, rating_2, rating_3, rating_4, rating_5]
  end
end
