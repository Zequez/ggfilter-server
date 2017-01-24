class SysreqAnalyzer
  attr_accessor :tokens

  # Params:
  # +tokens_list+:: array of arrays of tokens strings
  # +known_values+:: hash of tokens with known values
  def initialize(tokens_list, known_values)
    @tokens_list = tokens_list
    @known_values = known_values
    @linear_regression_tokens = {
      /^[0-9]+x[0-9]+$/ => ->(name){ name.split('x').map(&:to_i).reduce(:*) },
      /^directx[0-9]+$/ => ->(name){ name.match(/[0-9]+$/)[0].to_i },
      /^year[0-9]+$/ => ->(name){ name.match(/[0-9]+$/)[0].to_i }
    }

    # Hash of all tokens in the tokens_list and the resolved values
    @tokens = {}

    resolve_all_values
  end

  def get_list_values
    @tokens_list.map do |tokens|
      tokens.map{ |token| @tokens[token] }
    end
  end

  def get_list_values_averages
    get_list_values.map{ |values| avg(values.compact) }
  end

  def resolve_all_values
    resolve_known_values
    resolve_wildcards_values
    resolve_inferred_values
    resolve_projected_values
  end

  def resolve_known_values
    @tokens_list.flatten.uniq.each do |token|
      if @known_values[token]
        @tokens[token] = @known_values[token]
      else
        @tokens[token] = nil
      end
    end
  end

  def unresolved
    @tokens.keys.select{ |key| @tokens[key].nil? }
  end

  def resolve_wildcards_values
    known_tokens = @known_values.keys
    unresolved.each do |token|
      if token =~ /x{2,}/
        regex = Regexp.new token.gsub(/x/, '[0-9]')
        found_tokens = known_tokens.select{ |name| name =~ regex }
        values = found_tokens.map{ |name| @known_values[name] }
        @tokens[token] = avg values
      end
    end
  end

  def resolve_inferred_values
    unresolved.each do |token|
      siblings_values = []
      @tokens_list.each do |group|
        if group.include? token
          siblings_values += group.map{ |v| @tokens[v] }.compact
        end
      end

      @tokens[token] = avg(siblings_values)
    end
  end

  def resolve_projected_values
    @linear_regression_tokens.each_pair do |name_scan, extract_value|
      known_tokens_values_x = []
      known_tokens_values_y = []
      to_resolve_from_slope = []

      @tokens.keys.each do |name|
        if name =~ name_scan
          if @tokens[name]
            extracted_value = extract_value.call(name)
            token_value = @tokens[name]
            count_token(name).times do
              known_tokens_values_x.push extracted_value
              known_tokens_values_y.push token_value
            end
          else
            to_resolve_from_slope.push name
          end
        end
      end

      if known_tokens_values_x.size > 0 and to_resolve_from_slope.size > 0
        lr = SimpleLinearRegression.new(
          known_tokens_values_x,
          known_tokens_values_y
        )

        to_resolve_from_slope.each do |name|
          value_to_project = extract_value.call(name)
          @tokens[name] = (lr.y_intercept + lr.slope * value_to_project).round
        end
      end
    end
  end

  def avg(arr)
    return nil unless arr.size > 0
    arr.reduce(&:+).to_f / arr.size
  end

  def count_token(name)
    @flat_tokens_list ||= @tokens_list.flatten
    count = 0
    @flat_tokens_list.each{ |n| count += 1 if n == name }
    count
  end
end
