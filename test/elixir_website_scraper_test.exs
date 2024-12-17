defmodule WebsiteScraperTest do
  use ExUnit.Case
  doctest WebsiteScraper

  test "greets the world" do
    assert WebsiteScraper.hello() == :world
  end
end
