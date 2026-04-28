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
  #text(22pt, weight: "bold")[OS Prog 5]
  #v(0.3em)
  #text(14pt)[Gordon Chen]
]
#v(1em)

#set enum(numbering: "a.")


= 1 Problem A: [50 points]
+ What function is called to create a new process when you run a test program? For instance,
  what function is executed first to create a new process (thread in case of OS161) to setup the new
  process when you run “p testbin/testA”?

  Feel free to list multiple functions in order they are called to explain the steps involved in the
  creation of a new process. You can draw a function call graph to illustrate the process. List the
  names of the files where each function is implemented. [10 points]

  #solution[
    #set enum(numbering: "1.")
    + menu, menu_execute, cmd_dispatch cmdtable (menu.c): parse command, find command name and function
      pointer in table, call command function
    + cmd_prog, common_prog, thread_fork cmd_progthread (menu.c): call thread_fork to create a new
      thread running the command
    + thread_fork (thread.c): thread_create to allocate a thread struct, allocate stack,
      allocate space for the thread in list of sleepers and zombies and scheduler, make runnable.
      puts cmd_progthread function into the switchframe return address (so next switch goes to that function)
    + cmd_progthread (main.c), runprogram (runprogram.c): read the executable program, set up the user
      level program's virtual address space (heap and stack), load the executable from the file,
      create a stack in the virtual address space, and run the user program
  ]

+ Please list all the relevant functions and explain the order of execution. You can draw a function
  call graph to illustrate the process. List the names of the files where each function is implemented.
  [20 points]

  - What function(s) are called to setup the memory for a new process?

    #solution[
      #set enum(numbering: "1.")
      + thread_fork (thread.c) allocates cmd_progthread's stack
      + runprogram (runprogram.c) creates the user level program's virtual address space using
        as_create (addrspace.c), and creates the user program's stack using as_define_stack (addrspace.c)
    ]

  - What function(s) are called to free the memory when a process is terminated?

    #solution[
      #set enum(numbering: "1.")
      + thread_exit (thread.c) checks that the stack wasn't overflowed, calls as_destroy (addrspace.c)
        which frees the thread's virtual address space
    ]


+ What is the size of a page in OS161? Where is this defined? [10+10 points]

  #solution[
    The page side is 4096 bytes. it is defined in vm.h.
  ]

= Problem B: [50 points]
Add a function so that OS161 prints out the available memory after running a test program. To
demonstrate this, run any of the test programs you wrote for prior Assignments and run that 3 times
in a row. For instance, you can run “p testbin/testA” 3 times in a row. After each execution of the
test program, it should output the remaining available memory. [50 points]

#solution[
  == ram.c
  ```C
  paddr_t ram_getavail() {
      return lastpaddr - firstpaddr;
  }
  ```

  == vm.h
  ```C
  paddr_t ram_getavail();
  ```

  == menu.c
  ```C
  #include <vm.h>
  ...
  void
  menu(char *args)
  {
      char buf[64];

      menu_execute(args, 1);

      while (1) {
          kprintf("OS/161 kernel [? for menu]: ");
          kgets(buf, sizeof(buf));
          menu_execute(buf, 0);

          // Print available memory after running program.
          kprintf("Mem avail: %u k\n", ram_getavail() / 1024);
      }
  }
  ```

  == Output
  ```
  OS/161 base system version 1.11
  Copyright (c) 2000, 2001, 2002, 2003
     President and Fellows of Harvard College.  All rights reserved.

  gordonbchen's system version 0 (ASST1 #23)

  Cpu is MIPS r2000/r3000
  328k physical memory available
  Device probe...
  lamebus0 (system main bus)
  emu0 at lamebus0
  ltrace0 at lamebus0
  ltimer0 at lamebus0
  hardclock on ltimer0 (100 hz)
  beep0 at ltimer0
  rtclock0 at ltimer0
  lrandom0 at lamebus0
  random0 at lrandom0
  lhd0 at lamebus0
  lhd1 at lamebus0
  lser0 at lamebus0
  con0 at lser0
  pseudorand0 (virtual)

  OS/161 kernel [? for menu]: p testbin/testA
  Warning: this probably won't work with a synchronization-problems kernel.
  5
  0
  6
  1
  olleh
  0
  lleh
  1
  _exit exitCode: 0
  thread_exit exitCode: 0
  Operation took 0.170855280 seconds
  Mem avail: 248 k
  OS/161 kernel [? for menu]: p testbin/testA
  Warning: this probably won't work with a synchronization-problems kernel.
  5
  0
  6
  1
  olleh
  0
  lleh
  1
  _exit exitCode: 0
  thread_exit exitCode: 0
  Operation took 0.621033040 seconds
  Mem avail: 188 k
  OS/161 kernel [? for menu]: p testbin/testA
  Warning: this probably won't work with a synchronization-problems kernel.
  5
  0
  6
  1
  olleh
  0
  lleh
  1
  _exit exitCode: 0
  thread_exit exitCode: 0
  Operation took 0.157492040 seconds
  Mem avail: 128 k
  ```
]
