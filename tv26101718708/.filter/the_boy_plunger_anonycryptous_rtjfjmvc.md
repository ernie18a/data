# The Boy Plunger | Anonycryptous

- url: https://www.tradingview.com/script/RtjfJMVc-The-Boy-Plunger-Anonycryptous/
- type: indicator
- pine_id: PUB;b5056e2b72c24bbd8f951c126514ad21
- version: 1.0

## Description

The Boy Plunger | Anonycryptous
Description & user manual

Why is this indicator different?
Most breakout indicators do one thing: they draw a line and fire a signal when price crosses it. They do not ask whether the move is real. They do not ask whether the volume confirms it. They do not ask whether the broader trend supports it. They just fire.

The Boy Plunger is built on a different philosophy. It does not look for crossings. It looks for proof.
Every signal in this indicator requires the market to pass through a series of gates before anything fires. A key structural level must be present. Price must approach it with observable intent. Volume must confirm participation. The body of the breakout candle must show conviction. The ribbon must be aligned with the move. Only when all required conditions are satisfied does a signal appear.
This is confirmation trading in its strictest form. It produces fewer signals than most indicators. That is not a weakness. That is the point.

Most indicators on TradingView that claim to be based on Livermore's method are either a single pivot high/low scanner or a basic breakout line. None of them implement the full confirmation philosophy — the waiting zone, the volume proof, the structural gate, the failed breakout detection. This indicator does all of that in a single tool, across all markets and timeframes, with a modular seven-preset system that lets you trade pure Livermore methodology or adapt it to modern intraday conditions.

A tribute to Jesse Lauriston Livermore (1877-1940)
He started with five dollars and a notebook. No connections, no capital, no safety net — just the ability to read price and the discipline to wait. By 1929 he had turned that into an estimated one hundred million dollars, shorting the crash while the rest of the world burned.

He defined what it means to trade with conviction. Wait for the decisive point. Watch how the market behaves around key levels. Demand proof before committing. Exit without hesitation when the market proves you wrong.
He called these moments pivot points — not a formula, but a philosophy. The market reveals its hand when it breaks away from structure with strength and volume. Everything before that is noise.
But Livermore also lost it all. Four times. He broke his own rules, overtraded, let emotion overrule his system. The man who made one hundred million dollars was declared bankrupt in 1934. On November 28, 1940, he took his own life in a New York hotel. His farewell note read: "My life has been a failure."

It wasn't. He gave traders a language to describe what markets do. A century later, his observations are still the foundation of how serious traders think about price.

This indicator is built on his principles:
- structure defines the battlefield
- volume confirms the move
- trend determines the direction
- proof before entry, always
What you do with it is your decision.

1. Overview
The Boy Plunger is a multi-engine confluence indicator built for traders who want to trade with structure, confirmation, and discipline. It works on all markets and timeframes — equities, crypto, futures, forex, indices. Nothing is hardcoded to a specific instrument.

The indicator contains seven engines that work together:
- Silk ribbon — multi-strand MA system for macro trend
- Htf levels — higher timeframe pivot structure as key levels
- Volume engine — spike detection with delta confirmation
- Signal gate — preset-based multi-condition filter
- Fvg engine — fair value gap detection for entry refinement
- Htf reversal radar — multi-timeframe warning system
- Trade block — locked entry, stop, and take profit management
All seven engines are visible simultaneously on the main chart. The dashboard gives you a real-time read of every active condition. The trade block locks the moment a signal fires and does not move until the trade is resolved.

2. The waiting zone system
This is the core visual innovation of the indicator. Rather than coloring elements only when a signal fires, every component communicates the current stage of a developing setup:

Scanning — price is away from any key level. The ribbon is grey and dimmed. No setup is developing.

Watching — price has entered the proximity zone around a key htf level (within a configurable ATR distance). The level turns gold. The waiting zone is active. This is the "I am watching" state that Livermore described — the market is approaching the decisive point but has not proven anything yet.

Confirmed — price breaks the level with volume spike and body conviction. Everything fires to full color. The signal candle is highlighted. If the preset requires it, the signal fires.

This three-state system means the chart is always telling you something — not just when a signal happens, but what stage of development you are in. Scanning means relax. Watching means pay attention. Confirmed means decide.

3. Presets
The indicator has seven presets that define which gates are required for a signal to fire. You change the preset in the settings under the preset group.

Livermore
The purest implementation of his method. No EMA gate — he did not use EMAs. Level proximity required. Volume spike required. Body conviction required. This preset is designed for traders who want to apply his original philosophy as closely as possible to modern markets. The recommended cooldown is 10 bars based on testing across multiple instruments — long enough to avoid noise, short enough to catch valid retests of confirmed levels. Best results observed on 15m and above.

Boy plunger
The intraday adaptation. Macro trend gate added via the ribbon (HMA 8/21 by default). Level required. Volume required. Body required. Cooldown shorter by default. Built for scalp-oriented traders who want Livermore's structure logic on faster timeframes. The HMA is used instead of EMA because of its faster response and cleaner directional read on lower timeframes.

Ribbon
Uses the MA cross as the primary gate. The level acts as a structural filter rather than a requirement. Best for trend-following traders who want ribbon-confirmed entries near key structure.

Sensitive
Level and volume spike only. No trend gate, no body filter. Produces more signals. Use when you want maximum opportunity detection and prefer to filter visually yourself.

Balanced
Trend, level, and volume. The middle ground between sensitivity and selectivity. Recommended starting point if you are new to the indicator.

Fvg entry
Balanced gates plus a requirement that price is inside an active fair value gap at signal time. This produces the tightest entries and smallest stop distances. Note: fair value gaps are not part of Livermore's original methodology. This preset is for modern traders who combine his structural philosophy with imbalance-based entry timing.

Custom
All engine gates become individual toggles. You build your own preset. Every toggle has a tooltip explaining its function and its relationship to Livermore's original method.

4. The silk ribbon
The ribbon consists of seven MA strands between your fast and slow periods, with gradient fills between them. The MA type applies to all strands simultaneously.
Available types: EMA, HMA, DEMA, TEMA, ZLEMA.
HMA is recommended for intraday scalping. EMA is more stable for swing setups. DEMA and TEMA reduce lag further but can be noisy on short timeframes. ZLEMA minimizes lag while maintaining smoothness.

The ribbon colors purely based on trend direction:
- Green when fast strand is above slow strand (bull)
- Red when fast strand is below slow strand (bear)
- Grey when flat

The color intensity and fill transparency are controlled by a single transparency slider. The fast strand width is separately configurable.
Cross signals (tiny circles) fire when the fast and slow strands cross. These are early warnings of potential trend change, not entry signals by themselves.

5. Htf levels
The indicator pulls pivot highs and lows from a higher timeframe of your choice using request.security. This means the levels you see on your 1m or 5m chart are actual structural levels from the 4h or daily chart — not redrawn approximations.
You can set a separate count for resistance levels and support levels. The nearest-only toggle reduces this to one resistance and one support — the most relevant levels on each side of price.

Each level has three visual states that match the waiting zone system described above. Scanning levels are dimmed. Watching levels turn gold. Confirmed breakout levels turn green or red.
An optional current timeframe overlay adds the pivots from your active chart at high transparency. This gives structural context without cluttering the main htf levels.
The failed breakout marker fires when price confirms a level, then returns through it within a configurable number of bars. This is the direct implementation of Livermore's rule: if the market moves back against you after a breakout, exit quickly with a small loss.

6. Volume engine
The volume engine has two components:
Spike detection: volume must exceed the configurable-period SMA multiplied by the spike multiplier. Default is 1.5x — meaning volume must be at least fifty percent above average to qualify.

Body conviction: the candle body must represent at least a configurable percentage of the total candle range. Default is 55%. This filters out doji candles and wick-heavy indecision candles from being counted as confirmed breakouts.

The volume halo appears on the chart for every spike bar. Its height scales with the volume ratio — a 3x spike produces a taller halo than a 1.5x spike. The halo color uses delta logic:
- Green for bull body with conviction (buying commitment)
- Red for bear body with conviction (selling commitment)
- Gold for high-volume doji or mixed candle (institutional activity, unclear direction)

The ratio text inside the halo shows the exact multiple (2.1x, 3.4x, etc.). Its opacity scales with strength — a weak spike shows faint text, a strong spike shows full text. This means glancing at the halo tells you both the direction and magnitude of institutional participation at that bar.

7. Htf ghost candles
The ghost candle engine projects the last N closed higher timeframe candles to the right of your chart, plus the current live (unfinished) htf candle. This gives you the htf price structure in candle form without switching timeframes.
The ghost candle timeframe is independent from the htf level timeframe. You can show 4H structural levels while projecting 1H ghost candles, or combine them however fits your workflow.
Closed candles are drawn left to right, oldest to newest. Each candle consists of a body box and a wick line. Bull candles are green, bear candles are red. No time labels appear on any candle — pure price structure only.
The live candle (the current unfinished htf bar) is drawn rightmost in a gold tint to distinguish it from closed candles. As the htf bar develops, this candle updates in real time.
Optional OHLC labels show the high, low, and close price to the right of each candle. The close label uses the candle direction color (green or red). High and low labels are grey.

Configurable settings:
- Ghost candle timeframe (independent from htf level TF)
- Number of closed candles to show (1-8)
- Right offset from last bar
- Candle width in bars
- Gap between candles
- OHLC labels on/off
- Bull, bear, wick, and live candle colors

8. Fair value gaps
Fair value gaps are three-bar imbalances where the middle candle leaves a gap between the high of the first candle and the low of the third candle (for bullish gaps) or the reverse. They represent areas where price moved too fast to fill orders on both sides.
In this indicator, fvgs are disabled by default in all presets except fvg entry. This is intentional — they are not part of Livermore's method and were not available to him. They are provided as an optional tool for traders who use modern imbalance concepts alongside structural analysis.
When enabled, fvgs show partial mitigation as price fills them progressively. Fully mitigated gaps are either removed or shown in a dimmed grey depending on your settings. The max visible fvg count prevents the chart from becoming cluttered on instruments with frequent gaps.

9. Htf reversal radar
The reversal radar monitors three configurable higher timeframes simultaneously for potential reversal conditions. A warning fires when two or more timeframes show:
- An EMA cross in the opposite direction to the current trend, or
- An RSI extreme exit (above 70 crossing back down, or below 30 crossing back up)
The warning appears as a small diamond plotshape and is reflected in the dashboard. It does not block signals — it is contextual information that something may be changing on higher timeframes while you are looking at a lower timeframe setup.

10. Rsi divergence
The divergence engine compares price pivot highs/lows to RSI pivot highs/lows. Bullish divergence fires when price makes a lower low but RSI makes a higher low. Bearish divergence fires when price makes a higher high but RSI makes a lower high.
Lines are drawn connecting the pivots that form the divergence. A small "div" text label appears at the endpoint. Line width and colors are separately configurable.
Divergence does not gate signals in any preset. It is contextual information — a potential warning that momentum is weakening even as price extends.

11. Signal quality filters
Three additional filters apply across all presets:
Cooldown: a minimum number of bars must pass between signals. This prevents multiple signals from firing on the same setup as it develops. Recommended: 10 bars as a starting point. Adjust based on your timeframe and how often valid setups appear. The dashboard shows either "ready" or the number of bars remaining.
Max ATR distance: if price is too far extended from the ribbon fast strand, the signal is blocked. This prevents entries on moves that are already largely done. Default is 3 ATR from the ribbon.
Pullback gate: an optional filter that requires price to return toward the ribbon after a breakout before confirming an entry. This is the cleanest implementation of Livermore's preferred entry timing — let the level break, let the market prove it wants to go, then enter on the retest rather than the initial breakout. Fewer signals, better risk to reward.

12. Trade block
The trade block appears only when a trade is active. It locks the moment a signal fires and does not move until the trade closes.

Components:
- Entry line with label showing price and direction
- Stop line (ATR, swing high/low, or hybrid of the two)
- Three take profit lines at configurable R multiples
- Risk zone box between entry and stop
- Reward boxes between entry and each TP
- Phase label above TP3 showing preset and direction
- R:R ratio and win rate displayed in the reward zone
TP lines dim when not yet reached and become fully saturated when hit. This gives you an immediate visual read of where you are in the trade without looking at the dashboard.

When the trade closes, a labeled exit appears at the exit candle:
- tp1, tp2, tp3 in green with dark text
- sl in red with dark text
- trail in gold with dark text
These labels remain on the chart after the trade closes so you can review the history.

Stop loss modes:
- ATR: stop at entry plus or minus ATR multiplied by a configurable value
- Swing: stop at the recent swing high or low
- Hybrid: the wider of the two — provides the most structure-aware placement

Trail stop activates after TP1 is hit. After TP1, the stop moves to breakeven. After TP2, the stop trails behind the ribbon fast strand with a configurable buffer.

13. Dashboard reference
The dashboard updates every bar at the latest bar. All values are live.

Htf — the timeframe driving the structural levels
Macro trend — ribbon direction (bull / bear)
Ribbon — active MA type
Active level — nearest htf pivot level to current price
Level state — scanning / watching / confirmed up / confirmed down
Volume ratio — current bar volume relative to the SMA (e.g. 1.8x avg or spike 2.3x)
Body ratio — current candle body as percentage of total range
Fvg active — count of active unmitigated bull and bear fvgs
Divergence — bull div or bear div if active, otherwise --
Htf radar — number of higher timeframes showing reversal conditions
Signal gate — active preset name
Last signal — most recent signal direction and whether trade is active
Tp progress — three dots showing current trade's TP hit status (o unlit, ^ hit)
Tp1 rate — percentage of total trades that reached TP1
Tp2 rate — percentage of total trades that reached TP2
Tp3 rate — percentage of total trades that reached TP3
Failed breakouts — cumulative count of failed breakout signals
Long win rate — TP1 hit rate on long signals only
Short win rate — TP1 hit rate on short signals only
Cooldown — bars remaining before next signal is allowed, or "ready"

14. Settings overview
Preset group
- Signal gate preset (7 options)
- Custom gate toggles (active only in custom preset)
- Signal cooldown on/off and bar count
- Pullback gate on/off and window
- Max ATR distance on/off and multiplier

Silk ribbon group
- Show ribbon on/off
- MA type
- Fast and slow periods
- Ribbon transparency slider
- Fast strand width
- Show cross signals on/off
- Bull and bear cross colors

Htf levels group
- Htf timeframe
- Pivot length
- Max resistance levels shown (1-8)
- Max support levels shown (1-8)
- Nearest only toggle
- Level line width
- Resistance, support, watching, and confirmed colors
- Show current TF levels on/off
- Current TF pivot length
- Watching zone ATR distance
- Failed breakout lookback bars

Volume engine group
- Show volume halo on/off
- Volume SMA length
- Spike multiplier
- Min body ratio
- Halo height ATR multiplier

Htf ghost candles group
- Show ghost candles on/off
- Ghost candle timeframe
- Number of candles to show
- Right offset, width, and gap between candles
- Show OHLC labels on/off
- Bull, bear, wick, and live candle colors

Fvg group
- Show fvgs on/off (off by default except in fvg entry preset)
- Max visible fvg count
- Min gap size in ATR
- Extend to right on/off
- Keep mitigated gaps on/off
- Bull, bear, and mitigated colors

Htf reversal radar group
- Enable radar on/off
- Three radar timeframes

Divergence group
- Show divergence on/off
- Pivot left and right lookback
- Max bars between pivots
- Show divergence lines on/off
- Line width
- Bull and bear divergence colors

Trade block group
- Show trade block on/off
- Show exit labels on/off
- Exit label colors (TP, SL, trail)
- SL source (ATR, swing, hybrid)
- ATR stop multiplier
- Swing lookback
- TP1, TP2, TP3 R multiples
- Trail stop on/off
- Trail buffer ATR multiplier
- Project bars (width of the trade block)

Dashboard group
- Show dashboard on/off
- Position (four corners)
- Size (tiny, small, normal)

15. How to use — beginners
If you are new to technical analysis and confluence-based trading, start here.
Step 1: add the indicator and set the preset to "balanced."

Step 2: set your htf timeframe to something higher than the chart you are watching. If you are on a 5m chart, use 1H. If you are on a 15m chart, use 4H.

Step 3: watch the dashboard. When level state changes from "scanning" to "watching," that means price is approaching a key level. This is your cue to pay close attention.

Step 4: wait. Do not act on "watching." Wait for volume to confirm. Wait for the ribbon to be aligned. Wait for the body ratio to show a conviction candle. When the level state changes to "confirmed," that is when the indicator agrees a signal may be valid.

Step 5: if a triangle signal appears below or above a candle, that means all preset gates passed simultaneously. The trade block will lock your entry, stop, and targets automatically.

Step 6: manage the trade with the trade block. Watch the TP progress dots in the dashboard. When dots light up, TPs are being hit.

Step 7: after the trade closes, look at the exit label on the chart. This tells you how the trade resolved — tp1, tp2, tp3, sl, or trail.

Step 8: over time, watch the dashboard metrics. TP1 rate above 60% on your chosen preset and timeframe is a solid foundation. If it is below 50%, try adjusting the cooldown, the volume multiplier, or the htf level pivot length.

16. How to use — experienced traders
For traders who understand confluence and want to customize the indicator for their own methodology:

The custom preset gives you individual control over every gate. Use this if you have a specific condition combination that the named presets do not cover.

The pullback gate is the highest-value optional filter in the indicator. Enable it if you find that your signals are entering too early on breakout candles and getting caught in the initial wick. It waits for price to retrace toward the ribbon before confirming entry.

The ribbon period settings matter significantly on lower timeframes. For 1m and 5m, test HMA 8/21. For 15m, HMA 13/34 or EMA 21/55. For 1H and above, EMA 21/89 gives cleaner swing context without too much noise.

The volume spike multiplier should be adjusted by instrument. Crypto and oil tend to have more frequent spikes than equity index futures. Start at 1.5x and move up to 2.0x if you are getting too many false spikes.

The failed breakout lookback (default 3 bars) can be extended to 5-8 bars on higher timeframes where reactions take longer to develop.

For multi-timeframe setups, use the htf reversal radar with timeframes one step above your normal analysis chain. If you trade on 15m, set the radar to 1H, 4H, and daily. A warning on two or more of those while a signal fires on your 15m is meaningful context.

17. Performance notes from testing
The Livermore preset on 15m across multiple instruments (MNQ, BTC futures, micro gold, crude oil) showed the following general ranges across several hundred signals. These are not guarantees and will vary by instrument and market conditions.

TP1 rate: 66-75% depending on instrument
TP2 rate: 27-45%
TP3 rate: 14-25%
Long win rate (TP1 as measure): 68-80%
Short win rate (TP1 as measure): 55-70%
The gap between long and short rates reflects the natural long bias of most risk assets over time. Instruments with persistent directional trends tend to show higher rates in the direction of that trend.
A 10-bar cooldown showed better results than 5 bars or 50 bars in testing. At 5 bars, too many signals clustered around the same level. At 50 bars, valid retests were missed entirely. At 10 bars, the indicator captures the initial breakout and the first meaningful retest while filtering pure noise.
These numbers should be treated as starting points for your own testing, not as targets to optimize around. Your instrument, timeframe, and current market regime will all affect them.

18. Alerts
The indicator includes eight alert conditions accessible through TradingView's alert system:
- Long signal confirmed
- Short signal confirmed
- Failed breakout detected
- Htf bear reversal warning (2+ timeframes)
- Htf bull reversal warning (2+ timeframes)
- Bull divergence detected
- Bear divergence detected
- Level watching (price approaching key htf level)
Set the alert on "once per bar close" for the cleanest signals without repainting on the current bar.

19. Compatibility
Works on all instruments: equities, ETFs, crypto, forex, futures, indices, commodities.
Works on all timeframes from 1m to monthly.
No hardcoded tick sizes, contract specifications, or session times.
No repainting on closed bars. The current bar may repaint as it develops, which is expected behavior for any indicator.
Pine Script v6. Requires TradingView Essential plan or above for the best performance due to the multiple request.security calls used for htf levels.

20. What this indicator does not do
- Does not connect to any broker
- Does not place trades automatically
- Does not guarantee any level of profitability
- Does not predict future price movement
- Does not work without price data — it needs bars to calculate
- Does not replace your own market analysis and judgment

The indicator provides structured visual context and a confirmation framework. The decision to enter, manage, and exit a trade remains entirely yours.

21. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document constitutes financial advice or any form of recommendation to buy or sell any financial instrument.
All trading decisions are made entirely by the user. Trading financial instruments involves substantial risk of loss. Past indicator performance on historical data is not indicative of future results. You may lose all of your invested capital.
Anonycryptous accepts no responsibility or liability for any trading losses incurred as a result of using this indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Anonycryptous

//@version=6
indicator("The Boy Plunger | Anonycryptous", shorttitle="TBP | Anonycryptous", overlay=true,
     max_bars_back=500, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// A tribute to Jesse Lauriston Livermore (1877–1940)
// "The Boy Plunger" -- master of the pivot point, patience, and proof.
// He never entered a trade randomly. He waited for the market to reveal its hand.
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// GROUP CONSTANTS
// ══════════════════════════════════════════════════════════════════════════════
var string G_PRE   = "════════ Preset ════════"
var string G_SILK  = "════════ Silk ribbon (EMA) ════════"
var string G_HTF   = "════════ HTF levels ════════"
var string G_VOL   = "════════ Volume engine ════════"
var string G_FVG   = "════════ Fair value gaps ════════"
var string G_REV   = "════════ HTF reversal radar ════════"
var string G_DIV   = "════════ Divergence ════════"
var string G_GHOST = "════════ HTF ghost candles ════════"
var string G_RISK  = "════════ Trade block ════════"
var string G_DASH  = "════════ Dashboard ════════"

// ══════════════════════════════════════════════════════════════════════════════
// BRAND COLORS
// ══════════════════════════════════════════════════════════════════════════════
color C_BULL    = #00ff00
color C_BEAR    = #ff0000
color C_NEUT    = #808080
color C_GOLD    = #f5c518
color C_PURPLE  = #bb86fc
color C_DASH_BG = #0d1117
color C_PANEL   = #161b22
color C_BORDER  = #30363d
color C_MUTED   = #8b949e
color C_WHITE   = #ffffff

// Silk ribbon palette
color SILK_1 = #00ffbb
color SILK_2 = #00e5ff
color SILK_3 = #40c4ff
color SILK_4 = #bb86fc
color SILK_5 = #e040fb
color SILK_6 = #ff6d00
color SILK_7 = #304ffe

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- PRESET
// ══════════════════════════════════════════════════════════════════════════════
preset = input.string("balanced", "Signal gate preset", group=G_PRE,
     options=["livermore", "boy plunger", "ribbon", "sensitive", "balanced", "fvg entry", "custom"],
     tooltip="livermore -- pure Livermore swing method. Daily/Weekly HTF levels, volume + body conviction, no EMA gate, long cooldown.\nboy plunger -- TBP intraday scalp. 15m/1H/4H levels, HMA ribbon gate, volume + body. Short cooldown.\nribbon -- MA cross as primary gate, HTF level as filter. HMA recommended.\nsensitive -- level + volume spike only. More signals, less filtered.\nbalanced -- trend + level + volume. Recommended default.\nfvg entry -- balanced + price inside active FVG at signal time. Tighter entries. Not part of Livermore original method.\ncustom -- build your own setup with individual engine toggles.")

// Custom gate toggles (only active when preset = custom)
gateUseTrend  = input.bool(true,  "Gate: macro trend aligned",    group=G_PRE, tooltip="Only fire signals when the silk ribbon EMA cross is aligned with signal direction.")
gateUseLevel  = input.bool(true,  "Gate: HTF level proximity",    group=G_PRE, tooltip="Only fire signals when price is near an active HTF pivot level.")
gateUseVol    = input.bool(true,  "Gate: volume spike",           group=G_PRE, tooltip="Only fire signals when volume exceeds the spike threshold.")
gateUseBody   = input.bool(true,  "Gate: body ratio conviction",  group=G_PRE, tooltip="Only fire signals when the breakout candle has a strong body vs wick ratio.")

// Signal quality filters — apply to all presets
useCooldown    = input.bool(true,  "Signal cooldown",              group=G_PRE, tooltip="Prevents multiple signals firing too close together on the same level. Highly recommended.")
cooldownBars   = input.int(10,     "Cooldown bars",                group=G_PRE, minval=1, maxval=100, tooltip="Minimum bars between signals. Default 10.")
usePullback    = input.bool(false, "Require pullback to ribbon",   group=G_PRE, tooltip="Livermore's preferred entry method — wait for price to break the level, then pull back toward the ribbon before confirming entry. Fewer signals, better R:R.")
pullbackBars   = input.int(10,     "Max bars to find pullback",    group=G_PRE, minval=2, maxval=50, tooltip="After a breakout, how many bars to wait for the pullback to the ribbon. If no pullback occurs within this window, the setup expires.")
useMaxDist     = input.bool(true,  "Max distance from ribbon",     group=G_PRE, tooltip="Blocks entries when price is too far extended from the ribbon. Avoids chasing moves already largely done.")
maxDistATR     = input.float(3.0,  "Max ATR distance from ribbon", group=G_PRE, step=0.5, tooltip="If close is more than this many ATRs away from the fast ribbon strand, the signal is blocked.")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- SILK RIBBON
// ══════════════════════════════════════════════════════════════════════════════
showRibbon   = input.bool(true,   "Show silk ribbon",    group=G_SILK)
maType       = input.string("EMA", "MA type",            group=G_SILK, options=["EMA","HMA","DEMA","TEMA","ZLEMA"],
     tooltip="Applies to all ribbon strands simultaneously.\nEMA = standard exponential MA.\nHMA = Hull MA -- fast, smooth, responsive.\nDEMA = double EMA -- less lag.\nTEMA = triple EMA -- even less lag.\nZLEMA = zero-lag EMA.")
ribbonFast   = input.int(9,    "Fast period",  group=G_SILK, minval=2)
ribbonSlow   = input.int(21,   "Slow period",  group=G_SILK, minval=3)
showCross     = input.bool(true, "Show cross signals",    group=G_SILK, tooltip="Plots a tiny circle on the bar where the fast strand crosses the slow strand.")
ribbonAlpha   = input.int(60,   "Ribbon transparency",   group=G_SILK, minval=0, maxval=95, tooltip="Global transparency for all ribbon strands and fills. 0 = fully opaque, 95 = nearly invisible.")
ribbonWidth   = input.int(1,    "Fast strand width",     group=G_SILK, minval=1, maxval=4, tooltip="Line width of the fast (outermost) ribbon strand.")
col_bullCross = input.color(C_BULL, "Bull cross color",  group=G_SILK)
col_bearCross = input.color(C_BEAR, "Bear cross color",  group=G_SILK)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- HTF LEVELS
// ══════════════════════════════════════════════════════════════════════════════
htfTF         = input.timeframe("240",  "HTF timeframe",                 group=G_HTF, tooltip="Pivot highs/lows are pulled from this timeframe. When set to 4H you see 4H structure levels. 15m gives 15m levels.")
htfPivLen     = input.int(5,            "HTF pivot length",              group=G_HTF, minval=2, tooltip="Higher = fewer, more significant levels.")
htfMaxRes     = input.int(3,            "Max resistance levels",         group=G_HTF, minval=1, maxval=8, tooltip="How many HTF resistance (pivot high) levels to draw. Set to 1 for only the nearest.")
htfMaxSup     = input.int(3,            "Max support levels",            group=G_HTF, minval=1, maxval=8, tooltip="How many HTF support (pivot low) levels to draw. Set to 1 for only the nearest.")
htfNearestOnly = input.bool(false,      "Nearest level only (per side)", group=G_HTF, tooltip="When enabled, overrides the max settings and shows only the single closest resistance and support level. Clean, minimal view.")
htfLevelWidth = input.int(2,            "Level line width",              group=G_HTF, minval=1, maxval=4)
col_htfRes    = input.color(#ff4444,    "Resistance color",              group=G_HTF)
col_htfSup    = input.color(#00cc88,    "Support color",                 group=G_HTF)
col_htfWatch  = input.color(C_GOLD,     "Watching state color",          group=G_HTF, tooltip="Color when price approaches a level but breakout not yet confirmed.")
col_htfConf   = input.color(C_BULL,     "Confirmed breakout color",      group=G_HTF)
showCurrTF    = input.bool(true,        "Show current TF levels (dim)",  group=G_HTF, tooltip="Overlays current timeframe pivot levels at high transparency as context.")
currPivLen    = input.int(10,           "Current TF pivot length",       group=G_HTF, minval=2)
watchATRmult  = input.float(1.5,        "Watching zone ATR distance",    group=G_HTF, step=0.1, tooltip="How close price needs to be to a level (in ATR multiples) to enter watching state.")
failBars      = input.int(3,            "Failed breakout lookback bars", group=G_HTF, minval=1, maxval=10, tooltip="After a confirmed breakout, if price returns through the level within this many bars, a failed breakout marker fires.")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- VOLUME ENGINE
// ══════════════════════════════════════════════════════════════════════════════
showVolHalo  = input.bool(true,   "Show volume halo on chart",   group=G_VOL, tooltip="Draws a glowing box below/above spike bars directly on the main chart. Height scales with spike ratio.")
volSMAlen    = input.int(20,      "Volume SMA length",           group=G_VOL, minval=5)
volMult      = input.float(1.5,   "Spike multiplier",            group=G_VOL, step=0.1, tooltip="Volume must exceed SMA × this multiplier to qualify as a spike. 1.5 = 50% above average.")
bodyRatioMin = input.float(0.55,  "Min body ratio (conviction)", group=G_VOL, step=0.05, tooltip="Body / total range. 0.55 = body must be at least 55% of the candle range. Filters doji and wick-heavy candles.")
col_volBull  = input.color(color.new(#00ff88, 60), "Bull spike halo color", group=G_VOL)
col_volBear  = input.color(color.new(#ff3333, 60), "Bear spike halo color", group=G_VOL)
haloATRmult  = input.float(0.4,   "Halo height (ATR mult)",      group=G_VOL, step=0.05, tooltip="Base height of the volume halo box in ATR multiples. Scales additionally with spike ratio.")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- FVG ENGINE
// ══════════════════════════════════════════════════════════════════════════════
showFVG      = input.bool(false,  "Show fair value gaps", group=G_FVG, tooltip="Fair value gaps are not part of Livermore's original methodology. Enable for visual context or use the 'fvg entry' preset to require FVG confirmation on signals.")
fvgMaxCount  = input.int(5,       "Max visible FVGs",    group=G_FVG, minval=1, maxval=50, tooltip="Maximum number of active (unmitigated) FVGs drawn at once. Oldest are removed first when the limit is reached. Mitigated FVGs do not count toward this limit.")
fvgATRmult   = input.float(0.1,   "Min gap size (ATR)",  group=G_FVG, step=0.05, tooltip="Minimum gap size relative to ATR(144) for an FVG to register.")
fvgExtend    = input.bool(true,   "Extend to right",      group=G_FVG)
fvgVanish    = input.bool(true,   "Keep mitigated (dim)", group=G_FVG)
col_fvgBull  = input.color(color.new(#00cc88, 80), "Bull FVG color",  group=G_FVG)
col_fvgBear  = input.color(color.new(#ff4444, 80), "Bear FVG color",  group=G_FVG)
col_fvgMit   = input.color(color.new(#808080, 90), "Mitigated color", group=G_FVG)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- HTF REVERSAL RADAR
// ══════════════════════════════════════════════════════════════════════════════
showRevRadar = input.bool(true,  "Enable HTF reversal radar", group=G_REV, tooltip="Monitors 3 HTF timeframes for EMA/RSI reversals. Warning fires when 2+ TFs align.")
revTF1       = input.timeframe("60",  "Radar TF 1", group=G_REV)
revTF2       = input.timeframe("240", "Radar TF 2", group=G_REV)
revTF3       = input.timeframe("D",   "Radar TF 3", group=G_REV)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- DIVERGENCE
// ══════════════════════════════════════════════════════════════════════════════
showDiv      = input.bool(true,  "Show RSI divergence",   group=G_DIV)
divLookL     = input.int(5,      "Pivot left",             group=G_DIV, minval=2)
divLookR     = input.int(2,      "Pivot right",            group=G_DIV, minval=1)
divRange     = input.int(60,     "Max bars between",       group=G_DIV)
showDivLines = input.bool(true,  "Draw divergence lines",  group=G_DIV)
divLineWidth = input.int(1,      "Line width",             group=G_DIV, minval=1, maxval=4)
col_divBull  = input.color(color.new(#00e5ff, 20), "Bull div color", group=G_DIV)
col_divBear  = input.color(color.new(#ff6d00, 20), "Bear div color", group=G_DIV)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- HTF GHOST CANDLES
// ══════════════════════════════════════════════════════════════════════════════
showGhost     = input.bool(true,  "Show HTF ghost candles",      group=G_GHOST, tooltip="Projects the last N closed HTF candles to the right of the chart, plus the current live HTF candle. No time labels -- pure structure.")
ghostTF       = input.timeframe("60", "Ghost candle timeframe",  group=G_GHOST, tooltip="The timeframe to pull candles from. Independent from the HTF level timeframe.")
ghostCount    = input.int(3,      "Candles to show",             group=G_GHOST, minval=1, maxval=8, tooltip="Number of closed HTF candles projected. The live (unfinished) candle is always shown additionally.")
ghostOffset   = input.int(12,     "Right offset (bars)",         group=G_GHOST, minval=5, maxval=60, tooltip="How many bars to the right of the last bar the ghost candles start.")
ghostWidth    = input.int(6,      "Candle width (bars)",         group=G_GHOST, minval=2, maxval=20, tooltip="Visual width of each ghost candle in bars.")
ghostGap      = input.int(3,      "Gap between candles (bars)",  group=G_GHOST, minval=1, maxval=10)
showGhostOHLC = input.bool(true,  "Show OHLC price labels",      group=G_GHOST, tooltip="Shows open, high, low, close price labels to the right of each ghost candle.")
col_ghostBull = input.color(color.new(#00cc88, 20), "Bull candle color",  group=G_GHOST)
col_ghostBear = input.color(color.new(#ff4444, 20), "Bear candle color",  group=G_GHOST)
col_ghostWick = input.color(color.new(#8b949e, 40), "Wick color",         group=G_GHOST)
col_ghostLive = input.color(color.new(#f5c518, 50), "Live candle tint",   group=G_GHOST, tooltip="The current unfinished HTF candle uses this color overlay to distinguish it from closed candles.")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- TRADE BLOCK
// ══════════════════════════════════════════════════════════════════════════════
showTrade    = input.bool(true,  "Show trade block",          group=G_RISK)
showExitLbl  = input.bool(true,  "Show exit labels",          group=G_RISK, tooltip="Shows a label above/below the exit candle with the exit type (tp1/tp2/tp3/sl/trail).")
col_exitSL   = input.color(color.new(#ff4444, 0),  "SL label color",    group=G_RISK)
col_exitTP   = input.color(color.new(#00cc88, 0),  "TP label color",    group=G_RISK)
col_exitTRL  = input.color(color.new(#f5c518, 0),  "Trail label color", group=G_RISK)
slSource     = input.string("Hybrid", "SL source",           group=G_RISK, options=["ATR","Swing","Hybrid"],
     tooltip="ATR = entry ± ATR × multiplier.\nSwing = recent swing high/low.\nHybrid = wider of the two.")
atrStopMult  = input.float(1.5,  "ATR stop multiplier",      group=G_RISK, step=0.1)
swingLook    = input.int(10,     "Swing lookback",            group=G_RISK, minval=3)
tp1R         = input.float(0.5,  "TP1 (R)",                  group=G_RISK, step=0.1)
tp2R         = input.float(1.0,  "TP2 (R)",                  group=G_RISK, step=0.1)
tp3R         = input.float(2.0,  "TP3 (R)",                  group=G_RISK, step=0.1)
useTrail     = input.bool(true,  "Trail stop after TP1",     group=G_RISK, tooltip="After TP1: SL moves to breakeven.\nAfter TP2: SL trails below/above ribbon fast strand.")
trailBuf     = input.float(0.2,  "Trail buffer (ATR mult)",  group=G_RISK, step=0.1)
boxExtend    = input.int(20,     "Project bars",             group=G_RISK, minval=5, maxval=60)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS -- DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════
showDash     = input.bool(true,  "Show dashboard",   group=G_DASH)
dashPos      = input.string("Top Right", "Position", group=G_DASH, options=["Top Right","Top Left","Bottom Right","Bottom Left"])
dashSz       = input.string("Small", "Size",         group=G_DASH, options=["Tiny","Small","Normal"])

// ══════════════════════════════════════════════════════════════════════════════
// MA FUNCTION
// ══════════════════════════════════════════════════════════════════════════════
f_ma(src, len, t) =>
    float result = na
    if t == "EMA"
        result := ta.ema(src, len)
    else if t == "HMA"
        result := ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))
    else if t == "DEMA"
        e = ta.ema(src, len)
        result := 2 * e - ta.ema(e, len)
    else if t == "TEMA"
        e1 = ta.ema(src, len)
        e2 = ta.ema(e1, len)
        e3 = ta.ema(e2, len)
        result := 3 * e1 - 3 * e2 + e3
    else if t == "ZLEMA"
        lag = math.round((len - 1) / 2)
        result := ta.ema(src + (src - src[lag]), len)
    result

// ══════════════════════════════════════════════════════════════════════════════
// SILK RIBBON CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════
// 7 strands between fast and slow, evenly spaced
// Preset-based ribbon overrides
// boy plunger: HMA 8/21 (fast scalp ribbon)
// livermore: EMA 21/89 (slow, swing context only)
// others: use input settings
string effectiveMAtype = preset == "boy plunger" ? "HMA" : preset == "livermore" ? "EMA" : maType
int effectiveFast = preset == "boy plunger" ? 8  : preset == "livermore" ? 21 : ribbonFast
int effectiveSlow = preset == "boy plunger" ? 21 : preset == "livermore" ? 89 : ribbonSlow

int step = math.max(1, math.round((effectiveSlow - effectiveFast) / 6))
int p1 = effectiveFast
int p2 = effectiveFast + step * 1
int p3 = effectiveFast + step * 2
int p4 = effectiveFast + step * 3
int p5 = effectiveFast + step * 4
int p6 = effectiveFast + step * 5
int p7 = effectiveSlow

float ma1 = f_ma(close, p1, effectiveMAtype)
float ma2 = f_ma(close, p2, effectiveMAtype)
float ma3 = f_ma(close, p3, effectiveMAtype)
float ma4 = f_ma(close, p4, effectiveMAtype)
float ma5 = f_ma(close, p5, effectiveMAtype)
float ma6 = f_ma(close, p6, effectiveMAtype)
float ma7 = f_ma(close, p7, effectiveMAtype)

bool crossBull = ta.crossover(ma1, ma7)
bool crossBear = ta.crossunder(ma1, ma7)

// Macro trend state
bool trendBull = ma1 > ma7
bool trendBear = ma1 < ma7

// ══════════════════════════════════════════════════════════════════════════════
// ATR
// ══════════════════════════════════════════════════════════════════════════════
float atrVal = ta.atr(14)
float volSMA = ta.sma(volume, volSMAlen)

// ══════════════════════════════════════════════════════════════════════════════
// VOLUME ENGINE
// ══════════════════════════════════════════════════════════════════════════════
float volRatio   = volSMA > 0 ? volume / volSMA : 1.0
bool  volSpike   = volume > volSMA * volMult
float bodySize   = math.abs(close - open)
float totalRange = high - low
float bodyRatio  = totalRange > 0 ? bodySize / totalRange : 0.0
bool  bodyConv   = bodyRatio >= bodyRatioMin
bool  isBullBar  = close >= open

// ══════════════════════════════════════════════════════════════════════════════
// HTF PIVOT LEVELS
// ══════════════════════════════════════════════════════════════════════════════
// Pull HTF pivot highs/lows
[htfHigh, htfLow, htfTime] = request.security(syminfo.tickerid, htfTF,
     [high, low, time], barmerge.gaps_off, barmerge.lookahead_off)

float htfPivH = request.security(syminfo.tickerid, htfTF,
     ta.valuewhen(not na(ta.pivothigh(high, htfPivLen, htfPivLen)), high[htfPivLen], 0),
     barmerge.gaps_off, barmerge.lookahead_off)

float htfPivL = request.security(syminfo.tickerid, htfTF,
     ta.valuewhen(not na(ta.pivotlow(low, htfPivLen, htfPivLen)), low[htfPivLen], 0),
     barmerge.gaps_off, barmerge.lookahead_off)

float htfPivH2 = request.security(syminfo.tickerid, htfTF,
     ta.valuewhen(not na(ta.pivothigh(high, htfPivLen, htfPivLen)), high[htfPivLen], 1),
     barmerge.gaps_off, barmerge.lookahead_off)

float htfPivL2 = request.security(syminfo.tickerid, htfTF,
     ta.valuewhen(not na(ta.pivotlow(low, htfPivLen, htfPivLen)), low[htfPivLen], 1),
     barmerge.gaps_off, barmerge.lookahead_off)

float htfPivH3 = request.security(syminfo.tickerid, htfTF,
     ta.valuewhen(not na(ta.pivothigh(high, htfPivLen, htfPivLen)), high[htfPivLen], 2),
     barmerge.gaps_off, barmerge.lookahead_off)

float htfPivL3 = request.security(syminfo.tickerid, htfTF,
     ta.valuewhen(not na(ta.pivotlow(low, htfPivLen, htfPivLen)), low[htfPivLen], 2),
     barmerge.gaps_off, barmerge.lookahead_off)

float htfPivH4 = request.security(syminfo.tickerid, htfTF,
     ta.valuewhen(not na(ta.pivothigh(high, htfPivLen, htfPivLen)), high[htfPivLen], 3),
     barmerge.gaps_off, barmerge.lookahead_off)

float htfPivL4 = request.security(syminfo.tickerid, htfTF,
     ta.valuewhen(not na(ta.pivotlow(low, htfPivLen, htfPivLen)), low[htfPivLen], 3),
     barmerge.gaps_off, barmerge.lookahead_off)

// Separate resistance and support arrays
float[] htfResLevels = array.from(htfPivH, htfPivH2, htfPivH3, htfPivH4)
float[] htfSupLevels = array.from(htfPivL, htfPivL2, htfPivL3, htfPivL4)

// Nearest HTF level distance -- scans all levels regardless of display limit
float nearestHTF     = na
float nearestHTFdist = 999999.0
for i = 0 to 3
    float rLvl = array.get(htfResLevels, i)
    float sLvl = array.get(htfSupLevels, i)
    if not na(rLvl)
        float d = math.abs(close - rLvl)
        if d < nearestHTFdist
            nearestHTFdist := d
            nearestHTF := rLvl
    if not na(sLvl)
        float d = math.abs(close - sLvl)
        if d < nearestHTFdist
            nearestHTFdist := d
            nearestHTF := sLvl

// Level states
bool levelWatching   = not na(nearestHTF) and nearestHTFdist <= atrVal * watchATRmult
bool levelConfirmedB = levelWatching and close > nearestHTF and volSpike and bodyConv
bool levelConfirmedS = levelWatching and close < nearestHTF and volSpike and bodyConv

// Current TF pivots (dim)
float currPivH = ta.valuewhen(not na(ta.pivothigh(high, currPivLen, currPivLen)), high[currPivLen], 0)
float currPivL = ta.valuewhen(not na(ta.pivotlow(low, currPivLen, currPivLen)), low[currPivLen], 0)

// Draw HTF levels at barstate.islast
var line[]  htfLines  = array.new<line>()
var label[] htfLabels = array.new<label>()

if barstate.islast
    for ln in htfLines
        line.delete(ln)
    array.clear(htfLines)
    for lb in htfLabels
        label.delete(lb)
    array.clear(htfLabels)

    // Determine draw limits
    int drawRes = htfNearestOnly ? 1 : math.min(htfMaxRes, 4)
    int drawSup = htfNearestOnly ? 1 : math.min(htfMaxSup, 4)

    // Draw resistance levels
    int resDrawn = 0
    for i = 0 to 3
        if resDrawn >= drawRes
            break
        float lvl = array.get(htfResLevels, i)
        if not na(lvl) and lvl > 0
            float dist   = math.abs(close - lvl)
            bool isWatch = dist <= atrVal * watchATRmult
            bool isConf  = isWatch and volSpike and bodyConv and close > lvl
            color lineCol = isConf ? col_htfConf : isWatch ? col_htfWatch : col_htfRes
            int   lineOp  = isConf ? 0 : isWatch ? 10 : 25
            array.push(htfLines, line.new(bar_index - 100, lvl, bar_index + 8, lvl,
                 color=color.new(lineCol, lineOp), width=htfLevelWidth, extend=extend.both))
            array.push(htfLabels, label.new(bar_index + 8, lvl,
                 str.tostring(lvl, format.mintick),
                 style=label.style_none, textcolor=color.new(lineCol, lineOp), size=size.small))
            resDrawn += 1

    // Draw support levels
    int supDrawn = 0
    for i = 0 to 3
        if supDrawn >= drawSup
            break
        float lvl = array.get(htfSupLevels, i)
        if not na(lvl) and lvl > 0
            float dist   = math.abs(close - lvl)
            bool isWatch = dist <= atrVal * watchATRmult
            bool isConf  = isWatch and volSpike and bodyConv and close < lvl
            color lineCol = isConf ? col_htfConf : isWatch ? col_htfWatch : col_htfSup
            int   lineOp  = isConf ? 0 : isWatch ? 10 : 25
            array.push(htfLines, line.new(bar_index - 100, lvl, bar_index + 8, lvl,
                 color=color.new(lineCol, lineOp), width=htfLevelWidth, extend=extend.both))
            array.push(htfLabels, label.new(bar_index + 8, lvl,
                 str.tostring(lvl, format.mintick),
                 style=label.style_none, textcolor=color.new(lineCol, lineOp), size=size.small))
            supDrawn += 1

    // Current TF dim levels
    if showCurrTF
        if not na(currPivH) and currPivH > 0
            array.push(htfLines, line.new(bar_index - 50, currPivH, bar_index + 5, currPivH,
                 color=color.new(col_htfRes, 75), width=1))
        if not na(currPivL) and currPivL > 0
            array.push(htfLines, line.new(bar_index - 50, currPivL, bar_index + 5, currPivL,
                 color=color.new(col_htfSup, 75), width=1))

// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL QUALITY FILTERS
// ══════════════════════════════════════════════════════════════════════════════
// Cooldown — min bars between signals
var int lastSignalBar = na
int effectiveCooldown = cooldownBars
bool cooldownOK = not useCooldown or na(lastSignalBar) or (bar_index - lastSignalBar) >= effectiveCooldown

// Max distance from ribbon
float ribbonDist = math.abs(close - ma1)
bool distOK = not useMaxDist or ribbonDist <= atrVal * maxDistATR

// Pullback gate — after a breakout, wait for price to retrace to ribbon
var bool breakoutPending = false
var int  breakoutBar     = na
var bool breakoutDir     = true  // true = bull breakout pending

// Detect raw breakout (level crossed with volume, before pullback filter)
bool rawBreakoutL = close > nz(nearestHTF, close) and isBullBar  and levelWatching and volSpike
bool rawBreakoutS = close < nz(nearestHTF, close) and not isBullBar and levelWatching and volSpike

if usePullback
    if rawBreakoutL and not breakoutPending
        breakoutPending := true
        breakoutDir     := true
        breakoutBar     := bar_index
    if rawBreakoutS and not breakoutPending
        breakoutPending := true
        breakoutDir     := false
        breakoutBar     := bar_index
    // Expire if pullback not found within window
    if breakoutPending and not na(breakoutBar) and (bar_index - breakoutBar) > pullbackBars
        breakoutPending := false

// Pullback confirmed = price has returned to within ribbon range
bool pullbackReachedL = breakoutPending and breakoutDir  and close <= ma1 + atrVal * 0.5 and close >= ma7 - atrVal * 0.5
bool pullbackReachedS = breakoutPending and not breakoutDir and close >= ma1 - atrVal * 0.5 and close <= ma7 + atrVal * 0.5

bool pullbackOK = not usePullback or pullbackReachedL or pullbackReachedS

if pullbackReachedL or pullbackReachedS
    breakoutPending := false

// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL GATE
// ══════════════════════════════════════════════════════════════════════════════
// Pre-declared here -- populated after FVG engine runs below
var bool inBullFVG = false
var bool inBearFVG = false

// Gate requirements per preset
// livermore: level + volume + body, no EMA, long cooldown handled separately
// boy plunger: trend + level + volume + body (HMA)
// ribbon: trend only as primary, level optional
// sensitive: level + volume
// balanced: trend + level + volume
// fvg entry: balanced + fvg
// custom: individual toggles
bool reqTrend = preset == "balanced" or preset == "boy plunger" or preset == "ribbon" or preset == "fvg entry" or (preset == "custom" and gateUseTrend)
bool reqLevel = preset == "livermore" or preset == "boy plunger" or preset == "balanced" or preset == "sensitive" or preset == "fvg entry" or (preset == "custom" and gateUseLevel)
bool reqVol   = preset == "livermore" or preset == "boy plunger" or preset == "balanced" or preset == "sensitive" or preset == "fvg entry" or (preset == "custom" and gateUseVol)
bool reqBody  = preset == "livermore" or preset == "boy plunger" or (preset == "custom" and gateUseBody)
bool reqFVG   = preset == "fvg entry"

bool gateTrendL = not reqTrend or trendBull
bool gateTrendS = not reqTrend or trendBear
bool gateLevel  = not reqLevel or levelWatching
bool gateVol    = not reqVol   or volSpike
bool gateBody   = not reqBody  or bodyConv
bool gateFVGL   = not reqFVG   or inBullFVG
bool gateFVGS   = not reqFVG   or inBearFVG

// Auto-enable FVG drawing when fvg entry preset is active
bool fvgActive  = showFVG or preset == "fvg entry"

bool rawLong  = close > nz(nearestHTF, close) and isBullBar
bool rawShort = close < nz(nearestHTF, close) and not isBullBar

bool longSignal  = rawLong  and gateTrendL and gateLevel and gateVol and gateBody and gateFVGL and cooldownOK and distOK and pullbackOK
bool shortSignal = rawShort and gateTrendS and gateLevel and gateVol and gateBody and gateFVGS and cooldownOK and distOK and pullbackOK

// ══════════════════════════════════════════════════════════════════════════════
// FAILED BREAKOUT DETECTION
// ══════════════════════════════════════════════════════════════════════════════
var bool lastWasLong  = false
var bool lastWasShort = false
var float lastBreakLevel = na
var int   lastBreakBar   = na

if longSignal
    lastWasLong     := true
    lastWasShort    := false
    lastBreakLevel  := nearestHTF
    lastBreakBar    := bar_index

if shortSignal
    lastWasShort    := true
    lastWasLong     := false
    lastBreakLevel  := nearestHTF
    lastBreakBar    := bar_index

bool failedBreakoutL = lastWasLong  and not na(lastBreakLevel) and
     (bar_index - lastBreakBar) <= failBars and (bar_index - lastBreakBar) > 0 and
     close < lastBreakLevel
bool failedBreakoutS = lastWasShort and not na(lastBreakLevel) and
     (bar_index - lastBreakBar) <= failBars and (bar_index - lastBreakBar) > 0 and
     close > lastBreakLevel

if failedBreakoutL or failedBreakoutS
    lastWasLong  := false
    lastWasShort := false
    lastBreakLevel := na

// ══════════════════════════════════════════════════════════════════════════════
// VOLUME HALO
// Delta color: bull body + spike = green, bear body + spike = red,
//              mixed/doji + spike = gold (institutional but unclear direction)
// Ratio text: transparency scales with spike strength — weak spike = faint,
//             strong spike = fully visible. Tells you how significant it was.
// ══════════════════════════════════════════════════════════════════════════════
if showVolHalo and volSpike
    float haloH = haloATRmult * atrVal * math.min(volRatio, 3.0)

    // Delta color — direction of institutional commitment
    color deltaCol = bodyConv and isBullBar  ? color.new(C_BULL, 20) :
                     bodyConv and not isBullBar ? color.new(C_BEAR, 20) :
                     color.new(C_GOLD, 20)

    // Text transparency scales with ratio — 1.5x nearly invisible, 3x+ fully opaque
    float ratioNorm = math.min((volRatio - volMult) / (3.0 - volMult), 1.0)
    int   txtAlpha  = math.round(70 - ratioNorm * 70)  // 70 (faint) → 0 (fully visible)
    color txtCol    = color.new(#8b949e, txtAlpha)      // grey, no white, works on any background
    string ratioTxt = str.tostring(math.round(volRatio, 1)) + "x"

    if isBullBar
        float haloBot = low - haloH
        float haloTop = low
        box.new(bar_index, haloTop, bar_index, haloBot,
             bgcolor=deltaCol, border_color=color.new(C_WHITE, 100), border_width=0)
        label.new(bar_index, haloBot + haloH * 0.5, ratioTxt,
             style=label.style_none, textcolor=txtCol, size=size.tiny, textalign=text.align_center)
    else
        float haloBot = high
        float haloTop = high + haloH
        box.new(bar_index, haloTop, bar_index, haloBot,
             bgcolor=deltaCol, border_color=color.new(C_WHITE, 100), border_width=0)
        label.new(bar_index, haloBot + haloH * 0.5, ratioTxt,
             style=label.style_none, textcolor=txtCol, size=size.tiny, textalign=text.align_center)

// ══════════════════════════════════════════════════════════════════════════════
// FVG ENGINE (from Compass -- rewritten)
// ══════════════════════════════════════════════════════════════════════════════
type FVGobj
    box   uBox
    box   mBox
    line  cLine
    bool  isBull

var FVGobj[] fvgList = array.new<FVGobj>()
var int activeFVGup = 0
var int activeFVGdn = 0
var float fvgMitPctUp = 0.0
var float fvgMitPctDn = 0.0

float fvgATR = nz(ta.atr(144)) * fvgATRmult

bool newBullFVG = low > high[2] and (low - high[2]) > fvgATR and close[1] > high[2]
bool newBearFVG = high < low[2] and (low[2] - high) > fvgATR and close[1] < low[2]

if fvgActive and newBullFVG
    // Remove oldest if at limit
    if array.size(fvgList) >= fvgMaxCount
        FVGobj oldest = array.shift(fvgList)
        oldest.uBox.delete()
        oldest.mBox.delete()
        oldest.cLine.delete()
    gTop = low
    gBot = high[2]
    fvgList.push(FVGobj.new(
         box.new(bar_index - 1, gTop, bar_index, gBot, bgcolor=col_fvgBull, border_color=color.new(C_WHITE, 100)),
         box.new(bar_index - 1, gTop, bar_index, gTop, bgcolor=color.new(#00cc88, 92), border_color=color.new(C_WHITE, 100)),
         line.new(bar_index - 1, gBot, bar_index, gBot, color=col_fvgBull, width=1),
         true))

if fvgActive and newBearFVG
    // Remove oldest if at limit
    if array.size(fvgList) >= fvgMaxCount
        FVGobj oldest = array.shift(fvgList)
        oldest.uBox.delete()
        oldest.mBox.delete()
        oldest.cLine.delete()
    gTop = low[2]
    gBot = high
    fvgList.push(FVGobj.new(
         box.new(bar_index - 1, gTop, bar_index, gBot, bgcolor=col_fvgBear, border_color=color.new(C_WHITE, 100)),
         box.new(bar_index - 1, gBot, bar_index, gBot, bgcolor=color.new(#ff4444, 92), border_color=color.new(C_WHITE, 100)),
         line.new(bar_index - 1, gTop, bar_index, gTop, color=col_fvgBear, width=1),
         false))

if fvgActive and array.size(fvgList) > 0
    activeFVGup := 0
    activeFVGdn := 0
    int i = array.size(fvgList) - 1
    while i >= 0
        FVGobj obj = array.get(fvgList, i)
        if fvgExtend
            obj.uBox.set_right(bar_index)
            obj.mBox.set_right(bar_index)
            obj.cLine.set_x2(bar_index)
        float uTop = obj.uBox.get_top()
        float uBot = obj.uBox.get_bottom()
        bool  fullyMit = false
        if obj.isBull
            if high > uBot and low < uTop
                if low > uBot
                    float newMBot = math.min(low, obj.mBox.get_top())
                    obj.mBox.set_bottom(newMBot)
                    obj.uBox.set_top(newMBot)
                    fvgMitPctUp := (obj.mBox.get_top() - newMBot) / (obj.mBox.get_top() - uBot) * 100
                else
                    fullyMit := true
        else
            if low < uTop and high > uBot
                if high < uTop
                    float newMTop = math.max(high, obj.mBox.get_bottom())
                    obj.mBox.set_top(newMTop)
                    obj.uBox.set_bottom(newMTop)
                    fvgMitPctDn := (newMTop - obj.mBox.get_bottom()) / (uTop - obj.mBox.get_bottom()) * 100
                else
                    fullyMit := true
        if fullyMit
            array.remove(fvgList, i)
            if fvgVanish
                obj.uBox.set_bgcolor(col_fvgMit)
                obj.cLine.set_color(color.new(C_NEUT, 85))
            else
                obj.uBox.delete()
                obj.mBox.delete()
                obj.cLine.delete()
        else
            if obj.isBull
                activeFVGup += 1
            else
                activeFVGdn += 1
        i -= 1

// Check if current price is inside an active FVG (for fvg entry preset)
// Always calculated regardless of showFVG toggle so the gate works independently
inBullFVG := false
inBearFVG := false
if array.size(fvgList) > 0
    for i = 0 to array.size(fvgList) - 1
        FVGobj obj = array.get(fvgList, i)
        float lvTop = obj.uBox.get_top()
        float lvBot = obj.uBox.get_bottom()
        if close >= lvBot and close <= lvTop
            if obj.isBull
                inBullFVG := true
            else
                inBearFVG := true

// ══════════════════════════════════════════════════════════════════════════════
// HTF REVERSAL RADAR
// ══════════════════════════════════════════════════════════════════════════════
f_htfRev(tf) =>
    [ema9_htf, ema21_htf, rsi_htf, rsiPrev_htf] = request.security(syminfo.tickerid, tf,
         [ta.ema(close, 9), ta.ema(close, 21), ta.rsi(close, 14), ta.rsi(close, 14)[1]],
         barmerge.gaps_off, barmerge.lookahead_off)
    bool bearEma = ta.crossunder(ema9_htf, ema21_htf)
    bool bullEma = ta.crossover(ema9_htf, ema21_htf)
    bool bearRsi = nz(rsiPrev_htf) > 70 and rsi_htf <= 70
    bool bullRsi = nz(rsiPrev_htf) < 30 and rsi_htf >= 30
    [bearEma or bearRsi, bullEma or bullRsi]

[rev1Bear, rev1Bull] = f_htfRev(revTF1)
[rev2Bear, rev2Bull] = f_htfRev(revTF2)
[rev3Bear, rev3Bull] = f_htfRev(revTF3)

int revBearCount = (rev1Bear ? 1 : 0) + (rev2Bear ? 1 : 0) + (rev3Bear ? 1 : 0)
int revBullCount = (rev1Bull ? 1 : 0) + (rev2Bull ? 1 : 0) + (rev3Bull ? 1 : 0)
bool revWarnBear = showRevRadar and revBearCount >= 2
bool revWarnBull = showRevRadar and revBullCount >= 2

// ══════════════════════════════════════════════════════════════════════════════
// RSI DIVERGENCE
// ══════════════════════════════════════════════════════════════════════════════
float rsiVal      = ta.rsi(close, 14)
float rsiPivH     = ta.pivothigh(rsiVal, divLookL, divLookR)
float rsiPivL     = ta.pivotlow(rsiVal,  divLookL, divLookR)
float pricePivH   = ta.pivothigh(high,   divLookL, divLookR)
float pricePivL   = ta.pivotlow(low,     divLookL, divLookR)

var float prevRsiL = na, var float prevPriceL = na, var int prevLowBar = na
var float prevRsiH = na, var float prevPriceH = na, var int prevHighBar = na

float oldPriceL = prevPriceL, float oldRsiL = prevRsiL, int oldLowBar = prevLowBar
float oldPriceH = prevPriceH, float oldRsiH = prevRsiH, int oldHighBar = prevHighBar

if not na(rsiPivL) and not na(pricePivL)
    prevPriceL := low[divLookR]
    prevRsiL   := rsiVal[divLookR]
    prevLowBar := bar_index - divLookR

if not na(rsiPivH) and not na(pricePivH)
    prevPriceH := high[divLookR]
    prevRsiH   := rsiVal[divLookR]
    prevHighBar := bar_index - divLookR

bool bullDiv = showDiv and not na(rsiPivL) and not na(pricePivL) and not na(oldPriceL) and not na(oldLowBar) and
     (bar_index - divLookR - oldLowBar) <= divRange and (bar_index - divLookR - oldLowBar) > 0 and
     low[divLookR] < oldPriceL and rsiVal[divLookR] > oldRsiL

bool bearDiv = showDiv and not na(rsiPivH) and not na(pricePivH) and not na(oldPriceH) and not na(oldHighBar) and
     (bar_index - divLookR - oldHighBar) <= divRange and (bar_index - divLookR - oldHighBar) > 0 and
     high[divLookR] > oldPriceH and rsiVal[divLookR] < oldRsiH

if showDivLines and bullDiv
    line.new(oldLowBar, oldPriceL, bar_index - divLookR, low[divLookR],
         color=col_divBull, width=divLineWidth)
    label.new(bar_index - divLookR, low[divLookR], "div",
         style=label.style_none, textcolor=col_divBull, size=size.tiny, textalign=text.align_center)

if showDivLines and bearDiv
    line.new(oldHighBar, oldPriceH, bar_index - divLookR, high[divLookR],
         color=col_divBear, width=divLineWidth)
    label.new(bar_index - divLookR, high[divLookR], "div",
         style=label.style_none, textcolor=col_divBear, size=size.tiny, textalign=text.align_center)

// ══════════════════════════════════════════════════════════════════════════════
// TRADE BLOCK -- LOCKED ENTRY MEMORY
// ══════════════════════════════════════════════════════════════════════════════
f_stopPrice(int dir, float entry, float atr, float swLow, float swHigh) =>
    float atrStop  = dir == 1 ? entry - atr * atrStopMult : entry + atr * atrStopMult
    float swingStop = dir == 1 ? swLow : swHigh
    slSource == "ATR"   ? atrStop :
     slSource == "Swing" ? swingStop :
     dir == 1 ? math.min(atrStop, swingStop) : math.max(atrStop, swingStop)

var bool  inTrade       = false
var int   tradeDir      = 0
var float tradeEntry    = 0.0
var float tradeSL       = 0.0
var float origSL        = 0.0
var float trailSL       = 0.0
var bool  hitTP1        = false
var bool  hitTP2        = false
var int   entryBar      = na
var int   tp1Wins       = 0
var int   tp2Wins       = 0
var int   tp3Wins       = 0
var int   totalShots    = 0
var int   totalSLhits   = 0
var int   trailExits    = 0
var float totalPnL      = 0.0
var int   lastTP3bar    = 0
var int   lastSLbar     = 0
var int   failedCount   = 0
var int   consecWins    = 0
var int   consecLoss    = 0

float swLow  = ta.lowest(low,  swingLook)
float swHigh = ta.highest(high, swingLook)

bool entryLong  = longSignal  and not inTrade
bool entryShort = shortSignal and not inTrade

if longSignal or shortSignal
    lastSignalBar := bar_index

var int longShots  = 0
var int longWins   = 0
var int shortShots = 0
var int shortWins  = 0

if entryLong or entryShort
    inTrade    := true
    hitTP1     := false
    hitTP2     := false
    tradeDir   := entryLong ? 1 : -1
    tradeEntry := close
    tradeSL    := f_stopPrice(tradeDir, close, atrVal, swLow, swHigh)
    origSL     := tradeSL
    trailSL    := tradeSL
    entryBar   := bar_index
    totalShots += 1
    if entryLong
        longShots += 1
    else
        shortShots += 1

if inTrade and bar_index > nz(entryBar)
    float riskD = math.abs(tradeEntry - origSL)
    float t1 = tradeEntry + riskD * tp1R * tradeDir
    float t2 = tradeEntry + riskD * tp2R * tradeDir
    float t3 = tradeEntry + riskD * tp3R * tradeDir

    if useTrail and hitTP1 and not hitTP2
        trailSL := tradeDir == 1 ? math.max(trailSL, tradeEntry) : math.min(trailSL, tradeEntry)
    if useTrail and hitTP2
        trailSL := tradeDir == 1 ?
             math.max(trailSL, ma1 - atrVal * trailBuf) :
             math.min(trailSL, ma1 + atrVal * trailBuf)

    float activeSL = useTrail ? trailSL : tradeSL

    if tradeDir == 1
        if high >= t1 and not hitTP1
            tp1Wins += 1
            hitTP1  := true
            if showExitLbl
                label.new(bar_index, high, "tp1", style=label.style_label_down, color=col_exitTP, textcolor=color.new(#0d1117, 0), size=size.tiny)
        if high >= t2 and not hitTP2
            tp2Wins += 1
            hitTP2  := true
            if showExitLbl
                label.new(bar_index, high, "tp2", style=label.style_label_down, color=col_exitTP, textcolor=color.new(#0d1117, 0), size=size.tiny)
        if high >= t3
            tp3Wins    += 1
            inTrade    := false
            consecWins += 1
            consecLoss := 0
            totalPnL   += riskD * tp3R
            lastTP3bar := bar_index
            longWins   += 1
            if showExitLbl
                label.new(bar_index, high, "tp3", style=label.style_label_down, color=color.new(col_exitTP, 0), textcolor=color.new(#0d1117, 0), size=size.tiny)
        else if low <= activeSL
            inTrade := false
            if useTrail and hitTP1
                trailExits += 1
                consecWins += 1
                consecLoss := 0
                longWins   += 1
                if showExitLbl
                    label.new(bar_index, low, "trail", style=label.style_label_up, color=col_exitTRL, textcolor=color.new(#0d1117, 0), size=size.tiny)
            else
                totalSLhits += 1
                consecLoss  += 1
                consecWins  := 0
                totalPnL    -= riskD
                lastSLbar   := bar_index
                if showExitLbl
                    label.new(bar_index, low, "sl", style=label.style_label_up, color=col_exitSL, textcolor=color.new(#0d1117, 0), size=size.tiny)
    else
        if low <= t1 and not hitTP1
            tp1Wins += 1
            hitTP1  := true
            if showExitLbl
                label.new(bar_index, low, "tp1", style=label.style_label_up, color=col_exitTP, textcolor=color.new(#0d1117, 0), size=size.tiny)
        if low <= t2 and not hitTP2
            tp2Wins += 1
            hitTP2  := true
            if showExitLbl
                label.new(bar_index, low, "tp2", style=label.style_label_up, color=col_exitTP, textcolor=color.new(#0d1117, 0), size=size.tiny)
        if low <= t3
            tp3Wins    += 1
            inTrade    := false
            consecWins += 1
            consecLoss := 0
            totalPnL   += riskD * tp3R
            lastTP3bar := bar_index
            shortWins  += 1
            if showExitLbl
                label.new(bar_index, low, "tp3", style=label.style_label_up, color=color.new(col_exitTP, 0), textcolor=color.new(#0d1117, 0), size=size.tiny)
        else if high >= activeSL
            inTrade := false
            if useTrail and hitTP1
                trailExits += 1
                consecWins += 1
                consecLoss := 0
                shortWins  += 1
                if showExitLbl
                    label.new(bar_index, high, "trail", style=label.style_label_down, color=col_exitTRL, textcolor=color.new(#0d1117, 0), size=size.tiny)
            else
                totalSLhits += 1
                consecLoss  += 1
                consecWins  := 0
                totalPnL    -= riskD
                lastSLbar   := bar_index
                if showExitLbl
                    label.new(bar_index, high, "sl", style=label.style_label_down, color=col_exitSL, textcolor=color.new(#0d1117, 0), size=size.tiny)

if failedBreakoutL or failedBreakoutS
    failedCount += 1

float winRate = totalShots > 0 ? (tp1Wins / totalShots) * 100.0 : 0.0
float avgRR   = totalShots > 0 ? totalPnL / math.max(totalSLhits, 1) : 0.0

// ══════════════════════════════════════════════════════════════════════════════
// TRADE BLOCK — Conflux Predator style, own implementation
// Persistent var lines/labels/boxes — updated every barstate.islast
// Shows only when inTrade = true. Labels right of lines with price + R info.
// PnL replaced by win rate / avg RR.
// ══════════════════════════════════════════════════════════════════════════════
float tbEntry  = inTrade ? tradeEntry : na
float tbSL     = inTrade ? (useTrail ? trailSL : origSL) : na
float tbRisk   = inTrade ? math.abs(tbEntry - origSL) : na
float tbTP1    = inTrade ? tbEntry + tbRisk * tp1R * tradeDir : na
float tbTP2    = inTrade ? tbEntry + tbRisk * tp2R * tradeDir : na
float tbTP3    = inTrade ? tbEntry + tbRisk * tp3R * tradeDir : na

var line  tb_l_en   = line.new(na, na, na, na, color=na)
var line  tb_l_sl   = line.new(na, na, na, na, color=na)
var line  tb_l_tp1  = line.new(na, na, na, na, color=na)
var line  tb_l_tp2  = line.new(na, na, na, na, color=na)
var line  tb_l_tp3  = line.new(na, na, na, na, color=na)
var label tb_lb_en    = label.new(na, na, "", color=#00000000, style=label.style_label_left,   size=size.small)
var label tb_lb_sl    = label.new(na, na, "", color=#00000000, style=label.style_label_left,   size=size.small)
var label tb_lb_tp1   = label.new(na, na, "", color=#00000000, style=label.style_label_left,   size=size.small)
var label tb_lb_tp2   = label.new(na, na, "", color=#00000000, style=label.style_label_left,   size=size.small)
var label tb_lb_tp3   = label.new(na, na, "", color=#00000000, style=label.style_label_left,   size=size.small)
var label tb_lb_phase = label.new(na, na, "", color=#00000000, style=label.style_label_center, size=size.small)
var label tb_lb_risk  = label.new(na, na, "", color=#00000000, style=label.style_label_center, size=size.small)
var label tb_lb_rr    = label.new(na, na, "", color=#00000000, style=label.style_label_center, size=size.small)
var box   tb_bx_risk = box.new(na, na, na, na, bgcolor=na, border_color=na)
var box   tb_bx_tp1  = box.new(na, na, na, na, bgcolor=na, border_color=na)
var box   tb_bx_tp2  = box.new(na, na, na, na, bgcolor=na, border_color=na)
var box   tb_bx_tp3  = box.new(na, na, na, na, bgcolor=na, border_color=na)

if showTrade and barstate.islast
    int xStart = nz(entryBar, bar_index)
    int xEnd   = bar_index + boxExtend
    int xMid   = bar_index + math.round(boxExtend / 2)
    int xLbl   = xEnd + 2

    if inTrade and not na(tbEntry)
        color dirCol = tradeDir == 1 ? C_BULL : C_BEAR
        color slCol  = C_BEAR
        string dirTxt = tradeDir == 1 ? "LONG" : "SHORT"

        // Phase label above TP3
        float phaseLvl = tradeDir == 1 ? tbTP3 + atrVal * 0.3 : tbTP3 - atrVal * 0.3
        tb_lb_phase.set_xy(xMid, phaseLvl)
        tb_lb_phase.set_text("TBP -- " + dirTxt + " -- " + preset)
        tb_lb_phase.set_textcolor(color.new(dirCol, 0))

        // Lines
        tb_l_en.set_xy1(xStart, tbEntry),  tb_l_en.set_xy2(xEnd, tbEntry)
        tb_l_sl.set_xy1(xStart, tbSL),     tb_l_sl.set_xy2(xEnd, tbSL)
        tb_l_tp1.set_xy1(xStart, tbTP1),   tb_l_tp1.set_xy2(xEnd, tbTP1)
        tb_l_tp2.set_xy1(xStart, tbTP2),   tb_l_tp2.set_xy2(xEnd, tbTP2)
        tb_l_tp3.set_xy1(xStart, tbTP3),   tb_l_tp3.set_xy2(xEnd, tbTP3)
        tb_l_en.set_color(color.new(C_GOLD, 20))
        tb_l_sl.set_color(color.new(slCol, 20))
        tb_l_tp1.set_color(hitTP1 ? color.new(dirCol, 0) : color.new(dirCol, 50))
        tb_l_tp2.set_color(hitTP2 ? color.new(dirCol, 0) : color.new(dirCol, 35))
        tb_l_tp3.set_color(color.new(dirCol, 15))

        // Boxes
        float riskTop = tradeDir == 1 ? tbEntry : tbSL
        float riskBot = tradeDir == 1 ? tbSL    : tbEntry
        tb_bx_risk.set_lefttop(xStart, riskTop),   tb_bx_risk.set_rightbottom(xEnd, riskBot)
        tb_bx_risk.set_bgcolor(color.new(C_BEAR, 88))
        tb_bx_risk.set_border_color(color.new(C_BEAR, 60))
        if tradeDir == 1
            tb_bx_tp1.set_lefttop(xStart, tbTP1), tb_bx_tp1.set_rightbottom(xEnd, tbEntry)
            tb_bx_tp2.set_lefttop(xStart, tbTP2), tb_bx_tp2.set_rightbottom(xEnd, tbTP1)
            tb_bx_tp3.set_lefttop(xStart, tbTP3), tb_bx_tp3.set_rightbottom(xEnd, tbTP2)
        else
            tb_bx_tp1.set_lefttop(xStart, tbEntry), tb_bx_tp1.set_rightbottom(xEnd, tbTP1)
            tb_bx_tp2.set_lefttop(xStart, tbTP1),   tb_bx_tp2.set_rightbottom(xEnd, tbTP2)
            tb_bx_tp3.set_lefttop(xStart, tbTP2),   tb_bx_tp3.set_rightbottom(xEnd, tbTP3)
        tb_bx_tp1.set_bgcolor(color.new(dirCol, 92)), tb_bx_tp1.set_border_color(color.new(dirCol, 60))
        tb_bx_tp2.set_bgcolor(color.new(dirCol, 90)), tb_bx_tp2.set_border_color(color.new(dirCol, 50))
        tb_bx_tp3.set_bgcolor(color.new(dirCol, 88)), tb_bx_tp3.set_border_color(color.new(dirCol, 40))

        // Labels right of lines
        string tp1Chk = hitTP1 ? " --" : ""
        string tp2Chk = hitTP2 ? " --" : ""
        string wrTxt  = totalShots > 0 ? str.tostring(math.round(winRate, 1)) + "%" : "--"
        float  rrDisp = tbRisk > 0 ? math.abs(tbTP3 - tbEntry) / tbRisk : tp3R
        tb_lb_en.set_xy(xLbl, tbEntry)
        tb_lb_en.set_text("ENTRY " + str.tostring(tbEntry, format.mintick) + " -- " + dirTxt)
        tb_lb_en.set_textcolor(color.new(C_GOLD, 0))
        tb_lb_sl.set_xy(xLbl, tbSL)
        tb_lb_sl.set_text("STOP " + str.tostring(tbSL, format.mintick))
        tb_lb_sl.set_textcolor(color.new(slCol, 0))
        tb_lb_tp1.set_xy(xLbl, tbTP1)
        tb_lb_tp1.set_text("TP1 " + str.tostring(tp1R, "#.#") + "R -- " + str.tostring(tbTP1, format.mintick) + tp1Chk)
        tb_lb_tp1.set_textcolor(hitTP1 ? color.new(dirCol, 0) : color.new(dirCol, 40))
        tb_lb_tp2.set_xy(xLbl, tbTP2)
        tb_lb_tp2.set_text("TP2 " + str.tostring(tp2R, "#.#") + "R -- " + str.tostring(tbTP2, format.mintick) + tp2Chk)
        tb_lb_tp2.set_textcolor(hitTP2 ? color.new(dirCol, 0) : color.new(dirCol, 25))
        tb_lb_tp3.set_xy(xLbl, tbTP3)
        tb_lb_tp3.set_text("TP3 " + str.tostring(tp3R, "#.#") + "R -- " + str.tostring(tbTP3, format.mintick))
        tb_lb_tp3.set_textcolor(color.new(dirCol, 0))

        // Risk zone center label
        tb_lb_risk.set_xy(xMid, (riskTop + riskBot) / 2)
        tb_lb_risk.set_text("RISK ZONE")
        tb_lb_risk.set_textcolor(color.new(C_BEAR, 10))

        // R:R + winrate center label
        tb_lb_rr.set_xy(xMid, (tbEntry + tbTP3) / 2)
        tb_lb_rr.set_text("R:R 1:" + str.tostring(rrDisp, "#.#") + "\nWR " + wrTxt)
        tb_lb_rr.set_textcolor(color.new(dirCol, 10))

    else
        // No active trade — hide everything
        tb_l_en.set_color(color.new(C_WHITE, 100)),  tb_l_sl.set_color(color.new(C_WHITE, 100))
        tb_l_tp1.set_color(color.new(C_WHITE, 100)), tb_l_tp2.set_color(color.new(C_WHITE, 100))
        tb_l_tp3.set_color(color.new(C_WHITE, 100))
        tb_bx_risk.set_bgcolor(color.new(C_WHITE, 100)), tb_bx_risk.set_border_color(color.new(C_WHITE, 100))
        tb_bx_tp1.set_bgcolor(color.new(C_WHITE, 100)),  tb_bx_tp1.set_border_color(color.new(C_WHITE, 100))
        tb_bx_tp2.set_bgcolor(color.new(C_WHITE, 100)),  tb_bx_tp2.set_border_color(color.new(C_WHITE, 100))
        tb_bx_tp3.set_bgcolor(color.new(C_WHITE, 100)),  tb_bx_tp3.set_border_color(color.new(C_WHITE, 100))
        tb_lb_en.set_text(""),   tb_lb_sl.set_text("")
        tb_lb_tp1.set_text(""),  tb_lb_tp2.set_text(""),  tb_lb_tp3.set_text("")
        tb_lb_phase.set_text(""), tb_lb_risk.set_text(""), tb_lb_rr.set_text("")

// ══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════
// SILK RIBBON PLOTS -- trend-based coloring
// bull (ma1 > ma7) = green, bear (ma1 < ma7) = red, flat = grey
// transparency controlled by ribbonAlpha input
// ══════════════════════════════════════════════════════════════════════════════
color ribbonBase = trendBull ? C_BULL : trendBear ? C_BEAR : C_NEUT

int aStrand = math.min(ribbonAlpha, 90)
int aFill1  = math.min(ribbonAlpha + 15, 95)
int aFill2  = math.min(ribbonAlpha + 25, 95)
int aFill3  = math.min(ribbonAlpha + 30, 95)

p_ma1 = plot(showRibbon ? ma1 : na, "Ribbon 1", color=color.new(ribbonBase, aStrand), linewidth=ribbonWidth)
p_ma2 = plot(showRibbon ? ma2 : na, "Ribbon 2", color=color.new(ribbonBase, aStrand), linewidth=1, display=display.none)
p_ma3 = plot(showRibbon ? ma3 : na, "Ribbon 3", color=color.new(ribbonBase, aStrand), linewidth=1, display=display.none)
p_ma4 = plot(showRibbon ? ma4 : na, "Ribbon 4", color=color.new(ribbonBase, aStrand), linewidth=1, display=display.none)
p_ma5 = plot(showRibbon ? ma5 : na, "Ribbon 5", color=color.new(ribbonBase, aStrand), linewidth=1, display=display.none)
p_ma6 = plot(showRibbon ? ma6 : na, "Ribbon 6", color=color.new(ribbonBase, aStrand), linewidth=1, display=display.none)
p_ma7 = plot(showRibbon ? ma7 : na, "Ribbon 7", color=color.new(ribbonBase, aStrand), linewidth=1)

fill(p_ma1, p_ma2, color=color.new(ribbonBase, aFill1))
fill(p_ma2, p_ma3, color=color.new(ribbonBase, aFill2))
fill(p_ma3, p_ma4, color=color.new(ribbonBase, aFill2))
fill(p_ma4, p_ma5, color=color.new(ribbonBase, aFill2))
fill(p_ma5, p_ma6, color=color.new(ribbonBase, aFill3))
fill(p_ma6, p_ma7, color=color.new(ribbonBase, aFill3))

// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL MARKERS -- all plotshape, no labels
// ══════════════════════════════════════════════════════════════════════════════
// EMA cross signals
plotshape(showCross and crossBull, "Cross bull", shape.circle, location.belowbar, col_bullCross, size=size.tiny)
plotshape(showCross and crossBear, "Cross bear", shape.circle, location.abovebar, col_bearCross, size=size.tiny)

// Entry signals -- triangle tiny
plotshape(longSignal,  "Long signal",  shape.triangleup,   location.belowbar, C_BULL, size=size.tiny)
plotshape(shortSignal, "Short signal", shape.triangledown,  location.abovebar, C_BEAR, size=size.tiny)

// Failed breakout -- x cross tiny
plotshape(failedBreakoutL, "Failed breakout L", shape.xcross, location.abovebar, color.new(C_GOLD, 0), size=size.tiny)
plotshape(failedBreakoutS, "Failed breakout S", shape.xcross, location.belowbar, color.new(C_GOLD, 0), size=size.tiny)

// HTF reversal warning -- small diamond
plotshape(revWarnBear, "HTF rev bear", shape.diamond, location.abovebar, color.new(C_BEAR, 20), size=size.tiny)
plotshape(revWarnBull, "HTF rev bull", shape.diamond, location.belowbar, color.new(C_BULL, 20), size=size.tiny)

// Divergence markers -- text label only, no dot

// ══════════════════════════════════════════════════════════════════════════════
// HTF GHOST CANDLES
// Pulls closed HTF bars + live bar via request.security.
// Projects them as box (body) + line (wick) to the right of the chart.
// No time labels. No TF labels. Pure price structure.
// ══════════════════════════════════════════════════════════════════════════════

// Pull HTF OHLC -- indices 0..ghostCount are closed bars, index -1 is live
f_ghostOHLC(idx) =>
    request.security(syminfo.tickerid, ghostTF,
         [open[idx], high[idx], low[idx], close[idx]],
         barmerge.gaps_off, barmerge.lookahead_off)

[g0o, g0h, g0l, g0c] = f_ghostOHLC(0)   // live (unfinished)
[g1o, g1h, g1l, g1c] = f_ghostOHLC(1)   // last closed
[g2o, g2h, g2l, g2c] = f_ghostOHLC(2)
[g3o, g3h, g3l, g3c] = f_ghostOHLC(3)
[g4o, g4h, g4l, g4c] = f_ghostOHLC(4)
[g5o, g5h, g5l, g5c] = f_ghostOHLC(5)
[g6o, g6h, g6l, g6c] = f_ghostOHLC(6)
[g7o, g7h, g7l, g7c] = f_ghostOHLC(7)
[g8o, g8h, g8l, g8c] = f_ghostOHLC(8)

// Storage arrays -- rebuilt every bar at barstate.islast
var box[]   ghostBodies = array.new<box>()
var line[]  ghostWicks  = array.new<line>()
var label[] ghostLabels = array.new<label>()

if showGhost and barstate.islast
    // Clear previous drawings
    for b in ghostBodies
        b.delete()
    for l in ghostWicks
        l.delete()
    for lb in ghostLabels
        lb.delete()
    array.clear(ghostBodies)
    array.clear(ghostWicks)
    array.clear(ghostLabels)

    // Pack closed candle data into arrays (oldest first for left-to-right draw)
    float[] oArr = array.from(g8o, g7o, g6o, g5o, g4o, g3o, g2o, g1o)
    float[] hArr = array.from(g8h, g7h, g6h, g5h, g4h, g3h, g2h, g1h)
    float[] lArr = array.from(g8l, g7l, g6l, g5l, g4l, g3l, g2l, g1l)
    float[] cArr = array.from(g8c, g7c, g6c, g5c, g4c, g3c, g2c, g1c)

    // Draw closed candles (oldest → newest, left → right)
    int startIdx = math.max(0, 8 - ghostCount)
    for i = startIdx to 7
        int slot    = i - startIdx                          // 0-based slot position
        int xLeft   = last_bar_index + ghostOffset + slot * (ghostWidth + ghostGap)
        int xRight  = xLeft + ghostWidth
        int xMid    = xLeft + ghostWidth / 2

        float o = array.get(oArr, i)
        float h = array.get(hArr, i)
        float l = array.get(lArr, i)
        float c = array.get(cArr, i)

        if not na(o) and not na(c)
            bool isBull  = c >= o
            color bodyC  = isBull ? col_ghostBull : col_ghostBear
            float bodyTop = math.max(o, c)
            float bodyBot = math.min(o, c)

            // Body
            array.push(ghostBodies, box.new(xLeft, bodyTop, xRight, bodyBot,
                 bgcolor=bodyC, border_color=color.new(isBull ? #00cc88 : #ff4444, 30), border_width=1))

            // Wick
            array.push(ghostWicks, line.new(xMid, h, xMid, l,
                 color=col_ghostWick, width=1))

            // OHLC labels
            if showGhostOHLC
                color lblC = isBull ? color.new(#00cc88, 0) : color.new(#ff4444, 0)
                array.push(ghostLabels, label.new(xRight + 1, h,
                     str.tostring(h, format.mintick),
                     style=label.style_none, textcolor=color.new(#8b949e, 0), size=size.tiny))
                array.push(ghostLabels, label.new(xRight + 1, l,
                     str.tostring(l, format.mintick),
                     style=label.style_none, textcolor=color.new(#8b949e, 0), size=size.tiny))
                array.push(ghostLabels, label.new(xRight + 1, c,
                     str.tostring(c, format.mintick),
                     style=label.style_none, textcolor=lblC, size=size.tiny))

    // Draw live (unfinished) candle -- rightmost, gold tint
    int liveSlot  = ghostCount
    int lxLeft    = last_bar_index + ghostOffset + liveSlot * (ghostWidth + ghostGap)
    int lxRight   = lxLeft + ghostWidth
    int lxMid     = lxLeft + ghostWidth / 2

    if not na(g0o) and not na(g0c)
        bool liveIsBull = g0c >= g0o
        color liveBody  = liveIsBull ? color.new(#00cc88, 55) : color.new(#ff4444, 55)
        float liveTop   = math.max(g0o, g0c)
        float liveBot   = math.min(g0o, g0c)

        array.push(ghostBodies, box.new(lxLeft, liveTop, lxRight, liveBot,
             bgcolor=col_ghostLive, border_color=color.new(#f5c518, 20), border_width=1))
        array.push(ghostWicks, line.new(lxMid, g0h, lxMid, g0l,
             color=color.new(#f5c518, 40), width=1))

        if showGhostOHLC
            array.push(ghostLabels, label.new(lxRight + 1, g0h,
                 str.tostring(g0h, format.mintick),
                 style=label.style_none, textcolor=color.new(#f5c518, 20), size=size.tiny))
            array.push(ghostLabels, label.new(lxRight + 1, g0l,
                 str.tostring(g0l, format.mintick),
                 style=label.style_none, textcolor=color.new(#f5c518, 20), size=size.tiny))
            array.push(ghostLabels, label.new(lxRight + 1, g0c,
                 str.tostring(g0c, format.mintick),
                 style=label.style_none, textcolor=color.new(#f5c518, 0), size=size.tiny))

// DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(
     dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right,
     2, 23,
     bgcolor=color.new(C_DASH_BG, 10),
     border_color=color.new(C_BORDER, 20),
     border_width=1,
     frame_color=color.new(C_BORDER, 40),
     frame_width=1)

if showDash and barstate.islast
    string txtSz = dashSz == "Tiny" ? size.tiny : dashSz == "Small" ? size.small : size.normal

    color cM  = color.new(C_MUTED, 0)
    color cW  = color.new(C_WHITE, 0)
    color cP  = color.new(C_PANEL, 0)
    color cBl = color.new(C_BULL, 0)
    color cBr = color.new(C_BEAR, 0)
    color cG  = color.new(C_GOLD, 0)

    // Header
    table.cell(dash, 0, 0, "THE BOY PLUNGER", text_color=cW, text_size=txtSz, bgcolor=color.new(C_PANEL, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0",            text_color=cM, text_size=txtSz, bgcolor=color.new(C_PANEL, 0), text_halign=text.align_right)

    // Environment
    string trendLbl = trendBull ? "bull ^" : trendBear ? "bear v" : "neutral"
    color  trendClr = trendBull ? cBl : trendBear ? cBr : cM
    table.cell(dash, 0, 1, "htf",         text_color=cM,       text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 1, htfTF,         text_color=cW,       text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 2, "macro trend", text_color=cM,       text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 2, trendLbl,      text_color=trendClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 3, "ribbon",      text_color=cM,       text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 3, effectiveMAtype,        text_color=cW,       text_size=txtSz, bgcolor=cP, text_halign=text.align_right)

    // Level state
    string levelLbl = levelConfirmedB ? "confirmed ^" : levelConfirmedS ? "confirmed v" : levelWatching ? "watching" : "scanning"
    color  levelClr = levelConfirmedB ? cBl : levelConfirmedS ? cBr : levelWatching ? cG : cM
    string nearLbl  = not na(nearestHTF) ? str.tostring(nearestHTF, format.mintick) : "--"
    table.cell(dash, 0, 4, "active level", text_color=cM,       text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 4, nearLbl,        text_color=cW,       text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 5, "level state",  text_color=cM,       text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 5, levelLbl,       text_color=levelClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)

    // Volume
    string volLbl  = volSpike ? "spike " + str.tostring(math.round(volRatio, 1)) + "x" : str.tostring(math.round(volRatio, 1)) + "x avg"
    color  volClr  = volSpike ? cG : cM
    string bodyLbl = str.tostring(math.round(bodyRatio * 100)) + "%"
    color  bodyClr = bodyConv ? cBl : cM
    table.cell(dash, 0, 6, "volume ratio", text_color=cM,      text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 6, volLbl,         text_color=volClr,  text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 7, "body ratio",   text_color=cM,      text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 7, bodyLbl,        text_color=bodyClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)

    // FVG
    string fvgLbl = str.tostring(activeFVGup) + "^ " + str.tostring(activeFVGdn) + "v"
    color  fvgClr = (activeFVGup + activeFVGdn) > 0 ? cW : cM
    table.cell(dash, 0, 8, "fvg active", text_color=cM,     text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 8, fvgLbl,       text_color=fvgClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)

    // Signal info
    string divLbl  = bullDiv ? "bull div ^" : bearDiv ? "bear div v" : "--"
    color  divClr  = bullDiv ? col_divBull : bearDiv ? col_divBear : cM
    string revLbl  = revWarnBear ? "bear v (" + str.tostring(revBearCount) + " tf)" : revWarnBull ? "bull ^ (" + str.tostring(revBullCount) + " tf)" : "-- clear"
    color  revClr  = revWarnBear ? cBr : revWarnBull ? cBl : cM
    string gateLbl = preset == "fvg entry" ? "fvg entry" : preset
    table.cell(dash, 0, 9,  "divergence",  text_color=cM,     text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 9,  divLbl,        text_color=divClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 10, "htf radar",   text_color=cM,     text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 10, revLbl,        text_color=revClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 11, "signal gate", text_color=cM,     text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 11, gateLbl,       text_color=cW,     text_size=txtSz, bgcolor=cP, text_halign=text.align_right)

    // Trade performance
    string lastSigLbl = inTrade ? (tradeDir == 1 ? "long ^ - active" : "short v - active") : (longSignal ? "long ^" : shortSignal ? "short v" : "--")
    color  lastSigClr = inTrade ? (tradeDir == 1 ? cBl : cBr) : cM
    string failLbl = str.tostring(failedCount)
    color  failClr = failedCount > 0 ? cBr : cM

    // Three separate TP rates
    float tp1Rate = totalShots > 0 ? (tp1Wins / totalShots) * 100.0 : 0.0
    float tp2Rate = totalShots > 0 ? (tp2Wins / totalShots) * 100.0 : 0.0
    float tp3Rate = totalShots > 0 ? (tp3Wins / totalShots) * 100.0 : 0.0
    string tp1RateLbl = totalShots > 0 ? str.tostring(math.round(tp1Rate, 1)) + "%" : "--"
    string tp2RateLbl = totalShots > 0 ? str.tostring(math.round(tp2Rate, 1)) + "%" : "--"
    string tp3RateLbl = totalShots > 0 ? str.tostring(math.round(tp3Rate, 1)) + "%" : "--"
    color  tp1RateClr = tp1Rate >= 50 ? cBl : cBr
    color  tp2RateClr = tp2Rate >= 50 ? cBl : cBr
    color  tp3RateClr = tp3Rate >= 50 ? cBl : cBr

    // TP progress dots — show current trade position
    string dot1 = inTrade and hitTP1 ? "▲" : "O"
    string dot2 = inTrade and hitTP2 ? "▲" : "O"
    string dot3 = (not inTrade and tp3Wins > 0 and lastTP3bar == bar_index) ? "▲" : "O"
    color  dot1c = inTrade and hitTP1 ? color.new(#4caf50, 0) : color.new(C_NEUT, 40)
    color  dot2c = inTrade and hitTP2 ? color.new(#66bb6a, 0) : color.new(C_NEUT, 40)
    color  dot3c = color.new(C_NEUT, 40)
    string progressLbl = dot1 + "  " + dot2 + "  " + dot3

    table.cell(dash, 0, 12, "last signal",      text_color=cM,         text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 12, lastSigLbl,         text_color=lastSigClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 13, "tp progress",      text_color=cM,         text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 13, progressLbl,        text_color=inTrade and hitTP2 ? color.new(#66bb6a, 0) : inTrade and hitTP1 ? color.new(#4caf50, 0) : color.new(C_NEUT, 40), text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 14, "tp1 rate",         text_color=cM,         text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 14, tp1RateLbl,         text_color=tp1RateClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 15, "tp2 rate",         text_color=cM,         text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 15, tp2RateLbl,         text_color=tp2RateClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 16, "tp3 rate",         text_color=cM,         text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 16, tp3RateLbl,         text_color=tp3RateClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 17, "failed breakouts", text_color=cM,         text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 17, failLbl,            text_color=failClr,    text_size=txtSz, bgcolor=cP, text_halign=text.align_right)

    // Long / short split winrate
    float longWR  = longShots  > 0 ? (longWins  / longShots)  * 100 : 0.0
    float shortWR = shortShots > 0 ? (shortWins / shortShots) * 100 : 0.0
    string lwLbl  = longShots  > 0 ? str.tostring(math.round(longWR,  1)) + "%" : "--"
    string swLbl  = shortShots > 0 ? str.tostring(math.round(shortWR, 1)) + "%" : "--"
    color  lwClr  = longWR  >= 50 ? cBl : cBr
    color  swClr  = shortWR >= 50 ? cBl : cBr
    table.cell(dash, 0, 18, "long win rate",  text_color=cM,    text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 18, lwLbl,            text_color=lwClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)
    table.cell(dash, 0, 19, "short win rate", text_color=cM,    text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 19, swLbl,            text_color=swClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)

    // Cooldown status
    int barsSinceSig  = na(lastSignalBar) ? effectiveCooldown : bar_index - lastSignalBar
    string cdLbl      = not useCooldown ? "off" : cooldownOK ? "ready" : str.tostring(effectiveCooldown - barsSinceSig) + " bars"
    color  cdClr      = not useCooldown ? cM : cooldownOK ? cBl : cG
    table.cell(dash, 0, 20, "cooldown",  text_color=cM,    text_size=txtSz, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 20, cdLbl,       text_color=cdClr, text_size=txtSz, bgcolor=cP, text_halign=text.align_right)

    // Footer
    table.cell(dash, 0, 21, "anonycryptous", text_color=color.new(#bb86fc, 0), text_size=txtSz, bgcolor=color.new(#0d1117, 0), text_halign=text.align_left)
    table.cell(dash, 1, 21, "TBP v1.0",           text_color=cM,                    text_size=txtSz, bgcolor=color.new(#0d1117, 0), text_halign=text.align_right)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(longSignal,                    "TBP -- long signal",          "The Boy Plunger: long signal confirmed")
alertcondition(shortSignal,                   "TBP -- short signal",         "The Boy Plunger: short signal confirmed")
alertcondition(failedBreakoutL or failedBreakoutS, "TBP -- failed breakout", "The Boy Plunger: failed breakout detected")
alertcondition(revWarnBear,                   "TBP -- HTF bear warning",     "The Boy Plunger: 2+ HTF timeframes showing bearish reversal")
alertcondition(revWarnBull,                   "TBP -- HTF bull warning",     "The Boy Plunger: 2+ HTF timeframes showing bullish reversal")
alertcondition(bullDiv,                       "TBP -- bull divergence",      "The Boy Plunger: bullish RSI divergence detected")
alertcondition(bearDiv,                       "TBP -- bear divergence",      "The Boy Plunger: bearish RSI divergence detected")
alertcondition(levelWatching,                 "TBP -- level watching",       "The Boy Plunger: price approaching key HTF level")
````
