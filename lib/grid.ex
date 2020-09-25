defmodule Grid do
  @moduledoc """
  The Game Grid

  Represented as a Map{row_num => Map{col_num => GridNode}}
  """

  defmodule Coords do
    @moduledoc """
    A Coordinate representation for objects
    Helpful for referencing to the GridNode the object exists on at the time

    NOTE:  This is not used **inside** the GridNode, but it can be used
    to get a GridNode from the Grid
    """
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

  @doc """
  Get the current GridNode at a specified Coordinate set.  Useful when used from
  objects/dwarves that you need the current spot they are in
  """
  @spec get_node(Grid, Coords) :: GridNode
  def get_node(grid, coords), do: grid[coords.x][coords.y]

  defmodule GridNode do
    @moduledoc """
    A single node inside the game's Grid
    """
    @enforce_keys [:x, :y]
    defstruct [:x, :y, weight: 0, blocked: false]

    defimpl String.Chars, for: GridNode do
      def to_string(node), do: "(#{node.x}, #{node.y}) ~> #{node.weight}"
    end

    def left_node == right_node do
      Kernel.==(left_node.x, right_node.x) &&
        Kernel.==(left_node.y, right_node.y)
    end
  end

  @doc """
  Define a new Grid, which is a map of X coord -> column of (Y coord -> Node @ X,Y)

  Can either be empty or defined by width/height
  """
  @spec new(non_neg_integer, non_neg_integer) :: %{integer => %{integer => GridNode}}
  def new(height \\ 0, width \\ 0) do
    case height + width do
      0 ->
        %{}
      _ ->
        Enum.reduce(0..(height - 1), %{}, fn x, grid ->
          # credo:disable-for-next-line
          Map.put(grid, x, Enum.reduce(0..(width - 1), %{}, fn y, row ->
            Map.put(row, y, %GridNode{x: x, y: y})
          end))
        end)
    end
  end

  # Internal function for applying a transformation to a GridNode at specified coordinates
  @spec transform(Grid, non_neg_integer, non_neg_integer, ((GridNode) -> GridNode)) :: {:ok | :errpr, Grid}
  defp transform(grid, x, y, fun) do
    case grid[x] do
      :nil -> {:error, grid}  # x is out of bounds
      row ->
        case row[y] do
          :nil -> {:error, grid}  # y is out of bounds
          node ->
            {:ok, grid |> Map.put(x, row |> Map.put(y, fun.(node)))}
        end
    end
  end

  @doc """
  Set the weight of a Node in the Grid by coordinates

  Returns :ok with the updated Grid on success
  If coordinates are out of bounds, returns :error with the unchanged Grid
  """
  @spec set_weight(Grid, non_neg_integer, non_neg_integer, non_neg_integer) :: {:ok | :error, Grid}
  def set_weight(grid, x, y, weight) do
    grid |> transform(x, y, fn node -> %{node | weight: weight} end)
  end

  @doc """
  Multiple version of set_weight.  Allows you to pass multiple set_weight "instructions" together.

  Returns same as set_weight()
  """
  @spec set_weights(Grid, [{non_neg_integer, non_neg_integer, non_neg_integer}]) :: {:ok | :error, Grid}
  def set_weights(grid, weight_set_list) do
    Enum.reduce(weight_set_list, {:ok, grid}, fn {x, y, weight}, {_, acc} -> acc |> set_weight(x, y, weight) end)
  end

  @doc """
  Sets the GridNode at the given coordinates as a "blocked" node (wall, hole, etc)

  Returns :ok with the updated Grid on success
  If coordinates are out of bounds, returns :error with the unchanged Grid
  """
  @spec set_blocker(Grid, non_neg_integer, non_neg_integer) :: {:ok | :error, Grid}
  def set_blocker(grid, x, y) do
    grid |> transform(x, y, fn node -> %{node | blocked: true} end)
  end

  @doc """
  Multiple version of set_blocker.  Allows you to pass multiple coordinates together.

  Returns same as set_blocker()
  """
  @spec set_blockers(Grid, [{non_neg_integer, non_neg_integer}]) :: {:ok | :error, Grid}
  def set_blockers(grid, blocker_list) do
    Enum.reduce(blocker_list, {:ok, grid}, fn {x, y}, {_, acc} -> acc |> set_blocker(x, y) end)
  end

  @doc """
  Get the direct side-by-side neighbors of a given GridNode in a Grid.
  Does not fetch corner neighbors

  Returns a list of GridNodes
  If GridNode is on a corner, 2 neighbors are returned
  If GridNode is on an edge, 3 neighbors are returned
  Otherwise, 4 neighbors are returned
  """
  @spec neighbors_of(Grid, GridNode) :: list(GridNode)
  def neighbors_of(grid, %GridNode{x: x, y: y}) do
    [
      grid[x - 1][y] || :nil,  # top
      grid[x + 1][y] || :nil,  # bottom
      grid[x][y - 1] || :nil,  # left
      grid[x][y + 1] || :nil   # right
    ] |> Enum.filter(&(!is_nil(&1)))
  end

  @doc """
  Function to calculate distance between two arbitrary nodes, based on the weight

  Given that each node has a weight representing the difficulting of movement in that node,
  This will take the average between the two nodes' weights

  Realistically, this should only ever be called on adjacent nodes, however this assumption is not tested
  """
  @spec travel_weight(GridNode, GridNode) :: float
  def travel_weight(start, finish), do: (start.weight + finish.weight) / 2

  @doc """
  Heuristic function for finding the approximate distance between 2 nodes in a Grid

  Just calculates the length of the hypotenuse between the nodes (the "straight line")
  """
  def beeline_distance(start, finish) do
    run = Enum.max([start.x, finish.x]) - Enum.min([start.x, finish.x])
    rise = Enum.max([start.y, finish.y]) - Enum.min([start.y, finish.y])
    :math.sqrt(run * run + rise * rise)
  end
end
