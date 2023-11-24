import Config

config :accountant, Accountant.Repo,
  database: "accountant_repo",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5555,
  template: "template0"

config :accountant, ecto_repos: [Accountant.Repo]

config :money,
  default_currency: :EUR,
  delimiter: ","

# separator: ".",
# symbol: false,
# symbol_on_right: false,
# symbol_space: false,
# fractional_unit: true,
# strip_insignificant_zeros: false,
# code: false,
# minus_sign_first: true,
# strip_insignificant_fractional_unit: false
