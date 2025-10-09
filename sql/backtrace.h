/* Copyright (c) 2023, MariaDB Corporation.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1335  USA */

#ifndef BACKTRACE_INCLUDED
#define BACKTRACE_INCLUDED

#include <sql_string.h>

struct Backtrace_info
{
  int line_no;
  String qname;
};

struct Error_info
{
  int err_no;
  String msg;
};

class sp_head;

class Backtrace
{
public:
  Backtrace()
   :error_stack(PSI_INSTRUMENT_MEM),
    bt_list(PSI_INSTRUMENT_MEM),
    erroring_bt_list(PSI_INSTRUMENT_MEM),
    instr_component_list(PSI_INSTRUMENT_MEM),
    errframes_strs(PSI_INSTRUMENT_MEM),
    normalframes_strs(PSI_INSTRUMENT_MEM),
    f1_sphead(NULL),
    backtrace_strings_constructed(FALSE),
    sql_condition_handled(FALSE),
    first_2_frames(PSI_INSTRUMENT_MEM),
    post_err_stack_top_visit_ctr(0)
  {
    last_instr= {0, String()};
  }

  ~Backtrace()
  {
    // Free String objects in error_stack
    for (size_t i = 0; i < error_stack.size(); i++)
    {
      error_stack[i].msg.free();
    }

    // Free String objects in bt_list
    for (size_t i = 0; i < bt_list.size(); i++)
    {
      bt_list[i].qname.free();
    }

    // Free String objects in erroring_bt_list
    for (size_t i = 0; i < erroring_bt_list.size(); i++)
    {
      erroring_bt_list[i].qname.free();
    }

    // Free String objects in first_2_frames
    for (size_t i = 0; i < first_2_frames.size(); i++)
    {
      first_2_frames[i].free();
    }

    // Free String objects in instr_component_list
    for (size_t i = 0; i < instr_component_list.size(); i++)
    {
      instr_component_list[i].qname.free();
    }

    // last_instr also has a String member
    last_instr.qname.free();

    // Free the main strings
    backtrace_std_str.free();
    errstack_str.free();
  }

  Dynamic_array<struct Error_info> error_stack;
  Dynamic_array<struct Backtrace_info> bt_list;
  Dynamic_array<struct Backtrace_info> erroring_bt_list;
  Dynamic_array<struct Backtrace_info> instr_component_list;
  Dynamic_array<String> errframes_strs;
  Dynamic_array<String> normalframes_strs;
  sp_head* f1_sphead;
  bool first_call;
  bool backtrace_strings_constructed;
  bool sql_condition_handled;
  Dynamic_array<String> first_2_frames;
  struct Backtrace_info last_instr;
  String backtrace_std_str;
  String errstack_str;
  int post_err_stack_top_visit_ctr;
};

#endif // BACKTRACE_INCLUDED
