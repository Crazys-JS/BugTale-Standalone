_LEDOL_REGISTER = {};

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

local phrases = {
    "MAKE THIS INTERESTING FOR ME",
    "LET'S PLAY A GAME",
    string.rep("GO BACK", 10, " "),
    string.rep("DIA.EXE", 100, " "),
    string.rep("CEASE INTERFERER", 10, ", ")
}

_LEDOL_REGISTER.AbilityRegistry = {
    {
        Name = "L-Action",
        DisplayName = "[color:00FF00]* L-Action",
        Target = "ENEMIES",
        OnExecuted = function(actor, id, targetID)
            local scr = BugTaleCharacters.GetEnemyScript(targetID);
            if scr.GetVar("HandleSpecialActionMessages") then
                scr.Call("HandleSpecialActionMessages", actor.Name);
            else
                BattleDialog("Ledol tried some things...[w:15]\nBut the enemy didn't care.");
            end
        end
    },

    {
        Name = "Rapier",
        DisplayName = "* Rapier",
        Description = "High damage to foe. Pierce DEF.",
        Target = "ENEMIES",
        OnExecuted = function (myCharacter, myID, targetID)
            myCharacter.RapierCooldown = 2;
            
            local scr = BugTaleCharacters.GetEnemyScript(targetID);
            local def = scr.GetVar("def") or 0;

            BugTaleLibrary.CreateAttacks({{targetID, math.ceil(Player.atk * 1.5) + def}})
        end,
        ConditionCheck = function (actor, id)
            local cd = actor.RapierCooldown or 0;
            return cd <= 0;
        end,

        BeforeMenu = function (actor, id, props)
            local cd = actor.RapierCooldown or 0;

            if cd > 0 then
                props.DisplayName = "[color:FF0000]-- " ..cd .." CD" .." --";
            else
                props.DisplayName = "* Rapier"
            end
        end
    },

    {
        Name = "BatonPassR",
        DisplayName = "* B. Pass R",
        Description = "Pass to ally and +3 MP to ally.",
        Target = "ALLIES",
        BeforeMenu = function(actor, id, props)
            local cd = actor.BatonPassRCooldown or 0;

            if cd > 0 then
                props.DisplayName = "[color:FF0000]-- " ..cd .." CD" .." --";
            elseif actor.Relayed then
                props.DisplayName = "[color:FF0000]* B. Pass R";
            else
                props.DisplayName = "* B. Pass R";
            end
        end,
        OnExecuted = function(currentActor, myId, targetID)
            local relayedTo = BugTaleLibrary.Actors[targetID];
    
            if relayedTo.Turns <= -1 then
                BattleDialog({relayedTo.Name .." acted too many times. You cannot relay to them this turn.", "[noskip][func:State,ACTIONSELECT][next]"})
                return
            end

            currentActor.BatonPassRCooldown = 3;
    
            BugTaleLibrary.GetCurrentActor().Relayed = true;
            currentActor.Turns = currentActor.Turns - 1;
            relayedTo.Turns = relayedTo.Turns + 1;
    
            currentActor.LastButton = "MERCY";

            ChangeMP(targetID, 3);
    
            BugTaleLibrary.ChangeActor(targetID)
            State("ACTIONSELECT")
            SetAction(relayedTo.LastButton)
        end,
        ConditionCheck = function (actor, id)
            local cd = actor.BatonPassRCooldown or 0;
            return cd <= 0 and not actor.Relayed;
        end
    },

    {
        Name = "SoulPurification",
        DisplayName = "* S. Purify",
        Description = "Revive ally to 60%.",
        Target = "DOWNEDALLIES",
        MPCost = 8,
        
        OnExecuted = function (currentActor, myID, targetID)
            local target = BugTaleLibrary.Actors[targetID];
            local amount = math.ceil(target.MaxHealth * 0.6);

            BugTaleLibrary.ReviveActor(targetID, amount);

            BattleDialog("Ledol purifies " ..target.Name .."'s soul.\nRevived with " ..amount .." HP!");
        end
    },

    {
        Name = "Healmore S",
        DisplayName = "* Healmore S",
        Description = "60% HP recovery to ally.",
        Target = "ALIVEALLIES",
        MPCost = 5,

        OnExecuted = function (currentActor, myID, targetID)
            local target = BugTaleLibrary.Actors[targetID];
            local amount = math.ceil(target.MaxHealth * 0.6);

            BugTaleLibrary.HealActor(targetID, amount);

            BattleDialog(target.Name .. " recovered " ..amount .. " HP!");
        end
    },

    {
        Name = "Healmore M",
        DisplayName = "* Healmore M",
        Description = "25% HP recovery to allies.",
        Target = "AUTO",
        MPCost = 7,

        OnExecuted = function (currentActor, myID)
            for i, target in pairs(BugTaleLibrary.Actors) do
                if(target.Health > 0) then
                    BugTaleLibrary.HealActor(i, math.ceil(target.MaxHealth * 0.25))
                end
            end

            BattleDialog("A soothing light engulfs the team.\nAll allies recovered 25% HP!");
        end
    },

    {
        Name = "Charge",
        DisplayName = "* Charge",
        Description = "+6 MP to self.",
        Target = "AUTO",
        
        OnExecuted = function (currentActor, myID)
            currentActor.ChargeCooldown = 4;
            BugTaleLibrary.ChangeMP(currentActor, 6);

            BattleDialog("Ledol charges his energy.\nLedol recovered 6 MP!")
        end,

        ConditionCheck = function (actor, id)
            local cd = actor.ChargeCooldown or 0;
            return cd <= 0;
        end,

        BeforeMenu = function (actor, id, props)
            local cd = actor.ChargeCooldown or 0;

            if cd > 0 then
                props.DisplayName = "[color:FF0000]-- " ..cd .." CD" .." --";
            else
                props.DisplayName = "* Charge"
            end
        end
    },

    {
        Name = "BlessingOfGods",
        DisplayName = "* BoG",
        Description = "HP/MP recover/regen to allies.",
        Target = "AUTO",

        MPCost = 13,

        OnExecuted = function (currentActor, myID)
            currentActor.BoGUsed = true
            currentActor.BoGRegen = 3;

            for i,actor in pairs(BugTaleLibrary.Actors) do
                if(actor ~= currentActor) then
                    local amount1 = math.ceil(actor.MaxHealth * 0.65);
                    local amount2 = math.ceil(actor.MaxMana * 0.65);

                    if(actor.Health > 0) then
                        BugTaleLibrary.HealActor(i, amount1);
                    else
                        BugTaleLibrary.ReviveActor(i, amount1);
                    end

                    BugTaleLibrary.ChangeMP(actor, amount2)
                end
            end

            BattleDialog("The party receives the blessing of the gods!")
        end,

        ConditionCheck = function (actor)
            return not actor.BoGUsed;
        end,

        BeforeMenu = function (actor, id, props)
            if actor.BoGUsed then
                props.DisplayName = "[color:FF0000]-- USED --";
                if actor.genocideRoute then
                    props.Description = "But nobody came."
                else
                    props.Description = "The gods are silent."
                end
            else
                props.DisplayName = "* BoG";
            end
        end
    },

    {
        Name = "Ledol/KindScript",
        DisplayName = "K. Script",
        Description = "Fully heal allies.",
        Target = "AUTO",
        AdditionalActors = {"Crzys"},

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
        Name = "Ledol/SoulAcceleration",
        DisplayName = "S. Acc",
        Description = "Move faster for 3 turns.",
        Target = "AUTO",
        AdditionalActors = {"Veb"},

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
        Name = "Ledol/AoA",
        DisplayName = "AoA",
        Description = "Combined damage to enemies.",
        Target = "AUTO",
        AdditionalActors = {"Crzys", "Veb"},

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
    },

    {
        Name = "Dia",
        DisplayName = "* Dia",
        Description = "...",
        Target = "AUTO",
        
        OnExecuted = function (actor)
            
            if(actor.Idiot) then
                deathtext = {string.rep("DIA.EXE", 1000, " ")}
                Player.hp = 0;
            else
                actor.Idiot = true

                deathmusic = "diaover"
                
                for i,x in pairs(BugTaleLibrary.Actors) do
                    x.Actions = {"Do Nothing"}
                    x.Portrait.Set(x.AssetsFolder .."/exe")
                    x.PortraitMask.Set(x.AssetsFolder .."/exe")
                end

                for i,x in pairs(enemies) do
                    x.SetVar("def", 99999)
                    x.SetVar("comments", {string.rep("DIA.EXE", 30, " ")})
                    x.SetVar("randomdialogue", {string.rep("DIA.EXE", 30, " ")})
                end

                BugTaleLibrary.SetOtherMenuActions({"Do Nothing"})

                actor.Actions = {};

                BugTaleLibrary.SetInventory({
                    "Do Nothing"
                })

                Audio.LoadFile("dia")
    
                for i=1, 6666 do
                    table.insert(actor.Actions, "Dia")
                end
    
                BattleDialog("[color:FF0000]You made a bad mistake.")
            end
        end,

        BeforeMenu = function (actor, id, props)
            if actor.Idiot then
                if BugTaleLibrary.SelectionUIIndex >= 255*4 - 3 then
                    BugTaleLibrary.SetInventory({"Dia"});
                    BugTaleLibrary.SetOtherMenuActions({"Dia"});

                    if BugTaleLibrary.SelectionUIIndex >= 333*4 - 3 then
                        props.DisplayName = "[color:FF0000] " .. string.rep("DIE", 20, " ")
                    else
                        props.DisplayName = "[color:AA0000]* " .. phrases[math.random(1,#phrases)]
                        props.Description = "[color:AA0000]YOU WILL NEVER WIN, INTERFERER. YOU ARE IN MY WORLD NOW. MAKE THIS INTERESTING FOR ME."
                    end
                else
                    props.DisplayName = "[color:FF0000]* DIA.EXE"
                    props.Description = "[color:FF0000]BUT NO ONE CAME."
                end
            else
                props.DisplayName = "* Dia"
            end
        end
    }
}

_LEDOL_REGISTER.UnlockedSkills = {}

for _,x in pairs(_LEDOL_REGISTER.AbilityRegistry) do
    table.insert(_LEDOL_REGISTER.UnlockedSkills, x.Name)
    BugTaleLibrary.RegisterActionProperty(x)
end

function _LEDOL_REGISTER.Register(xPos)
    _LEDOL_REGISTER.ID = BugTaleLibrary.CreateActor("Ledol", {0,125,0}, 9, 15, "Ledol", "kabbu", xPos, _LEDOL_REGISTER.UnlockedSkills);
    BugTaleLibrary.SetActorAttack(_LEDOL_REGISTER.ID, "Slash")

    BugTaleLibrary.Actors[_LEDOL_REGISTER.ID].OnTeamTurn = function(currentID)
        local ledol = BugTaleLibrary.Actors[currentID];
        
        local cd1 = ledol.BatonPassRCooldown or 0;
        local cd2 = ledol.RapierCooldown or 0;
        local cd3 = ledol.ChargeCooldown or 0;
        local dur = ledol.BoGRegen or 0;
        local kindScript = ledol.KindScript or 0;
        local soulAcc = ledol.SoulAcceleration or 0;
        local aoa = ledol.AoA or 0;

        if cd1 > 0 then ledol.BatonPassRCooldown = cd1 - 1 end;
        if cd2 > 0 then ledol.RapierCooldown = cd2 - 1 end;
        if cd3 > 0 then ledol.ChargeCooldown = cd3 - 1 end;
        if kindScript > 0 then ledol.KindScript = kindScript - 1 end;
        if soulAcc > 0 then ledol.SoulAcceleration = soulAcc - 1 end;
        if aoa > 0 then ledol.AoA = aoa - 1 end;

        if dur > 0 then
            ledol.BoGRegen = dur - 1;

            for i,actor in pairs(BugTaleLibrary.Actors) do
                if actor.Health > 0 then
                    local amount1 = math.ceil(actor.MaxHealth * 0.05);
                    local amount2 = math.ceil(actor.MaxMana * 0.05);
    
                    BugTaleLibrary.HealActor(i, amount1);
                    BugTaleLibrary.ChangeMP(actor, amount2)
                end
            end
        end
    end
end

return _LEDOL_REGISTER