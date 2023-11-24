defmodule Accountant.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add(:title, :string)
      add(:type, :string)
      add(:amount, :integer)
      add(:description, :text)
      add(:date, :utc_datetime)

      timestamps()
    end
  end
end
