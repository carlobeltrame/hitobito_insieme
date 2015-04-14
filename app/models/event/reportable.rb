# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Event::Reportable

  extend ActiveSupport::Concern

  LEISTUNGSKATEGORIEN = %w(bk tk sk)

  included do
    self.used_attributes += [:leistungskategorie]

    has_one :course_record, foreign_key: :event_id, dependent: :destroy, inverse_of: :event
    accepts_nested_attributes_for :course_record

    attr_readonly :leistungskategorie

    validates :leistungskategorie, inclusion: LEISTUNGSKATEGORIEN
  end

  ### INSTANCE METHODS

  def years
    dates.
      map { |date| [date.start_at, date.finish_at] }.
      flatten.
      compact.
      map(&:year).
      uniq.
      sort
  end

  def reportable?
    true
  end

  module ClassMethods
    def available_leistungskategorien
      LEISTUNGSKATEGORIEN.map do |period|
        [period, I18n.t("activerecord.attributes.event/course.leistungskategorien.#{period}")]
      end
    end
  end
end