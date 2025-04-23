
/*
Necessary includes.
*/
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

/*
Function prototypes.
*/
int lua_fork(lua_State *L);
int lua_waitpid(lua_State *L);
int luaopen_lua_fork(lua_State *L);

/*
Calls the fork() subroutine from the POSIX operating system API.

This function isn't available to Lua because it's a low-level operating system
call. One of the purposes for allowing modules to be written in C is so that
these types of functions can be made accessible.
*/
int
lua_fork(lua_State *L)
{
    /*
    fork() returns a pid_t type. According to the GNU libc manual, pid_t
    is just an int data type.
    */
    pid_t pid = (int)fork();

    /*
    If the pid is less than 0, it failed.
    */
    if (pid < 0)
        return luaL_error(L, "fork() failed.");

    /*
    The pid is returned via the lua_State.
    */
    lua_pushnumber(L, pid);

    /*
    The number of results we're giving back to Lua.
    */
    return 1;
}

int
lua_waitpid(lua_State *L)
{
    pid_t pid = (pid_t)luaL_checkinteger(L, 1);
    int status;
    pid_t result = waitpid(pid, &status, WNOHANG);
    lua_pushinteger(L, result);
    return 1;
}

/*
In order for Lua to recognize the entrypoint of the module, at least one
function must be named according to this format: luaopen_<module name>. In the
Lua program, you can import the module by writing require(<module name>).
*/
int
luaopen_lua_pid(lua_State *L)
{
    /*
    Create an array of functions which should be accessible from Lua.
    */
    static const struct luaL_Reg functions[] = {
        {"lua_fork", lua_fork},
        {"lua_waitpid", lua_waitpid},
        {NULL, NULL}
    };

    /*
    Add those functions to the Lua state so they're accessible.
    */
    luaL_register(L, "lua_pid", functions);

    /*
    The number of results we're giving back to Lua.
    */
    return 1;
}

