describe SysreqAnalyzer do
  describe '#get_list_values_averages' do
    it 'should return the averages of each group' do
      sa = SysreqAnalyzer.new([['amd8950', 'amd8955'], ['unknown'], ['intel4000']], {
        'amd8950' => 100,
        'amd8955' => 200,
        'intel4000' => 300
      })

      expect(sa.tokens).to eq({
        'amd8950' => 100,
        'amd8955' => 200,
        'intel4000' => 300,
        'unknown' => nil
      })
      expect(sa.get_list_values_averages).to eq [150.0, nil, 300.0]
    end
  end

  it 'should extract values from the GPUs benchmarks' do
    sa = SysreqAnalyzer.new([['amd8950']], {
      'amd8950' => 100
    })

    expect(sa.tokens).to eq({
      'amd8950' => 100
    })
    expect(sa.get_list_values).to eq [[100]]
  end

  it 'should infer the values from other tokens there' do
    sa = SysreqAnalyzer.new(
      [
        ['intel4000', 'year2005'],
        ['intel4000', 'year2005'],
        ['intel5000', 'year2005'],
        ['intel6000', 'year2005']
      ], {
      'intel4000' => 100,
      'intel5000' => 120,
      'intel6000' => 150,
    })

    expect(sa.tokens).to eq({
      'intel4000' => 100,
      'intel5000' => 120,
      'intel6000' => 150,
      'year2005'  => (100+100+120+150).to_f / 4
    })
  end

  it 'should link wildcards to the averages of other tokens' do
    sa = SysreqAnalyzer.new([['intel4xxx']], {
      'intel4000' => 300,
      'intel4400' => 500
    })

    expect(sa.tokens).to eq({
      'intel4xxx' => 400
    })
  end

  it 'should project numeric-based tokens that could not be inferred' do
    sa = SysreqAnalyzer.new(
      [
        ['aaa', 'directx8', 'year2004', '1000x2000'],
        ['bbb', 'directx9'],
        ['bbb', 'directx9'],
        ['ccc', 'directx10', 'year2007'],
        ['ddd', 'directx11', '1000x3000'],
        ['directx7', 'year2005', '1000x1000'],
      ], {
      'aaa' => 229,
      'bbb' => 1213,
      'ccc' => 1714,
      'ddd' => 2227
    })

    slr = SimpleLinearRegression.new [11, 10, 9, 9, 8], [2227, 1714, 1213, 1213, 229]

    expect(sa.tokens['directx7'].round).to eq(
      (slr.y_intercept + slr.slope * 7).round
    )

    slr = SimpleLinearRegression.new [2004, 2007], [229, 1714]
    expect(sa.tokens['year2005'].round).to eq(
      (slr.y_intercept + slr.slope * 2005).round
    )

    slr = SimpleLinearRegression.new [1000*2000, 1000*3000], [229, 2227]
    expect(sa.tokens['1000x1000'].round).to eq(
      (slr.y_intercept + slr.slope * (1000*1000)).round
    )
  end
end
