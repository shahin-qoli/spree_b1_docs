Deface::Override.new(
    virtual_path: 'spree/admin/shared/_order_tabs',
    name: 'Display the sync with b1',
    insert_after: '[data-hook="admin_order_tabs_state_changes"]',
    text: <<-HTML
  
            <li class="nav-item" >
              <%= link_to_with_icon 'calendar3.svg',
                "SYNC",
                spree.admin_order_state_changes_url(@order),
                class: "nav-link" %>
            </li>
     
     HTML
)
