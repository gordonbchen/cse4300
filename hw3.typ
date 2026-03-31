#align(center)[
  #text(22pt, weight: "bold")[OS HW 3]
  #v(0.3em)
  #text(14pt)[Gordon Chen]
]
#v(1em)

= Problem 1 (5 points)
How is a virtual address in MULTICS converted to physical address?


= Problem 2 (5 points)
Assume that there are 2048 entries in the segment table, and there can be at most 128
pages in a segment. If the virtual address is 32 bits, what is the maximum size of a
page you can have?


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

Available Resources: $(1, 1, 0, 0, 1)$

Is this a safe state? Show a sequence of scheduling, if one exists,
that will lead to successful completion of the tasks.
The request matrix specifies how many of each type of resource are still needed by each process,
in addition to what it currently has.


= Problem 4 (5 points)
A system has two processes and three identical resources. Each process needs a maximum
of two resources. Is deadlock possible? Explain your answer. 


= Problem 5 (2+3 points)
Bitmap and free list are two ways to keep track of the free space on the disk. Consider a
disk of 2 Gigabytes with 2^20 (i.e., 2 to the power of 20) blocks.
 
#set enum(numbering: "a)")
+ What will be size of each block?

+ If you use bitmap, how much space (in bytes or blocks) will be needed
  to represent the free space in the disk?


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


= Problem 7 (3+2 points)
Let us assume that a file system uses 4-KB disk block size.
+ In your system, if all files were exactly 3 KB, what fraction of the disk space would be wasted?

+ In your system, assume that the median file size is 12 KB Will the wastage for this file system will
  be higher or lower compared to scenario (a)? Explain.


= Problem 8 (5 points)
How many disk operations are needed to fetch the i-node for the file /usr/ast/courses/os/a.txt?
Explain. Assume that the i-node for the root directory is in the memory, but nothing else along the path is
in memory. Also assume that all directories for a given i-node fit in one disk block. 


