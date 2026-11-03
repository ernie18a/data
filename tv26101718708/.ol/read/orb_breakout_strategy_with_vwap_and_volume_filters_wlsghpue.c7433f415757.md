Calculation: ORB High = highest high of the first N bars of the trading session
Calculation: ORB Low = lowest low of the first N bars of the trading session
Calculation: Session VWAP = cumulative volume-weighted average of (high + low + close) / 3 from the session start
Calculation: VWAP slope = current session VWAP minus session VWAP N bars earlier
Calculation: Close position = (close - low) / (high - low); when high equals low, use 0.5
Long: flat AND trades today < daily trade limit AND in trading session AND ORB ready AND (VWAP filter disabled OR (close > session VWAP AND VWAP slope > minimum slope)) AND (volume filter disabled OR volume >= minimum volume) AND (candle filter disabled OR close position >= minimum candle strength) AND close < ORB High AND high >= ORB High
Short: flat AND trades today < daily trade limit AND in trading session AND ORB ready AND (VWAP filter disabled OR (close < session VWAP AND VWAP slope < negative minimum slope)) AND (volume filter disabled OR volume >= minimum volume) AND (candle filter disabled OR close position <= 1 - minimum candle strength) AND close > ORB Low AND low <= ORB Low
Exit: long, high >= take profit level OR low <= stop level OR trading session ends
Exit: short, low <= take profit level OR high >= stop level OR trading session ends
Exit: long, high >= breakeven trigger
Exit: short, low <= breakeven trigger