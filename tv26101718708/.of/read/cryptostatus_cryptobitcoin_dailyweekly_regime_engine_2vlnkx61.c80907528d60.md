Calculation: Anchor bars = chart-symbol bars at the selected anchor timeframe; if higher than the chart timeframe, use the last completed anchor bar; if lower, use the last completed anchor bar within the chart bar; if equal, use the chart bar.
Calculation: Ribbon = four smoothed moving averages of anchor-bar (high + low) / 2, ordered by increasing length from A to D; each is initialized with a simple moving average and subsequently updated as (previous average × (length − 1) + current source) / length.
Calculation: Ribbon spread = (A − D) / D × 100 when D is nonzero, otherwise 0.
Calculation: Confirmed pivot = an anchor-bar high or low that is a pivot using the specified numbers of bars to its left and right; evaluate it when the right-hand bars have completed. Compare each confirmed pivot with the immediately preceding confirmed pivot of the same type, provided their confirmation bars are no more than the maximum lookback apart.
Long: A ≥ D AND A ≥ B AND C ≥ D AND absolute ribbon spread ≥ neutral-zone threshold.
Short: A < D AND A < B AND C < D AND absolute ribbon spread ≥ neutral-zone threshold.
Long: Confirmed pivot low < preceding pivot low AND RSI at the confirmed pivot > RSI at the preceding pivot.
Short: Confirmed pivot high > preceding pivot high AND RSI at the confirmed pivot < RSI at the preceding pivot.
Long: Confirmed pivot low < preceding pivot low AND ADX at the confirmed pivot < ADX one anchor bar before the confirmed pivot.
Short: Confirmed pivot high > preceding pivot high AND ADX at the confirmed pivot < ADX one anchor bar before the confirmed pivot.