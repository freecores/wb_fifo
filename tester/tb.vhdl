/*
	This file is part of the Memories project:
		http://www.opencores.org/project,wb_fifo
		
	Description
	Testbench for generic FIFO project.
	
	To Do: 
	
	Author(s): 
	- Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
	
	Copyright (C) 2012-2013 Authors and OPENCORES.ORG
	
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
--library tauhop; use tauhop.fifoTypes.all;
library tauhop; use tauhop.fifoTransactor.all;
library osvvm; use osvvm.RandomPkg.all;
entity testbench is end entity testbench;

architecture simulation of testbench is
	constant period:time:=10 ps;
	constant memoryDepth:positive:=16;
	signal reset,clk:std_ulogic:='0';
	--signal write,read:boolean;
	--signal d,q:t_data;
	
	/* BFM signalling. */
	--signal readRequest,writeRequest:i_transactor.t_bfm;
	signal fifoInterface:t_fifoTransactor;
begin
	--duv: entity tauhop.fifo(rtl) generic map(memoryDepth=>memoryDepth) port map(clk=>clk, reset=>reset, write=>write, read=>read, d=>d, q=>q);
	duv: entity tauhop.fifo(rtl) generic map(memoryDepth=>memoryDepth) port map(clk=>clk, reset=>reset, fifoInterface=>fifoInterface);
	
	clk<=not clk after period/2;

	process is begin
		reset<='1';
--		fifoInterface.write<=false;
		wait for 30 ps;
		
		reset<='0';
		wait until falling_edge(clk);
		
--		fifoInterface.write<=true;
		wait for memoryDepth*period;
		
--		fifoInterface.write<=false;
		wait;
	end process;
	
	/* Read operation. */
/*	process is begin
		fifoInterface.read<=false;
		wait for 50 ps;
		fifoInterface.read<=true;
		wait;
	end process;
*/	
	/* Write operation. */
	process(reset,clk) is
		/* Local procedures to map BFM signals with the package procedure. */
        --procedure read(address:in i_transactor.t_addr) is begin
        procedure read is begin
            i_transactor.read(request=>fifoInterface.readRequest, address=>(others=>'-'));
        end procedure read;
		
		procedure write(data:in i_transactor.t_msg) is begin
			i_transactor.write(request=>fifoInterface.writeRequest, address=>(others=>'-'), data=>data);
		end procedure write;

		variable rv:RandomPType;
		variable cnt:unsigned(7 downto 0);
	begin
		if reset then
			rv.InitSeed(rv'instance_name);
			cnt:=(others=>'0');
		elsif rising_edge(clk) then
		/*	if fifoInterface.write then
				--fifoInterface.d<=rv.RandUnsigned(fifoInterface.d'length);
			else fifoInterface.d<=(others=>'Z');
			end if;
		*/
			
			if cnt<x"a8" then
				write(rv.RandUnsigned(fifoInterface.writeRequest.message'length));
			else read;
			end if;
			
			cnt:=cnt+1;
		end if;
	end process;
end architecture simulation;
