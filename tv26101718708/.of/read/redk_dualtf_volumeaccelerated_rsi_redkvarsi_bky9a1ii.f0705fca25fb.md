Calculation: Volume-weighted RSI = Apply a selected moving average to the positive and negative parts of each close change multiplied by the bar's volume. Divide the averaged positive part by the averaged absolute negative part to obtain relative strength; transform it as RSI. If the averaged negative part is zero, return the top of the RSI range; otherwise, if the averaged positive part is zero, return the bottom. Optionally replace volume with one. Optionally smooth the resulting RSI with a selected moving average.
Calculation: Higher-timeframe volume-weighted RSI = Calculate volume-weighted RSI without smoothing on higher-timeframe bars, using the same RSI length, averaging method and volume-weighting choice as the chart-timeframe calculation. Use either the still-forming higher-timeframe bar or the last completed higher-timeframe bar.
Long: Chart-timeframe volume-weighted RSI > midpoint of the RSI range.
Short: Chart-timeframe volume-weighted RSI <= midpoint of the RSI range.
Long: Higher-timeframe volume-weighted RSI > midpoint of the RSI range.
Short: Higher-timeframe volume-weighted RSI <= midpoint of the RSI range.
Long: Chart-timeframe volume-weighted RSI crosses above the midpoint of the RSI range.
Short: Chart-timeframe volume-weighted RSI crosses below the midpoint of the RSI range.
Long: Chart-timeframe volume-weighted RSI > midpoint of the RSI range AND higher-timeframe volume-weighted RSI > midpoint of the RSI range AND the same conjunction was false on the previous chart bar.
Short: Chart-timeframe volume-weighted RSI <= midpoint of the RSI range AND higher-timeframe volume-weighted RSI <= midpoint of the RSI range AND the same conjunction was false on the previous chart bar.