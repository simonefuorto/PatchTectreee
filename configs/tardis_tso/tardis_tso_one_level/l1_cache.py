# Copyright (c) 2021 The Regents of the University of California
# All Rights Reserved.
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

from m5.objects import (
    ClockDomain,
    MessageBuffer,
    RubyCache,
)

from gem5.isas import ISA
from gem5.utils.override import overrides
from gem5.components.processors.abstract_core import AbstractCore
from gem5.components.cachehierarchies.ruby.caches.abstract_l1_cache import AbstractL1Cache


class L1Cache(AbstractL1Cache):
    def __init__(
        self,
        size: str,
        assoc: int,
        network,
        core: AbstractCore,
        cache_line_size,
        target_isa: ISA,
        clk_domain: ClockDomain,
        lease: int,
    ):
        super().__init__(network, cache_line_size)

        self.cacheMemory = RubyCache(
            size=size, assoc=assoc, start_index_bit=self.getBlockSizeBits()
        )

        self.clk_domain = clk_domain
        self.send_evictions = core.requires_send_evicts()
        self.lease = lease

    @overrides(AbstractL1Cache)
    def connectQueues(self, network):
        self.mandatoryQueue = MessageBuffer()
        self.requestToDir = MessageBuffer()
        self.requestToDir.out_port = network.in_port
        self.responseToDir = MessageBuffer()
        self.responseToDir.out_port = network.in_port
        self.forwardFromDir = MessageBuffer()
        self.forwardFromDir.in_port = network.out_port
        self.responseFromDir = MessageBuffer()
        self.responseFromDir.in_port = network.out_port
