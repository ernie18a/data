Calculation: Vortex+ = On the indicator timeframe, sum |each bar’s high − the prior bar’s low| over the lookback, divided by the sum of true range over the same bars
Calculation: Vortex− = On the indicator timeframe, sum |each bar’s low − the prior bar’s high| over the lookback, divided by the sum of true range over the same bars
Long: On the indicator timeframe, the older of the two most recent completed bars has Vortex+ <= Vortex− AND the newer completed bar has Vortex+ > Vortex−
Short: On the indicator timeframe, the older of the two most recent completed bars has Vortex+ >= Vortex− AND the newer completed bar has Vortex+ < Vortex−
Exit: Long, on the indicator timeframe’s most recent completed bar, Vortex− > Vortex+
Exit: Short, on the indicator timeframe’s most recent completed bar, Vortex− < Vortex+