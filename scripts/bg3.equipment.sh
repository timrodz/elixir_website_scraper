#!/bin/bash

export SCRAPER="bg3.equipment"
export OUTPUT_FOLDER="./lib/baldurs_gate_3/output"
export OUTPUT_EXTENSION="csv"

cd ..
iex -S mix run -e "Crawly.Engine.start_spider(BG3.EquipmentScraper)"
