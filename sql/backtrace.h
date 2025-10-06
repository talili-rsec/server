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

typedef struct Backtrace_info
{
  int line_no;
  String qname;
} Backtrace_info_type;

typedef struct Error_info
{
  int err_no;
  String msg;
} Error_info_type;

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
    backtrace_strings_constructed(FALSE),
    sql_condition_handled(FALSE),
    first_2_frames(PSI_INSTRUMENT_MEM),
    post_err_stack_top_visit_ctr(0)
  { 
    last_instr= {0, String()};
  }

  Dynamic_array<Error_info_type> error_stack;
  Dynamic_array<Backtrace_info_type> bt_list;
  Dynamic_array<Backtrace_info_type> erroring_bt_list;
  Dynamic_array<Backtrace_info_type> instr_component_list;
  Dynamic_array<String> errframes_strs;
  Dynamic_array<String> normalframes_strs;
  bool first_call;
  bool backtrace_strings_constructed;
  bool sql_condition_handled;
  Dynamic_array<String> first_2_frames;
  Backtrace_info_type last_instr;
  String backtrace_std_str;
  String errstack_str;
  int post_err_stack_top_visit_ctr;
};

#endif // BACKTRACE_INCLUDED
