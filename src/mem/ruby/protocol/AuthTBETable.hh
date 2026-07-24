#ifndef __MEM_RUBY_PROTOCOL_AUTHTBETABLE_HH__
#define __MEM_RUBY_PROTOCOL_AUTHTBETABLE_HH__

#include "mem/ruby/structures/TBETable.hh"

namespace gem5 {
namespace ruby {

    template <class ENTRY>
    class AuthTBETable : public TBETable<ENTRY> {
    public:
        AuthTBETable(int number_of_TBEs) : TBETable<ENTRY>(number_of_TBEs) {}
        
        ENTRY& lookup_ref(Addr address) {
            return *(this->lookup(address));
        }
    };

} // namespace ruby
} // namespace gem5

#endif