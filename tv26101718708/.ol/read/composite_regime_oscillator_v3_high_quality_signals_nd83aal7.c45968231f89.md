Calculation: Scale(x, a, b) = 100 × clamp((x − a) / (b − a), 0, 1)
Calculation: ATR ratio = shorter-lookback ATR / longer-lookback ATR
Calculation: Drawdown = (highest high over its lookback − close) / highest high over that lookback
Calculation: Rebound = (close − lowest low over its lookback) / lowest low over that lookback
Calculation: Range position = (close − lowest low over its lookback) / (highest high over that lookback − lowest low over that lookback)
Calculation: Price-to-low = (close − lowest low over the range lookback) / lowest low over that lookback
Calculation: Price-to-high = (highest high over the range lookback − close) / highest high over that lookback
Calculation: Relative volume = volume / simple moving average of volume over its lookback
Calculation: Regime stress = SMA over the signal-smoothing lookback of 0.45 × Scale(ATR ratio, 1.00, 1.50) + 0.30 × Scale(Drawdown, 0.00, 0.12) + 0.25 × Scale(Rebound, 0.00, 0.10)
Calculation: Location score = SMA over the signal-smoothing lookback of 0.60 × Scale(Range position, 0.00, 1.00) + 0.25 × Scale(Price-to-low, 0.00, 0.10) + 0.15 × (100 − Scale(Price-to-high, 0.00, 0.08))
Calculation: Bull overreaction = SMA over the signal-smoothing lookback of 0.75 × Scale(100 − RSI, 20, 50) + 0.25 × Scale((EMA of close − close) / shorter-lookback ATR, 0.50, 2.80)
Calculation: Bear overreaction = SMA over the signal-smoothing lookback of 0.75 × Scale(RSI, 50, 80) + 0.25 × Scale((close − EMA of close) / shorter-lookback ATR, 0.50, 2.80)
Calculation: Pressure score = SMA over the signal-smoothing lookback of 0.70 × Scale(Relative volume, 0.80, 2.00) + 0.30 × Scale(ATR ratio, 1.00, 1.50)
Calculation: Bull exhaustion = EMA over the oscillator-smoothing lookback of 0.35 × (100 − Location score) + 0.30 × Bull overreaction + 0.15 × Regime stress + 0.20 × Pressure score
Calculation: Bear exhaustion = EMA over the oscillator-smoothing lookback of 0.35 × Location score + 0.30 × Bear overreaction + 0.10 × (100 − Regime stress) + 0.25 × Pressure score
Long: Bull exhaustion ≥ minimum exhaustion strength AND (close > previous bar high OR (close > open AND previous close < previous open) OR (RSI crosses above 30) OR (close > each of the previous two closes)) AND bullish setup was false on the previous bar AND no bullish signal occurred within the cooldown lookback
Short: Bear exhaustion ≥ minimum exhaustion strength AND (close < previous bar low OR (close < open AND previous close > previous open) OR (RSI crosses below 70) OR (close < each of the previous two closes)) AND bearish setup was false on the previous bar AND no bearish signal occurred within the cooldown lookback