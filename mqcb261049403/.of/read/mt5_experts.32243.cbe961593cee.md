Calculation: CCI = CCI on its configured timeframe's last completed bar; that timeframe may be higher or lower than the chart timeframe
Calculation: RSI = RSI on its configured timeframe's last completed bar; that timeframe may be higher or lower than the chart timeframe
Calculation: MA = configured moving average on its configured timeframe; compare the current forming bar with the two preceding completed bars
Long: CCI < -CCI threshold AND RSI < RSI threshold
Short: CCI > CCI threshold AND RSI > 100 - RSI threshold
Long: at least one long position is open AND (lowest long entry price > current price + grid step OR long position count = short position count)
Short: at least one short position is open AND (highest short entry price < current price - grid step OR long position count = short position count)
Exit: long, total long floating profit including swap > profit target AND (MA current < MA previous < MA two bars ago OR MA filter disabled)
Exit: short, total short floating profit including swap > profit target AND (MA current > MA previous > MA two bars ago OR MA filter disabled)
Exit: all positions, total long and short floating profit including swap > profit target AND ((long profit > short profit AND (MA current < MA previous < MA two bars ago OR MA filter disabled)) OR (short profit > long profit AND (MA current > MA previous > MA two bars ago OR MA filter disabled))