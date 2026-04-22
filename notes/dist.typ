#let solution(body) = block(
  width: 100%,
  fill: rgb("#f4f8ff"),
  stroke: rgb("#c7d7f2"),
  inset: 12pt,
  above: 10pt,
  below: 10pt,
  [
    #strong[Solution]

    #body
  ],
)

#let code(body) = block(
  width: 100%,
  fill: rgb("#f4f4f4"),
  stroke: rgb("#c7c7c7"),
  inset: 12pt,
  above: 10pt,
  below: 10pt,
  [#body],
)

#let todo(body) = box(
  fill: rgb("#ff6666"),
  stroke: rgb("#cc4444"),
  inset: (x: 6pt, y: 4pt),
  [*TODO:* #body],
)


#align(center)[
  #text(22pt, weight: "bold")[Distributed Systems]
  #v(0.3em)
  #text(14pt)[Gordon Chen]
]
#v(1em)

= Distributed systems
- different computers, how to guarentee that $|x_i - x_j| <= delta$
- communication delay
- create history (sequence of events), then sort messages by timestamp
  - problem: times are not perfectly synced
  - don't know how long message spent in transit
  - https://groups.csail.mit.edu/tds/papers/Lynch/ic84-scanned.pdf

Berkely algorithm: master tells slave times

internet: NTP, heirarchical, lower leaves = higher innaccuracy

logical clock (sequence numbering): leslie lamport
- local clock will not work b/c of delays
- happened-before relation: a and b in same proc and a before b, then aRb
- concurrent events: can't tell
- send sequence number to everyone, wait for ack
