defmodule Dorf do
  use EnumType
  alias Grid.Coords, as: Coords

  defmodule Dwarf do
    @moduledoc """
    Represents a single Dwarf in the game
    """
    defenum State do
      value(Idle, "idle")
      value(Working, "working")
      value(Walking, "walking")

      default(Idle)
    end

    @enforce_keys [:name, :location]
    defstruct [:name, :location, destination: nil, state: State.default()]

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

  # <================================================================> #

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
