import Config

validation_fields =
  case System.get_env("SCRAPER") do
    "bg3" ->
      [:name, :enchantment, :damage, :damage_type, :weight, :price, :special, :url, :category]

    _ ->
      [:url]
  end

output_folder = System.get_env("OUTPUT_FOLDER")
output_extension = System.get_env("OUTPUT_EXTENSION")

pipeline_encoder =
  case output_extension do
    "csv" -> {Crawly.Pipelines.CSVEncoder, fields: validation_fields}
    _ -> Crawly.Pipelines.JSONEncoder
  end

config :crawly,
  closespider_timeout: 10,
  concurrent_requests_per_domain: 8,
  closespider_itemcount: 100,
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    Crawly.Middlewares.UniqueRequest,
    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot"]}
  ],
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:url, :name]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :url},
    pipeline_encoder,
    {
      Crawly.Pipelines.WriteToFile,
      folder: output_folder, extension: output_extension
    }
  ]