# Copyright (c) 2021 The Regents of the University of California
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

"""
This script utilizes the X86DemoBoard to run a simple Ubunutu boot. The script
will boot the the OS to login before exiting the simulation.

A detailed terminal output can be found in `m5out/system.pc.com_1.device`.

**Warning:** The X86DemoBoard uses the Timing CPU. The boot may take
considerable time to complete execution.
`configs/example/gem5_library/x86-ubuntu-run-with-kvm.py` can be referenced as
an example of booting Ubuntu with a KVM CPU.

Usage
-----

```
scons build/X86/gem5.opt
./build/X86/gem5.opt configs/tardis_tso_tectree/x86-ubuntu-run-timing-tardistso.py
```
"""



from m5.util import warn

from gem5.coherence_protocol import CoherenceProtocol
from gem5.components.boards.x86_board import X86Board
from tardis_tso_tectree_one_level_cache_hierarchy import TARDISTSO_TECTREEOneLevelCacheHierarchy
from gem5.components.memory.single_channel import SingleChannelDDR3_1600
from gem5.components.processors.cpu_types import CPUTypes
from gem5.components.processors.simple_processor import SimpleProcessor
from gem5.isas import ISA
from gem5.utils.requires import requires
from gem5.resources.resource import obtain_resource
from gem5.simulate.simulator import Simulator

class X86TardisBoard(X86Board):

    def __init__(self):
        requires(
            isa_required=ISA.X86,
            coherence_protocol_required=CoherenceProtocol.TARDISTSO_TECTREE,
        )

        warn(
            "The X86DemoBoard is solely for demonstration purposes. "
            "This board is not known to be be representative of any "
            "real-world system. Use with caution."
        )

        memory = SingleChannelDDR3_1600(size="3GB")
        processor = SimpleProcessor(
            cpu_type=CPUTypes.TIMING, isa=ISA.X86, num_cores=2
        )
        
        cache_hierarchy = TARDISTSO_TECTREEOneLevelCacheHierarchy(
            size = "32kB",
            assoc = "8",
        )

        super().__init__(
            clk_freq="2GHz",
            processor=processor,
            memory=memory,
            cache_hierarchy=cache_hierarchy,
        )


# Here we setup the board. The prebuilt X86DemoBoard allows for Full-System X86
# simulation.
board = X86TardisBoard()

# We then set the workload. Here we use the "x86-ubuntu-18.04-boot" workload.
# This boots Ubuntu 18.04 with Linux 5.4.49. If the required resources are not
# found locally, they will be downloaded.
board.set_workload(obtain_resource("x86-ubuntu-18.04-boot"))

simulator = Simulator(board=board)
simulator.run()
