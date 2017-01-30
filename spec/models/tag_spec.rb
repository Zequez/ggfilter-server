describe Tag, type: :model do
  after :each do
    Tag.delete_tags_cache
  end

  describe '.get_id_from_name' do
    it 'should allow you to get a tag ID from the name' do
      t = create :tag, name: 'Potato'
      expect(Tag.get_id_from_name('potato')).to eq t.id
      expect(Tag.count).to eq 1
    end

    it 'should create a tag if it doesnt exists' do
      id = Tag.get_id_from_name('Cuack')
      tag = Tag.find(id)
      expect(Tag.count).to eq 1
      expect(tag.name).to eq 'Cuack'
    end
  end
end
