fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

files {
    "audiodata/nd_police.dat54.rel",
    "audiodirectory/nd_police.awc",
    "data/**",
    "bridge/**/client.lua"
}

data_file "DLC_ITYP_REQUEST" "stream/cuffs_main.ytyp"
data_file "AUDIO_WAVEPACK" "audiodirectory"
data_file "AUDIO_SOUNDDATA" "audiodata/nd_police.dat"

dependencies {
    "ox_target",
    "ox_inventory",
    "ox_lib"
}

shared_scripts {
    "@ox_lib/init.lua",
    "shared/bridge.lua"
}

server_scripts {
    'server/main.lua',
    'server/evidence.lua',
    'server/cuff.lua'
}

client_scripts {
    'client/main.lua',
    'client/cuff.lua',
    --'client/escort.lua',
    'client/evidence.lua',
    'client/gsr.lua',
    'client/spikes.lua',
    'client/shield.lua',
    'client/shotspotter.lua',
    'client/locker_rooms.lua'
}
