Calculation: BullDom = 100 * sum of (close-open) over bullish bars in the last N bars / sum of absolute candle bodies over the same N bars (50 if the total is 0); BearDom = 100 * sum of (open-close) over bearish bars in the same window / the same total (50 if the total is 0)
Calculation: BullScore = 0.7*BullDom + 30*(close > SMA(close, N)); BearScore = 0.7*BearDom + 30*(close < SMA(close, N))
Calculation: Bias (evaluated on completed chart bars) = BUY if BullScore > threshold; else SELL if BearScore > threshold; else NEUTRAL
Calculation: FinalBias = Bias of the chart timeframe; optional multi-timeframe variant: compute Bias with identical parameters on three higher-timeframe series (each using the higher-timeframe bar still forming at the current chart bar), then FinalBias = BUY if at least 3 of the 4 Biases (chart + three higher) are BUY, SELL if at least 3 of 4 are SELL, otherwise NEUTRAL
Calculation: Entry = close of the signal bar; SwingLow = lowest low over the last M bars including the current bar; SwingHigh = highest high over the last M bars including the current bar
Calculation: LongSL = SwingLow at signal bar * (1 - buffer%); LongTP = Entry + (Entry - LongSL) * RR; ShortSL = SwingHigh at signal bar * (1 + buffer%); ShortTP = Entry - (ShortSL - Entry) * RR
Long: FinalBias == BUY AND previous bar FinalBias != BUY AND no setup is currently open (enter at Entry)
Short: FinalBias == SELL AND previous bar FinalBias != SELL AND no setup is currently open (enter at Entry)
Exit: long, high >= LongTP OR low <= LongSL (stop loss takes precedence if both occur on the same bar)
Exit: short, low <= ShortTP OR high >= ShortSL (stop loss takes precedence if both occur on the same bar)