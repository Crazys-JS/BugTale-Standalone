--[[
    @Crazys_JS 2023 MP VERSION
    Basic encounter template for well... encounters. Most stuff are the same as normal CYF.
]]--

autolinebreak = true
music = "test" --Either OGG or WAV. Extension is added automatically.
encountertext = "Poseur strikes a pose!" --Modify as necessary. It will only be read out in the action select screen.
nextwaves = {"bullettest_chaserorb"}
wavetimer = 4.0
arenasize = {155, 130}

enemies = {
"poseur",
"poseur"
}

enemypositions = {
{-100, 0},
{100, 0}
}

-- A custom list with attacks to choose from. Actual selection happens in EnemyDialogueEnding(). Put here in case you want to use it.
possible_attacks = {"test"}
deathtext = {"And their tale was never finished..."}


-- Make sure these are in your encounter script: -------------------
BugTaleLibrary = require 'bugtale_mp'
--------------------------------------------------------------------

require 'behavior/othermenu' -- This library creates the "other" menu.

--!!!! REGISTER CHARACTERS HERE!!!--
_CRAZYS_REGISTER = require('characters/crazys')
_LEDOL_REGISTER = require('characters/ledol')
_VEB_REGISTER = require('characters/veb')

_CRAZYS_REGISTER.Register(39) -- Spawn UI at X:39.
_VEB_REGISTER.Register(229)
_LEDOL_REGISTER.Register(420)

_ITEM_REGISTRY = require('item/defaults'); -- This library adds some items from bug fables to the encounter.
BugTaleLibrary.SetInventory({
    "Crunchy Leaf",
    "Crunchy Leaf",
    "Crunchy Leaf",
    "Honey Drop",
    "Magic Seed",
    "Glazed Honey"
})

function BeforeEnd()
    --Before battle ends.
end

function EncounterStarting()
    --Very important :sob:
    for i,x in pairs(enemies) do
        x.GetVar("monstersprite").layer = "BelowArena"
    end

    -- Call Bugtale yes.
    BugTaleLibrary.EncounterStarting()
end

function EnemyDialogueStarting()
    local enemyTurn = BugTaleLibrary.ActorFinish();

    if enemyTurn then
        -- Good location for setting monster dialogue depending on how the battle is going.
        -- Enemy turn is starting!
    end
end

function EnemyDialogueEnding()
    -- Good location to fill the 'nextwaves' table with the attacks you want to have simultaneously.
    BugTaleLibrary.EnemyDialogEnd();

    nextwaves = { possible_attacks[math.random(#possible_attacks)] }
end

function DefenseEnding() --This built-in function fires after the defense round ends.
    encountertext = RandomEncounterText() --This built-in function gets a random encounter text from a random enemy.
    BugTaleLibrary.TurnBegin();
end

function HandleSpare()
    State("ENEMYDIALOGUE")
end

function HandleItem(ItemID)
    BugTaleLibrary.HandleAction(ItemID)
end

function EnteringState(new, old)
    BugTaleLibrary.EnteringState(new, old)
end

local rate = 0;

function Update()
    if BugTaleLibrary.Actors[3].Idiot then
        
        rate = rate + 1;
        if BugTaleLibrary.Actors[3].Health < BugTaleLibrary.Actors[3].MaxHealth and rate % 30 == 0 then
            HealActor(3, 1)
        end

        if BugTaleLibrary.CurrentActor > 0 and BugTaleLibrary.CurrentActor < 3 then
            if rate % 30 == 0 then
                DamageActor(BugTaleLibrary.CurrentActor, 1);
            end
        end

        if rate % 600 == 0 then
            for i,x in pairs(BugTaleLibrary.Actors) do
                if x.Health <= 0 then
                    DamageActor(i, 1)
                end
            end
        end
    end

    if BugTaleLibrary.SelectionUIIndex >= 333*4 - 3 then
        deathtext = {string.rep("YOU LOST INTERFERER", 500, " ")}
        DamageAll(1, 0);
        
        if BugTaleLibrary.SelectionUIIndex >= 380*4 - 3 then
            deathtext = {"no more"}
            Player.hp = 0
        end
    end

    BugTaleLibrary.Update();
end