class SysreqToken < ActiveRecord::Base
  include SimpleEnum

  simple_enum_column :token_type, {
    no:  0,
    gpu: 1,
    cpu: 2,
    mem: 3,
    hdd: 4
  }

  simple_enum_column :source, {
    none: 0,
    manual: 1,
    gpu_benchmarks: 2,
    wildcard: 3,
    inferred: 4
  }

  before_save do
    if linked_to_changed?
      tokens_names = linked_to.split(/\s+/)
      self.value = SysreqToken.where(name: tokens_names).average_value
    end
  end

  def self.analyze_games
    tokens = SysreqToken.where(token_type: token_type_enum[:gpu]).all
    hashed_tokens = Hash[tokens.map do |t|
      t.games_count = 0
      [t.name, t]
    end]

    games_string_tokens = Game.pluck(:sysreq_video_tokens)
    games_string_tokens.each do |string_tokens|
      string_tokens.split(' ').each do |token|
        hashed_tokens[token] ||= SysreqToken.new name: token
        hashed_tokens[token].token_type = :gpu
        hashed_tokens[token].games_count += 1
      end
    end

    ActiveRecord::Base.transaction do
      hashed_tokens.each_value do |token|
        token.save!
      end
    end

    nil
  end

  def self.values_from_gpus_benchmarks!
    SysreqToken.all.each do |token|
      if ( gpu = Gpu.where(tokenized_name: token.name).first )
        token.value = gpu.value
        token.source = :gpu_benchmarks
        token.save!
      end
    end
  end

  def self.link_wildcards!
    SysreqToken.where("name ~ 'x{2,}'").each do |token|
      regex_name = token.name.gsub(/x/, '[0-9]')
      token.linked_to = SysreqToken.where("name ~ '\\m#{regex_name}\\M'").pluck(:name).join(' ')
      token.source = :wildcard
      token.save!
    end
  end

  def infer_value
    names = games.pluck(:sysreq_video_tokens).join(' ').split(/\s+/).uniq
    self.value = SysreqToken.where(
      name: names,
      source: [source_enum[:gpu_benchmarks], source_enum[:manual]]
    ).average_value
    if value
      self.source = :inferred
      value
    else
      nil
    end
  end

  def self.infer_values!
    SysreqToken.where(source: [source_enum[:none], source_enum[:inferred]]).each do |token|
      if token.infer_value
        token.save!
      end
    end
  end

  def games
    @games ||= Game.where("sysreq_video_tokens ~ '\\m#{name}\\M'")
  end

  def self.average_value
    where.not(value: nil).average(:value)
  end
end
