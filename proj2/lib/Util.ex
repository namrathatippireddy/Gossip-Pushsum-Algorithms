defmodule Utils do
  # "getNeighbour" might be an appropriate name here
  def get_neighbors(actors, topology) do
    case topology do
      # "line" ->
      "full" ->
        Topology.get_full_neighbors(actors)
        # "rand2D" -> numNodes
        # "3Dtorus" -> getCube(numNodes)
        # "honeycomb" -> numNodes
        # "randhoneycomd" -> numNodes
    end
  end
end
