Calculation: Overlay OHLCV = chart-timeframe OHLCV, or OHLCV aggregated to a higher timeframe using either the last completed bar or the still-forming bar. When using the higher timeframe, hold the selected completed bar or update the forming bar on each chart bar; advance displayed-bar history at each higher-timeframe boundary.
Calculation: Heikin Ashi OHLC = Heikin Ashi calculated from overlay OHLC, optionally followed by a second Heikin Ashi calculation on the first result. Advance each recursive Heikin Ashi open only at displayed-bar boundaries; update its close on every chart bar.
Calculation: Displayed OHLC = overlay OHLC or Heikin Ashi OHLC; optionally invert each price around a fixed pivot, exchanging high and low after inversion. The pivot is a parameter or the first chart bar's (high + low) / 2.
Calculation: Pattern OHLC = overlay OHLC or displayed OHLC. For pattern history, use consecutive displayed bars. Body = abs(close - open); range = high - low; upper wick = high - max(open, close); lower wick = min(open, close) - low. Pattern context = EMA of pattern close calculated on chart bars, including repeated higher-timeframe values.
Calculation: Line source = overlay open, close, (high + low) / 2, (high + low + close) / 3, or (open + high + low + close) / 4, optionally smoothed by SMA, EMA, WMA, or RMA on chart bars and optionally inverted around the pivot. Baseline = a fixed parameter or the first chart bar's (high + low) / 2, inverted when the line source is inverted.
Calculation: Trend reference = EMA of chart close on chart bars, EMA of displayed Heikin Ashi close on chart bars, or EMA of overlay close calculated in the overlay timeframe. For a higher-timeframe overlay EMA use the still-forming higher-timeframe bar. Compare it respectively with chart close, displayed Heikin Ashi close before inversion, or overlay close before inversion; reverse the comparison when inversion is enabled.
Calculation: Divergence series = overlay OHLCV or inverted overlay OHLC with overlay volume, sampled on chart bars. Oscillator = RSI of close, MACD line of close with a shorter and a longer EMA, stochastic of close and high/low, CCI of (high + low + close) / 3, or MFI of (high + low + close) / 3 and volume. Confirm oscillator pivots after a parameterized number of right-hand chart bars, using a parameterized number of left-hand chart bars; compare each confirmed pivot with the preceding pivot of the same type and use the divergence-series low or high at each oscillator pivot.
Long: Displayed close >= displayed open for candle-direction coloring.
Short: Displayed close < displayed open for candle-direction coloring.
Long: Displayed close >= previous chart bar's displayed close for candle-momentum coloring.
Short: Displayed close < previous chart bar's displayed close for candle-momentum coloring.
Long: Line source >= previous chart bar's line source for line-direction or line-momentum coloring.
Short: Line source < previous chart bar's line source for line-direction or line-momentum coloring.
Long: Trend comparison price > trend reference when inversion is disabled, OR trend comparison price < trend reference when inversion is enabled.
Short: Trend comparison price <= trend reference when inversion is disabled, OR trend comparison price >= trend reference when inversion is enabled.
Long: Displayed Heikin Ashi close >= open AND previous chart bar's displayed Heikin Ashi close < open.
Short: Displayed Heikin Ashi close < open AND previous chart bar's displayed Heikin Ashi close >= open.
Long: Displayed Heikin Ashi close >= open AND abs(low - min(open, close)) < wick tolerance.
Short: Displayed Heikin Ashi close < open AND abs(high - max(open, close)) < wick tolerance.
Long: Line source >= baseline.
Short: Line source < baseline.
Long: Line source > baseline AND previous chart bar's line source <= previous baseline.
Short: Line source < baseline AND previous chart bar's line source >= previous baseline.
Long: Pattern range > 0 AND body > 0 AND lower wick >= body multiplied by a lower-wick ratio AND upper wick <= body AND close < pattern context.
Long: Pattern range > 0 AND body > 0 AND upper wick >= body multiplied by an upper-wick ratio AND lower wick <= body AND close < pattern context.
Short: Pattern range > 0 AND body > 0 AND lower wick >= body multiplied by the same lower-wick ratio AND upper wick <= body AND close > pattern context.
Short: Pattern range > 0 AND body > 0 AND upper wick >= body multiplied by the same upper-wick ratio AND lower wick <= body AND close > pattern context.
Long: Pattern range > 0 AND body <= range multiplied by a doji threshold AND lower wick >= range multiplied by a long-wick threshold AND upper wick <= range multiplied by a small-wick threshold.
Short: Pattern range > 0 AND body <= range multiplied by the same doji threshold AND upper wick >= range multiplied by the same long-wick threshold AND lower wick <= range multiplied by the same small-wick threshold.
Long: Pattern range > 0 AND close > open AND body >= range multiplied by a body threshold.
Short: Pattern range > 0 AND close < open AND body >= range multiplied by the same body threshold.
Long: Previous pattern close < previous open AND current close > open AND abs(current low - previous low) <= max(tick tolerance, current range multiplied by a range tolerance).
Short: Previous pattern close > previous open AND current close < open AND abs(current high - previous high) <= max(tick tolerance, current range multiplied by the same range tolerance).
Long: Pattern close > open AND previous close < previous open AND close >= previous open AND open <= previous close.
Short: Pattern close < open AND previous close > previous open AND open >= previous close AND close <= previous open.
Long: Previous pattern close < previous open AND current close > open AND current open >= previous close AND current close <= previous open AND current body < previous body.
Short: Previous pattern close > previous open AND current close < open AND current open <= previous close AND current close >= previous open AND current body < previous body.
Long: Pattern close two displayed bars ago < its open AND previous body < body two displayed bars ago multiplied by a small-body ratio AND current close > open AND current close > (open + close) two displayed bars ago / 2.
Short: Pattern close two displayed bars ago > its open AND previous body < body two displayed bars ago multiplied by the same small-body ratio AND current close < open AND current close < (open + close) two displayed bars ago / 2.
Long: Pattern closes exceed opens on the current and previous two displayed bars AND current close > previous close AND previous close > close two bars ago AND current open < previous close AND current open > previous open AND previous open < close two bars ago AND previous open > open two bars ago.
Short: Pattern closes are below opens on the current and previous two displayed bars AND current close < previous close AND previous close < close two bars ago AND current open > previous close AND current open < previous open AND previous open > close two bars ago AND previous open < open two bars ago.
Long: Previous pattern close < previous open AND current close > current open AND current open < previous close AND current close > (previous open + previous close) / 2 AND current close < previous open.
Short: Previous pattern close > previous open AND current close < current open AND current open > previous close AND current close < (previous open + previous close) / 2 AND current close > previous open.
Long: A low oscillator pivot is confirmed AND its oscillator value > the preceding low pivot's oscillator value AND its corresponding price low < the preceding low pivot's price low.
Long: A low oscillator pivot is confirmed AND its oscillator value < the preceding low pivot's oscillator value AND its corresponding price low > the preceding low pivot's price low.
Short: A high oscillator pivot is confirmed AND its oscillator value < the preceding high pivot's oscillator value AND its corresponding price high > the preceding high pivot's price high.
Short: A high oscillator pivot is confirmed AND its oscillator value > the preceding high pivot's oscillator value AND its corresponding price high < the preceding high pivot's price high.