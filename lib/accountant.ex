defmodule Accountant do
  @defaultPath "/Users/dep/workplace/pdftotext/output"

  def read_and_parse(folder_path) do
    FilesInDirectory.list_files(folder_path)
    |> Enum.map(fn filename ->
      File.read(filename)
      |> ParserDates.year_from_file_name(filename)
      |> try_to_parse()
    end)
    |> List.flatten()
  end

  def try_to_parse([{:ok, content}, file_date]) do
    ParserCommerzbank.parse(content, file_date)
  end

  def try_to_parse([{:error, _error}, _file_date]) do
    []
  end

  def add_to_database(path \\ @defaultPath) do
    read_and_parse(path)
    |> Enum.each(fn entry ->
      trans = %Accountant.Transaction{}

      change = Accountant.Transaction.changeset(trans, entry)
      Accountant.Repo.insert(change)
    end)
  end
end
