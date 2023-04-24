
--[[
    @Crazys_JS 2023
    Basic monster template.
]]--

comments = {"Smells like the work\rof an enemy stand.", "Poseur is posing like his\rlife depends on it.", "Poseur's limbs shouldn't be\rmoving in this way."}
commands = {"Spy"}
randomdialogue = {"Random\nDialogue\n1.", "Random\nDialogue\n2.", "Random\nDialogue\n3."}

sprite = "poseur" --Always PNG. Extension is added automatically.
name = "Poseur"
hp = 100
atk = 1
def = 1
check = "An evil poseur!!!"
dialogbubble = "right" -- See documentation for what bubbles you have available.
canspare = false
cancheck = false

myid = 0; -- this will change to accurately represent the enemy's id in enemies table but not during init.

spymessages = {};
SetDamageUIOffset(0, 100)

actionmessages = {};

bugtale_XP = 10;
bugtale_GOLD = 100;

spare_progress = 0;
was_spied = false;

function ConstructSpyMessages() -- This is ran after initialization and MYID is set.
    spymessages = {
        {{1, {"I don't have the time.", "Let's end this quickly."}}},
        {{2, {"An inanimate object is attacking us?", "Must be the work of some strange magic."}}},
    }
end

function HandleSpecialActionMessages(actorID) -- This is for stuff like L-Action and V-Action.
    if actorID == 2 then
        Encounter.Call("ChangeSpareProgress", {myid, 25});
        BattleDialog("Leif posed even harder than Poseur!\nThe enemy liked that!")
    end
end

-- Happens after the slash animation but before 
function HandleAttack(attackstatus)
    if attackstatus == -1 then
        -- player pressed fight but didn't press Z afterwards
    else
        -- player did actually attack
        Encounter.Call("AfterAttack")

        if hp < 75 and not canspare then
            canspare = true
            comments = {"Poseur is hurt."}
        end
    end
end

-- This should return TRUE if the enemy is alive. (aka you didn't call Kill here.)
function OnDeath()
    bugtale_GOLD = 124;
    Encounter.Call("IncreaseBugTaleEXP", bugtale_XP);
    Kill();

    return false;
end

function BeforeDamageCalculation()
    Audio.PlaySound(Encounter.GetVar("SlashSound"))
end
 
-- This handles the commands; all-caps versions of the commands list you have above.
function HandleCustomCommand(command)

end