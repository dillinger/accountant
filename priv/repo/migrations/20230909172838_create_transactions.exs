defmodule Accountant.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add(:title, :string)
      add(:info, :text)
      add(:operation_type, :string)
      add(:amount, :string)
      add(:payment_date, :string)
      add(:transaction_date, :utc_datetime)

      timestamps()
    end
  end
end
