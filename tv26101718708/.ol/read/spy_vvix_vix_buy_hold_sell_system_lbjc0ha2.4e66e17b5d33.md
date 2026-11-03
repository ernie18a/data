Calculation: SPY trend EMA = EMA of chart-timeframe close over the trend lookback
Calculation: Smoothed range = range multiplier × EMA(EMA(abs(close − prior close), range lookback), 2 × range lookback − 1)
Calculation: Range filter = if close > prior filter, max(prior filter, close − smoothed range); if close < prior filter, min(prior filter, close + smoothed range); otherwise prior filter
Calculation: Bullish range = close > range filter AND range filter has risen on at least one consecutive bar
Calculation: Bearish range = close < range filter AND range filter has fallen on at least one consecutive bar
Calculation: VVIX and VIX = higher-timeframe closes from their respective symbols, using the still-forming bar; their EMAs are calculated over the returned chart-timeframe series
Calculation: Long-state condition = close > SPY trend EMA AND bullish range AND VVIX < caution level AND NOT (VIX > its EMA AND VIX > its prior value) AND VVIX < its EMA AND VVIX < its prior value
Calculation: Hold-state condition = close > SPY trend EMA AND bullish range AND NOT (VVIX >= panic level OR (VVIX > its EMA AND VVIX > its prior value AND VIX > its EMA AND VIX > its prior value))
Calculation: Sell-state condition = VVIX >= panic level OR (VVIX > its EMA AND VVIX > its prior value AND VIX > its EMA AND VIX > its prior value) OR (VVIX >= danger level AND VVIX > its EMA AND VVIX > its prior value) OR (close < SPY trend EMA AND bearish range)
Calculation: System state = 1 when the long-state condition is true; otherwise −1 when the sell-state condition is true; otherwise 0 when the hold-state condition is true; otherwise prior system state (initially 0)
Long: System state = 1 AND prior system state != 1
Exit: long, System state = −1 AND prior system state != −1