-- Welcome to metatable hell
--  We hope you __enjoy your stay!

local Reflection = {}

local function __index(self, index)
	return self[index]
end
local function __newindex(self, index, value)
	self[index] = value
end
local function __concat(self, value)
	return self .. value
end
local function __unm(self)
	return -self
end
local function __add(self, other)
	return self + other
end
local function __sub(self, other)
	return self - other
end
local function __mul(self, other)
	return self * other
end
local function __div(self, other)
	return self / other
end
local function __idiv(self, other)
	return self // other
end
local function __mod(self, other)
	return self % other
end
local function __pow(self, other)
	return self ^ other
end
local function __tostring(self)
	return tostring(self)
end
local function __eq(self, other)
	return self == other
end
local function __lt(self, other)
	return self < other
end
local function __le(self, other)
	return self <= other
end
local function __len(self)
	return #self
end
local function __iter(self)
	return coroutine.wrap(function(_object)
		for first, second, third, fourth in self do
			if not rawequal(first, nil) then
				coroutine.yield(first, second, third, fourth)
			end
		end
	end), self
end

function Reflection:wrap(PROXY_DATA: any, callFunctionTransformed: (...any) -> ...any)
	local ProxyReflection = {}
	function ProxyReflection.__index(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __index, data._target, ...)
	end
	function ProxyReflection.__newindex(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __newindex, data._target, ...)
	end
	function ProxyReflection.__call(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, data._inputMode, data._target, ...)
	end
	function ProxyReflection.__concat(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __concat, data._target, ...)
	end
	function ProxyReflection.__unm(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __unm, data._target, ...)
	end
	function ProxyReflection.__add(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __add, data._target, ...)
	end
	function ProxyReflection.__sub(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __sub, data._target, ...)
	end
	function ProxyReflection.__mul(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __mul, data._target, ...)
	end
	function ProxyReflection.__div(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __div, data._target, ...)
	end
	function ProxyReflection.__idiv(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __idiv, data._target, ...)
	end
	function ProxyReflection.__mod(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __mod, data._target, ...)
	end
	function ProxyReflection.__pow(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __pow, data._target, ...)
	end
	function ProxyReflection.__tostring(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __tostring, data._target, ...)
	end
	function ProxyReflection.__eq(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __eq, data._target, ...)
	end
	function ProxyReflection.__lt(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __lt, data._target, ...)
	end
	function ProxyReflection.__le(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __le, data._target, ...)
	end
	function ProxyReflection.__len(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __len, data._target, ...)
	end
	function ProxyReflection.__iter(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __iter, data._target, ...)
	end
	return table.freeze(ProxyReflection)
end

return table.freeze(Reflection)