_ZERO_REGISTER = {};

--[[ Targets specifiers:

    ALLIES,
    ALIVEALLIES,
    DOWNEDALLIES,
    OTHERALLIES,
    ENEMIES,
    AUTO -- No target selection on AUTO.
]]--

_ZERO_REGISTER.AbilityRegistry = {
    {
        Name = "tripleslash",
        DisplayName = "* T Slash",
        Description = "Low dmg to enemy thrice.",
        Target = "ENEMIES",
        OnExecuted = function()
            local zero = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor];
            if zero.IsCharged then
                zero.IsCharged = false;

                local atk = Player.atk * 4
                BugTaleLibrary.CreateAttacks({{BugTaleLibrary.TargetSelected, atk}})
            else
                local atk = math.ceil(Player.atk / 2)
                BugTaleLibrary.CreateAttacks({{BugTaleLibrary.TargetSelected, atk}, {BugTaleLibrary.TargetSelected, atk}, {BugTaleLibrary.TargetSelected, atk}})
            end
        end,
        BeforeMenu = function()
            local zero = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor];
            if zero.IsCharged then
                _ZERO_REGISTER.AbilityRegistry[1].DisplayName = "[color:FFFF00]* C. Slash"
                _ZERO_REGISTER.AbilityRegistry[1].Description = "Brutal damage to enemy."
            else
                _ZERO_REGISTER.AbilityRegistry[1].DisplayName = "* T. Slash"
                _ZERO_REGISTER.AbilityRegistry[1].Description = "Low damage to enemy thrice."
            end
        end
    },

    {
        Name = "risingslash",
        DisplayName = "* R. Slash",
        Description = "Heavy damage to enemy.",
        MPCost = 2,
        Target = "ENEMIES",
        OnExecuted = function()
            local zero = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor];
            if zero.IsCharged then
                zero.IsCharged = false;

                local atk = Player.atk * 4
                BugTaleLibrary.CreateAttacks({{BugTaleLibrary.TargetSelected, atk}})
            else
                local atk = Player.atk * 2
                BugTaleLibrary.CreateAttacks({{BugTaleLibrary.TargetSelected, atk}})
            end
        end,
        BeforeMenu = function()
            local zero = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor];
            if zero.IsCharged then
                _ZERO_REGISTER.AbilityRegistry[2].DisplayName = "[color:FFFF00]* C. Slash"
                _ZERO_REGISTER.AbilityRegistry[2].Description = "Brutal damage to enemy."
                _ZERO_REGISTER.AbilityRegistry[2].MPCost = 0
            else
                _ZERO_REGISTER.AbilityRegistry[2].DisplayName = "* R. Slash"
                _ZERO_REGISTER.AbilityRegistry[2].Description = "Heavy damage to enemy."
                _ZERO_REGISTER.AbilityRegistry[2].MPCost = 2
            end
        end
    },

    {
        Name = "zero/charge",
        DisplayName = "* Charge",
        Description = "Z-Saber strength up.",
        MPCost = 2,
        Target = "AUTO",
        OnExecuted = function()
            local zero = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor];
            zero.IsCharged = true;
            BattleDialog("Zero charges his Z-Saber!");
        end,
        BeforeMenu = function()
            local zero = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor];
            if zero.IsCharged then
                _ZERO_REGISTER.AbilityRegistry[3].DisplayName = "[color:FFFF00]-- ACTIVE --"
            else
                _ZERO_REGISTER.AbilityRegistry[3].DisplayName = "* Charge"
            end
        end,
        ConditionCheck = function()
            return not BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor].IsCharged;
        end
    },

    {
        Name = "zero/dash",
        DisplayName = "* Dash",
        Description = "Move faster next wave.",
        MPCost = 1,
        Target = "AUTO",
        OnExecuted = function()
            local zero = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor];
            zero.IsDashing = true;
            
            Player.speed = Player.speed * 2;

            BattleDialog("Zero dashes at incredible speed!");
        end,
        BeforeMenu = function()
            local zero = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor];
            if zero.IsDashing then
                _ZERO_REGISTER.AbilityRegistry[4].DisplayName = "[color:FFFF00]-- ACTIVE --"
            else
                _ZERO_REGISTER.AbilityRegistry[4].DisplayName = "* Dash"
            end
        end,
        ConditionCheck = function()
            return not BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor].IsDashing;
        end
    },

    {
        Name = "cyberelf",
        DisplayName = "* Cyber-Elf",
        Description = "Heal/Revive to full but once.",
        Target = "ALLIES",
        OnExecuted = function()
            local zero = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor];
            zero.UsedCyberElf = true;

            local target = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected];

            HealActor(BugTaleLibrary.TargetSelected, target.MaxHealth)

            _ZERO_REGISTER.AbilityRegistry[5].DisplayName = "[color:FF0000]-- RIP --"
            _ZERO_REGISTER.AbilityRegistry[5].Description = "They are resting in peace."
            BattleDialog("Zero used Cyber-Elf!\nHP fully restored but the Cyber-Elf perished!");
        end,
        ConditionCheck = function()
            return not BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor].UsedCyberElf;
        end
    }
}

_ZERO_REGISTER.UnlockedSkills = {}

for _,x in pairs(_ZERO_REGISTER.AbilityRegistry) do
    table.insert(_ZERO_REGISTER.UnlockedSkills, x.Name)
    BugTaleLibrary.RegisterActionProperty(x)
end

function _ZERO_REGISTER.Register(xPos)
    _ZERO_REGISTER.ID = BugTaleLibrary.CreateActor("Zero", {255,0,0}, 14, 5, "Zero", "kabbu", xPos, _ZERO_REGISTER.UnlockedSkills);
    BugTaleLibrary.SetActorAttack(_ZERO_REGISTER.ID, "Slash")

    BugTaleLibrary.Actors[_ZERO_REGISTER.ID].OnTeamTurn = function(currentID)
        local zero = BugTaleLibrary.Actors[currentID];
        if zero.IsDashing then
            zero.IsDashing = false;
            Player.speed = Player.speed / 2
        end
    end
end

return _ZERO_REGISTER