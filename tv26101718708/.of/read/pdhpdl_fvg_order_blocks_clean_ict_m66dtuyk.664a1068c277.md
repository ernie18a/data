Calculation: Previous day high and low = maximum high and minimum low of chart bars in the last completed day, using a configurable day-boundary timezone; the day is a higher timeframe than the chart.
Long: Low < previous day low AND close > previous day low
Short: High > previous day high AND close < previous day high
Long: Low > high two bars ago AND low - high two bars ago > ATR × FVG size threshold
Short: High < low two bars ago AND low two bars ago - high > ATR × FVG size threshold
Long: Close > open AND close - open > ATR × displacement threshold AND previous close < previous open AND previous high - previous low > ATR × order-block size threshold AND (FVG requirement disabled OR (FVG module enabled AND low > high two bars ago AND low - high two bars ago > ATR × FVG size threshold))
Short: Close < open AND open - close > ATR × displacement threshold AND previous close > previous open AND previous high - previous low > ATR × order-block size threshold AND (FVG requirement disabled OR (FVG module enabled AND high < low two bars ago AND low two bars ago - high > ATR × FVG size threshold))