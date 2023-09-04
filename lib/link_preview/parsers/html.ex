defmodule LinkPreview.Parsers.Html do
  @moduledoc """
    Parser implementation based on html tags.
  """
  import LinkPreview.Parsers.Util

  @doc """
    Get page title based on first encountered title tag.

    Config options:
    * `:friendly_strings`\n
      see `LinkPreview.Parsers.Basic.maybe_friendly_string/1` function\n
      default: true
  """
  def title(parsed_body) do
    parsed_body
    |> Floki.find("title")
    |> List.first()
    |> get_text
  end

  @doc """
    Get page description based on first encountered h1..h6 tag.

    Preference: h1> h2 > h3 > h4 > h5 > h6

    Config options:
    * `:friendly_strings`\n
      see `LinkPreview.Parsers.Basic.maybe_friendly_string/1` function\n
      default: true
  """
  def description(parsed_body), do: search_h(parsed_body, 1)

  defp get_text(nil), do: nil

  defp get_text(choosen) do
    choosen |> Floki.text() |> maybe_friendly_string()
  end

  defp search_h(_parsed_body, 7), do: nil

  defp search_h(parsed_body, level) do
    parsed_body
    |> Floki.find("h#{level}")
    |> List.first()
    |> get_text
    |> case do
      nil -> search_h(parsed_body, level + 1)
      "" -> search_h(parsed_body, level + 1)
      description -> description
    end
  end
end
