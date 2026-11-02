Calculation: EMA upper boundary = maximum of the shorter-lookback and longer-lookback EMAs of close plus an optional ATR multiplied by a nonnegative parameter; calculate all components on the same timeframe.
Calculation: EMA lower boundary = minimum of the shorter-lookback and longer-lookback EMAs of close minus the same optional ATR buffer; calculate all components on the same timeframe.
Calculation: Previous-period midpoint = (high + low) / 2 of the previous completed higher-timeframe daily bar. The previous-period close is its close. Map both to chart bars with lookahead off.
Calculation: Opening-range midpoint = (highest high + lowest low) / 2 of chart bars in a configurable opening session and timezone, reset each local day; it is available after the opening session ends.
Calculation: Session VWAP = cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative volume, reset at each trading session.
Long: Close > EMA upper boundary on any of the three successively shorter higher timeframes, using the last completed bar with lookahead off.
Short: Close < EMA lower boundary on any of the three successively shorter higher timeframes, using the last completed bar with lookahead off.
Long: Chart close > the selected previous-period midpoint, previous-period close, or both.
Short: Chart close < the selected previous-period midpoint, previous-period close, or both.
Long: Chart close > session VWAP.
Short: Chart close < session VWAP.
Long: Opening-range midpoint is available AND chart close > opening-range midpoint.
Short: Opening-range midpoint is available AND chart close < opening-range midpoint.
Long: Close > EMA upper boundary on a configurable lower timeframe, using the last completed bar selected with lookahead off.
Short: Close < EMA lower boundary on a configurable lower timeframe, using the last completed bar selected with lookahead off.
Long: Lower-timeframe close > session VWAP, using the lower-timeframe close selected with lookahead off.
Short: Lower-timeframe close < session VWAP, using the lower-timeframe close selected with lookahead off.
Long: Close > EMA upper boundary on both longer higher timeframes AND, if the previous-period filter is enabled, chart close > the selected previous-period midpoint, previous-period close, or both.
Short: Close < EMA lower boundary on both longer higher timeframes AND, if the previous-period filter is enabled, chart close < the selected previous-period midpoint, previous-period close, or both.
Long: Close > EMA upper boundary on the shortest higher timeframe AND, if enabled, chart close > session VWAP AND, if enabled, opening-range midpoint is available and chart close > opening-range midpoint.
Short: Close < EMA lower boundary on the shortest higher timeframe AND, if enabled, chart close < session VWAP AND, if enabled, opening-range midpoint is available and chart close < opening-range midpoint.
Long: Lower-timeframe close > EMA upper boundary AND, if enabled, lower-timeframe close > chart session VWAP.
Short: Lower-timeframe close < EMA lower boundary AND, if enabled, lower-timeframe close < chart session VWAP.
Long: The lower-timeframe long condition is true on the current chart bar AND was false on the previous chart bar.
Short: The lower-timeframe short condition is true on the current chart bar AND was false on the previous chart bar.
Long: Close > EMA upper boundary on all three higher timeframes AND, if enabled, chart close > the selected previous-period midpoint, previous-period close, or both AND, if enabled, chart close > session VWAP AND, if enabled, opening-range midpoint is available and chart close > opening-range midpoint.
Short: Close < EMA lower boundary on all three higher timeframes AND, if enabled, chart close < the selected previous-period midpoint, previous-period close, or both AND, if enabled, chart close < session VWAP AND, if enabled, opening-range midpoint is available and chart close < opening-range midpoint.