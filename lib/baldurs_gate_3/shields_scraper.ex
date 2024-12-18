defmodule BG3.ShieldsScraper do
  use Crawly.Spider
  alias ScraperUtils

  @base_url "https://bg3.wiki"

  @impl Crawly.Spider
  def base_url(), do: @base_url

  @impl Crawly.Spider
  def init() do
    [start_urls: ["#{@base_url}/wiki/Shields"]]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    items = ScraperUtils.scrape(document, response.request_url, &get_category/2)

    %Crawly.ParsedItem{items: items, requests: []}
  end

  defp get_category(_url, _index) do
    "shields"
  end
end
