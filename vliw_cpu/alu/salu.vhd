--------------------------------------------------------------------------------
--  VLIW-RT CPU - All four Arithmetic Logic Units
--              - Includes Forward Logic
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
--
-- This file uses Altera libraries subjected to Altera licenses
-- See altera-ip folder for more information

library IEEE;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;
use work.alu_functions.all;

entity salu is
port (
	clk    : in std_logic;	
	reset  : in std_logic;
	
	ex_stall : in std_logic;
	
	-- cycle that need forward
	rd_ctrl_src_0_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_1_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_2_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_3_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	rd_ctrl_src_0_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_1_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_2_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_3_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	scond_0					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	scond_1					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	scond_2					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	scond_3					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);

	-- needed to disable forward
	branch_en				: in std_logic;	
	
	-- immediates	
	imm_0							: word_t;
	imm_1							: word_t;
	imm_2							: word_t;
	imm_3							: word_t;
	
	-- register / immediate selection
	src_2_sel_0				: IN STD_LOGIC;
	src_2_sel_1				: IN STD_LOGIC;
	src_2_sel_2				: IN STD_LOGIC;
	src_2_sel_3				: IN STD_LOGIC;
	
	-- destination registers
	wb_addr_reg_0		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_0	: in std_logic;
		
	wb_addr_reg_1		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_1	: in std_logic;
	
	wb_addr_reg_2		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_2	: in std_logic;
	
	wb_addr_reg_3		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_3	: in std_logic;
	
	wb_mem_rd_0			: in std_logic;
	wb_mem_rd_1			: in std_logic;
	
	wb_mul_div_0		: in std_logic;
	wb_mul_div_1		: in std_logic;
	
	-- destination predicates
	wb_addr_pred_0 : in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	wb_pred_w_en_0: in std_logic;
	
	wb_addr_pred_1 : in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	wb_pred_w_en_1: in std_logic;
	
	wb_addr_pred_2 : in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	wb_pred_w_en_2: in std_logic;
	
	wb_addr_pred_3 : in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	wb_pred_w_en_3: in std_logic;	
		
	func_0   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
	func_1   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
	func_2   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
	func_3   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
   
	carry_in_0		 : in std_logic;
	carry_in_1		 : in std_logic;
	carry_in_2		 : in std_logic;
	carry_in_3		 : in std_logic;
	
	src1_in_0		 : in word_t;
	src2_in_0		 : in word_t;
	
	src1_in_1		 : in word_t;
	src2_in_1		 : in word_t;
	
	src1_in_2		 : in word_t;
	src2_in_2		 : in word_t;
	
	src1_in_3		 : in word_t;
	src2_in_3		 : in word_t;
	
	memory_data			: in word_t;
	memory_data_1	: in word_t;
	
	mul_div_0_data	: in word_t;
	mul_div_1_data	: in word_t;
					
	alu_out_0		: out t_alu_val;
	alu_out_1		: out t_alu_val;
	alu_out_2		: out t_alu_val;
	alu_out_3		: out t_alu_val
		
	);
end salu;


architecture rtl of salu is
		
	component compare_signed
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		aeb		: OUT STD_LOGIC ;
		agb		: OUT STD_LOGIC ;
		ageb		: OUT STD_LOGIC ;
		alb		: OUT STD_LOGIC ;
		aleb		: OUT STD_LOGIC ;
		aneb		: OUT STD_LOGIC 
	);
	end component;

	component compare_unsigned
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		agb		: OUT STD_LOGIC ;
		ageb		: OUT STD_LOGIC ;
		alb		: OUT STD_LOGIC ;
		aleb		: OUT STD_LOGIC 
	);
	end component;
	
	component add_carry port
	(
		add_sub	: IN STD_LOGIC ;
		cin					: IN STD_LOGIC ;
		dataa			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		overflow			: OUT STD_LOGIC ;
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component add_carry;

	component mux_carry
	PORT
	(
		data0		: IN STD_LOGIC ;
		data1		: IN STD_LOGIC ;
		data2		: IN STD_LOGIC ;
		data3		: IN STD_LOGIC ;
		data4		: IN STD_LOGIC ;
		sel				: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		result		: OUT STD_LOGIC 
	);
	end component;	
	
	component forward_mux  port
	(
		data0x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data1x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data2x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data3x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data4x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data5x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data6x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data7x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data8x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		sel		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END component forward_mux;

	component mux_0 is
	port
	(
		data0x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data1x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		sel					: IN STD_LOGIC ;
		result			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component mux_0;
	
	signal add_carry_val_0	:	word_t;
	signal add_carry_val_1	:	word_t;
	signal add_carry_val_2	:	word_t;
	signal add_carry_val_3	:	word_t;
	signal carry_out_0		:  std_logic;
	signal carry_out_1		:  std_logic;
	signal carry_out_2		:  std_logic;
	signal carry_out_3		:  std_logic;
	
	signal carry_forw_0 : std_logic;
	signal carry_forw_1 : std_logic;
	signal carry_forw_2 : std_logic;
	signal carry_forw_3 : std_logic;
	
	signal carry_0_sel : STD_LOGIC_VECTOR (2 DOWNTO 0);
	signal carry_1_sel : STD_LOGIC_VECTOR (2 DOWNTO 0);
	signal carry_2_sel : STD_LOGIC_VECTOR (2 DOWNTO 0);
	signal carry_3_sel : STD_LOGIC_VECTOR (2 DOWNTO 0);	

	signal aeb_0 : std_logic;
	signal agb_0 : std_logic;
	signal ageb_0 : std_logic;
	signal alb_0 : std_logic;
	signal aleb_0 : std_logic;
	signal aneb_0 : std_logic;
	
	signal aeb_1 : std_logic;
	signal agb_1 : std_logic;
	signal ageb_1 : std_logic;
	signal alb_1: std_logic;
	signal aleb_1 : std_logic;
	signal aneb_1 : std_logic;
	
	signal aeb_2 : std_logic;
	signal agb_2 : std_logic;
	signal ageb_2 : std_logic;
	signal alb_2: std_logic;
	signal aleb_2 : std_logic;
	signal aneb_2 : std_logic;
	
	signal aeb_3 : std_logic;
	signal agb_3 : std_logic;
	signal ageb_3 : std_logic;
	signal alb_3: std_logic;
	signal aleb_3 : std_logic;
	signal aneb_3 : std_logic;
	
	signal agbu_0 : std_logic;
	signal agebu_0 : std_logic;
	signal albu_0 : std_logic;
	signal alebu_0 : std_logic;	
	
	signal agbu_1 : std_logic;
	signal agebu_1 : std_logic;
	signal albu_1 : std_logic;
	signal alebu_1 : std_logic;	
	
	signal agbu_2 : std_logic;
	signal agebu_2 : std_logic;
	signal albu_2 : std_logic;
	signal alebu_2 : std_logic;	
	
	signal agbu_3 : std_logic;
	signal agebu_3 : std_logic;
	signal albu_3: std_logic;
	signal alebu_3 : std_logic;	
	
	signal alu_val_0 : t_alu_val;	
	signal alu_val_1 : t_alu_val;	
	signal alu_val_2 : t_alu_val;	
	signal alu_val_3 : t_alu_val;

	signal alu_0_sel_1 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal alu_0_sel_2 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal alu_0_src_1 : word_t;
	signal alu_0_src_2 : word_t;	
	signal mux_src2_0_val : word_t;
	
	signal alu_1_sel_1 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal alu_1_sel_2 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal alu_1_src_1 : word_t;
	signal alu_1_src_2 : word_t;	
	signal mux_src2_1_val : word_t;
	
	signal alu_2_sel_1 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal alu_2_sel_2 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal alu_2_src_1 : word_t;
	signal alu_2_src_2 : word_t;	
	signal mux_src2_2_val : word_t;
	
	signal alu_3_sel_1 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal alu_3_sel_2 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal alu_3_src_1 : word_t;
	signal alu_3_src_2 : word_t;	
	signal mux_src2_3_val : word_t;
	
	----------------------------------------------------------
	
	signal alu_0_and  : word_t;
	signal alu_0_andc : word_t;
	signal alu_0_or : word_t;
	signal alu_0_orc: word_t;
	signal alu_0_xor : word_t;
	
	signal alu_1_and  : word_t;
	signal alu_1_andc : word_t;
	signal alu_1_or : word_t;
	signal alu_1_orc: word_t;
	signal alu_1_xor : word_t;
	
	signal alu_2_and  : word_t;
	signal alu_2_andc : word_t;
	signal alu_2_or : word_t;
	signal alu_2_orc: word_t;
	signal alu_2_xor : word_t;
	
	signal alu_3_and  : word_t;
	signal alu_3_andc : word_t;
	signal alu_3_or : word_t;
	signal alu_3_orc: word_t;
	signal alu_3_xor : word_t;
	
	signal l_shift_0_val : word_t;
	signal l_shift_1_val : word_t;
	signal l_shift_2_val : word_t;
	signal l_shift_3_val : word_t;
		
begin
		
	add_carry_0: add_carry port map 
   (
		add_sub => func_0(0),	-- 1 adds / 0 substracts
		cin => carry_forw_0,
		--dataa => src1_in_0,
		dataa => alu_0_src_1,
		--datab => src2_in_0, 
		datab => mux_src2_0_val,
		overflow  => carry_out_0,
		result => add_carry_val_0	
	);

	add_carry_1: add_carry port map 
   (
		add_sub => func_1(0),
		cin => carry_forw_1,
		--dataa => src1_in_0,
		dataa => alu_1_src_1,
		--datab => src2_in_0, 
		datab => mux_src2_1_val,
		overflow  => carry_out_1,
		result => add_carry_val_1	
	);		
	
	add_carry_2: add_carry port map 
   (
		add_sub => func_2(0),
		cin => carry_forw_2,
		--dataa => src1_in_0,
		dataa => alu_2_src_1,
		--datab => src2_in_0, 
		datab => mux_src2_2_val,
		overflow  => carry_out_2,
		result => add_carry_val_2	
	);		
	
	add_carry_3: add_carry port map 
   (
		add_sub => func_3(0),
		cin => carry_forw_3,
		--dataa => src1_in_0,
		dataa => alu_3_src_1,
		--datab => src2_in_0, 
		datab => mux_src2_3_val,
		overflow  => carry_out_3,
		result => add_carry_val_3	
	);
	
	mux_forward_carry_0: mux_carry port map	
	(
		--clock	=> clk,
		data0		=> carry_in_0,							-- read from register file
		data1		=> alu_val_0.carry_cmp,	-- forward from alu 0
		data2		=> alu_val_1.carry_cmp,	-- forward from alu 1
		data3		=> alu_val_2.carry_cmp,	-- forward from alu 2
		data4		=> alu_val_3.carry_cmp,	-- forward from alu 3
		sel				=> carry_0_sel,
		result		=> carry_forw_0
	);	

	mux_forward_carry_1: mux_carry port map	
	(
		--clock	=> clk,
		data0		=> carry_in_1,							-- read from register file
		data1		=> alu_val_0.carry_cmp,	-- forward from alu 0
		data2		=> alu_val_1.carry_cmp,	-- forward from alu 1
		data3		=> alu_val_2.carry_cmp,	-- forward from alu 2
		data4		=> alu_val_3.carry_cmp,	-- forward from alu 3
		sel				=> carry_1_sel,
		result		=> carry_forw_1
	);	
	
	mux_forward_carry_2: mux_carry port map	
	(
		--clock	=> clk,
		data0		=> carry_in_2,							-- read from register file
		data1		=> alu_val_0.carry_cmp,	-- forward from alu 0
		data2		=> alu_val_1.carry_cmp,	-- forward from alu 1
		data3		=> alu_val_2.carry_cmp,	-- forward from alu 2
		data4		=> alu_val_3.carry_cmp,	-- forward from alu 3
		sel				=> carry_2_sel,
		result		=> carry_forw_2
	);	
	
	mux_forward_carry_3: mux_carry port map	
	(
		--clock	=> clk,
		data0		=> carry_in_3,							-- read from register file
		data1		=> alu_val_0.carry_cmp,	-- forward from alu 0
		data2		=> alu_val_1.carry_cmp,	-- forward from alu 1
		data3		=> alu_val_2.carry_cmp,	-- forward from alu 2
		data4		=> alu_val_3.carry_cmp,	-- forward from alu 3
		sel				=> carry_3_sel,
		result		=> carry_forw_3
	);	
	
	comp_sg_0 : compare_signed	PORT map
	(
		dataa		=>  alu_0_src_1,
		datab		=> mux_src2_0_val,
		aeb		   => aeb_0,
		agb		   => agb_0,
		ageb		=> ageb_0,
		alb				=> alb_0,
		aleb			=> aleb_0,
		aneb		=> aneb_0
	);
	
	comp_sg_1 : compare_signed	PORT map
	(
		dataa		=> alu_1_src_1,
		datab		=> mux_src2_1_val,
		aeb		   => aeb_1,
		agb		   => agb_1,
		ageb		=> ageb_1,
		alb				=> alb_1,
		aleb			=> aleb_1,
		aneb		=> aneb_1
	);
	
	comp_sg_2 : compare_signed	PORT map
	(
		dataa		=> alu_2_src_1,
		datab		=> mux_src2_2_val,
		aeb		   => aeb_2,
		agb		   => agb_2,
		ageb		=> ageb_2,
		alb				=> alb_2,
		aleb			=> aleb_2,
		aneb		=> aneb_2
	);
	
	comp_sg_3 : compare_signed	PORT map
	(
		dataa		=> alu_3_src_1,
		datab		=> mux_src2_3_val,
		aeb		   => aeb_3,
		agb		   => agb_3,
		ageb		=> ageb_3,
		alb				=> alb_3,
		aleb			=> aleb_3,
		aneb		=> aneb_3
	);
	
	comp_usg_0 : compare_unsigned	PORT map
	(
		dataa		=> alu_0_src_1,
		datab		=> mux_src2_0_val,		
		agb		   => agbu_0,
		ageb		=> agebu_0,
		alb				=> albu_0,
		aleb			=> alebu_0
	);
	
	comp_usg_1 : compare_unsigned	PORT map
	(
		dataa		=> alu_1_src_1,
		datab		=> mux_src2_1_val,		
		agb		   => agbu_1,
		ageb		=> agebu_1,
		alb				=> albu_1,
		aleb			=> alebu_1
	);
	
	comp_usg_2 : compare_unsigned	PORT map
	(
		dataa		=> alu_2_src_1,
		datab		=> mux_src2_2_val,		
		agb		   => agbu_2,
		ageb		=> agebu_2,
		alb				=> albu_2,
		aleb			=> alebu_2
	);
	
		comp_usg_3 : compare_unsigned	PORT map
	(
		dataa		=> alu_3_src_1,
		datab		=> mux_src2_3_val,		
		agb		   => agbu_3,
		ageb		=> agebu_3,
		alb				=> albu_3,
		aleb			=> alebu_3
	);
	

	alu_0_and  	<= alu_0_src_1 and mux_src2_0_val;
	alu_0_andc 	<= (not alu_0_src_1) and mux_src2_0_val;
	alu_0_or 		<= alu_0_src_1 or mux_src2_0_val;
	alu_0_orc 		<= (not alu_0_src_1) or mux_src2_0_val;
	alu_0_xor 		<= alu_0_src_1 xor mux_src2_0_val;
--	
--	alu_1_and  	<= alu_1_src_1 and mux_src2_1_val;
--	alu_1_andc 	<= (not alu_1_src_1) and mux_src2_1_val;
--	alu_1_or 		<= alu_1_src_1 or mux_src2_1_val;
--	alu_1_orc 		<= (not alu_1_src_1) or mux_src2_1_val;
--	alu_1_xor 		<= alu_1_src_1 xor mux_src2_1_val;
--	
--	alu_2_and  	<= alu_2_src_1 and mux_src2_2_val;
--	alu_2_andc 	<= (not alu_2_src_1) and mux_src2_2_val;
--	alu_2_or 		<= alu_2_src_1 or mux_src2_2_val;
--	alu_2_orc 		<= (not alu_2_src_1) or mux_src2_2_val;
--	alu_2_xor 		<= alu_2_src_1 xor mux_src2_2_val;	
--	
	alu_3_and  	<= alu_3_src_1 and mux_src2_3_val;
	alu_3_andc 	<= (not alu_3_src_1) and mux_src2_3_val;
	alu_3_or 		<= alu_3_src_1 or mux_src2_3_val;
	alu_3_orc 		<= (not alu_3_src_1) or mux_src2_3_val;
	alu_3_xor 		<= alu_3_src_1 xor mux_src2_3_val;
	
	
--		scond_0					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
--	scond_1					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
--	scond_2					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
--	scond_3					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
--	
--		wb_addr_pred_0 : in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
--	wb_pred_w_en_0: in std_logic;

	
	
	process	(clk, reset, wb_addr_pred_0 , scond_0, wb_pred_w_en_0,
											    wb_addr_pred_1 , scond_1, wb_pred_w_en_1,
											    wb_addr_pred_2 , scond_2, wb_pred_w_en_2,
											    wb_addr_pred_3 , scond_3, wb_pred_w_en_3,
												 ex_stall)
	begin
		if reset = '1' then
			carry_0_sel	<=	"000";
			carry_1_sel	<=	"000";
			carry_2_sel	<=	"000";
			carry_3_sel	<=	"000";
		else
			if rising_edge(clk) and ex_stall = '0' then
			
				carry_0_sel	<=	"000";
				carry_1_sel	<=	"000";
				carry_2_sel	<=	"000";
				carry_3_sel	<=	"000";					
			
				-- ALU	0 to ALU 0
				if wb_addr_pred_0 = scond_0 and wb_pred_w_en_0 = '1' then
					carry_0_sel	<=	"001";
				end if;
									
				-- ALU	1 to ALU 0
				if wb_addr_pred_1 = scond_0 and wb_pred_w_en_1 = '1' then
					carry_0_sel	<=	"010";
				end if;
				
				-- ALU	2 to ALU 0
				if wb_addr_pred_2 = scond_0 and wb_pred_w_en_2 = '1' then
					carry_0_sel	<=	"011";
				end if;			
							
				-- ALU	3 to ALU 0
				if wb_addr_pred_3 = scond_0 and wb_pred_w_en_3 = '1' then
					carry_0_sel	<=	"100";
				end if;
					
				----------------------------------------------				
				-- ALU	0 to ALU 1
				if wb_addr_pred_0 = scond_1 and wb_pred_w_en_0 = '1' then
					carry_1_sel	<=	"001";
				end if;
									
				-- ALU	1 to ALU 1
				if wb_addr_pred_1 = scond_1 and wb_pred_w_en_1 = '1' then
					carry_1_sel	<=	"010";
				end if;
				
				-- ALU	2 to ALU 1
				if wb_addr_pred_2 = scond_1 and wb_pred_w_en_2 = '1' then
					carry_1_sel	<=	"011";
				end if;			
							
				-- ALU	3 to ALU 1
				if wb_addr_pred_3 = scond_1 and wb_pred_w_en_3 = '1' then
					carry_1_sel	<=	"100";
				end if;
			
				----------------------------------------------				
				-- ALU	0 to ALU 2				
				if wb_addr_pred_0 = scond_2 and wb_pred_w_en_0 = '1' then
					carry_2_sel	<=	"001";
				end if;
									
				-- ALU	1 to ALU 2
				if wb_addr_pred_1 = scond_2 and wb_pred_w_en_1 = '1' then
					carry_2_sel	<=	"010";
				end if;
				
				-- ALU	2 to ALU 2
				if wb_addr_pred_2 = scond_2 and wb_pred_w_en_2 = '1' then
					carry_2_sel	<=	"011";
				end if;			
							
				-- ALU	3 to ALU 2
				if wb_addr_pred_3 = scond_2 and wb_pred_w_en_3 = '1' then
					carry_2_sel	<=	"100";
				end if;
				
				----------------------------------------------
				-- ALU	0 to ALU 3
				if wb_addr_pred_0 = scond_3 and wb_pred_w_en_0 = '1' then
					carry_3_sel	<=	"001";
				end if;
									
				-- ALU	1 to ALU 3
				if wb_addr_pred_1 = scond_3 and wb_pred_w_en_1 = '1' then
					carry_3_sel	<=	"010";
				end if;
				
				-- ALU	2 to ALU 3
				if wb_addr_pred_2 = scond_3 and wb_pred_w_en_2 = '1' then
					carry_3_sel	<=	"011";
				end if;			
							
				-- ALU	3 to ALU 3
				if wb_addr_pred_3 = scond_3 and wb_pred_w_en_3 = '1' then
					carry_3_sel	<=	"100";
				end if;
					
			end if;
		end if;
	end process;
	

	-- Forward logic ALU to ALU: there is no forward logic from MUL_DIV and LD_ST.
   -- such forward logic implies another stall cycle on those units due register "setup	"
	-- better solution is interlock logic, stalls only when there is data dependency
	process	(clk, reset, wb_addr_reg_0 , rd_ctrl_src_0_a, rd_ctrl_src_0_b, wb_reg_w_en_0, 
											wb_addr_reg_1 , rd_ctrl_src_1_a, rd_ctrl_src_1_b, wb_reg_w_en_1, 
											wb_addr_reg_2 , rd_ctrl_src_2_a, rd_ctrl_src_2_b, wb_reg_w_en_2, 
											wb_addr_reg_3 , rd_ctrl_src_3_a, rd_ctrl_src_3_b, wb_reg_w_en_3,
											ex_stall, branch_en)
	begin
		if reset = '1' then
			alu_0_sel_1	<=	"0000";
			alu_0_sel_2	<=	"0000";
			
			alu_1_sel_1	<=	"0000";
			alu_1_sel_2	<=	"0000";
			
			alu_2_sel_1	<=	"0000";
			alu_2_sel_2	<=	"0000";			
			
			alu_3_sel_1	<=	"0000";
			alu_3_sel_2	<=	"0000";
		else
			if rising_edge(clk) and ex_stall = '0' then
					
				alu_0_sel_1	<=	"0000";
				alu_0_sel_2	<=	"0000";
				
				alu_1_sel_1	<=	"0000";
				alu_1_sel_2	<=	"0000";
				
				alu_2_sel_1	<=	"0000";
				alu_2_sel_2	<=	"0000";
			
				alu_3_sel_1	<=	"0000";
				alu_3_sel_2	<=	"0000";
			
				-- ALU	0 to ALU 0
				if wb_addr_reg_0 = rd_ctrl_src_0_a and wb_reg_w_en_0 = '1' and branch_en = '0' then
					alu_0_sel_1	<=	"0001";
				end if;
			
				if wb_addr_reg_0 =rd_ctrl_src_0_b and wb_reg_w_en_0 = '1' and branch_en = '0' then
					alu_0_sel_2	<=	"0001";
				end if;
				
				-- ALU	1 to ALU 0
				if wb_addr_reg_1 = rd_ctrl_src_0_a and wb_reg_w_en_1 = '1' then
					alu_0_sel_1	<=	"0010";
				end if;
			
				if wb_addr_reg_1 =rd_ctrl_src_0_b and wb_reg_w_en_1 = '1' then
					alu_0_sel_2	<=	"0010";
				end if;
				
				-- ALU	2 to ALU 0
				if wb_addr_reg_2 = rd_ctrl_src_0_a and wb_reg_w_en_2 = '1' then
					alu_0_sel_1	<=	"0011";
				end if;
			
				if wb_addr_reg_2 =rd_ctrl_src_0_b and wb_reg_w_en_2 = '1' then
					alu_0_sel_2	<=	"0011";
				end if;
				
				-- ALU	3 to ALU 0
				if wb_addr_reg_3 = rd_ctrl_src_0_a and wb_reg_w_en_3 = '1' then
					alu_0_sel_1	<=	"0100";
				end if;
			
				if wb_addr_reg_3 =rd_ctrl_src_0_b and wb_reg_w_en_3 = '1' then
					alu_0_sel_2	<=	"0100";
				end if;
							
--				-- memory	to ALU 0	
				--if (wb_addr_reg_0 = rd_ctrl_src_0_a or wb_addr_reg_1 = rd_ctrl_src_0_a) and wb_mem_rd = '1' then
				if (wb_addr_reg_0 = rd_ctrl_src_0_a) and wb_mem_rd_0 = '1' and branch_en = '0'then
					alu_0_sel_1	<=	"0101";
				end if;
			
				if (wb_addr_reg_0 =rd_ctrl_src_0_b) and wb_mem_rd_0 = '1' and branch_en = '0' then
				--if (wb_addr_reg_0 =rd_ctrl_src_0_b or wb_addr_reg_1 = rd_ctrl_src_0_b) and wb_mem_rd = '1' then
					alu_0_sel_2	<=	"0101";
				end if;		
				
				if (wb_addr_reg_1 = rd_ctrl_src_0_a) and wb_mem_rd_1 = '1' and branch_en = '0' then
					alu_0_sel_1	<=	"0110";
				end if;
			
				if (wb_addr_reg_1 =rd_ctrl_src_0_b) and wb_mem_rd_1 = '1' and branch_en = '0' then
				--if (wb_addr_reg_0 =rd_ctrl_src_0_b or wb_addr_reg_1 = rd_ctrl_src_0_b) and wb_mem_rd = '1' then
					alu_0_sel_2	<=	"0110";
				end if;	
			
				
				-- mul_div_0 to ALU 0
				if (wb_addr_reg_0 = rd_ctrl_src_0_a) and wb_mul_div_0 = '1' then
					alu_0_sel_1	<=	"0111";
				end if;
			
				if (wb_addr_reg_0 =rd_ctrl_src_0_b) and wb_mul_div_0 = '1' then
					alu_0_sel_2	<=	"0111";
				end if;		
--				
				-- mul_div_1 to ALU 0
				if (wb_addr_reg_1 = rd_ctrl_src_0_a) and wb_mul_div_1 = '1' then
					alu_0_sel_1	<=	"1000";
				end if;
			
				if (wb_addr_reg_1 =rd_ctrl_src_0_b) and wb_mul_div_1 = '1' then
					alu_0_sel_2	<=	"1000";
				end if;		
			
			----------------------------------------------				
			-- ALU	0	to ALU 1--
				if wb_addr_reg_0 = rd_ctrl_src_1_a and wb_reg_w_en_0= '1' then
					alu_1_sel_1	<=	"0001";
				end if;
			
				if wb_addr_reg_0 =rd_ctrl_src_1_b and wb_reg_w_en_0 = '1' then
					alu_1_sel_2	<=	"0001";
				end if;
	
				-- ALU	1	to ALU 1--
				if wb_addr_reg_1 = rd_ctrl_src_1_a and wb_reg_w_en_1= '1' then
					alu_1_sel_1	<=	"0010";
				end if;
			
				if wb_addr_reg_1 =rd_ctrl_src_1_b and wb_reg_w_en_1 = '1' then
					alu_1_sel_2	<=	"0010";
				end if;			
				
				-- ALU	2	to ALU 1--
				if wb_addr_reg_2 = rd_ctrl_src_1_a and wb_reg_w_en_2= '1' then
					alu_1_sel_1	<=	"0011";
				end if;
			
				if wb_addr_reg_2 =rd_ctrl_src_1_b and wb_reg_w_en_2 = '1' then
					alu_1_sel_2	<=	"0011";
				end if;
				
				-- ALU	3	to ALU 1--
				if wb_addr_reg_3 = rd_ctrl_src_1_a and wb_reg_w_en_3= '1' then
					alu_1_sel_1	<=	"0100"; --entity salu is";
				end if;
			
				if wb_addr_reg_3 =rd_ctrl_src_1_b and wb_reg_w_en_3 = '1' then
					alu_1_sel_2	<=	"0100";
				end if;
				
				-- memory	to ALU 1	
				if (wb_addr_reg_0 = rd_ctrl_src_1_a) and wb_mem_rd_0 = '1' then
					alu_1_sel_1	<=	"0101";
				end if;
			
				if (wb_addr_reg_0 =rd_ctrl_src_1_b ) and wb_mem_rd_0 = '1' then
					alu_1_sel_2	<=	"0101";
				end if;	
				
				if (wb_addr_reg_1 = rd_ctrl_src_1_a) and wb_mem_rd_1 = '1' then
					alu_1_sel_1	<=	"0110";
				end if;
			
				if (wb_addr_reg_1 =rd_ctrl_src_1_b ) and wb_mem_rd_1 = '1' then
					alu_1_sel_2	<=	"0110";
				end if;
				
--				
				-- mul_div_0 to ALU 1
				if (wb_addr_reg_0 = rd_ctrl_src_1_a) and wb_mul_div_0 = '1' then
					alu_1_sel_1	<=	"0111";
				end if;
			
				if (wb_addr_reg_0 =rd_ctrl_src_1_b) and wb_mul_div_0 = '1' then
					alu_1_sel_2	<=	"0111";
				end if;	
				
				-- mul_div_1 to ALU 1
				if (wb_addr_reg_1 = rd_ctrl_src_1_a) and wb_mul_div_1 = '1' then
					alu_1_sel_1	<=	"1000";
				end if;
			
				if (wb_addr_reg_1 =rd_ctrl_src_1_b) and wb_mul_div_1 = '1' then
					alu_1_sel_2	<=	"1000";
				end if;	
				
			----------------------------------------------				
				-- ALU	0 to ALU 2 
				if wb_addr_reg_0 = rd_ctrl_src_2_a and wb_reg_w_en_0= '1' then
					alu_2_sel_1	<=	"0001";
				end if;
			
				if wb_addr_reg_0 =rd_ctrl_src_2_b and wb_reg_w_en_0 = '1' then
					alu_2_sel_2	<=	"0001";
				end if;	
			
				-- ALU	1 to ALU 2 
				if wb_addr_reg_1 = rd_ctrl_src_2_a and wb_reg_w_en_1= '1' then
					alu_2_sel_1	<=	"0010";
				end if;
			
				if wb_addr_reg_1 =rd_ctrl_src_2_b and wb_reg_w_en_1 = '1' then
					alu_2_sel_2	<=	"0010";
				end if;					
				
				-- ALU	2 to ALU 2 
				if wb_addr_reg_2 = rd_ctrl_src_2_a and wb_reg_w_en_2= '1' then
					alu_2_sel_1	<=	"0011";
				end if;
			
				if wb_addr_reg_2 =rd_ctrl_src_2_b and wb_reg_w_en_2 = '1' then
					alu_2_sel_2	<=	"0011";
				end if;
				
				-- ALU	3 to ALU 2 
				if wb_addr_reg_3 = rd_ctrl_src_2_a and wb_reg_w_en_3= '1' then
					alu_2_sel_1	<=	"0100";
				end if;
			
				if wb_addr_reg_3 =rd_ctrl_src_2_b and wb_reg_w_en_3 = '1' then
					alu_2_sel_2	<=	"0100";
				end if;
				
--				-- memory	to ALU 2
				if (wb_addr_reg_0 = rd_ctrl_src_2_a ) and wb_mem_rd_0 = '1' then
					alu_2_sel_1	<=	"0101";
				end if;
			
				if (wb_addr_reg_0 =rd_ctrl_src_2_b) and wb_mem_rd_0 = '1' then
					alu_2_sel_2	<=	"0101";
				end if;	
				
				if (wb_addr_reg_1 = rd_ctrl_src_2_a ) and wb_mem_rd_1 = '1' then
					alu_2_sel_1	<=	"0110";
				end if;
			
				if (wb_addr_reg_1 =rd_ctrl_src_2_b) and wb_mem_rd_1 = '1' then
					alu_2_sel_2	<=	"0110";
				end if;	
				
				-- mul_div_0 to ALU 2
				if (wb_addr_reg_0 = rd_ctrl_src_2_a) and wb_mul_div_0 = '1' then
					alu_2_sel_1	<=	"0111";
				end if;
			
				if (wb_addr_reg_0 =rd_ctrl_src_2_b) and wb_mul_div_0 = '1' then
					alu_2_sel_2	<=	"0111";
				end if;	
				
					-- mul_div_1 to ALU 2
				if (wb_addr_reg_1 = rd_ctrl_src_2_a) and wb_mul_div_1 = '1' then
					alu_2_sel_1	<=	"1000";
				end if;
			
				if (wb_addr_reg_1 =rd_ctrl_src_2_b) and wb_mul_div_1 = '1' then
					alu_2_sel_2	<=	"1000";
				end if;	
		
			----------------------------------------------
				-- ALU	0 to ALU 3
				if wb_addr_reg_0 = rd_ctrl_src_3_a and wb_reg_w_en_0 = '1' then
					alu_3_sel_1	<=	"0001";
				end if;
			
				if wb_addr_reg_0 =rd_ctrl_src_3_b and wb_reg_w_en_0 = '1' then
					alu_3_sel_2	<=	"0001";
				end if;
				
				-- ALU	1 to ALU 3
				if wb_addr_reg_1 = rd_ctrl_src_3_a and wb_reg_w_en_1= '1' then
					alu_3_sel_1	<=	"0010";
				end if;
			
				if wb_addr_reg_1 =rd_ctrl_src_3_b and wb_reg_w_en_1 = '1' then
					alu_3_sel_2	<=	"0010";
				end if;
				
				-- ALU	2 to ALU 3
				if wb_addr_reg_2 = rd_ctrl_src_3_a and wb_reg_w_en_2= '1' then
					alu_3_sel_1	<=	"0011";
				end if;
			
				if wb_addr_reg_2 =rd_ctrl_src_3_b and wb_reg_w_en_2 = '1' then
					alu_3_sel_2	<=	"0011";
				end if;
	
				-- ALU	3 to ALU 3
				if wb_addr_reg_3 = rd_ctrl_src_3_a and wb_reg_w_en_3= '1' then
					alu_3_sel_1	<=	"0100";
				end if;
			
				if wb_addr_reg_3 =rd_ctrl_src_3_b and wb_reg_w_en_3 = '1' then
					alu_3_sel_2	<=	"0100";
				end if;
				
				-- memory	to ALU 3
				if (wb_addr_reg_0 = rd_ctrl_src_3_a ) and wb_mem_rd_0 = '1' then
					alu_3_sel_1	<=	"0101";
				end if;
			
				if (wb_addr_reg_0 =rd_ctrl_src_3_b ) and wb_mem_rd_0 = '1' then
					alu_3_sel_2	<=	"0101";
				end if;	
				
				-- memory	to ALU 3
				if (wb_addr_reg_1 = rd_ctrl_src_3_a ) and wb_mem_rd_1 = '1' then
					alu_3_sel_1	<=	"0110";
				end if;
			
				if (wb_addr_reg_1 =rd_ctrl_src_3_b ) and wb_mem_rd_1 = '1' then
					alu_3_sel_2	<=	"0110";
				end if;	
				
				-- mul_div_0 to ALU 3
				if (wb_addr_reg_0 = rd_ctrl_src_3_a) and wb_mul_div_0 = '1' then
					alu_3_sel_1	<=	"0111";
				end if;
			
				if (wb_addr_reg_0 =rd_ctrl_src_3_b) and wb_mul_div_0 = '1' then
					alu_3_sel_2	<=	"0111";
				end if;	
				
				-- mul_div_1 to ALU 3
				if (wb_addr_reg_1 = rd_ctrl_src_3_a) and wb_mul_div_1 = '1' then
					alu_3_sel_1	<=	"1000";
				end if;
			
				if (wb_addr_reg_1 = rd_ctrl_src_3_b) and wb_mul_div_1 = '1' then
					alu_3_sel_2	<=	"1000";
				end if;	
				
							
			end if;
		end if;
end process;
				
		
	calc_0: process (clk, reset, func_0, alu_0_src_1, mux_src2_0_val, add_carry_val_0, carry_forw_0,
																  func_1, alu_1_src_1, mux_src2_1_val, add_carry_val_1, carry_forw_1,
																  func_2, alu_2_src_1, mux_src2_2_val, add_carry_val_2, carry_forw_2,
																  func_3, alu_3_src_1, mux_src2_3_val, add_carry_val_3, carry_forw_3,
																  ex_stall)	
		variable s1 : word_t;
		variable s2 : word_t;
		
		variable s3 : word_t;
		variable s4 : word_t;
		
		variable s5 : word_t;
		variable s6 : word_t;		
		
		variable s7 : word_t;
		variable s8 : word_t;		
		
	
	begin
		if reset = '1' then			
			alu_val_0.alu_val 	<=  (alu_val_0.alu_val'range => '0');
			alu_val_0.carry_cmp <= '0';
			
			alu_val_1.alu_val 	<=  (alu_val_1.alu_val'range => '0');
			alu_val_1.carry_cmp <= '0';
			
			alu_val_2.alu_val 	<=  (alu_val_2.alu_val'range => '0');
			alu_val_2.carry_cmp <= '0';
			
			alu_val_3.alu_val 	<=  (alu_val_2.alu_val'range => '0');
			alu_val_3.carry_cmp <= '0';
			
		else			
			if rising_edge(clk) and ex_stall = '0'  then						

				s1 := alu_0_src_1;	
				s2 := mux_src2_0_val;

				s3 := alu_1_src_1;				
				s4 := mux_src2_1_val;
				
				s5 := alu_2_src_1;				
				s6 := mux_src2_2_val;
				
				s7 := alu_3_src_1;				
				s8 := mux_src2_3_val;
				
				--alu_val_0.carry_cmp <= '0';
				
				
				case func_0 is
					when ALU_ADD => 
						alu_val_0.alu_val <= s1 +s2;
						--	alu_val_0.alu_val <= add_carry_val_0;
						alu_val_0.carry_cmp <= '0';
					when ALU_SUB =>
						alu_val_0.alu_val <= s2 - s1;
						--alu_val_0.alu_val 	<= add_carry_val_0;
						--alu_val_0.carry_cmp <= '0';
					when ALU_SHL => 
						alu_val_0.alu_val <= SHL(s1, s2(4 downto 0));
						--alu_val_0.alu_val <=	l_shift_0_val;
					when ALU_SHR => 
						alu_val_0.alu_val <= SHR(s1, s2(4 downto 0));						
					when ALU_SHRU =>
						-- look in alu_functions
						alu_val_0.alu_val <= SHRU(s1, s2);
						--alu_val_0.alu_val <=	l_shift_0_val;

--					when ALU_SH1ADD =>
--						alu_val_0.alu_val <= SHL(s1, "001") + s2;
--					when ALU_SH2ADD =>
--						alu_val_0.alu_val <= SHL(s1, "010") + s2;
--					when ALU_SH3ADD =>
--						alu_val_0.alu_val <= SHL(s1, "011") + s2;
--					when ALU_SH4ADD =>
--						alu_val_0.alu_val <= SHL(s1, "100") + s2;

					when ALU_AND =>
						--alu_val_0.alu_val <= s1 and s2;
						alu_val_0.alu_val <= alu_0_and;
				
					when ALU_ANDC =>
						--alu_val_0.alu_val <= (not s1) and s2;
						alu_val_0.alu_val <= alu_0_andc;
					when ALU_OR =>
						--alu_val_0.alu_val <= s1 or s2;
						alu_val_0.alu_val <= alu_0_or;
					when ALU_ORC =>
						--alu_val_0.alu_val <= (not s1) or s2;
						alu_val_0.alu_val <= alu_0_orc;
						
					when ALU_XOR =>
						--alu_val_0.alu_val <= s1 xor s2;						
						alu_val_0.alu_val <= alu_0_xor;
						
--					when ALU_MAX =>
--						if s1 > s2 then
--							alu_val_0.alu_val <= s1;
--						else
--							alu_val_0.alu_val <= s2;
--						end if;
--						
--					when ALU_MAXU =>
--						alu_val_0.alu_val <= MAXU(s1, s2);
--					
--					when ALU_MIN =>
--						if s1 < s2 then
--							alu_val_0.alu_val <= s1;
--						else
--							alu_val_0.alu_val <= s2;
--						end if;
--						
--					when ALU_MINU =>
--						alu_val_0.alu_val <= MINU(s1, s2);
					
					when ALU_SXTB =>
						if s1(7) = '1' then
							alu_val_0.alu_val <= x"FFFFFF" & s1(7 downto 0);
						else
							alu_val_0.alu_val <= s1;
						end if;
					
					when ALU_SXTH =>
						if s1(15) = '1' then
							alu_val_0.alu_val <= x"FFFF" & s1(15 downto 0);
						else
							alu_val_0.alu_val <= s1;
						end if;
					
					when ALU_ZXTB =>
						alu_val_0.alu_val <= x"000000" & s1(7 downto 0);
					
					when ALU_ZXTH =>
						alu_val_0.alu_val <= x"0000" & s1(15 downto 0);
											
					when ALU_ADDCG => 
						alu_val_0.alu_val <= add_carry_val_0;
						alu_val_0.carry_cmp <= carry_out_0;	
					
					when ALU_SUBCG => 
						alu_val_0.alu_val <= add_carry_val_0;
						alu_val_0.carry_cmp <= carry_out_0;	
					
					when ALU_CMPEQ  => 
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & aeb_0;
						alu_val_0.carry_cmp <= aeb_0; 
				
--						if s1 = s2 then
--							alu_val_0.alu_val	 	<= x"00000001";
--							alu_val_0.carry_cmp 	<= '1';
--						else
--							alu_val_0.alu_val 		<= x"00000000";
--							alu_val_0.carry_cmp 	<= '0';
--						end if;
						
					when ALU_CMPGE  => 
					
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & ageb_0;
						alu_val_0.carry_cmp <= ageb_0; 
						
--						if s1 >= s2 then
--							alu_val_0.alu_val	 	<= x"00000001";
--							alu_val_0.carry_cmp 	<= '1';
--						else
--							alu_val_0.alu_val 		<= x"00000000";
--							alu_val_0.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPGEU  => 
					
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & agebu_0;
						alu_val_0.carry_cmp <= agebu_0; 
					
--						if CMPGEU(s1,s2) then
--							alu_val_0.alu_val	 	<= x"00000001";
--							alu_val_0.carry_cmp 	<= '1';
--						else
--							alu_val_0.alu_val 		<= x"00000000";
--							alu_val_0.carry_cmp 	<= '0';
--						end if;	
					
					
					when ALU_CMPGT  => 
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & agb_0;
						alu_val_0.carry_cmp <= agb_0; 
					
				
--						if s1 > s2 then
--							alu_val_0.alu_val	 	<= x"00000001";
--							alu_val_0.carry_cmp 	<= '1';
--						else
--							alu_val_0.alu_val 		<= x"00000000";
--							alu_val_0.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPGTU  => 
					
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & agbu_0;
						alu_val_0.carry_cmp <= agbu_0; 
					
--						if CMPGTU(s1,s2) then
--							alu_val_0.alu_val	 	<= x"00000001";
--							alu_val_0.carry_cmp 	<= '1';
--						else
--							alu_val_0.alu_val 		<= x"00000000";
--							alu_val_0.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPLE  => 
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & aleb_0;
						alu_val_0.carry_cmp <= aleb_0; 
					
--						if s1 <= s2 then
--							alu_val_0.alu_val	 	<= x"00000001";
--							alu_val_0.carry_cmp 	<= '1';
--						else
--							alu_val_0.alu_val 		<= x"00000000";
--							alu_val_0.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPLEU  => 
					
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & alebu_0;
						alu_val_0.carry_cmp <= alebu_0; 
						
--						if CMPLEU(s1,s2) then
--							alu_val_0.alu_val	 	<= x"00000001";
--							alu_val_0.carry_cmp 	<= '1';
--						else
--							alu_val_0.alu_val 		<= x"00000000";
--							alu_val_0.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPLT  => 
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & alb_0;
						alu_val_0.carry_cmp <= alb_0; 
					
					
--						if s1 < s2 then
--							alu_val_0.alu_val	 	<= x"00000001";
--							alu_val_0.carry_cmp 	<= '1';
--						else
--							alu_val_0.alu_val 		<= x"00000000";
--							alu_val_0.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPLTU  => 
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & albu_0;
						alu_val_0.carry_cmp <= albu_0; 
					
				
					
					when ALU_CMPNE  => 
						alu_val_0.alu_val       <= "0000000000000000000000000000000" & aneb_0;
						alu_val_0.carry_cmp <= aneb_0; 

	
--						if s1 /= s2 then
--							alu_val_0.alu_val	 	<= x"00000001";
--							alu_val_0.carry_cmp 	<= '1';
--						else
--							alu_val_0.alu_val 		<= x"00000000";
--							alu_val_0.carry_cmp 	<= '0';
--						end if;
					
--					when ALU_ANDL  => 
--						
--						alu_val_0.alu_val 		<= "0000000000000000000000000000000" & (s1(0) and s2(0));
--						alu_val_0.carry_cmp 	<= s1(0) and s2(0);
--					
--					when ALU_NANDL  => 
--						
--						alu_val_0.alu_val 		<= "0000000000000000000000000000000" & (s1(0) nand s2(0));
--						alu_val_0.carry_cmp 	<= s1(0) nand s2(0);
--										
--					when ALU_NORL  => 	
--						alu_val_0.alu_val 		<= "0000000000000000000000000000000" & (s1(0) nor s2(0));
--						alu_val_0.carry_cmp 	<= s1(0) nor s2(0);
				
					when ALU_ORL  => 	
						alu_val_0.alu_val 		<= "0000000000000000000000000000000" & (s1(0) or s2(0));
						alu_val_0.carry_cmp 	<= s1(0) or s2(0);				
					
					
					when ALU_SLCT => 
						alu_val_0.carry_cmp 	<= '0';
						
						if carry_forw_0 = '1' then
							alu_val_0.alu_val 		<= s1;							
						else
							alu_val_0.alu_val 		<= s2;
						end if;
						
					when ALU_SLCTF => 
						alu_val_0.carry_cmp 	<= '0';
						
						if carry_forw_0 = '0' then
							alu_val_0.alu_val 		<= s1;							
						else
							alu_val_0.alu_val 		<= s2;
						end if;	
						
				when others =>				
						
				end case;

				case func_1 is
					when ALU_ADD => 
						alu_val_1.alu_val <= s3 + s4;
						--alu_val_1.alu_val <= add_carry_val_1;
					when ALU_SUB =>
						alu_val_1.alu_val <= s4 - s3;
						--alu_val_1.alu_val <= add_carry_val_1;
					when ALU_SHL => 
						alu_val_1.alu_val <= SHL(s3, s4(4 downto 0));
						--alu_val_1.alu_val <=	l_shift_1_val;
						
					when ALU_SHR => 
						alu_val_1.alu_val <= SHR(s3, s4(4 downto 0));						
					
					when ALU_SHRU =>
						-- look in alu_functions						
						alu_val_1.alu_val <= SHRU(s3, s4);
						--alu_val_1.alu_val <=	l_shift_1_val;
						
--					when ALU_SH1ADD =>
--						alu_val_1.alu_val <= SHL(s3, "001") + s4;
--					when ALU_SH2ADD =>
--						alu_val_1.alu_val <= SHL(s3, "010") + s4;
--					when ALU_SH3ADD =>
--						alu_val_1.alu_val <= SHL(s3, "011") + s4;
--					when ALU_SH4ADD =>
--						alu_val_1.alu_val <= SHL(s3, "100") + s4;
					when ALU_AND =>
						alu_val_1.alu_val <= s3 and s4;
						--alu_val_1.alu_val <= alu_1_and;
				
					when ALU_ANDC =>
						alu_val_1.alu_val <= (not s3) and s4;
						--alu_val_1.alu_val <= alu_1_andc;
					when ALU_OR =>
						alu_val_1.alu_val <= s3 or s4;
						--alu_val_1.alu_val <= alu_1_or;
					when ALU_ORC =>
						alu_val_1.alu_val <= (not s3) or s4;
						--alu_val_1.alu_val <= alu_1_orc;
						
					when ALU_XOR =>
						alu_val_1.alu_val <= s3 xor s4;						
						--alu_val_1.alu_val <= alu_1_xor;
						
--					when ALU_MAX =>
--						if s3 > s4 then
--							alu_val_1.alu_val <= s3;
--						else
--							alu_val_1.alu_val <= s4;
--						end if;
--						
--					when ALU_MAXU =>
--						alu_val_1.alu_val <= MAXU(s3, s4);
--					
--					when ALU_MIN =>
--						if s3 < s4 then
--							alu_val_1.alu_val <= s3;
--						else
--							alu_val_1.alu_val <= s4;
--						end if;
--						
--					when ALU_MINU =>
--						alu_val_1.alu_val <= MINU(s3, s4);
					
					when ALU_SXTB =>
						if s3(7) = '1' then
							alu_val_1.alu_val <= x"FFFFFF" & s3(7 downto 0);
						else
							alu_val_1.alu_val <= s3;
						end if;
					
					when ALU_SXTH =>
						if s3(15) = '1' then
							alu_val_1.alu_val <= x"FFFF" & s3(15 downto 0);
						else
							alu_val_1.alu_val <= s3;
						end if;
					
					when ALU_ZXTB =>
						alu_val_1.alu_val <= x"000000" & s3(7 downto 0);
					
					when ALU_ZXTH =>
						alu_val_1.alu_val <= x"0000" & s3(15 downto 0);
											
					when ALU_ADDCG => 
						alu_val_1.alu_val <= add_carry_val_1;
						alu_val_1.carry_cmp <= carry_out_1;		
		
					when ALU_SUBCG => 
						alu_val_1.alu_val <= add_carry_val_1;
						alu_val_1.carry_cmp <= carry_out_1;			
					
					when ALU_CMPEQ  => 
					
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & aeb_1;
						alu_val_1.carry_cmp <= aeb_1; 
						
--						if s3 = s4 then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;
						
					when ALU_CMPGE  => 
					
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & ageb_1;
						alu_val_1.carry_cmp <= ageb_1; 
						
--						if s3 >= s4 then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPGEU  => 
					
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & agebu_1;
						alu_val_1.carry_cmp <= agebu_1; 
					
--						if CMPGEU(s3,s4) then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;	
					
					
					when ALU_CMPGT  => 
					
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & agb_1;
						alu_val_1.carry_cmp <= agb_1; 
					
--						if s3 > s4 then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPGTU  => 
					
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & agbu_1;
						alu_val_1.carry_cmp <= agbu_1; 
					
						
--						if CMPGTU(s3,s4) then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPLE  => 
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & aleb_1;
						alu_val_1.carry_cmp <= aleb_1; 
					
--						if s3 <= s4 then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPLEU  => 
					
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & alebu_1;
						alu_val_1.carry_cmp <= alebu_1; 
						
--						if CMPLEU(s3,s4) then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPLT  => 
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & alb_1;
						alu_val_1.carry_cmp <= alb_1; 
					
--						if s3 < s4 then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPLTU  => 
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & albu_1;
						alu_val_1.carry_cmp <= albu_1; 
					
--						if CMPLTU(s3,s4) then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPNE  => 
					
						alu_val_1.alu_val       <= "0000000000000000000000000000000" & aneb_1;
						alu_val_1.carry_cmp <= aneb_1; 
					
--						if s3 /= s4 then
--							alu_val_1.alu_val	 	<= x"00000001";
--							alu_val_1.carry_cmp 	<= '1';
--						else
--							alu_val_1.alu_val 		<= x"00000000";
--							alu_val_1.carry_cmp 	<= '0';
--						end if;
					
--					when ALU_ANDL  => 
--						
--						alu_val_1.alu_val 		<= "0000000000000000000000000000000" & (s3(0) and s4(0));
--						alu_val_1.carry_cmp 	<= s3(0) and s4(0);
--					
--					when ALU_NANDL  => 
--						
--						alu_val_1.alu_val 		<= "0000000000000000000000000000000" & (s3(0) nand s4(0));
--						alu_val_1.carry_cmp 	<= s3(0) nand s4(0);
--										
--					when ALU_NORL  => 	
--						alu_val_1.alu_val 		<= "0000000000000000000000000000000" & (s3(0) nor s4(0));
--						alu_val_1.carry_cmp 	<= s3(0) nor s4(0);
				
					when ALU_ORL  => 	
						alu_val_1.alu_val 		<= "0000000000000000000000000000000" & (s3(0) or s4(0));
						alu_val_1.carry_cmp 	<= s3(0) or s4(0);				
					
					
					when ALU_SLCT => 
						alu_val_1.carry_cmp 	<= '0';
						
						if carry_forw_1 = '1' then
							alu_val_1.alu_val 		<= s3;							
						else
							alu_val_1.alu_val 		<= s4;
						end if;
						
					when ALU_SLCTF => 
						alu_val_1.carry_cmp 	<= '0';
						
						if carry_forw_1 = '0' then
							alu_val_1.alu_val 		<= s3;							
						else
							alu_val_1.alu_val 		<= s4;
						end if;	
					
					when others =>						
				end case;					

				case func_2 is
					when ALU_ADD => 
						alu_val_2.alu_val <= s5 +s6;
						--alu_val_2.alu_val <= add_carry_val_2;
					when ALU_SUB =>
						alu_val_2.alu_val <= s6 - s5;
						--alu_val_1.alu_val <= add_carry_val_2;
					when ALU_SHL => 
						alu_val_2.alu_val <= SHL(s5, s6(4 downto 0));
						--alu_val_2.alu_val <=	l_shift_2_val;
					
					when ALU_SHR => 
						alu_val_2.alu_val <= SHR(s5, s6(4 downto 0));						
					
					when ALU_SHRU =>
						-- look in alu_functions
						alu_val_2.alu_val <= SHRU(s5, s6);
						--alu_val_2.alu_val <=	l_shift_2_val;
						
--					when ALU_SH1ADD =>
--						alu_val_2.alu_val <= SHL(s5, "001") + s6;
--					when ALU_SH2ADD =>
--						alu_val_2.alu_val <= SHL(s5, "010") + s6;
--					when ALU_SH3ADD =>
--						alu_val_2.alu_val <= SHL(s5, "011") + s6;
--					when ALU_SH4ADD =>
--						alu_val_2.alu_val <= SHL(s5, "100") + s6;

				when ALU_AND =>
						alu_val_2.alu_val <= s5 and s6;
						--alu_val_2.alu_val <= alu_2_and;
				
					when ALU_ANDC =>
						alu_val_2.alu_val <= (not s5) and s6;
						--alu_val_2.alu_val <= alu_2_andc;
					when ALU_OR =>
						alu_val_2.alu_val <= s5 or s6;
						--alu_val_2.alu_val <= alu_2_or;
					when ALU_ORC =>
						alu_val_2.alu_val <= (not s5) or s6;
						--alu_val_2.alu_val <= alu_2_orc;
						
					when ALU_XOR =>
						alu_val_2.alu_val <= s5 xor s6;						
						--alu_val_2.alu_val <= alu_2_xor;
--					when ALU_MAX =>
--						if s5 > s6 then
--							alu_val_2.alu_val <= s5;
--						else
--							alu_val_2.alu_val <= s6;
--						end if;
--						
--					when ALU_MAXU =>
--						alu_val_2.alu_val <= MAXU(s5, s6);
--					
--					when ALU_MIN =>
--						if s5 < s6 then
--							alu_val_2.alu_val <= s5;
--						else
--							alu_val_2.alu_val <= s6;
--						end if;
--						
--					when ALU_MINU =>
--						alu_val_2.alu_val <= MINU(s5, s6);
--					
--					when ALU_SXTB =>
--						if s5(7) = '1' then
--							alu_val_2.alu_val <= x"FFFFFF" & s5(7 downto 0);
--						else
--							alu_val_2.alu_val <= s5;
--						end if;
					
					when ALU_SXTH =>
						if s5(15) = '1' then
							alu_val_2.alu_val <= x"FFFF" & s5(15 downto 0);
						else
							alu_val_2.alu_val <= s5;
						end if;
					
					when ALU_ZXTB =>
						alu_val_2.alu_val <= x"000000" & s5(7 downto 0);
					
					when ALU_ZXTH =>
						alu_val_2.alu_val <= x"0000" & s5(15 downto 0);
											
					when ALU_ADDCG => 
						alu_val_2.alu_val <= add_carry_val_2;
						alu_val_2.carry_cmp <= carry_out_2;
					
					when ALU_SUBCG => 
						alu_val_2.alu_val <= add_carry_val_2;
						alu_val_2.carry_cmp <= carry_out_2;
					
					when ALU_CMPEQ  => 
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & aeb_2;
						alu_val_2.carry_cmp <= aeb_2; 
						
--						if s5 = s6 then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;
						
					when ALU_CMPGE  => 
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & ageb_2;
						alu_val_2.carry_cmp <= ageb_2; 
						
--						if s5 >= s6 then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPGEU  => 
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & agebu_2;
						alu_val_2.carry_cmp <= agebu_2; 
					
--						if CMPGEU(s5,s6) then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;	
					
					
					when ALU_CMPGT  => 
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & agb_2;
						alu_val_2.carry_cmp <= agb_2; 
					
--						if s5 > s6 then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPGTU  =>
				
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & agbu_2;
						alu_val_2.carry_cmp <= agbu_2; 
						
--						if CMPGTU(s5,s6) then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPLE  => 
					
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & aleb_2;
						alu_val_2.carry_cmp <= aleb_2; 
					
--						if s5 <= s6 then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPLEU  => 
					
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & alebu_2;
						alu_val_2.carry_cmp <= alebu_2; 
						
--						if CMPLEU(s5,s6) then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPLT  => 
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & alb_2;
						alu_val_2.carry_cmp <= alb_2; 
					
--						if s5 < s6 then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPLTU  => 
					
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & albu_2;
						alu_val_2.carry_cmp <= albu_2; 
					
					
--						if CMPLTU(s5,s6) then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPNE  => 
						alu_val_2.alu_val       <= "0000000000000000000000000000000" & aneb_2;
						alu_val_2.carry_cmp <= aneb_2; 
					
--						if s5 /= s6 then
--							alu_val_2.alu_val	 	<= x"00000001";
--							alu_val_2.carry_cmp 	<= '1';
--						else
--							alu_val_2.alu_val 		<= x"00000000";
--							alu_val_2.carry_cmp 	<= '0';
--						end if;
					
--					when ALU_ANDL  => 
--						
--						alu_val_2.alu_val 		<= "0000000000000000000000000000000" & (s5(0) and s6(0));
--						alu_val_2.carry_cmp 	<= s5(0) and s6(0);
--					
--					when ALU_NANDL  => 
--						
--						alu_val_2.alu_val 		<= "0000000000000000000000000000000" & (s5(0) nand s6(0));
--						alu_val_2.carry_cmp 	<= s5(0) nand s6(0);
--										
--					when ALU_NORL  => 	
--						alu_val_2.alu_val 		<= "0000000000000000000000000000000" & (s5(0) nor s6(0));
--						alu_val_2.carry_cmp 	<= s5(0) nor s6(0);
				
					when ALU_ORL  => 	
						alu_val_2.alu_val 		<= "0000000000000000000000000000000" & (s5(0) or s6(0));
						alu_val_2.carry_cmp 	<= s5(0) or s6(0);				
					
					
					when ALU_SLCT => 
						alu_val_2.carry_cmp 	<= '0';
						
						if carry_forw_2 = '1' then
							alu_val_2.alu_val 		<= s5;							
						else
							alu_val_2.alu_val 		<= s6;
						end if;
						
					when ALU_SLCTF => 
						alu_val_2.carry_cmp 	<= '0';
						
						if carry_forw_2 = '0' then
							alu_val_2.alu_val 		<= s5;							
						else
							alu_val_2.alu_val 		<= s6;
						end if;	
					
					when others =>
						
				end case;	
		
			case func_3 is
					when ALU_ADD => 
						alu_val_3.alu_val <= s7 + s8;
						--alu_val_3.alu_val <= add_carry_val_3;
					when ALU_SUB =>
						alu_val_3.alu_val <= s8 - s7;
						--alu_val_1.alu_val <= add_carry_val_3;
					when ALU_SHL => 
						alu_val_3.alu_val <= SHL(s7, s8(4 downto 0));
						--alu_val_3.alu_val <=	l_shift_3_val;
						
					when ALU_SHR => 
						alu_val_3.alu_val <= SHR(s7, s8(4 downto 0));						
					when ALU_SHRU =>
						-- look in alu_functions
						alu_val_3.alu_val <= SHRU(s7, s8);
						
						--alu_val_3.alu_val <=	l_shift_3_val;
						
--					when ALU_SH1ADD =>
--						alu_val_3.alu_val <= SHL(s7, "001") + s8;
--					when ALU_SH2ADD =>
--						alu_val_3.alu_val <= SHL(s7, "010") + s8;
--					when ALU_SH3ADD =>
--						alu_val_3.alu_val <= SHL(s7, "011") + s8;
--					when ALU_SH4ADD =>
--						alu_val_3.alu_val <= SHL(s7, "100") + s8;
					when ALU_AND =>
						--alu_val_3.alu_val <= s7 and s8;
						alu_val_3.alu_val  <= alu_3_and;					
					when ALU_ANDC =>
						--alu_val_3.alu_val <= (not s7) and s8;
						alu_val_3.alu_val <= alu_3_andc;
					when ALU_OR =>
						--alu_val_3.alu_val <= s7 or s8;
						alu_val_3.alu_val <= alu_3_or;
					when ALU_ORC =>											
						--alu_val_3.alu_val <= (not s7) or s8;
						alu_val_3.alu_val <= alu_3_orc;
					when ALU_XOR =>
						--alu_val_3.alu_val <= s7 xor s8;
						alu_val_3.alu_val <= alu_3_xor;
						
--					when ALU_MAX =>
--						if s7 > s8 then
--							alu_val_3.alu_val <= s7;
--						else
--							alu_val_3.alu_val <= s8;
--						end if;
--						
--					when ALU_MAXU =>
--						alu_val_3.alu_val <= MAXU(s7, s8);
--					
--					when ALU_MIN =>
--						if s7 < s8 then
--							alu_val_3.alu_val <= s7;
--						else
--							alu_val_3.alu_val <= s8;
--						end if;
--						
--					when ALU_MINU =>
--						alu_val_3.alu_val <= MINU(s7, s8);
					
					when ALU_SXTB =>
						if s7(7) = '1' then
							alu_val_3.alu_val <= x"FFFFFF" & s7(7 downto 0);
						else
							alu_val_3.alu_val <= s7;
						end if;
					
					when ALU_SXTH =>
						if s7(15) = '1' then
							alu_val_3.alu_val <= x"FFFF" & s7(15 downto 0);
						else
							alu_val_3.alu_val <= s7;
						end if;
					
					when ALU_ZXTB =>
						alu_val_3.alu_val <= x"000000" & s7(7 downto 0);
					
					when ALU_ZXTH =>
						alu_val_3.alu_val <= x"0000" & s7(15 downto 0);
											
					when ALU_ADDCG => 
						alu_val_3.alu_val <= add_carry_val_3;
						alu_val_3.carry_cmp <= carry_out_3;						
					
					when ALU_SUBCG => 
						alu_val_3.alu_val <= add_carry_val_3;
						alu_val_3.carry_cmp <= carry_out_3;	
					
					when ALU_CMPEQ  => 
					
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & aeb_3;
						alu_val_3.carry_cmp <= aeb_3; 
						
--						if s7 = s8 then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;
						
					when ALU_CMPGE  => 
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & ageb_3;
						alu_val_3.carry_cmp <= ageb_3; 
						
--						if s7 >= s8 then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPGEU  => 
					
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & agebu_3;
						alu_val_3.carry_cmp <= agebu_3; 
					
--						if CMPGEU(s7,s8) then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;	
					
					
					when ALU_CMPGT  => 
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & agb_3;
						alu_val_3.carry_cmp <= agb_3; 
					
--						if s7 > s8 then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPGTU  => 
					
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & agbu_3;
						alu_val_3.carry_cmp <= agbu_3; 
						
--						if CMPGTU(s7,s8) then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPLE  => 
					
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & aleb_3;
						alu_val_3.carry_cmp <= aleb_3; 
					
--						if s7 <= s8 then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPLEU  => 
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & alebu_3;
						alu_val_3.carry_cmp <= alebu_3; 
						
--						if CMPLEU(s7,s8) then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPLT  => 
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & alb_3;
						alu_val_3.carry_cmp <= alb_3; 
					
--						if s7 < s8 then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;
					
					when ALU_CMPLTU  => 
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & albu_3;
						alu_val_3.carry_cmp <= albu_3; 
						
					
--						if CMPLTU(s7,s8) then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;	
					
					when ALU_CMPNE  => 
						alu_val_3.alu_val       <= "0000000000000000000000000000000" & aneb_3;
						alu_val_3.carry_cmp <= aneb_3; 
					
--						if s7 /= s8 then
--							alu_val_3.alu_val	 	<= x"00000001";
--							alu_val_3.carry_cmp 	<= '1';
--						else
--							alu_val_3.alu_val 		<= x"00000000";
--							alu_val_3.carry_cmp 	<= '0';
--						end if;
					
--					when ALU_ANDL  => 
--						
--						alu_val_3.alu_val 		<= "0000000000000000000000000000000" & (s7(0) and s8(0));
--						alu_val_3.carry_cmp 	<= s7(0) and s8(0);
--					
--					when ALU_NANDL  => 
--						
--						alu_val_3.alu_val 		<= "0000000000000000000000000000000" & (s7(0) nand s8(0));
--						alu_val_3.carry_cmp 	<= s7(0) nand s8(0);
--										
--					when ALU_NORL  => 	
--						alu_val_3.alu_val 		<= "0000000000000000000000000000000" & (s7(0) nor s8(0));
--						alu_val_3.carry_cmp 	<= s7(0) nor s8(0);
				
					when ALU_ORL  => 	
						alu_val_3.alu_val 		<= "0000000000000000000000000000000" & (s7(0) or s8(0));
						alu_val_3.carry_cmp 	<= s7(0) or s8(0);				
					
					
					when ALU_SLCT => 
						alu_val_3.carry_cmp 	<= '0';
						
						if carry_forw_3 = '1' then
							alu_val_3.alu_val 		<= s7;							
						else
							alu_val_3.alu_val 		<= s8;
						end if;
						
					when ALU_SLCTF => 
						alu_val_3.carry_cmp 	<= '0';
						
						if carry_forw_3 = '0' then
							alu_val_3.alu_val 		<= s7;							
						else
							alu_val_3.alu_val 		<= s8;
						end if;	
	
					when others =>
						
				end case;							
				
				
			end if;	
		end if;	
	end process;
		
	
	mux_forward_0_src1: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src1_in_0,					-- read from register file
		data1x		=> alu_val_0.alu_val,	-- forward from alu 0
		data2x		=> alu_val_1.alu_val,	-- forward from alu 1
		data3x		=> alu_val_2.alu_val,	 -- forward from alu 2
		data4x		=> alu_val_3.alu_val,	-- forward from alu 3
		data5x		=> memory_data,
		data6x		=> memory_data_1,
		data7x		=> mul_div_0_data,
		data8x		=> mul_div_1_data,
		sel			=> alu_0_sel_1,
		result		=> alu_0_src_1
	);
	
	mux_forward_0_src2: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src2_in_0,					-- read from register file
		data1x		=> alu_val_0.alu_val,	-- forward from alu 0
		data2x		=> alu_val_1.alu_val,	-- forward from alu 1
		data3x		=> alu_val_2.alu_val,	-- forward from alu 2
		data4x		=> alu_val_3.alu_val,	-- forward from alu 3
		data5x		=> memory_data,
		data6x		=> memory_data_1,
		data7x		=> mul_div_0_data,
		data8x		=> mul_div_1_data,
		sel			=> alu_0_sel_2,
		result		=> alu_0_src_2
	);	
			
	mux_src2_0: mux_0 port map
	(
		data0x		=> alu_0_src_2, 			--ex_reg_src2_0,
		data1x		=> imm_0,
		sel					=> src_2_sel_0,
		result			=> mux_src2_0_val
	);	
	
	mux_forward_1_src1: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src1_in_1,					-- read from register file
		data1x		=> alu_val_0.alu_val,	-- forward from alu 0
		data2x		=> alu_val_1.alu_val,	-- forward from alu 1
		data3x		=> alu_val_2.alu_val,				-- forward from alu 2
		data4x		=> alu_val_3.alu_val,	-- forward from alu 3
		data5x		=> memory_data,
		data6x		=> memory_data_1,
		data7x		=> mul_div_0_data,
		data8x		=> mul_div_1_data,
		sel					=> alu_1_sel_1,
		result		=> alu_1_src_1
	);
	
	mux_forward_1_src2: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src2_in_1,					-- read from register file
		data1x		=> alu_val_0.alu_val,	-- forward from alu 0
		data2x		=> alu_val_1.alu_val,	-- forward from alu 1
		data3x		=> alu_val_2.alu_val,			-- forward from alu 2
		data4x		=> alu_val_3.alu_val,			-- forward from alu 3
		data5x		=> memory_data,
		data6x		=> memory_data_1,
		data7x		=> mul_div_0_data,
		data8x		=> mul_div_1_data,
		sel					=> alu_1_sel_2,
		result		=> alu_1_src_2
	);	
			
	mux_src2_1: mux_0 port map
	(
		data0x		=> alu_1_src_2, 			--ex_reg_src2_0,
		data1x		=> imm_1,
		sel					=> src_2_sel_1,
		result			=> mux_src2_1_val
	);	

	mux_forward_2_src1: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src1_in_2,					-- read from register file
		data1x		=> alu_val_0.alu_val,	-- forward from alu 0
		data2x		=> alu_val_1.alu_val,	-- forward from alu 1
		data3x		=> alu_val_2.alu_val,	-- forward from alu 2
		data4x		=> alu_val_3.alu_val,	-- forward from alu 3
		data5x		=> memory_data,
		data6x		=> memory_data_1,
		data7x		=> mul_div_0_data,
		data8x		=> mul_div_1_data,
		sel					=> alu_2_sel_1,
		result			=> alu_2_src_1
	);
	
	mux_forward_2_src2: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src2_in_2,					-- read from register file
		data1x		=> alu_val_0.alu_val,	-- forward from alu 0
		data2x		=> alu_val_1.alu_val,	-- forward from alu 1
		data3x		=> alu_val_2.alu_val,	-- forward from alu 2
		data4x		=> alu_val_3.alu_val,	-- forward from alu 3
		data5x		=> memory_data,
		data6x		=> memory_data_1,
		data7x		=> mul_div_0_data,
		data8x		=> mul_div_1_data,
		sel					=> alu_2_sel_2,
		result		=> alu_2_src_2
	);	
			
	mux_src2_2: mux_0 port map
	(
		data0x		=> alu_2_src_2, 			--ex_reg_src2_0,
		data1x		=> imm_2,
		sel					=> src_2_sel_2,
		result			=> mux_src2_2_val
	);
	
	----------------- Forward logic for ALU 3 ------------------------------------------------------------------------

	mux_forward_3_src1: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src1_in_3,					-- read from register file
		data1x		=> alu_val_0.alu_val,	-- forward from alu 0
		data2x		=> alu_val_1.alu_val,	-- forward from alu 1
		data3x		=> alu_val_2.alu_val,	-- forward from alu 2
		data4x		=> alu_val_3.alu_val,	-- forward from alu 3
		data5x		=> memory_data,
		data6x		=> memory_data_1,
		data7x		=> mul_div_0_data,
		data8x		=> mul_div_1_data,
		sel			=> alu_3_sel_1,
		result		=> alu_3_src_1
	);
	
	mux_forward_3_src2: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src2_in_3,					-- read from register file
		data1x		=> alu_val_0.alu_val,	-- forward from alu 0
		data2x		=> alu_val_1.alu_val,	-- forward from alu 1
		data3x		=> alu_val_2.alu_val,	-- forward from alu 2
		data4x		=> alu_val_3.alu_val,	-- forward from alu 3
		data5x		=> memory_data,
		data6x		=> memory_data_1,
		data7x		=> mul_div_0_data,
		data8x		=> mul_div_1_data,
		sel			=> alu_3_sel_2,
		result		=> alu_3_src_2
	);	
			
	mux_src2_3: mux_0 port map
	(
		data0x		=> alu_3_src_2, 			--ex_reg_src2_0,
		data1x		=> imm_3,
		sel					=> src_2_sel_3,
		result			=> mux_src2_3_val
	);
	
	----------------- Output results ------------------------------------------------------------------------
	
	alu_out_0 <= alu_val_0;
	alu_out_1 <= alu_val_1;
	alu_out_2 <= alu_val_2;
	alu_out_3 <= alu_val_3;
	
	----------------------------------------------------------------------------------------------------------------

end rtl;