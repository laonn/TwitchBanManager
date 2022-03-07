#include <stdio.h>

#include "lualib.h"
#include "lua.h"
#include "lauxlib.h"
#include "luajit.h"

int main()
{
	lua_State* L = luaL_newstate();
	if (!L)
	{
		return -1;
	}

	luaL_openlibs(L);
	
	luaL_dofile(L, "DBInterface.lua");
	


	return 0;
}
