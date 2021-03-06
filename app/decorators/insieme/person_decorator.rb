# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module PersonDecorator
    extend ActiveSupport::Concern

    included do
      alias_method_chain :full_label, :number
    end

    def full_label_with_number
      "#{number} #{full_label_without_number}".strip
    end
  end
end
