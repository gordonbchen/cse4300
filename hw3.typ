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

#let todo(body) = box(
  fill: rgb("#ff6666"),
  stroke: rgb("#cc4444"),
  inset: (x: 6pt, y: 4pt),
  [*TODO:* #body],
)


#align(center)[
  #text(22pt, weight: "bold")[OS HW 3]
  #v(0.3em)
  #text(14pt)[Gordon Chen]
]
#v(1em)


= Problem 1 (5 points)
How is a virtual address in MULTICS converted to physical address?

#solution[
  + MULTICS virtual addr = segment number | page number | offset
  + descriptor_segment[segment number] = segment page table addr
  + segment_page_table[page number] = page physical addr
  + final physical addr = page physical addr + offset
]


= Problem 2 (5 points)
Assume that there are 2048 entries in the segment table, and there can be at most 128
pages in a segment. If the virtual address is 32 bits, what is the maximum size of a
page you can have?

#solution[
  $2048 = 2^11$ entries in segment table, so 11-bit segment number.

  $128 = 2^7$ pages in a segment, so 7-bit page idx.

  virtual addr = segment number | page idx | offset, so offset must be $32-11-7=14$ bits.

  So then a page has $2^14$ bytes.
]


= Problem 3 (5 points)
A system has four processes and five allocable resources.
The current allocation and request matrix are as follows:

== Current Allocation Matrix
#table(
  columns: 6,
  [*Process*], [*R1*], [*R2*], [*R3*], [*R4*], [*R5*],
  [A], [1], [0], [2], [0], [1],
  [B], [2], [0], [0], [1], [0],
  [C], [1], [0], [0], [1], [1],
  [D], [1], [1], [1], [0], [1],
)

== Request Matrix
#table(
  columns: 6,
  [*Process*], [*R1*], [*R2*], [*R3*], [*R4*], [*R5*],
  [A], [2], [0], [2], [0], [0],
  [B], [2], [0], [0], [3], [0],
  [C], [1], [1], [0], [0], [0],
  [D], [0], [0], [0], [0], [1],
)

== Available Resources
#table(
  columns: 5,
  [*R1*], [*R2*], [*R3*], [*R4*], [*R5*],
  [1], [1], [0], [0], [1],
)

Is this a safe state? Show a sequence of scheduling, if one exists,
that will lead to successful completion of the tasks.
The request matrix specifies how many of each type of resource are still needed by each process,
in addition to what it currently has.

#solution[
  No, this is not a safe state. Process B wants 3 R4, but only 2 R4 exist (0 are available, and
  Process B and C each have 1). Since there do not exist enough R4 anywhere to satisfy Process B,
  Process B cannot complete and this is not a safe state.
]


= Problem 4 (5 points)
A system has two processes and three identical resources. Each process needs a maximum
of two resources. Is deadlock possible? Explain your answer. 

#solution[
  No, deadlock is not possible. If Process 1 only gets 1 resource and cannot execute, then Process 2
  can get 2 resources, terminates, and then Process 1 will be able to get 2 resources. Similarly,
  if Process 2 can only get 1 resource and cannot execute, then Process 1 gets 2 resources, terminates,
  and then Process 2 can run.
]


= Problem 5 (2+3 points)
Bitmap and free list are two ways to keep track of the free space on the disk. Consider a
disk of 2 Gigabytes with 2^20 (i.e., 2 to the power of 20) blocks.
 
#set enum(numbering: "a)")
+ What will be size of each block?

  #solution[
    2 GB $= 2 * 2^30 = 2^31$ bytes.

    $2^20$ blocks, so each block is $2^31 / 2^20 = 2^11$ bytes, so 2 KB.
  ]

+ If you use bitmap, how much space (in bytes or blocks) will be needed
  to represent the free space in the disk?

  #solution[
    Bitmap uses 1 bit per block as a flag for free or not.

    1 bit per block $* 2^20$ blocks = $2^20$ bits = $2^17$ bytes.
  ]


= Problem 6 (5 points)
Suppose each disk block can hold 256 bytes of data. Assume that it takes 8 bytes to record
the address of a disk block.

Calculate the maximum file size that can be allowed in a file system assuming the following i-node
structure:
- File attributes
- Address to disk block 0
- Address to disk block 1
- Address to disk block 2
- Address to disk block 3
- Address to disk block with single Indirect block

#solution[
  File attributes do not count towards file contents size.

  4 direct disk blocks, so $4 * 256$ bytes = $1024$ bytes = 1 KB.

  Indirect block will have $256 / 8 = 32$ pointers to disk blocks.
  Each disk block can have $256$ bytes, so in total, the single indirect block allows for
  $256 * 32 = 2^13$ = 8 KB.

  Total: 1 KB + 8 KB = 9 KB.
]


= Problem 7 (3+2 points)
Let us assume that a file system uses 4-KB disk block size.
+ In your system, if all files were exactly 3 KB, what fraction of the disk space would be wasted?

  #solution[
    $1/4$ of the disk space is wasted since each 3 KB file is stored in a 4 KB disk block.
  ]


+ In your system, assume that the median file size is 12 KB. Will the wastage for this file system will
  be higher or lower compared to scenario (a)? Explain.

  #solution[
    It is not clear. Knowing the median file size does not tell us about how much of the file system is wasted.
    Consider the following 2 cases as an illustration:
    #set enum(numbering: "1.")
    + Every file is exactly 12 KB. Then waste of this file system is lower than scenario (a) since
      12 is a clean multiple of 4, so each file uses up 4 blocks exactly, and no block space is wasted.

    + Half of the files are 1 KB, the other half are 13 KB, and a single file is 12 KB.
      Then the median file size is still 12 KB, but this file system wastes 3 KB for every file.
      For every 20 KB of disk space, 6 KB are wasted, giving a waste of $6/20 > 5/20 = 1/4$.

    So we do not have enough information to tell.

    However, for non-pathological cases with a median file size of 12 KB, in general, the file system waste
    will be lower than scenario (a) because most files will fill up 3 blocks, with files
    potentially a underfilling the last block or some bytes spilling into the 4th block. Since files mostly
    span multiple blocks, many blocks will be completely full and only some will be underfull,
    which causes better block utilization and less waste than one where $1/4$ of every block is wasted.
  ]


= Problem 8 (5 points)
How many disk operations are needed to fetch the i-node for the file /usr/ast/courses/os/a.txt?
Explain. Assume that the i-node for the root directory is in the memory, but nothing else along the path is
in memory. Also assume that all directories for a given i-node fit in one disk block. 

#solution[
  To go to the next subdirectory, you need to fetch the current directory block to find the subdirectory
  inode, and then fetch the subdirectory inode.

  #set enum(numbering: "1.")
  + fetch root dir block.
  + fetch usr inode.
  + fetch usr inode block.
  + fetch ast inode.
  + fetch ast block.
  + fetch courses inode.
  + fetch courses block.
  + fetch os inode.
  + fetch os block.
  + fetch a.txt inode.

  10 disk ops.
]
