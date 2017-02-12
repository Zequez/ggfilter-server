describe Filter, type: :model do
  describe 'validation' do
    describe 'filter' do
      describe '#name' do
        it 'should allow it to be nil' do
          expect(build :filter, name: nil).to be_valid
        end

        it 'should turn blanks into nil' do
          f = build :filter, name: ''
          expect(f).to be_valid
          f.save!
          expect(f.name).to eq nil
        end

        it 'should allow up to 140 characters' do
          expect(build :filter, name: 'a'*140).to be_valid
          expect(build :filter, name: 'a'*141).to be_invalid
        end
      end

      describe '#name_slug' do
        it 'should automatically be generated from the name' do
          expect(create(:filter, name: 'Potato Galaxy').name_slug)
            .to eq 'potato-galaxy'
        end

        it 'should allow it to be repeated' do
          f1 = create :filter, name: 'potato galaxy'
          f2 = create :filter, name: 'potato galaxy'
          expect(f1.name_slug).to eq f2.name_slug
        end
      end

      describe '#global_slug' do
        it 'should allow to create an global_slug' do
          f = build :filter, global_slug: 'potato'
          expect(f).to be_valid
          expect(f.global_slug).to eq 'potato'
        end

        it 'should not allow 2 filters with the same global_slug' do
          _ = create :filter, global_slug: 'potato'
          f2 = build :filter, global_slug: 'potato'
          expect(f2).to be_invalid
        end

        it 'should allow 2 filters with nil global_slug' do
          create :filter, global_slug: nil
          expect{ create :filter, global_slug: nil }.to_not raise_error
        end

        it 'should turn blanks into nil' do
          f = build :filter, global_slug: ''
          expect(f).to be_valid
          f.save!
          expect(f.global_slug).to eq nil
        end

        it 'should validate the official slug characters' do
          expect(build :filter, global_slug: '!!!').to be_invalid
          expect(build :filter, global_slug: 'hello there').to be_invalid
          expect(build :filter, global_slug: 'Amazing!').to be_invalid
          expect(build :filter, global_slug: 'what$if').to be_invalid
          expect(build :filter, global_slug: '      hello').to be_invalid
          expect(build :filter, global_slug: 'padd  ').to be_invalid
          expect(build :filter, global_slug: '/potato').to be_invalid
          expect(build :filter, global_slug: '/potato/salad').to be_invalid
          expect(build :filter, global_slug: 'potato_salad').to be_invalid
          expect(build :filter, global_slug: 'a'*51).to be_invalid

          expect(build :filter, global_slug: 'a').to be_valid
          expect(build :filter, global_slug: 'a'*50).to be_valid
          expect(build :filter, global_slug: 'abc-123').to be_valid
          expect(build :filter, global_slug: 'Abc123').to be_valid
        end
      end
    end
  end

  describe '#sid' do
    it 'should be generated on save' do
      f = build :filter
      expect(f.sid).to eq nil
      f.save!
      expect(f.sid).to match(/\A[a-zA-Z0-9\-_]{8}\Z/)
    end

    it 'should not re-generate it on update' do
      f = build :filter
      expect(f.sid).to eq nil
      f.save!
      sid = f.sid
      f.save!
      expect(f.sid).to eq sid
    end
  end

  describe '#secret' do
    it 'should be generated on save' do
      f = build :filter
      expect(f.secret).to eq nil
      f.save!
      expect(f.secret).to match(/\A[a-zA-Z0-9\-_]{50}\Z/)
    end

    it 'should not re-generate it on update' do
      f = build :filter
      expect(f.secret).to eq nil
      f.save!
      secret = f.secret
      f.save!
      expect(f.secret).to eq secret
    end
  end

  describe '#ip_address' do
    it 'should be limited to 30 per hour' do
      30.times do
        create :filter, ip_address: '123.456.654.321'
      end

      f = build :filter, ip_address: '123.456.654.321'
      expect(f).to be_invalid
      expect(f.errors[:ip_address]).to_not be_nil

    end
  end

  describe 'all serialized objects' do
    it 'should validate them' do
      expect(build :filter, controls_list: {}).to be_invalid
      expect(build :filter, controls_hl_mode: {}).to be_invalid
      expect(build :filter, controls_params: []).to be_invalid
      expect(build :filter, columns_list: {}).to be_invalid
      expect(build :filter, columns_params: []).to be_invalid
      expect(build :filter, sorting: 'sup').to be_invalid
      expect(build :filter, global_config: []).to be_invalid
    end
  end
end
