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
- problem loading programs directly into RAM: program assumes starts at 0 mem
  - static relocation: recalculate all addrs
  - base and limit registers: all addrs + base, must be < limit
- fitting processes in memory

== Swapping
- bring whole process into memory
- external fragmentation, need memory compaction
- need room for growth
- memory management with bitmap and linked list
- first fit is best, next fit: start again from last hole used
- example: holes 10, 4, 20, 18, 7, 9, 12, 15. process is 12, 10, 9.

  first fit: 20, 10, 18, next fit: 20, 18, 9

== Virtual Memory
- split into pages, pages get loaded into memory
- overlays: programmer defined wher to split programs
- paging: TLB is cache for page table, page table in memory, tells you if page is loaded in RAM or page fault
  to HDD
- VA = page table idx + offset, page table converts idx -> physical page addr
- page table
  - caching disabled: for IO
  - referenced + modified: for page replacement
  - present/absent + physical page frame idx
- TLB: cache for page table
- Multilevel page table: page table idx 1 + page table idx 2 + offset
  - only create level 2 page tables if used
- inverted page table: hash(virtual page number) -> page table idx ->
  linked list of (virtual page, page frame addr)
  - ex: 8kb page, 256mb ram, 64gb virtual addr: how big hash table for expected chain length < 1
    - 256mb / 8kb = 32K physical pages so any > 32K
  - ex: 64kb program, 4k pages, p1 has 32kb text, 16,386 bytes data, 16kb stack
    - program has 16 pages, text is 8 pages, data is 5 (round up) pages, stack is 4 pages
    - page size is 512 bytes: works fine b/c round up doesn't hurt as bad

== TODO: page replacment algorithms

== Global vs local allocation policies
- separate I and D mem
- copy on write
- shared libraries
- cleaning policy
- allocation implementation
- backing store

== Segmentation
- multics: allows with and without paging
- segmentation with paging
- pentium: segmentation with or without paging

= Deadlocks

= File Systems

= IO
- memory mapped IO: part of memory reserved for IO
- DMA controller: reduce interrupts
  - P1 wants to read IO, OS tells DMA controller to copy to RAM (or else raise an interrupt for every
    block to copy to RAM). DMA tells disk controller to load HDD block to buffer, DMA controller handles
    disk controller mamagement
- interrupts handling
- soft timers: clear timer and check interrupt when you go to kernel mode (piggy back)
  - avoid extra interrupt overhead

= Distributed Systems
== Logical clocks
- can't rely on local time for ordering b/c no perfect time sync
- need logical clock (sequence numbers)
- vector clock: event number for every process, happened after if all sequence numbers are greater
