fx_version "adamant"
game "gta5" 

shared_scripts {
  "shared/*.lua",
}

server_scripts {
  "@vrp/lib/utils.lua",
  "server-side/*.lua",
  "server-side/script_**/*.lua",
}

client_scripts {
  "@vrp/lib/utils.lua",
  "client-side/*.lua",
  "client-side/script_**/*.lua",
}

-- files {
--    "nui/**/*",
-- }
-- ui_page ""