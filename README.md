Cure-Please
===========

Open source repository for anyone wishing to make changes to the official Cure Please source code.

Running without EliteAPI (2026-09-11)
-------------------------------------

`EliteAPI.dll` / `EliteMMO.API.dll` stopped working on current clients and are no longer
maintained. This branch replaces them with **XIScry**, which keeps the same namespace and
type names, so every call site in CurePlease is unchanged.

What that means for you:

* `XIScry.dll` is committed here, exactly where `EliteMMO.API.dll` used to be. Clone,
  open in Visual Studio, build, run. Nothing else to install.
* **No injection.** It reads the client from outside the process, so there is no native
  32-bit DLL to load, and CurePlease no longer has to be 32-bit or elevated for the library's
  sake. Reading another process can still need administrator depending on how the game was
  started.
* XIScry is a managed library that reads the client's memory from outside the process,
  the same structures the old pair read, exposed under the same namespace and type names.

Three things changed in CurePlease itself, all forced by the above:

1. **The injected console is gone.** EliteAPI read `/cureplease` from inside the game process
   and nothing outside it can. The same three commands still travel over UDP from the companion
   addon, so `/cpaddon cmd toggle|start|pause` typed in game reaches the handler that way.
2. **The addon's `cmd` branch sent the wrong argument.** It sent `args[1]`, which is the
   literal `/cpaddon`, instead of `args[3]`. Windower's copy was always correct, so this path
   has never worked on Ashita. Fixed, and the addon must be updated alongside the exe.
3. **The addon reader no longer stops listening while paused.** It was gated on
   `pauseActions == false`, so a worker restarting while paused bound no socket and the
   unpause command could never arrive.

Two features do not work yet and say so rather than failing quietly: the **Chat Log** window
stays empty, because nothing has located the client's chat buffer, and **AcceptRaise** never
fires, because it needs a menu field that has not been found. Everything else, including
curing, party reads, recasts, buffs, auto-follow and targeting, runs on real reads.

Follow, rebuilt
---------------

* **It keeps up now.** The follower fed the client a movement delta ten times a second and
  re-checked once a second, so it fell behind and then sprinted to catch up. Both run at
  50 Hz, and it tracks the target almost step for step.
* **Distance goes down to 0.1**, in tenths, and is compared as a real number instead of a
  truncated integer, so small gaps mean what they say.
* **Stop to cast**, a new checkbox in PL Follow Options and on by default: following holds
  while a spell is casting, so a step never interrupts a cure. Turn it off to follow
  through casts.

Hot keys, rewired
-----------------

CTRL+ALT+F1, F2 and F3 (toggle, start, pause) used to be `/bind` commands sent to the PL's
client, which meant they only fired while that window had focus, they were sent once per run
so turning the option on later did nothing, and they were skipped entirely when the program
was set to pause on start. CurePlease now registers them with Windows itself, so they work
from whichever window you are in and follow the option the moment you change it.

The Ashita addon in this repository is for **Ashita v4**. The copy shipped through 2.1.0 was
written for Ashita v3 and will not load on v4.
