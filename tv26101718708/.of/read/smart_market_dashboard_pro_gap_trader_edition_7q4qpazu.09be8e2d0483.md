Calculation: Estimated buy volume = volume × (close − low) / (high − low) when high ≠ low; otherwise volume if close ≥ open, else 0. Estimated sell volume = volume − estimated buy volume. Delta = estimated buy volume − estimated sell volume.
Calculation: Daily values = OHLCV aggregated to a higher timeframe representing a trading day; use the last completed daily bar on historical chart bars and the still-forming daily bar in real time. Previous daily close = the close of the daily bar preceding the daily bar used for daily values. Apply estimated buy volume and delta to daily values in the same way as to chart bars.
Calculation: Breakout = close > the highest high over a lookback ending at the preceding chart bar.
Calculation: Intraday pressure = (high > low AND (close − low) / (high − low) > a threshold OR high = low AND close ≥ open) AND delta > volume × a threshold AND volume > its SMA × a multiplier AND breakout.
Calculation: Daily strength = daily open ≠ 0 AND (daily close − daily open) / daily open ≥ a threshold AND daily high > daily low AND (daily close − daily low) / (daily high − daily low) > a threshold.
Calculation: Gap score = the weighted sum of indicators for volume > volume SMA × a multiplier, delta > volume × a threshold, breakout, short-period EMA > long-period EMA, higher-timeframe short-period EMA > higher-timeframe long-period EMA, and RSI > a threshold. The weights are respectively higher, highest, higher, lowest, lowest, and lowest. The EMA pairs use the same respective periods; higher-timeframe EMAs use the last completed bar on historical chart bars and the still-forming bar in real time. Gap probability = the score scaled and capped at its maximum.
Calculation: Sell-to-buy ratio = the sum of estimated sell volume over a lookback divided by the sum of estimated buy volume over the same lookback; use a high fallback value when the buy-volume sum is zero.
Calculation: Order-book score = a capped, piecewise-linear decreasing function of the sell-to-buy ratio: maximum below the first threshold, decreasing at the same rate through the next two successive ratio intervals, then decreasing at a slower rate to a minimum of zero.
Calculation: Delta score = absolute delta / volume scaled and capped at its maximum, or zero when volume is zero. Volume score = volume / volume SMA minus one, scaled and clamped between zero and its maximum; use a ratio of one when the SMA is zero. Price-action score = (close − low) / (high − low) scaled to the score range, or its midpoint when high = low. Trend score = the sum of equal contributions for each of the chart and higher timeframes whose short-period EMA exceeds its long-period EMA. Market-pressure score = weighted sum of order-book, delta, volume, price-action, and trend scores, with weights in decreasing order.
Calculation: Active setup = true after an end-of-day qualifying gap signal, and false after a new trading day, a market-open exit, or a stop-loss hit. Its reference price is updated to the close on every qualifying gap-signal bar and cleared when the setup is cleared. A qualifying gap signal requires gap probability ≥ its threshold AND delta > 0 AND (daily strength AND daily delta > daily volume × a threshold OR intraday pressure) AND daily volume ≥ a threshold AND (daily open ≠ 0 AND (daily high − daily low) / daily open ≥ a threshold OR daily open = 0 AND daily close ≥ daily open) AND (weekday filter disabled OR weekday ≠ the excluded weekday) AND (gap filter disabled OR previous daily close = 0 OR (daily open − previous daily close) / previous daily close ≤ a threshold) AND (order-book filter disabled OR sell-to-buy ratio < a threshold) AND (market-pressure filter disabled OR market-pressure score ≥ a threshold).
Long: Intraday chart AND time within the configured end-of-day window AND qualifying gap signal.
Long: Delta > 0.
Short: Delta ≤ 0.
Long: Daily strength.
Long: Daily delta > daily volume × a threshold.
Long: Intraday pressure.
Long: Gap probability ≥ its threshold.
Long: RSI > its lower threshold AND RSI ≤ its higher threshold.
Short: RSI > its higher threshold.
Long: Higher-timeframe short-period EMA > higher-timeframe long-period EMA.
Short: Higher-timeframe short-period EMA ≤ higher-timeframe long-period EMA.
Short: Order-book filter enabled AND sell-to-buy ratio ≥ its threshold.
Long: Order-book score ≥ a threshold.
Long: Market-pressure score ≥ its upper threshold.
Short: Market-pressure score < its lower threshold.
Exit: long, intraday chart AND time within the configured market-open window AND active setup on the preceding chart bar.
Exit: long, stop loss enabled AND active setup AND close < the setup reference price × (1 − stop-loss percentage).