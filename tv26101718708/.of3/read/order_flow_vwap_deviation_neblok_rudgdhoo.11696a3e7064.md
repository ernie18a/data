Calculation: Estimated buy volume = on each chart bar, sum over its T2 intrabars, including any still forming, of volume × (close − low) / (high − low) when high > low, or volume / 2 otherwise; use the chart bar itself when no T2 intrabars are available
Calculation: Estimated sell volume = on each chart bar, sum over its T2 intrabars of volume − estimated buy volume for each intrabar; use the chart bar itself when no T2 intrabars are available
Calculation: Bar delta = estimated buy volume − estimated sell volume
Calculation: Upper flow deviation = square root of the sum over chart bars in the current T1 anchor period of estimated buy volume × (source − Anchored VWAP(source, estimated buy volume + estimated sell volume, T1))², divided by the sum of estimated buy volume; zero if that sum is zero
Calculation: Lower flow deviation = square root of the sum over chart bars in the current T1 anchor period of estimated sell volume × (source − Anchored VWAP(source, estimated buy volume + estimated sell volume, T1))², divided by the sum of estimated sell volume; zero if that sum is zero
Calculation: Inner upper band = Anchored VWAP(source, estimated buy volume + estimated sell volume, T1) + inner multiplier × upper flow deviation
Calculation: Outer upper band = Anchored VWAP(source, estimated buy volume + estimated sell volume, T1) + outer multiplier × upper flow deviation
Calculation: Inner lower band = Anchored VWAP(source, estimated buy volume + estimated sell volume, T1) − inner multiplier × lower flow deviation
Calculation: Outer lower band = Anchored VWAP(source, estimated buy volume + estimated sell volume, T1) − outer multiplier × lower flow deviation
Calculation: Selected upper rejection band = inner upper band or outer upper band according to the signal-band parameter
Calculation: Selected lower rejection band = inner lower band or outer lower band according to the signal-band parameter
Calculation: Anchor delta = sum of bar delta over chart bars in the current T1 anchor period
Calculation: Band skew = upper flow deviation / lower flow deviation when lower flow deviation > 0, otherwise 1
Calculation: VWAP deviation score = (close − Anchored VWAP) / upper flow deviation when close ≥ Anchored VWAP and upper flow deviation > 0; (close − Anchored VWAP) / lower flow deviation when close < Anchored VWAP and lower flow deviation > 0; otherwise 0
Calculation: Profile row buy and sell volumes = distribute each of the capped recent chart bars in the current T1 anchor period across equal-price rows from the bars’ minimum low to maximum high, allocating each bar’s estimated buy and sell volume in proportion to each row’s overlap with the bar’s high-low range; allocate all volume to one row when the bar range is zero or both extremes fall in the same row
Calculation: Profile row ratio = min(max(profile row buy volume, profile row sell volume) / max(min(profile row buy volume, profile row sell volume), denominator floor), maximum ratio cap)
Long: not an anchor-reset bar AND (closed-bar-only setting is disabled OR the chart bar is closed) AND bars since anchor reset ≥ warm-up parameter AND bars since the prior bullish rejection > cooldown parameter AND low ≤ selected lower rejection band AND close > selected lower rejection band AND (flow-confirmation setting is disabled OR bar delta > 0)
Short: not an anchor-reset bar AND (closed-bar-only setting is disabled OR the chart bar is closed) AND bars since anchor reset ≥ warm-up parameter AND bars since the prior bearish rejection > cooldown parameter AND high ≥ selected upper rejection band AND close < selected upper rejection band AND (flow-confirmation setting is disabled OR bar delta < 0)
Long: on chart bar close, close crosses above outer upper band AND not an anchor-reset bar
Short: on chart bar close, close crosses below outer lower band AND not an anchor-reset bar
Long: on chart bar close, close crosses above Anchored VWAP(source, estimated buy volume + estimated sell volume, T1) AND not an anchor-reset bar
Short: on chart bar close, close crosses below Anchored VWAP(source, estimated buy volume + estimated sell volume, T1) AND not an anchor-reset bar
Long: close ≥ Anchored VWAP(source, estimated buy volume + estimated sell volume, T1)
Short: close < Anchored VWAP(source, estimated buy volume + estimated sell volume, T1)
Long: VWAP deviation score ≥ outer multiplier
Short: VWAP deviation score ≤ −outer multiplier
Long: Band skew > upper skew threshold
Short: Band skew < lower skew threshold
Long: Anchor delta ≥ 0
Short: Anchor delta < 0
Long: a profile row has positive volume, profile row volume ≥ POC row volume × minimum row-volume fraction, profile row ratio ≥ imbalance-ratio threshold, and profile row buy volume ≥ profile row sell volume
Short: a profile row has positive volume, profile row volume ≥ POC row volume × minimum row-volume fraction, profile row ratio ≥ imbalance-ratio threshold, and profile row sell volume > profile row buy volume