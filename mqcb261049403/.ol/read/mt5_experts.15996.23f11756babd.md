Calculation: SMI = 100 × smoothed(price − midpoint of the lookback high and low) ÷ (smoothed lookback range ÷ 2); if the smoothed range is zero, SMI = 100. Apply the same first smoothing to the price difference and range, then the same second smoothing to both results.
Calculation: Trigger = smooth SMI with a third smoothing stage.
Long: On the indicator timeframe (which may be higher or lower than the chart timeframe), the last completed bar has SMI > Trigger AND the preceding completed bar has SMI ≤ Trigger.
Short: On the indicator timeframe (which may be higher or lower than the chart timeframe), the last completed bar has SMI < Trigger AND the preceding completed bar has SMI ≥ Trigger.
Exit: short, on the indicator timeframe (which may be higher or lower than the chart timeframe), the last completed bar has SMI > Trigger.
Exit: long, on the indicator timeframe (which may be higher or lower than the chart timeframe), the last completed bar has SMI < Trigger.