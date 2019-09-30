# ToDo: implement all correct
defmodule Watcher do
  use GenServer

  def init(watcher_state) do
    {:ok,
     %{
       "main_pid" => Enum.at(watcher_state, 0),
       "num_nodes" => Enum.at(watcher_state, 1),
       "death_count" => 0
     }}
  end

  def handle_cast({:increment_deaths}, state) do
    {:ok, num_nodes} = Map.fetch(state, "num_nodes")
    {:ok, death_count} = Map.fetch(state, "death_count")
    {:ok, main_pid} = Map.fetch(state, "main_pid")

    if num_nodes == death_count do
      send(main_pid, {:gossip_end, ""})
    end

    state = Map.put(state, "death_count", death_count + 1)

    {:noreply, state}
    # watcherTodo: if numnodes==deathcount then
    # send(main_pid, {:gossip_end, ""})

    # cast-in-call:
    # def handle_call({:chechterminated}, {counter}):
    # start_time = :os.system_time(:millisecond)
    # start_gossiping(map_of_neighbors, node_list, true)
  end
end
