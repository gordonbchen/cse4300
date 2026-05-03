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


= 2. Processes and Threads
Context switch
- Interrupt
- Hardware pushes PC onto stack, loads interrupt service PC from interrupt vector table
- Interrupt service runs: saves registers, creates new stack for interrupt service
- Scheduler

$"CPU utilization" = 1 - ("IO wait")^n$

Threads vs Processes
- Threads are the unit of execution, each thread has its own stack
- Processes have their own virtual memory space

User-level thread: JVM
- Runtime system creating threads
- Problem: interrupt (blocking syscall / thread yield) will block entire runtime

Kernel-level thread: pthread
- Kernel has process and thread tables
- #todo[If a thread blocks and the process' CPU quantum is not up yet, does OS switch to thread in same process
        or a thread in any process?]

Race condition solutions
- Disable interrupts: bad idea to allow user to do, good idea in kernel
- Lock variables: bad, another source of race condition
- Strict alteration: blocking other process while in noncritical zone
- Peterson's solution: software solution, tracks which process is interrested
- TSL RX, LOCK: atomically (lock memory bus) read LOCK into RX and set LOCK = 1. if RX = 0, then have the lock.
  otherwise, call TSL lock again (busy waiting)

Priority inversion: high priority busy waits while low priority holds lock and never gets scheduled

Lost wakeup problem: wakeup signal is lost, need persistent bit (semaphore has up/down count)

#code[```
mutex_lock:
  TSL X0, LOCK
  CMP X0
  JEQ ok
  JNE thread_yield
  JMP mutex_lock
ok:
  RET

mutex_unlock:
  MOV LOCK, 0
  RET
```]

Monitors: provided by compiler, Java `synchronized`

Dining philosophers: livelock, everyone has left fork, tries to get right fork repeatedly

Reader writer
- first reader locks mutex, last reader unlocks
- writer must lock

== Scheduling
Batch
- First come first serve: bad when IO bound task must wait at the end
- Shortest first: optimal if everyone arrives at the same time
- Shortest remaining next: preemptive shortest first, if shorter job arrives do it

Interactive
- Round-robin
- Priority: decrease priority on every tick so low priority doesn't starve
  - IO: priority = 1 / cpu quantum used
- Priority classes: round-robin in classes
- Multiple queues: classes have 2x quantum as before, reduces swap cost
- Shortest process next: aging lerp
- Guarenteed scheduling: each user gets 1/n CPU time, track process CPU time
- Lottery scheduling: lottery tickets for CPU time

Real-time:
- schedulable if: $sum "cpu time" / "period" <= 1$


= 3. Memory Management
Relocation problem
- programs are compiled assuming that the base addr is 0, but can be put anywhere in RAM
- static relocation: when loading into RAM, add base addr
- addr += base register, check < limit register

Swapping
- bring whole process into RAM
- external fragmentation: needs compaction
- heap grows up and stack grows down so programs can grow

Memory allocation
- bitmaps / linked list tracks processes and hooles
- first fit: best
- next fit: start looking where you last found one
- best fit: smallest hole that can fit
- worst fit: largest hole
- quick fit: list of common hole sizes

Overlays: programmer defined way to split programs

Paging
- page is the unit of memory
- CPU asks MMU to fetch virtual addr
- virtual addr = virtual page (page table idx) + offset
- page table in RAM, TLB is page table cache
- multi-level page table: virtual addr = level 1 idx + level 2 idx + offset, create level 2 page tables on access
- inverted page table: hash virtual page for index, want num physical pages entries in hash table

Page replacement algorithms
- FIFO
- Second chance: FIFO queue, add to end of list if referenced  #todo[When a page is first loaded, is R=1?]
- Clock page replacement: circular clock hand, if referenced, clear bit and advance, else evict
- Not Recently Used: classes (R0, M0), (R0, M1), (R1, M0), (R1, M1)
- Least Recently Used: each page has counter for \# referecnes, pick lowest
- Not Frequently Used: add R-bit to all page coutners, shift counters right for aging
- Working set page replacement: remove page with referenced age > threshold
- WSClock
  - old page and M0: claim
  - old page and M1: schedule write
  - if no write scheduled: claim any page

Local vs global allocation: global is better if process size changes

Optimal page size = $sqrt(2 s e)$
- waste = $s/p e + p/2$

Shared pages: copy on write

Shared libraries: point to same place in RAM

Cleaning Daemon (clock)

Accessing a page
- VA = page table idx + offset
- check TLB for page table idx
- TLB miss, check RAM page table for page table idx
- page fault, not loaded in page table
- read page from HDD, evict a current page to make space

Pin pages for IO or use kernel buffers

Segmentation
- every varaible can have segment
- without paging: contiguous allocation, hole problem

MULTICS
- VA = segment idx + page idx + offset
- find segment in segment table, points to segment page table, then idx by page + offset
- TLBm must have segment idx and page idx

Pentium
- LDT per process, GDT for OS
- addr = selector + offset = (index + LDT / GDT) + offset
- selector to get segment descriptor (base addr) + offset = linear addr
- no paging: linear addr = physical addr

  paging: linear addr = page dir + page idx + offset


= 4. File Systems
- Boot: BIOS executes MBR program, finds active partition, active partition boot block runs, loads OS
- Contiguous allocation: bad if file sizes are dynamic
- Linked list allocation
- FAT (File Allocation Table): block has pointer to next

- disk latency = seek + half rotation + read
- data rate (read rate) increases with block size, don't need to fetch as many blocks
    - disk space util decreases with block size, more empty
- managing free blocks: linked list, bitmap
- physical dump: backup copy everything

  logical dump: copy only dirs to files chagnged

INodes
- File attr + address of disk blocks + addr to single indirect block
- single indirect block: addr of a block of addrs to blocks

Access /usr/asmt/mbox, root dir in memory
+ find usr inode
+ load usr dir block
+ find asmt inode
+ load asmt dir block
+ find mbox inode


= 5. IO
- os -> disk driver -> disk controller
- controllers assigned port numbers

  memory mapped: IN and MOV instead of special istruction IN and OUT
- must disable cachine for memory mapped

DMA controller
- without: disk controller reads block and interrupts CPU to copy into memory
- with: saves interrupts, dma controller oversees disk controller, handles copying into memory

cylinder skew: shift blocks against rotation so seek catches start of next ring block

disk arm scheduling
- shortest seek first: starve far blocks
- elecator: sweep in 1 direction

RAID
- level 0: strips in separate disks, read from all disks
- level 1: complete duplicate of level 0, faster read, same write
- level 2: word + ecc instead of strips
- level 3: parity drive
- level 4: partity strip in separate drive
- level 5: parity strips are distributed across drives

Timers
- simulating multiple timers: linked list of timers sorted, tracks time to next one
  - on periodic interrupt: traverse through timers
- soft timers: set timer for minimum frequency, but piggyback off of frequent syscalls, checking soft timer
  and handling task


= 9. Security
- Bell La padula: military reports, write up, read down
- Biba: corporate: write down, read up


= Distributed systems
- physical clocks are not synced, need logical clocks (sequence number), vector to tell if out of order
- impossibility of distributed consensus: cannot tell b/t slow and crashed process
- byzantine generals: 3m+1 generals to deal with m traitors, >2/3 loyal
- brewers conjecture: cannot have consistency (db same everywhere), availability (no disruption in access),
  and partition tolerance (works if some parts are unreachable)
  - must choose consistence and partition tolerance (don't serve new requests), or availability and partition tolerance
