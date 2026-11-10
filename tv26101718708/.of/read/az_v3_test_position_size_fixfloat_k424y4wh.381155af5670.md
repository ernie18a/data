Calculation: Smoothed price = EMA of a selected price field on the chart timeframe.
Calculation: Fast and slow averages = respectively shorter- and longer-period EMAs of smoothed price. In fixed-timeframe mode, each is instead the chart-timeframe EMA of the corresponding EMA of the selected price field calculated on the selected other timeframe; use the last completed bar when that timeframe is higher, or the last completed intrabar when it is lower.
Calculation: Bullish zone = fast average > slow average AND smoothed price > fast average.
Calculation: Bearish zone = fast average < slow average AND smoothed price < fast average.
Calculation: Bullish state = bars since the bullish zone first became true < bars since the bearish zone first became true; bearish state = bars since the bearish zone first became true < bars since the bullish zone first became true. A state is undefined until both transitions have occurred.
Calculation: Stochastic RSI K = SMA of the stochastic oscillator of close-based RSI; D = SMA of K.
Long: bullish zone.
Long: fast average < slow average AND smoothed price > fast average AND smoothed price != slow average.
Long: bullish state.
Long: bullish state AND K crosses above D AND D < an oversold threshold.
Long: bullish state AND K crosses above D AND D > the oversold threshold AND the momentum signal threshold is less than the lower signal strength.
Short: bearish zone.
Short: fast average > slow average AND smoothed price < fast average AND smoothed price != slow average.
Short: bearish state.
Short: bearish state AND K crosses below D AND D > an overbought threshold.
Short: bearish state AND K crosses below D AND D < the overbought threshold AND the momentum signal threshold is less than the lower signal strength.
Exit: long, bearish zone is true AND bearish zone was false on the previous bar AND datetime is within the configured trading date range.