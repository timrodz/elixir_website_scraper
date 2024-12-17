defmodule BG3.WeaponScraper do
  use Crawly.Spider
  alias ScraperUtils

  @base_url "https://bg3.wiki"

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

    table = document |> Floki.find(".wikitable")

    headers =
      table
      |> Floki.find("th")
      |> Enum.map(fn header ->
        case header |> Floki.text() |> ScraperUtils.cleanup_text() |> String.downcase() do
          "enchant." -> "enchantment"
          "weapon" -> "name"
          "damage type" -> "damage_type"
          h -> h
        end
        |> String.to_atom()
      end)

    items =
      table
      |> Floki.find("tr")
      |> Enum.map(fn row ->
        columns =
          row
          |> Floki.find("td")
          |> Enum.map(fn results ->
            Floki.text(results)
            |> ScraperUtils.cleanup_text()
          end)

        case length(columns) do
          0 ->
            nil

          _ ->
            # Grab the first link, which is the left-most table cell
            url =
              row
              |> Floki.find("td p span a")
              |> Enum.at(0)
              |> Floki.attribute("href")
              |> Floki.text()

            Enum.zip(headers, columns)
            |> Enum.into(%{})
            |> Map.put(:url, "#{@base_url}#{url}")
            |> Map.put(:category, get_weapon_category(response.request_url))
        end
      end)
      |> Enum.filter(&(&1 != nil))
      |> IO.inspect()

    %Crawly.ParsedItem{items: items, requests: []}
  end

  defp get_weapon_category(url) do
    cond do
      String.contains?(url, @one_handed_simple) -> "One-handed simple"
      String.contains?(url, @one_handed_martial) -> "One-handed martial"
      String.contains?(url, @one_handed_martial_ranged) -> "One-handed martial ranged"
      String.contains?(url, @versatile_simple) -> "Versatile simple"
      String.contains?(url, @versatile_martial) -> "Versatile martial"
      String.contains?(url, @two_handed_simple) -> "Two-handed simple"
      String.contains?(url, @two_handed_simple_ranged) -> "Two-handed simple ranged"
      String.contains?(url, @two_handed_martial) -> "Two-handed martial"
      String.contains?(url, @two_handed_martial_ranged) -> "Two-handed martial ranged"
      true -> exit("Unknown weapon category for #{url}")
    end
  end
end
