class RenameOculusGamePriceWasToPriceRegularJesusChristWhyDidntIGotAWarningAboutIt < ActiveRecord::Migration[5.0]
  def change
    rename_column :oculus_games, :price_was, :price_regular
  end
end
