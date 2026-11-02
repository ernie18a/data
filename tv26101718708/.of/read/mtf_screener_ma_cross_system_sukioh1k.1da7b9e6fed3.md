Calculation: Selected MA pair = either the shorter-period EMA and longer-period EMA of chart closes, the shorter-period EMA and slow HMA of chart closes, or the longer-period EMA and slow HMA of chart closes; the first MA is the faster member.
Calculation: Screener MA pair = the selected MA pair calculated on a separately selected higher or lower timeframe; use the last completed bar historically and the still-forming bar in real time for a higher timeframe, and the last available lower-timeframe bar for a lower timeframe.
Calculation: Higher-timeframe trend HMA = HMA of higher-timeframe closes; use the last completed higher-timeframe bar historically and the still-forming bar in real time.
Calculation: Risk distance = entry price multiplied by the stop percentage in percentage risk mode, or current chart-timeframe ATR multiplied by the stop multiplier in ATR risk mode; recalculate on every bar.
Calculation: Target distance = entry price multiplied by the target percentage in percentage risk mode, or current chart-timeframe ATR multiplied by the stop multiplier and risk/reward multiplier in ATR risk mode; recalculate on every bar.
Calculation: Current risk/reward = (close − entry price) / risk distance for a long position, or (entry price − close) / risk distance for a short position; use the minimum price tick as the denominator if risk distance is smaller.
Calculation: Break-even activation = in break-even mode, current risk/reward has reached the break-even threshold since the position was opened; in partial or advanced mode, current risk/reward has reached the partial-exit threshold since the position was opened; reset on a flat position.
Calculation: Long stop = entry price − risk distance before break-even activation or in basic mode; entry price after activation in break-even or partial mode; maximum of entry price and close − ATR multiplied by the trailing multiplier after activation in advanced mode. Recalculate on every bar.
Calculation: Short stop = entry price + risk distance before break-even activation or in basic mode; entry price after activation in break-even or partial mode; minimum of entry price and close + ATR multiplied by the trailing multiplier after activation in advanced mode. Recalculate on every bar.
Long: Faster selected MA crosses above slower selected MA.
Short: Faster selected MA crosses below slower selected MA.
Long: Faster selected MA > slower selected MA.
Short: Faster selected MA <= slower selected MA.
Long: Faster selected MA crosses above slower selected MA AND close > higher-timeframe trend HMA.
Short: Faster selected MA crosses below slower selected MA AND close < higher-timeframe trend HMA.
Long: Bars since the screener pair's faster MA last crossed above its slower MA < bars since it last crossed below; both crosses must have occurred.
Short: Bars since the screener pair's faster MA last crossed below its slower MA < bars since it last crossed above; both crosses must have occurred.
Exit: long, low <= previously submitted long stop OR high >= previously submitted entry price + target distance.
Exit: short, high >= previously submitted short stop OR low <= previously submitted entry price − target distance.
Exit: long, partial or advanced management mode AND current risk/reward >= partial-exit threshold AND no partial exit has occurred in the current position; close the configured fraction.
Exit: short, partial or advanced management mode AND current risk/reward >= partial-exit threshold AND no partial exit has occurred in the current position; close the configured fraction.