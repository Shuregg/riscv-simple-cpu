/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

#if defined(_WIN32)
 #include "stdio.h"
#endif
#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

#if defined(_WIN32)
 #include "stdio.h"
#endif
#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern int main(int, char**);
extern void execute_3127(char*, char *);
extern void vlog_simple_process_execute_0_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_4148(char*, char *);
extern void execute_4(char*, char *);
extern void execute_3132(char*, char *);
extern void execute_24(char*, char *);
extern void execute_3142(char*, char *);
extern void execute_3143(char*, char *);
extern void execute_3144(char*, char *);
extern void execute_27(char*, char *);
extern void execute_28(char*, char *);
extern void execute_30(char*, char *);
extern void execute_38(char*, char *);
extern void execute_59(char*, char *);
extern void execute_60(char*, char *);
extern void execute_203(char*, char *);
extern void execute_3209(char*, char *);
extern void execute_3210(char*, char *);
extern void execute_3211(char*, char *);
extern void execute_3212(char*, char *);
extern void execute_3213(char*, char *);
extern void execute_3214(char*, char *);
extern void execute_3215(char*, char *);
extern void execute_3216(char*, char *);
extern void execute_3208(char*, char *);
extern void execute_208(char*, char *);
extern void execute_3219(char*, char *);
extern void execute_3220(char*, char *);
extern void execute_3221(char*, char *);
extern void execute_3222(char*, char *);
extern void execute_3218(char*, char *);
extern void execute_276(char*, char *);
extern void execute_277(char*, char *);
extern void execute_3125(char*, char *);
extern void execute_3126(char*, char *);
extern void execute_3129(char*, char *);
extern void execute_3130(char*, char *);
extern void execute_3131(char*, char *);
extern void execute_4149(char*, char *);
extern void execute_4150(char*, char *);
extern void execute_4151(char*, char *);
extern void execute_4152(char*, char *);
extern void execute_4153(char*, char *);
extern void vlog_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
funcp funcTab[44] = {(funcp)execute_3127, (funcp)vlog_simple_process_execute_0_fast_no_reg_no_agg, (funcp)execute_4148, (funcp)execute_4, (funcp)execute_3132, (funcp)execute_24, (funcp)execute_3142, (funcp)execute_3143, (funcp)execute_3144, (funcp)execute_27, (funcp)execute_28, (funcp)execute_30, (funcp)execute_38, (funcp)execute_59, (funcp)execute_60, (funcp)execute_203, (funcp)execute_3209, (funcp)execute_3210, (funcp)execute_3211, (funcp)execute_3212, (funcp)execute_3213, (funcp)execute_3214, (funcp)execute_3215, (funcp)execute_3216, (funcp)execute_3208, (funcp)execute_208, (funcp)execute_3219, (funcp)execute_3220, (funcp)execute_3221, (funcp)execute_3222, (funcp)execute_3218, (funcp)execute_276, (funcp)execute_277, (funcp)execute_3125, (funcp)execute_3126, (funcp)execute_3129, (funcp)execute_3130, (funcp)execute_3131, (funcp)execute_4149, (funcp)execute_4150, (funcp)execute_4151, (funcp)execute_4152, (funcp)execute_4153, (funcp)vlog_transfunc_eventcallback};
const int NumRelocateId= 44;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/tb_instr_mem_behav/xsim.reloc",  (void **)funcTab, 44);

	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/tb_instr_mem_behav/xsim.reloc");
}

	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net

void wrapper_func_0(char *dp)

{

}

void simulate(char *dp)
{
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/tb_instr_mem_behav/xsim.reloc");
	wrapper_func_0(dp);

	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern void implicit_HDL_SCinstantiate();

extern void implicit_HDL_SCcleanup();

extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/tb_instr_mem_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/tb_instr_mem_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/tb_instr_mem_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
