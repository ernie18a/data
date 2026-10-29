Calculation: Efficient Work = (close − previous close) / ((high − min(open, previous close)) + (max(open, previous close) − low)); when the denominator is zero, Efficient Work = 0
Calculation: Signal = configured moving average of Efficient Work
Calculation: Aggregate signal = weighted average of chart, medium-timeframe, and highest-timeframe signals, using only available timeframe values
Calculation: Hi/Lo channel = highest and lowest Main Line values over the configured lookback; comparisons use the prior bar’s channel values
Calculation: Divergence level = Main Line value on the latest bar where rounded bar direction differs from whether Signal is rising
Calculation: High volatility = short-term ATR > long-term ATR
Long: every enabled condition is bullish: Main Line > 0; Main Line > prior channel high; Main Line > divergence level; Main Line > medium-timeframe signal; Main Line > highest-timeframe signal; chart-timeframe signal > medium-timeframe signal; chart-timeframe signal > highest-timeframe signal; medium-timeframe signal > 0; highest-timeframe signal > 0; and the configured volatility filter passes
Short: every enabled condition is bearish: Main Line < 0; Main Line < prior channel low; Main Line < divergence level; Main Line < medium-timeframe signal; Main Line < highest-timeframe signal; chart-timeframe signal < medium-timeframe signal; chart-timeframe signal < highest-timeframe signal; medium-timeframe signal < 0; highest-timeframe signal < 0; and the configured volatility filter passes
Exit: