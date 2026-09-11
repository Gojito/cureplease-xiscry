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
   and nothing outside it can. The same three commands already travel over UDP from the
   companion addon, so the hotkeys now send `/cpaddon cmd toggle|start|pause` and reach the
   handler that way.
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
