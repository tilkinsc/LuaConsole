
#ifndef ADDITIONS_H_
#define ADDITIONS_H_

#if defined(__cplusplus)
extern "C" {
#endif

// I don't like this include here
#include "lua.h" 

int stack_dump(lua_State* L);

void additions_add(lua_State* L);

#if defined(__cplusplus)
}
#endif

#endif
