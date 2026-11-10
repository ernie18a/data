Calculation: Opening range high and low = highest high and lowest low of the first configured number of chart bars in each trading session; ready on the last of those bars.
Calculation: Session VWAP = cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative volume, reset at session start; retain its last value outside the session.
Calculation: VWAP change = session VWAP minus its value a configured number of chart bars ago; substitute zero if the earlier value is unavailable.
Calculation: Close position = (close - low) / (high - low), or 0.5 when high equals low.
Calculation: Long pending order = position is flat AND session trade count is below its limit AND current bar is in session AND opening range is ready AND close < opening range high AND (VWAP filter disabled OR (close > session VWAP AND VWAP change > positive slope threshold)) AND (volume filter disabled OR volume >= minimum volume) AND (candle filter disabled OR close position >= strength threshold).
Calculation: Short pending order = position is flat AND session trade count is below its limit AND current bar is in session AND opening range is ready AND close > opening range low AND (VWAP filter disabled OR (close < session VWAP AND VWAP change < negative slope threshold)) AND (volume filter disabled OR volume >= minimum volume) AND (candle filter disabled OR close position <= 1 - strength threshold).
Calculation: Session trade count = number of positions opened since session start, reset at session start.
Calculation: Long target and initial stop = entry price plus configured target distance and entry price minus configured stop distance in fixed-distance mode; otherwise entry price plus a configured reward multiple of max(entry price minus entry-bar low, minimum risk) and entry-bar low.
Calculation: Short target and initial stop = entry price minus configured target distance and entry price plus configured stop distance in fixed-distance mode; otherwise entry price minus a configured reward multiple of max(entry-bar high minus entry price, minimum risk) and entry-bar high.
Calculation: Active stop = initial stop until breakeven is enabled and a bar's high reaches entry price plus a configured fraction of the long target distance, or a bar's low reaches entry price minus that fraction of the short target distance; thereafter entry price. The updated stop applies after the triggering bar closes. Target and initial stop orders are placed after the entry bar closes.
Long: Long pending order.
Long: Previous bar's long pending order AND current high >= opening range high.
Short: Short pending order.
Short: Previous bar's short pending order AND current low <= opening range low.
Exit: long, high >= long target OR low <= active stop OR current bar is outside the trading session AND previous bar was in the trading session.
Exit: short, low <= short target OR high >= active stop OR current bar is outside the trading session AND previous bar was in the trading session.