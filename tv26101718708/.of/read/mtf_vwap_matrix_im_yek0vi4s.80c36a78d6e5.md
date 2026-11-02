Calculation: Anchored VWAP = cumulative sum of selected price source times volume divided by cumulative volume since the start of the anchor period, including the current chart bar; use the source price when cumulative volume is zero. Each enabled anchor uses a different period; the session anchor resets at the start of the regular session and the others reset at their respective calendar-period boundaries.
Calculation: VWAP slope = percentage change in an anchor's VWAP from its value a lookback number of chart bars ago, divided by that lookback; use zero if the past value is unavailable or zero.
Calculation: Bullish votes = number of enabled anchors for which close > anchored VWAP. Active anchors = number of enabled anchors. Nonbullish votes = active anchors minus bullish votes, including anchors where close equals VWAP or VWAP is unavailable.
Calculation: Candle strength = body weight times min(1, abs(close - open) / (high - low)) plus volume weight times clamp((volume / average volume - volume offset) / volume scale, 0, 1) plus alignment weight times directional alignment. Use zero for the body ratio when high equals low and use 1 for the volume ratio when average volume is unavailable or nonpositive. Average volume is a chart-bar simple moving average including the current bar. Directional alignment is bullish votes / active anchors for close >= open and 1 minus that ratio for close < open; use 0.5 as the ratio when there are no active anchors.
Long: Close > an enabled anchored VWAP.
Short: Close < an enabled anchored VWAP.
Long: Active anchors > 0 AND bullish votes > nonbullish votes.
Short: Active anchors > 0 AND nonbullish votes > bullish votes.
Long: VWAP slope > positive slope threshold for an enabled anchor.
Short: VWAP slope < negative slope threshold for an enabled anchor.
Long: Close >= open AND candle strength >= minimum strength.
Short: Close < open AND candle strength >= minimum strength.
Long: Close > primary anchored VWAP AND previous close <= previous primary anchored VWAP.
Short: Close < primary anchored VWAP AND previous close >= previous primary anchored VWAP.
Long: The session and longer-period anchors are enabled AND session VWAP slope < negative slope threshold AND longer-period VWAP slope > positive slope threshold AND neither opposing-slope divergence condition was true on the previous chart bar.
Short: The session and longer-period anchors are enabled AND session VWAP slope > positive slope threshold AND longer-period VWAP slope < negative slope threshold AND neither opposing-slope divergence condition was true on the previous chart bar.