Calculation: Positive Volume Index = prior value × (1 + (close − prior close) / prior close) when volume exceeds prior volume; otherwise prior value (initialize at 1000)
Calculation: Negative Volume Index = prior value × (1 + (close − prior close) / prior close) when volume is below prior volume; otherwise prior value (initialize at 1000)
Calculation: On-Balance Volume = prior value + volume when close rises, prior value − volume when close falls, otherwise prior value (initialize at 0)
Calculation: Composite RSI = average of RSI of Positive Volume Index, RSI of Negative Volume Index, and RSI of On-Balance Volume, using the same lookback
Calculation: Smoothed Composite RSI = EMA of Composite RSI
Calculation: Composite RSI Oscillator = EMA of RSI of Composite RSI
Long: Composite RSI Oscillator crosses above the oversold level AND Supertrend is bullish
Short: Composite RSI Oscillator crosses below the overbought level AND Supertrend is bearish
Long: Smoothed Composite RSI crosses into the oversold zone
Short: Smoothed Composite RSI crosses into the overbought zone
Long: At a confirmed low pivot, price makes a lower low and Smoothed Composite RSI makes a higher low than at the prior qualifying low pivot, both RSI pivots at or below the oversold level, and the pivots are no more than the maximum lookback apart
Short: At a confirmed high pivot, price makes a higher high and Smoothed Composite RSI makes a lower high than at the prior qualifying high pivot, both RSI pivots at or above the overbought level, and the pivots are no more than the maximum lookback apart