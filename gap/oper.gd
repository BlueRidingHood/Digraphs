#############################################################################
##
#W  oper.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("DigraphRelabel", [IsDigraph, IsPerm]);
DeclareOperation("DigraphRemoveLoops", [IsDigraph]);
DeclareOperation("DigraphRemoveDigraphEdges", [IsDigraph, IsList]);
DeclareOperation("DigraphReflexiveTransitiveClosure", [IsDigraph]);
DeclareOperation("DigraphTransitiveClosure", [IsDigraph]);
DeclareOperation("DigraphReverse", [IsDigraph]);
DeclareOperation("QuotientDigraph", [IsDigraph, IsList]);
DeclareOperation("InducedSubdigraph", [IsDigraph, IsList]);
