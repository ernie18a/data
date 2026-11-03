Calculation: Buy volume = volume × (close − low) / (high − low); if high = low, use volume when close ≥ open, otherwise zero
Calculation: Sell volume = volume − buy volume
Calculation: Bar delta = buy volume − sell volume
Calculation: Volume spike = current-bar volume > its longer-lookback average volume × a multiplier
Calculation: Breakout = close > the highest high of the preceding shorter-lookback bars
Calculation: Chart-timeframe trend = short-term EMA(close) > long-term EMA(close)
Calculation: Higher-timeframe trend = short-term EMA(close) > long-term EMA(close), calculated on the higher timeframe’s bar still forming
Calculation: RSI = relative strength index of close
Calculation: Daily strength = current daily bar’s close-to-open return exceeds a threshold AND its close is in the upper part of its high-low range; use the higher-timeframe daily bar still forming
Calculation: Daily delta = daily buy volume − (daily volume − daily buy volume), using the higher-timeframe daily bar still forming
Calculation: Intraday limit pressure = close is in the upper part of the bar’s range AND bar delta exceeds a fraction of volume AND volume exceeds its average by a multiplier AND breakout
Calculation: Daily filter = (daily strength AND daily delta exceeds a fraction of daily volume) OR intraday limit pressure
Calculation: Gap probability = capped score from volume spike, positive delta strength, breakout, chart-timeframe trend up, higher-timeframe trend up, and RSI above a threshold
Calculation: Recent sell/buy volume ratio = sum of sell volume over a short lookback / sum of buy volume over the same lookback
Calculation: Order-book score = piecewise score that decreases as the recent sell/buy volume ratio rises
Calculation: Market pressure score = weighted combination of order-book score, absolute delta-to-volume ratio, volume relative to average volume, close’s position within the bar range, and chart-timeframe and higher-timeframe trend directions
Long: No active setup AND current chart bar is intraday and within the configured end-of-day window AND gap probability ≥ its threshold AND bar delta > 0 AND daily filter AND not Thursday when the Thursday filter is enabled AND daily volume ≥ its minimum AND daily range / daily open ≥ its minimum (or, when daily open is zero, daily close ≥ daily open) AND previous daily close is nonzero and current daily open is not more than a threshold above it when the prior-gap filter is enabled (use the previous completed daily bar’s close) AND recent sell/buy volume ratio < its maximum when the order-book filter is enabled AND market pressure score ≥ its minimum when the pressure filter is enabled
Exit: long, (current chart bar is intraday and at the configured market-open time before its cutoff AND a setup was active on the preceding bar) OR (stop loss is enabled AND a setup is active AND close < entry price × (1 − stop-loss percentage))