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
  #text(22pt, weight: "bold")[OS HW 4]
  #v(0.3em)
  #text(14pt)[Gordon Chen]
]
#v(1em)


= Problem 1 (5+5 points)
Consider the following C program:

#code[
  ```C
  int X[N];
  int step = M; // M is some predefined constant
  for (int i=0; i<N; i=i+step)
      X[i]=X[i]+1;
  ```
]

Assume that an integer is 1 Byte in size.
#set enum(numbering: "a.")

+ If this program is run on a machine with a 4-KB page size and 64 entry TLB, what values of `M` and
  `N` will cause a TLB miss for every execution of the inner loop?

  #solution[
    We want `X[i]` to fetch a new page every iteration. Page size is 4 KB, so at 1 byte per int, it stores
    $4 times 1024 = 4096$ ints. So then we need `M = 4096` to get the first int in the next page every iteration.

    Since we aren't repeating the loop, `N` can be any multiple of `M`.
  ]

+ Would your answer in part (a) be different if the loop were repeated many times? Explain. 

  #solution[
    Yes, `M` will be the same, but now we need to make the array long enough (`N` large enough) so that
    the loop tries to access more pages than the number of entries in the TLB. This way, when the loop is
    run repeatedly, the TLB will not have the right entries for the next loop.

    The TLB has 64 entries, so we need $(64 + 1) times M = 65 times 4096 = 266240$ ints.
  ]


= Problem 2 (5 points)
Suppose that the virtual page reference sequence contains repetitions of long sequences of
page references. For example, the sequence: 0,1,2,...,511,431,0,1,...,511,431,0,1,...consists of
repetition of the sequence 0,1,...,511,431.

If this sequence repeats 5 times (a total of 2565 page reference), how many page fault will you have if you
use LRU, FIFO, and clock algorithm? Assume that you have 500 page frames allocated for this proces

#solution[
  === FIFO

  The very first time the sequence starts, you get 512 page faults for accessing 0...511. Then your page table
  has [12...511], so you don't miss on 431.

  The next time the sequence starts, you again have 512 page faults since 0..11 aren't in the page table,
  so [12...] get replaced and aren't in the page table when you need them right after.

  So every sequence gives 512 page faults. Total page faults = $5 times 512 = 2560$.


  === Clock
  #set enum(numbering: "1.")
  + 512 page faults for 0...511. Then 431 is a hit, so the R-bit is set to 1.
  + everything but 431 misses for 0...511, so 511 misses. 431 is a hit again, R-bit set to 1...

  Total page faults = $512 + 4 times 511 = 2556$.

  === LRU
  This will be similar to clock.
  + 512 page faults for 0...511. Then 431 is a hit, so counter incremented.
  + everything but 431 misses for 0...511 b/c 431 is kept (counter is higher), so 511 misses.

  Total page faults = $512 + 4 times 511 = 2556 = 2556$
]


= Problem 3 (5+5 points)
Assume that disk requests come in to the disk controller for cylinders 5, 10, 15, 55, 85, and 33, in that order.
A seek takes 5 msec per cylinder move. In all cases, the arm is initially at cylinder 20.
Show all the calculations. How much seek time is needed to serve the requests if you use:
#set enum(numbering: "a.")

+ First-come, first-serve algorithm
  #solution[
    #table(
      columns: 8,
      [*position*], [20], [5], [10], [15], [55], [85], [33],
      [*dist*], [], [15], [5], [5], [40], [30], [52]
    )

    Total dist = $15 + 5 + 5 + 40 + 30 + 52 = 147$.

    Seek time = $147 times 5 "ms" = 735 "ms"$.
  ]


+ Closest cylinder next algorithm
  #solution[
    #table(
      columns: 8,
      [*position*], [20], [15], [10], [5], [33], [55], [85],
      [*dist*], [], [5], [5], [5], [28], [22], [30]
    )

    Total dist = $5 + 5 + 5 + 28 + 22 + 30 = 95$.

    Seek time = $95 times 5 "ms" = 475 "ms"$.
  ]


= Problem 4 (5 points)
What is cylinder skew? Why is it useful?

#solution[
  Cylinder skew offsets the sector numbers between tracks.

  It is useful when you need to read contiguous chunks
  across tracks. Say that you need to read a file that is stored contiguously starting from half of one track
  and spilling over onto the next outer track. Without cylinder skew, when you finish reading the inner track,
  the next part of the file is the next sector on the outer track, but you will miss it and have to wait an
  entire rotation because you have to move to the outer track.

  With a cylinder skew, the sector numbers are shifted against the direction of the track rotation so that
  after you finish reading the inner track, you have enough time to move the arm to the outer track
  while sector 0 of the next track is rotating towards the arm. That way you don't miss the start of the
  next track and don't have to wait another full rotation.
]


= Problem 5 (5+5 points)
Recall that both RAID level 0 and RAID level 1 use block-striping. The only difference
is that RAID level 0 has no redundancy and RAID level 1 uses mirroring for redundancy.

Assume that RAID 1 uses double the number of disks as RAID 0 (i.e., the number of primary disks is same
in both cases).

+ Could a RAID Level 1 organization achieve better performance for read requests (e.g., complete a
  read request faster) than a RAID Level 0 organization? If so, how?

  #solution[
    Yes, RAID level 1 can read up to 2x faster than RAID level 0. Since RAID level 1 has a full duplicate
    of the drives for backup (essentially 2 RAID level 0s), you can read half of the data from each and
    get a 2x speedup at best.
  ]

+ Could a RAID Level 1 organization achieve better performance for write requests (e.g., complete
  a write request faster) than a RAID Level 0 organization? If so, how?

  #solution[
    No RAID level 1 write performance will be the same. You will write to the drives and the backups
    in parallel, but you still need to write all changes to each, so it still takes the same amount of time.
  ]


= Problem 6 (5 points)
Let’s assume that a RAID can fail if two or more drive crashes within a short time interval.
Suppose that the probability of one drive failing in a given hour is 0.05. What is the probability of a 10
drive RAID failing in a given hour?

#solution[
  $PP("RAID no fail") = PP(0 "crash") + PP(1 "crash") = (0.95)^10 + binom(10, 1) (0.95)^9 (0.05)$

  $PP("RAID fail") = 1 - PP("RAID no fail") = 1 - (0.95)^10 - 10 (0.95)^9 (0.05) approx 0.086$
]


= Problem 7 (5 points)
Explain the Biba model for access control. 

#solution[
  The Biba model is the opposite of the Bell-LaPadula model.

  In the Bell-LaPadula model, processes can read objects at lower or equal levels and write objects
  at higher or equal levels.

  In the Biba model, processes can write objects at lower or equal levels and read objects
  at higher or equal levels.

  Biba is like a manager being able to read the CEO's instructions and then telling
  workers what to do.

  Biba ensures integrity, that no lower level process can write to an upper level process.
]
