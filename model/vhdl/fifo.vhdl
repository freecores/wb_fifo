/*
	This file is part of the Memories project:
		http://opencores.org/project,wb_fifo
		
	Description
	FIFO memory model.
	
	To Do: 
	
	Author(s): 
	- Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
	
	Copyright (C) 2012-2013 Authors and OPENCORES.ORG.
	
	This source file may be used and distributed without 
	restriction provided that this copyright statement is not 
	removed from the file and that any derivative work contains 
	the original copyright notice and the associated disclaimer.
	
	This source file is free software; you can redistribute it 
	and/or modify it under the terms of the GNU Lesser General 
	Public License as published by the Free Software Foundation; 
	either version 2.1 of the License, or (at your option) any 
	later version.
	
	This source is distributed in the hope that it will be 
	useful, but WITHOUT ANY WARRANTY; without even the implied 
	warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
	PURPOSE. See the GNU Lesser General Public License for more 
	details.
	
	You should have received a copy of the GNU Lesser General 
	Public License along with this source; if not, download it 
	from http://www.opencores.org/lgpl.shtml.
*/
library ieee; use ieee.std_logic_1164.all, ieee.numeric_std.all;
library tauhop;
--package fifoTypes is new tauhop.types generic map(t_data=>unsigned(31 downto 0));
use tauhop.fifoTransactor.all;

--library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
--library tauhop; use tauhop.fifoTypes.all;
entity fifo is
	generic(memoryDepth:positive);
	port(clk,reset:in std_ulogic;
		fifoInterface:inout t_fifoTransactor
	);
end entity fifo;

architecture rtl of fifo is
	type t_memory is array(memoryDepth-1 downto 0) of i_transactor.t_msg;
	signal memory:t_memory;
	signal ptr:natural range 0 to memoryDepth-1;
	
	signal i_writeRequest,i_readRequest:i_transactor.t_bfm;
	signal write,read:boolean;
begin
	controller: process(reset,clk) is begin
		if reset then fifoInterface.readResponse.message<=(others=>'Z');
		elsif falling_edge(clk) then
			if fifoInterface.writeRequest.trigger xor i_writeRequest.trigger then
				memory(ptr)<=fifoInterface.writeRequest.message;
			end if;
			
			if fifoInterface.readRequest.trigger xor i_readRequest.trigger then
				fifoInterface.readResponse.message<=memory(ptr);
			end if;
			
		end if;
	end process controller;
	
	write<=fifoInterface.writeRequest.trigger xor i_writeRequest.trigger;
	read<=fifoInterface.readRequest.trigger xor i_readRequest.trigger;
	
	addrPointer: process(reset,clk) is begin
		if reset then ptr<=0;
		elsif falling_edge(clk) then
			/* Increment or decrement the address pointer only when write or read is HIGH;
				do nothing when both are HIGH or when both are LOW.
			*/
			if write xor read then
				if write then
					if ptr<memoryDepth-1 then ptr<=ptr+1; end if;
				end if;
				if read then
					if ptr>0 then ptr<=ptr-1; end if;
				end if;
			end if;
		end if;
	end process addrPointer;
	
	/* Registers and pipelines. */
	process(clk) is begin
		i_writeRequest<=fifoInterface.writeRequest;
		i_readRequest<=fifoInterface.readRequest;
	end process;
	
	fifoInterface.pctFilled<=to_unsigned(ptr*100/(memoryDepth-1), fifoInterface.pctFilled'length);
	
	process(clk) is begin
		if rising_edge(clk) then
			fifoInterface.nearFull<=true when fifoInterface.pctFilled>=d"75" and fifoInterface.pctFilled<d"100" else false;
			fifoInterface.full<=true when fifoInterface.pctFilled=d"100" else false;
			fifoInterface.nearEmpty<=true when fifoInterface.pctFilled<=d"25" and fifoInterface.pctFilled>d"0" else false;
			fifoInterface.empty<=true when fifoInterface.pctFilled=d"0" else false;
		end if;
	end process;
	
	process(clk) is begin
		if falling_edge(clk) then
			fifoInterface.overflow<=fifoInterface.full and write;
			fifoInterface.underflow<=fifoInterface.empty and read;
		end if;
	end process;
end architecture rtl;
