Calculation: Prior swing high = highest high over the preceding lookback bars, excluding the current bar
Calculation: Prior swing low = lowest low over the preceding lookback bars, excluding the current bar
Calculation: Average volume = simple moving average of volume over a lookback period
Long: high > prior swing high AND close < prior swing high AND volume > average volume multiplied by a threshold
Short: low < prior swing low AND close > prior swing low AND volume > average volume multiplied by a threshold
Exit: short, low < prior swing low AND close > prior swing low AND volume > average volume multiplied by a threshold