defmodule PQueue do
  @moduledoc """
  A Simple Priority Queue specifically for our custom GridNodes
  """

  @typedoc """
  Type that represents a Priority Queue of GridNodes
  """
  @type queue :: list(GridNode)

  @doc """
  Return a new priority queue
  """
  @spec new() :: list(GridNode)
  def new, do: []

  @doc """
  Implements a priority queue "pop" function, getting the next node with the lowest weight

  Returns {best_node, new_queue} after removing best_node from the queue
  """
  @spec pop(node_list) :: {nil, node_list} when node_list: []
  @spec pop(node_list) :: {GridNode, queue} when node_list: nonempty_list(GridNode)
  def pop(node_list) do
    # Find best node
    best_node =
      node_list
      |> Enum.sort_by(fn node -> node.weight end)
      |> List.first()

    index =
      node_list
      |> Enum.find_index(fn node -> node.x == best_node.x and node.y == best_node.y end)

    # Return the best node by index along with the remaining queue
    case index do
      nil -> {nil, node_list}
      idx -> node_list |> List.pop_at(idx)
    end
  end

  @doc """
  Implements a priority queue "push" function, which in this case is an "append if unique"

  Returns the new list of nodes
  """
  @spec push(queue, GridNode) :: queue
  def push(node_list, new_node) do
    case node_list |> Enum.find(fn node -> new_node == node end) do
      nil -> node_list ++ [new_node]
      _ -> node_list
    end
  end

  @doc """
  Check if the priority queue is empty or not
  """
  @spec empty?(queue) :: boolean
  def empty?(node_list), do: node_list |> Enum.empty?()
end
