#= require active_admin/base

$ ->
  $('#index_table_sysreq_tokens').on 'change', '.edit_sysreq_token', (ev)=>
    $(ev.currentTarget).submit()
