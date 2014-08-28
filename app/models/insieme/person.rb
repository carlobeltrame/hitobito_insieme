# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Person
  extend ActiveSupport::Concern

  def canton_value
    value_from_i18n(:canton)
  end

  def language_value
    value_from_i18n(:language)
  end

  def correspondence_language_value
    value_from_i18n(:correspondence_language)
  end

  private

  def value_from_i18n(key)
    value = send(key)

    if value.present?
      I18n.t("activerecord.attributes.person.#{key.to_s.pluralize}.#{value}")
    end
  end
end