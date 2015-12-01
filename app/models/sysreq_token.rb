class SysreqToken < ActiveRecord::Base
  def self.token_type_enum
    { no: 0, gpu: 1, cpu: 2, mem: 3, hdd: 4 }
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

  ### token_type enum

  def token_type_enum
    self.class.token_type_enum
  end

  def token_type=(support)
    write_attribute :token_type, token_type_enum[support.to_sym]
  end

  def token_type
    token_type_enum.invert[read_attribute :token_type]
  end
end
