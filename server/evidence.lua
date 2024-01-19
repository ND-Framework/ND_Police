local evidence = {}
local addEvidence = {}
local clearEvidence = {}
local evidenceMetadata = lib.load("data.evidence")

local bulletText = {
    slug = "Bullet slug from ",
    case = "Bullet case from "
}

exports.ox_inventory:registerHook('createItem', function(payload)
    local name = payload.itemn.name
    local text = bulletText[name]
    if not text then return end

    local metadata = payload.metadata
    local evidence = evidenceMetadata[metadata.type]
    if not evidence then return end
    
    return {
        label = text .. evidence.label,
        weight = evidence.weight
    }
end, {
    itemFilter = {
        case = true,
        slug = true
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

        table.merge(items, evidence[coords])

        clearEvidence[coords] = true
        evidence[coords] = nil
    end

    for item, data in pairs(items) do
        for type, count in pairs(data) do
            print(item, count, type)
            exports.ox_inventory:AddItem(source, item, count, type)
        end
    end

    lib.notify(source, {type = 'success', title = 'Evidence collected'})
end)
