Calculation: Composite Z-score = weighted average of the Z-scores of rate of change, RSI, and volume divided by its moving average.
Calculation: Smoothed composite = composite Z-score smoothed with an EMA whose length decreases as the ATR percentile rank increases.
Calculation: Bullish divergence = on a confirmed pivot low of the smoothed composite, price makes a lower low than at the prior confirmed pivot low while the smoothed composite makes a higher low.
Calculation: Bearish divergence = on a confirmed pivot high of the smoothed composite, price makes a higher high than at the prior confirmed pivot high while the smoothed composite makes a lower high.
Long: In Zero Cross mode, smoothed composite crosses above zero OR, in Threshold Reversion mode, smoothed composite crosses above the long threshold OR bullish divergence.
Short: In Zero Cross mode, smoothed composite crosses below zero OR, in Threshold Reversion mode, smoothed composite crosses below the short threshold OR bearish divergence.
Exit: long, smoothed composite crosses below the long exit level OR low reaches the ATR-based stop set at entry.
Exit: short, smoothed composite crosses above the short exit level OR high reaches the ATR-based stop set at entry.