defmodule Accountant.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field(:amount, :string)
    field(:info, :string)
    field(:title, :string)
    field(:payment_date, :string)
    field(:transaction_date, :utc_datetime)
    field(:operation_type, :string)

    timestamps(type: :utc_datetime)
  end

  def changeset(account, params \\ %{}) do
    account
    |> cast(params, [:amount, :info, :title, :payment_date, :transaction_date, :operation_type])
    |> validate_required([
      :amount,
      :info,
      :operation_type,
      # :payment_date,
      :title,
      :transaction_date
    ])
  end
end
