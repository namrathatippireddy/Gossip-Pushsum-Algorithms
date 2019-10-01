defmodule PushsumActor do
  use GenServer

  def init(pushsum_state) do
    {:ok,
     %{
       "s" => Enum.at(pushsum_state, 0),
       "w" => 1,
       "diff1" => 1,
       "diff2" => 1,
       "diff3" => Enum.at(pushsum_state, 0),
       "triggered" => Enum.at(pushsum_state, 1),
       "neighbors" => [],
       # this is to carry actor name in the state to persist, might replace self()
       "name" => Enum.at(pushsum_state, 2),
       "watcher_pid" => Enum.at(pushsum_state, 3)
     }}
  end

  def handle_cast({:set_neighbors, neighbors}, state) do
    {:noreply, Map.put(state, "neighbors", neighbors)}
  end

  def handle_call({:get_neighbors}, _from, state) do
    {:reply, Map.fetch(state, "neighbors"), state}
  end

  def handle_cast({:transmit_values}, state) do
    state = Map.put(state, "triggered", 1)
    {:ok, s} = Map.fetch(state, "s")
    {:ok, w} = Map.fetch(state, "w")
    {:ok, triggered} = Map.fetch(state, "triggered")
    {:ok, neighbors} = Map.fetch(state, "neighbors")
    {:ok, watcher_pid} = Map.fetch(state, "watcher_pid")

    state = Map.put(state, "s", s / 2)
    state = Map.put(state, "w", w / 2)

    if length(neighbors) > 0 do
      # because of self() and the name conflict, it messes up here
      {:ok, actor_name} = Map.fetch(state, "name")
      #IO.inspect("Transmitting from #{actor_name}")
      _ = GenServer.cast(Enum.random(neighbors), {:receive_values, s / 2, w / 2, actor_name})
    else
      GenServer.cast(watcher_pid, {:algo_end})
    end

    {:noreply, state}
  end

  def handle_cast({:receive_values, s_recvd, w_recvd, sender}, state) do
    {:ok, diff1} = Map.fetch(state, "diff1")
    {:ok, diff2} = Map.fetch(state, "diff2")
    {:ok, diff3} = Map.fetch(state, "diff3")
    {:ok, s_cur} = Map.fetch(state, "s")
    {:ok, w_cur} = Map.fetch(state, "w")
    {:ok, watcher_pid} = Map.fetch(state, "watcher_pid")
    s_new = s_cur + s_recvd
    w_new = w_cur + w_recvd
    {:ok, actor_name} = Map.fetch(state, "name")

    {:ok, neighbors} = Map.fetch(state, "neighbors")
    #IO.inspect("recv from #{sender} in actor #{actor_name}")

    if length(neighbors) > 0 do
      next = Enum.random(neighbors)
      #IO.inspect(" send to next = #{next}")
      GenServer.cast(next, {:receive_values, s_new / 2, w_new / 2, actor_name})
    else
      GenServer.cast(watcher_pid, {:algo_end})
    end
    #IO.inspect("#{diff1} #{diff2} #{diff3}")
    # if three consecutive differences are less than 10 power -10 terminate the actor
    if diff1 < :math.pow(10, -10) && diff2 < :math.pow(10, -10) && diff3 < :math.pow(10, -10) do

      Enum.each(neighbors, fn each_neighbor ->
        GenServer.cast(each_neighbor, {:terminate_neighbor, actor_name})
      end)

      GenServer.cast(watcher_pid, {:increment_deaths})
      #IO.inspect("in here")

      {:noreply, state}
    else
      # Added this as a substitute for "for" loop in main

      # fetching current values and updating them

      diff1 = diff2
      diff2 = diff3
      cur_ratio = s_cur / w_cur
      new_ratio = s_new / w_new
      diff3 = abs(cur_ratio - new_ratio)
      #IO.inspect("current ratio #{cur_ratio}")
      # To keep half the value and send the other half
      # s_new = s_new / 2
      # w_new = w_new / 2

      state = Map.put(state, "s", s_new/2)
      state = Map.put(state, "w", w_new/2)
      state = Map.put(state, "diff1", diff1)
      state = Map.put(state, "diff2", diff2)
      state = Map.put(state, "diff3", diff3)
      # state = Map.put(state, "triggered", 1)
      # {:ok, neighbors} = Map.fetch(state, "neighbors")
      # GenServer.cast(Enum.random(neighbors), {:transmit_values})
      {:noreply, state}
    end
  end

  def handle_cast({:terminate_neighbor, neighbor}, state) do
    {:ok, neighbors} = Map.fetch(state, "neighbors")
    {:noreply, Map.put(state, "neighbors", List.delete(neighbors, neighbor))}
  end

  def handle_call({:check_alive}, _from, state) do
    {:ok, diff1} = Map.fetch(state, "diff1")
    {:ok, diff2} = Map.fetch(state, "diff2")
    {:ok, diff3} = Map.fetch(state, "diff3")

    # This syntax might be wrong
    if abs(diff1) > :math.pow(10, -10) || abs(diff2) > :math.pow(10, -10) ||
         abs(diff3) > :math.pow(10, -10) do
      {:reply, true, state}
    else
      {:reply, false, state}
    end
  end

  def handle_call({:set_message}, _from, state) do
    {:reply, Map.put(state, "message", state)}
  end
end
