local Reflection = require(script.Parent.Reflection)

local PRIMITIVE_TYPES = table.freeze({
	["number"] = true;
	["string"] = true;
	["boolean"] = true;
	["nil"] = true;
	["vector"] = true;
	["buffer"] = true;
	["thread"] = true;
})

-- Proxy data symbol
local PROXY_DATA = newproxy(false)

-- Do nothing symbol
local DO_NOTHING = newproxy(false)

local Environment = {}
Environment.__index = Environment

local function addProxy(environment)
	environment._toProxy = setmetatable({}, {__mode="v"; __metatable="The metatable is locked."})
	environment._toTarget = setmetatable({}, {__mode="k"; __metatable="The metatable is locked."})
	environment._protectedThreads = setmetatable({}, {__mode="kv"; __metatable="The metatable is locked."})

	return environment
end

local function _clone(environment: Environment)
	local copy = table.clone(environment)
	assert(
		(not environment._toProxy or next(environment._toProxy) == nil)
		and (not environment._toTarget or next(environment._toProxy) == nil)
		and (next(environment._env) == nil),
		"Cannot clone a non-empty Environment"
	)
	return addProxy(copy)
end
local function defaultSubstitute()
	return DO_NOTHING
end
local function defaultInputMode()
	return nil
end
function Environment.new()
	local self = setmetatable({}, Environment)
	self._env = {}
	self._substitute = defaultSubstitute
	self._inputMode = defaultInputMode
	return table.freeze(addProxy(self))
end

function Environment:clone()
	return table.freeze(_clone(self))
end

function Environment:applyTo(functionToBind: (...any) -> ...any): (...any) -> ...any
	return assert(setfenv(functionToBind, (assert(self._env, "Environment is not initialized. Call Environment:withFenv(globals) to initialize it."))))
end

export type proxyable = {[any]: any} | (...any) -> ...any

local MetamethodProxies = {}
for _, method in Reflection.Methods do
	MetamethodProxies[method] = true
end

local callFunctionTransformed
local proxyFunction
local function getErrorTraceback(value: any, prependInfo: boolean)
	-- A C function followed by a callFunctionTransformed indicates this was an error from a callFunctionTransformed
	local currentLevel = 2
	if debug.info(3, "s") == "[C]" and rawequal(debug.info(4, "f"), callFunctionTransformed) then
		currentLevel = 4
	end

	local traceback = {
		"",
		"Stack Begin",
	}
	-- Go over every level to create a traceback
	while true do
		currentLevel += 1

		-- Get the info for the current level
		local identifier, line, name, func = debug.info(currentLevel, "slnf")

		-- If the function doesn't exist then the end has been reached
		if func == nil then
			break
		end

		-- Ignore proxy functions
		if func == callFunctionTransformed then
			continue
		end
		if func == proxyFunction then
			currentLevel += 1
			continue
		end
		if MetamethodProxies[func] then
			continue
		end

		-- Ignore any C functions in the traceback
		if identifier == "[C]" then
			continue
		end

		-- Prepend script and line info if needed
		if prependInfo then
			prependInfo = false
			if type(value) == "string" then
				value = string.format("%s:%d: %s", tostring(identifier), tonumber(line) or 0, value)
			end
		end

		-- Insert the formatted line
		-- A script's main thread has an empty string for a name
		if name and name ~= "" then
			table.insert(
				traceback,
				string.format("Script '%s', Line %d - function %s", tostring(identifier), tonumber(line) or 0, tostring(name))
			)
		else
			table.insert(
				traceback,
				string.format("Script '%s', Line %d", tostring(identifier), tonumber(line) or 0)
			)
		end
	end

	traceback[1] = if rawequal(value, nil) then "Error occurred, no output from Lua." else tostring(value)
	-- Apply the traceback string
	table.insert(traceback, "Stack End\n\nNOTE: The below traceback may be incorrect. See above for an accurate stack trace.")
	return table.concat(traceback, "\n"), value
end

-- Wraps all values in the list into proxies
local function wrapList(environment: Environment, list: {n: number, [number]: any}, inputMode: ("forLua" | "forBuiltin")?)
	for i=1, list.n do
		list[i] = environment:wrap(list[i], inputMode)
	end
end
-- Unwraps all values in the list into their proxy targets
local function unwrapList(environment: Environment, list: {n: number, [number]: any})
	for i=1, list.n do
		list[i] = environment:unwrap(list[i])
	end
end

-- Calls a function and transforms its inputs as specified by inputMode, and its outputs into proxies
function callFunctionTransformed(
	self: Environment,
	inputMode: "forLua" | "forBuiltin",
	target: (...any) -> (...any),
	args: {n: number, [number]: any}
)
	-- Get current thread
	local thread = coroutine.running()

	-- Convert all input arguments either to their wrapped values, or their targets depending on the input mode
	if inputMode == "forLua" then
		wrapList(self, args)
	elseif inputMode == "forBuiltin" then
		unwrapList(self, args)
	else
		error(string.format("Invalid inputMode %s", inputMode), 2)
	end

	-- Mark this thread as protected if it isn't
	local protectedThreads = self._protectedThreads
	local isUnsafe = protectedThreads[thread] == nil
	if isUnsafe then
		protectedThreads[thread] = ""
	end

	-- Call the target and collect all results
	local results = table.pack(xpcall(target, function(err: any)
		-- A C function followed by a callFunctionTransformed indicates this was an error from a callFunctionTransformed
		if debug.info(2, "s") == "[C]" and rawequal(debug.info(3, "f"), callFunctionTransformed) then
			-- Pass the error through, the traceback has already been handled
			return err
		end

		-- Add line info to string error messages
		local prependInfo = false
		if type(err) == "string" then
			prependInfo = true

			-- Attempt to remove existing line info from builtins
			local _, match = string.find(err, ":%d+: ")
			if match then
				err = string.sub(err, match + 1)
			end
		end

		-- Create a new error object
		local traceback, value = getErrorTraceback(err, prependInfo)
		protectedThreads[thread] = traceback
		return value
	end, table.unpack(args, 1, args.n)))

	-- If the call failed, bubble the error
	local success, result = table.unpack(results, 1, 2)
	if not success then
		local message = protectedThreads[thread]

		-- Bubble the result down if the thread was protected
		-- Otherwise, mark this thread as no longer safe and give a traceback error
		if isUnsafe then
			protectedThreads[thread] = nil
			error(message, -1)
		else
			error(result, -1)
		end
	end

	-- Mark this thread as unprotected if this function call marked it as protected
	if isUnsafe then
		protectedThreads[thread] = nil
	end

	-- Convert all outputs to wrapped values
	wrapList(self, results)

	-- Unpack results
	return table.unpack(results, 2, results.n)
end

-- Create reflection for proxies
local ProxyReflection = Reflection:wrap(PROXY_DATA, callFunctionTransformed)

-- Calls a function for the given environment, inputMode, and arguments
function proxyFunction(environment: Environment, inputMode: "forLua" | "forBuiltin", target: (...any) -> ...any, ...: any)
	-- Ensure that all arguments get wrapped, even if a C function is being called
	local args = table.pack(...)
	wrapList(environment, args)

	-- Call the function
	return callFunctionTransformed(environment, inputMode, target, args)
end

-- Creates a proxy targeting a particular value
function Environment:wrap(target: proxyable, inputMode: ("forLua" | "forBuiltin")?): proxyable
	-- Check if the target is a primitive
	if PRIMITIVE_TYPES[type(target)] then
		return target
	end

	-- Check if the target is already proxied
	if self._toProxy[target] then
		return self._toProxy[target]
	end
	if not rawequal(self._toTarget[target], nil) then
		return target
	end

	-- Substitute value
	local substitution = self._substitute(target, DO_NOTHING)
	if not rawequal(substitution, DO_NOTHING) then
		target = substitution
	end

	-- Replace the inputMode
	inputMode = self._inputMode(target) or inputMode

	-- If the target is a function, use forBultin if its a CFunction
	if not inputMode and type(target) == "function" then
		inputMode = if debug.info(target, "s") == "[C]" then "forBuiltin" else inputMode
	end

	-- If the inputMode is default, use forLua
	if not inputMode then
		inputMode = "forLua"
	end

	-- Create and freeze proxy
	local proxy
	if type(target) == "function" then
		-- A function proxy is used so it can be passed to C functions
		proxy = function(...: any)
			-- Call the function while wrapping its arguments
			return proxyFunction(self, inputMode, target, ...)
		end

		-- Map the target to the proxy
		self._toProxy[target] = proxy
	elseif
		inputMode ~= "forBuiltin"
		and type(target) == "table"
		and not table.isfrozen(target)
		and rawequal(getmetatable(target :: any), nil)
	then
		-- Convert mutable tables into proxies themselves
		-- This way, any references to the table before it was sandboxed are preserved
		-- Tables that are already frozen or have a metatable must have been created externally

		-- Map the proxy and newly created target to each other
		-- This must be done now, as if the table is recursive then this will resolve any cycles
		proxy = target
		target = {}
		self._toTarget[proxy] = target
		self._toProxy[target] = proxy

		-- Copy the values of the target into the new one
		for key, value in pairs(proxy) do
			-- Wrap and unwrap the keys to ensure any function or table transformations occur
			target[self:unwrap(self:wrap(key))] = self:unwrap(self:wrap(value))

			-- Remove it from the old target
			proxy[key] = nil
		end

		-- Transform the old target into a proxy
		proxy[PROXY_DATA] = table.freeze({
			_inputMode = inputMode;
			_target = target;
			_environment = self;
		})
		setmetatable(proxy, ProxyReflection)
		table.freeze(proxy)
	else
		-- Regular proxy for objects
		proxy = table.freeze(setmetatable({
			[PROXY_DATA] = table.freeze({
				_inputMode = inputMode;
				_target = target;
				_environment = self;
			})
		}, ProxyReflection))

		-- Map the proxy and target to each other
		self._toTarget[proxy] = target
		self._toProxy[target] = proxy
	end

	return proxy
end

function Environment:unwrap(target: proxyable)
	-- Check if the target is a primitive
	if PRIMITIVE_TYPES[type(target)] then
		return target
	end

	local unwrapped = self._toTarget[target]
	if not rawequal(unwrapped, nil) then
		return unwrapped
	end
	return target
end

function Environment:withFenv<K, V>(globals: {[K]: V})
	local newEnvironment = _clone(self)
	newEnvironment._env = newEnvironment:wrap(globals)
	return table.freeze(newEnvironment)
end

function Environment:withSubstitute(substitute: (any, any) -> any)
	local newEnvironment = _clone(self)
	newEnvironment._substitute = substitute
	return table.freeze(newEnvironment)
end

function Environment:withInputMode(inputMode: (unknown) -> ("forLua" | "forBuiltin", boolean))
	local newEnvironment = _clone(self)
	newEnvironment._inputMode = inputMode
	return table.freeze(newEnvironment)
end

export type Environment = typeof(Environment.new())
return table.freeze(Environment)