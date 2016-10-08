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

      describe '#official_slug' do
        it 'should allow to create an official_slug' do
          f = build :filter, official_slug: 'potato'
          expect(f).to be_valid
          expect(f.official_slug).to eq 'potato'
        end

        it 'should not allow 2 filters with the same official_slug' do
          _ = create :filter, official_slug: 'potato'
          f2 = build :filter, official_slug: 'potato'
          expect(f2).to be_invalid
        end

        it 'should allow 2 filters with nil official_slug' do
          create :filter, official_slug: nil
          expect{ create :filter, official_slug: nil }.to_not raise_error
        end

        it 'should turn blanks into nil' do
          f = build :filter, official_slug: ''
          expect(f).to be_valid
          f.save!
          expect(f.official_slug).to eq nil
        end

        it 'should validate the official slug characters' do
          expect(build :filter, official_slug: '!!!').to be_invalid
          expect(build :filter, official_slug: 'hello there').to be_invalid
          expect(build :filter, official_slug: 'Amazing!').to be_invalid
          expect(build :filter, official_slug: 'what$if').to be_invalid
          expect(build :filter, official_slug: '      hello').to be_invalid
          expect(build :filter, official_slug: 'padd  ').to be_invalid
          expect(build :filter, official_slug: '/potato').to be_invalid
          expect(build :filter, official_slug: '/potato/salad').to be_invalid
          expect(build :filter, official_slug: 'potato_salad').to be_invalid
          expect(build :filter, official_slug: 'a'*51).to be_invalid

          expect(build :filter, official_slug: 'a').to be_valid
          expect(build :filter, official_slug: 'a'*50).to be_valid
          expect(build :filter, official_slug: 'abc-123').to be_valid
          expect(build :filter, official_slug: 'Abc123').to be_valid
        end
      end

      describe '#user_slug' do
        it 'should allow to create a #user_slug' do
          u = create :user
          f = build :filter, user_slug: 'potato', user: u
          expect(f).to be_valid
          expect(f.user_slug).to eq 'potato'
        end

        it 'should allow a nil #user_slug' do
          u = create :user
          f = build :filter, user_slug: nil, user: u
          expect(f).to be_valid
          expect(f.user_slug).to eq nil
        end

        it 'should not allow a filter with a #user_slug and no user' do
          f = build :filter, user_slug: 'potato'
          expect(f).to be_invalid
        end

        it 'should not allow 2 filters of the same user with the same #user_slug' do
          u = create :user
          create :filter, user_slug: 'aaa', user: u
          f = build :filter, user_slug: 'aaa', user: u
          expect(f).to be_invalid
        end

        it 'should allow 2 filters from different users with the same #user_slug' do
          u1 = create :user
          u2 = create :user
          create :filter, user_slug: 'aaa', user: u1
          f = create :filter, user_slug: 'aaa', user: u2
          expect(f).to be_valid
        end

        it 'should turn blanks into nil' do
          u1 = create :user
          f = build :filter, user_slug: '', user: u1
          expect(f).to be_valid
          f.save!
          expect(f.user_slug).to eq nil
        end

        it 'should validate the #user_slug characters' do
          u = create :user
          expect(build :filter, user: u, user_slug: '!!!').to be_invalid
          expect(build :filter, user: u, user_slug: 'hello there').to be_invalid
          expect(build :filter, user: u, user_slug: 'Amazing!').to be_invalid
          expect(build :filter, user: u, user_slug: 'what$if').to be_invalid
          expect(build :filter, user: u, user_slug: '      hello').to be_invalid
          expect(build :filter, user: u, user_slug: 'padd  ').to be_invalid
          expect(build :filter, user: u, user_slug: '/potato').to be_invalid
          expect(build :filter, user: u, user_slug: '/potato/salad').to be_invalid
          expect(build :filter, user: u, user_slug: 'potato_salad').to be_invalid
          expect(build :filter, user: u, user_slug: 'a'*51).to be_invalid

          expect(build :filter, user: u, user_slug: 'a').to be_valid
          expect(build :filter, user: u, user_slug: 'a'*50).to be_valid
          expect(build :filter, user: u, user_slug: 'abc-123').to be_valid
          expect(build :filter, user: u, user_slug: 'Abc123').to be_valid
        end
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

    it 'should not re-generate it on update' do
      f = build :filter
      expect(f.sid).to eq nil
      f.save!
      sid = f.sid
      f.save!
      expect(f.sid).to eq sid
    end
  end
end
