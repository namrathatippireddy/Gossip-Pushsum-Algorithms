defmodule Utils do
    # "getNeighbour" might be an appropriate name here
    def checkNodes(numNodes,topology) do
        case topology do
            "line" -> numNodes
            "full" -> numNodes
            "rand2D" -> numNodes
            "3Dtorus" -> getCube(numNodes)
            "honeycomb" -> numNodes
            "randhoneycomd" -> numNodes

end
