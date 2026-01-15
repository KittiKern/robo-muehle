#import "@preview/charged-ieee:0.1.4": ieee

#show: ieee.with(
  title: [Robo Arm],
  paper-size: "a4",
  abstract: [Ein Robo Arm der Mühle spielt],
  authors: (
    (
      name: "Frederik Schwarz",
      department: [Informatik],
      organization: [Hof-University],
    ),
  ),
  bibliography: bibliography("refs.bib"),
)
#pagebreak()
#include "ai.typ"
