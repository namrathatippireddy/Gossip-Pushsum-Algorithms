defmodule Gossip do
#This is the main module
  def main do
    argument_list = System.argv()

#start the timer before the algo is called for a topology and end it when all the nodes are traversed
#starttime-endtime gives the convergence time


    if Enum.count(argument_list)!= 3 do
      IO.puts "Provide number of nodes, topology and algorithm"
    else
    num_nodes = Enum.at(argument_list, 0)
    topology  = Enum.at(argument_list, 1)
    algorithm = Enum.at(argument_list, 2)
    end

    if num_nodes <= 1 do
      IO.puts "Nodes should be greater than 1"
    end

    main_pid = self()

    if algorithm == "gossip" do
      gossip_pids = get_pid_list(num_nodes, [], main_pid)
      generic_topology = generate_topology(topology)
      gossip_implementation(gossip_pids)
    else
      push_sum_pids = get_pid_list(num_nodes, [], main_pid)
      generic_topology = generate_topology(topology)
      pushsum_implementation(push_sum_pids)
    end
  end

#this function generates the pids list for gossip algo
  def get_pid_list(num_nodes, pid_list, main_pid) do
    pid_list = pid_list ++ spawn(Child, :init, [num_nodes, main_pid])
    get_pid_list(num_nodes-1, pid_list, main_pid)
  end

#gossip algo implementation

  def gossip_implementation() do
    start_time = :os.system_time(:millisecond)
    #main gossip logic
    if num_nodes_completed == num_nodes do
      stop_time = :os.system_time(:millisecond)
    end
    IO.puts ("Time taken for convergence of gossip algo is #{(start_time - stop_time)*1000}s")
  end

  def pushsum_implementation() do
    start_time = :os.system_time(:millisecond)
    #main gossip logic
    if num_nodes_completed = num_nodes do
      stop_time = :os.system_time(:millisecond)
    end
    IO.puts ("Time taken for convergence of pushsum algo is #{(start_time - stop_time)*1000}s")
  end


# this function handles the topology part
  def generate_topology(topology) do
    case topology do
      "full" ->
        full_topology_logic()
      "line" ->
        line_topology_logic()
      "rand2D" ->
        rand2D_topology_logic()
      "3Dtorus" ->
        3Dtorus_topology_logic()
      _ ->
        IO.puts "Please enter a valid topology"
      end
    end

end

#creating pids--Implementing topologies
#TA suggested not to create another module for implementing topologies
#for 2D toplogy round the values to nearest square root
#for 3D nearest cube root

#Gossip algorithm
defmodule Simulator_for_Gossip do
  use GenServer

  def start_link(vals_gossip) do
    GenServer.start_link(__MODULE__, vals_gossip)
  end

#In vals gossip, all the values are passed as an array, since vals_gossip is passed as the state of genserver, values are retaines
  def init(vals_gossip) do
    receive_msg()
    {:ok, vals_gossip}
  end

  def receive_msg(main_pid, gossip_pids, messages_received, stop) do
    receive do
      {:response_node, response} ->
        messages_received = messages_received +1
    end

    if (messages_received >= 5) do
      stop = true
      send main_pid, {:response_node, stop}
    else
      :timer.sleep(1000)
      pid_to_gossip = :rand.uniform(gossip_pids)
      gossip_msg(pid_to_gossip, messages_recieved)
    end

  def gossip_msg(pid, message) do
    send pid, {:response, "Hello"}
  end
end

end


#push_sum algorithm
defmodule Simulator_for_pushsum do
  use GenServer
  def start_link(vals_pushsum) do
    GenServer.start_link(__MODULE__, vals_pushsum)
  end

#In vals gossip, all the values are passed as an array, since vals_gossip is passed as the state of genserver, values are retaines
  def init(vals_pushsum) do
    receive_msg()
    {:ok, vals_pushsum}
  end

  def receive_msg(main_pid, pushsum_pids, s, w, [], stop) do
    receive do
      {:start_pushsum, response} ->
        push_sum_start(s,w,pushsum_pids)
      {:message_main, response} ->
        neighbors_pid_list = response
      {:response, response} ->
        push_sum_receive(s,w,pushsum_pids,stop)
    end
  end

  def push_sum_algo(s, w, pushsum_pids) do
    if pushsum_pids != nil do
    pid_to_pushsum = :rand.uniform(pushsum_pids)
    send pid_to_pushsum, {:response, [] ++ [s] ++ [w]}
  end

  def push_sum_receive(s, w, stop) do
    if !stop do
    s = s + Enum.at(response, 0)
    w = w + Enum.at(response, 1)

    s = s/2
    w = w/2

    ratio = s/w
    ratio_list = ratio_list ++ [ratio]
    if List.length(ratio_list) == 4
    ratio1 = Enum.at(ratio_list, 0)
    ratio2 = Enum.at(ratio_list, 1)
    ratio3 = Enum.at(ratio_list, 2)
    ratio4 = Enum.at(ratio_list, 3)

    if (abs(ratio2 - ratio1) <= 0.0000000001 && abs(ratio3 - ratio2) <= 0.0000000001 && abs(ratio4 - ratio3) <= 0.0000000001) do
       stop = true
       send main_pid, { :response, "stop" }
    else
      push_sum_algo(s, w, pushsum_pids, stop)
    end

  end
  end


  def push_sum_start(s, w, pushsum_pids, stop) do
    ratio_list = []
    s = s/2
    w = w/2

    ratio = s/w
    ratio_list = ratio_list ++ [ratio]
    push_sum_algo(s, w, pushsum_pids)
  end
end
