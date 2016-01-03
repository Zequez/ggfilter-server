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
    inferred: 4,
    inferred_projection: 5
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
      t.value = nil
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

  def infer_projection_resolution
    infer_projection(/^[0-9]+x[0-9]+$/) do |name|
      name.split('x').map(&:to_i).reduce(:*)
    end
  end

  def infer_projection_directx
    infer_projection(/^directx[0-9]+$/) do |name|
      name.match(/[0-9]+$/)[0].to_i
    end
  end

  # def infer_projection_video_memory
  #   infer_projection(/^[0-9]+mb$/, true) do |name|
  #     m = name.match(/([0-9]+)/)
  #     val = m[1].to_i
  #     unit = m[2]
  #     if unit == 'gb'
  #       val = val * 1024
  #     end
  #     val
  #   end
  # end

  def self.infer_projected_values!
    SysreqToken.where(source: [source_enum[:none], source_enum[:inferred_projection]]).each do |token|
      token.infer_projection_resolution
      token.infer_projection_directx
      # token.infer_projection_video_memory
      token.save!
    end
  end

  def games
    @games ||= Game.where("sysreq_video_tokens ~ '\\m#{name}\\M'")
  end

  def self.average_value
    where.not(value: nil).average(:value)
  end

  private

  def infer_projection(name_regex, weighted = false, &name_to_linear_value)
    if name =~ name_regex
      tokens = SysreqToken
        .where("name ~ '#{name_regex.source}'")
        .where(source: source_enum[:inferred])
        .where.not(value: nil)
      name_values = tokens.map{ |t| Array.new t.games_count, name_to_linear_value.call(t.name) }.flatten
      values = tokens.map{ |t| Array.new t.games_count, t.value }.flatten
      lr = SimpleLinearRegression.new name_values, values
      L lr.slope
      L lr.y_intercept
      self.value = (lr.y_intercept + lr.slope * name_to_linear_value.call(name)).round
      self.source = :inferred_projection
    end
  end
end
