defmodule Accountant.CommerzbankParser do
  def parse(text) do
    lines = String.split(text, "\n", trim: true)

    parse_transaction_entry(lines, [], "")
    |> build_list_of_transaction
  end

  defp parse_transaction_entry([line | rest], acc_entry, key) do
    case Regex.run(
           ~r/(.*?)\s+(\d+\.\d+)\s+(\d+\.\d+\,{0,}\d+-{0,1}|\d+\,{0,}\d+-{0,1})$/,
           String.trim(line)
         ) do
      [_head | title_group] ->
        trimed_key = Enum.join(title_group, "=")
        new_transaction_entry = {trimed_key, []}

        parse_transaction_entry(rest, [new_transaction_entry] ++ acc_entry, trimed_key)

      nil ->
        cond do
          String.length(key) > 2 ->
            [{title, info} | last] = acc_entry

            info_string = String.trim(line) |> String.replace(~r/\W[ ]{1,}\W/i, "")
            updated_transaction_entry = {title, info ++ [info_string]}
            parse_transaction_entry(rest, [updated_transaction_entry] ++ last, key)

          key === "" ->
            parse_transaction_entry(rest, acc_entry, key)
        end
    end
  end

  defp parse_transaction_entry([], acc, _key), do: acc

  defp build_list_of_transaction(input) do
    Enum.reduce(input, [], fn {head, description}, acc ->
      cond do
        [short_title, transaction_date, amount] = String.split(head, "=") ->
          operation = %{
            amount: amount,
            info: description,
            short_title: short_title,
            payment_date: "",
            bank_transaction_date: transaction_date,
            type: operation_type(amount)
          }

          [operation | acc]
      end
    end)
  end

  def operation_type(amount) do
    case String.match?(amount, ~r/\-$/) do
      true -> "credit"
      false -> "debet"
    end
  end
end
