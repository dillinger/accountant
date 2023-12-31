defmodule Accountant.Core.Commerzbank do
  defstruct amount: 0,
            description: "",
            date: "",
            title: "",
            type: ""

  @doc """
  Parse strings of entries. Where each entry is separated by line with date and anount.
  The rest of the lines are the description of the transaction antil the next entry.


  The structure of the one entry look like this:
  ```
  " IZ  -Zacharias   Kaffeeba    BERLIN  DE        12.10                    2,60-"
  " Karte  Nr.  5355  3100  0256  0152"
  " Virtual   Debit  Card"
  " IZ  -Zacharias   Kaffeeba     BERLIN"
  "     DEU"
  " 2021-10-09T12:48:15     Kartenzahlung"
  " Buchungsdatum:    13.10.2021"
  ```

  """
  def parse(text, file_date) do
    lines = String.split(text, "\n", trim: true)

    parse_transaction_entry(lines, [], "")
    |> build_list_of_transactions(file_date)
  end

  defp parse_transaction_entry([line | rest], acc_entry, key) do
    case match_new_entry(line) do
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

  defp match_new_entry(line) do
    Regex.run(
      ~r/(.*?)\s+(\d+\.\d+)\s+(\d+\.\d+\,{0,}\d+-{0,1}|\d+\,{0,}\d+-{0,1})$/,
      String.trim(line)
    )
  end

  defp build_list_of_transactions(input, file_for_year) do
    Enum.reduce(input, [], fn {head, description}, acc ->
      cond do
        [short_title, transaction_date, amount] = String.split(head, "=") ->
          transaction_description = Enum.join(description, " ") |> check_for_valid_string

          transaction_date_from_file_name =
            ParserDates.build_date_time(transaction_date, file_for_year)

          date =
            ParserDates.transaction_date_time(
              transaction_description,
              transaction_date_from_file_name
            )

          {:ok, amount_value} =
            String.replace(amount, "-", "") |> Money.parse(:EUR)

          operation =
            %{}
            |> Map.put(:amount, amount_value)
            |> Map.put(:description, transaction_description)
            |> Map.put(:date, date)
            |> Map.put(:title, short_title)
            |> Map.put(:type, operation_type(amount))

          IO.inspect(operation)

          [operation | acc]

        true ->
          acc
      end
    end)
  end

  def operation_type(amount) do
    case String.match?(amount, ~r/\-$/) do
      true -> "credit"
      false -> "debet"
    end
  end

  defp check_for_valid_string(string) do
    case String.valid?(string) do
      true -> string
      false -> "not valid string"
    end
  end
end
