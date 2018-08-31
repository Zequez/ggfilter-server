# == Schema Information
#
# Table name: tags
#
#  id   :integer          not null, primary key
#  name :string           not null
#
# Indexes
#
#  index_tags_on_name  (name)
#

class Tag < ActiveRecord::Base
  def self.tags_cache
    @tags_cache ||= Hash[Tag.pluck(:name, :id).map{|t| [t[0].downcase, t[1]]}]
  end

  def self.delete_tags_cache
    @tags_cache = nil
  end

  def self.from_tags_cache(name)
    tags_cache[name.downcase]
  end

  def self.get_id_from_name(name)
    from_tags_cache(name) || create(name: name).id
  end

  after_create do
    Tag.tags_cache[name.downcase] = id
  end

  after_destroy do
    Tag.tags_cache.delete(name.downcase)
  end

  def self.find_or_create_by_name(name)
    if ( tag = where('lower(name) = ?', name.downcase).first )
      tag
    else
      create name: name
    end
  end

  def self.ids_by_names(names)
    where('lower(name) IN ?', names.map(&:downcase)).pluck(:id)
  end
end
