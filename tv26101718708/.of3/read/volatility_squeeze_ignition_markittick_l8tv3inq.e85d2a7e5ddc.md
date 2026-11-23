Calculation: Bollinger upper = SMA(close, bb lookback) + bb multiplier * STDEV(close, bb lookback)
Calculation: Bollinger lower = SMA(close, bb lookback) - bb multiplier * STDEV(close, bb lookback)
Calculation: Squeeze = Bollinger lower > SMA(close, kc lookback) - kc multiplier * ATR(kc lookback) AND Bollinger upper < SMA(close, kc lookback) + kc multiplier * ATR(kc lookback)
Calculation: Squeeze run length = IF Squeeze THEN Squeeze run length[1] + 1 ELSE 0
Calculation: Squeeze delta = IF Squeeze THEN Squeeze delta[1] + SIGN(close - open) * volume ELSE 0
Calculation: Squeeze directional volume = IF Squeeze THEN Squeeze directional volume[1] + (IF close != open THEN volume ELSE 0) ELSE 0
Calculation: Delta ratio = ABS(Squeeze delta) / Squeeze directional volume
Calculation: Body ratio = ABS(close - open) / (high - low)
Calculation: Band width = Bollinger upper - Bollinger lower
Long: Squeeze[1] AND NOT Squeeze AND Squeeze run length[1] >= min squeeze bars AND close > Bollinger upper AND Squeeze delta[1] > 0
Long: Squeeze[1] AND NOT Squeeze AND Squeeze run length[1] >= min squeeze bars AND close > Bollinger upper AND Squeeze delta[1] > 0 AND (volume filter disabled OR Delta ratio[1] >= min delta ratio) AND (HTF filter disabled OR close(T1, last completed bar) > SMA(close, htf lookback, T1, last completed bar)) AND (ADX filter disabled OR ADX(adx lookback) >= min ADX) AND (body filter disabled OR Body ratio >= min body ratio) AND (expansion filter disabled OR Band width / Band width[1] >= min expansion ratio)
Short: Squeeze[1] AND NOT Squeeze AND Squeeze run length[1] >= min squeeze bars AND close < Bollinger lower AND Squeeze delta[1] < 0
Short: Squeeze[1] AND NOT Squeeze AND Squeeze run length[1] >= min squeeze bars AND close < Bollinger lower AND Squeeze delta[1] < 0 AND (volume filter disabled OR Delta ratio[1] >= min delta ratio) AND (HTF filter disabled OR close(T1, last completed bar) <= SMA(close, htf lookback, T1, last completed bar)) AND (ADX filter disabled OR ADX(adx lookback) >= min ADX) AND (body filter disabled OR Body ratio >= min body ratio) AND (expansion filter disabled OR Band width / Band width[1] >= min expansion ratio)