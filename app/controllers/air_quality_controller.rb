class AirQualityController < ApplicationController
  require "httparty"

  def index
    respond_to do |format|
      format.html
      format.turbo_stream do
        url = "#{Rails.application.credentials.dig(:air_quality_api, :base_url)}/api/v1/getCityRankByCitySlug"
        headers = {
          "Authorization" => "bearer #{Rails.application.credentials.dig(:air_quality_api, :bearer_token)}",
          "cityslug" => "indonesia/jawa-barat/bandung",
          "sensorname" => "aqi"
        }
        response = HTTParty.get(url, headers: headers)
        if response.success?
          @data = response.parsed_response["data"]
          @aqius = @data["location"]["aqius"]
          if @aqius <= 50
            @bg_color = "bg-green-400"
          elsif @aqius >= 51 && @aqius <= 100
            @bg_color = "bg-yellow-400"
          elsif @aqius >= 101 && @aqius <= 150
            @bg_color = "bg-orange-400"
          elsif @aqius >= 151 && @aqius <= 200
            @bg_color = "bg-red-400"
          elsif @aqius >= 201 && @aqius <= 300
            @bg_color = "bg-purple-400"
          elsif @aqius >= 301 && @aqius <= 500
            @bg_color = "bg-rose-700"
          end
        else
          @error = "Failed to fetch air quality data."
        end

        render turbo_stream: turbo_stream.replace("air_quality_data", partial: "air_quality/data", locals: {
          data: @data, bgColor: @bg_color, error: @error })
      end
    end
  end
end
