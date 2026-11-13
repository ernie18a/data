Applies only on weekly or monthly bars. The signal source is always the external BTC index close series, regardless of the traded instrument. Decisions are made on the traded instrument and should be evaluated at bar close.

1. Momentum: compute a logarithmic MACD as log(fast EMA of the BTC index close) minus log(slow EMA of the BTC index close). The EMA lengths are the standard fast and slow MACD pair.

2. Channel: build a top boundary and a bottom boundary as functions of elapsed time since a fixed historical anchor date. Each boundary is a pre-fitted regression to historical LMACD cycle peaks (top) or troughs (bottom). The fit is either logarithmic-in-time or linear-in-time, chosen by user setting. Separate fits exist for weekly and monthly timeframes. On monthly bars the bottom boundary is always the linear fit. The fits are fixed, hardcoded, historical-based coefficients.

3. Risk score: risk = (LMACD - bottom boundary) / (top boundary - bottom boundary). This normalizes the LMACD to roughly 0..1 within the channel and can fall outside that range.

4. Signals:
- Buy (go long) when risk is less than or equal to a low buy threshold, meaning the LMACD is in the oversold zone near the bottom boundary.
- Sell (go short, or exit longs) when risk is greater than or equal to a high sell threshold, meaning the LMACD is in the overbought zone near the top boundary.
- Otherwise neutral, with no signal. A neutral reading means hold the current state or stay flat; the indicator does not define an explicit exit other than the opposite zone.

The buy threshold is below the sell threshold, and both lie within the 0..1 risk scale.