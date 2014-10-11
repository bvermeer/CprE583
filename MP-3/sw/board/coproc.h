/*****************************************************************************
 * Joseph Zambreno
 * Department of Electrical and Computer Engineering
 * Iowa State University
 *****************************************************************************/


/*****************************************************************************
 * coproc.h - baseline LEON3 coprocessor instructions, wrapped as C functions.
 *
 *
 * NOTES:
 * 10/30/12 by JAZ::Design created.
 * 6/13/13 by TJB::Added new opcodes.
 *****************************************************************************/


#ifndef _COPROC_H_
#define _COPROC_H_


#include <stdint.h>
#include <stdio.h>


/* Define coprocssor-specfic opcodes - used as string arguments to cpop macros (use 9 LSb) */
#define CP_ANOTHER_OP "0x001"
#define CP_SIMPLE_ADD "0x002"
#define CP_COLOR_2_BW "0x004"


/* Coprocessor operator 1 */
#define cpop1(opc,rs1,rs2,rd)				\
".word (0x81B00000 + (("rs1" & 0x1F) << 14) + "	\
"(("rd" & 0x1F) << 25) + ("rs2" & 0x1F) +"		\
"(("opc" & 0x1FF) << 5) )"

/* Coprocessor operator 2 */
#define cpop2(opc,rs1,rs2,rd)			 \
".word (0x81B80000 + (("rs1" & 0x1F) << 14) +"	\
"(("rd" & 0x1F) << 25) + ("rs2" & 0x1F) +"		\
"(("opc" & 0x1FF) << 5) )"


/* Enable the coprocessor by setting the appropriate status register */
inline void cp_en()
{
	//Write to Process Status Register to enable coprocessor
	asm("rd %psr, %l0");       // Get current PSR value  
	asm("set 0x2000, %l1");    // Set bit mask
	asm("or %l0, %l1, %l0");   // Set bit 13 to Enable Coprocssor 
	asm("wr %l0, 0x0, %psr");  // Write updated PSR value
}


/* An example illustrating use of the cpop1 instruction */
inline void cpop1_use()
{
	asm(cpop1(CP_ANOTHER_OP, "0x0", "0x0", "0x0"));
}


/* Memory-coproc load functions (32-bit). */
inline void ld_c0(uint32_t a)
{
	asm("ld %0, %%c0" : : "m" (a) );
}
inline void ld_c1(uint32_t a)
{
	asm("ld %0, %%c1" : : "m" (a) );
}
inline void ld_c2(uint32_t a)
{
	asm("ld %0, %%c2" : : "m" (a) );
}
inline void ld_c3(uint32_t a)
{
	asm("ld %0, %%c3" : : "m" (a) );
}
inline void ld_c4(uint32_t a)
{
	asm("ld %0, %%c4" : : "m" (a) );
}
inline void ld_c5(uint32_t a)
{
	asm("ld %0, %%c5" : : "m" (a) );
}
inline void ld_c6(uint32_t a)
{
	asm("ld %0, %%c6" : : "m" (a) );
}
inline void ld_c7(uint32_t a)
{
	asm("ld %0, %%c7" : : "m" (a) );
}
inline void ld_c8(uint32_t a)
{
	asm("ld %0, %%c8" : : "m" (a) );
}
inline void ld_c9(uint32_t a)
{
	asm("ld %0, %%c9" : : "m" (a) );
}
inline void ld_c10(uint32_t a)
{
	asm("ld %0, %%c10" : : "m" (a) );
}
inline void ld_c11(uint32_t a)
{
	asm("ld %0, %%c11" : : "m" (a) );
}
inline void ld_c12(uint32_t a)
{
	asm("ld %0, %%c12" : : "m" (a) );
}
inline void ld_c13(uint32_t a)
{
	asm("ld %0, %%c13" : : "m" (a) );
}
inline void ld_c14(uint32_t a)
{
	asm("ld %0, %%c14" : : "m" (a) );
}
inline void ld_c15(uint32_t a)
{
	asm("ld %0, %%c15" : : "m" (a) );
}
inline void ld_c16(uint32_t a)
{
	asm("ld %0, %%c16" : : "m" (a) );
}
inline void ld_c17(uint32_t a)
{
	asm("ld %0, %%c17" : : "m" (a) );
}
inline void ld_c18(uint32_t a)
{
	asm("ld %0, %%c18" : : "m" (a) );
}
inline void ld_c19(uint32_t a)
{
	asm("ld %0, %%c19" : : "m" (a) );
}
inline void ld_c20(uint32_t a)
{
	asm("ld %0, %%c20" : : "m" (a) );
}
inline void ld_c21(uint32_t a)
{
	asm("ld %0, %%c21" : : "m" (a) );
}
inline void ld_c22(uint32_t a)
{
	asm("ld %0, %%c22" : : "m" (a) );
}
inline void ld_c23(uint32_t a)
{
	asm("ld %0, %%c23" : : "m" (a) );
}
inline void ld_c24(uint32_t a)
{
	asm("ld %0, %%c24" : : "m" (a) );
}
inline void ld_c25(uint32_t a)
{
	asm("ld %0, %%c25" : : "m" (a) );
}
inline void ld_c26(uint32_t a)
{
	asm("ld %0, %%c26" : : "m" (a) );
}
inline void ld_c27(uint32_t a)
{
	asm("ld %0, %%c27" : : "m" (a) );
}
inline void ld_c28(uint32_t a)
{
	asm("ld %0, %%c28" : : "m" (a) );
}
inline void ld_c29(uint32_t a)
{
	asm("ld %0, %%c29" : : "m" (a) );
}
inline void ld_c30(uint32_t a)
{
	asm("ld %0, %%c30" : : "m" (a) );
}
inline void ld_c31(uint32_t a)
{
	asm("ld %0, %%c31" : : "m" (a) );
}

/* Memory-coproc load functions (64-bit). */
inline void ldd_c0(uint64_t a)
{
	asm("ldd %0, %%c0" : : "m" (a) );
}
inline void ldd_c2(uint64_t a)
{
	asm("ldd %0, %%c2" : : "m" (a) );
}
inline void ldd_c4(uint64_t a)
{
	asm("ldd %0, %%c4" : : "m" (a) );
}
inline void ldd_c6(uint64_t a)
{
	asm("ldd %0, %%c6" : : "m" (a) );
}
inline void ldd_c8(uint64_t a)
{
	asm("ldd %0, %%c8" : : "m" (a) );
}
inline void ldd_c10(uint64_t a)
{
	asm("ldd %0, %%c10" : : "m" (a) );
}
inline void ldd_c12(uint64_t a)
{
	asm("ldd %0, %%c12" : : "m" (a) );
}
inline void ldd_c14(uint64_t a)
{
	asm("ldd %0, %%c14" : : "m" (a) );
}
inline void ldd_c16(uint64_t a)
{
	asm("ldd %0, %%c16" : : "m" (a) );
}
inline void ldd_c18(uint64_t a)
{
	asm("ldd %0, %%c18" : : "m" (a) );
}
inline void ldd_c20(uint64_t a)
{
	asm("ldd %0, %%c20" : : "m" (a) );
}
inline void ldd_c22(uint64_t a)
{
	asm("ldd %0, %%c22" : : "m" (a) );
}
inline void ldd_c24(uint64_t a)
{
	asm("ldd %0, %%c24" : : "m" (a) );
}
inline void ldd_c26(uint64_t a)
{
	asm("ldd %0, %%c26" : : "m" (a) );
}
inline void ldd_c28(uint64_t a)
{
	asm("ldd %0, %%c28" : : "m" (a) );
}
inline void ldd_c30(uint64_t a)
{
	asm("ldd %0, %%c30" : : "m" (a) );
}

/* Memory-coproc store functions (32-bit). */
inline void st_c0(uint32_t *a)
{
	asm("st %%c0, %0" : "=m" (*a) );
}
inline void st_c1(uint32_t *a)
{
	asm("st %%c1, %0" : "=m" (*a) );
}
inline void st_c2(uint32_t *a)
{
	asm("st %%c2, %0" : "=m" (*a) );
}
inline void st_c3(uint32_t *a)
{
	asm("st %%c3, %0" : "=m" (*a) );
}
inline void st_c4(uint32_t *a)
{
	asm("st %%c4, %0" : "=m" (*a) );
}
inline void st_c5(uint32_t *a)
{
	asm("st %%c5, %0" : "=m" (*a) );
}
inline void st_c6(uint32_t *a)
{
	asm("st %%c6, %0" : "=m" (*a) );
}
inline void st_c7(uint32_t *a)
{
	asm("st %%c7, %0" : "=m" (*a) );
}
inline void st_c8(uint32_t *a)
{
	asm("st %%c8, %0" : "=m" (*a) );
}
inline void st_c9(uint32_t *a)
{
	asm("st %%c9, %0" : "=m" (*a) );
}
inline void st_c10(uint32_t *a)
{
	asm("st %%c10, %0" : "=m" (*a) );
}
inline void st_c11(uint32_t *a)
{
	asm("st %%c11, %0" : "=m" (*a) );
}
inline void st_c12(uint32_t *a)
{
	asm("st %%c12, %0" : "=m" (*a) );
}
inline void st_c13(uint32_t *a)
{
	asm("st %%c13, %0" : "=m" (*a) );
}
inline void st_c14(uint32_t *a)
{
	asm("st %%c14, %0" : "=m" (*a) );
}
inline void st_c15(uint32_t *a)
{
	asm("st %%c15, %0" : "=m" (*a) );
}
inline void st_c16(uint32_t *a)
{
	asm("st %%c16, %0" : "=m" (*a) );
}
inline void st_c17(uint32_t *a)
{
	asm("st %%c17, %0" : "=m" (*a) );
}
inline void st_c18(uint32_t *a)
{
	asm("st %%c18, %0" : "=m" (*a) );
}
inline void st_c19(uint32_t *a)
{
	asm("st %%c19, %0" : "=m" (*a) );
}
inline void st_c20(uint32_t *a)
{
	asm("st %%c20, %0" : "=m" (*a) );
}
inline void st_c21(uint32_t *a)
{
	asm("st %%c21, %0" : "=m" (*a) );
}
inline void st_c22(uint32_t *a)
{
	asm("st %%c22, %0" : "=m" (*a) );
}
inline void st_c23(uint32_t *a)
{
	asm("st %%c23, %0" : "=m" (*a) );
}
inline void st_c24(uint32_t *a)
{
	asm("st %%c24, %0" : "=m" (*a) );
}
inline void st_c25(uint32_t *a)
{
	asm("st %%c25, %0" : "=m" (*a) );
}
inline void st_c26(uint32_t *a)
{
	asm("st %%c26, %0" : "=m" (*a) );
}
inline void st_c27(uint32_t *a)
{
	asm("st %%c27, %0" : "=m" (*a) );
}
inline void st_c28(uint32_t *a)
{
	asm("st %%c28, %0" : "=m" (*a) );
}
inline void st_c29(uint32_t *a)
{
	asm("st %%c29, %0" : "=m" (*a) );
}
inline void st_c30(uint32_t *a)
{
	asm("st %%c30, %0" : "=m" (*a) );
}
inline void st_c31(uint32_t *a)
{
	asm("st %%c31, %0" : "=m" (*a) );
}

/* Memory-coproc store functions (64-bit) */
inline void std_c0(uint64_t *a)
{
	asm("std %%c0, %0" : "=m" (*a) );
}
inline void std_c1(uint64_t *a)
{
	asm("std %%c1, %0" : "=m" (*a) );
}
inline void std_c2(uint64_t *a)
{
	asm("std %%c2, %0" : "=m" (*a) );
}
inline void std_c4(uint64_t *a)
{
	asm("std %%c4, %0" : "=m" (*a) );
}
inline void std_c6(uint64_t *a)
{
	asm("std %%c6, %0" : "=m" (*a) );
}
inline void std_c8(uint64_t *a)
{
	asm("std %%c8, %0" : "=m" (*a) );
}
inline void std_c10(uint64_t *a)
{
	asm("std %%c10, %0" : "=m" (*a) );
}
inline void std_c12(uint64_t *a)
{
	asm("std %%c12, %0" : "=m" (*a) );
}
inline void std_c14(uint64_t *a)
{
	asm("std %%c14, %0" : "=m" (*a) );
}
inline void std_c16(uint64_t *a)
{
	asm("std %%c16, %0" : "=m" (*a) );
}
inline void std_c18(uint64_t *a)
{
	asm("std %%c18, %0" : "=m" (*a) );
}
inline void std_c20(uint64_t *a)
{
	asm("std %%c20, %0" : "=m" (*a) );
}
inline void std_c22(uint64_t *a)
{
	asm("std %%c22, %0" : "=m" (*a) );
}
inline void std_c24(uint64_t *a)
{
	asm("std %%c24, %0" : "=m" (*a) );
}
inline void std_c26(uint64_t *a)
{
	asm("std %%c26, %0" : "=m" (*a) );
}
inline void std_c28(uint64_t *a)
{
	asm("std %%c28, %0" : "=m" (*a) );
}
inline void std_c30(uint64_t *a)
{
	asm("std %%c30, %0" : "=m" (*a) );
}


#endif /* _COPROC_H_ */

