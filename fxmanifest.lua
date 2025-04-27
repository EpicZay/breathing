fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Advanced Breathing System - Requires manual breathing'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

-- Optional dependencies for sound effects
dependencies {
    'InteractSound'
}

-- Export client functions
exports {
    'GetBreathLevel',
    'GetBreathMultiplier'
}