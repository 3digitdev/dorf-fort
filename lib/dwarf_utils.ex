defmodule DwarfUtils do
  use EnumType

  defenum State do
    value(Idle, "idle")
    value(Working, "working")
    value(Walking, "walking")

    default(Idle)
  end

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
end
