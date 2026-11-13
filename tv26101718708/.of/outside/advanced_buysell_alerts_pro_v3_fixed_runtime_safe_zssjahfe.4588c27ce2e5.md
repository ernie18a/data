Long-only daily swing scanner over a fixed watchlist of stocks. Each stock is evaluated independently on its own bar-close data, combined with a market-wide regime filter that uses data from other instruments.

Market regime (gate for all stocks):
- Trend filter, which can be switched off: the close of a broad Nasdaq-100 ETF (QQQ) must be above its own 200-period simple moving average.
- Volatility filter, which can be switched off: the close of the VIX index must be below a configurable threshold.
- If either enabled filter fails, or its data is missing, no stock can signal.

Per-stock score, an integer from 0 to 5. Add one point for each condition that is true:
1. Trend alignment: close > 50-period SMA > 150-period SMA > 200-period SMA.
2. Momentum: 14-period RSI lies within a configurable min-max band.
3. Volume surge: the 5-period average volume divided by the 20-period average volume is at least a multiplier.
4. Volatility band: 14-period ATR as a percent of close lies between a min and a max.
5. Proximity to the high: the close is below the highest high of the last 252 bars by at least 1% and by no more than a configurable max percent.

Entry (go long):
- The stock's data must be valid: close, ATR and score are available, and close and ATR are both positive.
- The regime gate must pass.
- The score must be at least a configurable minimum.
- When all three hold, emit a BUY for that stock once per confirmed bar close. The stock's own bar data is taken without lookahead.

Exit and risk levels at signal time:
- Stop = close minus ATR times a stop multiplier.
- Target = close plus ATR times a target multiplier.
- Risk/reward = (target - close) / (close - stop). The signal is valid only if this is computable and the stop is below the close.

There are no short signals and no other exit rules. The stop and target are reported levels only. When the conditions are not met there is no signal for that stock. The count of active BUY stocks across the watchlist is plotted.