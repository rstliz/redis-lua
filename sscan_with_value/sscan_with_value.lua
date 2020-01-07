local unpack = unpack or table.unpack
local function map(fn, tbl, ...)
  local a = {}
  for i = 1, #tbl do
    table.insert(a, fn(tbl[i], ...))
  end
  return a
end

local function zip(l, m)
    local n = {}
    for i, v in ipairs(l) do
        n[i] = {v, m[i]}
    end
    return n
end

local function hash(tbl)
    if #tbl %2 ~= 0 then return {} end

    local n = {}
    for i, v in ipairs(tbl) do
	if i %2 == 0 then
           local key = tbl[i-1]
           n[key] = v 
        end
    end
    return n
end

local function unhash(tbl)
    local n = {}
    for k, v in pairs(tbl) do
        table.insert(n, k)
        table.insert(n, v)
    end
    return n
end

local function slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end
    
local function add_prefix(v,prefix) return prefix .. v end

-- local argv_hash = hash(map(string.upper, ARGV))
local argv_hash = hash(ARGV)
local t_sscan_arg = {COUNT =  10, MATCH = '*'}
t_sscan_arg['COUNT'] = argv_hash['COUNT'] and argv_hash['COUNT']
t_sscan_arg['MATCH'] = argv_hash['MATCH'] and argv_hash['MATCH']
local value_prefix = argv_hash['V_PREFIX'] and argv_hash['V_PREFIX'] or ""

local t_scan = redis.call('SSCAN', KEYS[1], KEYS[2], unpack(unhash(t_sscan_arg)))

if next(t_scan[2]) then
    local t_bidp = map(add_prefix, t_scan[2], value_prefix)
    local c = 0
    local merged = {}
    local inc = 5000 
    while 1 do 
        local sliced = slice(t_bidp, c+1, c+inc)
	if not next(sliced) then break end
    	local values = redis.call('MGET', unpack(sliced))
        for i,v in ipairs(values) do merged[c + i] = v end
	c = c + inc 
    end
    return {t_scan[1], zip(t_scan[2], merged)}
else
    return {t_scan[1], {}}
end
