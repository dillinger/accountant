defmodule Accountant do
  alias Accountant.FilesInDirectory
  alias Accountant.CommerzbankParser

  def parse(folder_path) do
    FilesInDirectory.list_files(folder_path)
    |> Enum.map(fn filepath ->
      case File.read(filepath) do
        {:ok, content} ->
          CommerzbankParser.parse(content)

        {:error, _reason} ->
          []
      end
    end)
    |> List.flatten()
  end
end
