--[[
    @Crazys_JS 2023
    Semi-basic bullet template.
]]--

spawntimer = 0;
bullets = {};

Encounter.Call("SetEnemyTargets");
Encounter.SetVar("wavetimer", 5)

function Update()
    spawntimer = spawntimer + 1;

    if spawntimer % 20 == 0 then
        local amount = math.random(1,3)
        local speed = (3 / amount) * 2;
        for i=1, math.random(1,3) do
            local spawnX = math.random(-100, 100)
            local spawnY = math.random(Arena.height + 50, Arena.height + 150)
            local bullet = CreateProjectile("bullet", spawnX, spawnY);
            bullet.sprite.alpha = 0;

            local difX = Player.x - spawnX;
            local difY = Player.y - spawnY;

            local mag = math.sqrt(difX*difX+difY*difY);

            bullet.SetVar("VelX", difX * speed / mag)
            bullet.SetVar("VelY", difY * speed / mag)
            bullet.SetVar("StartAt", spawntimer)

            table.insert(bullets, bullet);
        end
    end

    for i,x in pairs(bullets) do
        local elapsed = spawntimer - x.GetVar("StartAt");

        if elapsed % 5 == 0 then
            x.sprite.rotation = x.sprite.rotation + 90
        end
        if elapsed <= 30 then
            local ratio = elapsed / 30;
            x.sprite.alpha = math.sin(ratio * (math.pi / 2));
        end

        x.Move(x.GetVar("VelX"), x.GetVar("VelY"))
    end
end

function OnHit()
    Encounter.Call("DamageTargeted", 3); -- Targets one character automatically and damages them for the entire wave, unless taunted.
    --Encounter.Call("DamageAll", 3); -- Damages all participants.
    --Encounter.Call("DamageRandom", 3); -- Damages random, unless taunted.
end