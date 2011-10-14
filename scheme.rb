# encoding: utf-8

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
  p contents
  if contents[0] == "+"
    return contents[1...(contents.length)].inject(0){|sum, i| sum + i.to_i }
  end
  if contents[0] == "-"
    return 2 * contents[1].to_i - contents[1...(contents.length)].inject(0){|sum, i| sum + i.to_i }
  end
  if contents[0] == "*"
    return contents[1...(contents.length)].inject(1){|sum, i| sum * i.to_i }
  end
  if contents[0] == "/"
    return contents[1].to_i * contents[1].to_i / contents[1...(contents.length)].inject(1){|sum, i| sum * i.to_i }
  end
end


while(print "> "; line = gets)
  p parse(tokenize(line))
end

