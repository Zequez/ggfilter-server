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
    wildcard: 3
  }

  before_save do
    if linked_to_changed?
      tokens_names = linked_to.split(/\s+/)
      values = SysreqToken.where(name: tokens_names).where.not(value: nil).pluck(:value)
      if values.size > 0
        self.value = values.reduce(&:+) / values.size
      end
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

  def games
    @games ||= Game.where("sysreq_video_tokens ~ '\\m#{name}\\M'")
  end

  def games=(games)
    @games = games
  end

  def self.with_loaded_games
    tokens = all.to_a
    selected_tokens = tokens.select{|t| t.games_count <= 10}
    names = selected_tokens.select{|t| t.games_count <= 10}.map(&:name).join('|') # Performance reasons
    names = "sysreq_video_tokens ~ '\\m#{names}\\M'"
    games = Game.where(names).to_a
    selected_tokens.map do |t|
      regex = /\b#{t.name}\b/
      gg = games.select{|g| g.sysreq_video_tokens =~ regex }
      t.games = gg
    end
    tokens
  end
end
