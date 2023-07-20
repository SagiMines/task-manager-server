local config = require("lapis.config")

config("development", {
  server = "nginx",
  code_cache = "off",
  num_workers = "1",
  postgres = {
    host = os.getenv("DB_HOST"),
    user = os.getenv("DB_USER"),
    database = os.getenv("DB_DATABASE"),
    password = os.getenv("DB_PASSWORD")
  }
})
