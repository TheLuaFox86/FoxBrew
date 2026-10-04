_G.string.split = function(str, del)
  local out = {}
local a = ''
local i = 1
for _=1, #str do
  if str:sub(i, i + (#del - 1)) == del then
    table.insert(out, a)
    a = ''
    i = i + #del
  else
    a = a .. str:sub(i, i)
    i = i + 1
  end 
end
table.insert(out, a)
return out
end
_G.argc = function(value, msg, lv, ...)
	for k, v in pairs({value, ...}) do
    if not v then
      error(msg, (lv or 3))
    else
      return value
    end
  end
end
_G.class =  {}
class._searchers = {
'lfrt',
}
class._types = {}
function class:addSearcher(name, place)
	local i = place
	if place == nil then
		i = #self._searchers + 1
	end
	self._searchers[i] = name
end
function class:append(tb)
	  argc(type(tb):match("ClassType "), "argument #1: expected ClassType got ", type(tb))
  if not self[tb.domain] then self[tb.domain] = {} end
  self[tb.domain][tb.type] = tb
  self._types[tb.type] = tb
end
function class:getById(t, id)
  argc(type(t) == "string", "argument #1: expected string got ", type(t))
  argc(type(id) == "string", "argument #2: expected string got ", type(t))
  local a = {}
  for i, v in ipairs(id:split(":")) do
    a[i]=v
  end
  if not a[2] then
  	a[2] = a[1]
    a[1] = self._searchers[1]
    for i=1, #self._searchers do
    	if self[self._searchers[i]] then
    		if self[self._searchers[i]][t] then
    			if self[self._searchers[i]][t][a[2]] then
    				a[1] = self._searchers[i]
    				break
    			end
    		end
    	end
    end
  end
  if not self[a[1]] then
    return nil
  elseif not self[a[1]][t] then
    return nil
  elseif not self[a[1]][t][a[2]] then
    return nil
  end
  local b = {}
  for k, v in pairs(self[a[1]][t][a[2]]) do
    b[k] = v
  end
  return b
end
function class:setById(t, id, val)
  argc(type(t) == "string", "argument #1: expected string got ", type(t))
  argc(type(id) == "string", "argument #2: expected string got ", type(t))
  argc(type(val):match("Class "), "argument #1: expected Class got ", type(t))
  local a = {}
  for i, v in ipairs(id:split(":")) do
    a[i]=v
  end
  if not a[2] then
    a[2] = a[1]
    a[1] = self._searchers[1]
    for i=1, #self._searchers do
    	if self[self._searchers[i]] then
    		if self[self._searchers[i]][t] then
    			if self[self._searchers[i]][t][a[2]] then
    				a[1] = self._searchers[i]
    				break
    			end
    		end
    	end
    end
  end
  if not self[a[1]] then
    self[a[1]] = {}
  end
  if not self[a[1]][t] then
    self[a[1]][t] = self._types[t]
  end
  self[a[1]][t][a[2]] = val
 end
function class:newType(id, tb)
  tb.domain = id:split(":")[1]
  tb.type = id:split(":")[2]
  tb.id = id
  log("creating classtype: " .. tb.type or "?")
  local out = setmetatable(tb, {__index = function(s, k)
    if k == id:split(":")[2] then
      return function(...)
        local a = tb.constructor(self, s, ...)
        local obj = setmetatable(a, {__index = function(_s, _k)
          if _k == "push" then
            return function()
              local c = {}
              for k, _ in pairs(_s) do
                c[k] = rawget(_s, k)
              end
              class:setById(tb.type, rawget(s, "id"), c)
            end 
          elseif _k == "pull" then
            return function()
                for k, v in pairs(class:getById(tb.type, rawget(s, "id"))) do
                  rawset(_s, k, v)
                end
            end
          else
            return rawget(_s, _k)
          end
        end, __newindex = function(_s, k, v)
            rawset(_s, k, v)
        end, __type="Class " .. id})
        class:setById(s.type, obj.id, obj)
        log('added class: ' .. obj.id .. ' of type [' .. id:split(':')[2] .. ']')
      end
    else
      return rawget(s, k)
  	end
  end, __type="ClassType " .. id})
  return out
end
function class:getAPI(id, version)
  local a = self:getById("api", id)
  if not a then
  	error('API not defined (API: ' .. id .. ' v' .. version, 2)
  end
  local b = a.VERSIONS[version]
  if not b then
  	error('API of that version not available (API: ' .. id .. ' v' .. version, 2)
  end
  b.version = version
  setmetatable(b, {__index=function(s, k)
    if k == "pull" then
      return function()
        s = _G.class:getById('api', id).VERSIONS[version]
      end
    elseif k == 'push' then
      return function()
        local c = _G.class:getById('api', id)
        local d = {}
        for _k, _v in pairs(s) do
          d[_k] = rawget(s, _k)
        end
        c.VERSIONS[version] = d
        _G.class:setById('api', id, c)
      end
    else
    	return rawget(s, k)
    end
  end, __newindex = function(s, k, v)
    rawset(s, k, v)
  end, __type="Class lfrt:api"})
  return b
end
function class:config(key)
	local cfg = {
		["Beta-Mode"] = false,
	}
	return cfg[key]
end
