Calculation: Kernel regression = weighted mean of current and preceding closes through the lookback inclusive, with weight exp(-i² / (2 × (lookback / 2)²)) for offset i; use current close until at least lookback prior bars exist.
Calculation: Heikin-Ashi close = (open + high + low + close) / 4; Heikin-Ashi open = (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2, initialized as (open + close) / 2.
Calculation: Swing high or low = a pivot high or low confirmed using the same number of bars on each side. Store the latest confirmed swing high and low separately; clear the relevant stored swing after its breakout when that side's order blocks are enabled, even if the optional gap filter fails.
Calculation: Support pivot low = a pivot low confirmed using independently specified left and right lookbacks; retain the latest two confirmed values.
Calculation: Estimated buying volume = volume × (close - low) / (high - low), or volume / 2 when high = low; estimated selling volume = volume - estimated buying volume.
Long: Short-term close EMA > kernel regression.
Short: Short-term close EMA <= kernel regression.
Long: Short-term close EMA crosses above kernel regression.
Short: Short-term close EMA crosses below kernel regression.
Long: Close crosses above the stored swing high AND, if the optional gap filter is enabled, low > high two bars earlier on at least one bar from the current bar through the gap lookback AND the current close, or low when high/low mitigation is selected, >= the lowest low among the preceding order-block lookback bars.
Short: Close crosses below the stored swing low AND, if the optional gap filter is enabled, high < low two bars earlier on at least one bar from the current bar through the gap lookback AND the current close, or high when high/low mitigation is selected, <= the highest high among the preceding order-block lookback bars.
Long: Close < close at the setup comparison lookback for exactly the setup-count number of consecutive bars.
Short: Close > close at the setup comparison lookback for exactly the setup-count number of consecutive bars.
Long: On a completed bar, Heikin-Ashi close crosses above the maximum of the short-term close EMA and kernel regression AND Heikin-Ashi close > Heikin-Ashi open.
Long: Close > long-term close EMA.
Short: Close <= long-term close EMA.
Long: Close > short-term close EMA.
Short: Close <= short-term close EMA.
Long: Latest support pivot low > preceding support pivot low.
Short: Latest support pivot low <= preceding support pivot low.
Long: Close > session VWAP of typical price.
Short: Close <= session VWAP of typical price.
Long: Estimated buying volume > estimated selling volume.
Short: Estimated buying volume <= estimated selling volume.