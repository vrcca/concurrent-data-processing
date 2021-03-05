defmodule Airports.Airports do
  alias NimbleCSV.RFC4180, as: CSV

  def airports_csv() do
    Application.app_dir(:cdp, "/priv/airports.csv")
  end

  def open_airports() do
    airports_csv()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn row ->
      # :binary.copy is required if you want to keep the data from CSV
      # because row is just a reference to the file (which is good for performance)
      %{
        id: :binary.copy(Enum.at(row, 0)),
        type: :binary.copy(Enum.at(row, 2)),
        name: :binary.copy(Enum.at(row, 3)),
        country: :binary.copy(Enum.at(row, 8))
      }
    end)
    |> Stream.reject(&(&1.type == "closed"))
    |> Enum.to_list()
  end
end
