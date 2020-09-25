defmodule GridTest do
  use ExUnit.Case
  alias Grid.GridNode, as: GridNode
  doctest Grid

  test "create new empty grid" do
    assert Grid.new() == %{}
  end

  test "create new 2x2 grid" do
    assert Grid.new(2, 2) == %{
      0 => %{
        0 => %GridNode{x: 0, y: 0, weight: 0},
        1 => %GridNode{x: 0, y: 1, weight: 0}
      },
      1 => %{
        0 => %GridNode{x: 1, y: 0, weight: 0},
        1 => %GridNode{x: 1, y: 1, weight: 0}
      }
    }
  end

  test "set weight" do
    assert Grid.new(2, 2) |> Grid.set_weight(0, 1, 5) == {
      :ok,
      %{
        0 => %{
          0 => %GridNode{x: 0, y: 0, weight: 0},
          1 => %GridNode{x: 0, y: 1, weight: 5}
        },
        1 => %{
          0 => %GridNode{x: 1, y: 0, weight: 0},
          1 => %GridNode{x: 1, y: 1, weight: 0}
        }
      }
    }
  end

  test "set weight out of bounds" do
    assert Grid.new(2, 2) |> Grid.set_weight(0, 6, 5) == {
      :error,
      %{
        0 => %{
          0 => %GridNode{x: 0, y: 0, weight: 0},
          1 => %GridNode{x: 0, y: 1, weight: 0}
        },
        1 => %{
          0 => %GridNode{x: 1, y: 0, weight: 0},
          1 => %GridNode{x: 1, y: 1, weight: 0}
        }
      }
    }
  end

  test "set multiple weights" do
    assert Grid.new(2, 2) |> Grid.set_weights([
      {0, 0, 4}, {1, 0, 10}
    ]) == {
      :ok,
      %{
        0 => %{
          0 => %GridNode{x: 0, y: 0, weight: 4},
          1 => %GridNode{x: 0, y: 1, weight: 0}
        },
        1 => %{
          0 => %GridNode{x: 1, y: 0, weight: 10},
          1 => %GridNode{x: 1, y: 1, weight: 0}
        }
      }
    }
  end

  test "set blocker" do
    assert Grid.new(2, 2) |> Grid.set_blocker(0, 0) == {
      :ok,
      %{
        0 => %{
          0 => %GridNode{x: 0, y: 0, weight: 0, blocked: true},
          1 => %GridNode{x: 0, y: 1, weight: 0, blocked: false}
        },
        1 => %{
          0 => %GridNode{x: 1, y: 0, weight: 0, blocked: false},
          1 => %GridNode{x: 1, y: 1, weight: 0, blocked: false}
        }
      }
    }
  end

  test "set blocker out of bounds" do
    assert Grid.new(2, 2) |> Grid.set_blocker(4, 4) == {
      :error,
      %{
        0 => %{
          0 => %GridNode{x: 0, y: 0, weight: 0, blocked: false},
          1 => %GridNode{x: 0, y: 1, weight: 0, blocked: false}
        },
        1 => %{
          0 => %GridNode{x: 1, y: 0, weight: 0, blocked: false},
          1 => %GridNode{x: 1, y: 1, weight: 0, blocked: false}
        }
      }
    }
  end

  test "set multiple blockers" do
    assert Grid.new(2, 2) |> Grid.set_blockers([{0, 0}, {1, 0}, {1, 1}]) == {
      :ok,
      %{
        0 => %{
          0 => %GridNode{x: 0, y: 0, weight: 0, blocked: true},
          1 => %GridNode{x: 0, y: 1, weight: 0, blocked: false}
        },
        1 => %{
          0 => %GridNode{x: 1, y: 0, weight: 0, blocked: true},
          1 => %GridNode{x: 1, y: 1, weight: 0, blocked: true}
        }
      }
    }
  end

  #   X N X
  #   N C N
  #   X N X
  test "get neighbors of middle node" do
    grid = Grid.new(3, 3)

    assert grid |> Grid.neighbors_of(grid[1][1]) == [
      %GridNode{x: 0, y: 1, weight: 0},
      %GridNode{x: 2, y: 1, weight: 0},
      %GridNode{x: 1, y: 0, weight: 0},
      %GridNode{x: 1, y: 2, weight: 0}
    ]
  end

  #   C N X
  #   N X X
  #   X X X
  test "get neighbors of corner node" do
    grid = Grid.new(3, 3)

    assert grid |> Grid.neighbors_of(grid[0][0]) == [
      %GridNode{x: 1, y: 0, weight: 0},
      %GridNode{x: 0, y: 1, weight: 0}
    ]
  end

  #   N C N
  #   X N X
  #   X X X
  test "get neighbors of edge node" do
    grid = Grid.new(3, 3)

    assert grid |> Grid.neighbors_of(grid[0][1]) == [
      %GridNode{x: 1, y: 1, weight: 0},
      %GridNode{x: 0, y: 0, weight: 0},
      %GridNode{x: 0, y: 2, weight: 0}
    ]
  end

  #   X X X
  #   X X N
  #   X N C
  test "get neighbors of final node" do
    grid = Grid.new(3, 3)

    assert grid |> Grid.neighbors_of(grid[2][2]) == [
      %GridNode{x: 1, y: 2, weight: 0},
      %GridNode{x: 2, y: 1, weight: 0}
    ]
  end

  test "distance between two nodes" do
    assert Grid.travel_weight(
      %GridNode{x: 1, y: 2, weight: 3},
      %GridNode{x: 4, y: 6, weight: 2}
    ) == 2.5
  end

  test "beeline distance simple pythagorean triplet" do
    assert Grid.beeline_distance(
      %GridNode{x: 1, y: 2, weight: 1},
      %GridNode{x: 4, y: 6, weight: 1}
    ) == 5.0
  end

  test "beeline distance more complex result" do
    assert Grid.beeline_distance(
      %GridNode{x: 36, y: 23, weight: 1},
      %GridNode{x: 94, y: 16, weight: 1}
    ) == 58.42088667591412
  end
end
