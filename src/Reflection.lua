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

Reflection.Methods = {
	__index,
	__newindex,
	__concat,
	__unm,
	__add,
	__sub,
	__mul,
	__div,
	__idiv,
	__mod,
	__pow,
	__tostring,
	__eq,
	__lt,
	__le,
	__len,
	__iter,
}

function Reflection:wrap(PROXY_DATA: any, callFunctionTransformed: (...any) -> ...any)
	local ProxyReflection = {}
	function ProxyReflection.__index(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __index, table.pack(data._target, ...))
	end
	function ProxyReflection.__newindex(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __newindex, table.pack(data._target, ...))
	end
	function ProxyReflection.__call(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, data._inputMode, data._target, table.pack(...))
	end
	function ProxyReflection.__concat(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __concat, table.pack(data._target, ...))
	end
	function ProxyReflection.__unm(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __unm, table.pack(data._target, ...))
	end
	function ProxyReflection.__add(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __add, table.pack(data._target, ...))
	end
	function ProxyReflection.__sub(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __sub, table.pack(data._target, ...))
	end
	function ProxyReflection.__mul(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __mul, table.pack(data._target, ...))
	end
	function ProxyReflection.__div(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __div, table.pack(data._target, ...))
	end
	function ProxyReflection.__idiv(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __idiv, table.pack(data._target, ...))
	end
	function ProxyReflection.__mod(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __mod, table.pack(data._target, ...))
	end
	function ProxyReflection.__pow(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __pow, table.pack(data._target, ...))
	end
	function ProxyReflection.__tostring(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __tostring, table.pack(data._target, ...))
	end
	function ProxyReflection.__eq(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __eq, table.pack(data._target, ...))
	end
	function ProxyReflection.__lt(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __lt, table.pack(data._target, ...))
	end
	function ProxyReflection.__le(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __le, table.pack(data._target, ...))
	end
	function ProxyReflection.__len(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __len, table.pack(data._target, ...))
	end
	function ProxyReflection.__iter(proxy, ...)
		-- Grab the data from the proxy
		local data = rawget(proxy, PROXY_DATA)
		-- Call the metamethod
		return callFunctionTransformed(data._environment, "forBuiltin", __iter, table.pack(data._target, ...))
	end
	return table.freeze(ProxyReflection)
end

return table.freeze(Reflection)