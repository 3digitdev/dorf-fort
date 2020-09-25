defmodule AStarTest do
  use ExUnit.Case
  alias Grid.GridNode, as: GridNode
  doctest AStar

  # Utility Functions
  # build_path()
  test "build path" do
    start_node = %GridNode{x: 8, y: 1, weight: 6}
    node_2     = %GridNode{x: 4, y: 2, weight: 5}
    node_3     = %GridNode{x: 2, y: 3, weight: 4}
    node_4     = %GridNode{x: 1, y: 4, weight: 3}
    node_5     = %GridNode{x: 9, y: 9, weight: 2}
    node_6     = %GridNode{x: 5, y: 5, weight: 1}
    goal_node  = %GridNode{x: 0, y: 0, weight: 0}
    prev_node_map = %{
      node_3     => node_2,
      goal_node  => node_6,
      node_4     => node_3,
      node_2     => start_node,
      node_5     => node_4,
      node_6     => node_5,
      start_node => :nil,
    }
    assert AStar.build_path(prev_node_map, goal_node) == [
      node_2, node_3, node_4, node_5, node_6, goal_node
    ]
  end

  test "build short path" do
    start_node = %GridNode{x: 5, y: 5, weight: 1}
    goal_node  = %GridNode{x: 0, y: 0, weight: 0}
    prev_node_map = %{
      goal_node => start_node,
      start_node => :nil
    }
    assert AStar.build_path(prev_node_map, goal_node) == [goal_node]
  end

  # update_trackers()
  test "update trackers empty" do
    current =  %GridNode{x: 5, y: 5, weight: 1}
    neighbor = %GridNode{x: 6, y: 5, weight: 4}
    goal =     %GridNode{x: 10, y: 10, weight: 10}
    assert AStar.update_trackers(
      {PQueue.new(), %{}, %{}}, current, neighbor, goal, 18
    ) == {
      [neighbor],
      %{neighbor => current},
      %{neighbor => %AStar.Scores{from_start: 18, thru_node: 24.40312423743285}}
    }
  end

  test "update trackers existing data" do
    old      = %GridNode{x: 4, y: 5, weight: 4}
    current  = %GridNode{x: 5, y: 5, weight: 1}
    neighbor = %GridNode{x: 6, y: 5, weight: 4}
    goal     = %GridNode{x: 10, y: 10, weight: 10}
    assert AStar.update_trackers(
      {[current], %{current => old}, %{current => %AStar.Scores{from_start: 17, thru_node: 23.2536475}}},
      current,
      neighbor,
      goal,
      18
    ) == {
      [current, neighbor],
      %{current => old, neighbor => current},
      %{
        current  => %AStar.Scores{from_start: 17, thru_node: 23.2536475},
        neighbor => %AStar.Scores{from_start: 18, thru_node: 24.40312423743285}
      }
    }
  end

  # loop()
  test "loop empty queue" do
    assert AStar.loop(:nil, :nil, :nil, {[], :nil, :nil}) == []
  end

  test "find simple path" do
    grid    = Grid.new(2, 2)
    goal    = grid[1][1]
    current = grid[1][0]
    assert AStar.find_path(grid, current, goal) == [goal]
  end

  test "find multiple point path" do
    grid  = Grid.new(2, 2)
    goal  = grid[1][1]
    start = grid[0][0]
    assert AStar.find_path(grid, start, goal) == [grid[1][0], goal]
  end

  @doc """
     0 1 2 3
    +-------
  0 |8 7 X B
  1 |X 6 5 B
  2 |X X 4 B
  3 |1 2 3 B
  """
  test "find complex path" do
    # B == Walls, set them as blockers
    {_, grid} = Grid.new(4, 4) |> Grid.set_blockers([
      {0, 3}, {1, 3}, {2, 3}, {3, 3}
    ])
    # Setup weights for unblocked walls
    {_, grid} = grid |> Grid.set_weights([
      # Set huge weights for all the ones we want to avoid (X's in above diagram)
      {0, 2, 500}, {1, 0, 500},
      {2, 0, 500}, {2, 1, 500},
      # Set weights to ensure path above is followed (weight == # in diagram above)
      {3, 0, 1}, {3, 1, 2}, {3, 2, 3}, {2, 2, 4},
      {1, 2, 5}, {1, 1, 6}, {0, 1, 7}, {0, 0, 8},
    ])
    start = grid[3][0]
    goal  = grid[0][0]
    assert AStar.find_path(grid, start, goal) == [
      grid[3][1], grid[3][2], grid[2][2], grid[1][2], grid[1][1], grid[0][1], goal
    ]
  end

  @doc """
     0 1 2 3
    +-------
  0 |X X B G
  1 |X X X B
  2 |X X X X
  3 |S X X X
  """
  test "try to find invalid path" do
    # Start at "S", trying to find "G", but it all of G's neighbors are blocked
    {_, grid} = Grid.new(4, 4) |> Grid.set_blockers([{0, 2}, {1, 3}])
    start = grid[3][0]
    goal = grid[0][3]
    assert AStar.find_path(grid, start, goal) == []
  end
end
