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

logical clock (sequence numbering): leslie lamport b/c local clock will not work b/c of delays
- p1: send request + sequence number to everyone, wait for ack
- p2: put request in queue, break ties w/ process id, send ack
- p1: recv ack from everyone, use printer, send release
- p2: see release, remove from queue
- PROBLEM: failed process doesn't ack p1, p1 waits forever

vector clock:
- logical clock counter for every process
- concurrent if not all sequence ids are <

= Classic Papers
== impossibility of distributed consensus with one faulty process
- how to detect if a server is down?
- impossibility to know w/ 100% prob, packet could have gotten lost
- leader election: who is new primary server and who is duplicate

== byzantine generals
- all loyal generals do correct plan
- few traitors cannot make generals do bad plan
- all loyal lieutenants obey the same order
- if loyal commanding general, then every loyal lietenant obeys order
- 3 generals, 1 traitor, is there a solution? no solution
  - always listen to general: then could be traitor
  - to cope with n traitors, need 3n + 1 generals

== brewer's conjecture and the feasibility of consistent, available, partition-tolerant web services
- impossible to have all 3: consistency, availability, tolerate server disconnect
- if server partitioned, no consistency
- eventual consistency model: replica management service to broadcast changes (for when partiitoned server
  comes back online)
