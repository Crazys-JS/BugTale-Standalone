--[[
    @Crazys_JS 2023 MP VERSION
    Do not modify the library for making new encounters as you can modify stuff in the encounter script itself. Consistency is key.
    Adds multiple character functionality to the game.
    Stuff you can use in encounter script are defined on the bottom.
]]--

-- !!! DEPENDENCY: tp_library.lua library in Encounter. --
CreateLayer("AboveEnemy", "BelowArena");

BugTaleCharacters = {};

BugTaleCharacters.Actors = {};
BugTaleCharacters.CurrentActor = 1;

BugTaleCharacters.ActorAnimationTimer = 0;
BugTaleCharacters.UIAnimationTimer = 0;

BugTaleCharacters.OtherMenuActions = {}
BugTaleCharacters.ActionProperties = {};
BugTaleCharacters.TextVisuals = {};
BugTaleCharacters.RevertState = "ACTIONSELECT"

BugTaleCharacters.TeamName = "???"
BugTaleCharacters.TeamLV = 1;

QueuedSpyDialog = nil;
BugTaleCharacters.SpyDialogText = {};
BugTaleCharacters.DialogSequence = false;
BugTaleCharacters.DialogSequencePaused = false;
BugTaleCharacters.DialogBox = nil;

BugTaleCharacters.QueuedAction = nil;
BugTaleCharacters.QueuedActionID = nil;

BugTaleCharacters.PartyItems = {};
BugTaleCharacters.ItemActions = {};

BugTaleCharacters.AdditionalActions = {};

BugTaleCharacters.QueuedAttacks = {};
BugTaleCharacters.AttackTimer = 0;
BugTaleCharacters.AttackTimerStart = 0;
BugTaleCharacters.AttackFrequency = 60; -- Change this to make multiattacks quicker.

BugTaleCharacters.ActiveActions = {}; -- The actions currently selectable.
BugTaleCharacters.ActiveActionImages = {};
BugTaleCharacters.ActionSelectionTexts = {};
BugTaleCharacters.SelectionUIIndex = 1;
BugTaleCharacters.ActionSelectionActive = false;
BugTaleCharacters.ActionSelectionActivating = false;
BugTaleCharacters.ActionSelectMPCostAnimation = 0;

BugTaleCharacters.SelectionHeart = CreateSprite("ut-heart", "Top")
BugTaleCharacters.SelectionHeart.SetParent(Player.sprite);
BugTaleCharacters.SelectionHeart.color = {1,0,0,0}
BugTaleCharacters.SelectionHeart.MoveTo(0,0)

BugTaleCharacters.MPCostBG = CreateSprite("UI/tp_cost_bg", "BelowArena");
BugTaleCharacters.MPCostBG.SetPivot(0,0);
BugTaleCharacters.MPCostBG.MoveToAbs(436, 94);
BugTaleCharacters.MPCostBG.alpha = 0;
BugTaleCharacters.MPCostVisible = false;

BugTaleCharacters.MPCostText = CreateText("[instant]", {0,0}, 141, "BelowArena");
BugTaleCharacters.MPCostText.progressmode = "none";
BugTaleCharacters.MPCostText.deleteWhenFinished = false;
BugTaleCharacters.MPCostText.color = {1,1,1,1};
BugTaleCharacters.MPCostText.SetFont("uidialog")
BugTaleCharacters.MPCostText.HideBubble()
BugTaleCharacters.MPCostText.SetAnchor(0,0);
BugTaleCharacters.MPCostText.SetParent(BugTaleCharacters.MPCostBG);
BugTaleCharacters.MPCostText.MoveTo(42, 12);

BugTaleCharacters.PageText = CreateText("[instant]", {0,0}, 141, "BelowArena");
BugTaleCharacters.PageText.progressmode = "none";
BugTaleCharacters.PageText.deleteWhenFinished = false;
BugTaleCharacters.PageText.color = {1,1,1,1};
BugTaleCharacters.PageText.SetFont("uibattlesmall")
BugTaleCharacters.PageText.HideBubble()
BugTaleCharacters.PageText.SetAnchor(1,0);
BugTaleCharacters.PageText.MoveTo(300,63);
BugTaleCharacters.PageText.color = {.75,.75,.75}

BugTaleCharacters.SkillDescriptionTXT = CreateText("[instant]", {0,0}, 565, "BelowPlayer");
BugTaleCharacters.SkillDescriptionTXT.progressmode = "none";
BugTaleCharacters.SkillDescriptionTXT.deleteWhenFinished = false;
BugTaleCharacters.SkillDescriptionTXT.color = {.5,.5,.5,1};
BugTaleCharacters.SkillDescriptionTXT.SetFont("uidialog")
BugTaleCharacters.SkillDescriptionTXT.HideBubble()
BugTaleCharacters.SkillDescriptionTXT.SetAnchor(0,0);
BugTaleCharacters.SkillDescriptionTXT.MoveTo(60, 106);

BugTaleCharacters.XPGained = 0;
BugTaleCharacters.GoldGained = 0;
BugTaleCharacters.VictoryScreenExtra = nil; --Currently Unused.

BugTaleCharacters.TargetSelectionTexts = {};
BugTaleCharacters.TargetSelectionBars = {};

BugTaleCharacters.TargetSelectionMercyBars = {};

BugTaleCharacters.TargetSelectionValues = {};
BugTaleCharacters.CurrentTargetIndex = 0;
BugTaleCharacters.TargetSelected = 0;

-- 303, 182;
-- {x, y, targetIndex, name, hpRatio} new targeting system format

for i=0, 3 do
    local row = math.floor(i / 2);
    local column = i % 2;
    
    local absx = 92 + column * 265;
    local absy = 183 - row * 30;
    
    local text = CreateText("", {absx, absy}, 225);
    text.progressmode = "none";
    text.deleteWhenFinished = false;
    text.color = {1,1,1,1};
    text.SetFont("uidialog")
    text.HideBubble()
    text.SetAnchor(0,0);

    text.MoveTo(absx,absy);

    table.insert(BugTaleCharacters.ActionSelectionTexts, text);
end

for i=0, 2 do
    local absx = 92;
    local absy = 183 - i * 30;
    
    local text = CreateText("", {absx, absy}, 225);
    text.progressmode = "none";
    text.deleteWhenFinished = false;
    text.color = {1,1,1,1};
    text.SetFont("uidialog")
    text.HideBubble()
    text.SetAnchor(0,0);

    text.MoveTo(absx,absy);
    table.insert(BugTaleCharacters.TargetSelectionTexts, text);

    local absxBAR = 303;
    local bar = CreateBar(absxBAR, absy - 1, 90, 20);
    bar.background.layer = "BelowPlayer";
    bar.background.SetPivot(0,0);
    bar.background.MoveTo(absxBAR, absy - 1);

    bar.background.color = {1,0,0};
    bar.fill.color = {0,1,0};
    bar.SetVisible(false);

    local absxBAR2 = 403;
    local bar2 = CreateBar(absxBAR2, absy - 1, 90, 20);
    bar2.background.layer = "BelowPlayer";
    bar2.background.SetPivot(0,0);
    bar2.background.MoveTo(absxBAR2, absy - 1);

    bar2.background.color32 = {128, 0, 0};
    bar2.fill.color = {1,1,0};
    bar2.SetVisible(false);

    table.insert(BugTaleCharacters.TargetSelectionBars, bar);
    table.insert(BugTaleCharacters.TargetSelectionMercyBars, bar2);
end

BugTaleCharacters.TargetNext = nil; -- This is reset everytime Defense phase ends. See BugTaleCharacters.SetTargets;
BugTaleCharacters.EnemyTargeting = nil; -- This is overriden by TargetNext, only meant for enemies wanting to target someone for a whole wave. See BugTaleCharacters.SetEnemyTargets;

SlashSound = "slash";
HitSound = "hitsound";

BugTaleCharacters.AttackTypes = {};

function BugTaleCharacters.ConvertColorToInteger(color)
	return math.floor(color[1]*255)*256^2+math.floor(color[2]*255)*256+math.floor(color[3]*255)
end

function BugTaleCharacters.ConvertColor32ToInteger(color)
	return math.floor(color[1])*256^2+math.floor(color[2])*256+math.floor(color[3])
end

function BugTaleCharacters.ConvertColorToHex(color)
	local int = BugTaleCharacters.ConvertColorToInteger(color)
	
	local current = int
	local final = ""
	
	local hexChar = {
		"A", "B", "C", "D", "E", "F"
	}
	
	repeat local remainder = current % 16
		local char = tostring(remainder)
		
		if remainder >= 10 then
			char = hexChar[1 + remainder - 10]
		end
		
		current = math.floor(current/16)
		final = final..char
	until current <= 0
	
	return string.reverse(final)
end

function BugTaleCharacters.ConvertColor32ToHex(color)
	local int = BugTaleCharacters.ConvertColor32ToInteger(color)
	
	local current = int
	local final = ""
	
	local hexChar = {
		"A", "B", "C", "D", "E", "F"
	}
	
	repeat local remainder = current % 16
		local char = tostring(remainder)
		
		if remainder >= 10 then
			char = hexChar[1 + remainder - 10]
		end
		
		current = math.floor(current/16)
		final = final..char
	until current <= 0
	
	return string.reverse(final)
end

-- This is so other scripts (enemies and waves) can call BugTaleLibrary.
function CallBugTale(functionName, ...)
    return BugTaleCharacters[functionName](...)
end

-- This is so other scripts (enemies and waves) can call BugTaleLibrary.
function GetBugTaleVar(varName)
    return BugTaleCharacters[varName]
end

-- The given targets will be targeted when DamageRandom or DamageTargeted is called. Supresses SetEnemyTargets. Useful for Taunt.
function BugTaleCharacters.SetTargets(targets)
    BugTaleCharacters.TargetNext = targets
end

-- The given targets will be targeted when DamageRandom or DamageTargeted is called. Useful for targeting someone the whole wave.
function BugTaleCharacters.SetEnemyTargets(...)
    if #{...} == 0 then
        local aliveIDs = {};
        for i,x in pairs(BugTaleCharacters.Actors) do
            if x.Health > 0 then
                table.insert(aliveIDs, i)
            end
        end

        BugTaleCharacters.EnemyTargeting = {aliveIDs[math.random(1, #aliveIDs)]};
    else
        BugTaleCharacters.EnemyTargeting = {...}
    end
end

function BugTaleCharacters.GetEnemyScript(id)
    local found = nil;
    for i,x in pairs(enemies) do
        if x.GetVar("isactive") then
            id = id - 1;
            if id == 0 then
                found = x
                break
            end
        end
    end

    return found
end

function BugTaleCharacters.UpdateTargetSelection()

    local clamped = (BugTaleCharacters.CurrentTargetIndex - 1) % 3;
    local currentPage = math.ceil(BugTaleCharacters.CurrentTargetIndex / 3);

    local firstIndex = (currentPage - 1) * 3 + 1;

    local absx = 92;
    local absy = 183 - clamped * 30;

    local localIndex = 1;
    for i=firstIndex, firstIndex + 2 do
        local data = BugTaleCharacters.TargetSelectionValues[i];
        if data then
            BugTaleCharacters.TargetSelectionTexts[localIndex].SetText("[noskip][instant]" ..data[4]);
            if data[5] then
                BugTaleCharacters.TargetSelectionBars[localIndex].SetInstant(data[5]);
                BugTaleCharacters.TargetSelectionBars[localIndex].SetVisible(true);
            else
                BugTaleCharacters.TargetSelectionBars[localIndex].SetVisible(false);
            end

            if data[6] then
                BugTaleCharacters.TargetSelectionMercyBars[localIndex].SetInstant(data[6]);
                BugTaleCharacters.TargetSelectionMercyBars[localIndex].SetVisible(true);
            else
                BugTaleCharacters.TargetSelectionMercyBars[localIndex].SetVisible(false);
            end
        else
            BugTaleCharacters.TargetSelectionTexts[localIndex].SetText("");
            BugTaleCharacters.TargetSelectionBars[localIndex].SetVisible(false);
            BugTaleCharacters.TargetSelectionMercyBars[localIndex].SetVisible(false);
        end
        localIndex = localIndex + 1;
    end

    Player.MoveToAbs(absx - 27, absy + 7)
end

function BugTaleCharacters.HideTargetSelection()
    for i,x in pairs(BugTaleCharacters.TargetSelectionTexts) do
        x.SetText("")
    end

    for i,x in pairs(BugTaleCharacters.TargetSelectionBars) do
        x.SetVisible(false)
    end

    for i,x in pairs(BugTaleCharacters.TargetSelectionMercyBars) do
        x.SetVisible(false)
    end
end

function BugTaleCharacters.CreateTargetSelection(mode)
    State("PAUSE")
    
    BugTaleCharacters.TargetSelectionValues = {};
    BugTaleCharacters.TargetSelected = 0;

    TargetSelectionEnemyMode = false;

    if mode == "ALLIES" then
        for i,x in pairs(BugTaleCharacters.Actors) do
            local portrait = x.Portrait;
            local xPos = portrait.absx;
            local yPos = portrait.absy + portrait.height / 2 + 30;

            local data = {xPos, yPos, i, "* " ..x.Name, x.Health / x.MaxHealth, x.Mana / x.MaxMana};
            BugTaleCharacters.TargetSelectionValues[i] = data;
        end
    elseif mode == "ALIVEALLIES" then
        for i,x in pairs(BugTaleCharacters.Actors) do
            if x.Health > 0 then
                local portrait = x.Portrait;
                local xPos = portrait.absx;
                local yPos = portrait.absy + portrait.height / 2 + 30;

                local data = {xPos, yPos, i, "* " ..x.Name, x.Health / x.MaxHealth, x.Mana / x.MaxMana};
                table.insert(BugTaleCharacters.TargetSelectionValues, data);
            end
        end
    elseif mode == "DOWNEDALLIES" then
        for i,x in pairs(BugTaleCharacters.Actors) do
            if x.Health <= 0 then
                local portrait = x.Portrait;
                local xPos = portrait.absx;
                local yPos = portrait.absy + portrait.height / 2 + 30;
    
                local data = {xPos, yPos, i, "* " ..x.Name, x.Health / x.MaxHealth, x.Mana / x.MaxMana};
                table.insert(BugTaleCharacters.TargetSelectionValues, data);
            end
        end
    elseif mode == "OTHERALLIES" then
        for i,x in pairs(BugTaleCharacters.Actors) do
            if BugTaleCharacters.CurrentActor ~= i and x.Health > 0 then
                local portrait = x.Portrait;
                local xPos = portrait.absx;
                local yPos = portrait.absy + portrait.height / 2 + 30;
    
                local data = {xPos, yPos, i, "* " ..x.Name, x.Health / x.MaxHealth, x.Mana / x.MaxMana};
                table.insert(BugTaleCharacters.TargetSelectionValues, data);
            end
        end
    elseif mode == "ENEMIES" then
        TargetSelectionEnemyMode = true;
        local currentID = 1;
        for i,x in pairs(enemies) do
            if x.GetVar("isactive") then
                local sprite = x.GetVar("monstersprite");
                local xPos = sprite.absx;
                local yPos = sprite.absy + sprite.height / 1.25;

                local hp = x.GetVar("hp");
                local maxhp = x.GetVar("maxhp");

                local name = "* " ..x.GetVar("name")
                if x.GetVar("canspare") then
                    name = "[color:FFFF00]" ..name .."[color:FFFFFF]"
                end

                local data;
                if x.GetVar("was_spied") and x.GetVar("spare_progress") then
                    data = {xPos, yPos, currentID, name, hp / maxhp, x.GetVar("spare_progress") / 100};
                else
                    data = {xPos, yPos, currentID, name, hp / maxhp};
                end

                table.insert(BugTaleCharacters.TargetSelectionValues, data);

                currentID = currentID + 1;
            end
        end
    end

    local barColor = {1,1,0}
    local backColor = {128, 0, 0}

    if(not TargetSelectionEnemyMode) then
        barColor = {0,.5,1}
        backColor = {255,0,0}
    end

    for _, x in pairs(BugTaleCharacters.TargetSelectionMercyBars) do
        x.fill.color = barColor;
        x.background.color = backColor; 
    end

    if #BugTaleCharacters.TargetSelectionValues == 0 then
        State(BugTaleCharacters.RevertState);
        return
    end

    for i,x in pairs(BugTaleCharacters.ActionSelectionTexts) do
        x.SetText("[noskip][instant]")
    end

    for i,x in pairs(BugTaleCharacters.ActiveActionImages) do
        x.Remove()
    end

    BugTaleCharacters.PageText.SetText("[instant]");

    BugTaleCharacters.ActiveActionImages = {};

    BugTaleCharacters.SkillDescriptionTXT.SetText("[noskip][instant]")

    BugTaleCharacters.CurrentTargetIndex = 1;
    BugTaleCharacters.UpdateTargetSelection()
end

-- DO NOT PUT "Portraits/" IN PORTRAIT VARIABLE, THAT IS DONE AUTOMATICALLY FOR YOU!
function BugTaleCharacters.CreateActor(name, color32, hp, mana, assetName, voice, posX, actionList)
    local actor = {};

    actor.Name = name;
    actor.Color32 = {color32[1], color32[2], color32[3]};
    actor.HexColor = BugTaleCharacters.ConvertColor32ToHex(actor.Color32);
    actor.Turns = 1;
    actor.Relayed = false;
    actor.Actions = actionList;
    actor.LastButton = "FIGHT"

    actor.MaxHealth = hp;
    actor.Health = hp;

    actor.MaxMana = mana;
    actor.Mana = mana;

    actor.HighlightActor = false;
    actor.Voice = voice

    actor.ATK = 10;
    actor.DEF = 0;

    actor.UI = CreateSprite("UI/actorbar", "AboveEnemy");
    actor.UI.SetPivot(0, 0);
    actor.UI.color32 = actor.Color32
    actor.UI.MoveTo(posX, 225)

    actor.AssetsFolder = "CharacterAssets/" ..assetName;

    actor.PortraitMask = CreateSprite(actor.AssetsFolder .."/portrait");
    actor.PortraitMask.SetParent(actor.UI)
    actor.PortraitMask.SetAnchor(.5,1)
    actor.PortraitMask.MoveTo(0,actor.PortraitMask.height / 2)
    actor.PortraitMask.alpha = 0
    actor.PortraitMask.Mask("box")

    actor.Portrait = CreateSprite(actor.AssetsFolder .."/portrait");
    actor.Portrait.SetParent(actor.PortraitMask)
    actor.Portrait.MoveTo(0,0)

    actor.NameText = CreateText("[instant]" ..name:upper(), {0,0}, 100, "BelowArena")
    actor.NameText.color = {1,1,1}
    actor.NameText.progressmode = "none"
    actor.NameText.deleteWhenFinished = false
    actor.NameText.HideBubble()

    actor.NameText.SetFont("uibattlesmall")
    actor.NameText.Scale(.6,.6)
    actor.NameText.SetParent(actor.UI);
    actor.NameText.SetAnchor(.5,1)

    actor.Exhaustion = 0;

    actor.AttackType = "Default"

    local nameX = 15;
    if name:len() <= 3 then
        nameX = 25
    end

    actor.NameText.SetText("[instant]" ..name:upper())
    actor.NameText.MoveTo(nameX,10)

    actor.HealthBar = CreateBar(0,0, 40, 15)
    actor.HealthBar.background.SetParent(actor.UI);
    actor.HealthBar.background.SetAnchor(0,1);
    actor.HealthBar.background.MoveTo(65, -24)

    actor.ManaBar = CreateBar(0,0, 40, 3)
    actor.ManaBar.background.SetParent(actor.UI);
    actor.ManaBar.background.SetAnchor(0,1);
    actor.ManaBar.background.MoveTo(65, -24)
    actor.ManaBar.fill.color = {0,.5,1}

    actor.HealthText = CreateText("[instant]7/7", {0,0}, 100, "BelowArena")
    actor.HealthText.color = {1,1,1}
    actor.HealthText.progressmode = "none"
    actor.HealthText.deleteWhenFinished = false
    actor.HealthText.HideBubble()

    actor.HealthText.SetFont("uidialog")
    actor.HealthText.Scale(.6,.6)
    actor.HealthText.SetParent(actor.UI);
    actor.HealthText.SetAnchor(0,1)
    actor.HealthText.MoveTo(120,10)

    actor.HealthText.SetText("[instant]" ..hp .."/" ..hp)   
    table.insert(BugTaleCharacters.Actors, actor);

    return #BugTaleCharacters.Actors;
end

function BugTaleCharacters.SetActorAttack(actorID, attacktype)
    BugTaleCharacters.Actors[actorID].AttackType = attacktype
end

function BugTaleCharacters.RegisterAttackType(name, slashSound, hitSound, animation, frequency)
    BugTaleCharacters.AttackTypes[name] = {slashSound, hitSound, animation, frequency}
end

function BugTaleCharacters.SetCurrentAttackType(name)
    local data = BugTaleCharacters.AttackTypes[name];
    assert(data, "Could not find Attack Type with name " ..name ..". Did you forget to register a custom attack type?");

    SlashSound = data[1];
    HitSound = data[2];

    Player.SetAttackAnim(data[3], data[4]);
end

BugTaleCharacters.RegisterAttackType("Default", "slice_actual", "hitsound_actual", {"UI/Battle/spr_slice_o_0", "UI/Battle/spr_slice_o_1", "UI/Battle/spr_slice_o_2", "UI/Battle/spr_slice_o_3", "UI/Battle/spr_slice_o_4", "UI/Battle/spr_slice_o_5"}, .25)
BugTaleCharacters.RegisterAttackType("Ice", "ice_hit", "hitsound_actual", {"Effects/AttackIce/1", "Effects/AttackIce/2", "Effects/AttackIce/3", "Effects/AttackIce/4"}, .1)
BugTaleCharacters.RegisterAttackType("Slash", "slice_actual", "hitsound_actual", {"Effects/AttackSlash/1", "Effects/AttackSlash/2", "Effects/AttackSlash/3"}, .2)
BugTaleCharacters.RegisterAttackType("Strike", "strike_hit", "hitsound_actual", {"Effects/AttackStrike/1", "Effects/AttackStrike/2", "Effects/AttackStrike/3", "Effects/AttackStrike/4"}, .15)

function BugTaleCharacters.SetOtherMenuActions(actions)
    BugTaleCharacters.OtherMenuActions = actions
end

function BugTaleCharacters.SetInventory(actions)
    BugTaleCharacters.PartyItems = actions
end

function BugTaleCharacters.GetCurrentActor()
    return BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor]
end

function BugTaleCharacters.RegisterAdditionalActions(actions)
    -- This is useful for making actions that only appear later on...
    BugTaleCharacters.AdditionalActions = actions
end

-- Provide a table of {target, damage?}. If damage provided is 0 or not provided, it is calculated with your normal ATK values.
function BugTaleCharacters.CreateAttacks(values)
    local waitFrames = 180
    local existingTargets = {};
    local largest = 1;

    for i,x in pairs(values) do
        if existingTargets[x[1]] then
            table.insert(existingTargets[x[1]], x[2])
            if #existingTargets[x[1]] > largest then
                largest = #existingTargets[x[1]]
            end
        else
            existingTargets[x[1]] = {x[2]};
        end
    end

    waitFrames = waitFrames + (largest - 1) * 60;
    
    BattleDialog("[noskip][novoice][color:000000][func:State,NONE][next]")
    BugTaleCharacters.QueuedAttacks = existingTargets;
    BugTaleCharacters.AttackTimerStart = waitFrames;
    BugTaleCharacters.AttackTimer = waitFrames;
end

function BugTaleCharacters.ChangeActor(newActor)
    if newActor then
        BugTaleCharacters.CurrentActor = newActor;

        -- New event to listen to.
        local actorData = BugTaleCharacters.Actors[newActor];
        if actorData and actorData.OnActorTurn then
            actorData.OnActorTurn(newActor)
        end
    else
        --Find the best possible actor.
        local currentActor = BugTaleCharacters.GetCurrentActor()
        if not currentActor or currentActor.Turns <= 0 or currentActor.Health <= 0 then
            local toSelect = -1

            for i,x in pairs(BugTaleCharacters.Actors) do
                if x.Health > 0 and x.Turns > 0 then
                    toSelect = i;
                    break;
                end
            end

            BugTaleCharacters.CurrentActor = toSelect

            -- New event to listen to.
            local actorData = BugTaleCharacters.Actors[toSelect];
            if actorData and actorData.OnActorTurn then
                actorData.OnActorTurn(newActor)
            end
        end
    end

    for i,x in pairs(BugTaleCharacters.Actors) do
        if BugTaleCharacters.CurrentActor == i then
            x.HighlightActor = true
        else
            x.HighlightActor = false
        end
    end

    BugTaleCharacters.ActorAnimationTimer = 15

    if BugTaleCharacters.CurrentActor == -1 then
        BugTaleCharacters.UIAnimationTimer = 30;
    else
        local data = BugTaleCharacters.GetCurrentActor();
        BugTaleCharacters.SetCurrentAttackType(BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor].AttackType);
        Player.atk = math.max(0, data.ATK - (data.Exhaustion * 2));
    end
end

function BugTaleCharacters.CreateTextVisual(x, y, input, color)
    local text = CreateText("[instant]", {0,0}, 300, "Top")
    text.color = color or {1,1,1,1};
    text.progressmode = "none"
    text.deleteWhenFinished = false
    text.HideBubble()

    text.SetFont("uibattlesmall")
    text.Scale(1,1)
    text.SetAnchor(.5,.5)
    text.MoveTo(x,y)

    text.Scale(1.5,1.5)

    text.SetText("[instant]" ..input)
    
    table.insert(BugTaleCharacters.TextVisuals, {text, 75})
end

function BugTaleCharacters.RegisterActionProperty(properties)
    --[[
        Properties format: (? means optional)
        Name: string, -- The identifier for this action.
        DisplayName: string, -- How the action will appear in the menu.

        MPCost: number?, --Defaults to 0.
        AdditionalActors: number[]?, --What other actors will lose their turn if this action is executed. Defaults to nil.
        OnExecuted: function()?: any, -- The function to execute. Can be set to nil if not implemented yet.
        ConditionCheck: function()?: boolean, -- The function to execute before target selection algorithm. Returns condition success boolean.
        IsConsumable: boolean? -- Defaults to false, whether or not the action is removed from PartyItems list when used. Should only be used for items.
        Target: string -- Defaults to "AUTO". Possible values: "ALLIES", "OTHERALLIES", "ALIVEALLIES", "DOWNEDALLIES", "ENEMIES" and "AUTO".
    ]]

    if not properties.OnExecuted then
        properties.OnExecuted = function()
            BattleDialog("This action hasn't been implemented yet.")
        end
    end

    BugTaleCharacters.ActionProperties[properties.Name] = properties;
end

function BugTaleCharacters.HandleAction(actionID)
    local action = BugTaleCharacters.ActionProperties[actionID]

    if actionID == "Turn Relay" and BugTaleCharacters.GetCurrentActor().Relayed then
        BattleDialog({"You already turn relayed this turn.", "[noskip][func:State," .."ACTIONSELECT" .."][next]"})
        return
    end

    if action then
        if action.ConditionCheck then
            local result = action.ConditionCheck(BugTaleCharacters.GetCurrentActor(), BugTaleCharacters.CurrentActor)
            if(not result) then return end;
        end

        if action.MPCost then
            if BugTaleCharacters.GetCurrentActor().Mana < action.MPCost then
                return
            end
        end
        
        if action.AdditionalActors then
            local unavailableActors = {};
            
            for i,x in pairs(action.AdditionalActors) do
                local actor = nil;

                for _,k in pairs(BugTaleCharacters.Actors) do
                    if k.Name == x then
                        actor = k
                        break;
                    end
                end

                if actor.Health <= 0 or actor.Turns <= -1 then
                    table.insert(unavailableActors, actor.Name)
                end
            end

            if #unavailableActors > 0 then
                local concatted = "";

                if #unavailableActors == 1 then
                    concatted = unavailableActors[1] .." is unable to act!"
                else
                    for i,x in pairs(unavailableActors) do
                        if i == #unavailableActors - 1 then
                            concatted = concatted  ..x .." and "
                        elseif i == #unavailableActors then
                            concatted = concatted .. x
                        else
                            concatted = concatted .. x .. ", "
                        end
                    end

                    concatted = concatted .. " are unable to act!";
                end

                BattleDialog({concatted, "[noskip][func:State," .."ACTIONSELECT" .."][next]"})
                return
            end
        end

        BugTaleCharacters.QueuedAction = action
        BugTaleCharacters.QueuedActionID = action.Name
        local target = action.Target or "AUTO"
        if target ~= "AUTO" then
            BugTaleCharacters.CreateTargetSelection(target)
        else
            State("PAUSE")
            if BugTaleCharacters.QueuedAction.MPCost and BugTaleCharacters.QueuedAction.MPCost > 0 then
                BugTaleCharacters.ChangeMP(BugTaleCharacters.GetCurrentActor(), -BugTaleCharacters.QueuedAction.MPCost)
            end
            if BugTaleCharacters.QueuedAction.AdditionalActors then
                for i,x in pairs(BugTaleCharacters.QueuedAction.AdditionalActors) do
                    local actor = nil;

                    for _,k in pairs(BugTaleCharacters.Actors) do
                        if k.Name == x then
                            actor = k
                            break;
                        end
                    end

                    actor.Turns = actor.Turns - 1;

                    actor.HighlightActor = true
                end

                BugTaleCharacters.ActorAnimationTimer = 15;
            end
            if BugTaleCharacters.QueuedAction.IsConsumable then
                for i,x in pairs(BugTaleCharacters.PartyItems) do
                    if x == BugTaleCharacters.QueuedActionID then
                        table.remove(BugTaleCharacters.PartyItems, i)
                        break
                    end
                end
            end
            BugTaleCharacters.QueuedAction.OnExecuted(BugTaleCharacters.GetCurrentActor(), BugTaleCharacters.CurrentActor, -1);
        end
    end
end

function BugTaleCharacters.DisplayActionSelectPage()

    for i,x in pairs(BugTaleCharacters.ActiveActions) do
        local properties = BugTaleCharacters.ActionProperties[x];
        if properties.BeforeMenu then
            properties.BeforeMenu(BugTaleCharacters.GetCurrentActor(), BugTaleCharacters.CurrentActor, properties);
        end
    end

    local page = math.ceil((BugTaleCharacters.SelectionUIIndex) / 4) - 1;
    local firstIndex = page * 4 + 1;
    local lastIndex = firstIndex + 3;

    local maxPages = math.ceil(#BugTaleCharacters.ActiveActions / 4);
    if(maxPages > 1) then
        BugTaleCharacters.PageText.SetText("[instant]PAGE " ..page + 1 .."/" ..maxPages);
    else
        BugTaleCharacters.PageText.SetText("[instant]");
    end

    for i,x in pairs(BugTaleCharacters.ActiveActionImages) do
        x.Remove()
    end

    BugTaleCharacters.ActiveActionImages = {};

    local j = 0;
    for i=firstIndex, lastIndex do
        local actionName = BugTaleCharacters.ActiveActions[i];
        local actionData = BugTaleCharacters.ActionProperties[actionName];
        local textObj = BugTaleCharacters.ActionSelectionTexts[4 - (lastIndex - i)]

        local row = math.floor(j / 2);
        local column = j % 2;
        
        local absx = 92 + column * 265;
        local absy = 183 - row * 30;

        if not actionName or not actionData then
            textObj.SetText("[noskip][instant]");
        else
            local failed = false;
            local totalWidth = 0;
            local extra = "";

            if actionData.AdditionalActors and #actionData.AdditionalActors > 0 then
                for i=1, #actionData.AdditionalActors do
                    local actor = nil;

                    for k,x in pairs(BugTaleCharacters.Actors) do
                        if x.Name == actionData.AdditionalActors[i] then
                            if k == BugTaleCharacters.CurrentActor then
                                error("Character tries to teamwork attack with themselves.")
                                break;
                            end

                            actor = x;
                            break;
                        end
                    end

                    if not actor then
                        failed = true
                        error("Tried to find additional actor but couldn't find one.");
                        break
                    end

                    if(#actionData.AdditionalActors == 1) then
                        extra = "[color:" ..actor.HexColor .."]";
                    end

                    
                    local image = CreateSprite(actor.AssetsFolder .. "/dialog", "BelowPlayer");
                    image.SetPivot(.5,0);
                    image.MoveToAbs(absx + totalWidth + 10, absy)

                    totalWidth = totalWidth + image.width;
                    
                    table.insert(BugTaleCharacters.ActiveActionImages, image);
                end
                absx = absx + totalWidth + 16;
            end

            textObj.SetText("[noskip][instant]" ..extra ..actionData.DisplayName .."[color:FFFFFF]");
        end

        textObj.MoveTo(absx, absy)
        j = j + 1;
    end

    local currentAction = BugTaleCharacters.ActionProperties[BugTaleCharacters.ActiveActions[BugTaleCharacters.SelectionUIIndex]];
    if currentAction.MPCost and currentAction.MPCost > 0 then
        if BugTaleCharacters.GetCurrentActor().Mana < currentAction.MPCost then
            BugTaleCharacters.MPCostText.color = {1,0,0}
        else
            BugTaleCharacters.MPCostText.color = {1,1,1}
        end
        BugTaleCharacters.MPCostText.SetText("[noskip][instant]" ..currentAction.MPCost .."/" ..BugTaleCharacters.GetCurrentActor().Mana .." MP")
        
        if not BugTaleCharacters.MPCostVisible then
            BugTaleCharacters.MPCostVisible = true
            BugTaleCharacters.ActionSelectMPCostAnimation = 15
        end
    elseif BugTaleCharacters.MPCostVisible then
        BugTaleCharacters.MPCostVisible = false
        BugTaleCharacters.ActionSelectMPCostAnimation = 15
    end

    if currentAction.Description then
        BugTaleCharacters.SkillDescriptionTXT.SetText("[instant]" .. currentAction.Description)
    else
        BugTaleCharacters.SkillDescriptionTXT.SetText("[instant]")
    end

    local localIndex = (BugTaleCharacters.SelectionUIIndex - 1) % 4;
    local column = localIndex % 2;
    local row = math.floor(localIndex / 2);

    local absx = 92 + column * 265;
    local absy = 183 - row * 30;

    Player.MoveToAbs(absx - 27, absy + 7)
end

function BugTaleCharacters.StartActionSelectSequence()
    State("NONE")

    BugTaleCharacters.MPCostVisible = false;
    BugTaleCharacters.MPCostBG.MoveTo(BugTaleCharacters.MPCostBG.absx, 94)
    BugTaleCharacters.MPCostBG.alpha = 1;
    BugTaleCharacters.MPCostText.alpha = 1;

    BugTaleCharacters.RevertState = "SKILLSELECT"
    BugTaleCharacters.SelectionUIIndex = 1;
    
    BattleDialog("[noskip][novoice][alpha:0][func:State,SKILLSELECT][next]")
    
    for i,x in pairs(BugTaleCharacters.ActiveActions) do
        local properties = BugTaleCharacters.ActionProperties[x];
        if properties.BeforeMenu then
            properties.BeforeMenu(BugTaleCharacters.GetCurrentActor(), BugTaleCharacters.CurrentActor, properties);
        end
    end
    
    BugTaleCharacters.DisplayActionSelectPage();
    BugTaleCharacters.SkillDescriptionTXT.alpha = 1;

    BugTaleCharacters.SelectionHeart.alpha = 1;
    BugTaleCharacters.ActionSelectionActive = true;
end

function BugTaleCharacters.StopActionSelect()
    BugTaleCharacters.ActionSelectionActive = false;

    BugTaleCharacters.MPCostVisible = false;
    BugTaleCharacters.MPCostBG.alpha = 0;
    BugTaleCharacters.MPCostText.alpha = 0;
    BugTaleCharacters.SkillDescriptionTXT.alpha = 0

    BugTaleCharacters.SelectionHeart.alpha = 0;

    for i,x in pairs(BugTaleCharacters.ActionSelectionTexts) do
        x.SetText("[noskip][instant][next]")
    end

    for i,x in pairs(BugTaleCharacters.ActiveActionImages) do
        x.Remove()
    end

    BugTaleCharacters.PageText.SetText("[instant]");

    BugTaleCharacters.ActiveActionImages = {};
end

function AfterAttack()
    Audio.PlaySound(HitSound);

    --[[
    if GetCurrentState() == "ATTACKING" then
        if Player.lasthitmultiplier > 1.8 then
            ChangeTP(6)
        end
    end
    ]]--
end

function IncreaseBugTaleEXP(exp)
    BugTaleCharacters.XPGained = BugTaleCharacters.XPGained + exp
end

function BugTaleCharacters.EnteringState(new, old)
    --[[
    if new == "DIALOGRESULT" and BugTaleCharacters.ActionSelectionActivating then
        BugTaleCharacters.ActionSelectionActivating = false;
        State("SKILLSELECT")
        return
    end
    --]]

    if new == "DIALOGRESULT" then
        local battleEnded = true
        local totalGold = 0;
        for i,x in pairs(enemies) do
            if x.GetVar("isactive") then
                battleEnded = false
                break
            else
                totalGold = totalGold + (x.GetVar("bugtale_GOLD") or 0)
            end
        end
        
        if battleEnded then
            State("NONE")
            BugTaleCharacters.GoldGained = totalGold
    
            if BeforeEnd then
                BeforeEnd()
            end
            
            if OnSave then
                BattleDialog({"YOU WON!\nYou earned " ..BugTaleCharacters.XPGained .." XP and " ..totalGold .." gold.", "[noskip][novoice][alpha:0][func:State,NONE][func:OnSave]"})
            else
                BattleDialog({"YOU WON!\nYou earned " ..BugTaleCharacters.XPGained .." XP and " ..totalGold .." gold.", "[noskip][func:State,DONE]"})
            end
        end
    end

    if new ~= "PAUSE" and new ~= "SKILLSELECT" and BugTaleCharacters.ActionSelectionActive then
        BugTaleCharacters.StopActionSelect();
    end

    if new == "ACTIONSELECT" then
        for i,x in pairs(BugTaleCharacters.TargetSelectionMercyBars) do
            x.SetVisible(false);
        end
    end

    if new == "ENEMYSELECT" then
        if UI.GetCurrentButton() == "ACT" then
            BugTaleCharacters.ActiveActions = BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor].Actions;
            BugTaleCharacters.StartActionSelectSequence()
            SetAction("ACT")
        else
            SetAction("FIGHT")

            --We should show mercy progress.
            local LOCALINDEX = 0;

            for i,x in pairs(enemies) do
                if x.GetVar("isactive") then
                    LOCALINDEX = LOCALINDEX + 1;
                    if x.GetVar("was_spied") and x.GetVar("spare_progress") then
                        BugTaleCharacters.TargetSelectionMercyBars[LOCALINDEX].SetVisible(true)
                        BugTaleCharacters.TargetSelectionMercyBars[LOCALINDEX].SetInstant(x.GetVar("spare_progress") / 100);
                    end
                end
            end
        end
    elseif new == "ACTMENU" then
        BugTaleCharacters.ActiveActions = BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor].Actions;
        BugTaleCharacters.StartActionSelectSequence()
    elseif new == "MERCYMENU" then
        BugTaleCharacters.ActiveActions = BugTaleCharacters.OtherMenuActions;
        BugTaleCharacters.StartActionSelectSequence()
    elseif new == "ITEMMENU" then
        if #BugTaleCharacters.PartyItems == 0 then
            BugTaleCharacters.RevertState = "ACTIONSELECT"
            State("ACTIONSELECT")
        else
            BugTaleCharacters.ActiveActions = BugTaleCharacters.PartyItems;
            BugTaleCharacters.StartActionSelectSequence()
        end
    elseif new == "ATTACKING" then
        BugTaleCharacters.TargetSelected = Player.lastenemychosen;

        for i,x in pairs(BugTaleCharacters.TargetSelectionMercyBars) do
            x.SetVisible(false);
        end
    end
end

function BugTaleCharacters.EnemyDialogEnd()
    if BugTaleCharacters.DialogSequence then
        State("NONE");
        table.remove(BugTaleCharacters.SpyDialogText, 1);

        BugTaleCharacters.DialogSequencePaused = false
    end
end

function BugTaleCharacters.ActorFinish() -- Turns true if it is the enemy's turn.
    BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor].LastButton = UI.GetCurrentButton();
    local enemiesAlive = false;
    for _,x in pairs(enemies) do
        if x.GetVar("isactive") then
            enemiesAlive = true
        end
    end

    if not enemiesAlive then
        State("DIALOGRESULT")
        State("PAUSE")
        return false
    end

    if QueuedSpyDialog then
        State("NONE")

        BugTaleCharacters.SpyDialogText = QueuedSpyDialog;
        QueuedSpyDialog = nil;
        return false
    end

    if BugTaleCharacters.DialogSequence then
        --We will display the enemy dialog.
        Arena.Resize(565, 130)

        local wantedIndex = BugTaleCharacters.SpyDialogText[1][3];
        if wantedIndex == 0 then
            local alive = 0;
            for i,x in pairs(enemies) do
                if x.GetVar("isactive") then
                    alive = alive + 1;
                    if alive == TargetSelected then
                        wantedIndex = i
                        break
                    end
                end
            end
        end

        for i,x in pairs(enemies) do
            if x.GetVar("isactive") then
                if i == wantedIndex then
                    x.SetVar("currentdialogue", BugTaleCharacters.SpyDialogText[1][2]);
                else
                    x.SetVar("currentdialogue", {"[noskip][instant]"})
                end
            end
        end

        return false;
    end

    if BugTaleCharacters.CurrentActor ~= -1 then
        BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor].Turns = BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor].Turns - 1; -- Used up their turn.
        BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor].Exhaustion = BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor].Exhaustion + 1; -- Getting exhausted.

        BugTaleCharacters.ChangeActor()

        if BugTaleCharacters.CurrentActor ~= -1 then
            State("ACTIONSELECT")
            SetAction(BugTaleCharacters.Actors[BugTaleCharacters.CurrentActor].LastButton)

            return false
        end
    end

    return true
end

function BugTaleCharacters.HealAll(amount, disableSound)
    if not disableSound then
        Audio.PlaySound("healsound")
    end

    for i=1, #BugTaleCharacters.Actors do
        BugTaleCharacters.HealActor(i, amount, true)
    end
end

function BugTaleCharacters.TurnBegin()
    BugTaleCharacters.TargetNext = nil;
    BugTaleCharacters.EnemyTargeting = nil;

    local healSFX = false;
    for i,x in pairs(BugTaleCharacters.Actors) do
        x.Relayed = false;
        x.Exhaustion = 0;
        if x.Turns < 1 then
            x.Turns = x.Turns + 1;
        end

        if x.Health <= 0 then
            BugTaleCharacters.HealActor(i, 1, true);
            healSFX = true
        end

        -- New event to listen to.
        if x.OnTeamTurn then
            x.OnTeamTurn(i)
        end
    end

    if healSFX then
        Audio.PlaySound("healsound")
    end

    BugTaleCharacters.ChangeActor()
    BugTaleCharacters.UIAnimationTimer = 30
end

function BugTaleCharacters.UpdateActorHP(actor)
    local data = BugTaleCharacters.Actors[actor];
    data.HealthBar.SetInstant(math.max(0, data.Health / data.MaxHealth));
    data.HealthText.SetText("[instant]" ..data.Health .."/" ..data.MaxHealth)

    if data.Health > 0 then
        data.UI.color32 = data.Color32;
        data.HealthText.color = {1,1,1}
    else        
        data.UI.color = {.5,.5,.5};
        data.HealthText.color = {1,0,0}
    end
end

function BugTaleCharacters.HealActor(actor, amount, disableSound)
    if not disableSound then
        Audio.PlaySound("healsound")
    end

    local actorData = BugTaleCharacters.Actors[actor];
    local currentHP = actorData.Health;
    local wasDowned = currentHP <= 0
    local newHP = currentHP + amount;

    if newHP > actorData.MaxHealth then
        newHP = actorData.MaxHealth
    end

    if newHP == 0 then
        amount = amount + 1;
        newHP = 1;
    end

    local ui = actorData.UI;

    actorData.Health = newHP
    BugTaleCharacters.UpdateActorHP(actor)

    local spawnX = ui.absx + math.random(0, ui.width);
    local spawnY = ui.absy + math.random(0, ui.height);

    if wasDowned and newHP > 0 then
        actorData.UI.color32 = actorData.Color32;
        BugTaleCharacters.CreateTextVisual(spawnX, spawnY, "UP", {0,1,0,1});
    else
        BugTaleCharacters.CreateTextVisual(spawnX, spawnY, amount, {0,1,0,1});
    end
end

function BugTaleCharacters.ReviveActor(actor, amount, disableSound)
    local target = BugTaleCharacters.Actors[actor];
    local difference = amount - target.Health;

    BugTaleCharacters.HealActor(actor, difference, disableSound);
end

function BugTaleCharacters.DamageActor(actor, amount, disableSound)
    if not disableSound then
        Audio.PlaySound("hurtsound")
    end

    local actorData = BugTaleCharacters.Actors[actor];
    local currentHP = actorData.Health;
    local newHP = currentHP - amount;

    if newHP <= 0 then
        amount = amount + 3;
        newHP = newHP - 3;
    end


    local ui = actorData.UI;
    actorData.Health = newHP
    BugTaleCharacters.UpdateActorHP(actor)
    
    local spawnX = ui.absx + math.random(0, ui.width);
    local spawnY = ui.absy + math.random(0, ui.height);

    if newHP <= 0 then
        BugTaleCharacters.CreateTextVisual(spawnX, spawnY, "DOWNED", {1,0,0,1});

        local alive = false;
        for i,x in pairs(BugTaleCharacters.Actors) do
            if x.Health > 0 then
                alive = true
                break
            end
        end

        if not alive then

            if BeforeGameover then
                BeforeGameover()
            else
                Player.hp = 0
            end

            return
        end

        if BugTaleCharacters.CurrentActor == actor then
            State("ENEMYDIALOGUE")
        end

    else
        BugTaleCharacters.CreateTextVisual(spawnX, spawnY, amount);
    end
end

function BugTaleCharacters.DamageRandom(amount, invulTime)
    if Player.ishurting then return end
    local availableActors = {};

    if BugTaleCharacters.TargetNext then
        for i,x in pairs(BugTaleCharacters.TargetNext) do
            if BugTaleCharacters.Actors[x].Health > 0 then
                table.insert(availableActors, x)
            end
        end
    end

    if #availableActors == 0 then
        for i,x in pairs(BugTaleCharacters.Actors) do
            if x.Health > 0 then
                table.insert(availableActors, i)
            end
        end
    end

    local chosenID = availableActors[math.random(1, #availableActors)];
    local chosenActor = BugTaleCharacters.Actors[chosenID];
    local def = chosenActor.DEF or 0;

    BugTaleCharacters.DamageActor(chosenID, math.max(1, amount - def));
    Player.Hurt(0, invulTime or 1.7, false, true)
end

function BugTaleCharacters.DamageAll(amount, invulTime)
    if Player.ishurting then return end

    Audio.PlaySound("hurtsound")

    for i,x in pairs(BugTaleCharacters.Actors) do
        if x.Health > 0 then
            local def = x.DEF or 0;
            BugTaleCharacters.DamageActor(i, math.max(1, amount - def), true)
        end
    end
    Player.Hurt(0, invulTime or 1.7, false, true)
end

function BugTaleCharacters.DamageTargeted(amount, invulTime)
    if Player.ishurting then return end

    local availableActors = {};

    if BugTaleCharacters.TargetNext then
        for i,x in pairs(BugTaleCharacters.TargetNext) do
            if BugTaleCharacters.Actors[x].Health > 0 then
                table.insert(availableActors, x)
            end
        end
    end

    if #availableActors == 0 and BugTaleCharacters.EnemyTargeting  then
        for i,x in pairs(BugTaleCharacters.EnemyTargeting) do
            if BugTaleCharacters.Actors[x].Health > 0 then
                table.insert(availableActors, x)
            end
        end
    end
    
    if #availableActors == 0 then
        for i,x in pairs(BugTaleCharacters.Actors) do
            if x.Health > 0 then
                table.insert(availableActors, i)
            end
        end
    end

    local chosenID = availableActors[math.random(1, #availableActors)];
    local chosenActor = BugTaleCharacters.Actors[chosenID];
    local def = chosenActor.DEF or 0;

    BugTaleCharacters.DamageActor(chosenID, math.max(1, amount - def));
    Player.Hurt(0, invulTime or 1.7, false, true)
end

function BugTaleCharacters.AddEnemy(scriptName, posX, posY)
    local reference = CreateEnemy(scriptName, posX, posY)
    reference.SetVar("myid", #enemies + 1)

    if reference.GetVar("ConstructSpyMessages") then
        reference.Call("ConstructSpyMessages")
    end

    table.insert(enemies, reference);
end

function BugTaleCharacters.EncounterStarting()
    for i,x in pairs(enemies) do
        x.SetVar("myid", i)

        if x.GetVar("ConstructSpyMessages") then
            x.Call("ConstructSpyMessages")
        end
    end

    CreateState("SKILLSELECT")
    UI.namelv.SetText("[instant]" ..BugTaleCharacters.TeamName:upper() .." LV " ..BugTaleCharacters.TeamLV)
    UI.hplabel.alpha = 0;
    UI.hpbar.SetVisible(false);
    UI.hptext.alpha = 0;

    UI.actbtn.Set("UI/skillbt_0")
    UI.SetButtonActiveSprite("ACT", "UI/skillbt_1")

    UI.mercybtn.Set("UI/otherbt_0")
    UI.SetButtonActiveSprite("MERCY", "UI/otherbt_1")
    UI.SetPlayerXPosOnButton("MERCY", 14)

    BugTaleCharacters.ChangeActor(1);
    Inventory.SetInventory({"Butterscotch Pie"}); -- Just so inventory button works.
    State("ACTIONSELECT")
end

function BugTaleCharacters.ChangeMP(actor, amount)
    actor.Mana = math.max(0, math.min(actor.Mana + amount, actor.MaxMana));
    actor.ManaBar.SetInstant(math.max(0, actor.Mana / actor.MaxMana));

    if(amount > 0) then
        local ui = actor.UI;
        local spawnX = ui.absx + math.random(0, ui.width);
        local spawnY = ui.absy + math.random(0, ui.height);

        BugTaleCharacters.CreateTextVisual(spawnX, spawnY, amount, {0, .5, 1, 1});
    end
end

function BugTaleCharacters.SkipToEnemyDialogue()
    for i,x in pairs(BugTaleCharacters.Actors) do
        x.Turns = math.min(0, x.Turns);

        if i == BugTaleCharacters.CurrentActor then
            x.Turns = 1;
        end
    end

    State("ENEMYDIALOGUE")
end

function BugTaleCharacters.Update()
    
    if BugTaleCharacters.ActionSelectMPCostAnimation > 0 then
        BugTaleCharacters.ActionSelectMPCostAnimation = BugTaleCharacters.ActionSelectMPCostAnimation - 1;
        local ratio = 1 - BugTaleCharacters.ActionSelectMPCostAnimation / 15;
        local startAt = 52;
        local destination = 94;

        if BugTaleCharacters.MPCostVisible then
            startAt = 94;
            destination = 52;
        end

        local travel = destination - startAt;
        local newY = startAt + travel * math.sin(ratio * (math.pi / 2));
        BugTaleCharacters.MPCostBG.MoveTo(BugTaleCharacters.MPCostBG.absx, newY);
    end

    if BugTaleCharacters.CurrentTargetIndex > 0 then
        local old = BugTaleCharacters.CurrentTargetIndex;
        if Input.Up == 1 then
            BugTaleCharacters.CurrentTargetIndex = BugTaleCharacters.CurrentTargetIndex - 1;

            if BugTaleCharacters.CurrentTargetIndex == 0 then
                BugTaleCharacters.CurrentTargetIndex = #BugTaleCharacters.TargetSelectionValues
            end
        elseif Input.Down == 1 then
            BugTaleCharacters.CurrentTargetIndex = BugTaleCharacters.CurrentTargetIndex + 1;

            if BugTaleCharacters.CurrentTargetIndex > #BugTaleCharacters.TargetSelectionValues then
                BugTaleCharacters.CurrentTargetIndex = 1
            end
        end

        if old ~= BugTaleCharacters.CurrentTargetIndex then
            BugTaleCharacters.UpdateTargetSelection();
        end

        if Input.Confirm == 1 then
            BugTaleCharacters.TargetSelected = BugTaleCharacters.TargetSelectionValues[BugTaleCharacters.CurrentTargetIndex][3];
            BugTaleCharacters.CurrentTargetIndex = 0;
            BugTaleCharacters.HideTargetSelection();

            if(BugTaleCharacters.QueuedAction) then
                if BugTaleCharacters.QueuedAction.MPCost and BugTaleCharacters.QueuedAction.MPCost > 0 then
                    BugTaleCharacters.ChangeMP(BugTaleCharacters.GetCurrentActor(), -BugTaleCharacters.QueuedAction.MPCost)
                end
                if BugTaleCharacters.QueuedAction.AdditionalActors then
                    for i,x in pairs(BugTaleCharacters.QueuedAction.AdditionalActors) do
                        local actor = nil;

                        for _,k in pairs(BugTaleCharacters.Actors) do
                            if k.Name == x then
                                actor = k
                                break;
                            end
                        end
                        actor.Turns = actor.Turns - 1;
    
                        actor.HighlightActor = true
                    end
    
                    BugTaleCharacters.ActorAnimationTimer = 15;
                end
                if BugTaleCharacters.QueuedAction.IsConsumable then
                    for i,x in pairs(BugTaleCharacters.PartyItems) do
                        if x == BugTaleCharacters.QueuedActionID then
                            table.remove(BugTaleCharacters.PartyItems, i)
                            break
                        end
                    end
                end
                BugTaleCharacters.QueuedAction.OnExecuted(BugTaleCharacters.GetCurrentActor(), BugTaleCharacters.CurrentActor, BugTaleCharacters.TargetSelected)
            end
        elseif Input.Cancel == 2 then
            BugTaleCharacters.TargetSelected = 0;
            BugTaleCharacters.CurrentTargetIndex = 0;
            BugTaleCharacters.HideTargetSelection();

            if BugTaleCharacters.RevertState == "SKILLSELECT" then
                BugTaleCharacters.DisplayActionSelectPage();
            end

            State(BugTaleCharacters.RevertState)
        end
    elseif BugTaleCharacters.ActionSelectionActive then
        local amount = #BugTaleCharacters.ActiveActions
        --local lastPage = math.ceil(amount / 4);
        --local currentPage = math.ceil((BugTaleCharacters.SelectionUIIndex - 1) / 4);

        local isEven = BugTaleCharacters.SelectionUIIndex % 2 == 0;
        local starting = BugTaleCharacters.SelectionUIIndex;

        if Input.Right == 1 then
            if isEven then
                if BugTaleCharacters.SelectionUIIndex + 3 <= amount then
                    BugTaleCharacters.SelectionUIIndex = BugTaleCharacters.SelectionUIIndex + 3;
                else
                    BugTaleCharacters.SelectionUIIndex = ((BugTaleCharacters.SelectionUIIndex - 1) % 4);
                end
            else
                if BugTaleCharacters.SelectionUIIndex + 1 <= amount then
                    BugTaleCharacters.SelectionUIIndex = BugTaleCharacters.SelectionUIIndex + 1;
                end
            end
        end

        if Input.Left == 1 then
            if not isEven then
                if BugTaleCharacters.SelectionUIIndex - 3 >= 1 then
                    BugTaleCharacters.SelectionUIIndex = BugTaleCharacters.SelectionUIIndex - 3;
                end
            else
                BugTaleCharacters.SelectionUIIndex = BugTaleCharacters.SelectionUIIndex -1;
            end
        end

        if Input.Up == 1 or Input.Down == 1 then
            local a = ((BugTaleCharacters.SelectionUIIndex - 1) % 4) + 1
            if a < 3 then
                if BugTaleCharacters.SelectionUIIndex + 2 <= amount then
                    BugTaleCharacters.SelectionUIIndex = BugTaleCharacters.SelectionUIIndex + 2;
                end
            else
                BugTaleCharacters.SelectionUIIndex = BugTaleCharacters.SelectionUIIndex - 2;
            end
        end
        
        if GetCurrentState() == "SKILLSELECT" then
            if Input.Confirm == 1 then
                debounce = true
                Audio.PlaySound("menuconfirm");
                BugTaleCharacters.HandleAction(BugTaleCharacters.ActiveActions[BugTaleCharacters.SelectionUIIndex])
            elseif Input.Cancel == 1 then
                State("ACTIONSELECT")
                RevertState = "ACTIONSELECT"
            end
        end

        if starting ~= BugTaleCharacters.SelectionUIIndex then
            Audio.PlaySound("menumove");
            BugTaleCharacters.DisplayActionSelectPage();
        end
    end

    if BugTaleCharacters.ActorAnimationTimer > 0 then
        BugTaleCharacters.ActorAnimationTimer = BugTaleCharacters.ActorAnimationTimer - 1;
        if BugTaleCharacters.ActorAnimationTimer == 14 then
            -- Animation just started.
            for _,x in pairs(BugTaleCharacters.Actors) do
                x.StartY = x.Portrait.y;
            end
        end

        local ratio = 1 - (BugTaleCharacters.ActorAnimationTimer / 15);
        
        for _,x in pairs(BugTaleCharacters.Actors) do
            local portrait = x.Portrait;
            local startY = x.StartY;
            local destination = 0;
            
            if not x.HighlightActor then
                destination = -portrait.height
            end

            local travel = startY - destination;
            local newY = startY - (travel *  ratio)
            portrait.MoveTo(0, newY)
        end
    end

    if BugTaleCharacters.UIAnimationTimer > 0 then
        BugTaleCharacters.UIAnimationTimer = BugTaleCharacters.UIAnimationTimer - 1;
        local ratio = 1 - (BugTaleCharacters.UIAnimationTimer / 30);

        local destination = 225
        local start = 54

        if BugTaleCharacters.CurrentActor == -1 then
            destination = 54
            start = 225

            UI.namelv.alpha = 1 - ratio;
        else
            actor_animation_timer = 15
            UI.namelv.alpha = ratio;
        end


        local travel = start - destination;
        local newY = start - (travel *  ratio);
        
        -- Move all uis.
        for _,x in pairs(BugTaleCharacters.Actors) do
            x.UI.MoveTo(x.UI.x, newY)
        end
    end

    for i=#BugTaleCharacters.TextVisuals, 1, -1 do
        local data = BugTaleCharacters.TextVisuals[i];
        local text = data[1];
        local lifetime = data[2];
        
        lifetime = lifetime - 1;
        data[2] = lifetime;

        for i,x in pairs(text.GetLetters()) do
            x.Move(0,.1)
        end

        if lifetime <= 30 then
            local r = lifetime / 30;
            local yScale = 1.5 + ( (1 - r) * 3);


            text.alpha = r;
            text.Scale(1.5, yScale)
            for i,x in pairs(text.GetLetters()) do
                x.Move(0,.3)
            end

            if lifetime == 0 then
                text.Remove()
                table.remove(BugTaleCharacters.TextVisuals, i)
            end
        end
    end

    if #BugTaleCharacters.SpyDialogText > 0 then
        BugTaleCharacters.DialogSequence = true
        if not BugTaleCharacters.DialogSequencePaused then
            if BugTaleCharacters.DialogBox then
                if BugTaleCharacters.DialogBox.isactive then
                    local ui = BugTaleCharacters.Actors[BugTaleCharacters.SpyDialogText[1][1]].Portrait;
                    BugTaleCharacters.DialogBox.MoveTo(ui.absx - ui.width - 20, ui.absy + 100)
                else
                    table.remove(BugTaleCharacters.SpyDialogText, 1)
                    BugTaleCharacters.DialogBox = nil
                end
            else
                if not BugTaleCharacters.SpyDialogText[1][3] then
                    local actor = BugTaleCharacters.SpyDialogText[1][1];
                    local messages = BugTaleCharacters.SpyDialogText[1][2];

                    local ui = BugTaleCharacters.Actors[actor].Portrait

                    for i,x in pairs(BugTaleCharacters.Actors) do
                        if i == actor then
                            x.HighlightActor = true
                        else
                            x.HighlightActor = false
                        end
                    end
                    BugTaleCharacters.ActorAnimationTimer = 15

                    BugTaleCharacters.DialogBox = CreateText(messages, {ui.absx - ui.width - 20, ui.absy + 100}, 180, "Top", 50);
                    BugTaleCharacters.DialogBox.SetTail("down");
                    BugTaleCharacters.DialogBox.progressmode = "manual"
                    BugTaleCharacters.DialogBox.deleteWhenFinished = true

                    BugTaleCharacters.DialogBox.SetVoice(BugTaleCharacters.Actors[actor].Voice)
                else
                    BugTaleCharacters.DialogSequencePaused = true;

                    for i,x in pairs(BugTaleCharacters.Actors) do
                        x.HighlightActor = false;
                    end

                    BugTaleCharacters.ActorAnimationTimer = 15;

                    State("ENEMYDIALOGUE")
                end
            end
        end
    elseif BugTaleCharacters.DialogSequence then
        BugTaleCharacters.DialogSequence = false
        BugTaleCharacters.DialogBox = nil;

        local current = GetCurrentState();

        if current ~= "DIALOGRESULT" then
            State("ENEMYDIALOGUE")
        end
    end

    if BugTaleCharacters.AttackTimer > 0 then
        local elapsed = BugTaleCharacters.AttackTimerStart - BugTaleCharacters.AttackTimer;
        if elapsed % BugTaleCharacters.AttackFrequency == 0 then
            -- Do the attacks!
            for i,x in pairs(BugTaleCharacters.QueuedAttacks) do
                if x and #x > 0 then
                    local atk = Player.atk;
                    if x[1] then
                        atk = x[1]
                    end

                    local k = 0;
                    local enemyOBJ;
                    for _, enemy in pairs(enemies) do
                        if enemy.GetVar("isactive") then
                            k = k + 1;
                            
                            if k == i then
                                enemyOBJ = enemy
                                break
                            end
                        end
                    end
                    
                    -- GRABBED FROM CYF GITHUB.
                    Player.ForceAttack(i, math.max(1, math.floor((atk - enemyOBJ.GetVar("def") + math.random() * 2) * 2.2)));
                    
                    table.remove(x, 1)
                    
                    if #x == 0 then
                        BugTaleCharacters.QueuedAttacks[i] = nil;
                    end
                end
            end
        end

        BugTaleCharacters.AttackTimer = BugTaleCharacters.AttackTimer - 1;

        if BugTaleCharacters.AttackTimer == 0 then
            local enemiesAlive = false;
            for _,x in pairs(enemies) do
                if x.GetVar("isactive") then
                    if x.GetVar("hp") <= 0 then
                        if x.GetVar("OnDeath") then
                            local isAlive = x.Call("OnDeath")
                            if isAlive then
                                enemiesAlive = true;
                            end
                        elseif not x.GetVar("unkillable") then
                            x.Call("Kill")
                        end
                    else
                        enemiesAlive = true
                    end
                end
            end

            Player.CheckDeath()

            if enemiesAlive then
                State("ENEMYDIALOGUE")
            else
                State("DIALOGRESULT")
            end
        end
    end
end

function ChangeSpareProgress(targetID, amount) --this ID is the position of the enemy in the enemies table. Do not use negative numbers.
    local enemyScript = enemies[targetID];
    
    local spareProgress = enemyScript.GetVar("spare_progress");
    local wasSpied = enemyScript.GetVar("was_spied");
    local enemySprite = enemyScript.GetVar("monstersprite");

    local enemyX = enemySprite.absx - enemySprite.width / 2;
    local enemyY = enemySprite.absy + enemySprite.height / 2;

    local text = "+???%";
    local color = {.5,.5,.5};

    if spareProgress then
        spareProgress = math.min(100, spareProgress + amount);
        enemyScript.SetVar("spare_progress", spareProgress)
        if wasSpied then
            text = "+" ..amount .."%";
            color = {1,.8,0};
        end

        if spareProgress == 100 then
            enemyScript.SetVar("canspare", true)
        end
    else
        if wasSpied then
            text = "+0%"
            color = {1,0,0}
        end
    end
    
    BugTaleCharacters.CreateTextVisual(enemyX, enemyY, text, color)
end

--- ENCOUNTER FUNCTIONS ------------------------
function DamageRandom(amount, invulTime)
    BugTaleCharacters.DamageRandom(amount, invulTime)
end

function DamageAll(amount, invulTime)
    BugTaleCharacters.DamageAll(amount, invulTime)
end

function DamageTargeted(amount, invulTime)
    BugTaleCharacters.DamageTargeted(amount, invulTime)
end

function DamageActor(actor, amount)
    BugTaleCharacters.DamageActor(actor, amount)
end

function HealActor(actor, amount, disableSound)
    BugTaleCharacters.HealActor(actor, amount, disableSound)
end

function HealAll(amount, disableSound)
    BugTaleCharacters.HealAll(amount, disableSound)
end

function ReviveActor(actor, amount, disableSound)
    BugTaleCharacters.ReviveActor(actor, amount, disableSound)
end

function SkipToEnemyDialogue()
    BugTaleCharacters.SkipToEnemyDialogue()
end

function GetActorHP(actor)
    return BugTaleCharacters.Actors[actor].Health
end

function SetEnemyTargets(...)
    BugTaleCharacters.SetEnemyTargets(...);
end

function ChangeMP(actorID, amount)
    BugTaleCharacters.ChangeMP(BugTaleCharacters.Actors[actorID], amount);
end
------------------------------------------------

return BugTaleCharacters;