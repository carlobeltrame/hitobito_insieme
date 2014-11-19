# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Cantons

  module_function

  SHORT_NAMES = [:ag, :ai, :ar, :be, :bl, :bs, :fr, :ge, :gl, :gr, :ju, :lu,
                 :ne, :nw, :ow, :sg, :sh, :so, :sz, :tg, :ti, :ur, :vd, :vs,
                 :zg, :zh, :other].freeze

  def short_names
    SHORT_NAMES
  end

  def short_name_strings
    short_names.collect(&:to_s)
  end

  def full_name(shortname)
    if shortname.present?
      I18n.t("activerecord.attributes.cantons.#{shortname.to_s.downcase}")
    end
  end

  def labels
    short_names.each_with_object({}) do |short, labels|
      labels[short] = full_name(short)
    end
  end

end
