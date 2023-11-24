defmodule Accountant do
  alias Accountant.Transaction
  alias Accountant.Core.Commerzbank
  alias Accountant.Core.DateTimeUtils
  alias Accountant.Core.ListFiles

  @defaultPath "/Users/dep/workplace/pdftotext/output"

  def read_and_parse(folder_path) do
    ListFiles.list_files(folder_path)
    |> Enum.map(fn filename ->
      File.read(filename)
      |> DateTimeUtils.year_from_file_name(filename)
      |> try_to_parse_with_file_date()
    end)
    |> List.flatten()
  end

  def try_to_parse_with_file_date([{:ok, content}, file_date]) do
    Commerzbank.parse(content, file_date)
  end

  def try_to_parse_with_file_date([{:error, _error}, _file_date]) do
    []
  end

  def add_to_database(path \\ @defaultPath) do
    read_and_parse(path)
    |> Enum.each(fn entry ->
      change = Transaction.changeset(%Accountant.Transaction{}, entry)
      Accountant.Repo.insert(change)
    end)
  end
end
