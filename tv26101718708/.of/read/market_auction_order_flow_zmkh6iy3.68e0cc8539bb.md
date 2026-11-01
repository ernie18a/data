Calculation: Anchored VWAP bands = anchored VWAP of the selected price source plus or minus a band multiplier times either the volume-weighted standard deviation of that source since the anchor or a percentage of VWAP.
Calculation: Signed bar volume = sum the volume of completed lower-timeframe bars within the chart bar, adding volume when their close >= open and subtracting it otherwise; if lower-timeframe bars are unavailable, use chart-bar volume with the same sign rule. Delta EMA is the EMA of signed bar volume.
Calculation: SSL direction = 1 when close > SMA(high), -1 when close < SMA(low), and otherwise its previous value, initially 0; both SMAs use the same lookback. SSL bullish state is SMA(high) > SMA(low) when direction >= 0 and SMA(low) > SMA(high) otherwise; SSL bearish state reverses these comparisons. An SSL cross occurs when the corresponding state becomes true after not being true on the preceding bar.
Calculation: Pending SSL direction = on an eligible SSL cross, set the pending direction to that cross and record its bar. Eligibility requires the same-direction confirmed signal cooldown to have elapsed and, if alternation is enabled, the last confirmed signal to have the opposite direction or no last direction. Starting on the next bar, confirm and clear the pending direction if its delta condition holds; otherwise clear it when its age >= expiry or an opposite SSL cross occurs. After clearing, process a new eligible cross on the same bar. Delta confirmation is optional; when enabled, it requires delta EMA > 0 for long or < 0 for short, or, in exhaustion mode, respectively a cross above zero with the minimum delta EMA over the preceding lookback <= negative exhaustion threshold, or a cross below zero with the maximum delta EMA over the preceding lookback >= positive exhaustion threshold. A confirmed signal updates its direction's cooldown and the last confirmed direction.
Calculation: Historical display delta = chart-bar volume when close > open and negative volume when close < open; when close = open, retain the previous bar's sign, initially negative. Historical display tick delta is the same sign with unit magnitude. Historical display point of control equals close.
Long: Close > the upper anchored VWAP band.
Short: Close < the lower anchored VWAP band.
Long: Lower anchored VWAP band - low >= the band multiplied by the minimum penetration percentage AND close > the lower band AND bars since the preceding qualifying lower-band rejection >= rejection cooldown.
Short: High - upper anchored VWAP band >= the band multiplied by the minimum penetration percentage AND close < the upper band AND bars since the preceding qualifying upper-band rejection >= rejection cooldown.
Long: Close crosses above anchored VWAP.
Short: Close crosses below anchored VWAP.
Long: Delta EMA crosses above zero.
Short: Delta EMA crosses below zero.
Long: SSL bullish cross AND same-direction confirmed signal cooldown has elapsed AND optional alternation permits long AND no pending direction remains after processing the previous pending signal.
Short: SSL bearish cross AND same-direction confirmed signal cooldown has elapsed AND optional alternation permits short AND no pending direction remains after processing the previous pending signal.
Long: Pending SSL long direction is confirmed.
Short: Pending SSL short direction is confirmed.
Long: Close > open.
Short: Close <= open.
Long: Historical display delta >= 0 OR historical display tick delta >= 0.
Short: Historical display delta < 0 OR historical display tick delta < 0.
Long: Historical display delta > its previous value AND both values > 0 OR historical display tick delta > its previous value AND both values > 0 OR historical display point of control > its previous value.
Short: Historical display delta < its previous value AND both values < 0 OR historical display tick delta < its previous value AND both values < 0 OR historical display point of control < its previous value.