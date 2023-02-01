# frozen_string_literal: true

ActiveAdmin.register VolunteeringPosition do
  belongs_to :event

  permit_params :event_id, :rank, :role, :number

  config.filters = false
  config.sort_order = 'rank'

  breadcrumb do
    [
      link_to('главная', admin_root_path),
      link_to('волонтёрские позиции', admin_event_volunteering_positions_path(event))
    ]
  end

  controller do
    def update
      update! do |format|
        if resource.valid?
          format.html { redirect_to collection_path, notice: t('active_admin.volunteering_position.successful_updated') }
        end
      end
    end

    def create
      create! do |format|
        if resource.valid?
          format.html { redirect_to collection_path, notice: t('active_admin.volunteering_position.successful_created') }
        end
      end
    end
  end

  index download_links: false, title: -> { "Волонтёрские позиции #{@event.name}" } do
    selectable_column
    column :rank
    column :number
    column(:role) { |v| human_volunteer_role v.role }
    actions
  end

  form do |f|
    f.inputs do
      f.input :rank
      f.input :number
      f.input :role
    end
    f.actions
  end
end