defmodule LinkPreview.Parsers.OpengraphTest do
  use LinkPreview.Case
  alias LinkPreview.Parsers.Opengraph

  describe "title" do
    test "optimistic case" do
      parsed_doc = Floki.parse_document!(@opengraph)

      assert Opengraph.title(parsed_doc) == "Opengraph Test Title"
    end

    test "pessimistic case" do
      parsed_doc = Floki.parse_document!(@html)

      assert Opengraph.title(parsed_doc) == nil
    end
  end

  describe "description" do
    test "optimistic case" do
      parsed_doc = Floki.parse_document!(@opengraph)

      assert Opengraph.description(parsed_doc) == "Opengraph Test Description"

    end

    test "pessimistic case" do
      parsed_doc = Floki.parse_document!(@html)

      assert Opengraph.description(parsed_doc) == nil
    end
  end

  describe "images" do
    test "optimistic case" do
      parsed_doc = Floki.parse_document!(@opengraph)

      assert Opengraph.images(parsed_doc) == [
               %{url: "http://example.com/images/og1.jpg"},
               %{url: "http://example.com/images/og2.jpg"}
             ]
    end

    test "pessimistic case" do
      parsed_doc = Floki.parse_document!(@html)

      assert Opengraph.images(parsed_doc) == []
    end
  end
end
