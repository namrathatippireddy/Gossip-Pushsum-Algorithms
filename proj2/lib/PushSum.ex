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
