local Environment = require(script.Environment)
local Rules = require(script.Rules)
local Queries = require(script.Queries)
local Reflection = require(script.Reflection)

local Chlorine = {
	Environment = Environment;
	Rules = Rules;
	Queries = Queries;
	Reflection = Reflection;
}

return table.freeze(Chlorine)