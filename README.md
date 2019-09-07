# The OCaml Game: Duidoku

A game project from CS 3110 where we implemented an interesting game called
Duidoku in OCaml. Two players compete with each other to place numbers into
the grid, and like in sudoku, they need to make sure that no row, no column,
and no smaller grids should have duplicates. The last player to place the
number will win the game.

Here we not only built a Unix-style pretty print that displays the state of
the game, designed an algorithmic AI that could compete with real players, but
also utilized Unix socket programming to establish connections between players
using TCP/IP.
