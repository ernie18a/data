Calculation: RSI = RSI of the current-timeframe Heikin-Ashi close
Calculation: po = 100 × (short moving average of close − long moving average of close) ÷ long moving average of close; both averages use the same selectable SMA or EMA method and have separate lengths
Calculation: c1 = triple Hull moving average of the last completed higher-timeframe Heikin-Ashi close
Calculation: o1 = triple Hull moving average of the last completed higher-timeframe Heikin-Ashi open
Long: c1 crosses above o1 AND RSI is above its threshold AND (po is positive OR po is greater than its previous value) AND po is below its upper threshold
Exit: long, c1 crosses below o1
Exit: short, c1 crosses below o1