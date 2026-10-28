Calculation: OBV slope score = clip((linear-regression slope of OBV over its lookback / ATR) × 50 + 12.5, 0, 25)
Calculation: CMF score = clip((Chaikin Money Flow over its lookback + 0.5) × 25, 0, 25)
Calculation: Relative volume score = clip((current volume / its longer-lookback volume SMA − 0.5) × 12.5, 0, 25)
Calculation: Price-volume alignment score = 25 when close rose and the shorter-lookback volume SMA rose over the alignment lookback; 5 when exactly one rose; 15 when both fell; otherwise 12.5
Calculation: Volume DNA score = clip(EMA of the sum of the four component scores, 0, 100)
Long: Volume DNA score ≥ 60
Short: Volume DNA score < 40