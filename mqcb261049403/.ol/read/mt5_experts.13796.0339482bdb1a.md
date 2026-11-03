Calculation: Hi-Lo Range Oscillator = 100 × (current bar midpoint − lowest low over its lookback) ÷ (highest high over its lookback − lowest low over its lookback), or 0 if the range is zero
Calculation: Fast trend line = weighted sum of five Hi-Lo Range Oscillators with progressively longer lookbacks
Calculation: Slow trend line = exponentially smoothed fast trend line using the prior slow trend line
Long: On the configured indicator timeframe, fast trend line > slow trend line on the latest completed bar AND fast trend line < slow trend line on the preceding completed bar
Short: On the configured indicator timeframe, fast trend line < slow trend line on the latest completed bar AND fast trend line > slow trend line on the preceding completed bar
Exit: Short, fast trend line > slow trend line on the latest completed bar AND fast trend line < slow trend line on the preceding completed bar
Exit: Long, fast trend line < slow trend line on the latest completed bar AND fast trend line > slow trend line on the preceding completed bar