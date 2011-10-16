# encoding: utf-8

$variables = Hash.new

def tokenize(line)
  temp = line.split()
  tokens = Array.new
  temp.each do |word|
    if(word =~ /\(/)
      tokens.push($&)
      tokens.push($')
    elsif(word =~ /\)+/)
      tokens.push($`)
      $&.each_char{|char| tokens.push(char)}
    else
      tokens.push(word)
    end
  end
  tokens
end

def parse(tokens)
  contents = tokens[1...(tokens.length-1)]
  while contents.include?("(")
    left = contents.index("(")
    num = 1
    right = left #right"("の位置ではないけど暫定的に
    while true
      right = contents[(right+1)...(contents.length)].index(")") + right + 1
      break if num == contents.slice(left,right).find_all{|ch|ch=="("}.length
      num += 1
    end
    inner_contents = contents.slice!(left..right)
    contents[left,0] = parse(inner_contents)
  end
  if contents[0] == "define"
    unless $variables.has_key?(contents[1].downcase.intern)
      $variables[contents[1].downcase.intern] = eval(contents[2].to_s)
    end
  end
  if contents[0] == "set!"
    if $variables.has_key?(contents[1].downcase.intern)
      $variables[contents[1].downcase.intern] = eval(contents[2].to_s)
    end
  end
  if contents[0] == "+"
    return contents[1...(contents.length)].inject(0){|sum, i| sum + parse([i]) }
  end
  if contents[0] == "-"
    return 2 * parse([contents[i]]) - contents[1...(contents.length)].inject(0){|sum, i| sum + parse([i]) }
  end
  if contents[0] == "*"
    return contents[1...(contents.length)].inject(1){|sum, i| sum * parse([i]) }
  end
  if contents[0] == "/"
    return parse([contents[1]]) * parse([contents[1]]) / contents[1...(contents.length)].inject(1){|sum, i| sum * parse([i]) }
  end
  if tokens[0] =~ /-?[1-9][0-9]*/ or tokens[0] == "0" or tokens[0] =~ /-?[1-9][0-9]*\.[0-9]+/ or tokens =~ /-?0\.[0-9]+/
    return tokens[0].to_f
  elsif tokens[0].class.ancestors.include?(Numeric)
    return tokens[0]
  else
    return $variables[tokens[0].downcase.intern]
  end
end


while(print "> "; line = gets)
  out = parse(tokenize(line))
  p out unless out.nil?
end
