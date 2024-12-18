defmodule BG3.WeaponsScraper do
  use Crawly.Spider
  alias ScraperUtils

  @one_handed_martial [
    "Flails",
    "Morningstars",
    "Rapiers",
    "Scimitars",
    "Shortswords",
    "War_Picks"
  ]

  @versatile_martial [
    "Battleaxes",
    "Longswords",
    "Tridents",
    "Warhammers"
  ]

  @two_handed_martial [
    "Glaives",
    "Greataxes",
    "Greatswords",
    "Halberds",
    "Mauls",
    "Pikes"
  ]

  @one_handed_martial_ranged [
    "Hand_Crossbows"
  ]

  @two_handed_martial_ranged [
    "Heavy_Crossbows",
    "Longbows"
  ]

  @one_handed_simple [
    "Clubs",
    "Daggers",
    "Javelins",
    "Handaxes",
    "Maces",
    "Sickles"
  ]

  @versatile_simple [
    "Quarterstaves",
    "Spears"
  ]

  @two_handed_simple [
    "Greatclubs"
  ]

  @two_handed_simple_ranged [
    "Light_Crossbows",
    "Shortbows"
  ]

  @impl Crawly.Spider
  def base_url(), do: @base_url

  @impl Crawly.Spider
  def init() do
    [
      start_urls: get_urls()
    ]
  end

  def get_urls() do
    (@one_handed_martial ++
       @one_handed_martial_ranged ++
       @versatile_martial ++
       @two_handed_martial ++
       @two_handed_martial_ranged ++
       @one_handed_simple ++ @versatile_simple ++ @two_handed_simple ++ @two_handed_simple_ranged)
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
      String.contains?(url, @one_handed_simple) -> "one-handed simple"
      String.contains?(url, @one_handed_martial) -> "one-handed martial"
      String.contains?(url, @one_handed_martial_ranged) -> "one-handed martial ranged"
      String.contains?(url, @versatile_simple) -> "versatile simple"
      String.contains?(url, @versatile_martial) -> "versatile martial"
      String.contains?(url, @two_handed_simple) -> "two-handed simple"
      String.contains?(url, @two_handed_simple_ranged) -> "two-handed simple ranged"
      String.contains?(url, @two_handed_martial) -> "two-handed martial"
      String.contains?(url, @two_handed_martial_ranged) -> "two-handed martial ranged"
      true -> exit("Unknown weapon category for #{url}")
    end
  end
end
