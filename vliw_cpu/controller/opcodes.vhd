--------------------------------------------------------------------------------
--  VLIW-RT CPU - Opcode mapping package
--------------------------------------------------------------------------------
--
-- Copyright (c) 2016, Renan Augusto Starke <xtarke@gmail.com>
-- 
-- Departamento de Automação e Sistemas - DAS (Automation and Systems Department)
-- Universidade Federal de Santa Catarina - UFSC (Federal University of Santa Catarina)
-- Florianópolis, Brasil (Brazil)
--
-- This file is part of VLIW-RT CPU.

-- VLIW-RT CPU is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- VLIW-RT CPU is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with VLIW-RT CPU.  If not, see <http://www.gnu.org/licenses/>.
--
-- More information regarding operation decoding see:
-- Fisher, J. A., Faraboshi, P., & Young, C. (2005). Emebedded Computing: 
-- A VLIW Approach to Architecture Compilers and Tools. (Elsevier, Ed.). Morgan 
-- Kaufmann Publishers.
--

library ieee;
use ieee.std_logic_1164.all;
use work.cpu_typedef_package.all;
    
package opcodes is
	constant ADD_OP: std_logic_vector (OPCODE_SIZE-1 downto 0) := "00000";
	constant SUB_OP: std_logic_vector (OPCODE_SIZE-1 downto 0) := "00001";
	
	constant SHL_OP: std_logic_vector (OPCODE_SIZE-1 downto 0) := "00010";
	constant SHR_OP: std_logic_vector (OPCODE_SIZE-1 downto 0) := "00011";
	constant SHRU_OP: std_logic_vector (OPCODE_SIZE-1 downto 0) := "00100";
	
	constant SH1ADD_OP: std_logic_vector (OPCODE_SIZE-1 downto 0) := "00101";
	constant SH2ADD_OP: std_logic_vector (OPCODE_SIZE-1 downto 0) := "00110";
	constant SH3ADD_OP: std_logic_vector (OPCODE_SIZE-1 downto 0) := "00111";
	constant SH4ADD_OP: std_logic_vector (OPCODE_SIZE-1 downto 0) := "01000";
	
	constant AND_OP		: std_logic_vector (OPCODE_SIZE-1 downto 0) := "01001";
	constant ANDC_OP	: std_logic_vector (OPCODE_SIZE-1 downto 0) := "01010";	
	constant OR_OP			: std_logic_vector (OPCODE_SIZE-1 downto 0) := "01011";
	constant ORC_OP		: std_logic_vector (OPCODE_SIZE-1 downto 0) := "01100";	
	constant XOR_OP		: std_logic_vector (OPCODE_SIZE-1 downto 0) := "01101";
	
	-- constant MULLHUS_OP	: std_logic_vector (OPCODE_SIZE-1 downto 0) := "01111";	-- not implemented, st231 arch
	
	constant MAX_OP		: std_logic_vector (OPCODE_SIZE-1 downto 0) := "10000";	
	constant MAXU_OP	: std_logic_vector (OPCODE_SIZE-1 downto 0) := "10001";	
	constant MIN_OP		: std_logic_vector (OPCODE_SIZE-1 downto 0) := "10010";	
	constant MINU_OP	: std_logic_vector (OPCODE_SIZE-1 downto 0) := "10011";
	
	constant MULL_OP  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "10101";
		
	constant DIVRU_OP	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "11100";
	constant DIVQU_OP	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "11101";
	
	constant DIVR_OP	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "11110";
	constant DIVQ_OP	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "11111";


	-- compare instructions
	constant CMPEQ_OP 	: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "0000";
	constant CMPNE_OP 	: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "0001";
	constant CMPGE_OP 	: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "0010";
	constant CMPGEU_OP : std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "0011";
	constant CMPGT_OP 	: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "0100";
	constant CMPGTU_OP : std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "0101";
	constant CMPLE_OP 	: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "0110";
	constant CMPLEU_OP : std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "0111";
	constant CMPLT_OP 	: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "1000";
	constant CMPLTU_OP 	: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "1001";	
	constant ANDL_OP 		: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "1010";
	constant NANDL_OP 	: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "1011";
	constant ORL_OP 			: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "1100";
	constant NORL_OP 		: std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "1101";	
	constant MUL64HU_OP  : std_logic_vector(CMP_OPCODE_SIZE-1 downto 0) := "1110";
	constant MUL64H_OP    : std_logic_vector(CMP_OPCODE_SIZE-1 downto 0)  := "1111";
	
	
	-- sign extend depend on Monadic operator and immediate field
	constant MONADIC_OP		: std_logic_vector (OPCODE_SIZE-1 downto 0) := "01110";
	constant	SXTB_OP			: std_logic_vector (IMMEDIATE_SIZE-1 downto 0) := "000000000";
	constant	SXTH_OP			: std_logic_vector (IMMEDIATE_SIZE-1 downto 0) := "000000001";	
	constant	ZXTH_OP			: std_logic_vector (IMMEDIATE_SIZE-1 downto 0) := "000000011";
	constant	ZXTB_OP			: std_logic_vector (IMMEDIATE_SIZE-1 downto 0) := "000000101";	-- doest exist in st231, but in vex compiler
	constant BREAK_OP			: std_logic_vector(6 downto 0)	:= "1111111";
	
	-- "01" instruction format: seletct, addcg, divs, long immeidate
	constant SLCT_OP			: std_logic_vector (2 downto 0)	:= "000";
	constant SLCTF_OP		: std_logic_vector (2 downto 0)	:= "001";
	constant ADDCG_OP		: std_logic_vector (2 downto 0)	:= "010";
	constant SUBCG_OP		: std_logic_vector (2 downto 0)	:= "011";
	constant DIVS_OP			: std_logic_vector (2 downto 0)	:= "100";
	constant IMM_OP			: std_logic_vector (2 downto 0)	:= "101";	-- needs one more bit to select imml and immr
	constant PAR_ON			: std_logic_vector (2 downto 0)	:= "110";	-- enable full predication, ex on true
	constant PAR_OFF			: std_logic_vector (2 downto 0)	:= "111";	-- enable full predication, ex on false
	
	-- "10" instruction format: memory
	constant LDW_OP		:	std_logic_vector (MEMI_SIZE-1 downto 0) := "00000";	
	constant LDH_OP		:	std_logic_vector (MEMI_SIZE-1 downto 0) := "00010";
	constant LDHU_OP		:	std_logic_vector (MEMI_SIZE-1 downto 0) := "00100";
	constant LDB_OP		:	std_logic_vector (MEMI_SIZE-1 downto 0) := "00110";
	constant LDBU_OP		:	std_logic_vector (MEMI_SIZE-1 downto 0) := "01000";
	constant STW_OP		:	std_logic_vector (MEMI_SIZE-1 downto 0) := "01010";
	constant STH_OP		:	std_logic_vector (MEMI_SIZE-1 downto 0) := "01011";
	constant STB_OP		:	std_logic_vector (MEMI_SIZE-1 downto 0) := "01100";	
	
end;

package body opcodes is

	 
end package body;


		
