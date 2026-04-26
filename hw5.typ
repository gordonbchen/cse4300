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
  #text(22pt, weight: "bold")[OS HW 5]
  #v(0.3em)
  #text(14pt)[Gordon Chen]
]
#v(1em)

#set enum(numbering: "a.")


= Q1. (5 points)
Suppose that a process is allocated 2 frames in the memory. The page reference sequence of this
process is

A B A C A D A B

Assume that OS approximates LRU using a single reference bit and resets the reference bits
periodically after every 3 page references (i.e., by setting them to 0). If both entries have R=1,
the algorithm replaces the one that was loaded the earliest.

For the given sequence, determine which of the reference will cause a page fault.

#solution[
  #table(
    columns:4,
    [*idx*], [*page*], [*page fault*], [*page table after*],
    [0], [A], [1], [(A, R=1)],
    [1], [B], [1], [(A, R=1), (B, R=1)],
    [2], [A], [0], [(A, R=1), (B, R=1) -clear-> (A, R=0), (B, R=0)],
    [3], [C], [1], [(B, R=0), (C, R=1)],
    [4], [A], [1], [(C, R=1), (A, R=1)],
    [5], [D], [1], [(A, R=1), (D, R=1) -clear-> (A, R=0), (D, R=0)],
    [6], [A], [0], [(A, R=1), (D, R=0)],
    [7], [B], [1], [(A, R=1), (B, R=1)],
  )
]


= Q2. (2+2 points)
+ What is thrashing?

  #solution[
    Thrashing is when you have a memory access pattern that causes page faults to happen very frequently.
  ]

+ How will increasing disk speed affect the thrashing? Please briefly justify your answer.

  #solution[
    Increasing disk speed will not prevent thrashing because thrashing is about the memory access pattern
    causing page faults, not about how quickly after a page fault the page can be loaded from the disk.

    However, increasing disk speed will reduce the effects of thrashing because faster disk speeds
    allow you to load the pages that are causing the page faults faster, thereby slowing down your program less.
  ]



= Q3. (2+2 points)
Let us assume that you have page requests in the following order:

Page requests: 3, 2, 1, 0, 3, 2, 4, 3, 2, 1, 0, 4

For (a) and (b), you must list the page requests that will cause a page fault.

+ How many page faults will you have if you have 3 page frames and use FIFO algorithm?

  #solution[
    #table(
      columns:3,
      [*page*], [*page fault*], [*page table after*],
      [3], [1], [3],
      [2], [1], [3, 2],
      [1], [1], [3, 2, 1],
      [0], [1], [2, 1, 0],
      [3], [1], [1, 0, 3],
      [2], [1], [0, 3, 2],
      [4], [1], [3, 2, 4],
      [3], [0], [3, 2, 4],
      [2], [0], [3, 2, 4],
      [1], [1], [2, 4, 1],
      [0], [1], [4, 1, 0],
      [4], [0], [4, 1, 0]
    )

    9 page faults.
  ]

+ How many page faults will you have if you have 4 page frames and use FIFO algorithm?

  #solution[
    #table(
      columns:3,
      [*page*], [*page fault*], [*page table after*],
      [3], [1], [3],
      [2], [1], [3, 2],
      [1], [1], [3, 2, 1],
      [0], [1], [3, 2, 1, 0],
      [3], [0], [3, 2, 1, 0],
      [2], [0], [3, 2, 1, 0],
      [4], [1], [2, 1, 0, 4],
      [3], [1], [1, 0, 4, 3],
      [2], [1], [0, 4, 3, 2],
      [1], [1], [4, 3, 2, 1],
      [0], [1], [3, 2, 1, 0],
      [4], [1], [2, 1, 0, 4]
    )

    10 page faults.
  ]


= Q4. (2+2 points)
In the context of memory utilization, there are two types of fragmentation: external and internal
fragmentation.
+ Which type of fragmentation does the contiguous-memory-allocation scheme suffer from?

  #solution[
    Contiguous memory allocation suffers from external fragmentation, checkerboarding caused by holes between
    contiguous memory chunks.
  ]

+ Which type of fragmentation does paging suffer from?

  #solution[
    Paging suffers from internal fragmentation, which is when a fraction of the last page is wasted because
    the data doesn't exactly fill an integral number of pages.
  ]


= Q5. (5+5 points)
- A barber shop consists of a waiting room with N waiting chairs and a barber room with
  one barber chair.
- If a customer enters the barbershop and all waiting chairs are occupied, then the customer
  leaves the shop. If the barber is busy but there are waiting chairs available, the customer
  sits in one of the free chairs.
- The barber goes to sleep if there are no customers to be served.
- When a customer comes in and finds the barber asleep, the customer wakes up the barber.

Write a program (pseudo code) to coordinate the barber and the customers.
More specifically:
- Write a function to represent the barber.
- Write a function to represent a customer.

Waiting for the customer and waking up the barber needs to be achieved through
synchronization primitives. (Hint: You need to keep track of the current number of
customers. You also need to keep track of the status of the barber.)
You need to provide the logic for the barber and the customer below.



#solution[

```C
int waiting_customers = 0;
int barber_sleeping = 0;

int customers[N];
int head_idx = 0;
int tail_idx = 0;

mutex customer_lock;
cond customer_exists;

void barber() {
  while (1) {
    lock(customer_lock);

    // sleep until a customer comes.
    while (waiting_customers == 0) {
      barber_sleeping = 1;
      cond_wait(customer_exists, customer_lock);
      barber_sleeping = 0;
    }

    // get the first customer.
    int customer = customers[head_idx];
    head_idx = (head_idx + 1) % N;
    --waiting_customers;

    unlock(customer_lock);

    // service the customer in the chair.
    service(customer);
  }
}

void customer(int id) {
  lock(customer_lock);

  // If waiting room is full, leave.
  if (waiting_customers == N) {
    unlock(customer_lock);
    return;
  }

  // There is space in the waiting room, wait.
  customers[tail_idx] = id;
  tail_idx = (tail_idx + 1) % N;
  ++waiting_customers;

  // Wake up the barber if sleeping.
  if (barber_sleeping == 1) {
    cond_signal(customer_exists);
  }

  unlock(customer_lock);
}

```
]
