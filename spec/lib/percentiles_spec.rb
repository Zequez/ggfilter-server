describe Percentiles do
  it 'should work with all different values' do
    # values = [5, 6, 10, 400, 10, 5, 10, 10, 40, 656, 43, 434, 125]
    values = [10, 20, 30, 40, 50, 50, 100]
    stats = DescriptiveStatistics::Stats.new(values)
    values_pct = values.map{ |v| stats.percentile_rank(v).round }

    expect(Percentiles.rank_of_values(values)).to eq values_pct
  end

  it 'should work with repeated values' do
    values = [10, 10, 10, 10, 10, 10, 10, 10]
    stats = DescriptiveStatistics::Stats.new(values)
    values_pct = values.map{ |v| stats.percentile_rank(v).round }

    expect(Percentiles.rank_of_values(values)).to eq values_pct
  end

  it 'should work mixed repeated values' do
    values = [10, 10, 20, 20, 30, 30, 40, 50, 60, 60, 60]
    stats = DescriptiveStatistics::Stats.new(values)
    values_pct = values.map{ |v| stats.percentile_rank(v).round }

    expect(Percentiles.rank_of_values(values)).to eq values_pct
  end

  # Note: Yes, it's 2 orders of magnitude faster
  it 'should actually be faster' do
    prng = Random.new
    values = 500.times.map{ prng.rand(1000) }

    values_pct_ds = nil
    time_ds = Benchmark.measure{
      stats = DescriptiveStatistics::Stats.new(values)
      values_pct_ds = values.map{ |v| stats.percentile_rank(v).round }
    }.real

    values_pct_own = nil
    time_own = Benchmark.measure{
      values_pct_own = Percentiles.rank_of_values(values)
    }.real

    expect(values_pct_ds).to eq values_pct_own
    expect(time_own).to be < time_ds
  end
end
