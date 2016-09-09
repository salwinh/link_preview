defmodule LinkPreviewGenerator.Parsers.Html do
  @moduledoc """
    TODO
  """
  use LinkPreviewGenerator.Parsers.Basic

  def title(page, body) do
    title =
      body
      |> Floki.find("title")
      |> List.first
      |> get_text

    page |> update_title(title)
  end

  def description(page, body) do
    description = search_h(body, 1)

    page |> update_description(description)
  end

  def images(page, body) do
    images = if Application.get_env(:link_preview_generator, :force_images_absolute_url, false) do
      map_image_urls(body, page.website_url)
    else
      map_image_urls(body)
    end

    page |> update_images(images)
  end

  defp map_image_urls(body) do
    body
    |> Floki.attribute("img", "src")
    |> Enum.map(&(%{url: &1}))
  end

  defp map_image_urls(body, website_url) do
    body
    |> Floki.attribute("img", "src")
    |> Enum.map(&force_absolute_url(&1, website_url))
    |> Enum.reject(&Kernel.is_nil(&1))
    |> Enum.map(&(%{url: &1}))
  end

  defp force_absolute_url(url, website_url) do
    cond do
      URI.parse(url).scheme != nil ->           #valid absolute url
        url
      Regex.match?(~r/\A\/\/.*/, url) ->        #absolute url without a scheme started with double
        URI.parse(website_url).scheme <> url
      Regex.match?(~r/\A\/[^\/].*/, url) ->     #relative url started with single /
        website_url <> url
      Regex.match?(~r/\A[^\.]+\/.*/, url) ->    #relative url without initial /
        website_url <> "/" <> url
      true ->                                   #anything that wasn't handled properly above
        nil
    end
  end

  defp search_h(_body, 7), do: nil
  defp search_h(body, level) do
    description =
      body
      |> Floki.find("h#{level}")
      |> List.first
      |> get_text

    description || search_h(body, level + 1)
  end

  defp get_text(nil), do: nil
  defp get_text(choosen), do: choosen |> Floki.text
end
