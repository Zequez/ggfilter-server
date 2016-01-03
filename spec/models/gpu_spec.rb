describe Gpu, type: :model do
  describe '#tokenized_name' do
    it 'should use the video card analyzer to tokenize the video card name' do
      gpu = Gpu.create name: 'Radeon HD 8950', value: 100
      expect(gpu.tokenized_name).to eq 'amd8950'
    end

    it 'should ignore megabytes and stuff' do
      gpu = Gpu.create name: '128mb Radeon HD 8950', value: 100
      expect(gpu.tokenized_name).to eq 'amd8950'
    end
  end
end
