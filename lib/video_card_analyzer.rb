class VideoCardAnalyzer
  W = {
    nvidia_deco: /(?:ti|gtx|gts|gt|gs|mx|fx|tm| )/,
    nvidia_number: /([0-9]+x*m?)/,
    amd_number: /x?m?([0-9]+(?:x{2,})?m?)x?/, # Allow xx but not x at the end of number
    amd_deco: /(?:hd|r5|r7|r9|rage| )/,
    intel_number: /i?([0-9]+)/,
    intel_deco: /(?:hd|iris|gma|mhd| )/,
  }

  REJECT_WORDS = [
    /\bshader model ?[0-9](\.[0-9])?\b/,
    /\b(1st|2nd|3rd|4th|5th)\b/,
    /\b(gen|pro|graphics|media|accelerator|core|series|gpu)\b/,
  ]

  VALID_TOKENS = [
    /nvidia/,
    /[0-9]+(mb|gb|kb|mhz|ghz)/,
    /amd/,
    /intel/,
    /\bdirectx[0-9]{0,2}\b/,
    /\bopengl[0-9]?\b/,
    /\b[0-9]+x[^0][0-9]+\b/,
    /\bintegrated\b/,
    /\bnegation\b/
  ]

  INVALID_TOKENS = [
    /[0-9]{2,}gb/,
    /[0-9]{5,}mb/
  ]

  GSUBS = [
    # Units
    [/mbytes?/, 'mb'],
    [/\b([a-z]*)([0-9]+) ?(mb|gb|kb|mhz|ghz)/, '\2\3'],
    [/([0-9]+(?:mb|gb|kb|mhz|ghz))/, '<\1>'],
    [/([0-9x]+) (hd)/, '\1'],
    [/(hd) ([0-9x]+)\b/, '\2'],

    # Resolutions
    [/\b(?:([0-9]+)x([0-9]+)|([0-9]+) x ([0-9]+))\b(?! textures)/, '<\1\3x\2\4>'],

    # Nvidia
    [/geforece/, 'geforce'],
    [/nvidia( ?geforce)?/, 'nvidia'],
    [/geforce/, 'nvidia'],
    [/(nvidia[0-9]*)#{W[:nvidia_deco]}*#{W[:nvidia_number]}(?:\b|#{W[:nvidia_deco]})/, '\1\2 '],

    # AMD
    [/\bati( amd)?|amd( ati)?\b/, 'amd'],
    [/amd radeon/, 'amd'],
    [/radeon/, 'amd'],
    [/(amd)#{W[:amd_deco]}*#{W[:amd_number]}(?:\b|#{W[:amd_deco]})/, '\1\2 '],

    # Intel
    [/(intel[0-9]*)#{W[:intel_deco]}*#{W[:intel_number]}(?:\b|#{W[:intel_deco]})/, '\1\2 '],
    [/\bi([357])\b/, 'intel\1'],

    # Tech
    [/direct ?x ?([0-9]+)/, 'directx\1 '],
    [/dx([0-9]+)/, 'directx\1 '],
    [/opengl ?([0-9])[^d]/, 'opengl\1 '],

    # Negations
    [/\bnot supported\b/, 'negation'],
    [/\bnot recommended\b/, 'negation'],
    [/\bnot be supported\b/, 'negation'],
  ]

  def tokens(str)
    unsorted_tokens_count(str).keys
  end

  def tokens_count(str)
    Hash[unsorted_tokens_count(str).sort_by{|a, b| b}]
  end

  def unsorted_tokens_count(str)
    tokens = {}

    str = str
      .downcase
      .gsub(/([0-9]+)(\.[0-9]+)/, '\1')
      .gsub(/[^a-z0-9 ]/i, ' ')
      .squeeze(' ')

    REJECT_WORDS.each do |m|
      # L str
      str = str.gsub(m, ' ').squeeze(' ')
    end

    GSUBS.each do |m|
      # L str
      str = str.gsub(m[0], m[1]).squeeze(' ')
    end

    str.gsub(/<|>/, ' ').squeeze(' ').split(/\s+/).each do |word|
      if VALID_TOKENS.any?{ |m| word =~ m } and not INVALID_TOKENS.any?{ |m| word =~ m }
        word = round_data_units(word)
        tokens[word] ||= 0
        tokens[word] += 1
      end
    end

    tokens_list = tokens.keys
    not_i = tokens_list.find_index('negation')
    if not_i
      if not_i < tokens_list.size-1
        tokens_list[not_i..-1].each{ |token| tokens.delete(token)}
      else
        tokens.delete(tokens_list[not_i-1])
      end
      tokens.delete('negation')
    end

    tokens
  end

  def round_data_units(token)
    if ( m = token.match(/([0-9]+)(mb|gb)/) )
      val = m[1].to_i
      unit = m[2]
      if unit == 'gb'
        val = val * 1024
      end

      n = 5
      n += 1 while val > 2**n

      if (2**n - val) - (val - 2**(n-1)) > 0
        val = 2**(n-1)
      else
        val = 2**n
      end

      "#{val}mb"
    else
      token
    end
  end
end
