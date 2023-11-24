defmodule Accountant.Core.ListFiles do
  @ignore_files [".DS_Store"]

  def list_files(filepath) do
    files_in_directory(filepath)
  end

  def files_in_directory(filepath) do
    cond do
      String.contains?(filepath, @ignore_files) -> []
      true -> expand(File.ls(filepath), filepath)
    end
  end

  defp expand({:ok, files}, path) do
    files
    |> Enum.flat_map(&files_in_directory("#{path}/#{&1}"))
  end

  defp expand({:error, _}, path) do
    [path]
  end
end
