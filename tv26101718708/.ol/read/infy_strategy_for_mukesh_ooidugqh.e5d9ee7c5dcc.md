Calculation: rsi = RSI of the linear regression of hlc3
Calculation: vwaprsi = RSI of VWAP(hlc3)
Calculation: rsiv = RSI of the VWMA of the linear regression of close
Long: vwaprsi > previous vwaprsi AND rsi > previous rsi AND vwaprsi < 10 AND bar time is between 09:30 and 15:00 AND bar datetime is on or after the configured start date
Short: rsiv > 96 AND rsiv < previous rsiv AND previous rsiv > rsiv two bars ago AND bar time is between 09:30 and 15:00 AND bar datetime is on or after the configured start date
Exit: long, vwaprsi > 99.8 AND previous vwaprsi <= 99.8 AND bar datetime is on or after the configured start date
Exit: short, rsiv > previous rsiv AND rsiv two bars ago > previous rsiv AND bar datetime is on or after the configured start date
Exit: long, bar high >= entry price × (1 + configured long profit fraction) AND bar datetime is on or after the configured start date
Exit: short, bar low <= entry price × (1 − configured short profit fraction) AND bar datetime is on or after the configured start date