local combatLog = io.open("WoWCombatLog.txt", "r")
local parsedLog = io.open("log.lua", "w")

parsedLog:write("CombatSimLog = {\n")

local matchSpells = {
	["Gravity Bomb"] = "Gravity Bomb",
	["Light Bomb"] = "Light Bomb",
	["Searing Light"] = "Searing Light",
}

local id = 1
for line in combatLog:lines() do
	for spell in pairs(matchSpells) do
		if( string.match(line, spell) ) then
			parsedLog:write(string.format("	[%d] = [[%s]],\n", id, line))
			id = id + 1
			print(line)
		end
	end
end

parsedLog:write("}")
parsedLog:flush()
parsedLog:close()
combatLog:close()