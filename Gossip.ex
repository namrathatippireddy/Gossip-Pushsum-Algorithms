defmodule Gossip do
  def convergence(num_nodes_completed, num_nodes, start_time, end_time, pid) do
    # keep track of time and number of nodes that are dead, try to build a connection for algo implementations
    receive do
      {:response, response} ->
        num_nodes_completed = num_nodes_completed + 1

      {:start_time, time_at_start} ->
        start_time = start_time = :os.system_time(:millisecond)
    end

    if num_nodes_completed >= num_nodes do
      stop_time = :os.system_time(:millisecond)
      IO.puts("Time taken for convergence of gossip algo is #{(start_time - stop_time) * 1000}s")
      send(pid, {:response, ""})
    else
      convergence(num_nodes_completed, num_nodes, start_time, end_time, pid)
    end
  end

  # This is the main module
  def main do
    argument_list = System.argv()

    # start the timer before the algo is called for a topology and end it when all the nodes are traversed
    # starttime-endtime gives the convergence time

    if Enum.count(argument_list) != 3 do
      IO.puts("Provide number of nodes, topology and algorithm")
    else
      num_nodes = Enum.at(argument_list, 0)
      topology = Enum.at(argument_list, 1)
      algorithm = Enum.at(argument_list, 2)
    end

    if num_nodes <= 1 do
      IO.puts("Nodes should be greater than 1")
    end

    main_pid = self()

    # TODO :What if algo name is invalid
    if algorithm == "gossip" do
      gossip_pids = get_pid_list_gossip(num_nodes, main_pid)

      spawn(Simulator_for_Gossip, :init, [])
    else
      push_sum_pids = get_pid_list_pushsum(num_nodes, [], main_pid)

      Enum.each(push_sum_pids, fn pid ->
        generic_topology = generate_topology(pid, topology, push_sum_pids)
        pushsum_implementation(push_sum_pids)
      end)
    end

    # this function generates the pids list for gossip algo
    def get_pid_list_gossip(num_nodes, main_pid) do
      pid_list = []

      pid_list =
        Enum.map(1..num_nodes, fn node ->
          spawn(Simulator_for_Gossip, :init, [])
        end)
    end

    # this function generates the pids list for gossip algo
    def get_pid_list_pushsum(num_nodes, pid_list, main_pid) do
      pid_list =
        Enum.map(1..num_nodes, fn node ->
          spawn(Simulator_for_pushsum, :init, [node, main_pid])
        end)
    end
  end
end

# Gossip algorithm -> change it same like pushsum
defmodule Simulator_for_Gossip do
  use GenServer

  def start_link(vals_gossip) do
    GenServer.start_link(__MODULE__, vals_gossip)
  end

  # In vals gossip, all the values are passed as an array, since vals_gossip is passed as the state of genserver, values are retaines
  def init(vals_gossip) do
    neighbor_pids = get_topology(pid, topology, gossip_pids)
    receive_msg(main_pid, gossip_pids, pid, messages_received, stop)
    {:ok, vals_gossip}
  end

  def receive_msg(main_pid, gossip_pids, pid, messages_received, stop) do
    start_gossip(gossip_pids, pid)

    receive do
      {:response_node, response} ->
        gossip_receive(
          main_pid,
          gossip_pids,
          pid_to_gossip,
          neighbor_pids,
          messages_received,
          stop
        )
    end

    # How to tell main that this pid is dead?
    def gossip_receive(
          main_pid,
          gossip_pids,
          pid_to_gossip,
          neighbor_pids,
          messages_received,
          stop
        ) do
      messages_received = messages_received + 1
      neighbor_pids = generate_topology(pid_to_gossip, topology, gossip_pids)
      pid_to_gossip = :rand.uniform(neighbor_pids)
      gossip_msg(pid_to_gossip, messages_recieved)

      if messages_received >= 5 do
        stop = true
        send(main_pid, {:response, stop})
      end

      def gossip_msg(pid_to_gossip, messages_received) do
        send(pid_to_gossip, {:response_node, "messages_received"})
      end

      def start_gossip(pid, gossip_pids, messages_received, topology)
      neighbor_pids = generate_topology(pid, topology, gossip_pids)
      pid_to_gossip = :rand.uniform(neighbor_pids)
      send(pid_to_gossip, {:response_node, messages_received})
    end
  end
end

# push_sum algorithm
defmodule Simulator_for_pushsum do
  use GenServer

  def start_link(vals_pushsum) do
    GenServer.start_link(__MODULE__, vals_pushsum)
  end

  # In vals gossip, all the values are passed as an array, since vals_gossip is passed as the state of genserver, values are retaines
  def init(vals_pushsum) do
    receive_msg()
    {:ok, vals_pushsum}
  end

  def receive_msg(main_pid, pushsum_pids, pid, s, w, [], stop) do
    push_sum_start(s, w, pushsum_pids, pid)

    receive do
      {:message_main, response} ->
        neighbors_pid_list = response

      {:response, response} ->
        push_sum_receive(s, w, stop, pushsum_pids, pid_to_pushsum)
    end
  end

  def push_sum_algo(s, w, neighbor_pids) do
    if pushsum_pids != nil do
      pid_to_pushsum = :rand.uniform(neighbor_pids)
      send(pid_to_pushsum, {:response, [] ++ [s] ++ [w]})
    end
  end

  def push_sum_receive(s, w, stop, pushsum_pids, pid_to_pushsum) do
    if !stop do
      neighbor_pids = generate_topology(pid_to_pushsum, topology, pushsum_pids)
      s = s + Enum.at(response, 0)
      w = w + Enum.at(response, 1)

      s = s / 2
      w = w / 2

      ratio = s / w
      # ratio_list = ratio_list ++ [ratio]
      if List.length(ratio_list) == 4 do
        ratio1 = Enum.at(ratio_list, 0)
        ratio2 = Enum.at(ratio_list, 1)
        ratio3 = Enum.at(ratio_list, 2)
        ratio4 = Enum.at(ratio_list, 3)
      end

      if abs(ratio2 - ratio1) <= 0.0000000001 && abs(ratio3 - ratio2) <= 0.0000000001 &&
           abs(ratio4 - ratio3) <= 0.0000000001 do
        stop = true
        send(main_pid, {:response, "stop"})
      else
        Enum.at(ratio_list, 0) = Enum.at(ratio_list, 1)
        Enum.at(ratio_list, 1) = Enum.at(ratio_list, 2)
        Enum.at(ratio_list, 2) = Enum.at(ratio_list, 3)
        Enum.at(ratio_list, 3) = ratio
        push_sum_algo(s, w, neighbor_pids)
      end
    end
  end

  def push_sum_start(s, w, pushsum_pids, pid) do
    neighbor_pids = generate_topology(pid, topology, pushsum_pids)
    ratio_list = []
    s = s / 2
    w = w / 2
    ratio = s / w
    ratio_list = ratio_list ++ [ratio]
    push_sum_algo(s, w, neighbor_pids)
  end
end
