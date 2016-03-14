# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecordsController < ReportingBaseController

  TYPES = [TimeRecord::EmployeeTime,
           TimeRecord::VolunteerWithVerificationTime,
           TimeRecord::VolunteerWithoutVerificationTime]

  include Rememberable

  self.remember_params = [:year]

  before_action :entry, except: :index

  def index
    @table = TimeRecord::Table.new(group, year)
  end

  private

  def entry
    @record ||= record_class.where(group_id: group.id, year: year).first_or_initialize
    if @record.is_a?(TimeRecord::EmployeeTime) && @record.employee_pensum.nil?
      @record.build_employee_pensum
    end
    @record
  end

  def record_class
    TYPES.find { |t| t.name.demodulize.underscore == params[:report] } || not_found
  end

  def permitted_params
    fields = TimeRecord.column_names - %w(id year group_id)
    if entry.is_a?(TimeRecord::EmployeeTime)
      fields += [employee_pensum_attributes: [:id, :paragraph_74, :not_paragraph_74]]
    end
    params.require(:time_record).permit(fields)
  end

  def show_path
    time_record_group_path(group, year: year)
  end

end
