defmodule ScraperUtils do
  def cleanup_text(input) do
    input
    |> String.trim()
    |> String.replace("\n", "")
    |> String.replace("  ", " ")
  end
end
