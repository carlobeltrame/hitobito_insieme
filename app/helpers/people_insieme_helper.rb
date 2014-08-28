# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module PeopleInsiemeHelper

  def format_person_canton(person)
    person.canton_value
  end

  def possible_person_cantons
    candidates_from_i18n(:cantons)
  end

  def format_person_language(person)
    person.language_value
  end

  def possible_person_languages
    candidates_from_i18n(:languages)
  end

  def format_person_correspondence_language(person)
    person.correspondence_language_value
  end

  def possible_person_correspondence_languages
    candidates_from_i18n(:correspondence_languages)
  end

  private

  def candidates_from_i18n(collection_attr)
    t("activerecord.attributes.person.#{collection_attr}").map do |key, value|
      Struct.new(:id, :to_s).new(key, value)
    end
  end
end