# trying a commit
defmodule Gossip do
  use GenServer
  # This is the main module
  def main do
    argument_list = System.argv()
    # num_nodes = 0

    # if Enum.count(argument_list) != 3 do
    #   IO.puts("Provide number of nodes, topology and algorithm")
    # else
    #   num_nodes = Enum.at(argument_list, 0)
    #   topology = Enum.at(argument_list, 1)
    #   algorithm = Enum.at(argument_list, 2)
    # end

    num_nodes = String.to_integer(Enum.at(argument_list, 0))
    topology = Enum.at(argument_list, 1)
    algorithm = Enum.at(argument_list, 2)

    if num_nodes <= 1 do
      IO.puts("Nodes should be greater than 1")
    end

    if algorithm == "gossip" do
      actors = spawn_actors(num_nodes)

      # now interate teammates code in here, Hoping to get a Map: key(actor):value[list of neighbors]
      map_of_neighbors = Utils.get_neighbors(actors, topology)

      # now set appropriate list of neighbors to each actor
      for {actor, neighbors} <- map_of_neighbors do
        GenServer.cast(actor, {:set_neighbors, neighbors})
      end

      start_gossiping(actors, map_of_neighbors)
    else
      # Call to pushsum actors goes here
    end
  end

  def spawn_actors(num_nodes) do
    random_initial_node = Enum.random(1..num_nodes)

    actor =
      Enum.map(1..num_nodes, fn n ->
        if n == random_initial_node do
          {:ok, actor} = GenServer.start_link(GossipActor, "rumor")
        else
          {:ok, actor} = GenServer.start_link(GossipActor, "")
        end
      end)
  end

  def start_gossiping(actors, map_of_neighbors) do
    # For each actor trigger transmit rumor on it as a handle cast
    for {actor, neighbors} <- map_of_neighbors do
      GenServer.cast(actor, {:transmit_rumor})
    end

    live_actors = get_alive_actors(actors)

    if length(live_actors) > 1 do
      # Now map_of_neighbors should only have the entries of the alive actors
      map_of_neighbors =
        Enum.filter(map_of_neighbors, fn {actor, _} -> Enum.member?(live_actors, actor) end)

      start_time = :os.system_time(:millisecond)
      start_gossiping(live_actors, map_of_neighbors)
      end_time = :os.system_time(:millisecond)
      IO.puts("Time taken for convergence is #{(start_time - end_time) * 1000}s")
    else
      IO.puts("Gosipping ends as all the actors are terminated")
    end
  end

  def get_alive_actors(actors) do
    # Returns all the actors whoes count is less than 10 and have atleast one neighbor
    alive_actors =
      Enum.map(actors, fn act ->
        {:ok, neighbors_count} = GenServer.call(act, {:get_neighbors_count})
        {:ok, count} = GenServer.call(act, {:get_count})

        if Process.alive?(act) && count < 10 && neighbors_count > 0 do
          act
        end
      end)

    List.delete(Enum.uniq(alive_actors), nil)
  end
end

# push_sum algorithm
