Calculation: Prior-quarter high = highest high of the previous completed calendar quarter, calculated on T1 bars and carried to chart bars
Calculation: Prior-quarter low = lowest low of the previous completed calendar quarter, calculated on T1 bars and carried to chart bars
Calculation: Valid range = Prior-quarter high and low exist AND Prior-quarter high > Prior-quarter low
Calculation: Range width = Prior-quarter high - Prior-quarter low
Calculation: Range position % = 100 * (close - Prior-quarter low) / Range width, on chart bars using the T1 values
Calculation: Range midpoint = (Prior-quarter high + Prior-quarter low) / 2, on chart bars using the T1 values
Calculation: Qualified = Valid range AND close >= minimum-price parameter AND SMA(volume, volume lookback parameter) on chart bars >= minimum-average-volume parameter
Calculation: Breakout occurred = Valid range AND at least one chart bar from the current calendar-quarter start through the current bar closed above Prior-quarter high
Calculation: First breakout = Valid range AND close > Prior-quarter high AND no earlier chart bar in the current calendar quarter closed above Prior-quarter high
Calculation: Retest condition = Qualified AND Breakout occurred AND the current chart bar is after the first breakout and no more than the retest-lookback parameter bars after it AND close >= Prior-quarter high AND low <= Prior-quarter high + Range width * retest-zone percentage parameter / 100
Long: Qualified AND Range position % >= building-threshold parameter AND Range position % < 100 - ready-zone percentage parameter AND close > close[approach-lookback parameter] AND no breakout has occurred in the current calendar quarter
Long: Qualified AND no breakout has occurred in the current calendar quarter AND Range position % >= 100 - ready-zone percentage parameter AND Range position % <= 100 AND close > close[approach-lookback parameter]
Long: Qualified AND First breakout
Long: Retest condition
Long: Qualified AND Breakout occurred AND close > Prior-quarter high AND NOT First breakout AND NOT Retest condition
Long: Qualified AND close crosses above Range midpoint
Exit: long, Qualified AND Breakout occurred AND close <= Prior-quarter high AND NOT Retest condition