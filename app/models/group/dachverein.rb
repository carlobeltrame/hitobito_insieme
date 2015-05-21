# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: groups
#
#  id             :integer          not null, primary key
#  parent_id      :integer
#  lft            :integer
#  rgt            :integer
#  name           :string(255)      not null
#  short_name     :string(31)
#  type           :string(255)      not null
#  email          :string(255)
#  address        :string(1024)
#  zip_code       :integer
#  town           :string(255)
#  country        :string(255)
#  contact_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#  layer_group_id :integer
#  creator_id     :integer
#  updater_id     :integer
#  deleter_id     :integer
#  full_name      :string(255)
#  vid            :integer
#  bsv_number     :integer
#  canton         :string(255)
#
class Group::Dachverein < Group

  self.layer = true
  self.used_attributes += [:full_name, :vid, :bsv_number, :canton]
  self.event_types = [Event, Event::Course, Event::AggregateCourse]
  self.reporting = true

  children Group::DachvereinListe,
           Group::DachvereinGremium,
           Group::DachvereinAbonnemente,
           Group::Regionalverein,
           Group::ExterneOrganisation


  ### ROLES
  #
  class Praesident < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Vorstandsmitglied < ::Role
    self.permissions = [:layer_read]
  end

  class Geschaeftsfuehrung < ::Role
    self.permissions = [:admin, :layer_and_below_full, :contact_data]
  end

  class Sekretariat < ::Role
    self.permissions = [:layer_and_below_full, :contact_data]
  end

  class Adressverwaltung < ::Role
    self.permissions = [:layer_and_below_full, :contact_data]
  end

  class Controlling < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class External < ::Role
    self.permissions = []
    self.visible_from_above = false
    self.kind = :external
  end


  roles Praesident,
        Vorstandsmitglied,
        Geschaeftsfuehrung,
        Sekretariat,
        Adressverwaltung,
        Controlling,
        External

end
