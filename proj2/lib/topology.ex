defmodule Topology do
  def get_full_neighbors(actors) do
    Enum.reduce(actors, %{}, fn x, acc ->
      Map.put(acc, x, Enum.filter(actors, fn y -> y != x end))
    end)
  end

  # def line(actorList,curActor) do
  #     totalLength = length(actorList)
  #     {_, actorNumber} = String(curActor,"_")
  #     actorNumber = to_integer(actorNumber)
  #     neighbours = []
  #     if actorNumber - 1 >= 0 do
  #         neighbours ++ ["server_" <> to_string(actorNumber - 1)]
  #     end
  #
  #     if actorNumber + 1 < totalLength do
  #         neighbours ++ ["server_" <> to_string(actorNumber + 1)]
  #     end
  #     neighbours
  # end
  #
  # def rand2D(actorList,curActor) do
  #      #adjMatrix =
  #     _
  # end
  #
  # def torus3D(actorList,curActor) do
  #     totalLength = length(actorList)
  #     n = Units.findCubeRoot(to_interger)
  #     {_, actorNumber} = String(curActor,"_")
  #
  #     nSqr = n * n
  #     nCube = n * n * n
  #     #Corners of the 3D torus (layer1)
  #     corner1 = 0
  #     corner2 = n - 1
  #     corner3 = nSqr - n
  #     corner4 = nSqr - 1
  #
  #     #Corners of layer n
  #     corner5 = nCube - nSqr
  #     corner6 = nCube - nSqr + n - 1
  #     corner7 = nCube - n
  #     corner8 = nCube - 1
  #
  #     #Get the layer of the torus
  #     layer = :math.floor(actorNumber/nSqr)
  #
  #     column = :math.rem(actorNumer,n)
  #
  #     row = :math.rem((actorNumber/n),n)
  #
  #     #to be completed :p
  #
  #
  #
  #
  # end
end
