module Scrapers::SteamList::GameExtension
  extend ActiveSupport::Concern

  included do
    flag_column :platforms, {
      win:   0b001,
      mac:   0b010,
      linux: 0b100
    }
  end
end
