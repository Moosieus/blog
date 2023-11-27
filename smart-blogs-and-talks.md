# Things Worth Reading

<!-- Low Level -->

### [Fibers, Oh My!](https://graphitemaster.github.io/fibers/) by [graphitemaster](https://github.com/graphitemaster)
Explores the difference between cooperative and preemptive scheduling, N:1 and N:M threading, and the challenges involved in implementing scheduling in general (read: Why Elixir and Go are awesome).

### [Memory Allocation Strategies](https://www.gingerbill.org/series/memory-allocation-strategies/) by [Ginger Bill](https://github.com/gingerBill)
Outlines how memory works on modern (post 1990's) operating systems, in addition to exploring different memory management strategies, allocators, and their tradeoffs.

<!-- Concurrency -->

### [The big idea is messaging](http://lists.squeakfoundation.org/pipermail/squeak-dev/1998-October/017019.html) from [Alan Kay](https://en.wikipedia.org/wiki/Alan_Kay)
Or how the original pervasive OOP langs (Objective-C, C++, Python, and Java) missed the point of Smalltalk-80.

### [Why concurrency isn't understood](https://elixirforum.com/t/learning-elixir-frst-impressions-plz-dont-kill-me/16424/52) from [Joe Armstrong](https://en.wikipedia.org/wiki/Joe_Armstrong_(programmer))
> I think a big problem in evangelising Erlang/Elixir is that you have to explain how having large numbers of parallel processes solving you problem helps. Since no other common languages support concurrency in any meaningful way the need for it is not understood.

### [Erlang's not about lightweight processes and message passing...](https://github.com/stevana/armstrong-distributed-systems/blob/main/docs/erlang-is-not-about.md)
A significant value of Elixir and Erlang's process model are the emergent patterns and architectures that arise from it. This article covers them well.

### [CALL-RETURN-Spaghetti](https://guitarvydas.github.io/2020/12/09/CALL-RETURN-Spaghetti.html) by [Paul Tarvydas](https://github.com/guitarvydas)
Makes a case for concurrent systems being inherently simpler than systems based on sequential Call/Return.

### [I ❤️ Logs](https://www.confluent.io/ebook/i-heart-logs-event-data-stream-processing-and-data-integration/) by [Jay Kreps](https://www.linkedin.com/in/jaykreps/)
A concise and wonderful book about logs, and how they lend themselves to solving problems in distributed systems and stream processing. 

<!-- Programming Philosophy -->

### [Less is exponentially more](https://commandcenter.blogspot.com/2012/06/less-is-exponentially-more.html) by [Rob Pyke](https://en.wikipedia.org/wiki/Rob_Pike)
Title is self explanatory. I particularly love this bit:
> But more important, what it says is that types are the way to lift that burden. Types. Not polymorphic functions or language primitives or helpers of other kinds, but types.

### [Forth: The programming language that writes itself](https://ratfactor.com/forth/the_programming_language_that_writes_itself.html) by [Dave Gauer](http://ratfactor.com/)
Stacks, Postfix Notation, Interpreters, oh my!

<!-- Education -->

### [How to get into software](https://github.com/npmaile/blog/blob/main/posts/2.%20How%20to%20get%20into%20software.md) by [Nate P. Maile](https://github.com/npmaile)
You can't learn to swim without getting wet.

# Things Worth Watching

<!-- Low Level -->

### [What's a Memory Allocator Anyway?](https://www.youtube.com/watch?v=vHWiDx_l4V0) by [Benjamin Feng](https://github.com/fengb)
A wonderful introduction to memory allocators, and thinking about memory beyond the hegemony of the heap and stack.

### [The Soul of Erlang and Elixir](https://www.youtube.com/watch?v=JvBT4XBdoUE) by [Sasa Juric](https://github.com/sasa1977)
Or how BEAM manages to keep rock-solid low latency, and keep long-running requests from hogging resources. Worth noting that Go's runtime is not dissimlar.

<!-- Concurrency -->

### [Joe Armstrong interviews Alan Kay](https://www.youtube.com/watch?v=fhOHn9TClXY)
Kay recounts the history of OOP and what Simula and Smalltalk-80 were going for. Cogent lessons for those willing to listen, and read between the lines:
> You can't go lower than a computer if you want to do arbitrary things. So going to data structures is meaningless; you can't go lower. Going to procedures is meaningless. ([10:40](https://youtu.be/fhOHn9TClXY?si=aR0SQre0PDNou2Yp&t=640))

<!-- Programming Philosophy -->

### [Stop Writing Dead Programs](https://www.youtube.com/watch?v=8Ab3ArE8W3s) by [Jack Rusher](https://jackrusher.com/)
Covers lots of amazing ground regarding visualizing and introspecting programs.

### [Object-Oriented Programming is Bad](https://www.youtube.com/watch?v=QM1iUe6IofM) by [Brian Will](https://github.com/BrianWill)
I watched this earlier in my career and am infinitely happy I did so. He also produced the wonderful followup [Object-Oriented Programming is Good*](https://www.youtube.com/watch?v=0iyB0_qPvWk), which proposes a mostly procedural solution with modest amounts of OO (perhaps closest to Go).
