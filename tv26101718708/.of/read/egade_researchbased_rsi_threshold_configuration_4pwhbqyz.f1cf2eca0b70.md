Calculation: HTF RSI = RSI of close computed on aggregated bars of a timeframe higher than the chart timeframe; on each chart bar use the value from the last completed higher-timeframe bar. HTF RSI[1] = the HTF RSI value on the previous chart bar.
Calculation: buy threshold < sell threshold; the buy threshold is below the RSI midpoint and the sell threshold is above it.
Long: HTF RSI <= buy threshold (entry zone)
Long: HTF RSI <= buy threshold AND HTF RSI[1] > buy threshold (first bar entering the zone)
Exit: long, HTF RSI >= sell threshold (exit zone)
Exit: long, HTF RSI >= sell threshold AND HTF RSI[1] < sell threshold (first bar entering the zone)