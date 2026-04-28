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
  #text(22pt, weight: "bold")[OS Final Review]
  #v(0.3em)
  #text(14pt)[Gordon Chen]
]
#v(1em)


= Overview
- 2 CPU: processes and threads, scheduling, locks w/ TSL
- 3 RAM: memory management, virtual addr space, paging, TLB, segmentation
- 4 Disk: filesystem, FAT vs INodes, logical backup, file consistency issues
- 5 IO: interrupts, DMA controller to reduce interrupts
- 6 Deadlocks: detection and recovery, prevention, ordered resources
- 9 Security: access control
- Distributed: impossibility of consensus, logical timestamps

= Processes and Threads
== Processes
- process table: registers, PC, pointers to segments (text, data, stack)
- interrupt, hardware dumps PC, loads new PC from interrupt vector table (idx from interrupt
  controller line), asm dumps registers + sets up stack, interrupt runs, scheduler runs
- CPU usage = 1 - p^n

== Threads
- share global variables
- user (JVM) vs kernel (pthread) level

== Race conditions
- disabiling interrupt: disable on all cores? impractical
- lock variable: source of race condition
- strict alternation: busy waiting
- peterson's solution: niceness (if another process wants it, then let them), busy waiting
  - priority inversion problem: high priority job busy waiting for lock, low priority with lock never schedules. no priority inversion with round-robin scheduling b/c low will eventually get scheduled.
- TSL register, lock: lock the bus (atomic), read the value, overwrite as 1. 1 = locked.
- producer-consumer
- semaphore
- mutex lock: TSL w/ thread_yield
- monitor: provided by compiler, Java's synchronize
- dining philosopher: livelock
- reader / writer
- barriers

== Scheduling
- batch
  - first come first serve
  - shortest job first (optimal if everyone arrives at same time)
  - shortest remaining time next (preemptive shortest jobo first)
- interactive
  - round-robin
  - priority scheduling: low priority starvation, reducd priority at every clock interrup
    - priority = 1/ time of CPU quantum used, higher for IO-bound so don't wait
  - priority classes: priority levels w/ round-robin in classes
  - multiple queues: expensive swapping, 2x quantum if not finished
  - shortest process next, estimate w/ aging
  - guarenteed scheduling: each user gets 1/n CPU time
  - lottery scheduling: probabilistic based on paying
- real-time: sum(cpu time / period time) <= 1
  - 2 voice calls, 1 ms call every 6 ms + 25 frames / sec where each frame takes 20ms
  - $2*(1/6) + 25 * 2/100 = 1/3 + 1/2 = 5/6 < 1$


= Memory Management

= Deadlocks

= File Systems

= IO

= Distributed Systems
== Logical clocks
- can't rely on local time for ordering b/c no perfect time sync
- need logical clock (sequence numbers)
- vector clock: event number for every process, happened after if all sequence numbers are greater
