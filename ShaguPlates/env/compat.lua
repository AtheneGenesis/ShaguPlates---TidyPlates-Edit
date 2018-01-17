pfLocaleSpells = {}
pfLocaleSpellEvents = {}
pfLocaleSpellInterrupts = {}

pfLocale = GetLocale()
if pfLocale ~= "enUS" and
   pfLocale ~= "frFR" and
   pfLocale ~= "deDE" and
   pfLocale ~= "zhCN" and
   pfLocale ~= "ruRU" then
   pfLocale = "enUS"
end

function round(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end
