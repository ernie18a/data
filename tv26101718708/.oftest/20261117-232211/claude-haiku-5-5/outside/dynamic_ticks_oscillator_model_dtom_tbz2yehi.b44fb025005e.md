Calculation: RateOfChange = (NYSE down ticks close on T1 - NYSE down ticks close on T1 P1 bars ago) / NYSE down ticks close on T1 P1 bars ago
Calculation: StdDevOfRateOfChange = population standard deviation of RateOfChange over the last P2 bars
Long: RateOfChange < -P3 * StdDevOfRateOfChange
Exit: long, RateOfChange > P4 * StdDevOfRateOfChange