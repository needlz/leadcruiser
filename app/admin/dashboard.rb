ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    span class: "action_item" do
      link_to 'Restart server', { controller: '/admins', action: 'restart_server' }, method: :post
    end
  end

end
