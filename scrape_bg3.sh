#!/bin/bash

export SCRAPER="bg3"
export OUTPUT_FOLDER="./lib/baldurs_gate_3/output"
export OUTPUT_EXTENSION="csv"

iex -S mix run -e "Crawly.Engine.start_spider(BG3.WeaponScraper)"
