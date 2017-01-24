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

  describe '.get_tokens_hash' do
    it 'should return a hash with ALL the GPU tokens and their values' do
      Gpu.create name: '128mb Radeon HD 8950', value: 200
      Gpu.create name: '128mb Radeon HD 8950 plus', value: 300
      Gpu.create name: 'Nvidia Geforce 970 ', value: 400

      expect(Gpu.get_tokens_hash).to eq({
        'nvidia970' => 400,
        'amd8950' => 250
      })
    end
  end
end
