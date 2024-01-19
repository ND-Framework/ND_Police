fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'


shared_scripts {
    "@ox_lib/init.lua",
    "@ND_Core/init.lua",
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'config.lua'
}


client_scripts {
    'client/main.lua',
    'client/cuff.lua',
    'client/escort.lua',
    'client/spikes.lua',
    'client/jail.lua',
    'client/gsr.lua',
    'client/evidence.lua'
}
