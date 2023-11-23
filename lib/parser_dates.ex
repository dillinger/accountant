defmodule ParserDates do
  @doc """
  Handle three different date forms.

  Case where year exist in file name and month and day in text in form 01.01.
  Case in form (e.g. 2017-01-01T00:00:00).
  Case form (e.g. 01.01.2017).

  Reurns the date in UTC format.
  """
  def find_date({nil, nil, file_date}) do
    file_date
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

  @doc """
  Use regex to find date in text or use date from file name.
  """
  def transaction_date_time(text, file_date \\ "") do
    isodate = Regex.run(~r/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, text)
    simpledate = Regex.run(~r/\b(\d{2})\.(\d{2})\.(\d{4})\b/, text)

    find_date({isodate, simpledate, file_date})
  end

  @doc """
  Get a year from file name or retrun 1970 as default.
  """
  def year_from_file_name(file_content, file_name) do
    date = String.split(file_name, "_") |> Enum.at(3)

    case Regex.run(~r/\b(\d{4})(\d{2})(\d{2})\b/, date) do
      [_, year, _month, _day] ->
        [file_content, year |> String.to_integer()]

      _ ->
        [file_content, 1970]
    end
  end

  def max_days_in_month(year, month) do
    Date.from_iso8601!("#{year}-#{month}-01")
    |> Date.days_in_month()
  end

  def build_date_time(short_date, year) do
    [day, month] = String.split(short_date, ".")
    days_in_month = max_days_in_month(year, month)

    case Date.from_iso8601("#{year}-#{month}-#{day}") do
      {:ok, date} ->
        DateTime.new!(date, ~T[00:00:00])

      {:error, _} ->
        Date.from_iso8601!("#{year}-#{month}-#{days_in_month}")
        |> DateTime.new!(~T[00:00:00])
    end
  end
end
