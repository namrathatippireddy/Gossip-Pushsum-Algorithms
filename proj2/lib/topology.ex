defmodule Topology do
  def get_full_neighbors(actors) do
    Enum.reduce(actors, %{}, fn x, acc ->
      Map.put(acc, x, Enum.filter(actors, fn y -> y != x end))
    end)
  end

  def line(actorList) do
    Enum.reduce(actorList, %{}, fn x, acc ->
      Map.put(acc, x, line_neighbor(actorList,x))
    end)
  end

  def line_neighbor(actorList,curActor) do
    totalLength = length(actorList)
    [_ , actorNumber] = String.split(Atom.to_string(curActor),"_")
    actorNumber = String.to_integer(actorNumber)
    neighbours = []
    if actorNumber == 1 do
      [String.to_atom("actor_#{2}")]
    end
    if actorNumber == totalLength do
      [String.to_atom("actor_#{totalLength - 1}")]
    else
      [String.to_atom("actor_#{actorNumber - 1}"),String.to_atom("actor_#{actorNumber + 1}")]
    end
  end

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
