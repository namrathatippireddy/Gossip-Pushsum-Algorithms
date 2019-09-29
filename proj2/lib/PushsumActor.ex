defmodule PushsumActor do
  use GenServer

  def init(s) do

    {:ok, %{"s" => s, "w" => 1, "diff1"=>1, "diff2"=>1, "diff3"=>1 , "triggered"=> 0, "neighbors" => []}}
  end

  def handle_cast({:set_neighbors, neighbors}, state) do
    {:noreply, Map.put(state, "neighbors", neighbors)}
  end

  def handle_call({:get_neighbors}, _from, state) do
    {:reply, Map.fetch(state, "neighbors"), state}
  end

  def handle_cast({:transmit_values}, state) do
    {:ok, s} = Map.fetch(state, "s")
    {:ok, w} = Map.fetch(state, "w")
    # the following commented if branch will also hold good, depending on how you look at the problem, triggering one after the other, and
    # the chain reaction starts by itself (this is what is implemented) or a guys being picked by main, followed triggering all the actors at once
    # if length(neighbors) > 0 do
    {:ok, diff1} = Map.fetch(state, "diff1")
    {:ok, diff2} = Map.fetch(state, "diff2")
    {:ok, diff3} = Map.fetch(state, "diff3")

    if length(neighbors) > 0 && triggered!= 0 do
        _ = GenServer.cast(Enum.random(neighbors), {:receive_values, s, w, self()})
    end
    {:noreply, state}
  end

  def handle_cast({:receive_values, s_recvd, w_recvd, sender}, state) do
    {:ok, diff1} = Map.fetch(state, "diff1")
    {:ok, diff2} = Map.fetch(state, "diff2")
    {:ok, diff3} = Map.fetch(state, "diff3")

    #if three consecutive differences are less than 10 power -10 terminate the actor
    if (diff1 < :math.pow(10, -10) && diff2 < :math.pow(10, -10) && diff3 < :math.pow(10, -10)) do
      _ = GenServer.cast(sender, {:terminate_neighbor, self()})
      {:noreply, state}
    else

      # fetching current values and updating them
      s_old = Map.fetch(state, "s")
      w_old = Map.fetch(state, "w")
      s_new = s_old + s_recvd
      w_new = w_old + w_recvd

      diff1 = diff2
      diff2 = diff3
      diff3 = s_new/w_new

      #To keep half the value and send the other half
      s_new = s_new/2
      w_new = w_new/2


      state = Map.put(state, "s", s_new)
      state = Map.put(state, "w", w_new)
      state = Map.put(state, "diff1", diff1)
      state = Map.put(state, "diff2", diff2)
      state = Map.put(state, "diff3", diff3)
    end
  end

  def handle_cast({:terminate_neighbor, neighbor}, state) do
    {:ok, neighbors} = Map.fetch(state, "neighbors")
    {:noreply, Map.put(state, "neighbors", List.delete(neighbors, neighbor))}
  end

  def handle_call({:get_diff}, _from, state) do
    {:reply, Map.fetch(state, "count"), state}
  end

  def handle_call({:set_message}, _from, state) do
    {:reply, Map.put(state, "message", state)}
  end

  def set_neighbors(actor, neighbors) do
    GenServer.cast(actor, {:set_neighbors, neighbors})
  end
end
