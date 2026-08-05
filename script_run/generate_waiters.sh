#!/bin/bash
for i in {0..15}; do
cat << INNER_EOF
            if (AuthTBEs.lookup_ref(address).Waiter${i} != intToAddress(0)) {
                Addr data_addr := AuthTBEs.lookup_ref(address).Waiter${i};
                Addr missing_parent := getFirstMissingParent(data_addr);
                
                if (missing_parent != intToAddress(0)) {
                    if (AuthTBEs.isPresent(missing_parent) == false) {
                        AuthTBEs.allocate(missing_parent);
                        enqueue(memQueue_out, MemoryMsg, to_memory_controller_latency) {
                            out_msg.addr := missing_parent;
                            out_msg.Type := MemoryRequestType:MEMORY_READ;
                            out_msg.Sender := machineID;
                            out_msg.MessageSize := MessageSizeType:Request_Control;
                            out_msg.Len := 0;
                        }
                        DPRINTF(Tectree, "[Cascading Eviction] Il blocco 0x%x ha svegliato 0x%x, ma manca il genitore 0x%x. Fetch!\n", address, data_addr, missing_parent);
                    }
                    
                    if (AuthTBEs.lookup_ref(missing_parent).Waiter0 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter0 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter1 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter1 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter2 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter2 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter3 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter3 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter4 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter4 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter5 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter5 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter6 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter6 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter7 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter7 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter8 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter8 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter9 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter9 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter10 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter10 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter11 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter11 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter12 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter12 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter13 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter13 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter14 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter14 := data_addr; }
                    else if (AuthTBEs.lookup_ref(missing_parent).Waiter15 == intToAddress(0)) { AuthTBEs.lookup_ref(missing_parent).Waiter15 := data_addr; }
                } else {
                    Addr L1 := getParentAddr(data_addr);
                    if (L1 != intToAddress(0) && LLC.isTagPresent(L1)) {
                        getLLCEntry(L1).Dirty := true;
                        getDirectoryEntry(L1).DirState := State:C_M;
                        LLC.setMRU(L1);
                        Addr L2 := getParentAddr(L1);
                        if (L2 != intToAddress(0) && LLC.isTagPresent(L2)) {
                            getLLCEntry(L2).Dirty := true;
                            getDirectoryEntry(L2).DirState := State:C_M;
                            LLC.setMRU(L2);
                            Addr L3 := getParentAddr(L2);
                            if (L3 != intToAddress(0) && LLC.isTagPresent(L3)) {
                                getLLCEntry(L3).Dirty := true;
                                getDirectoryEntry(L3).DirState := State:C_M;
                                LLC.setMRU(L3);
                                Addr L4 := getParentAddr(L3);
                                if (L4 != intToAddress(0) && LLC.isTagPresent(L4)) {
                                    getLLCEntry(L4).Dirty := true;
                                    getDirectoryEntry(L4).DirState := State:C_M;
                                    LLC.setMRU(L4);
                                    Addr L5 := getParentAddr(L4);
                                    if (L5 != intToAddress(0) && LLC.isTagPresent(L5)) {
                                        getLLCEntry(L5).Dirty := true;
                                        getDirectoryEntry(L5).DirState := State:C_M;
                                        LLC.setMRU(L5);
                                        Addr L6 := getParentAddr(L5);
                                        if (L6 != intToAddress(0) && LLC.isTagPresent(L6)) {
                                            getLLCEntry(L6).Dirty := true;
                                            getDirectoryEntry(L6).DirState := State:C_M;
                                            LLC.setMRU(L6);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Entry data_dir_entry := getDirectoryEntry(data_addr);
                    enqueue(memQueue_out, MemoryMsg, to_memory_controller_latency) {
                        out_msg.addr := data_addr;
                        out_msg.Type := MemoryRequestType:MEMORY_WB;
                        out_msg.Sender := machineID;
                        out_msg.MessageSize := MessageSizeType:Writeback_Data;
                        out_msg.DataBlk := TBEs[data_addr].DataBlk;
                    }
                    if (data_dir_entry.DirState == State:I_Evict_Auth) {
                        getDirectoryEntry(data_addr).DirState := State:I_Evicting;
                        TBEs[data_addr].TBEState := State:I_Evicting;
                    } else if (data_dir_entry.DirState == State:S_Evict_Auth) {
                        getDirectoryEntry(data_addr).DirState := State:S_Evicting;
                        TBEs[data_addr].TBEState := State:S_Evicting;
                    } else if (data_dir_entry.DirState == State:E_Evict_Auth) {
                        getDirectoryEntry(data_addr).DirState := State:E_Evicting;
                        TBEs[data_addr].TBEState := State:E_Evicting;
                    }
                    DPRINTF(Tectree, "[Cascading Eviction] Il blocco 0x%x ha tutto il ramo pronto! Sfrattato in MEMORY_WB.\n", data_addr);
                }
            }
INNER_EOF
done
