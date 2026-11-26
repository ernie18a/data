Calculation: Fast line = moving average(Chaikin Oscillator, shorter Chaikin lookback, longer Chaikin lookback, volume, shorter smoothing lookback, method, phase) on T1 bars
Calculation: Slow line = moving average(Fast line, longer smoothing lookback, method, phase) on T1 bars
Long: Fast line crosses above Slow line on a T1 bar close
Short: Fast line crosses below Slow line on a T1 bar close
Exit: long, Fast line < Slow line on the last completed T1 bar
Exit: short, Fast line > Slow line on the last completed T1 bar