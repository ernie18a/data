Calculation: WVAD sum = sum of ((close − open) / (high − low) × volume) over a rolling lookback; use 0 when high = low
Calculation: Filtered WVAD = WVAD sum passed through the selected smoothing method (none, SMA, EMA, RMA, double WMA, triple VWMA, HMA, LLAMA, or Kalman filter)
Calculation: Signal line = SMA of Filtered WVAD; use the selected signal lookback
Calculation: Stop price = entry price ± (ATR × stop multiple), subtracting for long and adding for short
Calculation: Target prices = entry price ± (ATR × stop multiple × target R multiple), adding for long and subtracting for short
Long: Filtered WVAD on the prior completed chart bar > Signal line on that bar AND Filtered WVAD two chart bars ago <= Signal line then AND (ADX on the prior completed chart bar >= threshold, if the ADX filter is enabled) AND (the last completed higher-timeframe bar closed above its open, if HTF confirmation is enabled)
Short: Filtered WVAD on the prior completed chart bar < Signal line on that bar AND Filtered WVAD two chart bars ago >= Signal line then AND (ADX on the prior completed chart bar >= threshold, if the ADX filter is enabled) AND (the last completed higher-timeframe bar closed below its open, if HTF confirmation is enabled)
Exit: Long, short-entry condition OR low <= stop price OR high >= any of the three target prices
Exit: Short, long-entry condition OR high >= stop price OR low <= any of the three target prices