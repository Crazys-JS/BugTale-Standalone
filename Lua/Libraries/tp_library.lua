--[[
    @Crazys_JS 2023
    Do not modify the library for making new encounters as you can modify stuff in the encounter script itself. Consistency is key.
    Adds TP mechanic.
]]--

TPLibrary = {}

TPLibrary.Underlay = CreateSprite("UI/tp_bar");
TPLibrary.Overlay = CreateSprite("UI/tp_bar");
TPLibrary.OverlayMask = CreateSprite("UI/tp_bar");
TPLibrary.Usage = CreateSprite("UI/tp_bar");
TPLibrary.UsageMask = CreateSprite("UI/tp_bar");

TPLibrary.OverlayMask.SetParent(TPLibrary.Underlay);
TPLibrary.UsageMask.SetParent(TPLibrary.Underlay);

TPLibrary.Overlay.SetParent(TPLibrary.OverlayMask);
TPLibrary.Usage.SetParent(TPLibrary.UsageMask);

TPLibrary.OverlayMask.SetPivot(.5,0);
TPLibrary.UsageMask.SetPivot(.5,0);

TPLibrary.OverlayMask.MoveTo(0, -TPLibrary.OverlayMask.height / 2)
TPLibrary.UsageMask.MoveTo(0, -TPLibrary.UsageMask.height / 2)

TPLibrary.Overlay.SetAnchor(.5,0);
TPLibrary.Overlay.MoveTo(0, TPLibrary.Overlay.height / 2)

TPLibrary.Usage.SetAnchor(.5,0);
TPLibrary.Usage.MoveTo(0, TPLibrary.Usage.height / 2)

TPLibrary.OverlayMask.Scale(1,0);
TPLibrary.UsageMask.Scale(1,0);
TPLibrary.OverlayMask.alpha = 0;
TPLibrary.UsageMask.alpha = 0;

TPLibrary.OverlayMask.Mask("box")
TPLibrary.UsageMask.Mask("box")

TPLibrary.Underlay.color32 = {128, 0, 0}
TPLibrary.Overlay.color32 = {255, 160, 64}
TPLibrary.Usage.color = {1,0,0}

TPLibrary.Underlay.MoveTo(59, 360);

TPLibrary.TPTextSprite = CreateSprite("UI/tp_text");
TPLibrary.TPTextSprite.MoveTo(33, 371);

TPLibrary.TPText = CreateText("", {20, 362}, 32, "BelowArena")
TPLibrary.TPText.Scale(1,1)
TPLibrary.TPText.color = {1,1,1}
TPLibrary.TPText.SetFont("uidialog")
TPLibrary.TPText.progressmode = "none"
TPLibrary.TPText.deleteWhenFinished = false
TPLibrary.TPText.HideBubble()

TPLibrary.TPText.SetText("[instant]0")

TPLibrary.OverlayMask.MoveAbove(TPLibrary.UsageMask)

TPLibrary.TP = 0;
TPLibrary.TPCatchingOrange = 0;
TPLibrary.TPCatchingRed = 0;

function TPLibrary.GetVar(varName)
    return TPLibrary[varName]
end

function TPLibrary.Call(funcName, ...)
    return TPLibrary[funcName](...)
end

function TPLibrary.ChangeTP(amount, sound)
    if amount > 0 then
        TPLibrary.TP = math.min(100, TPLibrary.TP + amount)
    else
        TPLibrary.TP = math.max(0, TPLibrary.TP + amount)
    end

    if TPLibrary.TP == 100 then
        TPLibrary.TPText.alpha = 0;
        TPLibrary.TPTextSprite.Set("UI/tp_max")
        TPLibrary.Overlay.color = {1,1,0};
    else
        TPLibrary.TPText.alpha = 1;
        TPLibrary.TPTextSprite.Set("UI/tp_text")
        TPLibrary.Overlay.color32 = {255, 160, 64}
    end

    TPLibrary.TPText.SetText("[instant]" ..TPLibrary.TP);
end

function TPLibrary.Update()
    if TPLibrary.TP ~= TPLibrary.TPCatchingRed then
        if TPLibrary.TP > TPLibrary.TPCatchingRed then
            TPLibrary.TPCatchingRed = math.min(TPLibrary.TP, TPLibrary.TPCatchingRed + 2)
        else
            TPLibrary.TPCatchingRed = math.max(TPLibrary.TP, TPLibrary.TPCatchingRed - 2)
        end

        local ratio = TPLibrary.TPCatchingRed / 100;
        TPLibrary.UsageMask.Scale(1, ratio);
    end

    if TPLibrary.TP ~= TPLibrary.TPCatchingOrange then
        if TPLibrary.TP > TPLibrary.TPCatchingOrange then
            TPLibrary.TPCatchingOrange = math.min(TPLibrary.TP, TPLibrary.TPCatchingOrange + 3)
        else
            TPLibrary.TPCatchingOrange = math.max(TPLibrary.TP, TPLibrary.TPCatchingOrange - 3)
        end

        local ratio = TPLibrary.TPCatchingOrange / 100;
        TPLibrary.OverlayMask.Scale(1, ratio);
    end
end

function GetTP()
    return TPLibrary.TP
end

function ChangeTP(amount, sound)
    TPLibrary.ChangeTP(amount, sound)
end

return TPLibrary