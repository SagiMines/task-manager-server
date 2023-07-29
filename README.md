# Task Manager - Lua (Lapis) Server

This project is built using Lua with the use of LuaRocks package manager.

## Run Locally

- Clone task-manager-server:

```bash
git clone https://github.com/SagiMines/task-manager-server.git
cd task-manager-server
```

- Install all the necessary dependencies locally:

```bash
luarocks install --only-deps task-manager-server-dev-1.rockspec --tree=lua_modules --lua-version=5.1
```

- Start your Lapis server:

```bash
lapis server
```

## Environment Variables

To run this project, you will need to add an `env_config.conf` file to the root of the project with the following environment variables included:

Database connection:

`DB_HOST`,
`DB_DATABASE`,
`DB_USER`,
`DB_PASSWORD`

Hashing process (user password hashing):

`HASH_ROUNDS`

JWT creation secret:

`JWT_SECRET`

## Related

[Task Manager Client](https://github.com/SagiMines/task-manager-client)
