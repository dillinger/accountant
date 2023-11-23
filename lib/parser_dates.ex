defmodule ParserDates do
  def find_date({nil, nil, file_date}) do
    file_date
  end

  def find_date({[dateTime], nil, _file_date}) do
    {:ok, date, _} = DateTime.from_iso8601("#{dateTime}+01:00")
    date
  end

  def find_date({[dateTime], _date, _file_date}) do
    {:ok, date, _} = DateTime.from_iso8601("#{dateTime}+01:00")
    date
  end

  def find_date({nil, [_, month, day, year], _file_date}) do
    case DateTime.from_iso8601("#{year}-#{month}-#{day}+01:00") do
      {:ok, date, _} ->
        date

      {:error, _} ->
        {:ok, date, _} = DateTime.from_iso8601("#{year}-#{day}-#{month}T00:00:00+01:00")
        date
    end
  end

  def find_datetime(string, file_date \\ "") do
    isodate = Regex.run(~r/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, string)
    simpledate = Regex.run(~r/\b(\d{2})\.(\d{2})\.(\d{4})\b/, string)

    find_date({isodate, simpledate, file_date})
  end

  def year_from_file_name(file_content, file_name) do
    date = String.split(file_name, "_") |> Enum.at(3)

    case Regex.run(~r/\b(\d{4})(\d{2})(\d{2})\b/, date) do
      [_, year, _month, _day] ->
        [file_content, year |> String.to_integer()]

      _ ->
        [file_content, 1970]
    end
  end
end
