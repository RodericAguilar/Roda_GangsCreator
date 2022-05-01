fx_version 'cerulean'

game 'gta5'

author 'Roderic#0001 and LittleFishy#0001'
description 'Gang System for FiveM | Roda Scripts'

client_scripts {
    'Client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'Server/*.lua'
}

shared_script {
    'Config.lua',
    'Language.lua'
}

ui_page {
    'html/index.html', 
}

files {
    'html/index.html',
    'html/app.js',
    'html/style.css'
} 