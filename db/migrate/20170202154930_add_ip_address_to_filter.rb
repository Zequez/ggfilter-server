class AddIpAddressToFilter < ActiveRecord::Migration[5.0]
  def change
    add_column :filters, :ip_address, :string
  end
end
