Calculation: Candle body % = 100 × abs(close − open) / (high − low), or 0 when high = low
Calculation: Bullish engulfing = previous close < previous open AND current close > current open AND current body % ≥ configured minimum AND (strict mode: current open < previous close AND current close > previous open; otherwise current open ≤ previous close AND current close ≥ previous open) AND (close-beyond-previous-open requirement disabled OR current close > previous open)
Calculation: Bearish engulfing = previous close > previous open AND current close < current open AND current body % ≥ configured minimum AND (strict mode: current open > previous close AND current close < previous open; otherwise current open ≥ previous close AND current close ≤ previous open) AND (close-beyond-previous-open requirement disabled OR current close < previous open)
Calculation: Morning Star = candle two bars ago closes below its open AND its body % ≥ configured outer-candle minimum AND intervening candle body % ≤ configured middle-candle maximum AND current candle closes above its open AND its body % ≥ configured outer-candle minimum AND current close > candle-two-bars-ago open − (configured penetration fraction × its body size)
Calculation: Evening Star = candle two bars ago closes above its open AND its body % ≥ configured outer-candle minimum AND intervening candle body % ≤ configured middle-candle maximum AND current candle closes below its open AND its body % ≥ configured outer-candle minimum AND current close < candle-two-bars-ago open + (configured penetration fraction × its body size)
Calculation: Long trigger = signal candle high + configured entry buffer
Calculation: Short trigger = signal candle low − configured entry buffer
Calculation: Initial long stop = lower of signal candle low and (for engulfing, previous candle low when whole-pattern stops are enabled; for Morning Star, lows of the prior two candles) − configured stop buffer; if trigger − stop is less than configured minimum stop distance, use trigger − minimum stop distance
Calculation: Initial short stop = higher of signal candle high and (for engulfing, previous candle high when whole-pattern stops are enabled; for Evening Star, highs of the prior two candles) + configured stop buffer; if stop − trigger is less than configured minimum stop distance, use trigger + minimum stop distance
Calculation: Risk distance = absolute value of entry price − initial stop
Calculation: Long TP1 = entry price + configured TP1 risk multiple × risk distance
Calculation: Long TP2 = entry price + configured TP2 risk multiple × risk distance
Calculation: Short TP1 = entry price − configured TP1 risk multiple × risk distance
Calculation: Short TP2 = entry price − configured TP2 risk multiple × risk distance
Calculation: Active stop after TP1 = entry price + configured break-even offset for a long position, or entry price − configured break-even offset for a short position, when break-even adjustment is enabled; otherwise retain the initial stop
Long: (Bullish engulfing OR Morning Star) AND (trend filter disabled OR close > EMA) AND long trades enabled
Long: Valid pending long setup AND high ≥ long trigger
Short: (Bearish engulfing OR Evening Star) AND (trend filter disabled OR close < EMA) AND short trades enabled
Short: Valid pending short setup AND low ≤ short trigger
Exit: long, low ≤ active stop
Exit: long, high ≥ long TP1 OR high ≥ long TP2
Exit: short, high ≥ active stop
Exit: short, low ≤ short TP1 OR low ≤ short TP2