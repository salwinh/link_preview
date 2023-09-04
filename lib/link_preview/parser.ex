defmodule LinkPreview.Parser do
  alias LinkPreview.Parsers.{Opengraph, Html}

  def parse(page, body) do
    parsed_body = Floki.parse_document!(body)

    title = Opengraph.title(parsed_body) || Html.title(parsed_body)
    description = Opengraph.description(parsed_body) || Html.description(parsed_body)
    images = Opengraph.images(parsed_body)

    %{
      page
      | title: title,
        description: description,
        images: images
    }
  end
end
