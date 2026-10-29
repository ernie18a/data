Calculation: Midprice = (high + low) / 2
Calculation: Laguerre filter = (L0 + 2×L1 + 2×L2 + L3) / 6, where L0 = (1 − γ)×midprice + γ×previous L0; L1 = −γ×L0 + previous L0 + γ×previous L1; L2 = −γ×L1 + previous L1 + γ×previous L2; L3 = −γ×L2 + previous L2 + γ×previous L3. Use bars from the configured indicator timeframe, which may be higher or lower than the chart timeframe; evaluate completed bars.
Calculation: FIR = (current midprice + 2×midprice one bar earlier + 2×midprice two bars earlier + midprice three bars earlier) / 6. Use bars from the configured indicator timeframe, which may be higher or lower than the chart timeframe; evaluate completed bars.
Long: FIR on the previous completed bar < Laguerre filter on the previous completed bar AND FIR on the latest completed bar > Laguerre filter on the latest completed bar
Short: FIR on the previous completed bar > Laguerre filter on the previous completed bar AND FIR on the latest completed bar < Laguerre filter on the latest completed bar
Exit: long, FIR on the latest completed bar < Laguerre filter on the latest completed bar
Exit: short, FIR on the latest completed bar > Laguerre filter on the latest completed bar