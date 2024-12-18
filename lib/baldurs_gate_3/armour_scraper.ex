defmodule BG3.ArmourScraper do
  use Crawly.Spider
  alias ScraperUtils

  @base_url "https://bg3.wiki"

  @impl Crawly.Spider
  def base_url(), do: @base_url

  @impl Crawly.Spider
  def init() do
    [start_urls: ["#{@base_url}/wiki/Armour"]]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    items = ScraperUtils.scrape(document, response.request_url, &get_category/2)

    %Crawly.ParsedItem{items: items, requests: []}
  end

  defp get_category(_url, index) do
    # Armour will have 3 tables: light, medium, and heavy armour
    case index do
      0 -> "light armour"
      1 -> "medium armour"
      2 -> "heavy armour"
    end
  end
end
