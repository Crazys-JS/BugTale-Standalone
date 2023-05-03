_CRAZYS_REGISTER = {};

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

_CRAZYS_REGISTER.AbilityRegistry = {
    {
        Name = "C-Action",
        DisplayName = "[color:FFA000]* C-Action",
        Target = "ENEMIES",
        OnExecuted = function(actor, id, targetID)
            local scr = BugTaleCharacters.GetEnemyScript(targetID);
            if scr.GetVar("HandleSpecialActionMessages") then
                scr.Call("HandleSpecialActionMessages", actor.Name);
            else
                BattleDialog("Crazys tried some things...[w:15]\nBut the enemy didn't care.");
            end
        end
    },

    {
        Name = "Changelog",
        DisplayName = "* Chlog",
        Description = "Check enemy & see MERCY progress.",
        Target = "ENEMIES",
        MPCost = 2,
        OnExecuted = function(actor, id, targetID)
            local enemy = BugTaleLibrary.GetEnemyScript(targetID)
            local checkMSG = enemy.GetVar("check")
            local spyMSG = enemy.GetVar("spymessages")
            local name = enemy.GetVar("name")
            local atk = enemy.GetVar("atk")
            local def = enemy.GetVar("def")
    
            enemy.SetVar("was_spied", true)
    
            BattleDialog(name:upper() .." ATK " ..atk .." DEF " ..def .."\n" ..checkMSG);
            if spyMSG and spyMSG[id] then
                QueuedSpyDialog = spyMSG[id]
            end
        end
    },

    {
        Name = "Code",
        DisplayName = "* Code",
        Description = "High damage to enemy.",
        Target = "ENEMIES",

        OnExecuted = function (actor, id, targetID)
            BugTaleLibrary.CreateAttacks({{targetID, math.ceil(Player.atk * 1.5)}})
        end
    },

    {
        Name = "SoulHack",
        DisplayName = "* S. Hack",
        Description = "6 MP recovery to ally.",
        Target = "OTHERALLIES",
        MPCost = 6,

        OnExecuted = function (actor, id, targetID)
            local target = BugTaleLibrary.Actors[targetID];
            BugTaleLibrary.ChangeMP(target, 6);

            BattleDialog("Crazys hacks " ..target.Name .."'s soul.\n" ..target.Name .." recovered 6 MP!");
        end
    },

    {
        Name = "Typescript",
        DisplayName = "* T. Script",
        Description = "Heavy damage to one enemy.",
        Target = "ENEMIES",
        MPCost = 7,

        OnExecuted = function (actor, id, targetID)
            BugTaleLibrary.CreateAttacks({{targetID, Player.atk * 2}})
        end
    },

    {
        Name = "RainingScripts",
        DisplayName = "* R. Script",
        Description = "Medium damage to enemies.",
        Target = "AUTO",
        MPCost = 5,

        OnExecuted = function (actor, id, targetID)
            local aliveEnemies = 0;
            local attacks = {};

            for _, x in pairs(enemies) do
                if x.GetVar("isactive") then
                    aliveEnemies = aliveEnemies + 1
                    table.insert(attacks, {aliveEnemies, Player.atk})
                end
            end
    
            BugTaleLibrary.CreateAttacks(attacks)
        end
    },

    {
        Name = "C++",
        DisplayName = "* C++",
        Description = "Brutal damage to one enemy.",
        Target = "ENEMIES",
        MPCost = 12,

        OnExecuted = function (actor, id, targetID)
            BugTaleLibrary.CreateAttacks({{targetID, Player.atk * 4}})
        end
    },


    {
        Name = "Break",
        DisplayName = "* Break",
        Description = "Full MP but can't act.",
        Target = "AUTO",
        
        OnExecuted = function (actor)
            actor.Turns = actor.Turns - 2;
            BugTaleLibrary.ChangeMP(actor, actor.MaxMana);

            BattleDialog("Crazys takes a break, MP fully restored!\nCrazys cannot act for 2 turns!");
        end
    },

    {
        Name = "Crazys/ModdingMess",
        DisplayName = "M. Mess",
        Description = "Medium dmg to 4 random enemies.",
        Target = "AUTO",
        AdditionalActors = {"Veb"},

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
        Name = "Crazys/KindScript",
        DisplayName = "K. Script",
        Description = "Fully heal allies.",
        Target = "AUTO",
        AdditionalActors = {"Ledol"},

        OnExecuted = function (actor, id)
            local crazys;
            local ledol;

            for i,x in pairs(BugTaleLibrary.Actors) do
                if x.Name == "Crzys" then
                    crazys = x;
                elseif x.Name == "Ledol" then
                    ledol = x;
                end
            end

            if not crazys or not ledol then error("Allies don't exist.") end;

            crazys.KindScript = 9;
            ledol.KindScript = 9;

            for i, target in pairs(BugTaleLibrary.Actors) do
                BugTaleLibrary.HealActor(i, target.MaxHealth - math.min(0, target.Health));
            end

            BattleDialog("Crazys and Ledol combine their powers.\nAll allies fully recovered.");
        end,

        ConditionCheck = function (actor)
            return (actor.KindScript or 0) <= 0;
        end,

        BeforeMenu = function (actor, id, properties)
            local cd = actor.KindScript or 0;

            if(cd > 0) then
                properties.DisplayName = "-- " ..cd .." CD --"
            else
                properties.DisplayName = "K. Script"
            end
        end
    },

    {
        Name = "Crazys/AoA",
        DisplayName = "AoA",
        Description = "Combined damage to enemies.",
        Target = "AUTO",
        AdditionalActors = {"Veb", "Ledol"},

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

_CRAZYS_REGISTER.UnlockedSkills = {}

for _,x in pairs(_CRAZYS_REGISTER.AbilityRegistry) do
    table.insert(_CRAZYS_REGISTER.UnlockedSkills, x.Name)
    BugTaleLibrary.RegisterActionProperty(x)
end

function _CRAZYS_REGISTER.Register(xPos)
    _CRAZYS_REGISTER.ID = BugTaleLibrary.CreateActor("Crzys", {255,125,0}, 7, 20, "Crazys", "kabbu", xPos, _CRAZYS_REGISTER.UnlockedSkills);
    BugTaleLibrary.SetActorAttack(_CRAZYS_REGISTER.ID, "Slash")

    BugTaleLibrary.Actors[_CRAZYS_REGISTER.ID].OnTeamTurn = function(currentID)
        local crazys = BugTaleLibrary.Actors[currentID];
        if crazys.Health > 0 then
            ChangeMP(currentID, 1);
        end

        local moddingMess = crazys.ModdingMess or 0;
        local kindScript = crazys.KindScript or 0;
        local aoa = crazys.AoA or 0;

        if(moddingMess > 0) then crazys.ModdingMess = moddingMess - 1 end
        if(kindScript > 0) then crazys.KindScript = kindScript - 1 end
        if(aoa > 0) then crazys.AoA = aoa - 1 end;
    end
end

return _CRAZYS_REGISTER