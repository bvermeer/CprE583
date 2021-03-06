/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    work_m_15980676999566119975_0384599330_init();
    work_m_01198895883271149522_3151427413_init();
    work_m_12720156847128194428_3922566773_init();
    unisims_ver_m_05793777342885121694_1942623789_init();
    work_m_06166911146081856876_2028898874_init();
    work_m_01226236256848061075_1821219061_init();
    work_m_02725609255998726451_2845640793_init();
    work_m_16250536692179668664_2450890912_init();
    work_m_16452126861537082597_3545803652_init();
    work_m_09925779491697741763_1443558247_init();
    work_m_16541823861846354283_2073120511_init();


    xsi_register_tops("work_m_09925779491697741763_1443558247");
    xsi_register_tops("work_m_16541823861846354283_2073120511");


    return xsi_run_simulation(argc, argv);

}
