class AirQualityController < ApplicationController
  require "httparty"

  def index
    @loading = true

    url = "#{Rails.application.credentials.dig(:air_quality_api, :base_url)}/api/v1/getCityRankByCitySlug"
    headers = {
      "Authorization" => "bearer #{Rails.application.credentials.dig(:air_quality_api, :bearer_token)}",
      "cityslug" => "indonesia/jawa-barat/bandung",
      "sensorname" => "aqi"
    }

    response = HTTParty.get(url, headers: headers)

    if response.success?
      @data = response.parsed_response["data"]
    else
      @error = "Failed to fetch air quality data."
    end

    @loading = false
  end
end
