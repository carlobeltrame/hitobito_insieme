# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe EventsController do


  before { sign_in(people(:top_leader)) }

  context 'GET#new' do
    let(:group) { groups(:dachverein) }

    it 'sets defaults for course record' do
      get :new, group_id: group.id, event: { type: 'Event::Course' }

      expect(assigns(:event).course_record.kursart).to eq 'weiterbildung'
      expect(assigns(:event).course_record.inputkriterien).to eq 'a'
      expect(assigns(:event).course_record).to be_subventioniert
    end
  end

  context 'POST#create' do
    let(:group) { groups(:dachverein) }
    let(:date)  {{ label: 'foo', start_at_date: Date.today, finish_at_date: Date.today }}

    let(:course_attrs) { { group_ids: [group.id],
                           name: 'foo',
                           dates_attributes: [date],
                           type: 'Event::Course' } }

    it 'creates new course with leistungskategorie' do
      expect { create('bk') }.to change { Event::Course.count }.by(1)
      expect(assigns(:event).leistungskategorie).to eq 'bk'
    end

    it 'validates leistungskategorie presence' do
      expect { create }.not_to change { Event::Course.count }
      expect(assigns(:event)).to have(1).error_on(:leistungskategorie)
    end

    it 'validates leistungskategorie value' do
      expect { create('test') }.not_to change { Event::Course.count }
      expect(assigns(:event)).to have(1).error_on(:leistungskategorie)
    end

    context 'reporting frozen' do
      before { GlobalValue.first.update!(reporting_frozen_until_year: 2015) }
      after { GlobalValue.clear_cache }

      let(:date) {{ label: 'foo', start_at_date: Date.new(2015, 3, 1), finish_at_date: Date.new(2015, 3, 8) }}

      it 'cannot create course in frozen year' do
        expect { create('bk') }.not_to change { Event::Course.count }
        expect(assigns(:event)).to have(1).error_on(:'course_record.year')
      end
    end

    context 'nested course_record fields' do
      it 'creates course record attribute' do
        expect { create('bk') }.to change { Event::CourseRecord.count }.by(1)
      end

      it 'validates course record attributes' do
        expect { create('bk', { kursart: 'foo' }) }.not_to change { Event::CourseRecord.count }
        expect(assigns(:event).errors.keys).to eq [:"course_record.kursart"] # how to do this with error_on?
      end
    end

    context 'for aggregate course' do
      let(:course_attrs) { { group_ids: [group.id],
                             name: 'foo',
                             year: Date.today.year,
                             type: 'Event::AggregateCourse' } }

      it 'assigns course record attributes' do
        expect { create('bk', { anzahl_kurse: 12 }) }.to change { Event::CourseRecord.count }
        expect(assigns(:event).course_record.anzahl_kurse).to eq 12
      end
    end

    def create(leistungskategorie = nil, course_record_attributes = {})
      post :create, group_id: group.id, event: course_attrs.merge(leistungskategorie: leistungskategorie,
                                                                  course_record_attributes: course_record_attributes)
    end
  end

  context 'PUT#update' do
    let(:event) { events(:top_course) }

    it 'ignores changes to leistungskategorie' do
      put :update, group_id: groups(:be).id, id: event.id,
        event: { leistungskategorie: 'sk' }

      expect(event.reload.leistungskategorie).to eq 'bk'
    end

    context 'reporting frozen' do
      before { GlobalValue.first.update!(reporting_frozen_until_year: 2015) }
      after { GlobalValue.clear_cache }

      it 'cannot update course in frozen year' do
        expect do
          put :update,
            group_id: groups(:be).id,
            id: event.id,
            event: { name: 'other' }
        end.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'nested course_record fields' do
      it 'updates course record attribute' do
        update(inputkriterien: 'b')
        expect(assigns(:event).course_record.inputkriterien).to eq 'b'
      end

      it 'validates course record attributes' do
        update(kursart: 'foo')
        expect(assigns(:event).errors.keys).to eq [:"course_record.kursart"]
      end

      it 'only updates, does not change missing fields' do
        event.course_record.update_attribute(:kursdauer, 1)
        update(id: event.course_record.id, inputkriterien: 'b')

        expect(event.reload.course_record.kursdauer).to eq 1
      end

      it 'raises not_found when trying to update different course_record' do
        other = Fabricate(:course, groups: [groups(:be)], leistungskategorie: 'sk', course_record_attributes: { kursdauer: 10 } )
        expect { update(id: other.course_record.id, kursdauer: 1) }.to raise_error ActiveRecord::RecordNotFound
      end

      def update(course_record_attributes = {})
        put :update, group_id: event.groups.first.id, id: event.id, event: { course_record_attributes: course_record_attributes }
      end
    end
  end

  context 'GET#index as XLSX' do

    context 'dachverein' do
      before do
        sign_in(people(:top_leader))
        c = Fabricate(:course, groups: [groups(:dachverein)], kind: Event::Kind.first,
                      leistungskategorie: 'bk')
        Fabricate(:event_date, event: c, start_at: Date.new(2012, 3, 5))
      end
      let(:group) { groups(:dachverein) }

      it 'creates default export for events' do
        get :index, group_id: group.id, event: { type: 'Event' }, format: 'csv'
      end

      it 'creates detail export for courses' do
        expect_any_instance_of(::Export::Xlsx::Events::DetailList)
          .to receive(:data_rows)
          .and_call_original

        group.update_attributes!(vid: 42, bsv_number: '99')
        get :index, group_id: group.id, type: 'Event::Course', format: 'xlsx', year: '2012'

        expect(filename).to eq('course_vid42_bsv99_insieme-schweiz_2012.xlsx')
      end

      it 'creates short export for courses' do
        vorstand = Fabricate(:role, group: groups(:dachverein), type: 'Group::Dachverein::Vorstandsmitglied').person
        sign_in(vorstand)

        expect_any_instance_of(::Export::Xlsx::Events::ShortList)
          .to receive(:data_rows)
          .and_call_original

        group.update_attributes!(vid: 42, bsv_number: '99')
        get :index, group_id: group.id, type: 'Event::Course', format: 'xlsx', year: '2012'

        expect(filename).to eq('course_vid42_bsv99_insieme-schweiz_2012.xlsx')
      end
    end

    context 'regionalverein' do
      before do
        sign_in(people(:regio_leader))
        c = Fabricate(:course, groups: [groups(:be)], kind: Event::Kind.first,
                      leistungskategorie: 'bk')
        Fabricate(:aggregate_course, groups: [groups(:be)],
                  leistungskategorie: 'bk')
        Fabricate(:event_date, event: c, start_at: Date.new(2012, 3, 5))
      end
      let(:group) { groups(:be) }

      it 'creates detail export for courses' do
        get :index, group_id: group.id, type: 'Event::Course', format: 'xlsx', year: '2012'

        expect(filename).to eq('course_kanton-bern_2012.xlsx')
      end

      it 'denies export to controlling if not controlling in group' do
        controlling = Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: groups(:fr)).person
        expect do
          sign_in(controlling)
          get :index, group_id: group.id, type: 'Event::Course', format: 'xlsx', year: '2012'
        end.to raise_error(CanCan::AccessDenied)
      end

      it 'creates detail export for aggregate courses' do
        expect_any_instance_of(::Export::Xlsx::Events::AggregateCourse::DetailList)
          .to receive(:data_rows)
          .and_call_original

        group.update_attributes!(vid: 42, bsv_number: '99')
        get :index, group_id: group.id, type: 'Event::AggregateCourse', format: 'xlsx', year: '2012'

        expect(filename).to eq('aggregate_course_vid42_bsv99_kanton-bern_2012.xlsx')
      end

      it 'creates short export for aggregate courses' do
        vorstand = Fabricate(:role, group: groups(:be), type: 'Group::Regionalverein::Vorstandsmitglied').person
        sign_in(vorstand)

        expect_any_instance_of(::Export::Xlsx::Events::AggregateCourse::ShortList)
          .to receive(:data_rows)
          .and_call_original

        group.update_attributes!(vid: 42, bsv_number: '99')
        get :index, group_id: group.id, type: 'Event::AggregateCourse', format: 'xlsx', year: '2012'

        expect(filename).to eq('aggregate_course_vid42_bsv99_kanton-bern_2012.xlsx')
      end
    end

  end

  context 'DELETE#destroy' do
    let(:event) { events(:top_course) }

    context 'reporting frozen' do
      before { GlobalValue.first.update!(reporting_frozen_until_year: 2015) }
      after { GlobalValue.clear_cache }

      it 'cannot destroy course in frozen year' do
        sign_in(people(:regio_leader))
        expect do
          delete :destroy, group_id: groups(:be).id, id: event.id
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  private

  def filename
    content_dispo = response.headers['Content-Disposition']
    content_dispo.split("\"").last
  end

end
