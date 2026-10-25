# UM Market Internals Oscillator: TICK TRIN VWAP SCORE

- url: https://www.tradingview.com/script/jwri0Znh-UM-Market-Internals-Oscillator-TICK-TRIN-VWAP-SCORE/
- type: indicator
- pine_id: PUB;26c93773137745518d16de518ce2352d
- version: 1.0

## Description

[b]UM Market Internals Oscillator: TICK / PUT-CALL / ADV-DEC / VIX / VOLD / TRIN / NQ A-D / VWAP / SCORE[/b]


[b]SUMMARY[/b]

One pane that answers a single question: is the broad market confirming the move you see on your chart? The indicator reads seven market internals plus VWAP, rates each one in plain words, and combines them into a single weighted Internals Score that runs from about -12 (broad selling) to +12 (broad buying). The score is plotted as an oscillator, and a table shows every component's current value and rating.


[b]DESCRIPTION[/b]

[b]WHAT IT MEASURES[/b]

- TICK: NYSE stocks on an uptick minus stocks on a downtick. Fast read on immediate buying or selling pressure.
- NYSE Advance/Decline: advancing minus declining NYSE stocks. Breadth of participation.
- NASDAQ Advance/Decline: the same breadth measure for Nasdaq stocks. Useful for QQQ and technology-heavy trading.
- VOLD: NYSE up volume minus down volume. Shows whether volume is backing the breadth.
- TRIN (Arms Index): compares advancing/declining stocks with advancing/declining volume. Lower is bullish, higher is bearish.
- VIX direction: a moving average of VIX. Falling is bullish for equities, rising is bearish. Direction matters here, not the level.
- VWAP: where the chart symbol's price sits relative to its VWAP, and whether VWAP is rising, flat or falling.
- Put/Call ratio: shown in the table with a contrarian rating, but deliberately left out of the score.
[b]
HOW THE SCORE IS BUILT[/b]

Each component is rated against thresholds (for example BUYING, EXTREME SELL, STRONG BULL, NEUTRAL). The rating becomes a base score from -2 to +2 (VIX is -1 or +1), which is multiplied by that component's weight. The weighted values are added together.

Default weights:
- VOLD 1.25
- NYSE A/D 1.15
- TRIN 1.05
- NASDAQ A/D 0.90
- VIX 0.80
- TICK 0.75
- VWAP 0.50

VOLD and breadth carry the most weight because they describe actual participation. TICK is weighted lower because it is noisy. VWAP is price-derived rather than a true internal, so its contribution is capped at plus or minus 1 by default. Setting any weight to 0 removes that component from the score.

[b]READING THE SCORE[/b]

- +7 or higher: STRONG BULL
- +3 to +7: BULLISH
- between -3 and +3: NEUTRAL
- -3 to -7: BEARISH
- -7 or lower: STRONG BEAR

Dotted lines mark +3 and -3, dashed lines mark +7 and -7. The oscillator is green above zero and red below. In the table, the INTERNALS column shows the score with an arrow for whether it rose or fell from the previous bar.

[b]HOW TO USE IT[/b]

- Confirmation: a price breakout with the score above +3 and rising has broad support. A breakout with the score near zero is being carried by a narrow group of stocks.
- Divergence: price making new highs while the score makes lower highs is a warning that participation is fading. The mirror applies at lows.
- Disagreement: the table shows which components disagree with the rest, for example strong breadth with weak volume.
- Extremes: CLIMAX and CAPITULATION readings confirm strong momentum, but after an extended move they can also mark short-term exhaustion.

[b]DISPLAY MODES[/b]

Line + Table (default), Histogram + Table, Line + Histogram + Table, or Table Only. The table can be placed in any corner.

[b]SETTINGS[/b]

- Internals TF (default 3 minutes): the timeframe used to sample TICK, Put/Call, both A/D lines, VOLD and TRIN. Use 5 or 15 minutes for a smoother, slower read. VIX is sampled on the chart's timeframe.
- Thresholds: every rating threshold is adjustable.
- VIX MA: EMA (default, length 8), SMA, WMA or a Nadaraya-Watson estimate.
- VWAP: source, the "at VWAP" distance, and the flat-slope threshold.
- Weights: one per component.
- Symbols: each data symbol can be changed if your data feed uses different tickers.

Every input has a tooltip explaining what it does and what the default means.

[b]ALERTS[/b]

- Internals: Bullish (score crosses up through +3)
- Internals: Strong Bull (score crosses up through +7)
- Internals: Bearish (score crosses down through -3)
- Internals: Strong Bear (score crosses down through -7)

Use "Once per bar close" if you only want confirmed readings, since the score can move while a bar is forming.

[b]NOTES[/b]

- Built for intraday charts of US index products such as SPX, SPY, XSP, ES, QQQ and NQ during regular US market hours. The internals do not update outside those hours.
- VWAP is calculated on the chart symbol, so that symbol needs volume data. On symbols without volume the VWAP column shows NO DATA and adds nothing to the score.
- The default weights are a starting point, not an optimized result. Adjust them to your market and timeframe and test before relying on them.
- This indicator describes market conditions. It does not generate buy or sell signals and is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © UnderwearMillionaire

//@version=6
indicator("UM Market Internals Oscillator: TICK / PUT-CALL / ADV-DEC / VIX / VOLD / TRIN / NQ A-D / VWAP / SCORE", overlay=false)

//==============================================================================
// SUMMARY
//==============================================================================
// One pane that answers a single question: is the broad market confirming the
// move you see on your chart? The indicator reads seven market internals plus
// VWAP, rates each one in plain words, and combines them into a single weighted
// Internals Score that runs from about -12 (broad selling) to +12 (broad
// buying). The score is plotted as an oscillator, and a table shows every
// component's current value and rating.
//
//==============================================================================
// DESCRIPTION
//==============================================================================
// WHAT IT MEASURES
//   TICK        NYSE stocks on an uptick minus stocks on a downtick. Fast read
//               on immediate buying or selling pressure.
//   NYSE A/D    Advancing minus declining NYSE stocks. Breadth of participation.
//   NASDAQ A/D  The same breadth measure for Nasdaq stocks.
//   VOLD        NYSE up volume minus down volume. Shows whether volume is
//               backing the breadth.
//   TRIN        Arms Index. Lower is bullish, higher is bearish.
//   VIX         Direction of a VIX moving average. Falling is bullish for
//               equities, rising is bearish. Direction matters, not the level.
//   VWAP        Chart symbol's price relative to its VWAP, and whether VWAP is
//               rising, flat or falling.
//   PUT/CALL    Shown in the table with a contrarian rating, but deliberately
//               left out of the score.
//
// HOW THE SCORE IS BUILT
//   Each component is rated against thresholds. The rating becomes a base score
//   from -2 to +2 (VIX is -1 or +1), which is multiplied by that component's
//   weight. The weighted values are added together.
//
//   Default weights: VOLD 1.25, NYSE A/D 1.15, TRIN 1.05, NASDAQ A/D 0.90,
//   VIX 0.80, TICK 0.75, VWAP 0.50. A weight of 0 removes a component.
//
// READING THE SCORE
//   +7 or higher        STRONG BULL
//   +3 to +7            BULLISH
//   between -3 and +3   NEUTRAL
//   -3 to -7            BEARISH
//   -7 or lower         STRONG BEAR
//
// HOW TO USE IT
//   Confirmation   A breakout with the score above +3 and rising has broad
//                  support. A breakout with the score near zero is narrow.
//   Divergence     Price at new highs while the score makes lower highs warns
//                  that participation is fading. The mirror applies at lows.
//   Disagreement   The table shows which components disagree with the rest.
//   Extremes       CLIMAX and CAPITULATION readings confirm momentum, but after
//                  an extended move they can also mark short-term exhaustion.
//
// ALERTS
//   Bullish (+3), Strong Bull (+7), Bearish (-3), Strong Bear (-7), each fired
//   when the score crosses into that zone.
//
// NOTES
//   - Built for intraday charts of US index products during regular US hours.
//   - Internals TF (default 3 minutes) sets the sampling timeframe for all
//     internals except VIX, which uses the chart's timeframe.
//   - VWAP needs volume on the chart symbol. Without it the VWAP column shows
//     NO DATA and adds nothing to the score.
//   - The default weights are a starting point, not an optimized result.
//   - This indicator describes market conditions. It does not generate buy or
//     sell signals and is not financial advice.
//==============================================================================
//==========================
// INPUTS — MARKET INTERNAL SYMBOLS
//==========================

symTick = input.symbol(
     "USI:TICK",
     "TICK Symbol",
     tooltip="NYSE TICK measures the number of NYSE stocks trading on an uptick minus those trading on a downtick.\n\n" +
             "Positive readings = broad immediate buying pressure.\n" +
             "Negative readings = broad immediate selling pressure.\n\n" +
             "+600 = meaningful buying\n" +
             "+1000 = strong/extreme buying\n" +
             "-600 = meaningful selling\n" +
             "-1000 = strong/extreme selling\n\n" +
             "TICK is very fast-moving and is useful for judging short-term buying/selling pressure and intraday exhaustion.")

symPC = input.symbol(
     "USI:PC",
     "Put/Call Ratio Symbol",
     tooltip="Put/Call Ratio compares put-option activity with call-option activity.\n\n" +
             "Higher readings indicate more put activity and greater fear/hedging.\n" +
             "Lower readings indicate more call activity and greater optimism/speculation.\n\n" +
             "Unlike most internals, Put/Call is primarily CONTRARIAN:\n" +
             "High P/C can become bullish because traders are excessively bearish.\n" +
             "Low P/C can become bearish because traders are excessively bullish.\n\n" +
             "Put/Call is displayed but intentionally excluded from the composite Internals Score.")

symAdvDec = input.symbol(
     "USI:ADVDEC.NY",
     "NYSE ADV-DEC Symbol",
     tooltip="NYSE Advance/Decline measures advancing NYSE stocks minus declining NYSE stocks.\n\n" +
             "Positive = more stocks advancing than declining.\n" +
             "Negative = more stocks declining than advancing.\n\n" +
             "A/D measures MARKET BREADTH rather than simply index price movement.\n\n" +
             "A rising SPX with weak or negative A/D may indicate narrow leadership.\n" +
             "A rising SPX with strongly positive A/D indicates broad participation.")

symVix = input.symbol(
     "CBOE:VIX",
     "VIX Symbol",
     tooltip="VIX measures the market's expected 30-day volatility derived from S&P 500 options.\n\n" +
             "For this indicator, VIX DIRECTION is more important than its absolute level.\n\n" +
             "Falling VIX MA = BULLISH for equities.\n" +
             "Rising VIX MA = BEARISH for equities.\n\n" +
             "VIX direction is evaluated using the selected moving average below.")

symVold = input.symbol(
     "USI:VOLD",
     "VOLD Symbol",
     tooltip="VOLD is NYSE Up Volume minus Down Volume.\n\n" +
             "It measures how much actual trading volume is flowing into advancing stocks versus declining stocks.\n\n" +
             "Positive VOLD = more volume in advancing stocks.\n" +
             "Negative VOLD = more volume in declining stocks.\n\n" +
             "Large positive or negative readings indicate broad buying or selling pressure.\n\n" +
             "A/D counts stocks. VOLD measures the volume behind those stocks.")

symTrin = input.symbol(
     "USI:TRIN.NY",
     "NYSE TRIN Symbol",
     tooltip="TRIN, also called the Arms Index, compares advancing/declining stocks with advancing/declining volume.\n\n" +
             "TRIN < 1.00 generally means volume favors advancing stocks.\n" +
             "TRIN > 1.00 generally means volume favors declining stocks.\n\n" +
             "Typical interpretation:\n" +
             "≤ 0.60 = strong bullish pressure\n" +
             "≤ 0.80 = bullish\n" +
             "≥ 1.20 = bearish\n" +
             "≥ 1.50 = strong bearish pressure\n\n" +
             "Unlike most internals, LOWER TRIN is bullish and HIGHER TRIN is bearish.")

symNqAdvDec = input.symbol(
     "USI:ADVDEC.NQ",
     "NASDAQ ADV-DEC Symbol",
     tooltip="NASDAQ Advance/Decline measures advancing NASDAQ stocks minus declining NASDAQ stocks.\n\n" +
             "Positive = more NASDAQ stocks advancing.\n" +
             "Negative = more NASDAQ stocks declining.\n\n" +
             "This is particularly useful for technology-heavy markets such as QQQ, FNGU/FNGD, semiconductors and large-cap growth stocks.\n\n" +
             "It helps determine whether the broader Nasdaq is confirming moves in the major technology leaders.")


//==========================
// INTERNALS TIMEFRAME
//==========================

internalsTF = input.timeframe(
     "3",
     "Internals TF",
     tooltip="Timeframe used to sample TICK, Put/Call, NYSE A/D, VOLD, TRIN and NASDAQ A/D.\n\n" +
             "DEFAULT = 3 minutes.\n\n" +
             "3 minutes provides faster responsiveness and matches a 3-minute SPX/SPY execution chart well.\n\n" +
             "5 minutes = slightly smoother and less sensitive to short-term noise.\n" +
             "15 minutes = slower confirmation and better suited to broader intraday context.\n\n" +
             "VIX is intentionally sampled from the chart timeframe rather than this setting.")


//==========================
// VWAP SETTINGS
//==========================

vwapSource = input.source(
     hlc3,
     "VWAP Source",
     group="VWAP",
     tooltip="Source used for the chart-symbol VWAP calculation.\n\n" +
             "Default = HLC3.\n\n" +
             "VWAP is price-derived, so it is used as an intraday structure/acceptance filter rather than a pure market internal.")

vwapAtPct = input.float(
     0.01,
     "VWAP At/Testing Threshold %",
     minval=0.0,
     step=0.005,
     group="VWAP",
     tooltip="Defines how close price must be to VWAP to be classified as AT / TESTING VWAP.\n\n" +
             "Default 0.01% treats price very near VWAP as neutral instead of forcing an above/below reading.")

vwapFlatPct = input.float(
     0.005,
     "VWAP Flat Slope Threshold %",
     minval=0.0,
     step=0.001,
     group="VWAP",
     tooltip="Defines how small the bar-to-bar VWAP change must be to classify VWAP as FLAT.\n\n" +
             "Default 0.005% keeps VWAP slope from flipping too aggressively on tiny changes.")


//==========================
// DISPLAY MODES
//==========================

displayMode = input.string(
     "Line + Table",
     "Mode",
     options=["Line + Table","Histogram + Table","Line + Histogram + Table","Table Only"],
     tooltip="Controls how the composite Internals Score is displayed in the oscillator pane.\n\n" +
             "Line + Table = default oscillator line with the internals table.\n" +
             "Histogram + Table = column view with the internals table.\n" +
             "Line + Histogram + Table = both oscillator views together.\n" +
             "Table Only = hides the oscillator plot while keeping the lower-right table.")

showThresholds = input.bool(
     true,
     "Show Bull/Bear Threshold Lines",
     tooltip="Shows reference lines at +3/-3 and +7/-7, matching the existing Bullish/Bearish and Strong Bull/Strong Bear score thresholds.")


//==========================
// TICK THRESHOLDS
//==========================

tick_neutralAbs = input.int(
     200,
     "TICK Neutral Abs (≤)",
     minval=0,
     tooltip="Defines the neutral TICK zone around zero.\n\n" +
             "Default ±200 means readings between -200 and +200 are considered NEUTRAL.\n\n" +
             "Increase this value to make TICK classification less sensitive.\n" +
             "Decrease it to classify smaller movements as directional.")

tick_buying = input.int(
     600,
     "TICK Buying (≥)",
     minval=0,
     tooltip="Minimum positive TICK reading classified as BUYING.\n\n" +
             "Default +600 represents meaningful broad short-term buying pressure across NYSE stocks.")

tick_extBuy = input.int(
     1000,
     "TICK Extreme Buy (≥)",
     minval=0,
     tooltip="TICK reading classified as EXTREME BUY.\n\n" +
             "Default +1000 represents unusually strong simultaneous buying across NYSE stocks.\n\n" +
             "Repeated +1000 readings can confirm a powerful bullish trend, while an isolated spike can sometimes occur near short-term exhaustion.")

tick_climaxBuy = input.int(
     1200,
     "TICK Climax Buy (≥)",
     minval=0,
     tooltip="Very high positive TICK classified as CLIMAX BUY.\n\n" +
             "Default +1200 represents exceptionally broad aggressive buying.\n\n" +
             "This may confirm very strong momentum, but after an extended move can also signal short-term buying exhaustion.")

tick_selling = input.int(
     600,
     "TICK Selling (≤ -)",
     minval=0,
     tooltip="Magnitude of negative TICK required for SELLING.\n\n" +
             "Default 600 means TICK ≤ -600 is classified as meaningful broad selling pressure.")

tick_extSell = input.int(
     1000,
     "TICK Extreme Sell (≤ -)",
     minval=0,
     tooltip="Magnitude of negative TICK classified as EXTREME SELL.\n\n" +
             "Default 1000 means TICK ≤ -1000 indicates unusually strong simultaneous selling across NYSE stocks.")

tick_capit = input.int(
     1200,
     "TICK Capitulation (≤ -)",
     minval=0,
     tooltip="Magnitude of negative TICK classified as CAPITULATION.\n\n" +
             "Default 1200 means TICK ≤ -1200 represents exceptionally aggressive broad selling.\n\n" +
             "This can confirm powerful downside momentum or indicate short-term selling exhaustion after an extended decline.")


//==========================
// PUT/CALL THRESHOLDS
//==========================

pc_extBull = input.float(
     1.10,
     "P/C Extreme Bullish (≥)",
     step=0.01,
     tooltip="Put/Call ratio at or above this level is classified EXTREME BULLISH on a contrarian basis.\n\n" +
             "Default 1.10 indicates unusually heavy put activity and fear, which can eventually favor a bullish reversal.")

pc_bull = input.float(
     0.90,
     "P/C Bullish (≥)",
     step=0.01,
     tooltip="Put/Call ratio at or above this level is considered BULLISH on a contrarian basis.\n\n" +
             "Higher put demand indicates increased fear and hedging.")

pc_neuLo = input.float(
     0.65,
     "P/C Neutral Low (≥)",
     step=0.01,
     tooltip="Lower boundary of the Put/Call NEUTRAL range.\n\n" +
             "Default neutral range begins at 0.65.")

pc_neuHi = input.float(
     0.85,
     "P/C Neutral High (≤)",
     step=0.01,
     tooltip="Upper boundary of the Put/Call NEUTRAL range.\n\n" +
             "Default neutral range ends at 0.85.")

pc_bear = input.float(
     0.55,
     "P/C Bearish (≤)",
     step=0.01,
     tooltip="Put/Call ratio at or below this level is classified BEARISH on a contrarian basis.\n\n" +
             "Low put activity relative to calls can indicate excessive trader optimism.")

pc_extBear = input.float(
     0.45,
     "P/C Extreme Bearish (≤)",
     step=0.01,
     tooltip="Put/Call ratio at or below this level is classified EXTREME BEARISH on a contrarian basis.\n\n" +
             "Default 0.45 represents unusually heavy call activity and potentially excessive bullish sentiment.")


//==========================
// NYSE ADVANCE / DECLINE
//==========================

ad_neutralAbs = input.int(
     500,
     "NYSE A/D Neutral Abs",
     minval=0,
     tooltip="Defines the neutral zone around zero for NYSE Advance/Decline.\n\n" +
             "Default ±500 means breadth between -500 and +500 is considered NEUTRAL.")

ad_bullish = input.int(
     800,
     "NYSE A/D Bullish",
     minval=0,
     tooltip="NYSE Advance/Decline reading required for BULLISH breadth.\n\n" +
             "Default +800 means there are roughly 800 more advancing stocks than declining stocks.")

ad_strBull = input.int(
     2000,
     "NYSE A/D Strong Bull",
     minval=0,
     tooltip="NYSE Advance/Decline reading classified as STRONG BULL.\n\n" +
             "Default +2000 indicates very broad participation in the advance.")

ad_breadthClmx = input.int(
     3500,
     "NYSE A/D Breadth Climax",
     minval=0,
     tooltip="Exceptionally strong positive NYSE breadth.\n\n" +
             "Default +3500 represents a breadth climax or breadth thrust where advancing stocks overwhelmingly dominate declining stocks.")

ad_bearish = input.int(
     800,
     "NYSE A/D Bearish",
     minval=0,
     tooltip="Magnitude of negative NYSE A/D required for BEARISH breadth.\n\n" +
             "Default 800 means A/D ≤ -800.")

ad_strBear = input.int(
     2000,
     "NYSE A/D Strong Bear",
     minval=0,
     tooltip="Magnitude of negative NYSE A/D required for STRONG BEAR breadth.\n\n" +
             "Default 2000 means A/D ≤ -2000, indicating very broad selling participation.")

ad_capit = input.int(
     3500,
     "NYSE A/D Capitulation",
     minval=0,
     tooltip="Extremely negative NYSE breadth threshold.\n\n" +
             "Default 3500 means A/D ≤ -3500 is classified as CAPITULATION.\n\n" +
             "This indicates exceptionally broad selling and can accompany panic or downside exhaustion.")


//==========================
// NASDAQ ADVANCE / DECLINE
//==========================

nqAdNeutralAbs = input.int(
     300,
     "NASDAQ A/D Neutral Abs",
     group="NASDAQ A/D",
     tooltip="Defines the neutral range around zero for NASDAQ Advance/Decline.\n\n" +
             "Default ±300 means breadth inside this range is considered NEUTRAL.")

nqAdBull = input.int(
     600,
     "NASDAQ A/D Bullish",
     group="NASDAQ A/D",
     tooltip="NASDAQ A/D reading required for BULLISH classification.\n\n" +
             "Default +600 means advancing Nasdaq stocks outnumber declining stocks by approximately 600.")

nqAdStrongBull = input.int(
     1500,
     "NASDAQ A/D Strong Bull",
     group="NASDAQ A/D",
     tooltip="NASDAQ A/D reading classified as STRONG BULL.\n\n" +
             "Default +1500 represents very broad participation across Nasdaq stocks.")

nqAdBear = input.int(
     600,
     "NASDAQ A/D Bearish",
     group="NASDAQ A/D",
     tooltip="Magnitude of negative NASDAQ A/D required for BEARISH classification.\n\n" +
             "Default 600 means A/D ≤ -600.")

nqAdStrongBear = input.int(
     1500,
     "NASDAQ A/D Strong Bear",
     group="NASDAQ A/D",
     tooltip="Magnitude of negative NASDAQ A/D required for STRONG BEAR classification.\n\n" +
             "Default 1500 means A/D ≤ -1500 and indicates broad Nasdaq selling.")


//==========================
// VOLD THRESHOLDS
//==========================

voldNeutralAbs = input.float(
     100000000,
     "VOLD Neutral Abs",
     group="VOLD",
     tooltip="Defines the VOLD neutral zone around zero.\n\n" +
             "Default ±100 million shares means up-volume and down-volume are relatively balanced.")

voldBull = input.float(
     500000000,
     "VOLD Bullish",
     group="VOLD",
     tooltip="Positive VOLD required for BULLISH classification.\n\n" +
             "Default +500 million indicates materially more NYSE volume is flowing into advancing stocks than declining stocks.")

voldStrongBull = input.float(
     1500000000,
     "VOLD Strong Bull",
     group="VOLD",
     tooltip="Positive VOLD required for STRONG BULL classification.\n\n" +
             "Default +1.5 billion represents extremely strong upside volume participation.")

voldBear = input.float(
     500000000,
     "VOLD Bearish",
     group="VOLD",
     tooltip="Magnitude of negative VOLD required for BEARISH classification.\n\n" +
             "Default 500 million means VOLD ≤ -500M and substantial volume is flowing into declining stocks.")

voldStrongBear = input.float(
     1500000000,
     "VOLD Strong Bear",
     group="VOLD",
     tooltip="Magnitude of negative VOLD required for STRONG BEAR classification.\n\n" +
             "Default 1.5 billion means VOLD ≤ -1.5B and indicates extremely strong downside volume pressure.")


//==========================
// TRIN THRESHOLDS
//==========================

trinStrongBull = input.float(
     0.60,
     "TRIN Strong Bull ≤",
     step=0.05,
     group="TRIN",
     tooltip="TRIN at or below this value is classified STRONG BULL.\n\n" +
             "Default 0.60 indicates volume is strongly concentrated in advancing stocks.\n\n" +
             "Remember: LOWER TRIN = more bullish.")

trinBull = input.float(
     0.80,
     "TRIN Bullish ≤",
     step=0.05,
     group="TRIN",
     tooltip="TRIN at or below this value is classified BULLISH.\n\n" +
             "Default 0.80 indicates upside volume participation is stronger than downside participation.")

trinBear = input.float(
     1.20,
     "TRIN Bearish ≥",
     step=0.05,
     group="TRIN",
     tooltip="TRIN at or above this value is classified BEARISH.\n\n" +
             "Default 1.20 indicates trading volume is disproportionately concentrated in declining stocks.")

trinStrongBear = input.float(
     1.50,
     "TRIN Strong Bear ≥",
     step=0.05,
     group="TRIN",
     tooltip="TRIN at or above this value is classified STRONG BEAR.\n\n" +
             "Default 1.50 represents substantial downside volume pressure.\n\n" +
             "Very high TRIN after an extended decline can also accompany selling exhaustion.")


//==========================
// VIX SETTINGS
//==========================

vixMaType = input.string(
     "EMA",
     "VIX MA Type",
     options=["SMA", "EMA", "WMA", "NWE"],
     tooltip="Moving-average method used to determine whether VIX is rising or falling.\n\n" +
             "EMA = responsive and recommended default.\n" +
             "SMA = slower and smoother.\n" +
             "WMA = gives greater weight to recent observations.\n" +
             "NWE = Nadaraya-Watson weighted estimate using the parameters below.\n\n" +
             "Falling VIX MA = equity bullish.\n" +
             "Rising VIX MA = equity bearish.")

vixMaLen = input.int(
     8,
     "VIX MA Length",
     minval=1,
     tooltip="Length of the SMA, EMA or WMA used for VIX direction.\n\n" +
             "Default 8 provides fairly fast detection of volatility turns.\n\n" +
             "Smaller values = faster but noisier.\n" +
             "Larger values = smoother but slower.\n\n" +
             "This setting does not control the NWE calculation when VIX MA Type is NWE.")

nweH = input.float(
     7.0,
     "VIX NWE h",
     minval=1.0,
     step=0.25,
     tooltip="Nadaraya-Watson bandwidth parameter used when VIX MA Type = NWE.\n\n" +
             "Higher values generally create more smoothing.\n" +
             "Lower values generally create a more responsive estimate.")

nweR = input.float(
     6.0,
     "VIX NWE r",
     minval=0.25,
     step=0.25,
     tooltip="Secondary Nadaraya-Watson weighting parameter.\n\n" +
             "Together with h, this controls the weighting applied to older observations.")

nweLen = input.int(
     6,
     "VIX NWE Length",
     minval=2,
     tooltip="Number of VIX observations used in the Nadaraya-Watson estimate.\n\n" +
             "Default 6 creates a responsive short-term VIX trend estimate.\n\n" +
             "Higher values = smoother/slower.\n" +
             "Lower values = faster/more sensitive.")


//==========================
// COMPOSITE SCORE WEIGHTS
//==========================
//
// QUANT PROVISIONAL DEFAULTS:
//
// TICK       = 0.75
// NYSE A/D   = 1.15
// VIX        = 0.80
// VOLD       = 1.25
// TRIN       = 1.05
// NASDAQ A/D = 0.90
// VWAP       = 0.50
//
// Put/Call remains intentionally excluded.
//
// VWAP is price-derived, so its default max
// contribution is intentionally limited to +/-1.
//

tickWeight = input.float(
     0.75,
     "TICK Weight",
     minval=0.0,
     step=0.05,
     group="Composite Score Weights",
     tooltip="Multiplier applied to the TICK contribution in the composite Internals Score.\n\n" +
             "Quant provisional default = 0.75.\n\n" +
             "TICK is highly responsive but also noisy, so its default influence is slightly reduced.\n\n" +
             "Set to 0 to exclude TICK from the composite.")

adWeight = input.float(
     1.15,
     "NYSE A/D Weight",
     minval=0.0,
     step=0.05,
     group="Composite Score Weights",
     tooltip="Multiplier applied to NYSE Advance/Decline in the composite Internals Score.\n\n" +
             "Quant provisional default = 1.15.\n\n" +
             "NYSE breadth receives slightly greater emphasis because broad participation is important confirmation for SPX direction.")

vixWeight = input.float(
     0.80,
     "VIX Weight",
     minval=0.0,
     step=0.05,
     group="Composite Score Weights",
     tooltip="Multiplier applied to the VIX directional score.\n\n" +
             "Quant provisional default = 0.80.\n\n" +
             "Falling VIX MA produces +1 before weighting.\n" +
             "Rising VIX MA produces -1 before weighting.")

voldWeight = input.float(
     1.25,
     "VOLD Weight",
     minval=0.0,
     step=0.05,
     group="Composite Score Weights",
     tooltip="Multiplier applied to NYSE VOLD.\n\n" +
             "Quant provisional default = 1.25.\n\n" +
             "VOLD receives the highest default weight because it measures whether actual trading volume confirms breadth.")

trinWeight = input.float(
     1.05,
     "TRIN Weight",
     minval=0.0,
     step=0.05,
     group="Composite Score Weights",
     tooltip="Multiplier applied to the TRIN contribution.\n\n" +
             "Quant provisional default = 1.05.\n\n" +
             "TRIN provides useful breadth/volume confirmation while overlapping somewhat with A/D and VOLD.")

nqAdWeight = input.float(
     0.90,
     "NASDAQ A/D Weight",
     minval=0.0,
     step=0.05,
     group="Composite Score Weights",
     tooltip="Multiplier applied to NASDAQ Advance/Decline.\n\n" +
             "Quant provisional default = 0.90.\n\n" +
             "NASDAQ breadth remains important but receives slightly less weight than NYSE breadth for an SPX-focused system.")

vwapWeight = input.float(
     0.50,
     "VWAP Weight",
     minval=0.0,
     step=0.05,
     group="Composite Score Weights",
     tooltip="Multiplier applied to the VWAP structure score.\n\n" +
             "Recommended default = 0.50.\n\n" +
             "VWAP base score ranges from -2 to +2, so the default VWAP contribution is capped at -1.00 to +1.00.\n\n" +
             "This lets VWAP tilt the composite without overpowering true internals such as A/D, VOLD and TRIN.")


//==========================
// TABLE POSITION
//==========================

posOpt = input.string(
     "Bottom Right",
     "Table Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"],
     tooltip="Selects where the Market Internals table appears on the chart.\n\n" +
             "This setting changes only the table location and does not affect any calculations.")

pos = switch posOpt
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_left


//==========================
// SECURITY
//==========================

f_sec(_sym, _tf) =>
    request.security(
         _sym,
         _tf,
         close,
         barmerge.gaps_off,
         barmerge.lookahead_off)

tick   = f_sec(symTick, internalsTF)
pc     = f_sec(symPC, internalsTF)
advdec = f_sec(symAdvDec, internalsTF)
vix    = f_sec(symVix, timeframe.period)

vold     = f_sec(symVold, internalsTF)
trin     = f_sec(symTrin, internalsTF)
nqAdvDec = f_sec(symNqAdvDec, internalsTF)


//==========================
// RATINGS
//==========================

tickRating(float x) =>
    na(x) ? "NO DATA" :    x >= tick_climaxBuy ? "CLIMAX BUY" :    x >= tick_extBuy ? "EXTREME BUY" :    x >= tick_buying ? "BUYING" :    x <= -tick_capit ? "CAPITULATION" :    x <= -tick_extSell ? "EXTREME SELL" :    x <= -tick_selling ? "SELLING" :    math.abs(x) <= tick_neutralAbs ? "NEUTRAL" :    "MIXED"


pcRating(float x) =>
    na(x) ? "NO DATA" :    x >= pc_extBull ? "EXTREME BULLISH" :    x >= pc_bull ? "BULLISH" :    (x >= pc_neuLo and x <= pc_neuHi) ? "NEUTRAL" :    x <= pc_extBear ? "EXTREME BEARISH" :    x <= pc_bear ? "BEARISH" :    "MIXED"


advdecRating(float x) =>
    na(x) ? "NO DATA" :    x >= ad_breadthClmx ? "BREADTH CLIMAX" :    x >= ad_strBull ? "STRONG BULL" :    x >= ad_bullish ? "BULLISH" :    x <= -ad_capit ? "CAPITULATION" :    x <= -ad_strBear ? "STRONG BEAR" :    x <= -ad_bearish ? "BEARISH" :    math.abs(x) <= ad_neutralAbs ? "NEUTRAL" :    "MIXED"


voldRating(float x) =>
    na(x) ? "NO DATA" :    x >= voldStrongBull ? "STRONG BULL" :    x >= voldBull ? "BULLISH" :    x <= -voldStrongBear ? "STRONG BEAR" :    x <= -voldBear ? "BEARISH" :    math.abs(x) <= voldNeutralAbs ? "NEUTRAL" :    "MIXED"


trinRating(float x) =>
    na(x) ? "NO DATA" :    x <= trinStrongBull ? "STRONG BULL" :    x <= trinBull ? "BULLISH" :    x >= trinStrongBear ? "STRONG BEAR" :    x >= trinBear ? "BEARISH" :    "NEUTRAL"


nqAdvRating(float x) =>
    na(x) ? "NO DATA" :    x >= nqAdStrongBull ? "STRONG BULL" :    x >= nqAdBull ? "BULLISH" :    x <= -nqAdStrongBear ? "STRONG BEAR" :    x <= -nqAdBear ? "BEARISH" :    math.abs(x) <= nqAdNeutralAbs ? "NEUTRAL" :    "MIXED"


//==========================
// COLORS
//==========================

isBull(string s) =>
    str.contains(s, "BULL") or str.contains(s, "BUY")


isBear(string s) =>
    str.contains(s, "BEAR") or    str.contains(s, "SELL") or    str.contains(s, "CAPITULATION")


ratingBg(string s) =>
    isBull(s) ? color.new(color.lime, 75) :    isBear(s) ? color.new(color.red, 75) :    color.new(color.yellow, 70)


ratingText(string s) =>
    isBull(s) ? color.rgb(0,100,0) :    isBear(s) ? color.rgb(139,0,0) :    color.rgb(120,120,0)


//==========================
// VIX NWE
//==========================

nwe(src, float h, float r, int len) =>
    float num = 0.0
    float den = 0.0

    float hr = math.max(0.0001, h * r)

    for i = 0 to len - 1
        float w = math.exp(-(i * i) / (2.0 * hr * hr))
        num += nz(src[i]) * w
        den += w

    den == 0.0 ? na : num / den


float vixNwe_raw = nwe(vix, nweH, nweR, nweLen)


float vixMa = switch vixMaType
    "SMA" => ta.sma(vix, vixMaLen)
    "EMA" => ta.ema(vix, vixMaLen)
    "WMA" => ta.wma(vix, vixMaLen)
    => vixNwe_raw


float vixMaFinal = na(vix) ? na : vixMa


bool vixMaDown =
     not na(vixMaFinal) and
     not na(vixMaFinal[1]) and
     vixMaFinal < vixMaFinal[1]


string vixBias =
     na(vixMaFinal) or na(vixMaFinal[1]) ?
     "NO DATA" :
     vixMaDown ? "BULLISH" : "BEARISH"


//==========================
// VWAP
//==========================

float chartVwap = ta.vwap(vwapSource)

float vwapDistancePct =
     na(chartVwap) or chartVwap == 0.0 ? na :
     ((close - chartVwap) / chartVwap) * 100.0

float vwapSlopePct =
     na(chartVwap) or na(chartVwap[1]) or chartVwap[1] == 0.0 ? na :
     ((chartVwap - chartVwap[1]) / chartVwap[1]) * 100.0

bool priceAtVwap =
     not na(vwapDistancePct) and
     math.abs(vwapDistancePct) <= vwapAtPct

bool priceAboveVwap =
     not na(chartVwap) and
     close > chartVwap and
     not priceAtVwap

bool priceBelowVwap =
     not na(chartVwap) and
     close < chartVwap and
     not priceAtVwap

bool vwapFlat =
     not na(vwapSlopePct) and
     math.abs(vwapSlopePct) <= vwapFlatPct

bool vwapRising =
     not na(vwapSlopePct) and
     vwapSlopePct > vwapFlatPct

bool vwapFalling =
     not na(vwapSlopePct) and
     vwapSlopePct < -vwapFlatPct

string vwapPosition =
     na(chartVwap) ? "NO DATA" :
     priceAtVwap ? "AT" :
     priceAboveVwap ? "ABOVE" :
     priceBelowVwap ? "BELOW" :
     "MIXED"

string vwapSlope =
     na(vwapSlopePct) ? "NO DATA" :
     vwapRising ? "RISING" :
     vwapFalling ? "FALLING" :
     "FLAT"

string vwapDisplay =
     vwapPosition == "ABOVE" and vwapSlope == "RISING" ? "ABV / RISE" :
     vwapPosition == "ABOVE" and vwapSlope == "FLAT" ? "ABV / FLAT" :
     vwapPosition == "ABOVE" and vwapSlope == "FALLING" ? "ABV / FALL" :
     vwapPosition == "BELOW" and vwapSlope == "FALLING" ? "BLW / FALL" :
     vwapPosition == "BELOW" and vwapSlope == "FLAT" ? "BLW / FLAT" :
     vwapPosition == "BELOW" and vwapSlope == "RISING" ? "BLW / RISE" :
     vwapPosition == "AT" ? "AT VWAP" :
     "NO DATA"

int vwapBaseScore =
     vwapPosition == "ABOVE" and vwapSlope == "RISING" ? 2 :
     vwapPosition == "ABOVE" and vwapSlope == "FLAT" ? 1 :
     vwapPosition == "ABOVE" and vwapSlope == "FALLING" ? 0 :
     vwapPosition == "BELOW" and vwapSlope == "FALLING" ? -2 :
     vwapPosition == "BELOW" and vwapSlope == "FLAT" ? -1 :
     vwapPosition == "BELOW" and vwapSlope == "RISING" ? 0 :
     0

string vwapBias =
     vwapBaseScore >= 2 ? "BULLISH" :
     vwapBaseScore == 1 ? "MILD BULL" :
     vwapBaseScore <= -2 ? "BEARISH" :
     vwapBaseScore == -1 ? "MILD BEAR" :
     "NEUTRAL"


//==========================
// COMPOSITE SCORE
//==========================

ratingScore(string s) =>
    str.contains(s, "STRONG BULL") or    str.contains(s, "EXTREME BUY") or    str.contains(s, "CLIMAX BUY") ? 2 :    str.contains(s, "BULL") or    str.contains(s, "BUYING") ? 1 :    str.contains(s, "STRONG BEAR") or    str.contains(s, "EXTREME SELL") or    str.contains(s, "CAPITULATION") ? -2 :    str.contains(s, "BEAR") or    str.contains(s, "SELLING") ? -1 :    0


//==========================
// INDIVIDUAL RATINGS
//==========================

string tickStr = tickRating(tick)
string pcStr   = pcRating(pc)
string adStr   = advdecRating(advdec)

string voldStr = voldRating(vold)
string trinStr = trinRating(trin)
string nqAdStr = nqAdvRating(nqAdvDec)


//==========================
// VIX BASE SCORE
//==========================

int vixBaseScore =
     na(vixMaFinal) or na(vixMaFinal[1]) ? 0 :
     vixMaDown ? 1 : -1


//==========================
// WEIGHTED COMPONENT SCORES
//==========================

float tickWeightedScore =
     ratingScore(tickStr) * tickWeight

float adWeightedScore =
     ratingScore(adStr) * adWeight

float vixWeightedScore =
     vixBaseScore * vixWeight

float voldWeightedScore =
     ratingScore(voldStr) * voldWeight

float trinWeightedScore =
     ratingScore(trinStr) * trinWeight

float nqAdWeightedScore =
     ratingScore(nqAdStr) * nqAdWeight

float vwapWeightedScore =
     vwapBaseScore * vwapWeight


//==========================
// FINAL WEIGHTED INTERNAL SCORE
//==========================
//
// Put/Call intentionally remains excluded.
//
// Default theoretical maximum:
//
// TICK       2 * 0.75 = 1.50
// NYSE A/D   2 * 1.15 = 2.30
// VIX        1 * 0.80 = 0.80
// VOLD       2 * 1.25 = 2.50
// TRIN       2 * 1.05 = 2.10
// NASDAQ A/D 2 * 0.90 = 1.80
// VWAP       2 * 0.50 = 1.00
//
// TOTAL = +12.00
//
// Minimum = -12.00

float internalScore =
     tickWeightedScore +
     adWeightedScore +
     vixWeightedScore +
     voldWeightedScore +
     trinWeightedScore +
     nqAdWeightedScore +
     vwapWeightedScore


//==========================
// SCORE BIAS
//==========================
//
// Strong Bull = +7 or higher
// Bullish     = +3 to +6.99
// Neutral     = between -3 and +3
// Bearish     = -3 to -6.99
// Strong Bear = -7 or lower
//

string scoreBias =
     internalScore >= 7 ? "STRONG BULL" :
     internalScore >= 3 ? "BULLISH" :
     internalScore <= -7 ? "STRONG BEAR" :
     internalScore <= -3 ? "BEARISH" :
     "NEUTRAL"


//==========================
// SCORE SLOPE
//==========================

bool scoreRising =
     internalScore > internalScore[1]

bool scoreFalling =
     internalScore < internalScore[1]


string scoreArrow =
     scoreRising ? " ▲" :
     scoreFalling ? " ▼" :
     " →"


string scoreDisplay =
     str.tostring(internalScore, "#.##") +
     scoreArrow +
     " " +
     scoreBias


//==========================
// OSCILLATOR
//==========================

bool showOscillator =
     displayMode != "Table Only"

bool showOscLine =
     showOscillator and
     (displayMode == "Line + Table" or
     displayMode == "Line + Histogram + Table")

bool showOscHistogram =
     showOscillator and
     (displayMode == "Histogram + Table" or
     displayMode == "Line + Histogram + Table")

bool showScoreThresholds =
     showOscillator and showThresholds

color oscillatorColor =
     internalScore >= 0 ?
     color.rgb(0, 150, 0) :
     color.rgb(190, 0, 0)

color oscillatorHistogramColor =
     internalScore >= 0 ?
     color.new(color.rgb(0, 150, 0), 65) :
     color.new(color.rgb(190, 0, 0), 65)


//==========================
// OSCILLATOR FILL COLORS
//==========================
//
// Highly transparent directional fill:
//
// Above zero = GREEN
// Below zero = RED
//
// Transparency = 88
//

color oscillatorFillColor =
     internalScore > 0 ?
     color.new(color.rgb(0, 150, 0), 88) :
     internalScore < 0 ?
     color.new(color.rgb(190, 0, 0), 88) :
     na


hline(
     0,
     "Internals Zero Line",
     color=color.new(color.gray, 20),
     linestyle=hline.style_solid,
     linewidth=1)

hline(
     3,
     "Bullish Threshold",
     color=showScoreThresholds ? color.new(color.rgb(0, 150, 0), 70) : color.new(color.rgb(0, 150, 0), 100),
     linestyle=hline.style_dotted)

hline(
     -3,
     "Bearish Threshold",
     color=showScoreThresholds ? color.new(color.rgb(190, 0, 0), 70) : color.new(color.rgb(190, 0, 0), 100),
     linestyle=hline.style_dotted)

hline(
     7,
     "Strong Bull Threshold",
     color=showScoreThresholds ? color.new(color.rgb(0, 150, 0), 82) : color.new(color.rgb(0, 150, 0), 100),
     linestyle=hline.style_dashed)

hline(
     -7,
     "Strong Bear Threshold",
     color=showScoreThresholds ? color.new(color.rgb(190, 0, 0), 82) : color.new(color.rgb(190, 0, 0), 100),
     linestyle=hline.style_dashed)

plot(
     showOscHistogram ? internalScore : na,
     "Internals Histogram",
     style=plot.style_columns,
     color=oscillatorHistogramColor)


//==========================
// OSCILLATOR LINE + ZERO FILL
//==========================
//
// A hidden zero-value plot is used because Pine's
// fill() function fills between two plot objects.
//

oscLinePlot = plot(
     showOscLine ? internalScore : na,
     "Internals Oscillator",
     color=oscillatorColor,
     linewidth=2)

zeroFillPlot = plot(
     showOscLine ? 0 : na,
     "Internals Fill Zero",
     color=color.new(color.gray, 100),
     display=display.none)

fill(
     oscLinePlot,
     zeroFillPlot,
     color=showOscLine ? oscillatorFillColor : na,
     title="Internals Directional Fill")


//==========================
// FORMATTING
//==========================

f_num(x, fmt) =>
    na(x) ? "NA" :    str.tostring(x, fmt)


f_vol(float x) =>
    na(x) ? "NA" :    math.abs(x) >= 1000000000 ?      str.tostring(x / 1000000000, "#.00") + "B" :    math.abs(x) >= 1000000 ?
      str.tostring(x / 1000000, "#.0") + "M" :
      str.tostring(x, "#")


//==========================
// TABLE COLORS
//==========================

blueBorder = color.new(color.blue, 0)
headerBg   = color.new(color.silver, 0)
headerText = color.new(color.black, 0)
cellBg     = color.new(color.white, 85)


color vixTextCol =
     vixBias == "BULLISH" ?
     color.rgb(0,100,0) :
     vixBias == "BEARISH" ?
     color.rgb(139,0,0) :
     color.gray


color vixBgCol =
     vixBias == "BULLISH" ?
     color.new(color.lime,75) :
     vixBias == "BEARISH" ?
     color.new(color.red,75) :
     color.new(color.gray,85)


//==========================
// TABLE
//==========================

var table t = table.new(
     pos,
     9,
     3,
     bgcolor=color.new(color.white,100),
     frame_color=blueBorder,
     frame_width=1,
     border_color=blueBorder,
     border_width=1)


//==========================
// TABLE HEADERS
//==========================

table.cell(
     t,0,0,"TICK",
     text_size=size.small,
     text_color=headerText,
     bgcolor=headerBg)

table.cell(
     t,1,0,"PUT/CALL",
     text_size=size.small,
     text_color=headerText,
     bgcolor=headerBg)

table.cell(
     t,2,0,"NY A/D",
     text_size=size.small,
     text_color=headerText,
     bgcolor=headerBg)

table.cell(
     t,3,0,"VIX",
     text_size=size.small,
     text_color=headerText,
     bgcolor=headerBg)

table.cell(
     t,4,0,"VOLD",
     text_size=size.small,
     text_color=headerText,
     bgcolor=headerBg)

table.cell(
     t,5,0,"TRIN",
     text_size=size.small,
     text_color=headerText,
     bgcolor=headerBg)

table.cell(
     t,6,0,"NQ A/D",
     text_size=size.small,
     text_color=headerText,
     bgcolor=headerBg)

table.cell(
     t,7,0,"INTERNALS",
     text_size=size.small,
     text_color=headerText,
     bgcolor=headerBg)

table.cell(
     t,8,0,"VWAP",
     text_size=size.small,
     text_color=headerText,
     bgcolor=headerBg)


//==========================
// TABLE VALUES
//==========================

table.cell(
     t,0,1,
     f_num(tick,"#"),
     text_size=size.small,
     text_color=ratingText(tickStr),
     bgcolor=cellBg)

table.cell(
     t,1,1,
     f_num(pc,"#.##"),
     text_size=size.small,
     text_color=ratingText(pcStr),
     bgcolor=cellBg)

table.cell(
     t,2,1,
     f_num(advdec,"#"),
     text_size=size.small,
     text_color=ratingText(adStr),
     bgcolor=cellBg)

table.cell(
     t,3,1,
     f_num(vix,"#.##"),
     text_size=size.small,
     text_color=vixTextCol,
     bgcolor=cellBg)

table.cell(
     t,4,1,
     f_vol(vold),
     text_size=size.small,
     text_color=ratingText(voldStr),
     bgcolor=cellBg)

table.cell(
     t,5,1,
     f_num(trin,"#.##"),
     text_size=size.small,
     text_color=ratingText(trinStr),
     bgcolor=cellBg)

table.cell(
     t,6,1,
     f_num(nqAdvDec,"#"),
     text_size=size.small,
     text_color=ratingText(nqAdStr),
     bgcolor=cellBg)

table.cell(
     t,7,1,
     str.tostring(internalScore, "#.##") + scoreArrow,
     text_size=size.small,
     text_color=ratingText(scoreBias),
     bgcolor=cellBg)

table.cell(
     t,8,1,
     vwapDisplay,
     text_size=size.small,
     text_color=ratingText(vwapBias),
     bgcolor=cellBg)


//==========================
// TABLE RATINGS
//==========================

table.cell(
     t,0,2,
     tickStr,
     text_size=size.small,
     text_color=ratingText(tickStr),
     bgcolor=ratingBg(tickStr))

table.cell(
     t,1,2,
     pcStr,
     text_size=size.small,
     text_color=ratingText(pcStr),
     bgcolor=ratingBg(pcStr))

table.cell(
     t,2,2,
     adStr,
     text_size=size.small,
     text_color=ratingText(adStr),
     bgcolor=ratingBg(adStr))

table.cell(
     t,3,2,
     vixBias,
     text_size=size.small,
     text_color=vixTextCol,
     bgcolor=vixBgCol)

table.cell(
     t,4,2,
     voldStr,
     text_size=size.small,
     text_color=ratingText(voldStr),
     bgcolor=ratingBg(voldStr))

table.cell(
     t,5,2,
     trinStr,
     text_size=size.small,
     text_color=ratingText(trinStr),
     bgcolor=ratingBg(trinStr))

table.cell(
     t,6,2,
     nqAdStr,
     text_size=size.small,
     text_color=ratingText(nqAdStr),
     bgcolor=ratingBg(nqAdStr))

table.cell(
     t,7,2,
     scoreBias,
     text_size=size.small,
     text_color=ratingText(scoreBias),
     bgcolor=ratingBg(scoreBias))

table.cell(
     t,8,2,
     vwapBias,
     text_size=size.small,
     text_color=ratingText(vwapBias),
     bgcolor=ratingBg(vwapBias))


//==========================
// COMPOSITE ALERTS
//==========================

bool scoreTurnsBull =
     internalScore >= 3 and
     internalScore[1] < 3


bool scoreTurnsStrongBull =
     internalScore >= 7 and
     internalScore[1] < 7


bool scoreTurnsBear =
     internalScore <= -3 and
     internalScore[1] > -3


bool scoreTurnsStrongBear =
     internalScore <= -7 and
     internalScore[1] > -7


alertcondition(
     scoreTurnsBull,
     title="Internals: Bullish",
     message="Composite market internals turned BULLISH")


alertcondition(
     scoreTurnsStrongBull,
     title="Internals: Strong Bull",
     message="Composite market internals turned STRONG BULL")


alertcondition(
     scoreTurnsBear,
     title="Internals: Bearish",
     message="Composite market internals turned BEARISH")


alertcondition(
     scoreTurnsStrongBear,
     title="Internals: Strong Bear",
     message="Composite market internals turned STRONG BEAR")
````
