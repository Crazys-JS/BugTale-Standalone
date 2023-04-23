--[[

    This library has default other menu actions provided by the original bugtale library. Import this module after bugtale library
    in order to get these options.

]]--

BugTaleLibrary.RegisterActionProperty({
    Name = "Spy",
    DisplayName = "* Spy",
    Description = "Check enemy & see MERCY progress.",
    Target = "ENEMIES",
    OnExecuted = function()
        local enemy = BugTaleLibrary.GetEnemyScript(BugTaleLibrary.TargetSelected)
        local checkMSG = enemy.GetVar("check")
        local spyMSG = enemy.GetVar("spymessages")
        local name = enemy.GetVar("name")
        local atk = enemy.GetVar("atk")
        local def = enemy.GetVar("def")

        enemy.SetVar("was_spied", true)

        BattleDialog(name:upper() .." ATK " ..atk .." DEF " ..def .."\n" ..checkMSG);
        if spyMSG and spyMSG[BugTaleLibrary.CurrentActor] then
            QueuedSpyDialog = spyMSG[BugTaleLibrary.CurrentActor]
        end
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Do Nothing",
    DisplayName = "* Do Nothing",
    Description = "+16% TP.",
    Target = "AUTO",
    OnExecuted = function()
        ChangeTP(16)
        State("ENEMYDIALOGUE")
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Turn Relay",
    DisplayName = "* Turn Relay",
    Description = "Pass to ally.",
    Target = "OTHERALLIES",
    BeforeMenu = function()
        if BugTaleLibrary.GetCurrentActor().Relayed then
            BugTaleLibrary.ActionProperties["Turn Relay"].DisplayName = "[color:FF0000]* Turn Relay";
        else
            BugTaleLibrary.ActionProperties["Turn Relay"].DisplayName = "* Turn Relay";
        end
    end,
    OnExecuted = function()
        local currentActor = BugTaleLibrary.GetCurrentActor();
        local relayedTo = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected];

        if relayedTo.Turns <= -1 then
            BattleDialog({relayedTo.Name .." acted too many times. You cannot relay to them this turn.", "[noskip][func:State,ACTIONSELECT][next]"})
            return
        end

        BugTaleLibrary.GetCurrentActor().Relayed = true;
        currentActor.Turns = currentActor.Turns - 1;
        relayedTo.Turns = relayedTo.Turns + 1;

        currentActor.LastButton = "MERCY";

        BugTaleLibrary.ChangeActor(BugTaleLibrary.TargetSelected)
        State("ACTIONSELECT")
        SetAction(relayedTo.LastButton)
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Spare",
    DisplayName = "* Spare",
    Description = "Spare enemies.",
    Target = "AUTO",
    BeforeMenu = function()
        local canSpare = false;
        for i,x in pairs(enemies) do
            if x.GetVar("isactive") and x.GetVar("canspare") then
                canSpare = true
                break
            end
        end

        if canSpare then
            BugTaleLibrary.ActionProperties["Spare"].DisplayName = "[color:FFFF00]* Spare";
        else
            BugTaleLibrary.ActionProperties["Spare"].DisplayName = "* Spare";
        end
    end,
    OnExecuted = function()
        State("NONE")

        local spared = false;
        
        for i,x in pairs(enemies) do
            if x.GetVar("canspare") then
                spared = true;
                if x.GetVar("OnSpare") then
                    x.Call("OnSpare");
                else
                    x.Call("Spare");
                end
            end
        end

        if spared then
            BattleDialog({BugTaleLibrary.GetCurrentActor().Name .." spared the enemies!", "[noskip][func:State,DIALOGRESULT][next]"});
        else
            BattleDialog({BugTaleLibrary.GetCurrentActor().Name .." spared the enemies![w:15]\nBut their names weren't [color:FFFF00]YELLOW[color:FFFFFF].", "[noskip][func:State,DIALOGRESULT][next]"});
        end
    end
});

BugTaleLibrary.SetOtherMenuActions({"Spy", "Do Nothing", "Turn Relay", "Spare"})