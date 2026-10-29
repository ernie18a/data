Calculation: Previous-period Camarilla H3/L3 = previous completed bar’s close ± (previous bar’s high − low) × 1.1/4, using the configured pivot timeframe, which is higher than the chart timeframe.
Calculation: MACD line = short-lookback EMA of close − long-lookback EMA of close; signal line = moving average of the MACD line over a shorter lookback.
Calculation: Bollinger Fibonacci bands = same-lookback SMA of close ± ATR of that lookback multiplied by Fibonacci ratios; band 2 uses the second ratio. Smoothed VPT price line = short-lookback SMA of the VPT-derived price series, where VPT is the cumulative sum of (close − open) × 100 × (volume / ((high − low) × 100)), and the derived price series is high + shadow when shadow is positive, otherwise low + shadow; shadow = (VPT − its short-lookback SMA) / standard deviation of that difference over a longer lookback × standard deviation of (high − low) over that longer lookback.
Long: low <= previous-period Camarilla L3
Short: high >= previous-period Camarilla H3
Exit: Long, high >= previous-period Camarilla H3
Exit: Short, low <= previous-period Camarilla L3
Long: RSI is above its threshold AND MACD line is above its signal line AND the previous signal state was short
Short: RSI is below its threshold AND MACD line is below its signal line AND the previous signal state was long
Long: smoothed VPT price line crosses above the lower band 2
Short: smoothed VPT price line crosses below the upper band 2
Long: TKE crosses above zero
Short: TKE crosses below its overbought threshold
Long: previous bar range > ATR × multiplier AND previous bar body/range is between minimum and maximum fractions AND previous bar closed below its open AND current bar closes above its open
Short: previous bar range > ATR × multiplier AND previous bar body/range is between minimum and maximum fractions AND previous bar closed above its open AND current bar closes below its open
Long: previous bar range > ATR × multiplier AND current low < previous low AND current close > previous high
Short: previous bar range > ATR × multiplier AND current high > previous high AND current close < previous low