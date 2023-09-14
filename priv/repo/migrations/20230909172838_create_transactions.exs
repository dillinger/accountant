defmodule Accountant.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add(:title, :string)
      add(:description, :string)
      add(:type, :string)
      add(:amount, :float, default: 0.0)
      add(:payment_date, :date)
      add(:transaction_date, :date)
    end
  end
end
