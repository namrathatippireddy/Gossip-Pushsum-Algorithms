#the main module
defmodule GossipPushSum do
#This is the main module
  def main do
    argument_list = System.argv()

#start the timer before the algo is called for a topology and end it when all the nodes are traversed
#starttime-endtime gives the convergence time

    if Enum.count(argument_list)!= 3 do
      IO.puts "Provide number of nodes, topology and algorithm"
    else
      num_nodes = to_integer(Enum.at(argument_list, 0))
      topology  = Enum.at(argument_list, 1)
      algorithm = Enum.at(argument_list, 2)
    end

    if num_nodes <= 1 do
      IO.puts "Nodes should be greater than 1"
    end

    if topology != "full" || topology != "line" || topology != "rand2D" || topology != "3Dtorus" || 
       topology != "honeycomb" || topology != "randhoneycomb" do
       raise("Incorrect topology")
    end

    #get the correct number of nodes for a topology
    

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
        Topology.full()
      "line" ->
        Topology.line()
      "rand2D" ->
        Topology.rand2D()
      "3Dtorus" ->
        Topology.3Dtorus()
      "honeycomb" -> 
        Topology.honeycomb()
      "randhoneycomb" ->
        Topology.randhoneycomb() 
      _ ->
        IO.puts "Please enter a valid topology"
      end
    end

end

#creating pids--Implementing topologies
#TA suggested not to create another module for implementing topologies
#for 2D toplogy round the values to nearest square root
#for 3D nearest cube root






  def push_sum_start(s, w, pushsum_pids, stop) do
    ratio_list = []
    s = s/2
    w = w/2

    ratio = s/w
    ratio_list = ratio_list ++ [ratio]
    push_sum_algo(s, w, pushsum_pids)
  end
end
