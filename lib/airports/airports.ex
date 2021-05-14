defmodule Airports.Airports do
  alias NimbleCSV.RFC4180, as: CSV

  def airports_csv() do
    Application.app_dir(:cdp, "/priv/airports.csv")
  end

  def open_airports() do
    window = Flow.Window.trigger_every(Flow.Window.global(), 1000)

    airports_csv()
    |> File.stream!()
    |> Stream.map(fn event ->
      Process.sleep(Enum.random([0, 0, 0, 1]))
      event
    end)
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
      # skip_headers because reads line by line now
      [row] = CSV.parse_string(row, skip_headers: false)

      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
    end)
    |> Flow.reject(&(&1.type == "closed"))
    |> Flow.partition(window: window, key: {:key, :country})
    |> Flow.group_by(& &1.country)
    |> Flow.on_trigger(fn acc, _partition_info, {_type, _id, trigger} ->
      events =
        acc
        |> Enum.map(fn {country, data} -> {country, Enum.count(data)} end)
        |> IO.inspect(label: inspect(self()))

      case trigger do
        :done -> {events, acc}
        {:every, 1000} -> {[], acc}
      end
    end)
    |> Flow.take_sort(10, fn {_, a}, {_, b} -> a > b end)
    |> Enum.to_list()
    |> List.flatten()
  end
end

# RESULTS
#
# # Naive Enum
# iex(2)> :timer.tc(&Airports.Airports.open_airports/0)
# {3_540_285, ...}
#
# iex(1)> :timer.tc(&Airports.Airports.open_airports/0)
# {933_022, ...}
#
# # Stream
# iex(3)> :timer.tc(&Airports.Airports.open_airports/0)
# {2_503,
#
# # Flow - naive
# iex(5)> :timer.tc(&Airports.Airports.open_airports/0)
# {916_531,
#
# # Flow - parse CSV in map
# iex(7)> :timer.tc(&Airports.Airports.open_airports/0)
# {891_809,
#
# # Flow + read_ahead
# iex(9)> :timer.tc(&Airports.Airports.open_airports/0)
# {1_020_540,
