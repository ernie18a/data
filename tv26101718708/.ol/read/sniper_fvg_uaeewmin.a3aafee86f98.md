Calculation: Bullish FVG = current bar low > high two bars earlier multiplied by the configured gap threshold factor
Calculation: Bearish FVG = current bar high multiplied by the configured gap threshold factor < low two bars earlier
Calculation: Session bias = bullish when close > the higher-timeframe EMA; bearish when close < it; neutral when equal. The EMA uses the last completed higher-timeframe bar in historical data.
Long: confirmed bar within the configured session AND bullish FVG AND (automatic mode with bearish session bias OR forced bearish mode OR both mode)
Short: confirmed bar within the configured session AND bearish FVG AND (automatic mode with bullish session bias OR forced bullish mode OR both mode)