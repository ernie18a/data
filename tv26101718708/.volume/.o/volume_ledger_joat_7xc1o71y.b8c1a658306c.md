Calculation: Relative volume = current volume divided by its moving average.
Calculation: Delta Z = z-score of volume × (close − open) / max(high − low, minimum price increment), using a rolling lookback.
Calculation: Participation = an exponentially smoothed combination of 0.50 × Delta Z, 0.35 × (relative volume − 1), and −0.15 × the z-score of relative volume divided by result efficiency; result efficiency = bar range / average bar range, with both averages using the same baseline lookback.
Calculation: Churn state = relative volume exceeds its threshold AND result efficiency / relative volume is below its threshold.
Calculation: Qualified volume pivot zone = a confirmed local maximum in volume whose pivot bar qualifies by relative volume, absolute Delta Z, or volume-return volatility z-score; its center is that bar’s typical price and its width is an ATR-based amount. Among unexpired zones below price, active support is the highest-scoring zone; among unexpired zones above price, active resistance is the highest-scoring zone.
Long: Current bar is complete AND relative volume exceeds its threshold AND Delta Z exceeds its threshold AND participation > 0.
Long: Current bar is complete AND churn state AND Delta Z > 0.
Long: Current bar is complete AND active support exists AND low ≤ active support’s upper edge AND close ≥ active support’s center.
Short: Current bar is complete AND relative volume exceeds its threshold AND Delta Z is below the negative of its threshold AND participation < 0.
Short: Current bar is complete AND churn state AND Delta Z < 0.
Short: Current bar is complete AND active resistance exists AND high ≥ active resistance’s lower edge AND close ≤ active resistance’s center.