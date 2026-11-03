Calculation: RSI(14) = Relative Strength Index of close over 14 chart-timeframe bars, evaluated at bar close
Long: flat AND RSI(14) < entry threshold
Long: long AND fewer than all configured safety orders are filled AND close <= base entry × (1 − deviation of the next unfilled safety order)
Exit: long, close >= average position entry × (1 + take-profit percentage)