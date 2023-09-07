defmodule LinkPreview.Processor do
  @moduledoc """
    Combines the logic of other modules with user input.
  """
  alias LinkPreview.{Page, Parser, Requests}

  @doc """
    Takes url and returns result of processing.
  """
  @spec call(String.t()) :: LinkPreview.success() | LinkPreview.failure()
  def call(url) do
    url
    |> Requests.head()
    |> case do
      {:ok, response} ->
        {:ok, response, response |> Tesla.get_header("content-type")}

      {:error, error} ->
        {:error, error, nil}
    end
    |> case do
      {:ok, %Tesla.Env{status: 200, url: final_url}, "text/html" <> _} ->
        do_call(url, final_url)

      {:ok, %Tesla.Env{status: 200, url: final_url}, "image/" <> _} ->
        do_image_call(url, final_url)

      {:ok, _, _} ->
        %LinkPreview.Error{origin: LinkPreview, message: "unsupported response"}

      {:error, reason, _} ->
        %LinkPreview.Error{origin: 123, message: reason}
    end
    |> to_tuple()
  catch
    _, %{__struct__: origin, message: message} ->
      {:error, %LinkPreview.Error{origin: origin, message: message}}

    _, _ ->
      {:error, %LinkPreview.Error{origin: :unknown}}
  end

  defp to_tuple(result) do
    case result do
      %Page{} ->
        {:ok, result}

      %LinkPreview.Error{} ->
        {:error, result}
    end
  end

  defp do_image_call(url, final_url) do
    page = Page.new(url, final_url)

    %Page{page | images: [%{url: url}]}
  end

  defp do_call(url, final_url) do
    case Requests.get(url) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        url
        |> Page.new(final_url)
        |> Parser.parse(body)

      _ ->
        %LinkPreview.Error{origin: LinkPreview, message: "unsupported response"}
    end
  end
end
