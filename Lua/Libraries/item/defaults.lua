--[[
    @Crazys_JS 2023 MP VERSION
    These are just some Bug Fables items in undertale form. Feel free to use this library for some generic items.
]]--

BugTaleLibrary.RegisterActionProperty({
    Name = "Crunchy Leaf",
    DisplayName = "* C. Leaf",
    Description = "4 HP Recovery",
    Target = "ALLIES",
    IsConsumable = true,
    OnExecuted = function()
        local name = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected].Name;
        HealActor(BugTaleLibrary.TargetSelected, 4)
        BattleDialog("Very crunchy.\n" ..name .." recovered 4 HP!")
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Leaf Omelet",
    DisplayName = "* L. Omelet",
    Description = "9 HP Recovery",
    Target = "ALLIES",
    IsConsumable = true,
    OnExecuted = function()
        local name = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected].Name;
        HealActor(BugTaleLibrary.TargetSelected, 9)
        BattleDialog("Very filling and delicious!\n" ..name .." recovered 9 HP!")
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Spider Donut",
    DisplayName = "* SpidrDont",
    Description = "6 HP Recovery",
    Target = "ALLIES",
    IsConsumable = true,
    OnExecuted = function()
        local name = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected].Name;
        HealActor(BugTaleLibrary.TargetSelected, 6)

        if math.random() <= .1 then
            BattleDialog("Don't worry, Spider didn't.\n" ..name .." recovered 6 HP!")
        else
            BattleDialog(name .." ate the Spider Donut.\n" ..name .." recovered 6 HP!")
        end
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Mushroom",
    DisplayName = "* Mushroom",
    Description = "3 HP/MP Recovery",
    Target = "ALLIES",
    IsConsumable = true,
    OnExecuted = function()
        local name = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected].Name;
        HealActor(BugTaleLibrary.TargetSelected, 3)
        ChangeMP(BugTaleLibrary.TargetSelected, 3)

        BattleDialog(name .." ate the Mushroom.\n" ..name .." recovered 3 HP!\nThe party gained 8% TP!")
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Abomihoney",
    DisplayName = "* Abomihoney",
    Description = "+20 MP at a big price.",
    Target = "ALLIES",
    IsConsumable = true,
    OnExecuted = function()
        local name = BugTaleLibrary.Actors[BugTaleLibrary.CurrentActor].Name;
        DamageActor(BugTaleLibrary.TargetSelected, 99)
        ChangeMP(BugTaleLibrary.TargetSelected, 20)
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Spider Cider",
    DisplayName = "* SpidrCidr",
    Description = "12 HP Recovery",
    Target = "ALLIES",
    IsConsumable = true,
    OnExecuted = function()
        local name = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected].Name;
        HealActor(BugTaleLibrary.TargetSelected, 12)
        BattleDialog(name .." drank the Spider Cider.\n" ..name .." recovered 12 HP!")
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Magic Seed",
    DisplayName = "* Magic Seed",
    Description = "7 HP Recovery",
    Target = "ALLIES",
    IsConsumable = true,
    OnExecuted = function()
        local target = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected];
        local name = target.Name;
        if target.Health > 0 then
            HealActor(BugTaleLibrary.TargetSelected, 7)
            BattleDialog("The magic seed heals your injuries.\n" ..name .." recovered 7 HP!")
        else
            ReviveActor(BugTaleLibrary.TargetSelected, 7)
            BattleDialog("The magic seed gets you up.\n" ..name .." got up with 7 HP!")
        end
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Honey Drop",
    DisplayName = "* Honey Drop",
    Description = "+5 MP",
    Target = "ALLIES",
    IsConsumable = true,
    OnExecuted = function()
        local target = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected];
        local name = target.Name;
        ChangeMP(BugTaleLibrary.TargetSelected, 5)
        BattleDialog("Nothing as refreshing as honey!\n" .. name .. " recovered 5 MP!");
    end
});

BugTaleLibrary.RegisterActionProperty({
    Name = "Glazed Honey",
    DisplayName = "* Glazed Honey",
    Description = "+10 MP",
    Target = "ALLIES",
    IsConsumable = true,
    OnExecuted = function()
        local target = BugTaleLibrary.Actors[BugTaleLibrary.TargetSelected];
        local name = target.Name;
        ChangeMP(BugTaleLibrary.TargetSelected, 10)
        BattleDialog("Tastes even better when warm!\n" .. name .. " recovered 10 MP!");
    end
});