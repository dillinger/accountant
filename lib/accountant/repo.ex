defmodule Accountant.Repo do
  use Ecto.Repo,
    otp_app: :accountant,
    adapter: Ecto.Adapters.Postgres
end
