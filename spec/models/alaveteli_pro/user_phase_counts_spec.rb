# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'AlaveteliPro::UserPhaseCounts' do
  let(:user) { FactoryGirl.create(:user) }

  describe '#phase_count' do

    it 'returns an integer'

    it 'returns 0 if there is no matching phase key' do
      expect(user.phase_count('imadethisup')).to eq 0
    end

    it 'calculates the total'

    context 'with expiring embargoes' do

      it 'counts the expiring emargoes'

      it 'does not overcount the total'

    end

    context 'with draft requests' do

      it 'counts the draft requests'

      it 'does not overcount the total'

    end

    it 'excepts a symbol key' do
      expect(user.phase_count(:awaiting_response)).to eq 1
    end

  end

  describe '#reset_phase_count' do

  end

end
