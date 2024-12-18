defmodule BG3.EquipmentScraper do
  use Crawly.Spider
  alias ScraperUtils

  @base_url "https://bg3.wiki"

  @clothing "Clothing"
  @headwear "Headwear"
  @cloaks "Cloaks"
  @handwear "Handwear"
  @footwear "Footwear"
  @amulets "Amulets"
  @rings "Rings"

  @impl Crawly.Spider
  def base_url(), do: @base_url

  @impl Crawly.Spider
  def init() do
    [
      start_urls: get_urls()
    ]
  end

  def get_urls() do
    [@clothing, @headwear, @cloaks, @handwear, @footwear, @amulets, @rings]
    |> Enum.map(fn category -> "#{@base_url}/wiki/#{category}" end)
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    items = ScraperUtils.scrape(document, response.request_url, &get_category/2)

    %Crawly.ParsedItem{items: items, requests: []}
  end

  defp get_category(url, _index) do
    cond do
      String.contains?(url, @clothing) -> "clothing"
      String.contains?(url, @headwear) -> "headwear"
      String.contains?(url, @cloaks) -> "cloaks"
      String.contains?(url, @handwear) -> "handwear"
      String.contains?(url, @footwear) -> "footwear"
      String.contains?(url, @amulets) -> "amulets"
      String.contains?(url, @rings) -> "rings"
      true -> exit("Unknown equipment category for #{url}")
    end
  end
end
