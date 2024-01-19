AddEventHandler("ND:characterUnloaded", function()
    LocalPlayer.state:set('isCuffed', false, true)
    LocalPlayer.state:set('isEscorted', false, true)
end)
