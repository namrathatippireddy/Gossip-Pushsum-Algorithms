defmodule Gossip do
  #use GenServer
  # This is the main module

  def main do
    argument_list = System.argv()

    num_nodes = String.to_integer(Enum.at(argument_list, 0))
    topology = Enum.at(argument_list, 1)
    algorithm = Enum.at(argument_list, 2)

    if num_nodes <= 1 do
      IO.puts("Nodes should be greater than 1")
    end

    #add correction
    num_nodes = Utils.node_correction(num_nodes,topology)

    node_list = Enum.map(1..num_nodes, fn n ->
      actor = "actor_" <> to_string(n)
      String.to_atom(actor)
    end)

    if algorithm == "gossip" do
      actors = spawn_actors(node_list)

      # now interate teammates code in here, Hoping to get a Map: key(actor):value[list of neighbors]
      map_of_neighbors = Utils.get_neighbors(node_list, topology)
      IO.inspect map_of_neighbors

      # now set appropriate list of neighbors to each actor
      for {actor, neighbors} <- map_of_neighbors do
        # GossipActor.set_neighbors(actor, neighbors)
        GenServer.cast(actor, {:set_neighbors, neighbors})
      end

      start_time = :os.system_time(:millisecond)
      start_gossiping(actors, map_of_neighbors, node_list, true)
      end_time = :os.system_time(:millisecond)
      IO.puts("Time taken for convergence is #{end_time - start_time}ms")
    else
      # Call to pushsum actors goes here
    end
  end

  def spawn_actors(node_list) do

    #IO.inspect node_list
    Enum.map(node_list, fn n ->
        {:ok, actor} = GenServer.start_link(GossipActor, "", name: n)
        actor
        end)
  end

  def start_gossiping(actors, map_of_neighbors, node_list, first_call) do
    if first_call == true do
      actor = Enum.random(node_list)
      GenServer.cast(actor, {:transmit_rumor, "rumor"})
      first_call = false
    end
    live_actors = get_alive_actors(actors)

    if length(live_actors) > 1 do
      # Now map_of_neighbors should only have the entries of the alive actors
      map_of_neighbors =
        Enum.filter(map_of_neighbors, fn {actor, _} -> Enum.member?(live_actors, actor) end)

      start_gossiping(live_actors, map_of_neighbors,node_list, first_call)
    else
      IO.puts("Gosipping ends as all the actors are terminated")
    end
  end

  def get_alive_actors(actors) do
    # Returns all the actors whoes count is less than 10 and have atleast one neighbor
    alive_actors =
      Enum.map(actors, fn act ->
        {:ok, neighbors_list} = GenServer.call(act, {:get_neighbors})
        neighbors_count = length(neighbors_list)
        {:ok, count} = GenServer.call(act, {:get_count})

        if Process.alive?(act) && count < 10 && neighbors_count > 0 do
          act
        end
      end)
    #IO.inspect alive_actors
    List.delete(Enum.uniq(alive_actors), nil)
  end
end

# push_sum algorithm
