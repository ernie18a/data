Calculation: WaveTrend fast = EMA of (HLC3 − EMA(HLC3, channel lookback)) / (0.015 × EMA(|HLC3 − EMA(HLC3, channel lookback)|, same lookback)), using the average lookback
Calculation: WaveTrend slow = 3-bar SMA of WaveTrend fast
Calculation: Stochastic RSI K = SMA of Stochastic(RSI(log(close)), RSI(log(close)), RSI(log(close)), stochastic lookback), using the K smoothing lookback
Calculation: Stochastic RSI D = SMA of Stochastic RSI K, using the D smoothing lookback
Calculation: RSI = RSI(close, lookback)
Calculation: Regular bullish stochastic RSI divergence = a confirmed 5-bar low pivot in K has a lower low in price and a higher K value than the preceding confirmed 5-bar low pivot
Calculation: Regular bearish stochastic RSI divergence = a confirmed 5-bar high pivot in K has a higher high in price and a lower K value than the preceding confirmed 5-bar high pivot
Calculation: Hidden bullish stochastic RSI divergence = a confirmed 5-bar low pivot in K has a higher low in price and a lower K value than the preceding confirmed 5-bar low pivot
Calculation: Hidden bearish stochastic RSI divergence = a confirmed 5-bar high pivot in K has a lower high in price and a higher K value than the preceding confirmed 5-bar high pivot
Calculation: Regular bullish WaveTrend divergence = a confirmed 5-bar low pivot in WaveTrend fast has a lower low in price and a higher WaveTrend fast value than the preceding confirmed 5-bar low pivot
Calculation: Regular bearish WaveTrend divergence = a confirmed 5-bar high pivot in WaveTrend fast has a higher high in price and a lower WaveTrend fast value than the preceding confirmed 5-bar high pivot
Calculation: Regular bullish slow WaveTrend divergence = a confirmed 5-bar low pivot in WaveTrend slow has a lower low in price and a higher WaveTrend slow value than the preceding confirmed 5-bar low pivot
Calculation: Regular bearish slow WaveTrend divergence = a confirmed 5-bar high pivot in WaveTrend slow has a higher high in price and a lower WaveTrend slow value than the preceding confirmed 5-bar high pivot
Calculation: Bullish RSI divergence = prior bar's close is a new high above the preceding bar's close, prior bar's RSI is below the tracked RSI high, current RSI is no greater than prior RSI, and prior RSI is at least the bearish RSI threshold
Calculation: Bearish RSI divergence = prior bar's close is a new low below the preceding bar's close, prior bar's RSI is above the tracked RSI low, current RSI is no less than prior RSI, and prior RSI is at most the bullish RSI threshold
Calculation: Hidden bearish RSI divergence = prior bar's close is below the preceding bar's close and prior bar's RSI is below the tracked RSI high
Calculation: Hidden bullish RSI divergence = prior bar's close is above the preceding bar's close and prior bar's RSI is above the tracked RSI low
Calculation: Money flow = SMA((close − open) / (high − low), lookback)
Long: WaveTrend fast crosses above WaveTrend slow OR WaveTrend fast crosses above WaveTrend slow and WaveTrend slow is below −59 OR regular bullish stochastic RSI divergence OR (hidden bullish stochastic RSI divergence and hidden divergences are enabled) OR bullish RSI divergence OR hidden bullish RSI divergence OR (regular bullish WaveTrend divergence and WaveTrend slow − WaveTrend fast ≤ 0) OR (regular bullish slow WaveTrend divergence and WaveTrend slow − WaveTrend fast ≤ 0) OR Money flow > 0
Short: WaveTrend slow crosses above WaveTrend fast OR WaveTrend slow crosses above WaveTrend fast and WaveTrend fast is above 59 OR regular bearish stochastic RSI divergence OR (hidden bearish stochastic RSI divergence and hidden divergences are enabled) OR bearish RSI divergence OR hidden bearish RSI divergence OR (regular bearish WaveTrend divergence and WaveTrend slow − WaveTrend fast ≥ 0) OR (regular bearish slow WaveTrend divergence and WaveTrend slow − WaveTrend fast ≥ 0) OR Money flow ≤ 0
Exit: long, WaveTrend slow crosses above WaveTrend fast
Exit: short, WaveTrend fast crosses above WaveTrend slow