# Absorption Arrows v2

- url: https://www.tradingview.com/script/k15zh7Dl-Absorption-Arrows-v2/
- type: indicator
- pine_id: PUB;b708089d9e404ebd8ca7aedd5df1ab28
- version: 3.0

## Description

Absorption Arrows v2
Pine Script v6 Indicator for TradingView
________________________________________
Overview

Absorption Arrows v2 is an order flow indicator designed to identify price levels where significant volume has been absorbed by opposing market participants. When price moves aggressively into a level but fails to sustain that move — leaving a wick — and that price action is accompanied by statistically elevated volume, it suggests that large limit orders absorbed the incoming market orders. This is known as absorption, and it often precedes reversals or stalls at key levels.

The indicator plots directional arrows above or below bars where absorption is detected, sized according to the relative significance of the volume event.
________________________________________
How It Works

Step 1 — Wick Zone Detection

The indicator first identifies where within the bar the volume occurred relative to price movement. The bar is divided into two zones:

•	Upper Wick Zone — the bar's midpoint (high + low / 2) falls above the body (above the
         open/close range). This indicates price ran up into a level and was rejected — a potential
         selling absorption event where sellers absorbed buying pressure.
•	Lower Wick Zone — the bar's midpoint falls below the body. This indicates price ran down
         into a level and was rejected — a potential buying absorption event where buyers
         absorbed selling pressure.

Bars where the midpoint is inside the body are ignored — no significant wick means no absorption signal regardless of volume.

Step 2 — Percentile-Based Volume Thresholds

Rather than using a fixed volume threshold or standard deviation, v2 measures volume against its own recent history using linear interpolation percentiles. This approach is more statistically robust for futures instruments like ES and NQ because volume distributions are heavily right-skewed — a few extreme spikes can distort standard deviation, making thresholds inconsistent. Percentiles are immune to this distortion.

Three volume tiers are defined by user-configurable percentile thresholds:
Tier	Default Percentile

Small	 75th	Top 25% of volume bars — notably elevated
Medium	 90th	Top 10% — significant, often institutional activity
Big	         97th	Top 3% — rare, high-impact events

Step 3 — Three-Window Consensus

A single lookback window can be fooled by the intraday volume profile of futures markets, where volume is naturally heavy at the open, light at midday, and active into the close. To address this, v2 calculates percentile thresholds across three independent lookback windows simultaneously:

     •	Short Window (default: 20 bars) — reacts quickly to recent volume shifts
     •	Medium Window (default: 50 bars) — balanced between recent and broader context
     •	Long Window (default: 100 bars) — resistant to short-term noise, flags truly exceptional
        volume

A signal is only confirmed when the majority (2 of 3) windows agree that volume is elevated at the specified tier. This consensus requirement significantly reduces false signals caused by temporary volume spikes or session-specific volume patterns.

Step 4 — Directional Filter (Optional)

When enabled, the directional filter adds a bar direction requirement to each signal:

     •	Selling absorption requires a bull bar (close > open) — price ran up into supply on a green
        candle and was rejected. This is the higher-conviction version of a selling absorption
        signal.
     •	Buying absorption requires a bear bar (close < open) — price ran down into demand on a
        red candle and was absorbed. Higher-conviction buying absorption.

When disabled, absorption signals fire regardless of bar direction.
________________________________________
Signal Output

Arrows are plotted directly on the price chart, sized according to volume tier:

| Arrow | Direction | Meaning | |---|---|---|| 🟢 Small up arrow | Below bar | Low-tier buying absorption | | 🟢 Medium up arrow | Below bar | Mid-tier buying absorption | | 🟢 Large up arrow | Below bar | High-tier buying absorption | | 🔴 Small down arrow | Above bar | Low-tier selling absorption | | 🔴 Medium down arrow | Above bar | Mid-tier selling absorption | | 🔴 Large down arrow | Above bar | High-tier selling absorption |
Arrow colors are fully user-configurable.
________________________________________
Settings Reference

Consensus Settings

              Setting	        Default	               Description

Small Cluster Percentile	   75	            Volume percentile floor for Small tier signals
Medium Cluster Percentile	   90	            Volume percentile floor for Medium tier signals
Big Cluster Percentile	   97	            Volume percentile floor for Big tier signals
Consensus Mode	  Majority (2 of 3)  How many windows must agree before a signal fires
Short Window	                   20	            Short-term lookback for percentile calculation
Medium Window	           50	            Medium-term lookback
Long Window	                   100            Long-term lookback

Detection Settings

             Setting              Default	              Description

Filter by bar direction	  Off	            When on, requires bull bar for sell signals and bear bar          
                                                            for buy signals

Visual Settings

             Setting	            Default	                      Description

Show Small Arrows	         On	           Toggle visibility of Small tier signals
Show Medium Arrows	         On	           Toggle visibility of Medium tier signals
Show Big Arrows	         On	           Toggle visibility of Big tier signals
Buy Arrow Color	  Bright green	   Color for buying absorption arrows
Sell Arrow Color	  Bright red	   Color for selling absorption arrows
Color Bars on Heavy 	         On	           Highlights bars where heavy volume is inside the body
Volume Body
________________________________________
Bar Coloring

When enabled, the indicator also colors bars where heavy volume (Medium or Big tier) is concentrated inside the candle body rather than in a wick. This is a separate but complementary signal:

      •	Bright green bar — heavy volume bull bar with body-dominant price action. Strong 
                committed buying with no significant rejection. This is a momentum/conviction
                signal rather than absorption — price moved decisively on volume.
     • 	Pink/red bar — heavy volume bear bar with body-dominant structure. Strong
                committed selling.

Note that bar coloring and absorption arrows are measuring different things. An absorption arrow identifies where price was rejected on volume. A colored bar identifies where price moved decisively on volume. When they appear together or in sequence, they can provide useful confluence context.
________________________________________
Alerts

Four alert conditions are available:

Alert	                                                       Trigger

Buying Absorption	Any buying absorption arrow fires on a confirmed bar
Selling Absorption	Any selling absorption arrow fires on a confirmed bar
Absorption (Any)	Either buying or selling absorption on a confirmed bar
Big Absorption Only	Big tier absorption only — highest conviction events

All alerts use barstate.isconfirmed to prevent false triggers on developing bars.
________________________________________
Settings

Settings should really be thought of as instrument-specific rather than universal. Here's a framework for thinking through it:
The core variables that drive settings

Three things determine what settings make sense for any instrument:

      1.  Average daily volume and liquidity — how many bars of meaningful volume exist in a   
           session
      2.  Volatility regime — how much price moves per bar, which affects wick frequency
      3.  Trading session structure — does it trade 24 hours, have a defined RTH session, have 
           regular volume spikes at known times
________________________________________
By instrument category

Equity index futures (ES, NQ, RTY, YM)  Well-defined RTH session, predictable volume profile, high liquidity. Your current settings are a solid baseline.

Commodity futures (CL, GC, NG) Crude oil and gold have sharp volume spikes around inventory reports and geopolitical events that can distort percentile thresholds significantly. Recommendations:

    •	Push Big percentile to 98–99 — spikes are more extreme and more common
    •	Longer windows — 150/300/500 on 5-minute to capture multi-day context
    •	Directional filter on — commodity moves are more impulsive and noisy

Individual equities Highly variable depending on the stock. A mega-cap like AAPL behaves more like an index future. A mid-cap can have very uneven volume. General guidance:

    •	Use longer windows relative to average daily bar count
    •	Turn off Small arrows — individual stock volume is spikier and small signals are unreliable
    •	Be aware that pre/post market volume can heavily skew percentile calculations — 
        consider only trading signals during regular market hours

Forex majors (EURUSD, GBPUSD etc.) No central exchange volume — TradingView shows tick volume, not real volume. The indicator will still run but the signals lose their fundamental meaning. Tick volume is a proxy at best. Use with significant skepticism and treat signals as supplementary rather than primary.

Crypto (BTCUSD, ETHUSD) Trades 24/7 with no session structure, which is actually a challenge for the lookback windows — there's no natural "one session" anchor like the 390-bar RTH window on ES. Volume also has strong time-of-day patterns driven by Asian/European/US overlap periods. Recommendations:

    •	Much longer windows — 100/300/600 to capture meaningful history
    •	Higher percentile thresholds — crypto volume is fat-tailed, spikes are more extreme
    •	Consensus on All Windows (strictest) — noise is very high
________________________________________
A general calibration process for any new instrument 

Rather than guessing settings, this is the process I'd suggest whenever you add a new instrument:

    1.	Pull up 2–3 weeks of history on your target timeframe
    2.	Identify 5–10 obvious absorption moments by eye — major level holds, capitulation wicks
        on high volume, clear reversals
    3.	Adjust settings until those known events show Medium or Big signals without the chart
        being flooded with Small arrows everywhere else
    4.	Check a few false reversal bars — bars that looked like absorption but price continued
        through. Good settings should produce few or no signals on those bars.

That visual calibration process on known historical events will get you to good settings faster than any formula.
________________________________________
The one universal principle

Regardless of instrument, the relationship between your lookback windows and the instrument's typical session length should stay roughly consistent. You want:

    •	Short window ≈ 20–25% of a typical session in bars
    •	Medium window ≈ 50–60% of a typical session
    •	Long window ≈ one full session or slightly more

That anchor keeps the percentile thresholds meaningful relative to the instrument's natural volume rhythm rather than an arbitrary number of bars.
________________________________________
Recommended Settings for ES/NQ/RTY/YM 5-Minute Charts

              Setting	                        Recommendation
Consensus Mode	                        Majority (2 of 3)
Short / Medium / Long Windows	20 / 50 / 100
Big Cluster Percentile	                97–99 for extreme-only signals
Directional Filter	                        Try both — on for higher conviction, off for more signals
Show Small Arrows	                        Optional — disable to reduce noise
________________________________________
Recommended Settings for ES/NQ/RTY/YM 1-Minute Charts

              Setting	                        Recommendation
Consensus Mode	                        Majority (2 of 3)
Short / Medium / Long Windows	50 / 150 / 390
Big Cluster Percentile	                98–99 for extreme-only signals
Directional Filter	                        Try both — on for higher conviction, off for more signals
Show Small Arrows	                        Optional — disable to reduce noise
________________________________________
What Absorption Is — and Is Not

Absorption is not a standalone trading system. It identifies potential inflection points where significant volume activity occurred at a wick, suggesting that large participants may have been defending a level. It does not guarantee reversal.

Best used in confluence with:
    •	Key support and resistance levels — absorption at a known level is more meaningful than 
        in open space
    •	Volume delta indicators (e.g. CVD) — confirms whether net buying or selling pressure
        supports the signal
    •	Higher timeframe context — absorption at a higher timeframe level carries more weight
    •	Price action confirmation — a follow-through bar in the expected direction strengthens 
        the signal
________________________________________
Version History

Version	Changes
v1	        Basic absorption detection using volume standard deviation, single lookback 
                window, close > open directional proxy
v2	        Replaced standard deviation with percentile thresholds; added three-window
                consensus system; simplified to single plotshape per direction for rendering stability
                on futures instruments

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// Absorption Arrows v2
// Designed by WaveWalker1

//@version=6
indicator("Absorption Arrows v2", overlay = true)

// ══════════════════════════════════════════════
//   INPUT GROUPS
// ══════════════════════════════════════════════

var string grp_detect = "════ Detection Settings ════"
var string grp_sens   = "════ Sensitivity & Consensus ════"
var string grp_visual = "════ Visual Settings ════"
var string grp_offset = "════ Arrow Offset Settings ════"

// ══════════════════════════════════════════════
//   DETECTION SETTINGS
// ══════════════════════════════════════════════

filterDir = input.bool(false, "Filter by bar direction?",
     tooltip = "When enabled, selling absorption only fires on bull bars and buying absorption only fires on bear bars — higher conviction signals.",
     group   = grp_detect)

// ══════════════════════════════════════════════
//   SENSITIVITY & CONSENSUS SETTINGS
// ══════════════════════════════════════════════

smallPct  = input.float(75, "Small Cluster Percentile",  step = 1, minval = 50, maxval = 99,
     tooltip = "Volume must exceed this percentile of recent history to qualify as a Small signal. 75 = top 25% of volume bars.",
     group   = grp_sens)
mediumPct = input.float(90, "Medium Cluster Percentile", step = 1, minval = 50, maxval = 99,
     tooltip = "Volume must exceed this percentile to qualify as Medium. 90 = top 10%.",
     group   = grp_sens)
bigPct    = input.float(97, "Big Cluster Percentile",    step = 1, minval = 50, maxval = 99,
     tooltip = "Volume must exceed this percentile to qualify as Big. 97 = top 3% — rare, high-impact events.",
     group   = grp_sens)

consensusMode = input.string("Majority (2 of 3)", "Consensus Mode",
     options  = ["Any Window", "Majority (2 of 3)", "All Windows (strictest)"],
     tooltip  = "How many lookback windows must agree before a signal fires.\nAny Window: most signals, most noise.\nMajority: balanced — recommended.\nAll Windows: fewest signals, highest confidence.",
     group    = grp_sens)
shortLen  = input.int(20,  "Short Window",  minval = 5,  group = grp_sens,
     tooltip = "Short-term lookback for percentile calculation. Reacts quickly to recent volume shifts.")
midLen    = input.int(50,  "Medium Window", minval = 10, group = grp_sens,
     tooltip = "Medium-term lookback. Balanced between recent and broader context.")
longLen   = input.int(100, "Long Window",   minval = 20, group = grp_sens,
     tooltip = "Long-term lookback. Resistant to short-term noise — flags truly exceptional volume.")

// ══════════════════════════════════════════════
//   VISUAL SETTINGS
// ══════════════════════════════════════════════

showSmall    = input.bool(true,  "Show Small Arrows",  group = grp_visual)
showMedium   = input.bool(true,  "Show Medium Arrows", group = grp_visual)
showBig      = input.bool(true,  "Show Big Arrows",    group = grp_visual)
arrowUpColor = input.color(color.rgb(0, 255, 100),  "Buy Arrow Color",  group = grp_visual)
arrowDnColor = input.color(color.rgb(255, 60,  60), "Sell Arrow Color", group = grp_visual)
colorBars    = input.bool(true, "Color Bars on Heavy Volume Body",
     tooltip = "Highlights bars where heavy volume is concentrated inside the body — strong directional conviction.",
     group   = grp_visual)

// ══════════════════════════════════════════════
//   ARROW OFFSET SETTINGS
// ══════════════════════════════════════════════

atrLen  = input.int(14,   "ATR Length",     minval = 1, group = grp_offset,
     tooltip = "Lookback length for ATR calculation used to position arrows above/below bars.")
atrMult = input.float(0.3, "ATR Multiplier", minval = 0.1, step = 0.1, group = grp_offset,
     tooltip = "Controls how far the arrow sits from the bar high/low. Lower = closer to the bar. Start at 0.3 and adjust to taste.")

// ══════════════════════════════════════════════
//   WICK ZONE DETECTION
// ══════════════════════════════════════════════

float topBody  = math.max(open, close)
float lowBody  = math.min(open, close)
float midPrice = (high + low) / 2
bool  bullBar  = close > open
bool  bearBar  = close < open

bool upperWick = midPrice >= topBody and midPrice <= high
bool lowerWick = midPrice <= lowBody and midPrice >= low

// ══════════════════════════════════════════════
//   PERCENTILE THRESHOLDS (three windows each)
// ══════════════════════════════════════════════

float vSmallS = ta.percentile_linear_interpolation(volume, shortLen, smallPct)
float vSmallM = ta.percentile_linear_interpolation(volume, midLen,   smallPct)
float vSmallL = ta.percentile_linear_interpolation(volume, longLen,  smallPct)
float vMedS   = ta.percentile_linear_interpolation(volume, shortLen, mediumPct)
float vMedM   = ta.percentile_linear_interpolation(volume, midLen,   mediumPct)
float vMedL   = ta.percentile_linear_interpolation(volume, longLen,  mediumPct)
float vBigS   = ta.percentile_linear_interpolation(volume, shortLen, bigPct)
float vBigM   = ta.percentile_linear_interpolation(volume, midLen,   bigPct)
float vBigL   = ta.percentile_linear_interpolation(volume, longLen,  bigPct)

// ══════════════════════════════════════════════
//   CONSENSUS FUNCTION
// ══════════════════════════════════════════════

f_consensus(bool pS, bool pM, bool pL, string mode) =>
    int hits = (pS ? 1 : 0) + (pM ? 1 : 0) + (pL ? 1 : 0)
    switch mode
        "Any Window"               => hits >= 1
        "Majority (2 of 3)"       => hits >= 2
        "All Windows (strictest)" => hits >= 3

// ══════════════════════════════════════════════
//   VOLUME TIER DETECTION
// ══════════════════════════════════════════════

bool isBig   = f_consensus(volume >= vBigS,   volume >= vBigM,   volume >= vBigL,   consensusMode)
bool isMed   = not isBig and f_consensus(volume >= vMedS,   volume >= vMedM,   volume >= vMedL,   consensusMode)
bool isSmall = not isBig and not isMed and f_consensus(volume >= vSmallS, volume >= vSmallM, volume >= vSmallL, consensusMode)

// ══════════════════════════════════════════════
//   ABSORPTION ZONE FILTERS
// ══════════════════════════════════════════════

bool validSell = upperWick and (filterDir ? bullBar : true)
bool validBuy  = lowerWick and (filterDir ? bearBar : true)

// ══════════════════════════════════════════════
//   FINAL SIGNAL CONDITIONS
// ══════════════════════════════════════════════

bool sigSellSmall = isSmall and validSell and showSmall
bool sigSellMed   = isMed   and validSell and showMedium
bool sigSellBig   = isBig   and validSell and showBig

bool sigBuySmall  = isSmall and validBuy  and showSmall
bool sigBuyMed    = isMed   and validBuy  and showMedium
bool sigBuyBig    = isBig   and validBuy  and showBig

// ══════════════════════════════════════════════
//   ARROW PLOTS (fixed ATR offset)
// ══════════════════════════════════════════════

float atrOffset = ta.atr(atrLen) * atrMult

plotshape(sigSellSmall ? high + atrOffset : na, "", shape.arrowdown, location.absolute, arrowDnColor, size = size.small)
plotshape(sigSellMed   ? high + atrOffset : na, "", shape.arrowdown, location.absolute, arrowDnColor, size = size.normal)
plotshape(sigSellBig   ? high + atrOffset : na, "", shape.arrowdown, location.absolute, arrowDnColor, size = size.large)

plotshape(sigBuySmall  ? low - atrOffset : na, "", shape.arrowup, location.absolute, arrowUpColor, size = size.small)
plotshape(sigBuyMed    ? low - atrOffset : na, "", shape.arrowup, location.absolute, arrowUpColor, size = size.normal)
plotshape(sigBuyBig    ? low - atrOffset : na, "", shape.arrowup, location.absolute, arrowUpColor, size = size.large)

// ══════════════════════════════════════════════
//   BAR COLORING
// ══════════════════════════════════════════════

bool insideBody   = midPrice > lowBody and midPrice < topBody
bool heavyVolBody = isBig or isMed

barcolor(colorBars and insideBody and heavyVolBody and bullBar ? color.rgb(0, 255, 0)    : na)
barcolor(colorBars and insideBody and heavyVolBody and bearBar ? color.rgb(255, 132, 132) : na)

// ══════════════════════════════════════════════
//   ALERTS
// ══════════════════════════════════════════════

alertcondition((sigBuySmall or sigBuyMed or sigBuyBig) and barstate.isconfirmed,
     title   = "Buying Absorption",
     message = "Absorption Arrows v2: Buying absorption detected")

alertcondition((sigSellSmall or sigSellMed or sigSellBig) and barstate.isconfirmed,
     title   = "Selling Absorption",
     message = "Absorption Arrows v2: Selling absorption detected")

alertcondition((sigBuySmall or sigBuyMed or sigBuyBig or sigSellSmall or sigSellMed or sigSellBig) and barstate.isconfirmed,
     title   = "Absorption (Any)",
     message = "Absorption Arrows v2: Absorption event detected")

alertcondition((sigBuyBig or sigSellBig) and barstate.isconfirmed,
     title   = "Big Absorption Only",
     message = "Absorption Arrows v2: HIGH CONVICTION absorption event detected")
````
