class Percentiles
  class << self
    def rank_of_values(values)
      sorted_vals = values.sort
      values_count = values.size
      values.map do |val|
        index = sorted_vals.rindex(val).to_f
        (index / values_count * 100).floor
      end
    end
  end
end
