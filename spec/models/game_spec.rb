describe Game, type: :model do
  subject{ build :game }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }
end
