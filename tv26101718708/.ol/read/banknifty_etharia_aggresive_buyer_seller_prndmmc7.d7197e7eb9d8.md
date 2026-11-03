Calculation: Linear regression of close = current endpoint of the least-squares linear regression of close over a configured lookback
Calculation: Linear regression slope = current linear regression of close − its prior-bar value
Calculation: Cumulative volume delta = cumulative sum of volume on bars where close > open minus volume on bars where close < open; unchanged on doji bars
Calculation: Candle body ratio = abs(close − open) / (high − low), or 0 when high = low
Calculation: Initial risk distance = for long, entry price − stop price; for short, stop price − entry price; stop price is selected by configured stop method: entry price offset by configured ATR multiple, the farther of the configured ATR offset and lookback swing extreme, or a configured fixed distance
Calculation: Target 1 = entry price + (long) or − (short) initial risk distance × configured first reward multiple
Calculation: Target 2 = entry price + (long) or − (short) initial risk distance × configured second reward multiple
Calculation: Active stop = trailing stop when trailing is active and enabled; otherwise stop price
Long: linear regression slope > 0 AND close > linear regression of close AND close > VWAP AND VWAP > its prior-bar value AND (CVD > its moving average AND CVD > each of its preceding two bars OR CVD filter disabled) AND (RSI > configured oversold threshold AND RSI < configured overbought threshold OR RSI filter disabled) AND (volume > its moving average × configured volume multiplier OR volume > prior-bar volume AND prior-bar volume > volume two bars ago) AND close > open AND candle body ratio >= configured minimum AND high − low >= configured minimum candle size AND close >= high − (high − low) × 0.25 AND inside configured trading session AND past configured opening-bar exclusion AND flat position AND within configured daily trade, consecutive-loss, and daily profit/loss limits AND long trading enabled
Short: linear regression slope < 0 AND close < linear regression of close AND close < VWAP AND VWAP < its prior-bar value AND (CVD < its moving average AND CVD < each of its preceding two bars OR CVD filter disabled) AND (RSI < configured overbought threshold AND RSI > configured oversold threshold OR RSI filter disabled) AND (volume > its moving average × configured volume multiplier OR volume > prior-bar volume AND prior-bar volume > volume two bars ago) AND close < open AND candle body ratio >= configured minimum AND high − low >= configured minimum candle size AND close <= low + (high − low) × 0.25 AND inside configured trading session AND past configured opening-bar exclusion AND flat position AND within configured daily trade, consecutive-loss, and daily profit/loss limits AND short trading enabled
Exit: long, low <= active stop
Exit: long, high >= Target 1 AND Target 1 not previously hit
Exit: long, high >= Target 2
Exit: long, current time >= configured session end minus the configured pre-close interval
Exit: long, Target 1 previously hit AND ((close < linear regression of close AND linear regression slope < 0) OR close < VWAP)
Exit: short, high >= active stop
Exit: short, low <= Target 1 AND Target 1 not previously hit
Exit: short, low <= Target 2
Exit: short, current time >= configured session end minus the configured pre-close interval
Exit: short, Target 1 previously hit AND ((close > linear regression of close AND linear regression slope > 0) OR close > VWAP)