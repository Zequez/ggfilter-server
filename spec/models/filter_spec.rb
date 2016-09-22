describe Filter, type: :model do
  describe 'validation' do
    describe 'filter' do
      it 'should be a valid JSON object' do
        f = build :filter, filter: '{"potato": "salad"}'
        expect(f).to be_valid
      end

      it 'should not allow arbitrary strings' do
        f = build :filter, filter: 'potato'
        expect(f).to be_invalid
      end

      it 'should not allow JSON strings' do
        f = build :filter, filter: '"potato"'
        expect(f).to be_invalid
      end

      it 'should not allow JSON numbers' do
        f = build :filter, filter: '6'
        expect(f).to be_invalid
      end
    end
  end

  describe 'sid' do
    it 'should be generated on save' do
      f = build :filter
      expect(f.sid).to eq nil
      f.save!
      expect(f.sid).to match(/\A[a-zA-Z0-9\-_]{8}\Z/)
    end
  end
end
