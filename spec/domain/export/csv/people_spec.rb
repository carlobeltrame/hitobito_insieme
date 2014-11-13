# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
require 'csv'

describe Export::Csv::People do

  let(:person) { people(:top_leader) }
  let(:simple_headers) do
    %w(Vorname Nachname Übername Firmenname Firma Haupt-E-Mail Adresse PLZ Ort Land
       Geschlecht Geburtstag Rollen Personnr. Anrede Korrespondenzsprache) +
       [
         'Anrede Korrespondenzadresse allgemein',
         'Vorname Korrespondenzadresse allgemein',
         'Nachname Korrespondenzadresse allgemein',
         'Firmenname Korrespondenzadresse allgemein',
         'Firma Korrespondenzadresse allgemein',
         'Adresse Korrespondenzadresse allgemein',
         'PLZ Korrespondenzadresse allgemein',
         'Ort Korrespondenzadresse allgemein',
         'Land Korrespondenzadresse allgemein',

         'Anrede Rechnungsadresse allgemein',
         'Vorname Rechnungsadresse allgemein',
         'Nachname Rechnungsadresse allgemein',
         'Firmenname Rechnungsadresse allgemein',
         'Firma Rechnungsadresse allgemein',
         'Adresse Rechnungsadresse allgemein',
         'PLZ Rechnungsadresse allgemein',
         'Ort Rechnungsadresse allgemein',
         'Land Rechnungsadresse allgemein',

         'Anrede Korrespondenzadresse Kurs',
         'Vorname Korrespondenzadresse Kurs',
         'Nachname Korrespondenzadresse Kurs',
         'Firmenname Korrespondenzadresse Kurs',
         'Firma Korrespondenzadresse Kurs',
         'Adresse Korrespondenzadresse Kurs',
         'PLZ Korrespondenzadresse Kurs',
         'Ort Korrespondenzadresse Kurs',
         'Land Korrespondenzadresse Kurs',

         'Anrede Rechnungsadresse Kurs',
         'Vorname Rechnungsadresse Kurs',
         'Nachname Rechnungsadresse Kurs',
         'Firmenname Rechnungsadresse Kurs',
         'Firma Rechnungsadresse Kurs',
         'Adresse Rechnungsadresse Kurs',
         'PLZ Rechnungsadresse Kurs',
         'Ort Rechnungsadresse Kurs',
         'Land Rechnungsadresse Kurs']
  end

  describe Export::Csv::People do

    let(:list) { [person] }
    let(:data) { Export::Csv::People::PeopleAddress.export(list) }
    let(:csv)  { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

    subject { csv }

    context 'export' do
      its(:headers) { should == simple_headers }

      context 'first row' do
        subject { csv[0] }

        its(['Vorname']) { should eq person.first_name }
        its(['Nachname']) { should eq person.last_name }
        its(['Haupt-E-Mail']) { should eq person.email }
        its(['Ort']) { should eq person.town }
        its(['Geschlecht']) { should eq person.gender_label }
        its(['Rollen']) { should eq 'Geschäftsführung insieme Schweiz' }
      end
    end

    context 'export_full' do
      its(:headers) { should include('Anrede') }
      let(:data) { Export::Csv::People::PeopleFull.export(list) }

      context 'first row' do
        subject { csv[0] }

        its(['Vorname']) { should eq 'Top' }
        its(['Nachname']) { should eq 'Leader' }
      end
    end
  end

end
