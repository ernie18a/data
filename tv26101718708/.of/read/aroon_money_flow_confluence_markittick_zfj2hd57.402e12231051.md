Calculation: Confirmation window = if automatic, the median of the latest 20 bar gaps between an Aroon Oscillator zero-cross and subsequent same-direction agreement (only gaps of at most 20 bars); until 5 gaps exist, use one quarter of the CMF lookback, rounded and bounded to 1–20 bars; otherwise use the manual confirmation-bar setting.
Calculation: Stop distance = ATR × stop multiplier; target distances = stop distance × the three target multiples, sorted from nearest to farthest.
Long: Aroon Oscillator > 0 AND CMF > flow buffer
Short: Aroon Oscillator < 0 AND CMF < −flow buffer
Long: Bullish agreement (Aroon Oscillator > 0 AND CMF > flow buffer) newly begins AND Aroon Oscillator crossed above zero within the confirmation window AND (higher-timeframe Aroon Oscillator > 0, if enabled; use the last completed higher-timeframe bar) AND (previous bar ADX ≥ minimum, if enabled) AND stop distance > minimum tick AND long stop price > 0
Short: Bearish agreement (Aroon Oscillator < 0 AND CMF < −flow buffer) newly begins AND Aroon Oscillator crossed below zero within the confirmation window AND (higher-timeframe Aroon Oscillator < 0, if enabled; use the last completed higher-timeframe bar) AND (previous bar ADX ≥ minimum, if enabled) AND stop distance > minimum tick AND farthest short target price > 0
Exit: Long, bar closes below stop price
Exit: Short, bar closes above stop price
Exit: Long, bar high reaches farthest target price
Exit: Short, bar low reaches farthest target price
Exit: Long, a new long or short entry signal occurs
Exit: Short, a new long or short entry signal occurs
Exit: Long, bar high reaches either of the two nearer target prices (partial exit)
Exit: Short, bar low reaches either of the two nearer target prices (partial exit)