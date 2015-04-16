# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CapitalSubstrateController < ReportingBaseController

  helper_method :report

  def edit

  end

  def report
    @report ||= TimeRecord::Report::CapitalSubstrate.new(TimeRecord::Table.new(group, year))
  end

  private

  def entry
    @substrate ||= CapitalSubstrate.where(group_id: group.id, year: year).first_or_initialize
  end

  def permitted_params
    params.require(:time_record).permit(CapitalSubstrate.column_names - %w(id year group_id))
  end

  def show_path
    capital_substrate_group_path(group, year)
  end

end
