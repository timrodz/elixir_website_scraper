defmodule ScraperUtils do
  @base_url "https://bg3.wiki"

  def map_headers(header) do
    case header do
      "weapon" -> "name"
      "armour" -> "name"
      "item" -> "name"
      "shield" -> "name"
      "enchant." -> "enchantment"
      "damage type" -> "damage_type"
      "armour class" -> "armour_class"
      "stealth disadvantage" -> "stealth_disadvantage"
      "armour class bonus" -> "armour_class_bonus"
      h -> h
    end
  end

  def scrape(document, request_url, get_category_fn) do
    document
    |> Floki.find(".wikitable")
    |> Enum.with_index()
    |> Enum.flat_map(fn {table, index} ->
      headers =
        table
        |> Floki.find("th")
        |> Enum.map(fn header ->
          header
          |> Floki.text()
          |> cleanup_text()
          |> String.downcase()
          |> map_headers()
          |> String.to_atom()
        end)
        |> IO.inspect(label: "headers")

      table
      |> Floki.find("tr")
      |> Enum.map(fn row ->
        columns =
          row
          |> Floki.find("td")
          |> Enum.map(fn results ->
            results
            |> Floki.text()
            |> cleanup_text()
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

            category = get_category_fn.(request_url, index)

            rarity = get_rarity(row)

            # Grab the first img, which is the left-most table cell
            image =
              row
              |> Floki.find("td img")
              |> Enum.at(0)
              |> Floki.attribute("src")
              |> Floki.text()

            Enum.zip(headers, columns)
            |> Enum.into(%{})
            |> Map.put(:url, "#{@base_url}#{url}")
            |> Map.put(:category, category)
            |> Map.put(:rarity, rarity)
            |> Map.put(:image, "#{@base_url}#{image}")
        end
      end)
      |> Enum.filter(&(&1 != nil))
    end)
  end

  def cleanup_text(input) do
    input
    |> String.trim()
    |> String.replace("\n", " ")
    |> String.replace("  ", " ")
    |> String.replace(" ", "")
  end

  def get_rarity(element) do
    rarity =
      element
      |> Floki.find("span.bg3wiki-itemicon")
      |> Floki.attribute("class")
      |> Floki.text()
      |> String.replace("bg3wiki-itemicon", "")
      |> String.replace("-", "")
      |> String.trim()

    case rarity do
      "veryrare" -> "very rare"
      _ -> rarity
    end
  end
end
