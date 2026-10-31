/*
===========================================================================

  Copyright (c) 2022 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#pragma once

#include <common/types/maybe.h>
#include <sol/sol.hpp>

// sol only knows its own and std's optional, so Maybe needs these to reach Lua as nil or its value
namespace tl
{

template <typename T, typename Handler>
auto sol_lua_check(sol::types<optional<T>>, lua_State* L, int index, Handler&& handler, sol::stack::record& tracking) -> bool
{
    const auto type = sol::type_of(L, index);
    if (type == sol::type::none)
    {
        tracking.use(0);
        return true;
    }

    if (type == sol::type::lua_nil)
    {
        tracking.use(1);
        return true;
    }

    return sol::stack::check<T>(L, index, std::forward<Handler>(handler), tracking);
}

template <typename T>
auto sol_lua_get(sol::types<optional<T>>, lua_State* L, int index, sol::stack::record& tracking) -> optional<T>
{
    auto value = sol::stack::check_get<T>(L, index, &sol::no_panic, tracking);
    if (!value)
    {
        return {};
    }

    return std::move(*value);
}

// A value of the wrong type reads as empty, the same as sol does for std::optional
template <typename T, typename Handler>
auto sol_lua_check_get(sol::types<optional<T>>, lua_State* L, int index, Handler&&, sol::stack::record& tracking) -> sol::optional<optional<T>>
{
    return sol_lua_get(sol::types<optional<T>>{}, L, index, tracking);
}

template <typename T>
auto sol_lua_push(sol::types<optional<T>>, lua_State* L, const optional<T>& value) -> int
{
    if (!value)
    {
        return sol::stack::push(L, sol::lua_nil);
    }

    return sol::stack::push(L, *value);
}

} // namespace tl

extern sol::state& lua;

void lua_init();
void lua_cleanup();
auto lua_to_string_depth(const sol::object& obj, std::size_t depth) -> std::string;
auto lua_to_string(sol::variadic_args va) -> std::string;
void lua_print(sol::variadic_args va);
auto lua_fmt(const std::string& fmtStr, sol::variadic_args va) -> std::string;
