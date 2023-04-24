_KABBU_REGISTER = {};

--[[ Targets specifiers:

    ALLIES,
    ALIVEALLIES,
    DOWNEDALLIES,
    OTHERALLIES,
    ENEMIES,
    AUTO -- No target selection on AUTO.
]]--

_KABBU_REGISTER.AbilityRegistry = {
    Taunt = {
        Name = "Taunt",
        DisplayName = "* Taunt",
        Description = "Make enemies target you.",
        TPCost = 16,
        Target = "AUTO",
        OnExecuted = function()
            BugTaleLibrary.SetTargets({BugTaleCharacters.CurrentActor})
            BattleDialog("All enemies will target Kabbu on the next attack!")
        end,
        ConditionCheck = function()
            return not BugTaleLibrary.TargetNext;
        end,
        BeforeMenu = function()
            if(BugTaleLibrary.TargetNext) then
                _KABBU_REGISTER.AbilityRegistry.Taunt.DisplayName = "[color:FFFF00]* --ACTIVE--[color:FFFFFF]"
            else
                _KABBU_REGISTER.AbilityRegistry.Taunt.DisplayName = "* Taunt"
            end
        end
    },
    ["Heavy Strike"] = {
        Name = "Heavy Strike",
        DisplayName = "* Heavy Strike",
        Description = "High damage to one enemy.",
        TPCost = 16,
        Target = "ENEMIES",
        OnExecuted = function()
            BugTaleLibrary.CreateAttacks({{BugTaleLibrary.TargetSelected, Player.atk * 2}})
        end
    },
    ["Pep Talk"] = {
        Name = "Pep Talk",
        DisplayName = "* Pep Talk",
        Description = "Revive ally.",
        TPCost = 50,
        Target = "DOWNEDALLIES",
        OnExecuted = function()
            local name = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected].Name;
            BattleDialog("[noskip]Kabbu inspires his fallen ally...\n[w:1][func:ReviveActor,{"..BugTaleLibrary.TargetSelected ..",4}][noskip:off]" ..name .." got up with 4 HP!")
        end
    }
}

_KABBU_REGISTER.UnlockedSkills = {}

for i,x in pairs(_KABBU_REGISTER.AbilityRegistry) do
    table.insert(_KABBU_REGISTER.UnlockedSkills, x.Name)
    BugTaleCharacters.RegisterActionProperty(x)
end

function _KABBU_REGISTER.Register(xPos)
    _KABBU_REGISTER.ID = BugTaleLibrary.CreateActor("Kabbu", {0,127,14}, 9, "Kabbu", "kabbu", xPos, _KABBU_REGISTER.UnlockedSkills);
    BugTaleCharacters.SetActorAttack(_KABBU_REGISTER.ID, "Slash")
end

return _KABBU_REGISTER