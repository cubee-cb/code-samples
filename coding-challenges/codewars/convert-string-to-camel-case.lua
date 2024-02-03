-- takes a string as imput and returns it as camelCase, using - and _ as delimeters. capital starting letters are retained as PascalCase.
return function(str)
  local out=""
  local i=1
  while i<=#str do
    -- get character
    local char=str:sub(i,i)
    
    -- if it's a dash, find the next character and make it uppercase
    while char=="-" or char=="_" do
      i=i+1
      char = str:sub(i,i):upper()
    end

    -- add the character
    out=out..(char or "")
    
    i=i+1
  end
  
  return out
end