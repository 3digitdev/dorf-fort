defmodule AStar do
  alias Grid.GridNode, as: GridNode

  defmodule Scores do
    @moduledoc """
    The scores needed for an A* search for a given GridNode
    """
    defstruct [:from_start, :thru_node]
  end

  @type priority_q  :: list(GridNode)
  @type score_map   :: %{GridNode => Scores}
  @type parent_map  :: %{GridNode => GridNode}

  @doc """
  The primary function for the A* search.  Initiates the Priority Queue for the search, and starts
  the algorithm to find a path from "start" to "goal"

  Returns the final path from "start" to "goal" as a list of GridNodes to navigate
  If no path exists, returns an empty list
  """
  @spec find_path(Grid, GridNode, GridNode) :: [GridNode]
  def find_path(grid, start, goal) do
    pqueue = PQueue.new() |> PQueue.push(start)
    score_map = Map.new()
      |> Map.put(start, %Scores{from_start: 0, thru_node: Grid.beeline_distance(start, goal)})
    loop(grid, goal, MapSet.new(), {pqueue, Map.new(), score_map})
  end

  @doc """
  Iterates through the Priority Queue

  Each call gets the next item from the queue and acts upon it, checking if we're done,
  then checking the neighbor nodes for traversal options

  When it reaches the goal, it rebuilds the path and returns it as a list of Grid Nodes to traverse
  """
  @spec loop(Grid, GridNode, MapSet.t, {priority_q, parent_map, score_map}) :: [GridNode]
  # If we get back an empty queue, that means we didn't find a path to the goal
  def loop(_, _, _, {pqueue, _, _}) when pqueue == [], do: []
  # The normal loop call
  def loop(grid, goal, visited_nodes, {pqueue, prev_node_map, node_scores}) do
    {current, pqueue} = pqueue |> PQueue.pop()
    if current == goal do  # already reached the goal
      prev_node_map |> build_path(current)
    else
      # Log current node as visited
      visited_nodes = visited_nodes |> MapSet.put(current)
      trackers = Enum.reduce(
        # For each neighbor of the current node...
        grid |> Grid.neighbors_of(current),
        # Starting with the base values...
        {pqueue, prev_node_map, node_scores},
        # Process the current neighbor.
        fn neighbor, {_pqueue, _prev_node_map, node_scores} = trackers ->
          cond do
            # Already visited this node
            visited_nodes |> MapSet.member?(neighbor) -> trackers
            # This is a blocked node
            neighbor.blocked -> trackers
            # Valid node to check in on
            true ->
              # this is the score from the start of the path through to the current neighbor node
              score_from_start = Map.get(node_scores, current).from_start + Grid.travel_weight(current, neighbor)
              case node_scores |> Map.get(neighbor) do
                :nil ->
                  # Neighbor node hasn't been scored yet, let's give it one
                  update_trackers(
                    trackers,
                    current,
                    neighbor,
                    goal,
                    score_from_start
                  )
                %{from_start: neighbor_score} when score_from_start < neighbor_score ->
                  # Neighbor has been scored at some point, and the new score is better
                  update_trackers(
                    trackers,
                    current,
                    neighbor,
                    goal,
                    score_from_start
                  )
                %{from_start: _} ->
                  # Neighbor has been scored before, and the old score is equal or better
                  trackers
              end
          end
        end
      )

      loop(grid, goal, visited_nodes, trackers)
    end
  end

  @doc """
  This function updates various tracker data structures that are being used in the A* search

  Returns all the updated trackers
  """
  @spec update_trackers(
    {priority_q, parent_map, score_map}, GridNode, GridNode, GridNode, float
  ) :: {priority_q, parent_map, score_map}
  def update_trackers({pqueue, prev_node_map, node_scores}, current, neighbor, goal, score_from_start) do
    {
      # Add neighbor to queue
      pqueue |> PQueue.push(neighbor),
      # Add neighbor to traversal map
      prev_node_map |> Map.put(neighbor, current),
      # Update neighbor scores
      node_scores |> Map.put(
        neighbor,
        %Scores{
          from_start: score_from_start,
          thru_node: Grid.beeline_distance(neighbor, goal) + score_from_start
        }
      )
    }
  end

  @doc """
  When A* is finished, this rebuilds the path from start->goal from the reversed traversal list

  Returns a list of GridNodes, in CORRECT order, starting at the FIRST STEP AFTER
  the Start Node, and ending with the Goal Node
  """
  @spec build_path(parent_map, GridNode) :: [GridNode]
  def build_path(prev_node_map, current, traversal_list \\ []) do
    case prev_node_map |> Map.get(current) do
      :nil -> traversal_list  # End of list
      parent -> prev_node_map |> build_path(parent, [current | traversal_list])
    end
  end

end
