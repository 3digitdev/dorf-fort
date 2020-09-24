defmodule Dorf do
  @moduledoc """
  Documentation for Dorf.
  """
  use Agent
  use EnumType

  defmodule Coords do
    defstruct [:x, :y]

    defimpl String.Chars, for: Coords do
      def to_string(coords), do: "(#{coords.x}, #{coords.y})"
    end

    def move_between(%Coords{x: x1, y: y1}, %Coords{x: x2, y: y2}) do
      xd =
        case x1 - x2 do
          r when r < 0 -> x1 + 1
          r when r == 0 -> x1
          r when r > 0 -> x1 - 1
        end

      yd =
        case y1 - y2 do
          r when r < 0 -> y1 + 1
          r when r == 0 -> y1
          r when r > 0 -> y1 - 1
        end

      %Coords{x: xd, y: yd}
    end
  end

  defmodule Dwarf do
    defenum State do
      value(Idle, "idle")
      value(Working, "working")
      value(Walking, "walking")

      default(Idle)
    end

    defstruct(
      name: :init,
      location: :init,
      destination: nil,
      state: State.default()
    )

    defimpl String.Chars, for: Dwarf do
      def to_string(dwarf) do
        "Dwarf '#{dwarf.name}'\n\t#{dwarf.state}\n\t#{dwarf.location}\n\t#{dwarf.destination}"
      end
    end

    def start_walking(dwarf, coords), do: %{dwarf | destination: coords, state: State.Walking}

    def update(dwarf) do
      # Movement
      case dwarf.state do
        State.Walking ->
          new_coords = Coords.move_between(dwarf.location, dwarf.destination)

          if new_coords != dwarf.destination do
            %{dwarf | location: new_coords}
          else
            %{dwarf | location: new_coords, destination: nil, state: State.Idle}
          end

        _ ->
          dwarf
      end
    end
  end

  def sandbox do
    dwarf = %Dwarf{name: "Erik", location: %Coords{x: 0, y: 0}}
    dwarf = Dwarf.start_walking(dwarf, %Coords{x: 30, y: 25})
    # Temporary "good enough" infinite loop for testing
    result =
      Enum.reduce_while(1..100_000, dwarf, fn _, acc ->
        if dwarf.state == State.Idle, do: {:halt, acc}, else: {:cont, Dwarf.update(acc)}
      end)

    IO.puts(result)
  end
end
