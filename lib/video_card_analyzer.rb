class VideoCardAnalyzer
  W = {
    nvidia_deco: /(gt|ti|gtx|gts|gs|mx|fx)/,
    nvidia_number: /([0-9]+x*m?)/,
    amd_number: /x?m?([0-9]+(?:x{2,})?m?)x?/, # Allow xx but not x at the end of number
    amd_deco: /(hd|r5|r7|r9|rage)/,
    intel_number: /i?([0-9]+)/,
    intel_deco: /(hd|iris|gma|mhd)/,
  }

  REJECT_WORDS = [
    /\bshader model ?[0-9.]+\b/,
    /\b(of|or|and)\b/,
    /\b(1st|2nd|3rd|4th|5th)\b/,
    /\b(gen|pro|graphics|media|accelerator|core|series|gpu)\b/,
  ]

  VALID_WORDS = [
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

  GSUBS = [
    # Units
    [/mbytes?/, 'mb'],
    [/\b([a-z]*)([0-9]+) ?(mb|gb|kb|mhz|ghz)/, '\2\3'],
    # [/([0-9]+)(\.[0-9]+)? ?(mb|gb|kb|mhz|ghz)/, '\1\3'],
    [/([0-9x]+) (hd)/, '\1'],
    [/(hd) ([0-9x]+)\b/, '\2'],

    # Nvidia
    [/(\b|[0-9])#{W[:nvidia_deco]}(\b|[0-9])/, '\1\3'],
    [/geforece/, 'geforce'],
    [/nvidia( ?geforce)?/, 'nvidia'],
    [/geforce/, 'nvidia'],
    [/nvidia#{W[:nvidia_deco]}/, 'nvidia'],
    [/(nvidia[0-9]?) ?#{W[:nvidia_number]}\b/, '\1\2'],

    # AMD
    [/(\b|[0-9])#{W[:amd_deco]}(\b|[0-9])/, '\1\3'],
    [/\bati( amd)?|amd( ati)?\b/, 'amd'],
    [/amd radeon/, 'amd'],
    [/radeon/, 'amd'],
    [/amd #{W[:amd_number]}\b/, 'amd\1'],

    # Intel
    [/(\b|[0-9])#{W[:intel_deco]}(\b|[0-9])/, '\1\3'],
    [/intel #{W[:intel_number]}\b/, 'intel\1'],
    [/\bi([357])\b/, 'intel\1'],

    # Resolutions
    [/\b([0-9]+) ?x ?([0-9]+)( ?x ?[0-9]+)?\b/, '\1x\2'],

    # Tech
    [/direct ?x ?([0-9]+)/, 'directx\1 '],
    [/dx([0-9])/, 'directx\1 '],
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
      str = str.gsub(m, ' ').squeeze(' ')
    end

    GSUBS.each do |m|
      L str
      str = str.gsub(m[0], m[1]).squeeze(' ')
    end


    str.split(/\s+/).each do |word|
      if VALID_WORDS.any?{ |m| word =~ m}
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
end
