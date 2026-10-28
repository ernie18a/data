Calculation: High-volume bar = volume is an unusually large positive deviation from its EMA, using a rolling maximum of that deviation as the reference; bullish/bearish requires close > open / close < open.
Calculation: Bullish/bearish CISD = on a higher-timeframe low/high sweep, the lower-timeframe close crosses above/below the selected reversal level after a high-volume bar overlaps the sweep zone, the zone has at least the configured number of chart bars, and its height is at most 1.6 times the largest chart-bar body in the zone; invalidate bullish/bearish CISD if price makes a new low/high beyond the sweep extreme. Sweep and CISD calculations use the currently forming higher-timeframe and middle-timeframe bars; the reversal-level search uses completed middle-timeframe bars.
Calculation: EMA-compression setup = the historical lower Ichimoku cloud boundary lies between the short and medium EMAs on three consecutive bars, within the configured lookback after a bullish or bearish CISD event.
Calculation: Bullish/bearish momentum alignment = on each of three progressively slower minute timeframes, +DI > −DI and MACD > signal / −DI > +DI and MACD < signal.
Calculation: Cloud breakout = close is above both historical Ichimoku cloud tops / below both historical cloud bottoms.
Calculation: Recent compression = an EMA-compression setup occurred within the configured lookback.
Calculation: Valid wall = no active wall exists, or the tracked range extends beyond the wall in the trade direction and does not contain the wall. The active wall is the overlap of the latest qualifying volume zones from three progressively slower intraday timeframes, if present; otherwise it is the latest completed session-volume wall.
Calculation: SK up/down = two bars ago is bearish/bullish, the previous bar is bullish/bearish, its body extreme is higher/lower than the two-bars-ago body extreme, and its volume is no greater than the two-bars-ago volume.
Long: bullish momentum alignment changes from false to true AND recent compression AND close > both cloud tops AND a bullish or bearish CISD event occurred within the configured lookback AND valid wall for a buy.
Short: bearish momentum alignment changes from false to true AND recent compression AND close < both cloud bottoms AND a bullish or bearish CISD event occurred within the configured lookback AND valid wall for a sell.
Long: within the configured bars after the latest buy breakout and after compression, SK up AND close is outside both clouds AND no plan-dead signal has occurred.
Short: within the configured bars after the latest sell breakout and after compression, SK down AND close is outside both clouds AND no plan-dead signal has occurred.
Long: bullish CISD becomes active.
Short: bearish CISD becomes active.
Long: exactly three bars after bullish CISD first becomes active, it remains active and its reversal level is unchanged.
Short: exactly three bars after bearish CISD first becomes active, it remains active and its reversal level is unchanged.
Exit: long, within the configured bars after the latest buy breakout, (SK up OR SK down) AND close is inside either cloud AND no plan-dead signal has occurred.
Exit: short, within the configured bars after the latest sell breakout, (SK up OR SK down) AND close is inside either cloud AND no plan-dead signal has occurred.