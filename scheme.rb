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
  if contents.include?("(")
    first = contents.index("(")
    last = contents.length - contents.reverse.index(")") - 1
    inner_contents = contents.slice!(first..last)
    contents[first,0] = parse(inner_contents)
  end
  if contents[0] == "define"
    unless $variables.has_key?(contents[1].intern)
      $variables[contents[1].intern] = eval(contents[2])
    end
  end
  if contents[0] == "set!"
    if $variables.has_key?(contents[1].intern)
      $variables[contents[1].intern] = eval(contents[2].to_s)
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
  if tokens[0] =~ /[1-9][0-9]*/ or tokens[0] == "0" or tokens[0] =~ /[1-9][0-9]*\.[0-9]+/ or tokens =~ /0\.[0-9]+/
    return tokens[0].to_f
  else
    return $variables[tokens[0].intern]
  end
end


while(print "> "; line = gets)
  out = parse(tokenize(line))
  p out unless out.nil?
end
