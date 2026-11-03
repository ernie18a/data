Calculation: EMA = exponential moving average of close; use shorter, intermediate, and longer lookbacks for EMA9, EMA21, and EMA50
Calculation: 52-bar-year high = highest high over 252 bars
Calculation: EP candle = current close is at least the EP threshold above the previous close
Calculation: Outperformance since EP = stock return from the latest EP candle's close to current close minus benchmark return over the same bars; benchmark bars use the chart timeframe
Calculation: Cloud bounds = EMA9 plus and EMA21 minus the cloud tolerance
Calculation: Pullback volume = current volume divided by its 50-bar simple moving average
Calculation: Coil high = highest high over the bars since the latest EP candle, locked when the setup first becomes true; clear the locked price after three consecutive bars without the setup
Long: setup conditions are true now and were false on the prior bar, and an EP candle is no more than the maximum age, and outperformance since EP >= minimum, and (52-bar-year high - close) / 52-bar-year high <= maximum proximity, and EMA9 > EMA21 > EMA50, and close is between the cloud bounds, and pullback volume <= volume threshold
Long: close > locked coil high and a locked price is active and the prior bar did not meet this trigger condition