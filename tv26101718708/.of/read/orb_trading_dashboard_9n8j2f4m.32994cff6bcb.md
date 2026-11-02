Calculation: Opening range = highest high and lowest low of completed lower-timeframe bars from the regular-session open through a chosen opening window. Use three windows: short, intermediate, and long.
Calculation: Opening-range stages = for each opening window and each side, reset to idle at the start of each trading day. After the window and during the regular session, process completed lower-timeframe bars in order. An idle or failed upside side becomes breakout when close > opening-range high; an active upside side becomes failed when close < opening-range high minus a buffer fraction of the range; otherwise, breakout becomes retest on a later bar with low <= opening-range high, and retest becomes confirmed on a still later bar with close > opening-range high. Apply the mirror image to the downside: close < range low, failure when close > range low plus the buffer, retest when high >= range low, and confirmation when close < range low. Record the time of each stage change. The net stage is the active side's stage; if both sides are active, use the side with the latest stage change, resolving ties upward. If one side is at breakout and the opposite side has failed, promote its net stage to retest. If neither side is active, the net stage is neutral.
Long: Opening-range net stage is upside breakout, retest, or confirmed, for any opening window.
Short: Opening-range net stage is downside breakout, retest, or confirmed, for any opening window.
Long: After an opening window, close > its opening-range high AND its net stage is neutral AND neither side has failed.
Short: After an opening window, close < its opening-range low AND its net stage is neutral AND neither side has failed.
Long: For the short or intermediate opening window, the upside stage changes to confirmed AND this is the first upside confirmation of the day OR repeat confirmations after failure are enabled.
Short: For the short or intermediate opening window, the downside stage changes to confirmed AND this is the first downside confirmation of the day OR repeat confirmations after failure are enabled.
Long: During the regular session after the long opening window, chart-bar close > its opening-range high AND the last alerted non-neutral long-window status that day was not bullish.
Short: During the regular session after the long opening window, chart-bar close < its opening-range low AND the last alerted non-neutral long-window status that day was not bearish.
Long: Close >= session VWAP calculated from chart-bar closes.
Short: Close < session VWAP calculated from chart-bar closes.
Long: Close > high of the last completed higher-timeframe regular-session bar.
Short: Close < low of the last completed higher-timeframe regular-session bar.
Long: Close > current premarket high calculated from completed and forming lower-timeframe bars.
Short: Close < current premarket low calculated from completed and forming lower-timeframe bars.
Long: Close >= midpoint of the current regular-session high and low calculated from completed and forming lower-timeframe bars.
Short: Close < midpoint of the current regular-session high and low calculated from completed and forming lower-timeframe bars.
Long: Close >= open of the forming higher-timeframe period, for either of two periods where one is longer than the other.
Short: Close < open of the forming higher-timeframe period, for either of two periods where one is longer than the other.
Long: Close > SMA or EMA of higher-timeframe regular-session closes, evaluated on the last completed bar, for any of five increasingly long lookbacks.
Short: Close <= SMA or EMA of higher-timeframe regular-session closes, evaluated on the last completed bar, for any of five increasingly long lookbacks.
Long: Close > the middle-lookback higher-timeframe moving average AND absolute distance from that average divided by higher-timeframe ATR is <= an extension threshold, with both calculations evaluated on the last completed regular-session bar.
Short: Close <= the middle-lookback higher-timeframe moving average AND absolute distance from that average divided by higher-timeframe ATR is <= an extension threshold, with both calculations evaluated on the last completed regular-session bar.