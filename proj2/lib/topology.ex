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

    if actorNumber == 0 do
      [String.to_atom("actor_#{1}")]
    end
    if actorNumber == totalLength-1 do
      [String.to_atom("actor_#{totalLength - 2}")]
    else
      [String.to_atom("actor_#{actorNumber - 1}"),String.to_atom("actor_#{actorNumber + 1}")]
    end
  end

  '''
  def rand2D(actorList,curActor) do
       #adjMatrix =
       _
  end
  '''
  def get_3Dtorus_neighbours(actorList) do
    totalLength = length(actorList)
    n = Utils.findCubeRoot(1,totalLength)
    IO.inspect(n)
    Enum.reduce(actorList, %{}, fn x, acc ->
      Map.put(acc, x, torus3D_neighbor(actorList,x,n))
    end)
  end

  def torus3D_neighbor(actorList,curActor,n) do
    IO.inspect(curActor)
    totalLength = length(actorList)
    [_ , actorNumber] = String.split(Atom.to_string(curActor),"_")
    actorNumber = String.to_integer(actorNumber)

    nSqr = n * n

    #Get the layer of the torus
    layer = round(:math.floor(actorNumber/nSqr))
    #Get column and row
    column = round(rem(actorNumber,n))
    row = rem(round(:math.floor(actorNumber/n)),n)
    neighbours = []
    n_1 = n - 1
    IO.inspect("n-1 is #{n_1} n is #{n} row #{row} column #{column} layer #{layer}")
    #left and right neighbors
    neighbours = neighbours ++ (case column do
      0 ->
        [String.to_atom("actor_#{actorNumber + 1}"),String.to_atom("actor_#{actorNumber + n - 1}")]
      ^n_1 ->
        [String.to_atom("actor_#{actorNumber - 1}"),String.to_atom("actor_#{actorNumber - n + 1}")]
      _ ->
        [String.to_atom("actor_#{actorNumber + 1}"),String.to_atom("actor_#{actorNumber - 1}")]
    end)
    #top and bottom neighbors
    neighbours = neighbours ++ (case row do
      0 ->
        [String.to_atom("actor_#{actorNumber + n}"),String.to_atom("actor_#{actorNumber + (n*n) - n}")]
      ^n_1 ->
        [String.to_atom("actor_#{actorNumber - n}"),String.to_atom("actor_#{actorNumber - (n*n) + n}")]
      _ ->
        [String.to_atom("actor_#{actorNumber + n}"),String.to_atom("actor_#{actorNumber - n}")]
    end)
    #front and behind neighbors
    neighbours = neighbours ++ (case layer do
      0 ->
        [String.to_atom("actor_#{actorNumber + (n*n)}"),String.to_atom("actor_#{actorNumber + n*n*n - n*n}")]
      ^n_1 ->
        [String.to_atom("actor_#{actorNumber - (n*n)}"),String.to_atom("actor_#{actorNumber - n*n*n + n*n}")]
      _ ->
        [String.to_atom("actor_#{actorNumber + (n*n)}"),String.to_atom("actor_#{actorNumber - n*n}")]
    end)
    neighbours = List.flatten(neighbours)
    IO.inspect(neighbours)
    neighbours
  end

  def get_honeycomb_neighbours(actorList) do
      totalLength = length(actorList)
      n = round(:math.ceil(:math.sqrt(totalLength)))

      n = if rem(n,2) == 0 do
        n - 1
      else
        n
      end

      Enum.reduce(actorList, %{}, fn x, acc ->
      Map.put(acc, x, honeycomb_neighbor(actorList,x,n))
      end)
  end

  def honeycomb_neighbor(actorList,curActor,n) do

      totalLength = length(actorList)
      [_ , actorNumber] = String.split(Atom.to_string(curActor),"_")
      actorNumber = String.to_integer(actorNumber)
      neighbours = []

      if rem(actorNumber,2) == 0 do
        neighbours = neighbours ++ [(if actorNumber + n < totalLength do
          String.to_atom("actor_#{actorNumber + n}") else ""
        end)]
        neighbours = neighbours ++ [(if actorNumber - n >= 0 do
          String.to_atom("actor_#{actorNumber - n}") else ""
        end)]
        neighbours = neighbours ++ [(if actorNumber - 1 >= 0 && rem(actorNumber,n) != 0 do
          String.to_atom("actor_#{actorNumber - 1}") else ""
        end)]

        Enum.filter(neighbours, fn x -> x != "" end)
        #IO.inspect neighbours
      else
        neighbours = neighbours ++ [(if actorNumber + n < totalLength do
          String.to_atom("actor_#{actorNumber + n}") else ""
        end)]
        neighbours = neighbours ++ [(if actorNumber - n >= 0 do
          String.to_atom("actor_#{actorNumber - n}") else ""
        end)]
        neighbours = neighbours ++ [(if actorNumber + 1 < totalLength && rem(actorNumber,n) != (n-1) do
          String.to_atom("actor_#{actorNumber + 1}") else ""
        end)]

        Enum.filter(neighbours, fn x -> x != "" end)
        #IO.inspect neighbours
      end
  end

  def get_randhoneycomb_neighbours(actorList) do
    totalLength = length(actorList)
    n = round(:math.ceil(:math.sqrt(totalLength)))

    n = if rem(n,2) == 0 do
      n + 1
    else
      n
    end

    Enum.reduce(actorList, %{}, fn x, acc ->
    Map.put(acc, x, randhoneycomb_neighbor(actorList,x,n))
    end)
  end

  def randhoneycomb_neighbor(actorList,curActor,n) do
    totalLength = length(actorList)
    [_ , actorNumber] = String.split(Atom.to_string(curActor),"_")
    actorNumber = String.to_integer(actorNumber)
    neighbours = []

    if rem(actorNumber,2) == 0 do
      neighbours = neighbours ++ [(if actorNumber + n < totalLength do
        String.to_atom("actor_#{actorNumber + n}") else ""
      end)]
      neighbours = neighbours ++ [(if actorNumber - n >= 0 do
        String.to_atom("actor_#{actorNumber - n}") else ""
      end)]
      neighbours = neighbours ++ [(if actorNumber - 1 >= 0 && rem(actorNumber,n) != (n-1) do
        String.to_atom("actor_#{actorNumber - 1}") else ""
      end)]
      neighbours = neighbours ++ [Enum.random(actorList)]
      Enum.filter(neighbours, fn x -> x != "" end)
    else
      neighbours = neighbours ++ [(if actorNumber + n < totalLength do
        String.to_atom("actor_#{actorNumber + n}") else ""
      end)]
      neighbours = neighbours ++ [(if actorNumber - n >= 0 do
        String.to_atom("actor_#{actorNumber - n}") else ""
      end)]
      neighbours = neighbours ++ [(if actorNumber + 1 < totalLength && rem(actorNumber,n) != (n-1) do
        String.to_atom("actor_#{actorNumber + 1}") else ""
      end)]
      neighbours = neighbours ++ [Enum.random(actorList)]
      Enum.filter(neighbours, fn x -> x != "" end)

    end
  end

end
