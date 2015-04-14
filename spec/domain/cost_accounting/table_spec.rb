# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::Table do

  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, 2014) }

  context '#value_of' do
    context 'is lazy initialized' do

      CostAccounting::Table::REPORTS.each do |key, report|
        CostAccounting::Report::Base::FIELDS.each do |field|
          context "for #{key}-#{field}" do
            it 'without records' do
              expect(table.value_of(key, field).to_d).to eq(0.0)
            end
          end
        end
      end

    end
  end
end
