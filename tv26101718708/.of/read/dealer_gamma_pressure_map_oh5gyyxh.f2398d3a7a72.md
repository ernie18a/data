Calculation: Gamma flip = EMA of VWMA(close, lookback); optionally calculate VWMA on a higher timeframe using its last completed bar, then apply the EMA on the chart timeframe
Calculation: Volatility scale = ATR or standard deviation of close over the Gamma flip lookback; if the selected value is zero, use standard deviation
Calculation: Gamma exposure = (close - Gamma flip) / Volatility scale
Calculation: Gamma velocity = current Gamma exposure - previous chart bar's Gamma exposure
Calculation: Upper/lower zone = Gamma flip +/- Volatility scale * zone multiplier / 2
Calculation: Upper/lower acceleration boundary = Gamma flip +/- Volatility scale * zone multiplier
Long: ADX > trend threshold AND close crosses above the highest high of the prior breakout lookback bars AND close > Upper zone AND Gamma velocity > 0 AND volume > 1.2 * its recent simple moving average AND bars since the previous breakout-long signal >= breakout cooldown
Long: lowest low over the recent reversal lookback bars < Lower acceleration boundary AND close crosses above Lower acceleration boundary AND Gamma velocity > 0 AND RSI < oversold threshold AND bars since the previous reversal signal >= reversal cooldown
Long: ADX < choppy threshold AND lowest low over the recent fade lookback bars <= Lower acceleration boundary AND close crosses above Lower zone AND Gamma velocity > 0 AND bars since the previous fade signal >= fade cooldown
Short: ADX > trend threshold AND close crosses below the lowest low of the prior breakout lookback bars AND close < Lower zone AND Gamma velocity < 0 AND volume > 1.2 * its recent simple moving average AND bars since the previous breakout-short signal >= breakout cooldown
Short: highest high over the recent reversal lookback bars > Upper acceleration boundary AND close crosses below Upper acceleration boundary AND Gamma velocity < 0 AND RSI > overbought threshold AND bars since the previous reversal signal >= reversal cooldown
Short: ADX < choppy threshold AND highest high over the recent fade lookback bars >= Upper acceleration boundary AND close crosses below Upper zone AND Gamma velocity < 0 AND bars since the previous fade signal >= fade cooldown