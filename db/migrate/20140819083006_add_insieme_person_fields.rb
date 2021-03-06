# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddInsiemePersonFields < ActiveRecord::Migration
  def change
    add_column :people, :salutation, :string
    add_column :people, :canton, :string
    add_column :people, :language, :string
    add_column :people, :correspondence_language, :string
    add_column :people, :number, :string
  end
end
