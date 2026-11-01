Calculation: Weighted RVI = weighted sum of five Relative Vigor Index main lines with progressively longer lookbacks; use the same weight for the second and third lines, and separate weights for the others.
Calculation: Smoothed RVI = Weighted RVI / smoothing period + previous Smoothed RVI × (smoothing period − 1) / smoothing period; initialize at the first calculated bar as Weighted RVI / smoothing period.
Long: Weighted RVI > Smoothed RVI on the chart timeframe.
Short: Weighted RVI < Smoothed RVI on the chart timeframe.
Long: On a configurable indicator timeframe, which may be higher or lower than the chart timeframe, the last completed bar has Weighted RVI > Smoothed RVI AND the preceding bar has Weighted RVI < Smoothed RVI.
Short: On the indicator timeframe, the last completed bar has Weighted RVI < Smoothed RVI AND the preceding bar has Weighted RVI > Smoothed RVI.
Exit: long, Weighted RVI < Smoothed RVI on the last completed indicator-timeframe bar OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, Weighted RVI > Smoothed RVI on the last completed indicator-timeframe bar OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.