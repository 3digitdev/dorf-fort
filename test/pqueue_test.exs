defmodule PQueueTest do
  use ExUnit.Case
  alias Grid.GridNode, as: GridNode
  doctest PQueue

  test "get best node from list" do
    assert PQueue.pop([
      %GridNode{x: 1, y: 1, weight: 5},
      %GridNode{x: 1, y: 2, weight: 4},
      %GridNode{x: 2, y: 1, weight: 2},
      %GridNode{x: 2, y: 2, weight: 3}
    ]) == {
      %GridNode{x: 2, y: 1, weight: 2},
      [
        %GridNode{x: 1, y: 1, weight: 5},
        %GridNode{x: 1, y: 2, weight: 4},
        %GridNode{x: 2, y: 2, weight: 3}
      ]
    }
  end

  test "get best node from single-item list" do
    assert PQueue.pop([
      %GridNode{x: 1, y: 1, weight: 0}
    ]) == {%GridNode{x: 1, y: 1, weight: 0}, []}
  end

  test "get best node from empty list" do
    assert PQueue.pop([]) == {nil, []}
  end

  test "add first node to list" do
    assert PQueue.push([], %GridNode{x: 1, y: 1, weight: 2}) == [%GridNode{x: 1, y: 1, weight: 2}]
  end

  test "add node to list with items" do
    assert PQueue.push(
      [%GridNode{x: 1, y: 1, weight: 2}],
      %GridNode{x: 1, y: 2, weight: 3}
    ) == [%GridNode{x: 1, y: 1, weight: 2}, %GridNode{x: 1, y: 2, weight: 3}]
  end

  test "add existing node doesn't happen" do
    assert PQueue.push(
      [%GridNode{x: 1, y: 1, weight: 2}],
      %GridNode{x: 1, y: 1, weight: 2}
    ) == [%GridNode{x: 1, y: 1, weight: 2}]
  end

  test "check empty list" do
    assert PQueue.empty?([]) == true
    assert PQueue.empty?([%GridNode{x: 1, y: 1, weight: 2}]) == false
  end
end
