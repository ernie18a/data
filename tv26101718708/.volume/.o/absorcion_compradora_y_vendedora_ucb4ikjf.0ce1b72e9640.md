Calculation: Average volume = simple moving average of volume over the configured lookback
Calculation: Estimated buy volume = volume × (close − low) / (high − low) when high > low, otherwise 0
Calculation: Estimated sell volume = volume × (high − close) / (high − low) when high > low, otherwise 0
Calculation: Buy ratio = estimated buy volume / volume when volume > 0, otherwise 0
Calculation: Sell ratio = estimated sell volume / volume when volume > 0, otherwise 0
Long: high > low AND abs(close − open) / (high − low) < configured maximum body-to-range ratio AND volume > average volume × configured minimum volume multiple AND buy ratio > configured minimum dominant-volume ratio
Short: high > low AND abs(close − open) / (high − low) < configured maximum body-to-range ratio AND volume > average volume × configured minimum volume multiple AND sell ratio > configured minimum dominant-volume ratio