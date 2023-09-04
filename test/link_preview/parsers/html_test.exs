defmodule LinkPreview.Parsers.HtmlTest do
  use LinkPreview.Case
  alias LinkPreview.Parsers.Html


  setup [:reset_defaults]

  describe "title" do
    test "optimistic case" do
      parsed_doc = Floki.parse_document!(@html)

      assert Html.title(parsed_doc) == "HTML Test Title"
    end

    test "pessimistic case" do
      parsed_doc = Floki.parse_document!(@opengraph)

      assert Html.title(parsed_doc) == nil
    end
  end

  describe "description" do
    test "optimistic case" do
      parsed_doc = Floki.parse_document!(@html)

      assert Html.description(parsed_doc) == "HTML Test Description"
    end

    test "pessimistic case" do
      parsed_doc = Floki.parse_document!(@opengraph)

      assert Html.description(parsed_doc) == nil
    end
  end



  defp reset_defaults(opts) do
    on_exit(fn ->
      Application.put_env(:link_preview, :friendly_strings, true)
      Application.put_env(:link_preview, :force_images_absolute_url, false)
      Application.put_env(:link_preview, :force_images_url_schema, false)
      Application.put_env(:link_preview, :filter_small_images, false)
    end)

    {:ok, opts}
  end
end
