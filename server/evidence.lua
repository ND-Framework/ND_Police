local evidence = {}
local addEvidence = {}
local clearEvidence = {}
local evidenceMetadata = lib.load("data.evidence")

local bulletText = {
    projectile = "Projectile from ",
    casing = "Casing from "
}

Ox_inventory:registerHook('createItem', function(payload)
    local name = payload.item.name
    local text = bulletText[name]
    if not text then return end

    local metadata = payload.metadata
    local evidence = evidenceMetadata[metadata.type]
    if not evidence then return end

    local image = evidence[name]
    if not image then return end
    
    return {
        label = text .. evidence.label,
        weight = evidence.weight,
        image = image
    }
end, {
    itemFilter = {
        projectile = true,
        casing = true
    }
})

CreateThread(function()
    while true do
        Wait(1000)

        if next(addEvidence) or next(clearEvidence) then
            TriggerClientEvent('ND_Police:updateEvidence', -1, addEvidence, clearEvidence)

            table.wipe(addEvidence)
            table.wipe(clearEvidence)
        end
    end
end)

RegisterServerEvent('ND_Police:distributeEvidence', function(nodes)
    local src = source
    local state = Player(src).state
    state.lastShot = os.time()

    if not state.shot then
        state.shot = true
    end

    for coords, items in pairs(nodes) do
        if evidence[coords] then
            lib.table.merge(evidence[coords], items)
        else
            evidence[coords] = items
            addEvidence[coords] = true
        end
    end
end)

RegisterServerEvent('ND_Police:collectEvidence', function(nodes)
    local items = {}

    for i = 1, #nodes do
        local coords = nodes[i]

        lib.table.merge(items, evidence[coords])

        clearEvidence[coords] = true
        evidence[coords] = nil
    end

    local success = false
    for item, data in pairs(items) do
        for type, count in pairs(data) do
            if Ox_inventory:AddItem(source, item, count, type) then
                success = true
            end
        end
    end

    if not success then return end
    lib.notify(source, {type = 'success', title = 'Evidence collected'})
end)
