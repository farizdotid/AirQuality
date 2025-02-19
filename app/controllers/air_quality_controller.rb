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
          aqi_levels = [
            { range: 0..50, color: "bg-green-400", status: "Good", index: "0 to 50", description: "Air quality is satisfactory, and air pollution poses little or no risk." },
            { range: 51..100, color: "bg-yellow-400", status: "Moderate", index: "51 to 100", description: "Air quality is acceptable. However, there may be a risk for some people, particularly those who are unusually sensitive to air pollution." },
            { range: 101..150, color: "bg-orange-400", status: "Unhealthy for Sensitive Groups", index: "101 to 150", description: "Members of sensitive groups may experience health effects. The general public is less likely to be affected." },
            { range: 151..200, color: "bg-red-400", status: "Unhealthy", index: "151 to 200", description: "Some members of the general public may experience health effects; members of sensitive groups may experience more serious health effects." },
            { range: 201..300, color: "bg-purple-400", status: "Very Unhealthy", index: "201 to 300", description: "Health alert: The risk of health effects is increased for everyone." },
            { range: 301..500, color: "bg-rose-700", status: "Hazardous", index: "301 and higher", description: "Health warning of emergency conditions: everyone is more likely to be affected." }
          ]
          selected_level = aqi_levels.find { |level| level[:range].include?(@aqius) } || aqi_levels.last
          @bg_color = selected_level[:color]
          @level_status = selected_level[:status]
          @value_of_index = selected_level[:index]
          @description = selected_level[:description]
        else
          @error = "Failed to fetch air quality data."
        end
        # Render the Turbo Stream response
        render turbo_stream: turbo_stream.replace("air_quality_data", partial: "air_quality/data", locals: {
          data: @data,
          bgColor: @bg_color,
          levelStatus: @level_status,
          valueOfIndex: @value_of_index,
          description: @description,
          error: @error
        })
      end
    end
  end
end
