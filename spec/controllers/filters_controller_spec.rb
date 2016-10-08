describe FiltersController, type: :controller do
  as_json = { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

  context 'logged out users' do
    describe '#create' do
      it 'should allow only filter and name' do
        post :create, {
          filter: {
            filter: {potato: "salad"}.to_json,
            name: 'qqq',
            official_slug: 'aaa',
            user_slug: 'neio'
          },
        }, as_json
        f = Filter.first
        expect(f.filter).to eq '{"potato":"salad"}'
        expect(f.name).to eq 'qqq'
        expect(f.official_slug).to eq nil
        expect(f.user_slug).to eq nil
        expect(f.user).to eq nil
      end
    end

    describe '#update' do
      it 'should not allow' do
        f = create :filter
        patch :update, id: f.sid, filter: { name: 'Potato' }
        expect(response.status).to eq 401
      end
    end

    describe '#destroy' do
      it 'should not allow' do
        f = create :filter
        delete :destroy, id: f.sid
        expect(response.status).to eq 401
        expect(Filter.find_by_sid(f.sid)).to eq f
      end
    end
  end

  context 'non-admin logged-in users' do
    before :each do
      @u = create :user
      sign_in @u
    end

    describe '#create' do
      it 'should not allow official_slug' do
        post :create, {
          filter: {
            filter: {potato: "salad"}.to_json,
            name: 'qqq',
            official_slug: 'aaa',
            user_slug: 'neio'
          },
        }, as_json
        f = Filter.first
        expect(f.filter).to eq '{"potato":"salad"}'
        expect(f.name).to eq 'qqq'
        expect(f.official_slug).to eq nil
        expect(f.user_slug).to eq 'neio'
        expect(f.user).to eq @u
      end
    end

    describe '#update' do
      it 'should allow on their own filters' do
        f = create :filter, user: @u, name: 'Mah filter'
        patch :update, id: f.sid, filter: { name: 'Potato' }
        expect(response.success?).to eq true
        f.reload
        expect(f.name).to eq 'Potato'
      end

      it 'should not allow on other people filters' do
        f = create :filter, user: (create :user)
        patch :update, id: f.sid, filter: { name: 'Potato' }
        expect(response.status).to eq 401
      end

      it 'should not allow on anonymous filters' do
        f = create :filter
        patch :update, id: f.sid, filter: { name: 'Potato' }
        expect(response.status).to eq 401
      end
    end

    describe '#destroy' do
      it 'should allow on their own filters' do
        f = create :filter, user: @u
        delete :destroy, id: f.sid
        expect(Filter.find_by_sid(f.sid)).to eq nil
      end

      it 'should not on other people filters' do
        u2 = create :user
        f = create :filter, user: u2
        delete :destroy, id: f.sid
        expect(response.status).to eq 401
        expect(Filter.find_by_sid(f.sid)).to eq f
      end

      it 'should not allow on anonymous filters' do
        f = create :filter
        delete :destroy, id: f.sid
        expect(response.status).to eq 401
        expect(Filter.find_by_sid(f.sid)).to eq f
      end
    end
  end

  context 'admin users' do
    before :each do
      @u = create :user, is_admin: true
      sign_in @u
    end

    describe '#create' do
      it 'should allow all params' do
        post :create, {
          filter: {
            filter: {potato: "salad"}.to_json,
            name: 'qqq',
            official_slug: 'aaa',
            user_slug: 'neio'
          },
        }, as_json
        f = Filter.first
        expect(f.filter).to eq '{"potato":"salad"}'
        expect(f.name).to eq 'qqq'
        expect(f.official_slug).to eq 'aaa'
        expect(f.user_slug).to eq 'neio'
        expect(f.user).to eq @u
      end
    end

    describe '#update' do
      it 'should allow regardless of the owner' do
        f = create :filter, user: (create :user)
        patch :update, id: f.sid, filter: { name: 'Potato' }
        expect(response.success?).to eq true
      end

      it 'should allow on anonymous filters' do
        f = create :filter
        patch :update, id: f.sid, filter: { name: 'Potato' }
        expect(response.success?).to eq true
      end
    end

    describe '#destroy' do
      it 'should allow for anonymous filter' do
        f = create :filter
        delete :destroy, id: f.sid
        expect(Filter.find_by_sid(f.sid)).to eq nil
      end

      it 'should allow for other people filters' do
        u2 = create :user, is_admin: false
        f = create :filter, user: u2
        delete :destroy, id: f.sid
        expect(Filter.find_by_sid(f.sid)).to eq nil
      end
    end
  end

  describe 'show' do
    it 'should retrieve a filter from a SID' do
      f = create :filter
      get :show, id: f.sid
      expect(response.success?).to eq true
      expect(JSON.parse(response.body)['sid']).to eq f.sid
    end

    it "should allow you to get a filter by it's official_slug" do
      create :filter, official_slug: 'whoa'
      get :show, id: '0', official_slug: 'whoa'
      expect(response.success?).to eq true
      expect(JSON.parse(response.body)['official_slug']).to eq 'whoa'
    end

    it "should allow you to get a filter by it's user_slug and user_id" do
      user = create :user
      create :filter, user: user, user_slug: 'yippy'
      get :show, id: '0', user_id: user.id, user_slug: 'yippy'
      expect(response.success?).to eq true
      data = JSON.parse(response.body)
      expect(data['user_id']).to eq user.id
      expect(data['user_slug']).to eq 'yippy'
    end

    # TODO:
    # it "should allow you to get a filter by it's session_id"
  end
end
