do 
    local _error = error  -- save the original

_G.error = function(msg, level)
    -- do whatever you want here (log, format, add traceback, etc.)
    local full = (msg or "") .. "\n" .. debug.traceback("", (level or 1) + 1)
    printErr(full)  -- re-raise with the original
end 
end  
print("FoxBrew Is Initializing lua overrides")
--app.innerHTML = "<h1 style='font-size:50pt'>Getting Closer</h1>" .. app.innerHTML
_G.io.open = function(path, mode)
    local stream = {
        _handle = {p = path, m = mode, i=0},
        read = function(self, method)
            if self._handle.m == "r" then
                if method == "*all" or method == "a" then
                    return fs.readFile(self._handle.p):await()
                elseif method == "l" then
                    if not self._handle.bufffer then
                        self._handle.bufffer = fs.readFile(self._handle.p):await():split("\n")
                        self._handle.i = 1
                    end
                    self._handle.i =  self._handle.i + 1
                    return self._handle.buffer[self._handle.i - 1]
                end
            elseif self._handle.m == "rb" then
                if type(method) == "number" then
                    local data = fs.readFile(self._handle.p):await()
                    self._handle.i = self._handle.i + (method + 1)
                    return data:sub(self._handle.i - method, self.handle.i - 1)
                end
            else
                error('stream not in read mode', 3)
            end
        end,
        write = function (self, data)
            if self._handle.m:sub(1, 1) == "w" then
                if not self._handle.bufffer then
                    self._handle.bufffer = data
                else
                    self._handle.bufffer = self._handle.bufffer .. data
                end
            end
        end,
        flush = function(self)
            if self._handle.m:sub(1, 1) == "w" then
                fs.writeFile(self._handle.bufffer):await()
            end
        end,
        close = function(self)
            self:flush()
            self._handle = nil
        end
    }
    return stream
end
_G.loadfile = function(path, mode, env)
    local f = io.open(path, "r")
    local tb = table.pack(load(f:read("a"), "=" .. path, mode, env or _G))
    f:close()
    return table.unpack(tb, 1)
end
_G.dofile = function (path, ...)
    local f, r = loadfile(path, "t", _ENV)
    if not f then
        error("Failed To Execute Script " .. path .. ": " .. r, 2)
    else
        local tb = table.pack(pcall(f, ...))
        if tb[1] then
            return table.unpack(tb, 2)
        end
        error("Error In Scipt " .. path .. ": " .. tb[2], 2)
    end
end
DOCUMENT.getElementById("splash").innerHTML = "<h1> Booting... </h1>"
print("Starting...")
dofile("OS/class.lua")
term.loadAddon(RL)
Shell = dofile("/OS/lfsh.lua")
Shell.BinaryPaths = {
    "/OS/bin",
}
local doClear = false
Shell.callback = function(cmd, args)
    if cmd == "source" then
        --here i add the source command
    elseif cmd == "echo" then
        local a = ""
        for _, v in ipairs(args) do
            a = a .. v .. " "
        end
        term.writeln(a)
    elseif cmd == "clear" then
        doClear = true
    else
        found = false
        for i, v in ipairs(Shell.BinaryPaths) do
           if fs.exists(v .. "/" .. cmd .. ".lfar"):await() then
                --run lfar here
                found = true
                term.writeln("lfar execution is comming soon")
           elseif fs.exists(v .. "/" .. cmd .. ".lua"):await() then
                found = true
                local ok, r = pcall(dofile, v .. "/" .. cmd .. ".lua", table.unpack(args, 1))
                if not ok then
                    term.writeln(cmd .. ": " .. r)
                end
            elseif fs.exists(v .. "/" .. cmd .. ".sh"):await() then
                found = true
                Shell.Source(fs.readFile(v .. "/" .. cmd, ".sh"):await(), Shell.callback)
           end 
        end
        if not found then
            term.writeln(cmd .. ": Command Not Found")
        end
    end
end
term.writeln("Warning: Currently In Pre Alpha Incomplete")
dofile("OS/FB_BOOT.lua")