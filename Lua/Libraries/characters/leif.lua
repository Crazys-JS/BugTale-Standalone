_LEIF_REGISTER = {};
_LEIF_REGISTER.ID = 1;

--[[ Targets specifiers:

    ALLIES,
    ALIVEALLIES,
    DOWNEDALLIES,
    OTHERALLIES,
    ENEMIES,
    AUTO -- No target selection on AUTO.
]]--

_LEIF_REGISTER.AbilityRegistry = {
    ["L-Action"] = {
        Name = "L-Action",
        DisplayName = "[color:0094FF]* L-Action[color:FFFFFF]",
        TPCost = 0,
        Target = "ENEMIES",
        OnExecuted = function()
            local scr = BugTaleCharacters.GetEnemyScript(BugTaleCharacters.TargetSelected);
            if scr.GetVar("HandleSpecialActionMessages") then
                scr.Call("HandleSpecialActionMessages", BugTaleCharacters.CurrentActor);
            else
                BattleDialog("Leif tried some things...[w:15]\nBut the enemy didn't care.");
            end
        end
    },
    Icefall = {
        Name = "Icefall",
        DisplayName = "* Icefall",
        Description = "Medium damage to all enemies.",
        TPCost = 16,
        Target = "AUTO",
        OnExecuted = function()
            local aliveEnemies = 0;
            for i, x in pairs(enemies) do
                if x.GetVar("isactive") then
                    aliveEnemies = aliveEnemies + 1
                end
            end
    
            local attacks = {};
            for i=1, aliveEnemies do
                table.insert(attacks, {i, Player.atk})
            end
    
            BugTaleLibrary.CreateAttacks(attacks)
        end
    },
    ["Frigid Coffin"] = {
        Name = "Frigid Coffin",
        DisplayName = "* F. Coffin",
        Description = "High damage to an enemy.",
        TPCost = 16,
        Target = "ENEMIES",
        OnExecuted = function()
            BugTaleLibrary.CreateAttacks({{BugTaleLibrary.TargetSelected, Player.atk * 2}})
        end
    }
}

_LEIF_REGISTER.UnlockedSkills = {};

for i,x in pairs(_LEIF_REGISTER.AbilityRegistry) do
    table.insert(_LEIF_REGISTER.UnlockedSkills, i);
    BugTaleCharacters.RegisterActionProperty(x)
end

function _LEIF_REGISTER.Register(xPos)
    _LEIF_REGISTER.ID = BugTaleLibrary.CreateActor("Leif", {0,148,255}, 7, "Leif", "leif", xPos, _LEIF_REGISTER.UnlockedSkills);
    BugTaleCharacters.SetActorAttack(_LEIF_REGISTER.ID, "Ice")
end

return _LEIF_REGISTER

