#############################################################################
##
#W  oper.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# graph algorithms

#

InstallMethod(DigraphFloydWarshall, "for a digraph",
[IsDigraph, IsFunction, IsObject, IsObject],
function(graph, func, nopath, edge)
  local vertices, n, m, dist, out, i, j, k;

  vertices := DigraphVertices(graph);
  n := DigraphNrVertices(graph);
  dist := EmptyPlist(n);

  for i in vertices do
    dist[i] := EmptyPlist(n);
    for j in vertices do 
      dist[i][j]:=nopath;
    od;
  od;
  
  if HasDigraphSource(graph) then 
    m := Length(DigraphSource(graph));
    for i in [ 1 .. m ] do
      dist[ DigraphSource(graph)[i] ][ DigraphRange(graph)[i] ] := edge;
    od;
  else
    out := OutNeighbours(graph);
    for i in vertices do 
      for j in out[i] do 
        dist[i][j] := edge;
      od;
    od;
  fi;
  
  for k in vertices do
    for i in vertices do
      for j in vertices do
        func(dist, i, j, k);
      od;
    od;
  od;

  return dist;
end);

#

InstallMethod(QuotientDigraph, "for a digraph and a list", 
[IsDigraph and HasOutNeighbours, IsHomogeneousList],
function(graph, verts)
  local nr, lookup, old, new, adj, j, l, i, k;
  
  nr := DigraphNrVertices(graph);

  if (IsRange(verts) and not (IsPosInt(verts[1]) and verts[1] <= nr and
    verts[Length(verts)] <= nr)) 
    or ForAny(verts, x-> not IsPosInt(x) or x > nr) 
    or not IsDuplicateFree(verts) then 
    Error("Digraphs: QuotientDigraph: usage,\n ", 
      "the 2nd argument <verts> must consist of vertices of the 1st ", 
      "argument <graph>,\n");
  fi;
  
  lookup := [ 1 .. nr ] * 0;
  nr := Length(verts); 
  lookup{verts} := [ 1 .. nr ];

  old := OutNeighbours(graph);
  new := EmptyPlist(nr);

  for i in [ 1 .. nr ] do 
    adj := [];
    j := 0;
    for k in old[verts[i]] do
      l := lookup[k];
      if l <> 0 then 
        j := j + 1;
        adj[j] := l;
      fi;
    od;
    new[i]:=adj;
  od;

  return DigraphNC(new);
end);

#

InstallMethod(DigraphReverse, "for a digraph with source",
[IsDigraph and HasDigraphSource],
function(graph)
  local source, range;

    source := ShallowCopy(DigraphRange(graph));
    range := Permuted(DigraphSource(graph), Sortex(source));

    return DigraphNC(rec( source:=source, 
                                range:=range,
                                nrvertices:=DigraphNrVertices(graph)));
end);

# the following doesn't apply to non-simple digraphs, and so we use
# IsDigraph and HasOutNeighbours

InstallMethod(DigraphReverse, "for a digraph by adjacency",
[IsDigraph and HasOutNeighbours],
function(graph)
  local old, new, i, j;

  old := OutNeighbours(graph);
  new := List(DigraphVertices(graph), x -> []);

  for i in DigraphVertices(graph) do 
    for j in old[i] do 
      Add(new[j], i);
    od;
  od;

  return DigraphNC(new);
end);

InstallMethod(DigraphRemoveLoops, "for a digraph with source",
[IsDigraph and HasDigraphSource],
function(graph)
  local source, range, newsource, newrange, nr, i;

  source := DigraphSource(graph);
  range := DigraphRange(graph);

  newsource := [];
  newrange := [];
  nr := 0;

  for i in [ 1 .. Length(source) ] do
    if range[i] <> source[i] then
      nr := nr + 1;
      newrange[nr] := range[i];
      newsource[nr] := source[i];
    fi;
  od;

  return DigraphNC(rec( source := newsource, range := newrange,
                              nrvertices := DigraphNrVertices(graph) ) );
end);

InstallMethod(DigraphRemoveLoops, "for a digraph by adjacency",
[IsDigraph and HasOutNeighbours],
function(graph)
  local old, new, nr, i, j;
  
  old := OutNeighbours(graph);
  new := [];

  for i in DigraphVertices(graph) do 
    new[i] := []; 
    nr := 0;
    for j in old[i] do 
      if i <> j then 
        nr := nr + 1;
        new[i][nr] := j;
      fi;
    od;
  od;

  return DigraphNC(new);
end);

InstallMethod(DigraphRemoveEdges, "for a digraph and a list",
[IsDigraph, IsList],
function(graph, edges)
  local range, nrvertices, source, newsource, newrange, pos, i;

  if Length(edges) > 0 and IsPosInt(edges[1]) then # remove edges by index
    edges := Difference( [ 1 .. Length(DigraphSource(graph)) ], edges );

    return DigraphNC(rec(
      source     := DigraphSource(graph){edges},
      range      := DigraphRange(graph){edges},
      nrvertices := DigraphNrVertices(graph)));
  else
    source := DigraphSource(graph);;
    range := DigraphRange(graph);;
    newsource := [ ];
    newrange := [ ];

    for i in [ 1 .. Length(source) ] do
      pos := Position(edges, [ source[i], range[i] ]); 
      if pos = fail then
        Add(newrange, range[i]);
        Add(newsource, source[i]);
      else 
        Remove(edges, pos);
      fi;
    od;

    return DigraphNC(rec( source := newsource, range := newrange,
                          nrvertices := DigraphNrVertices(graph) ) );
  fi;
end);

InstallMethod(DigraphRelabel, "for a digraph by adjacency and perm",
[IsDigraph and HasOutNeighbours, IsPerm],
function(graph, perm)
  local adj;

  if ForAny(DigraphVertices(graph), i-> i^perm > DigraphNrVertices(graph)) then
    Error("Digraphs: DigraphRelabel: usage,\n",
    "the 2nd argument <perm> must permute the vertices ",
    "of the 1st argument <graph>,\n");
    return;
  fi;
  
  adj := Permuted(OutNeighbours(graph), perm);
  Apply(adj, x-> OnTuples(x, perm));

  return DigraphNC(adj);
end);

InstallMethod(DigraphRelabel, "for a digraph and perm",
[IsDigraph and HasDigraphSource, IsPerm],
function(graph, perm)

  if ForAny(DigraphVertices(graph), i-> i^perm > DigraphNrVertices(graph)) then
    Error("Digraphs: DigraphRelabel: usage,\n",
    "the 2nd argument <perm> must permute the vertices ",
    "of the 1st argument <graph>,\n");
    return;
  fi;
  return DigraphNC(rec(
    source := ShallowCopy(OnTuples(DigraphSource(graph), perm)),
    range:= ShallowCopy(OnTuples(DigraphRange(graph), perm)),
    nrvertices:=DigraphNrVertices(graph)));
end);

# returns the vertices (i.e. numbers) of <digraph> ordered so that there are no
# edges from <out[j]> to <out[i]> for all <i> greater than <j>.

#

InstallMethod(DigraphTransitiveClosure, "for a digraph",
[IsDigraph],
function(graph)
  
  if IsMultiDigraph(graph) then
    Error("Digraphs: DigraphTransitiveClosure: usage,\n",
    "the argument <graph> cannot have multiple edges,\n");
    return;
  fi;

  return DigraphTransitiveClosure(graph, false);
end);

#

InstallMethod(DigraphReflexiveTransitiveClosure, "for a digraph",
[IsDigraph],
function(graph)

  if IsMultiDigraph(graph) then
    Error("Digraphs: DigraphReflexiveTransitiveClosure: usage,\n",
    "the argument <graph> cannot have multiple edges,\n");
    return;
  fi;

  return DigraphTransitiveClosure(graph, true); 
end);

#

InstallMethod(DigraphTransitiveClosure, "for a digraph and a record", 
[IsDigraph, IsBool],
function(graph, reflexive)
  local n, vertices, adj, sorted, out, trans, reflex, func, v, u;

  n := DigraphNrVertices(graph);
  vertices := DigraphVertices(graph);
  adj := OutNeighbours(graph);
  sorted := DigraphTopologicalSort(graph);

  if sorted <> fail then # Easier method for acyclic graphs (loops allowed)
    out := EmptyPlist(n);
    trans := EmptyPlist(n);

    for v in sorted do
      trans[v] := BlistList( vertices, [v]);
      reflex := false;
      for u in adj[v] do
        trans[v] := UnionBlist(trans[v], trans[u]);
        if u = v then
          reflex := true;
        fi;
      od;
      if (not reflexive) and (not reflex) then
        trans[v][v] := false;
      fi;
      out[v] := ListBlist(vertices, trans[v]);
      trans[v][v] := true;
    od;

    out := DigraphNC(out);
    SetIsMultiDigraph(out, false);
    return out;
  else # Non-acyclic method
 
    if reflexive then
      func := function(dist, i, j, k)
        if (i = j) or (dist[i][k] > 0 and dist[k][j] > 0) then 
          dist[i][j] := 1;
        fi;
      end;
    else
      func := function(dist, i, j, k)
        if dist[i][k] > 0 and dist[k][j] > 0 then 
          dist[i][j] := 1;
        fi;
      end;
    fi;

    out := DigraphByAdjacencyMatrix(DigraphFloydWarshall(graph, func, 0, 1));
    SetIsMultiDigraph(out, false);
    return out;
  fi;
end);

# This function will apply in the future to all "digraphs"
# A different method may be needed for multigraph

InstallMethod(InducedSubdigraph, "for a digraph and a list",
[IsDigraph, IsList],
function( digraph, subverts )
  local verts, nr, adj, lookup, new, i;

  verts := DigraphVertices(digraph);
  if not ForAll( subverts, x -> x in verts ) then
    Error("Digraphs: InducedSubdigraph: usage,\n",
    "the second argument <subvertices> such be a subset of the vertices of\n",
    "the first argument <digraph>,\n");
    return;
  fi;
  adj := OutNeighbours(digraph);
  nr := Length(subverts);
  lookup := EmptyPlist(nr);
  for i in [ 1 .. nr ] do
    lookup[ subverts[i] ] := i;
  od;
  new := List( [ 1 .. nr ], x -> [ ] );

  for i in [ 1 .. nr ] do
    new[i] := List( Filtered( adj[ subverts[i] ], x -> x in subverts), y -> lookup[y] );
  od;

  return DigraphNC(new);
end);


InstallMethod(InNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt],
function(graph, v)
  local vertices, inn, pos, out, i, j;

  vertices := DigraphVertices(graph);
  if not v in vertices then
    Error(v, " is not a vertex of the digraph");
    return;
  elif HasInNeighbours(graph) then
    return InNeighbours[v];
  else
    inn := [];
    pos := 1;
    out := OutNeighbours(graph);
    for i in [ 1 .. Length(out) ] do
      for j in [ 1 .. Length(out[i]) ] do
        if out[i][j] = v then
          inn[pos] := i;
          pos := pos + 1;
        fi;
      od;
    od;
    return inn;
  fi;
end);

InstallMethod(InNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph and HasDigraphSource, IsPosInt], 1,
function(graph, v)
  local vertices, inn, pos, source, range, i;

  vertices := DigraphVertices(graph);
  if not v in vertices then
    Error(v, " is not a vertex of the digraph");
    return;
  elif HasInNeighbours(graph) then
    return InNeighbours[v];
  else
    inn := [];
    pos := 1;
    source := DigraphSource(graph);
    range := DigraphRange(graph);
    for i in [ 1 .. Length(range) ] do
      if range[i] = v then
        inn[pos] := source[i];
        pos := pos + 1;
      fi;
    od;
    return inn;
  fi;
end);

InstallMethod(OutNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt], 1,
function(graph, v)

  if not v in DigraphVertices(graph) then
    Error(v, " is not a vertex of the digraph");
    return;
  else
    return OutNeighbours(graph)[v];
  fi;
end);

InstallMethod(OutNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph and HasDigraphSource, IsPosInt],
function(graph, v)
  local vertices, out, pos, source, range, i;

  vertices := DigraphVertices(graph);
  if not v in vertices then
    Error("Digraphs: OutNeighboursOfVertex: usage,\n",
          v, " is not a vertex of the digraph,\n");
    return;
  else
    out := [];
    pos := 1;
    source := DigraphSource(graph);
    range := DigraphRange(graph);
    for i in [ 1 .. Length(range) ] do
      if source[i] = v then
        out[pos] := range[i];
        pos := pos + 1;
      fi;
    od;
    return out;
  fi;
end);
