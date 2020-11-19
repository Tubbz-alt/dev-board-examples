-------------------------------------------------------------------------------
-- File       : VCU128Xaui.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Example using 10 GbE XAUI Protocol
-------------------------------------------------------------------------------
-- This file is part of 'Example Project Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'Example Project Firmware', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiLitePkg.all;
use surf.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity VCU128Xaui is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- Misc. IOs
      extRst      : in  sl;
      led         : out slv(7 downto 0);
      -- XADC Ports
      vPIn        : in  sl;
      vNIn        : in  sl;
      -- QSFP[3:0] Ports
      qsfpRstL    : out slv(3 downto 0);
      qsfpLpMode  : out slv(3 downto 0);
      qsfpModSelL : out slv(3 downto 0);
      qsfpModPrsL : in  slv(3 downto 0);
      qsfpRefClkP : in  slv(3 downto 0);
      qsfpRefClkN : in  slv(3 downto 0);
      qsfpRxP     : in  slv(15 downto 0);
      qsfpRxN     : in  slv(15 downto 0);
      qsfpTxP     : out slv(15 downto 0);
      qsfpTxN     : out slv(15 downto 0));
end VCU128Xaui;

architecture top_level of VCU128Xaui is

   constant AXIS_SIZE_C : positive := 1;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);

   signal bootReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal bootReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal bootWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal bootWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);

   signal clk      : sl;
   signal rst      : sl;
   signal rstL     : sl;
   signal reset    : sl;
   signal phyReady : sl;

begin

   -----------------
   -- Power Up Reset
   -----------------
   PwrUpRst_Inst : entity surf.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => extRst,
         clk    => clk,
         rstOut => reset);

   ----------------------
   -- 10 GigE XAUI Module
   ----------------------
   U_XAUI : entity surf.XauiGtyUltraScaleWrapper
      generic map (
         TPD_G         => TPD_G,
         AXIS_CONFIG_G => EMAC_AXIS_CONFIG_C)
      port map (
         -- Local Configurations
         localMac    => MAC_ADDR_INIT_C,
         -- Streaming DMA Interface
         dmaClk      => clk,
         dmaRst      => rst,
         dmaIbMaster => rxMasters(0),
         dmaIbSlave  => rxSlaves(0),
         dmaObMaster => txMasters(0),
         dmaObSlave  => txSlaves(0),
         -- Misc. Signals
         extRst      => reset,
         phyClk      => clk,
         phyRst      => rst,
         phyReady    => phyReady,
         -- MGT Clock Port (156.25 MHz or 312.5 MHz)
         gtClkP      => qsfpRefClkP(0),
         gtClkN      => qsfpRefClkN(0),
         -- MGT Ports
         gtTxP       => qsfpTxP(3 downto 0),
         gtTxN       => qsfpTxN(3 downto 0),
         gtRxP       => qsfpRxP(3 downto 0),
         gtRxN       => qsfpRxN(3 downto 0));

   -------------------------
   -- Terminate Unused Lanes
   -------------------------
   U_UnusedGty : entity surf.Gtye4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 12)
      port map (
         refClk => clk,
         gtRxP  => qsfpRxP(15 downto 4),
         gtRxN  => qsfpRxN(15 downto 4),
         gtTxP  => qsfpTxP(15 downto 4),
         gtTxN  => qsfpTxN(15 downto 4));

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G,
         XIL_DEVICE_G => "ULTRASCALE",
         APP_TYPE_G   => "ETH",
         AXIS_SIZE_G  => AXIS_SIZE_C,
         DHCP_G       => true,
         IP_ADDR_G    => x"0A_02_A8_C0",  -- 192.168.2.10
         MAC_ADDR_G   => MAC_ADDR_INIT_C)
      port map (
         -- Clock and Reset
         clk              => clk,
         rst              => rst,
         -- AXIS interface
         txMasters        => txMasters,
         txSlaves         => txSlaves,
         rxMasters        => rxMasters,
         rxSlaves         => rxSlaves,
         -- BOOT Prom Interface
         bootWriteMasters => bootWriteMasters,
         bootWriteSlaves  => bootWriteSlaves,
         bootReadMasters  => bootReadMasters,
         bootReadSlaves   => bootReadSlaves,
         -- ADC Ports
         vPIn             => vPIn,
         vNIn             => vNIn);

   ------------
   -- BOOT PROM
   ------------
   U_BootProm : entity work.BootProm
      generic map (
         TPD_G => TPD_G)
      port map (
         -- AXI-Lite Interface
         axilClk          => clk,
         axilRst          => rst,
         axilWriteMasters => bootWriteMasters,
         axilWriteSlaves  => bootWriteSlaves,
         axilReadMasters  => bootReadMasters,
         axilReadSlaves   => bootReadSlaves);

   ----------------
   -- Misc. Signals
   ----------------
   led(7)    <= '1';
   led(6)    <= '1';
   led(5)    <= extRst;
   led(4)    <= extRst;
   led(3)    <= rstL;
   led(2)    <= rstL;
   led(1)    <= phyReady;
   led(0)    <= phyReady;

   rstL        <= not(rst);
   qsfpRstL    <= (others => rstL);
   qsfpLpMode  <= (others => '0');
   qsfpModSelL <= (others => '1');

end top_level;