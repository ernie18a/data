Calculation: Score = weighted mean of normalized VWAP location and slope, smoothed TICK, standardized net up-volume minus down-volume, advance-minus-decline breadth, standardized change in cumulative volume delta, MACD histogram, MFI, and RSI(2) mean-reversion component; the RSI component is active only when VIX is below its threshold
Calculation: Short put strike = lower strike increment nearest to close minus the selected buffer; short call strike = upper strike increment nearest to close plus the selected buffer; the buffer is either an ATR multiple or a point amount
Calculation: Expected-move σ = supplied expected move when positive, otherwise ATR multiplied by the square root of the forecast horizon
Calculation: Put-spread POP = standard-normal CDF of (close + score-based directional drift − short put strike) / expected-move σ
Calculation: Call-spread POP = standard-normal CDF of (short call strike − close − score-based directional drift) / expected-move σ
Long: Score crosses above the bullish threshold AND put-spread POP is at least the minimum POP
Short: Score crosses below the negative bearish threshold AND call-spread POP is at least the minimum POP