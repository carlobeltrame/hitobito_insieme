# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Tabular::People
  module PeopleFull

    extend ActiveSupport::Concern

    REFERENCE_PERSON_FIELDS = [:reference_person_first_name, :reference_person_last_name,
                               :reference_person_address, :reference_person_zip_code,
                               :reference_person_town, :reference_person_active_membership_roles,
                               :reference_person_additional_information]

    included do
      alias_method_chain :person_attribute_labels, :insieme
      alias_method_chain :person_attributes, :insieme
    end

    def person_attributes_with_insieme
      person_attributes_without_insieme + REFERENCE_PERSON_FIELDS - [:disabled_person_reference]
    end

    def person_attribute_labels_with_insieme
      labels = person_attribute_labels_without_insieme
      REFERENCE_PERSON_FIELDS.each do |attr|
        labels[attr] = ::Person.human_attribute_name(attr)
      end
      labels
    end

  end
end
