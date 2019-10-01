defmodule Gossip do
  # use GenServer
  # This is the main module

  def main do
    main_pid = self()
    argument_list = System.argv()

    # if Enum.count(argument_list) != 3 do
    #   IO.puts("Provide number of nodes, topology and algorithm")
    # else
    num_nodes = String.to_integer(Enum.at(argument_list, 0))
    topology = Enum.at(argument_list, 1)
    algorithm = Enum.at(argument_list, 2)
    # end

    if num_nodes <= 1 do
      IO.puts("Nodes should be greater than 1")
    end

    # add correction
    num_nodes = Utils.node_correction(num_nodes, topology)

    node_list =
      Enum.map(0..num_nodes - 1, fn n ->
        actor = "actor_" <> to_string(n)
        String.to_atom(actor)
      end)

    if algorithm == "gossip" do
      # Starting the watcher here
      {:ok, watcher_pid} = GenServer.start_link(Watcher, [main_pid, length(node_list), topology])
      spawn_actors(node_list, main_pid, watcher_pid)

      # now interate teammates code in here, Hoping to get a Map: key(actor):value[list of neighbors]
      map_of_neighbors = Utils.get_neighbors(node_list, topology)
      # IO.inspect(map_of_neighbors)

      # now set appropriate list of neighbors to each actor
      for {actor_name, neighbors} <- map_of_neighbors do
        # GossipActor.set_neighbors(actor, neighbors)
        GenServer.cast(actor_name, {:set_neighbors, neighbors})
      end

      start_time = :os.system_time(:millisecond)
      # Watcher-ToDo: {:ok, watcher} = GossipWatcher.start_link
      start_gossiping(map_of_neighbors, node_list, true)
      # end_time = :os.system_time(:millisecond)

      # Watcher calls the gossip end, when all the actors are done
      receive do
        {:algo_end, response} ->
          end_time = :os.system_time(:millisecond)
          IO.puts("Time taken for convergence is #{end_time - start_time}ms")
      end

      # IO.puts("Time taken for convergence is #{end_time - start_time}ms")
      # terminated_nodes = 0
      # receive do
      #   {:terminate, response} ->
      #     terminated_nodes = terminated_nodes + 1
      # end
      #
      # if(terminated_nodes == num_nodes) do
      #   end_time = :os.system_time(:millisecond)
      #   IO.puts("Time taken for convergence is #{end_time - start_time}ms")
      #   send(main_pid, {:terminated, ""})
      # end
    else
      # Pushsum logic starts here
      if algorithm == "pushsum" do
        {:ok, watcher_pid} = GenServer.start_link(Watcher, [main_pid, length(node_list), topology])
        spawn_pushsum_actors(node_list, watcher_pid)
        map_of_neighbors = Utils.get_neighbors(node_list, topology)

        # now set appropriate list of neighbors to each actor
        for {actor_name, neighbors} <- map_of_neighbors do
          GenServer.cast(actor_name, {:set_neighbors, neighbors})
        end

        start_time = :os.system_time(:millisecond)
        start_pushsum(node_list, map_of_neighbors, true)
        receive do
          {:algo_end, response} ->
            end_time = :os.system_time(:millisecond)
            IO.puts("Time taken for convergence is #{end_time - start_time}ms")
        end
      else
        IO.puts("Invalid algorithm, please enter a valid algorithm")
      end
    end
  end

  def spawn_actors(node_list, main_pid, watcher_pid) do
    # IO.inspect node_list
    # random_initial_node = Enum.random(node_list)

    Enum.map(node_list, fn n ->
      {:ok, actor} = GenServer.start_link(GossipActor, ["", n, main_pid, watcher_pid], name: n)
      actor
    end)
  end

  def start_gossiping(map_of_neighbors, node_list, first_call) do
    first_call =
      if first_call == true do
        actor_name = Enum.random(node_list)
        GenServer.cast(actor_name, {:receive_rumor, "rumor", actor_name})
        # (this won't work ad it is local scoped)
        first_call = false
      else
        false
      end

  end


  def spawn_pushsum_actors(node_list, watcher_pid) do
    # random_initial_node = Enum.random(node_list)
    #
    Enum.map(node_list, fn n ->
      [_, actorNumber] = String.split(Atom.to_string(n), "_")
      s_integer = String.to_integer(actorNumber)
      {:ok, actor} = GenServer.start_link(PushsumActor, [s_integer, 0, n, watcher_pid], name: n)
      actor
    end)
  end

  def start_pushsum(node_list, map_of_neighbors, first_call) do
    # Ask each actor to start sending values
    # for {actor_name, neighbors} <- map_of_neighbors do
    #   # ToDo: send the proper values here
    #   GenServer.cast(actor_name, {:transmit_values})
    # end

    # ToDo: For mahee I'm trying to run the previous code
    first_call =
      if first_call == true do
        actor_name = Enum.random(node_list)
        [_, actorNumber] = String.split(Atom.to_string(actor_name), "_")
        s_integer = String.to_integer(actorNumber)
        # GenServer.cast(actor_name, {:receive_values, s_integer, 1, actor_name})
        GenServer.cast(actor_name, {:transmit_values})
        # (this won't work ad it is local scoped)
        first_call = false
      else
        false
      end

  end

end
