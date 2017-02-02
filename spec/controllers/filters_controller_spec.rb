describe FiltersController, type: :controller do
  def payload(attrs)
    {
      params: {
        payload: attrs
      }
    }
  end

  context 'logged out users' do
    describe '#create' do
      it 'should allow only filter and name' do
        post :create, payload(attributes_for(:filter_for_create,
          controls_list: ['prices'],
          name: 'Potato',
          front_page: 5,
          ip_address: 'woo',
          global_slug: 'nope',
          sid: '1234'
        )), format: :json
        f = Filter.first
        expect(f.controls_list).to eq ['prices']
        expect(f.name).to eq 'Potato'
        expect(f.name_slug).to eq 'potato'
        expect(f.global_slug).to eq nil
        expect(f.sid).to_not eq '1234'
        expect(f.ip_address).to eq '0.0.0.0'
        expect(f.front_page).to eq nil

        expect(response_json['secret']).to eq f.secret
      end
    end

    describe '#update' do
      it 'should not allow without the secret' do
        f = create :filter, name: 'Potato'
        patch :update, {params: {
          id: f.sid,
          secret: 'WRONG',
          payload: {
            name: 'Nope'
          }
        }}, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'should allow with the secret' do
        f = create :filter, name: 'Potato'
        old_secret = f.secret
        patch :update, {params: {
          id: f.sid,
          secret: old_secret,
          payload: {
            name: 'Yes!',
            secret: 'Nope'
          }
        }}, format: :json
        expect(response).to have_http_status(:success)
        f.reload
        expect(f.name).to eq 'Yes!'
        expect(f.secret).to eq old_secret
      end
    end

    describe '#destroy' do
      it 'should not allow it without a secret' do
        f = create :filter
        delete :destroy, {params: {id: f.sid}}
        expect(response).to have_http_status(:unauthorized)
        expect(Filter.find_by_sid(f.sid)).to eq f
      end

      it 'should allow it with the secret' do
        f = create :filter
        delete :destroy, {params: {id: f.sid, secret: f.secret}}
        expect(response).to have_http_status(:success)
        expect(Filter.find_by_sid(f.sid)).to eq nil
      end
    end

    describe '#show' do
      it 'should display the filter, but without the secret' do
        f = create :filter
        get :show, {params: {id: f.sid}}
        fj = response_json
        expect(fj.keys).to match_array [
          'created_at', 'updated_at',
          'sid', 'name', 'name_slug',
          'user_id', 'visits', 'ip_address',
          'global_slug', 'front_page',
          'sorting',
          'controls_list',
          'controls_hl_mode',
          'controls_config',
          'columns_list',
          'columns_config',
          'global_config',
        ]
      end
    end
  end
end

#   context 'non-admin logged-in users' do
#     before :each do
#       @u = create :user
#       sign_in @u
#     end
#
#     describe '#create' do
#       it 'should not allow official_slug' do
#         post :create, {
#           filter: {
#             filter: {potato: "salad"}.to_json,
#             name: 'qqq',
#             official_slug: 'aaa',
#             user_slug: 'neio'
#           },
#         }, as_json
#         f = Filter.first
#         expect(f.filter).to eq '{"potato":"salad"}'
#         expect(f.name).to eq 'qqq'
#         expect(f.official_slug).to eq nil
#         expect(f.user_slug).to eq 'neio'
#         expect(f.user).to eq @u
#       end
#     end
#
#     describe '#update' do
#       it 'should allow on their own filters' do
#         f = create :filter, user: @u, name: 'Mah filter'
#         patch :update, id: f.sid, filter: { name: 'Potato' }
#         expect(response.success?).to eq true
#         f.reload
#         expect(f.name).to eq 'Potato'
#       end
#
#       it 'should not allow on other people filters' do
#         f = create :filter, user: (create :user)
#         patch :update, id: f.sid, filter: { name: 'Potato' }
#         expect(response.status).to eq 401
#       end
#
#       it 'should not allow on anonymous filters' do
#         f = create :filter
#         patch :update, id: f.sid, filter: { name: 'Potato' }
#         expect(response.status).to eq 401
#       end
#     end
#
#     describe '#destroy' do
#       it 'should allow on their own filters' do
#         f = create :filter, user: @u
#         delete :destroy, id: f.sid
#         expect(Filter.find_by_sid(f.sid)).to eq nil
#       end
#
#       it 'should not on other people filters' do
#         u2 = create :user
#         f = create :filter, user: u2
#         delete :destroy, id: f.sid
#         expect(response.status).to eq 401
#         expect(Filter.find_by_sid(f.sid)).to eq f
#       end
#
#       it 'should not allow on anonymous filters' do
#         f = create :filter
#         delete :destroy, id: f.sid
#         expect(response.status).to eq 401
#         expect(Filter.find_by_sid(f.sid)).to eq f
#       end
#     end
#   end
#
#   context 'admin users' do
#     before :each do
#       @u = create :user, is_admin: true
#       sign_in @u
#     end
#
#     describe '#create' do
#       it 'should allow all params' do
#         post :create, {
#           filter: {
#             filter: {potato: "salad"}.to_json,
#             name: 'qqq',
#             official_slug: 'aaa',
#             user_slug: 'neio'
#           },
#         }, as_json
#         f = Filter.first
#         expect(f.filter).to eq '{"potato":"salad"}'
#         expect(f.name).to eq 'qqq'
#         expect(f.official_slug).to eq 'aaa'
#         expect(f.user_slug).to eq 'neio'
#         expect(f.user).to eq @u
#       end
#     end
#
#     describe '#update' do
#       it 'should allow regardless of the owner' do
#         f = create :filter, user: (create :user)
#         patch :update, id: f.sid, filter: { name: 'Potato' }
#         expect(response.success?).to eq true
#       end
#
#       it 'should allow on anonymous filters' do
#         f = create :filter
#         patch :update, id: f.sid, filter: { name: 'Potato' }
#         expect(response.success?).to eq true
#       end
#     end
#
#     describe '#destroy' do
#       it 'should allow for anonymous filter' do
#         f = create :filter
#         delete :destroy, id: f.sid
#         expect(Filter.find_by_sid(f.sid)).to eq nil
#       end
#
#       it 'should allow for other people filters' do
#         u2 = create :user, is_admin: false
#         f = create :filter, user: u2
#         delete :destroy, id: f.sid
#         expect(Filter.find_by_sid(f.sid)).to eq nil
#       end
#     end
#   end
#
#   describe 'show' do
#     it 'should retrieve a filter from a SID' do
#       f = create :filter
#       get :show, id: f.sid
#       expect(response.success?).to eq true
#       expect(JSON.parse(response.body)['sid']).to eq f.sid
#     end
#
#     it "should allow you to get a filter by it's official_slug" do
#       create :filter, official_slug: 'whoa'
#       get :show, id: '0', official_slug: 'whoa'
#       expect(response.success?).to eq true
#       expect(JSON.parse(response.body)['official_slug']).to eq 'whoa'
#     end
#
#     it "should allow you to get a filter by it's user_slug and user_id" do
#       user = create :user
#       create :filter, user: user, user_slug: 'yippy'
#       get :show, id: '0', user_id: user.id, user_slug: 'yippy'
#       expect(response.success?).to eq true
#       data = JSON.parse(response.body)
#       expect(data['user_id']).to eq user.id
#       expect(data['user_slug']).to eq 'yippy'
#     end
#
#     # TODO:
#     # it "should allow you to get a filter by it's session_id"
#   end
#
#   describe 'index' do
#     it 'should list all the official filters by default' do
#       f1 = create :filter, official_slug: 'potato-galaxy', visits: 10
#       f2 = create :filter, official_slug: 'amasa', visits: 30
#       f3 = create :filter, official_slug: 'mayonesa', visits: 5
#       create :filter, official_slug: nil
#       get :index
#       expect(response.success?).to eq true
#       expect(JSON.parse(response.body).map{|v| v['sid']}).to eq [f2.sid, f1.sid, f3.sid]
#     end
#
#     it 'should list all the filters by certain user' do
#       u1 = create :user
#       u2 = create :user
#       f1 = create :filter, official_slug: 'potato-galaxy', user: u1
#       create :filter, official_slug: 'amasa', user: u2
#       f3 = create :filter, official_slug: 'mayonesa', user: u1
#       f4 = create :filter, official_slug: nil, user: u1
#       get :index, user_id: u1.id
#       expect(JSON.parse(response.body).map{|v| v['sid']}).to eq [f1.sid, f3.sid, f4.sid]
#     end
#   end
# end
