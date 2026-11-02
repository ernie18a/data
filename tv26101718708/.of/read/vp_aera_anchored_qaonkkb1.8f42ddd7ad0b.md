Calculation: Confirmed swing high and low = the most recent pivot high and pivot low, respectively, confirmed using the same number of bars on each side; update them on the confirmation bar.
Calculation: Structure bias = initially neutral; set bullish when close > confirmed swing high, then set bearish when close < confirmed swing low, so bearish takes priority if both occur. Retain the last bias otherwise.
Calculation: Profile = calculate only on the dataset's last bar, retaining previously calculated values between updates. Use the selected rolling bars-back or date-anchored window, including the current bar. Divide its high-to-low range into equal price rows. Either distribute each bar's volume equally across every row touched by its high-low range, or assign all its volume to the row containing its close; clamp row indices to the profile. POC is the midpoint of the first row with maximum volume. Starting at that row, add the larger-volume adjacent row until the selected fraction of total volume is included, choosing the upper row on ties. VAL and VAH are the lower and upper edges of the resulting contiguous rows. If the price range is zero, use the instrument's minimum tick as row height.
Calculation: Anchored VWAP = volume-weighted average of the selected price source over the profile window, calculated only on the dataset's last bar and retained between updates.
Calculation: Bull pressure = the moving average of volume multiplied by the close's fraction of the bar's low-to-high range, divided by the sum of that average and the moving average of volume multiplied by the remaining fraction. Clamp the fraction to the range from zero to one; use zero for a zero-range bar and missing volume. Use equal lookbacks for both averages and half when their sum is zero. Bear pressure = one minus bull pressure.
Long: Close > confirmed swing high.
Short: Close < confirmed swing low.
Long: Low < confirmed swing low AND close > confirmed swing low.
Short: High > confirmed swing high AND close < confirmed swing high AND NOT (low < confirmed swing low AND close > confirmed swing low).
Long: A confirmed bar satisfies (low < confirmed swing low AND close > confirmed swing low AND close > open when the sweep requirement is enabled, OR close > confirmed swing low AND close > open AND close > previous close when it is disabled) AND (structure confirmation is disabled OR close > the then-current confirmed swing high occurred within the confirmation lookback including this bar) AND (value-area filter is disabled OR VAL is unavailable OR low is within a tolerance fraction of VAH minus VAL from VAL or POC) AND (trend filter is disabled OR close > EMA of close) AND (no previous signal exists OR bars since the last long or short signal >= cooldown).
Short: A confirmed bar satisfies (high > confirmed swing high AND close < confirmed swing high AND close < open when the sweep requirement is enabled, OR close < confirmed swing high AND close < open AND close < previous close when it is disabled) AND (structure confirmation is disabled OR close < the then-current confirmed swing low occurred within the confirmation lookback including this bar) AND (value-area filter is disabled OR VAH is unavailable OR high is within a tolerance fraction of VAH minus VAL from VAH or POC) AND (trend filter is disabled OR close < EMA of close) AND (no previous signal exists OR bars since the last long or short signal >= cooldown) AND the long signal above is false.
Long: Structure bias is bullish.
Short: Structure bias is bearish.
Long: Close > VAH.
Short: Close < VAL.
Long: Bull pressure >= bear pressure.
Short: Bull pressure < bear pressure.
Long: Bull pressure > dominance threshold.
Short: Bear pressure > dominance threshold AND bull pressure <= dominance threshold.
Long: Structure bias is bullish AND bull pressure >= projection threshold AND (POC is unavailable OR close >= POC) AND the short signal above is false.
Short: Structure bias is bearish AND bear pressure >= projection threshold AND (POC is unavailable OR close <= POC) AND the long and short signals above are false.
Long: Anchored VWAP display is enabled AND close > anchored VWAP.
Short: Anchored VWAP display is enabled AND close < anchored VWAP.