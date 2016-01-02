ActiveAdmin.register SysreqToken do
  include ActionView::Helpers::FormHelper
  config.per_page = 9999
  config.batch_actions = false
  config.sort_order = 'value_desc'
  permit_params :value, :linked_to, :year_analysis

  index do
    column :token_type
    column :name do |t|
      link_to t.name, [:admin, t]
    end
    column :value, sortable: :value do |t|
      form_for(t, url: admin_sysreq_token_path(t, format: :json), remote: true) do |f|
        f.text_field :value
        f.text_field :linked_to
        f.check_box :year_analysis
        f.label :year_analysis, 'Y.A.'
      end
    end
    column :games_count
    column :year_analysis
    actions
  end

  show do |t|
    h3 "#{t.token_type} - #{t.name}"

    attributes_table do
      row :token_type
      row :name
      row :value
      row :games_count
      row :year_analysis
      row :games do
        t.games.map do |g|
          # a = link_to g.name, [:admin, g]
          content_tag :div, "#{g.steam_id} - #{g.name} - #{g.sysreq(:min, :gpu)} - #{g.sysreq(:rec, :gpu)}"
        end.join('').html_safe
      end
      row :gpu do
        Gpu.where(tokenized_name: t.name).map do |gpu|
          content_tag :div, "#{gpu.name} - #{gpu.value}"
        end.join('').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    inputs :value, :year_analysis
    actions
  end
end
