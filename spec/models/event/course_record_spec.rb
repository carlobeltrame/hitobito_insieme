# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::CourseRecord do

  let(:group) { groups(:be) }

  let(:event_bk) { events(:top_course) }
  let(:event_tk) { Fabricate(:course, groups: [group], leistungskategorie: 'tk') }
  let(:event_sk) { Fabricate(:course, groups: [group], leistungskategorie: 'sk') }

  def new_record(event, attrs = {})
    r = Event::CourseRecord.new(attrs.merge(event: event))
    r.valid?
    r
  end

  context 'validation' do
    it 'fails for invalid event' do
      new_record(events(:top_event)).should have(1).error
    end

    it 'is fine with empty fields' do
      new_record(event_bk).should be_valid
    end

    it 'fails for inputkriterien other than a, b or c' do
      new_record(event_bk, inputkriterien: 'a').should be_valid
      new_record(event_bk, inputkriterien: 'b').should be_valid
      new_record(event_bk, inputkriterien: 'c').should be_valid
      new_record(event_bk, inputkriterien: 'd').should_not be_valid
    end

    it 'fails for not subsidized event with inputkriterien not being a' do
      new_record(event_bk, inputkriterien: 'a', subventioniert: true).should be_valid
      new_record(event_bk, inputkriterien: 'b', subventioniert: true).should be_valid
      new_record(event_bk, inputkriterien: 'a', subventioniert: false).should be_valid
      new_record(event_bk, inputkriterien: 'b', subventioniert: false).should_not be_valid
    end

    it 'fails for semester-/jahreskurs with inputkriterien not being a' do
      new_record(event_sk, inputkriterien: 'a').should be_valid
      new_record(event_sk, inputkriterien: 'b').should_not be_valid
    end

    it 'fails for kursart other than weiterbildung or freizeit_und_sport' do
      new_record(event_bk, kursart: 'weiterbildung').should be_valid
      new_record(event_bk, kursart: 'freizeit_und_sport').should be_valid
      new_record(event_bk, kursart: 'freizeit_und_sport').should be_valid
      new_record(event_bk, kursart: 'foo').should_not be_valid
    end

    it 'is fine for decimal time values that are a multiple of 0.5 for bk/tk courses' do
      new_record(event_bk, kursdauer: 1.5, absenzen_behinderte: 1.5,
                 absenzen_angehoerige: 1.5, absenzen_weitere: 1.5).should be_valid

      new_record(event_tk, kursdauer: 1.5, absenzen_behinderte: 1.5,
                 absenzen_angehoerige: 1.5, absenzen_weitere: 1.5).should be_valid
    end

    it 'fails for decimal time values that are not a multiple of 0.5 for bk/tk courses' do
      new_record(event_bk, kursdauer: 1.25, absenzen_behinderte: 1.25, absenzen_angehoerige: 1.25,
                 absenzen_weitere: 1.25).should have(4).errors

      new_record(event_bk, kursdauer: 1.25, absenzen_behinderte: 1.25, absenzen_angehoerige: 1.25,
                 absenzen_weitere: 1.25).should have(4).errors
    end

    it 'only accepts integer time values for sk course' do
      new_record(event_sk, kursdauer: 1, absenzen_behinderte: 1,
                 absenzen_angehoerige: 1, absenzen_weitere: 1).should be_valid

      new_record(event_sk, kursdauer: 1.5, absenzen_behinderte: 1.5,
                 absenzen_angehoerige: 1.5, absenzen_weitere: 1.5).should have(4).errors
    end
  end

  context 'default values' do
    it 'subventioniert defaults to true' do
      new_record(event_bk).should be_subventioniert
    end

    it 'inputkriterien defaults to a' do
      new_record(event_bk).inputkriterien.should eq('a')
    end

    it 'kursart defaults to weiterbildung' do
      new_record(event_bk).kursart.should eq('weiterbildung')
    end
  end


  context 'spezielle_unterkunft' do
    it 'can be overriden for bk and tk course' do
      new_record(event_bk).should_not be_spezielle_unterkunft
      new_record(event_bk, spezielle_unterkunft: true).should be_spezielle_unterkunft

      new_record(event_tk).should_not be_spezielle_unterkunft
      new_record(event_tk, spezielle_unterkunft: true).should be_spezielle_unterkunft
    end

    it 'is always false for sk course' do
      new_record(event_sk).should_not be_spezielle_unterkunft
      new_record(event_sk, spezielle_unterkunft: true).should_not be_spezielle_unterkunft
    end
  end

  context 'leistungskategorie helpers' do
    it 'should reflect bk course' do
      r = Event::CourseRecord.new(event: event_bk)
      r.bk?.should be_true
      r.tk?.should be_false
      r.sk?.should be_false
    end

    it 'should reflect tk course' do
      r = Event::CourseRecord.new(event: event_tk)
      r.bk?.should be_false
      r.tk?.should be_true
      r.sk?.should be_false
    end

    it 'should reflect sk course' do
      r = Event::CourseRecord.new(event: event_sk)
      r.bk?.should be_false
      r.tk?.should be_false
      r.sk?.should be_true
    end
  end

end
