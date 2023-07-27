package = "task-manager-server"
version = "dev-1"
source = {
   url = "https://github.com/SagiMines/task-manager-server.git"
}
description = {
   homepage = "",
}
dependencies = {
   "lua >= 5.1, < 5.2",
   "lapis >= 1.14.0-1",
   "bcrypt >= 2.3-1",
   "lua-resty-jwt >= 0.2.3-0",
   "lua-cjson >= 2.1.0.10-1",
   "lua-resty-cors >= 0.2-1"
}
build = {
   type = "builtin",
   modules = {}
}
