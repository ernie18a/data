Calculation: Normalized RSI = RSI of chart-bar closes divided by 100.
Calculation: Normalized EMA distance = (close − exponential moving average of close) / close.
Calculation: Normalized rate of change = rate of change of chart-bar close / 10.
Calculation: Normalized ATR = average true range / close.
Calculation: Relative volume change = volume / simple moving average of volume − 1.
Calculation: Range position = (close − lowest low) / (highest high − lowest low); use 0.5 if the range is zero.
Calculation: Model probability = an XGBoost model's predicted probability of an upward move, trained every 50 chart bars after bar 300 on 50 observations from 11 to 60 bars earlier. Each observation uses the six features above; its label is whether the close two bars after that observation exceeds its close. Train only when a model is available, and use the current chart bar's features for prediction.
Calculation: Trailing stop = 90% of the highest high since entry, initialized using the entry price and updated to never decrease.
Long: Model is available AND bar index > 300 AND model probability > threshold AND more than one bar has elapsed since the last exit AND close > 15-bar simple moving average AND no position is open.
Exit: Long, model is available AND bar index > 300 AND model probability < 1 − threshold AND current strategy equity exceeds the equity recorded at entry AND bar index is greater than the entry bar index + 3.
Exit: Long, low ≤ trailing stop, except on the bar the position opens.