defmodule Accountant.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field(:title, :string)
    field(:type, :string)
    field(:amount, Money.Ecto.Amount.Type)
    field(:description, :string)
    field(:date, :utc_datetime)

    timestamps(type: :utc_datetime)
  end

  def changeset(account, params \\ %{}) do
    account
    |> cast(params, [:title, :type, :amount, :description, :date])
    |> validate_required([
      :title,
      :type,
      :amount,
      :description,
      :date
    ])
  end
end
