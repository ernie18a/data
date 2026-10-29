Calculation: 10-bar price momentum = close − close 10 bars earlier
Calculation: Momentum average = simple moving average of 10-bar price momentum
Calculation: Volume spike = volume > simple moving average of volume × herd volume multiplier
Calculation: Institutional volume = volume > simple moving average of volume × institutional volume multiplier
Calculation: Accumulation/distribution = cumulative sum of (((close − low) − (high − close)) / (high − low)) × volume
Calculation: Smart money index = ((close − open) / (high − low)) × volume
Calculation: Nash upper/lower bands = simple moving average of close ± standard deviation of close × deviation multiplier
Calculation: Down liquidity trap = low < the previous bar’s recent lookback low AND close > that low AND volume spike
Calculation: Up liquidity trap = high > the previous bar’s recent lookback high AND close < that high AND volume spike
Long: Down liquidity trap
Long: RSI < oversold threshold AND volume spike AND 10-bar price momentum < momentum average AND (accumulation/distribution > its longer-term simple moving average OR down liquidity trap)
Short: Up liquidity trap
Short: RSI > overbought threshold AND volume spike AND 10-bar price momentum > momentum average AND (accumulation/distribution < its longer-term simple moving average OR up liquidity trap)
Long: close < Nash lower band AND smart money index > its shorter-term simple moving average AND NOT (RSI > overbought threshold AND volume spike AND 10-bar price momentum > momentum average)
Short: close > Nash upper band AND smart money index <= its shorter-term simple moving average AND NOT (RSI < oversold threshold AND volume spike AND 10-bar price momentum < momentum average)
Long: close < Nash lower band AND close > previous bar close AND volume > simple moving average of volume
Short: close > Nash upper band AND close < previous bar close AND volume > simple moving average of volume
Long: (contrarian buy OR momentum buy OR Nash reversion buy) AND position side <= 0
Short: (contrarian sell OR momentum sell OR Nash reversion sell) AND position side >= 0
Exit: Long, low <= entry signal bar close × (1 − stop-loss %) OR high >= entry signal bar close × (1 + take-profit %)
Exit: Short, high >= entry signal bar close × (1 + stop-loss %) OR low <= entry signal bar close × (1 − take-profit %)