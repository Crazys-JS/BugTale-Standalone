_VEB_REGISTER = {};

--[[ Targets specifiers:

    ALLIES,
    ALIVEALLIES,
    DOWNEDALLIES,
    OTHERALLIES,
    ENEMIES,
    AUTO -- No target selection on AUTO. TARGET ID BECOMES NIL.

    BeforeMenu: (actor, actorID, actionProperties): void,
    OnExecuted: (actor, actorID, targetID?): void,
    ConditionCheck: (actor, actorID): boolean
]]--

_VEB_REGISTER.AbilityRegistry = {
    {
        Name = "V-Action",
        DisplayName = "[color:8F00FF]* V-Action",
        Target = "ENEMIES",
        OnExecuted = function(actor, id, targetID)
            local scr = BugTaleCharacters.GetEnemyScript(targetID);
            if scr.GetVar("HandleSpecialActionMessages") then
                scr.Call("HandleSpecialActionMessages", actor.Name);
            else
                BattleDialog("Veblettor tried some things...[w:15]\nBut the enemy didn't care.");
            end
        end
    },

    {
        Name = "SwordCombo",
        DisplayName = "* S. Combo",
        Target = "ENEMIES",
        Description = "Low dmg to enemy twice.",
        OnExecuted = function (actor, id, targetID)
            BugTaleLibrary.CreateAttacks({{targetID, math.ceil(Player.atk * 0.5) + 2}, {targetID, math.ceil(Player.atk * 0.5)}})
        end
    },

    
    {
        Name = "DeterminationShield",
        DisplayName = "* D. Shield",
        Target = "AUTO",
        Description = "Enemy target & DMG reduction.",
        MPCost = 3,

        OnExecuted = function (actor, id)
            actor.DEF = actor.DEF + 1;
            actor.ShieldActive = true;

            BugTaleLibrary.SetTargets({id})

            BattleDialog({"Veblettor focuses his determination to form a shield.", "All enemies will target Veblettor this turn!\nDamage is reduced by 1."}); 
        end,

        ConditionCheck = function (actor)
            return not actor.ShieldActive;
        end,

        BeforeMenu = function (actor, id, props)
            if actor.ShieldActive then
                props.DisplayName = "[color:FFFF00]-- ACTIVE --"
            else
                props.DisplayName = "* D. Shield"
            end
        end
    },

    {
        Name = "DeterminedFrenzy",
        DisplayName = "* D. Frenzy",
        Target = "AUTO",
        Description = "Medium dmg to 3 random enemies.",
        MPCost = 4,

        OnExecuted = function (actor, id)
            local aliveEnemies = 0;
            local enemyTable = {};

            for _, x in pairs(enemies) do
                if x.GetVar("isactive") then
                    aliveEnemies = aliveEnemies + 1
                    table.insert(enemyTable, aliveEnemies)
                end
            end

            local attacks = {};
            for i=1, 3 do
                local rand = enemyTable[math.random(1, #enemyTable)]
                table.insert(attacks, {rand, Player.atk - i*2 + 2})
            end
    
            BugTaleLibrary.CreateAttacks(attacks)
        end
    },
    
    {
        Name = "DarknessOfFreedom",
        DisplayName = "* DoF",
        Target = "ENEMIES",
        Description = "Brutal++ dmg to enemy but once.",
        MPCost = 8,

        OnExecuted = function (actor, id, targetID)
            actor.DoFUsed = true
            BugTaleLibrary.CreateAttacks({{targetID, Player.atk * 6}});
        end,

        BeforeMenu = function (actor, id, props)
            if(actor.DoFUsed) then
                props.DisplayName = "[color:FF0000]-- USED --"
            else
                props.DisplayName = "* DoF"
            end
        end,

        ConditionCheck = function (actor)
            return not actor.DoFUsed;
        end
    },

    {
        Name = "Resonate",
        DisplayName = "* Resonate",
        Target = "AUTO",
        Description = "+3 HP/MP to self.",

        OnExecuted = function (actor, id)
            actor.ResonateCooldown = 3;
            ChangeMP(id, 3);
            HealActor(id, 3)

            BattleDialog("Veblettor reflects on the current situation.\nRecovered 3 HP and MP!");
        end,

        ConditionCheck = function (actor)
            return (actor.ResonateCooldown or 0) <= 0
        end,

        BeforeMenu = function (actor, id, props)
            local cd = actor.ResonateCooldown or 0;

            if cd > 0 then
                props.DisplayName = "[color:FF0000]-- " ..cd .." CD" .." --";
            else
                props.DisplayName = "* Resonate"
            end
        end
    },

    {
        Name = "HealthyPass",
        DisplayName = "* H. Pass",
        Description = "Pass to ally & +2 HP to both.",
        Target = "ALLIES",
        MPCost = 3,

        BeforeMenu = function(actor, id, props)
            if actor.Relayed then
                props.DisplayName = "[color:FF0000]* H. Pass";
            else
                props.DisplayName = "* H. Pass";
            end
        end,
        OnExecuted = function(currentActor, myId, targetID)
            local relayedTo = BugTaleLibrary.Actors[targetID];
    
            if relayedTo.Turns <= -1 then
                BattleDialog({relayedTo.Name .." acted too many times. You cannot relay to them this turn.", "[noskip][func:State,ACTIONSELECT][next]"})
                return
            end
    
            BugTaleLibrary.GetCurrentActor().Relayed = true;
            currentActor.Turns = currentActor.Turns - 1;
            relayedTo.Turns = relayedTo.Turns + 1;
    
            currentActor.LastButton = "MERCY";

            HealActor(myId, 2);
            HealActor(targetID, 2);
    
            BugTaleLibrary.ChangeActor(targetID)
            State("ACTIONSELECT")
            SetAction(relayedTo.LastButton)
        end,
        ConditionCheck = function (actor)
            return not actor.Relayed;
        end
    },

    {
        Name = "GravelCake",
        DisplayName = "* G. Cake",
        Description = "4 HP recovery to allies.",
        Target = "AUTO",
        MPCost = 4,

        OnExecuted = function (currentActor, myID)
            for i, target in pairs(BugTaleLibrary.Actors) do
                if(target.Health > 0) then
                    BugTaleLibrary.HealActor(i, 4)
                end
            end

            BattleDialog("Veblettor prepares a gravel cake.\nAll allies recovered 4 HP!");
        end
    },

    {
        Name = "Veb/ModdingMess",
        DisplayName = "M. Mess",
        Description = "Medium dmg to 4 random enemies.",
        Target = "AUTO",
        AdditionalActors = {"Crzys"},

        OnExecuted = function (actor, id)
            local crazys;
            local veblettor;

            for i,x in pairs(BugTaleLibrary.Actors) do
                if x.Name == "Crzys" then
                    crazys = x;
                elseif x.Name == "Veb" then
                    veblettor = x;
                end
            end

            if not crazys or not veblettor then error("Allies don't exist.") end;

            crazys.ModdingMess = 4;
            veblettor.ModdingMess = 4;

            local aliveEnemies = 0;
            local enemyTable = {};

            for _, x in pairs(enemies) do
                if x.GetVar("isactive") then
                    aliveEnemies = aliveEnemies + 1
                    table.insert(enemyTable, aliveEnemies)
                end
            end

            local attacks = {};

            for i=1, 4 do
                local rand = enemyTable[math.random(1, #enemyTable)]

                if(i > 2) then
                    table.insert(attacks, {rand, crazys.ATK - i*2 + 2})
                else
                    table.insert(attacks, {rand, veblettor.ATK - i*2 + 2})
                end
            end
    
            BugTaleLibrary.CreateAttacks(attacks)
        end,

        ConditionCheck = function (actor)
            return (actor.ModdingMess or 0) <= 0;
        end,

        BeforeMenu = function (actor, id, properties)
            local cd = actor.ModdingMess or 0;

            if(cd > 0) then
                properties.DisplayName = "-- " ..cd .." CD --"
            else
                properties.DisplayName = "M. Mess"
            end
        end
    },

    {
        Name = "Veb/SoulAcceleration",
        DisplayName = "S. Acc",
        Description = "Move faster for 3 turns.",
        Target = "AUTO",
        AdditionalActors = {"Ledol"},

        OnExecuted = function (actor, id)
            local ledol;
            local veblettor;

            for i,x in pairs(BugTaleLibrary.Actors) do
                if x.Name == "Ledol" then
                    ledol = x;
                elseif x.Name == "Veb" then
                    veblettor = x;
                end
            end

            if not ledol or not veblettor then error("Allies don't exist.") end;

            ledol.SoulAcceleration = 8;
            veblettor.SoulAcceleration = 8;
            veblettor.SoulAccelerationDuration = 3;

            Player.speed = Player.speed * 2;
            BattleDialog({"Veblettor and Ledol combine their powers!", "Your SOUL has accelerated for 3 turns!"})
        end,

        ConditionCheck = function (actor)
            return (actor.SoulAcceleration or 0) <= 0;
        end,

        BeforeMenu = function (actor, id, properties)
            local cd = actor.SoulAcceleration or 0;

            if(cd > 0) then
                properties.DisplayName = "-- " ..cd .." CD --"
            else
                properties.DisplayName = "S. Acc"
            end
        end
    },

    {
        Name = "Veb/AoA",
        DisplayName = "AoA",
        Description = "Combined damage to enemies.",
        Target = "AUTO",
        AdditionalActors = {"Crzys", "Ledol"},

        OnExecuted = function ()
            local totalATK = 0;

            for _,x in pairs(BugTaleLibrary.Actors) do
                x.AoA = 12;
                totalATK = totalATK + x.ATK;
            end

            local aliveEnemies = 0;
            local attacks = {};

            for _, x in pairs(enemies) do
                if x.GetVar("isactive") then
                    aliveEnemies = aliveEnemies + 1
                    table.insert(attacks, {aliveEnemies, math.ceil(totalATK * 1.5)})
                end
            end
    
            BugTaleLibrary.CreateAttacks(attacks)
        end,

        ConditionCheck = function (actor)
            return (actor.AoA or 0) <= 0;
        end,

        BeforeMenu = function (actor, id, props)
            local cd = actor.AoA or 0;

            if(cd > 0) then
                props.DisplayName = "[color:FF0000]-- " ..cd .." CD --"
            else
                props.DisplayName = "AoA"
            end
        end
    }
}

_VEB_REGISTER.UnlockedSkills = {}

for _,x in pairs(_VEB_REGISTER.AbilityRegistry) do
    table.insert(_VEB_REGISTER.UnlockedSkills, x.Name)
    BugTaleLibrary.RegisterActionProperty(x)
end

function _VEB_REGISTER.Register(xPos)
    _VEB_REGISTER.ID = BugTaleLibrary.CreateActor("Veb", {143,0,255}, 10, 8, "Veb", "kabbu", xPos, _VEB_REGISTER.UnlockedSkills);
    BugTaleLibrary.SetActorAttack(_VEB_REGISTER.ID, "Slash")

    BugTaleLibrary.Actors[_VEB_REGISTER.ID].OnTeamTurn = function(currentID)
        local veb = BugTaleLibrary.Actors[currentID];
        if veb.Health < 0 then
            HealActor(currentID, 1);
        end

        if veb.ShieldActive then
            veb.ShieldActive = false;
            veb.DEF = veb.DEF - 1;
        end

        local moddingMess = veb.ModdingMess or 0;
        if(moddingMess > 0) then veb.ModdingMess = moddingMess - 1 end

        local soulAcc = veb.SoulAcceleration or 0;
        if(soulAcc > 0) then veb.SoulAcceleration = soulAcc - 1 end

        local resonate = veb.ResonateCooldown or 0;
        if(resonate > 0) then veb.ResonateCooldown = resonate - 1 end

        local aoa = veb.AoA or 0;
        if aoa > 0 then veb.AoA = aoa - 1 end;

        local soulAccDuration = veb.SoulAccelerationDuration or 0;
        if(soulAccDuration > 0) then
            soulAccDuration = soulAccDuration - 1;
            veb.SoulAccelerationDuration = soulAccDuration;

            if(soulAccDuration == 0) then
                Player.speed = Player.speed / 2;    
            end
        end
    end
end

return _VEB_REGISTER