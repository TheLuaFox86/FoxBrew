local vars = {}

local function expand(s)
  -- ${var} first (braced, unambiguous)
  s = (s:gsub("%${(%w+)}", vars))
  -- then $var (greedy — matches longest word, bash-style)
  s = (s:gsub("%$(%w+)", vars))
  return s
end

local function tokenize(line)
  local args = {}
  local i = 1
  local len = #line

  while i <= len do
    local c = line:sub(i, i)

    if c:match("%s") then
      i = i + 1
    else
      local buf = {}
      local token = false

      while i <= len do
        local c = line:sub(i, i)

        if c:match("%s") then break end

        if c == "\\" then
          -- escape: take next char literally
          i = i + 1
          if i <= len then
            buf[#buf + 1] = line:sub(i, i)
            i = i + 1
          end
          token = true

        elseif c == '"' then
          i = i + 1
          local q = {}
          while i <= len and line:sub(i, i) ~= '"' do
            if line:sub(i, i) == "\\" and (i + 1 <= len) and line:sub(i+1, i+1):match("[\"\\\\$`]") then
              -- inside double quotes: only \" \\ \$ \` are special
              q[#q + 1] = line:sub(i+1, i+1)
              i = i + 2
            else
              q[#q + 1] = line:sub(i, i)
              i = i + 1
            end
          end
          i = i + 1
          buf[#buf + 1] = expand(table.concat(q))
          token = true

        elseif c == "'" then
          i = i + 1
          local q = {}
          while i <= len and line:sub(i, i) ~= "'" do
            q[#q + 1] = line:sub(i, i)
            i = i + 1
          end
          i = i + 1
          buf[#buf + 1] = table.concat(q)
          token = true

        else
          buf[#buf + 1] = c
          i = i + 1
          token = true
        end
      end

      if token then
        args[#args + 1] = expand(table.concat(buf))
      end
    end
  end

  return args
end

local function run(line, callback)
  line = line:match("^%s*(.-)%s*$")
  if line == "" then return end

  local name, val_str = line:match("^(%w+)=(.*)$")
  if name then
    local val = tokenize(val_str)
    if #val == 1 then
      vars[name] = val[1]
      return
    end
  end

  local tokens = tokenize(line)
  local cmd, args = tokens[1], {}
  for i = 2, #tokens do args[i - 1] = tokens[i] end
  callback(cmd, args)
end   
return {
    run = run,
    Source = function(self, full, callback)
        for _, line in ipairs(full:split("\n")) do
            self.run(line, callback)
        end
    end
}