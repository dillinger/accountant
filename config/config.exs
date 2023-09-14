import Config

config :accountant, Accountant.Repo,
  database: "accountant_repo",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5555,
  template: "template0"

config :accountant, ecto_repos: [Accountant.Repo]
