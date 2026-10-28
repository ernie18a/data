Calculation: Session = Asia 18:30–02:00, London 02:00–08:00, or New York 08:00–17:00 America/New_York; session filters use the current session.
Calculation: Dollar direction = current forming daily DXY close > open (strong); close < open (weak).
Calculation: Psychological price = price is within 5 points of a multiple of the configured interval.
Calculation: Supertrend direction = direction from trailing bands based on HLC3 and ATR; band width uses the session-adjusted multiplier.
Calculation: RSI extreme recency = RSI crossed below 30 (long) or above 70 (short) within the lookback.
Long: Supertrend flips short-to-long AND RSI crossed below 30 within the lookback AND signal spacing has elapsed AND session is enabled AND (daily DXY is unavailable OR DXY is weak) AND (volume filter is off OR volume exceeds its moving average by the configured multiplier).
Short: Supertrend flips long-to-short AND RSI crossed above 70 within the lookback AND signal spacing has elapsed AND session is enabled AND (daily DXY is unavailable OR DXY is strong) AND (volume filter is off OR volume exceeds its moving average by the configured multiplier).
Calculation: Stop-run range = highest high and lowest low over the lookback, excluding the current bar.
Long: A confirmed bar pierces the stop-run range low by at least the configured ATR fraction AND lower wick is at least the configured range fraction AND session is enabled; then within the confirmation window, close is at or above the range low, close location is at least 0.58, body/range is at least 0.17, the seed score is at least the minimum score, and (daily DXY is unavailable OR DXY is weak). Seed score = min(100, 60 × lower-wick/range + 30 × penetration/ATR + 10 × volume/volume-average + 8 if low is psychological + 5 if DXY is available and weak).
Short: A confirmed bar pierces the stop-run range high by at least the configured ATR fraction AND upper wick is at least the configured range fraction AND session is enabled; then within the confirmation window, close is at or below the range high, close location is at most 0.42, body/range is at least 0.17, the seed score is at least the minimum score, and (daily DXY is unavailable OR DXY is strong). Seed score = min(100, 60 × upper-wick/range + 30 × penetration/ATR + 10 × volume/volume-average + 8 if high is psychological + 5 if DXY is available and strong).
Calculation: Bullish fair value gap = current low > high two bars earlier and the intervening candle is bullish; bearish fair value gap = current high < low two bars earlier and the intervening candle is bearish.
Calculation: EMA trend = close above all three EMAs (short-term, medium-term, long-term), or below all three; fast-to-medium EMA separation must meet its minimum.
Long: A bearish fair value gap is later closed above its upper boundary AND EMA trend is long AND close is above the fast EMA AND entry is permitted after the cooldown AND session is enabled.
Short: A bullish fair value gap is later closed below its lower boundary AND EMA trend is short AND close is below the fast EMA AND entry is permitted after the cooldown AND session is enabled.
Exit: Long, low <= the lowest low over the swing lookback at entry OR high >= that stop plus the entry-time swing range (highest high minus lowest low over the same lookback).
Exit: Short, high >= the highest high over the swing lookback at entry OR low <= that stop minus the entry-time swing range (highest high minus lowest low over the same lookback).
Calculation: Parabolic SAR direction = close above SAR (long) or below SAR (short).
Long: SAR direction flips short-to-long AND session is enabled.
Short: SAR direction flips long-to-short AND session is enabled.
Long: On a SAR direction flip to long, current low is below the lowest low of the preceding sweep-lookback bars.
Short: On a SAR direction flip to short, current high is above the highest high of the preceding sweep-lookback bars.
Calculation: Coral trend line = the script's repeated EMA of WMA(close); risk bands are the line plus/minus close standard deviation over the base lookback, scaled by the risk threshold (reduced near psychological prices).
Long: Close crosses above the coral trend line AND close is above the upper risk band AND session is enabled AND (daily DXY is unavailable OR DXY is weak).
Short: Close crosses below the coral trend line AND close is below the lower risk band AND session is enabled AND (daily DXY is unavailable OR DXY is strong).
Calculation: Arc momentum = EMA of (RSI minus 50); arc direction changes when momentum crosses the arc by the configured buffer. In Asia, arc speed is reduced and start distance increased.
Long: Arc direction flips bearish-to-bullish AND session is enabled AND (daily DXY is unavailable OR DXY is weak).
Short: Arc direction flips bullish-to-bearish AND session is enabled AND (daily DXY is unavailable OR DXY is strong).
Calculation: Confirmed swing pivot = pivot high or low using the configured left and right lookbacks; use only after the right-side bars complete.
Calculation: Structure break = close crosses above the latest confirmed swing high (bullish) or below the latest confirmed swing low (bearish).
Long: Structure break above the latest swing high while prior structure direction is neutral or bearish AND session is enabled.
Short: Structure break below the latest swing low while prior structure direction is neutral or bullish AND session is enabled.
Calculation: Macro channel = regression line from the active confirmed swing segment, with half-width equal to the greater of maximum segment deviation × channel-width multiplier and ATR × minimum-band multiplier. Micro channel = regression over a shorter lookback than the macro segment, with standard-deviation bands; its direction requires R² above the configured minimum.
Long: Macro direction is down AND close crosses above its upper band (breakout); OR macro direction is up AND close enters the lower-band zone within 0.2 ATR (pullback); OR macro direction is up AND close crosses above the micro upper band with valid micro R² and active segment age within its allowed range (continuation). Require session enabled, corresponding signal type enabled, and its cooldown elapsed.
Short: Macro direction is up AND close crosses below its lower band (breakout); OR macro direction is down AND close enters the upper-band zone within 0.2 ATR (pullback); OR macro direction is down AND close crosses below the micro lower band with valid micro R² and active segment age within its allowed range (continuation). Require session enabled, corresponding signal type enabled, and its cooldown elapsed.
Calculation: Support/resistance zones = clusters of confirmed swing lows/highs, respectively, within an ATR-scaled price tolerance and minimum bar spacing; zone center is volume-, wick-, and age-weighted, with an ATR-scaled zone width. Retain the strongest zones. A zone is broken when close passes beyond its outer edge.
Long: Price touches an active support zone (low <= zone top) AND close >= zone bottom AND close >= open AND zone-specific cooldown has elapsed AND session is enabled.
Short: Price touches an active resistance zone (high >= zone bottom) AND close <= zone top AND close <= open AND zone-specific cooldown has elapsed AND session is enabled.
Long: Within the retest window after a resistance zone breaks, low <= its top AND close >= its bottom AND close >= open.
Short: Within the retest window after a support zone breaks, high >= its bottom AND close <= its top AND close <= open.
Calculation: Harmonic pivots = alternating confirmed swing pivots using the same left/right lookback. Ratios use X-A, A-B, B-C, and X-D leg lengths; each tested ratio must fall within the configured percentage tolerance of its pattern range.
Long: The latest five ordered alternating pivots form a bullish Bat, Gartley, Butterfly, Crab, or Shark by their configured Fibonacci ratio ranges AND session is enabled.
Short: The latest five ordered alternating pivots form a bearish Bat, Gartley, Butterfly, or Crab by their configured Fibonacci ratio ranges AND bearish patterns are enabled AND session is enabled.
Calculation: Fair value gap = current low > high two bars earlier (bullish) or current high < low two bars earlier (bearish), with gap exceeding the configured ATR fraction.
Long: A bullish fair value gap forms AND session is enabled.
Short: A bearish fair value gap forms AND session is enabled.
Calculation: RSI swing = RSI enters the overbought or oversold zone; track the high or low extreme during that zone. Asia uses tighter overbought/oversold thresholds than other sessions.
Long: At a new RSI-defined swing high, the high is lower than the previous swing high AND prior swing bias was bullish (change of character) AND session is enabled.
Short: At a new RSI-defined swing low, the low is higher than the previous swing low AND prior swing bias was bearish (change of character) AND session is enabled.
Calculation: Institutional candle = volume is at least the session-dependent multiple of its moving average, and either body/range meets the body threshold in the candle direction or the opposing wick meets the wick threshold with close in the corresponding half of the range. Accumulation/distribution percentages count bullish/bearish institutional candles over the cluster lookback.
Long: Institutional-candle count reaches its minimum AND bullish share reaches its threshold AND close is above the 200-period EMA AND accumulation was not true on the prior bar AND session is enabled.
Short: Institutional-candle count reaches its minimum AND bearish share reaches its threshold AND close is at or below the 200-period EMA AND distribution was not true on the prior bar AND session is enabled.
Calculation: Order-block displacement = after a confirmed swing pivot, find the nearest opposite-color candle within the source lookback; displacement from its range to the prior bar's extreme must meet the ATR multiple. Score each block from trend, session, DXY, and psychological-price components; require score at least the configured minimum.
Long: Bullish order block qualifies at a confirmed swing low, with upward displacement and score threshold met AND session is enabled.
Short: Bearish order block qualifies at a confirmed swing high, with downward displacement and score threshold met AND session is enabled.
Calculation: Vector volume = volume reaches at least 1.5 times its moving average, or volume × range reaches the lookback maximum. Swing highs/lows use equal left and right pivot lookbacks.
Long: Prior bar has vector volume, is bearish, sweeps below the latest confirmed swing low, and current close > prior open AND session is enabled.
Short: Prior bar has vector volume, is bullish, sweeps above the latest confirmed swing high, and current close < prior open AND session is enabled.
Calculation: Whale candle = absolute body exceeds the configured multiple of ATR.
Long: Whale candle is bullish AND session is enabled.
Short: Whale candle is bearish AND session is enabled.
Long: Close crosses above the anchored VWAP AND session is enabled.
Short: Close crosses below the anchored VWAP AND session is enabled.