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
  