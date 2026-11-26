# SHK All-In-One | 3MA - VWAP - Liq - SMC - Marco - ZZ

- url: https://www.tradingview.com/script/7E7EOg2k-SHK-All-In-One-3MA-VWAP-Liq-SMC-Marco-ZZ/
- type: indicator
- pine_id: PUB;263ea98688a249acacf66c951e4b8f9b
- version: 1.0

## Description

╔══════════════════════════════════════════════════════════════════╗
║     SHK All-In-One [3MA · VWAP · Liq · SMC · Marco · ZZ]      ║
║                    by SHK  ·  Pine Script v6                    ║
╚══════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏅 CREDITS & ORIGINAL AUTHORS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This script is a combined, extended and restructured version of
several outstanding open-source indicators. Full credit belongs
to the original authors listed below. I have only merged,
organised and added connecting logic.

  ① Smart Money Concepts (SMC)
     → Original: LuxAlgo — "SMC Lite" (open-source, TradingView)
     → Includes: BOS, CHoCH, Order Blocks, FVG, EQH/EQL,
                 MTF Levels, Premium/Discount Zones, STH/STL

  ② Liquidity Swings (BSL / SSL)
     → Original: LuxAlgo — "Liquidity Levels" (open-source)
     → Includes: Buy-Side & Sell-Side Liquidity zones,
                 sweep detection, volume/count filtering

  ③ Marco Polo Top Detective
     → Original: Marco Polo — community TradingView adaptation
     → Includes: Custom pivot top/bottom detection,
                 BBands 3-bar reversal confirmation

  ④ ZigZag Engine (Swing + Internal)
     → Original: Classic TradingView community ZigZag
                 (multiple open-source contributors)
     → Includes: Swing ZigZag with HH/HL/LH/LL labels,
                 Internal ZigZag with separate settings

  ⑤ UT Bot Filter (inside Signal MA)
     → Original: QuantNomad — "UT Bot Alert" (open-source)
     → Used as one of three Signal MA colour filters

  ⑥ Supertrend Filter (inside Signal MA)
     → Built-in ta.supertrend() — Pine Script standard library
     → Used as one of three Signal MA colour filters

  ⑦ 3 MA + Signal MA System + VWAP
     → Original work by SHK
     → Includes: 3 independent MAs, a colour-coded Signal MA
                 combining HA + Supertrend + UT Bot filters,
                 and an anchored VWAP

Combined, unified and extended by SHK.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 WHAT IS THIS INDICATOR?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SHK All-In-One brings together five of the most powerful
open-source market analysis tools into a single, clean,
modular indicator. Instead of adding 5 separate scripts to
your chart and dealing with clutter and conflicts, everything
lives in one place.

Each of the five modules can be INDEPENDENTLY TURNED ON OR OFF
using the Master Toggles at the top of the settings. Use only
what you need — run all five at once or pick just one.

Designed primarily for Indian markets (Nifty, BankNifty,
Sensex, MCX commodities) but works on any symbol and timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
① 3 MA + VWAP MODULE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Three fully independent Moving Averages, each with its own
type, length and colour setting.

SUPPORTED MA TYPES:
  • EMA  — Exponential Moving Average
  • SMA  — Simple Moving Average
  • WMA  — Weighted Moving Average
  • HMA  — Hull Moving Average (smooth, low lag)
  • TEMA — Triple EMA (very low lag)
  • DEMA — Double EMA (reduced lag)
  • ZLEMA — Zero-Lag EMA (lag corrected using looback)

All three MAs default to EMA 9 / 21 / 50 — the classic
short, medium and long-term trend framework.

SIGNAL MA:
A fourth moving average acts as a dynamic trend signal line.
It changes colour based on THREE combined market filters:

  Filter 1 — Heiken Ashi:
    Reads the Heiken Ashi close vs open to determine if price
    action is in a bullish or bearish HA candle. Smooths out
    noise from regular candles.

  Filter 2 — Supertrend:
    Uses ta.supertrend() with configurable ATR length and
    factor. Adds a trend-following layer to the signal.

  Filter 3 — UT Bot:
    QuantNomad's UT Bot trailing stop logic using ATR.
    Identifies momentum direction based on a key value
    multiplier and ATR period.

  Scoring system:
    Each filter votes +1 (bullish) or -1 (bearish).
    Total score > 0  → Signal MA turns GREEN (bullish)
    Total score < 0  → Signal MA turns RED (bearish)
    Total score = 0  → Signal MA turns GREY (neutral)

You can enable or disable any of the three filters
individually. Running all three gives the most robust signal.

MA CROSSOVER LABELS:
  Whenever MA1 crosses MA2, or MA2 crosses MA3, a small
  triangle label appears on the chart automatically.
  Upward triangle = bullish cross (below bar)
  Downward triangle = bearish cross (above bar)
  The label shows the two MA lengths that crossed.

VWAP (Volume Weighted Average Price):
  A fully anchored VWAP is included with anchor options:
    Session / Week / Month / Quarter / Year
  VWAP is calculated from scratch using cumulative
  TPV (typical price × volume) for accuracy.
  Displayed as a bold coloured line (default yellow).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
② LIQUIDITY SWINGS MODULE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Identifies areas where resting liquidity (stop losses and
pending orders) is likely clustered above swing highs and
below swing lows. Based on LuxAlgo's Liquidity Levels logic.

HOW IT WORKS:
  Uses ta.pivothigh() and ta.pivotlow() with a configurable
  lookback length to detect swing pivot points.

  For each detected swing high → marks a BSL zone
  (Buy-Side Liquidity — stop losses of shorts clustered above)

  For each detected swing low → marks a SSL zone
  (Sell-Side Liquidity — stop losses of longs clustered below)

  A horizontal line is drawn at the pivot level and extends
  to the right until price sweeps through it.

  When price closes beyond the level:
    • Line turns DASHED
    • Label updates to "✓ BSL Swept" or "✓ SSL Swept"
    • Zone box fades

SWING AREA MODES:
  Wick Extremity — Zone top/bottom uses the wick extreme
    vs the candle body edge (tighter zone)
  Full Range     — Zone spans full candle high to low

FILTERING:
  Filter by Count  — minimum number of bars that touched
    the zone (liquidity density)
  Filter by Volume — minimum cumulative volume inside
    the zone (institutional interest)

LABELS:
  Each level shows "▲ Buy Side Liquidity" or
  "▼ Sell Side Liquidity" with the cumulative volume.
  Label size and BSL/SSL label size are configurable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
③ SMART MONEY CONCEPTS (SMC) MODULE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The most comprehensive module. Based on LuxAlgo's SMC Lite
open-source indicator, adapted and integrated for this script.

─── STRUCTURE ───────────────────────────────────────────────

SWING STRUCTURE:
  Identifies the major market structure by tracking swing
  highs and swing lows over a configurable lookback length.

  BOS (Break of Structure):
    Price closes beyond the last swing high/low in the
    SAME direction as the current trend. Confirms trend
    continuation.

  CHoCH (Change of Character):
    Price closes beyond the last swing high/low in the
    OPPOSITE direction of the current trend. First signal
    of a potential trend reversal.

  A line is drawn from the broken level to the current bar,
  labelled BOS or CHoCH. Bullish = green, Bearish = red.

INTERNAL STRUCTURE:
  Same BOS/CHoCH logic applied to a shorter lookback (5 bars)
  to catch intrabar / internal structure shifts.
  Internal structure lines are dashed to distinguish from
  swing structure.

  Confluence Filter option: when enabled, only shows
  internal structure that aligns with candle body direction
  (filters out weak signals).

SWING POINTS:
  Optional labels showing HH (Higher High), HL (Higher Low),
  LH (Lower High), LL (Lower Low) at each pivot.

STRONG / WEAK HIGH-LOW LABELS:
  STH (Short-Term High) and STL (Short-Term Low) mark the
  most recent swing extreme. When both occur at the same
  bar, shows a combined STH/STL label.

─── ORDER BLOCKS ────────────────────────────────────────────

Order Blocks are the last up/down candle before a BOS or
CHoCH. They represent areas where institutional orders
were placed and price is likely to react on a return visit.

INTERNAL ORDER BLOCKS:
  Derived from internal structure BOS/CHoCH events.
  Show the 5 most recent (configurable up to 20).

SWING ORDER BLOCKS:
  Derived from swing structure BOS/CHoCH events.
  Disabled by default (toggle on if needed).

OB FILTER:
  ATR Filter — removes OBs from high-volatility candles
    (candle range ≥ 2× ATR is excluded as noise)
  Cumulative Mean Range Filter — uses average range
    instead of ATR as the volatility measure

OB MITIGATION:
  Close — OB is mitigated when price CLOSES inside it
  High/Low — OB is mitigated when price WICKS into it

Each OB is drawn as a coloured box that extends to the
right until price mitigates it.

─── FAIR VALUE GAPS (FVG) ───────────────────────────────────

A Fair Value Gap is a 3-candle imbalance where:
  Bullish FVG: candle 3 low > candle 1 high (gap up)
  Bearish FVG: candle 3 high < candle 1 low (gap down)

FVGs are drawn as semi-transparent boxes.
Auto Threshold option filters out micro-gaps below
0.5× ATR (reduces noise).

Optional multi-timeframe FVG via timeframe input —
you can display FVGs from a higher timeframe on your
current chart.

─── EQUAL HIGHS / EQUAL LOWS (EQH/EQL) ─────────────────────

Detects when two consecutive swing highs or lows are within
a configurable ATR threshold of each other, indicating
clustered liquidity at that level.

Drawn as a dotted line between the two equal levels,
labelled EQH or EQL.

─── MULTI-TIMEFRAME HIGHS & LOWS ────────────────────────────

Draws the previous period's High and Low for:
  • Daily  (previous day high/low)
  • Weekly (previous week high/low)
  • Monthly (previous month high/low)

Each level has its own style (solid/dashed/dotted) and
colour. Useful as key support/resistance reference levels.

─── PREMIUM / DISCOUNT / EQUILIBRIUM ZONES ──────────────────

Based on the current swing high and swing low (trailing
extremes), the visible range is divided into three zones:

  Premium Zone (top 5%):
    Price is trading at a premium. Bearish bias —
    institutions tend to SELL in premium.

  Equilibrium Zone (middle 5% around 50%):
    Price is at fair value. Neutral zone.

  Discount Zone (bottom 5%):
    Price is at a discount. Bullish bias —
    institutions tend to BUY in discount.

Display modes:
  Historical — draws ALL historical structure and OBs
  Present    — draws only the MOST RECENT instance
               (cleaner chart for live trading)

Style modes:
  Colored    — standard green/red/blue colours
  Monochrome — single grey tone (for minimal charts)

─── SMC ALERTS ──────────────────────────────────────────────

Full alert conditions available for:
  Internal Bullish / Bearish BOS
  Internal Bullish / Bearish CHoCH
  Swing Bullish / Bearish BOS
  Swing Bullish / Bearish CHoCH
  Equal Highs / Equal Lows
  Bullish / Bearish Fair Value Gap
  Internal Bullish / Bearish Order Block (mitigated)
  Swing Bullish / Bearish Order Block (mitigated)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
④ MARCO POLO TOP DETECTIVE MODULE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A pivot detection tool that identifies significant swing
tops and bottoms using a custom algorithm — different from
the standard ta.pivothigh() approach.

PIVOT DETECTION:
  Uses a rolling highest/lowest scan over a configurable
  Depth. A pivot is confirmed only when the price found
  deviates from the previous pivot by more than a threshold:

    Threshold = ATR(10) / close × 100 × Deviation input

  This prevents trivial micro-swings from being plotted and
  focuses only on significant structural pivots.

  Labels appear DEPTH bars back (offset) so they appear
  at the actual pivot bar, not the confirmation bar.
  → "Top Pivot" label (red, above bar)
  → "Bot Pivot" label (blue, below bar)

BOLLINGER BANDS REVERSAL CONFIRMATION:
  A second layer — the 3-bar BBands pattern — identifies
  short-term exhaustion reversals:

  Bear Reversal (bearish):
    • 2 bars ago: close > BBands upper AND green candle
    • 1 bar ago:  close > BBands upper AND red candle
    • Current bar: close < 1-bar-ago high
    → "Bear Rev" label (orange, above bar)

  Bull Reversal (bullish):
    • 2 bars ago: close < BBands lower AND red candle
    • 1 bar ago:  close < BBands lower AND green candle
    • Current bar: close > 1-bar-ago low
    → "Bull Rev" label (lime green, below bar)

This pattern catches short-term mean-reversion setups
at Bollinger Band extremes with candle confirmation.

ALERTS:
  Marco Top Detected — pivot top or bear reversal found
  Marco Bottom Detected — pivot bottom or bull reversal

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⑤ ZIGZAG MODULE (SWING + INTERNAL)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A dual ZigZag engine with a main Swing ZigZag and a
faster Internal ZigZag — each fully independent.

SWING ZIGZAG:
  Depth     — minimum bars before a pivot is confirmed
  Deviation — minimum % price move required for a new leg
  Backstep  — minimum bars between two pivots

  Each ZigZag leg is drawn as a line connecting consecutive
  swing highs and lows. Bull legs (rising) and Bear legs
  (falling) use separate configurable colours.

  HH / HL / LH / LL LABELS:
    Each pivot is automatically classified and labelled:
    • HH — Higher High (bullish trend continuation)
    • HL — Higher Low  (bullish trend continuation)
    • LH — Lower High  (bearish trend continuation)
    • LL — Lower Low   (bearish trend continuation)

  Label size is configurable (Tiny / Small / Normal).

INTERNAL ZIGZAG:
  A faster ZigZag with smaller depth and deviation to
  capture internal market structure swings within the
  main ZigZag legs. Displayed with a different colour
  and style (default dashed) to separate it visually
  from the main swing ZigZag.

  The internal ZigZag is disabled by default. Turn it on
  in the Internal ZigZag settings group.

LINE STYLES (both ZigZags):
  ⎯⎯⎯ Solid
  ---- Dashed
  ···· Dotted
  Line width: 1–4

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Master Toggles
  Enable / Disable each of the 5 modules independently.

① MA 1 / MA 2 / MA 3 — Type, Length, Colour
① Signal MA          — Type, Length, Width, Bull/Bear/Neutral colours
① Signal MA Filters  — HA toggle, Supertrend toggle, UT Bot toggle
① Supertrend         — ATR Length, Factor
① UT Bot             — Key Value, ATR Period
① VWAP               — Show toggle, Anchor, Colour

② Liquidity Swings   — Pivot Lookback, Swing Area mode
② Filter             — Count or Volume, threshold value
② Style              — Swing High colour, Swing Low colour,
                       area colours, label sizes, BSL/SSL labels

③ Smart Money Concepts — Mode (Historical/Present),
                          Style (Colored/Monochrome)
③ Internal Structure  — Show toggle, Bull/Bear filter, label size,
                         Confluence Filter
③ Swing Structure     — Show toggle, Bull/Bear filter, label size,
                         Swing Points toggle + length,
                         Strong/Weak High/Low toggle
③ Order Blocks        — Internal OB toggle + size,
                         Swing OB toggle + size,
                         OB Filter type, OB Mitigation type,
                         4 individual OB colours
③ EQH/EQL            — Show toggle, Bars Confirmation,
                         Threshold (ATR multiplier), Label size
③ Fair Value Gaps    — Show toggle, Auto Threshold,
                         Timeframe, Bull/Bear colours, Extend
③ Highs & Lows MTF   — Daily / Weekly / Monthly toggles,
                         style and colour for each
③ Premium & Discount — Show toggle, Premium / Equilibrium /
                         Discount zone colours

④ Marco Polo         — Deviation, Depth, Text colour,
                         BBands Length, BBands Multiplier

⑤ Main ZigZag        — Depth, Deviation, Backstep,
                         Bull/Bear colours, Width, Style,
                         HH/HL labels toggle + size
⑤ Internal ZigZag    — Same settings as main ZigZag,
                         independently configured

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 ALERTS SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SMC Alerts:
  ✦ Internal Bullish BOS        ✦ Internal Bearish BOS
  ✦ Internal Bullish CHoCH      ✦ Internal Bearish CHoCH
  ✦ Swing Bullish BOS           ✦ Swing Bearish BOS
  ✦ Swing Bullish CHoCH         ✦ Swing Bearish CHoCH
  ✦ Equal Highs                 ✦ Equal Lows
  ✦ Bullish Fair Value Gap      ✦ Bearish Fair Value Gap

Marco Polo Alerts:
  ✦ Marco Top Detected (pivot top or bear reversal)
  ✦ Marco Bottom Detected (pivot bottom or bull reversal)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 USAGE TIPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • On lower timeframes (1m–5m), disable Fair Value Gaps
    and Swing Order Blocks to reduce visual clutter.

  • For Nifty/BankNifty intraday, recommended setup:
    Signal MA (EMA 20) with all 3 filters ON +
    Liquidity Swings + Internal SMC structure only.

  • For positional/swing trading, enable the full SMC
    module with Historical mode to see all past structure.

  • Use Master Toggles to turn off modules you don't need —
    this significantly improves chart performance.

  • ZigZag and SMC Swing Structure complement each other:
    ZigZag shows the visual wave, SMC labels the reason
    (BOS/CHoCH) at each pivot.

  • Marco Polo works best on 15m and above for pivot
    detection. On 1m it may generate excessive signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📜 LICENSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CC BY-NC-SA 4.0 — Attribution-NonCommercial-ShareAlike 4.0
https://creativecommons.org/licenses/by-nc-sa/4.0/

✅ Free to use for personal and educational purposes
✅ Free to share with proper credit to SHK and original authors
✅ Free to adapt and modify with credit and same license
❌ Commercial use is NOT permitted
❌ Cannot be republished as invite-only or paid script



━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is published for EDUCATIONAL and INFORMATIONAL
purposes only. It is NOT financial advice, investment advice,
or a recommendation to buy or sell any financial instrument.

Trading and investing in financial markets — including stocks,
indices, commodities, currencies and derivatives — involves
substantial risk of loss. Past performance of any indicator,
strategy or signal does NOT guarantee future results.

The signals, labels, zones and levels produced by this script
are based purely on mathematical calculations applied to
historical price and volume data. They do not predict the
future with certainty. No indicator can.

YOU are solely responsible for your own trading decisions.
Always do your own research and analysis before entering any
trade. Always use proper risk management — including stop
losses and position sizing — on every trade.

The author (SHK) and the original authors of all combined
modules (LuxAlgo, QuantNomad, Marco Polo, ZigZag community)
accept NO liability for any financial losses incurred from
the use of this script, directly or indirectly.

This script is provided "AS IS" without warranty of any kind,
express or implied. The author makes no guarantee that the
script will function correctly on all symbols, timeframes,
brokers or data feeds.

By using this script, you acknowledge and accept that:
  • All trading decisions are made entirely at your own risk
  • No profit is guaranteed by using this indicator
  • The author bears zero responsibility for your P&L

If you are unsure about any trade, consult a registered
financial advisor before taking action.

Trade safe. Manage your risk. Protect your capital. 🙏
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
// © Combined: SHK 3 MA | VWAP | Liquidity Swings | Smart Money Concepts | Marco Polo | ZigZag
// License: Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

indicator("SHK All-In-One [3MA · VWAP · Liq · SMC · Marco · ZZ]",
  overlay         = true,
  max_lines_count = 500,
  max_labels_count= 500,
  max_boxes_count = 500)

// ═══════════════════════════════════════════════════════════
//  MASTER TOGGLES
// ═══════════════════════════════════════════════════════════
enable3MA   = input.bool(true,  "Enable  ▶  3 MA + VWAP",              group="◆ Master Toggles")
enableLiq   = input.bool(true,  "Enable  ▶  Liquidity Swings",         group="◆ Master Toggles")
enableSMC   = input.bool(true,  "Enable  ▶  Smart Money Concepts",     group="◆ Master Toggles")
enableMarco = input.bool(true,  "Enable  ▶  Marco Polo Top Detective", group="◆ Master Toggles")
enableZZ    = input.bool(true,  "Enable  ▶  ZigZag",                   group="◆ Master Toggles")

// ═══════════════════════════════════════════════════════════
//  ①  3 MA + VWAP SETTINGS
// ═══════════════════════════════════════════════════════════
ma1Type   = input.string("EMA","MA 1  Type",  options=["EMA","SMA","WMA","HMA","TEMA","DEMA","ZLEMA"], group="① MA 1", inline="ma1")
ma1Length = input.int(9,       "Length",      minval=1, maxval=500, group="① MA 1", inline="ma1")
ma1Col    = input.color(color.new(#2196F3,0), "Colour", group="① MA 1", inline="ma1")

ma2Type   = input.string("EMA","MA 2  Type",  options=["EMA","SMA","WMA","HMA","TEMA","DEMA","ZLEMA"], group="① MA 2", inline="ma2")
ma2Length = input.int(21,      "Length",      minval=1, maxval=500, group="① MA 2", inline="ma2")
ma2Col    = input.color(color.new(#FF9800,0), "Colour", group="① MA 2", inline="ma2")

ma3Type   = input.string("EMA","MA 3  Type",  options=["EMA","SMA","WMA","HMA","TEMA","DEMA","ZLEMA"], group="① MA 3", inline="ma3")
ma3Length = input.int(50,      "Length",      minval=1, maxval=500, group="① MA 3", inline="ma3")
ma3Col    = input.color(color.new(#E91E63,0), "Colour", group="① MA 3", inline="ma3")

smType    = input.string("EMA","Signal MA Type", options=["EMA","SMA","WMA","HMA","TEMA","DEMA","ZLEMA"], group="① Signal MA", inline="sm")
smLength  = input.int(20,      "Length",          minval=1, maxval=500, group="① Signal MA", inline="sm")
smWidth   = input.int(3,       "Line Width",      minval=1, maxval=5,   group="① Signal MA", inline="sm")
smBullCol = input.color(color.new(#00E676,0), "Bull",    group="① Signal MA", inline="smcol")
smBearCol = input.color(color.new(#FF1744,0), "Bear",    group="① Signal MA", inline="smcol")
smNeutCol = input.color(color.new(#B0BEC5,0), "Neutral", group="① Signal MA", inline="smcol")

useHA = input.bool(true, "Heiken Ashi filter", group="① Signal MA — Filters", inline="f1")
useST = input.bool(true, "Supertrend filter",  group="① Signal MA — Filters", inline="f1")
useUT = input.bool(true, "UT Bot filter",      group="① Signal MA — Filters", inline="f1")

showVWAP   = input.bool(true,      "Show VWAP", group="① VWAP")
vwapAnchor = input.string("Session","Anchor",   options=["Session","Week","Month","Quarter","Year"], group="① VWAP")
vwapCol    = input.color(color.new(#FFEB3B,0),  "Colour", group="① VWAP")

stLength = input.int(10,   "ATR Length", minval=1,   group="① Supertrend (Signal MA filter)", inline="st")
stFactor = input.float(3.0,"Factor",     minval=0.1, group="① Supertrend (Signal MA filter)", inline="st", step=0.1)

utKeyValue = input.float(1.0,"Key Value",  minval=0.1, step=0.1, group="① UT Bot (Signal MA filter)")
utATRLen   = input.int(1,    "ATR Period", minval=1,             group="① UT Bot (Signal MA filter)")

// ═══════════════════════════════════════════════════════════
//  ②  LIQUIDITY SWINGS SETTINGS
// ═══════════════════════════════════════════════════════════
liqLength        = input.int(14,             "Pivot Lookback",  group="② Liquidity Swings")
liqArea          = input.string("Wick Extremity","Swing Area",  options=["Wick Extremity","Full Range"], group="② Liquidity Swings")
liqFilterOptions = input.string("Count",     "Filter Areas By", options=["Count","Volume"], inline="liqfilter", group="② Liquidity Swings")
liqFilterValue   = input.float(0,            "",                inline="liqfilter", group="② Liquidity Swings")

showTop    = input.bool(true,  "Swing High", inline="top", group="② Liquidity Swings Style")
topCss     = input.color(color.red,  "",     inline="top", group="② Liquidity Swings Style")
topAreaCss = input.color(color.new(color.red,  50), "Area", inline="top", group="② Liquidity Swings Style")

showBtm    = input.bool(true,  "Swing Low",  inline="btm", group="② Liquidity Swings Style")
btmCss     = input.color(color.teal, "",     inline="btm", group="② Liquidity Swings Style")
btmAreaCss = input.color(color.new(color.teal, 50), "Area", inline="btm", group="② Liquidity Swings Style")

liqLabelSize    = input.string("Tiny", "Labels Size",       options=["Tiny","Small","Normal"], group="② Liquidity Swings Style")
showLiqLabels   = input.bool(true,     "Show BSL / SSL Labels",                                group="② Liquidity Swings Style")
liqBslLabelSize = input.string("Small","BSL/SSL Label Size", options=["Tiny","Small","Normal"], group="② Liquidity Swings Style")

// ═══════════════════════════════════════════════════════════
//  ③  SMART MONEY CONCEPTS SETTINGS
// ═══════════════════════════════════════════════════════════
GREEN        = #089981
RED          = #F23645
BLUE         = #2157f3
GRAY         = #878b94
MONO_BULLISH = #b2b5be
MONO_BEARISH = #5d606b
HISTORICAL   = "Historical"
PRESENT      = "Present"
COLORED      = "Colored"
MONOCHROME   = "Monochrome"
ALL          = "All"
BOS          = "BOS"
CHOCH        = "CHoCH"
ATR_F        = "Atr"
RANGE_F      = "Cumulative Mean Range"
CLOSE_M      = "Close"
HIGHLOW_M    = "High/Low"
SOLID_S      = "⎯⎯⎯"
DASHED_S     = "----"
DOTTED_S     = "····"

modeInput  = input.string(HISTORICAL,"Mode",  group="③ Smart Money Concepts", tooltip="Historical or Present only", options=[HISTORICAL,PRESENT])
styleInput = input.string(COLORED,   "Style", group="③ Smart Money Concepts", options=[COLORED,MONOCHROME])

showInternalsInput            = input.bool(true,  "Show Internal Structure",     group="③ Internal Structure")
showInternalBullInput         = input.string(ALL, "Bullish Structure",            group="③ Internal Structure", inline="ibull", options=[ALL,BOS,CHOCH])
internalBullColorInput        = input.color(GREEN,"",                             group="③ Internal Structure", inline="ibull")
showInternalBearInput         = input.string(ALL, "Bearish Structure",            group="③ Internal Structure", inline="ibear", options=[ALL,BOS,CHOCH])
internalBearColorInput        = input.color(RED,  "",                             group="③ Internal Structure", inline="ibear")
internalFilterConfluenceInput = input.bool(false, "Confluence Filter",            group="③ Internal Structure")
internalStructureSize         = input.string(size.tiny,"Internal Label Size",     group="③ Internal Structure", options=[size.tiny,size.small,size.normal])

showStructureInput  = input.bool(true,       "Show Swing Structure",  group="③ Swing Structure")
showSwingBullInput  = input.string(ALL,      "Bullish Structure",     group="③ Swing Structure", inline="bull", options=[ALL,BOS,CHOCH])
swingBullColorInput = input.color(GREEN,     "",                      group="③ Swing Structure", inline="bull")
showSwingBearInput  = input.string(ALL,      "Bearish Structure",     group="③ Swing Structure", inline="bear", options=[ALL,BOS,CHOCH])
swingBearColorInput = input.color(RED,       "",                      group="③ Swing Structure", inline="bear")
swingStructureSize  = input.string(size.small,"Swing Label Size",     group="③ Swing Structure", options=[size.tiny,size.small,size.normal])
showSwingsInput     = input.bool(false,      "Show Swings Points",    group="③ Swing Structure", inline="swings")
swingsLengthInput   = input.int(50,          "",                      group="③ Swing Structure", minval=10, inline="swings")
showHighLowSwingsInput = input.bool(true,    "Show Strong/Weak High/Low", group="③ Swing Structure")

showInternalOrderBlocksInput   = input.bool(true,  "Internal Order Blocks", group="③ Order Blocks", inline="iob")
internalOrderBlocksSizeInput   = input.int(5,       "",                     group="③ Order Blocks", minval=1, maxval=20, inline="iob")
showSwingOrderBlocksInput      = input.bool(false,  "Swing Order Blocks",   group="③ Order Blocks", inline="ob")
swingOrderBlocksSizeInput      = input.int(5,       "",                     group="③ Order Blocks", minval=1, maxval=20, inline="ob")
orderBlockFilterInput          = input.string(ATR_F,"Order Block Filter",   group="③ Order Blocks", options=[ATR_F,RANGE_F])
orderBlockMitigationInput      = input.string(HIGHLOW_M,"OB Mitigation",   group="③ Order Blocks", options=[CLOSE_M,HIGHLOW_M])
internalBullishOrderBlockColor = input.color(color.new(#3179f5,80),"Internal Bullish OB", group="③ Order Blocks")
internalBearishOrderBlockColor = input.color(color.new(#f77c80,80),"Internal Bearish OB", group="③ Order Blocks")
swingBullishOrderBlockColor    = input.color(color.new(#1848cc,80),"Bullish OB",          group="③ Order Blocks")
swingBearishOrderBlockColor    = input.color(color.new(#b22833,80),"Bearish OB",          group="③ Order Blocks")

showEqualHighsLowsInput      = input.bool(true,       "Equal High/Low",    group="③ EQH/EQL")
equalHighsLowsLengthInput    = input.int(3,            "Bars Confirmation", group="③ EQH/EQL", minval=1)
equalHighsLowsThresholdInput = input.float(0.1,        "Threshold",         group="③ EQH/EQL", minval=0, maxval=0.5, step=0.1)
equalHighsLowsSizeInput      = input.string(size.tiny, "Label Size",        group="③ EQH/EQL", options=[size.tiny,size.small,size.normal])

showFairValueGapsInput       = input.bool(false,    "Fair Value Gaps",  group="③ Fair Value Gaps")
fairValueGapsThresholdInput  = input.bool(true,     "Auto Threshold",   group="③ Fair Value Gaps")
fairValueGapsTimeframeInput  = input.timeframe("",  "Timeframe",        group="③ Fair Value Gaps")
fairValueGapsBullColorInput  = input.color(color.new(#00ff68,70),"Bullish FVG", group="③ Fair Value Gaps")
fairValueGapsBearColorInput  = input.color(color.new(#ff0008,70),"Bearish FVG", group="③ Fair Value Gaps")
fairValueGapsExtendInput     = input.int(1,         "Extend FVG",       group="③ Fair Value Gaps", minval=0)

showDailyLevelsInput    = input.bool(false,  "Daily",   group="③ Highs & Lows MTF", inline="daily")
dailyLevelsStyleInput   = input.string(SOLID_S,"",      group="③ Highs & Lows MTF", inline="daily",   options=[SOLID_S,DASHED_S,DOTTED_S])
dailyLevelsColorInput   = input.color(BLUE,   "",       group="③ Highs & Lows MTF", inline="daily")
showWeeklyLevelsInput   = input.bool(false,  "Weekly",  group="③ Highs & Lows MTF", inline="weekly")
weeklyLevelsStyleInput  = input.string(SOLID_S,"",      group="③ Highs & Lows MTF", inline="weekly",  options=[SOLID_S,DASHED_S,DOTTED_S])
weeklyLevelsColorInput  = input.color(BLUE,   "",       group="③ Highs & Lows MTF", inline="weekly")
showMonthlyLevelsInput  = input.bool(false,  "Monthly", group="③ Highs & Lows MTF", inline="monthly")
monthlyLevelsStyleInput = input.string(SOLID_S,"",      group="③ Highs & Lows MTF", inline="monthly", options=[SOLID_S,DASHED_S,DOTTED_S])
monthlyLevelsColorInput = input.color(BLUE,   "",       group="③ Highs & Lows MTF", inline="monthly")

showPremiumDiscountZonesInput = input.bool(false, "Premium/Discount Zones", group="③ Premium & Discount Zones")
premiumZoneColorInput         = input.color(RED,  "Premium Zone",           group="③ Premium & Discount Zones")
equilibriumZoneColorInput     = input.color(GRAY, "Equilibrium Zone",       group="③ Premium & Discount Zones")
discountZoneColorInput        = input.color(GREEN,"Discount Zone",          group="③ Premium & Discount Zones")

// ═══════════════════════════════════════════════════════════
//  ④  MARCO POLO SETTINGS
// ═══════════════════════════════════════════════════════════
marco_deviation = input.float(2.0, "Deviation",        minval=0,              group="④ Marco Polo Top Detective")
marco_depth     = input.int(22,    "Depth",             minval=1,              group="④ Marco Polo Top Detective")
marco_white     = input.bool(true, "White Text (False for Black)",              group="④ Marco Polo Top Detective")
marco_bblength  = input.int(19,    "BBands Length",     minval=1,              group="④ Marco Polo Top Detective")
marco_bbmult    = input.float(2.0, "BBands Multiplier", minval=0.001, maxval=50, group="④ Marco Polo Top Detective")

// ═══════════════════════════════════════════════════════════
//  ⑤  ZIGZAG SETTINGS
// ═══════════════════════════════════════════════════════════
showZZG         = input.bool(true,  "Show Swing ZigZag",       group="⑤ Main ZigZag")
zzgDepth        = input.int(12,     "Depth",                    group="⑤ Main ZigZag", minval=1, maxval=500)
zzgDeviation    = input.int(5,      "Deviation",                group="⑤ Main ZigZag", minval=1, maxval=100)
zzgBackstep     = input.int(2,      "Backstep",                 group="⑤ Main ZigZag", minval=1, maxval=50)
zzgBullColor    = input.color(color.new(#00FF00,0), "Bull Color", group="⑤ Main ZigZag", inline="c")
zzgBearColor    = input.color(color.new(#F23645,0), "Bear Color", group="⑤ Main ZigZag", inline="c")
zzgWidth        = input.int(2,      "Line Width",               group="⑤ Main ZigZag", inline="w", minval=1, maxval=4)
zzgStyle        = input.string("⎯⎯⎯","Line Style",             group="⑤ Main ZigZag", inline="w", options=["⎯⎯⎯","----","····"])
zzgShowLabels   = input.bool(true,  "Show HH/HL/LH/LL Labels", group="⑤ Main ZigZag")
zzgLabelSize    = input.string(size.small,"Label Size",         group="⑤ Main ZigZag", options=[size.tiny,size.small,size.normal])
zzgShowInternal = input.bool(false, "Show Internal ZigZag",    group="⑤ Internal ZigZag")
zzgiDepth       = input.int(5,      "Int Depth",                group="⑤ Internal ZigZag", minval=1, maxval=500)
zzgiDeviation   = input.int(3,      "Int Deviation",            group="⑤ Internal ZigZag", minval=1, maxval=100)
zzgiBackstep    = input.int(1,      "Int Backstep",             group="⑤ Internal ZigZag", minval=1, maxval=50)
zzgiBullColor   = input.color(color.new(#00FF00,0), "Int Bull Color", group="⑤ Internal ZigZag", inline="ic")
zzgiBearColor   = input.color(color.new(#ff9800,0), "Int Bear Color", group="⑤ Internal ZigZag", inline="ic")
zzgiWidth       = input.int(1,      "Int Width",                group="⑤ Internal ZigZag", inline="iw", minval=1, maxval=4)
zzgiStyle       = input.string("----","Int Style",              group="⑤ Internal ZigZag", inline="iw", options=["⎯⎯⎯","----","····"])

// ═══════════════════════════════════════════════════════════
//  SHARED — Heiken Ashi
// ═══════════════════════════════════════════════════════════
haClose  = (open + high + low + close) / 4
var float haOpen = na
haOpen  := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2
haIsBull = haClose > haOpen
haIsBear = haClose < haOpen

// ═══════════════════════════════════════════════════════════
//  ①  3 MA + VWAP CALCULATIONS
// ═══════════════════════════════════════════════════════════
getMA(src, len, t) =>
    float result = na
    switch t
        "EMA"   => result := ta.ema(src, len)
        "SMA"   => result := ta.sma(src, len)
        "WMA"   => result := ta.wma(src, len)
        "HMA"   => result := ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))
        "TEMA"  =>
            e1 = ta.ema(src, len)
            e2 = ta.ema(e1, len)
            e3 = ta.ema(e2, len)
            result := 3 * e1 - 3 * e2 + e3
        "DEMA"  =>
            e1 = ta.ema(src, len)
            result := 2 * e1 - ta.ema(e1, len)
        "ZLEMA" =>
            lag = math.round((len - 1) / 2)
            result := ta.ema(src + (src - src[lag]), len)
        => result := ta.ema(src, len)
    result

ma1Val = getMA(close, ma1Length, ma1Type)
ma2Val = getMA(close, ma2Length, ma2Type)
ma3Val = getMA(close, ma3Length, ma3Type)
smVal  = getMA(close, smLength,  smType)

[stLine, stDir] = ta.supertrend(stFactor, stLength)
stBull = stDir < 0
stBear = stDir > 0

xATR  = ta.atr(utATRLen)
nLoss = utKeyValue * xATR
utSrc = haClose
var float xATRTS = 0.0
xATRTS :=
     utSrc > nz(xATRTS[1]) and utSrc[1] > nz(xATRTS[1]) ?
         math.max(nz(xATRTS[1]), utSrc - nLoss) :
     utSrc < nz(xATRTS[1]) and utSrc[1] < nz(xATRTS[1]) ?
         math.min(nz(xATRTS[1]), utSrc + nLoss) :
     utSrc > nz(xATRTS[1]) ? utSrc - nLoss : utSrc + nLoss
utBull = utSrc > xATRTS
utBear = utSrc < xATRTS

score = 0
score := score + (useHA ? (haIsBull ? 1 : haIsBear ? -1 : 0) : 0)
score := score + (useST ? (stBull   ? 1 : stBear   ? -1 : 0) : 0)
score := score + (useUT ? (utBull   ? 1 : utBear   ? -1 : 0) : 0)
smColor = score > 0 ? smBullCol : score < 0 ? smBearCol : smNeutCol

anchorReset =
     vwapAnchor == "Session"  ? timeframe.change("D")   :
     vwapAnchor == "Week"     ? timeframe.change("W")   :
     vwapAnchor == "Month"    ? timeframe.change("M")   :
     vwapAnchor == "Quarter"  ? (month != month[3] and (month == 1 or month == 4 or month == 7 or month == 10)) :
     vwapAnchor == "Year"     ? timeframe.change("12M") : timeframe.change("D")

var float cumTPV = 0.0
var float cumVol = 0.0
if anchorReset or barstate.isfirst
    cumTPV := hlc3 * volume
    cumVol := volume
else
    cumTPV += hlc3 * volume
    cumVol += volume
vwapVal = cumVol != 0 ? cumTPV / cumVol : na

cross12Up   = ta.crossover(ma1Val,  ma2Val)
cross12Down = ta.crossunder(ma1Val, ma2Val)
cross23Up   = ta.crossover(ma2Val,  ma3Val)
cross23Down = ta.crossunder(ma2Val, ma3Val)

plot(enable3MA ? ma1Val : na, "MA 1",      color=ma1Col,  linewidth=2)
plot(enable3MA ? ma2Val : na, "MA 2",      color=ma2Col,  linewidth=2)
plot(enable3MA ? ma3Val : na, "MA 3",      color=ma3Col,  linewidth=2)
plot(enable3MA ? smVal  : na, "Signal MA", color=smColor, linewidth=smWidth)
plot(enable3MA and showVWAP ? vwapVal : na, "VWAP", color=vwapCol, linewidth=2)

if enable3MA and cross12Up
    label.new(bar_index, low,  str.tostring(ma1Length)+"×"+str.tostring(ma2Length),
         style=label.style_triangleup,   color=ma1Col,
         textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if enable3MA and cross12Down
    label.new(bar_index, high, str.tostring(ma2Length)+"×"+str.tostring(ma1Length),
         style=label.style_triangledown, color=ma1Col,
         textcolor=color.white, size=size.small, yloc=yloc.abovebar)
if enable3MA and cross23Up
    label.new(bar_index, low,  str.tostring(ma2Length)+"×"+str.tostring(ma3Length),
         style=label.style_triangleup,   color=ma2Col,
         textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if enable3MA and cross23Down
    label.new(bar_index, high, str.tostring(ma3Length)+"×"+str.tostring(ma2Length),
         style=label.style_triangledown, color=ma2Col,
         textcolor=color.white, size=size.small, yloc=yloc.abovebar)

// ═══════════════════════════════════════════════════════════
//  ②  LIQUIDITY SWINGS CALCULATIONS
// ═══════════════════════════════════════════════════════════
n = bar_index

liq_label_sz(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.small

get_liq_counts(condition, top, btm) =>
    var int   lcount = 0
    var float lvol   = 0.
    if not na(condition)
        lcount := 0
        lvol   := 0.
    else
        lvol   += low[liqLength]  < top and high[liqLength] > btm ? volume[liqLength] : 0
        lcount += low[liqLength]  < top and high[liqLength] > btm ? 1 : 0
    [lcount, lvol]

liq_set_label(count, vol, x, y, css, lbl_style) =>
    var label lbl = na
    var label_size2 = switch liqLabelSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.tiny
    target = switch liqFilterOptions
        "Count"  => count
        "Volume" => vol
    if ta.crossover(target, liqFilterValue)
        lbl := label.new(x, y, str.tostring(vol, format.volume),
              style=lbl_style, size=label_size2,
              color=#00000000, textcolor=css)
    if target > liqFilterValue
        label.set_text(lbl, str.tostring(vol, format.volume))

liq_set_level(condition, crossed, value, count, vol, css, isBuy) =>
    var line  lvl     = na
    var label liq_lbl = na
    var int   lbl_x1  = na
    target = switch liqFilterOptions
        "Count"  => count
        "Volume" => vol
    if not na(condition)
        if target[1] < liqFilterValue[1]
            line.delete(lvl[1])
            label.delete(liq_lbl[1])
        else if not crossed[1]
            line.set_x2(lvl, n - liqLength)
        lvl    := line.new(n - liqLength, value, n, value, color=na, width=3)
        lbl_x1 := n - liqLength
        if showLiqLabels
            vol_str   = str.tostring(vol, format.volume)
            liq_tag   = (isBuy ? "▲  Buy Side Liquidity" : "▼  Sell Side Liquidity") + "  │  " + vol_str
            liq_style = isBuy ? label.style_label_down : label.style_label_up
            liq_off   = value * 0.001
            liq_y     = isBuy ? value + liq_off : value - liq_off
            liq_lbl  := label.new(lbl_x1, liq_y, liq_tag,
                  xloc=xloc.bar_index, style=liq_style,
                  size=liq_label_sz(liqBslLabelSize),
                  color=css, textcolor=color.white)
    if not crossed[1]
        line.set_x2(lvl, n + 3)
        if showLiqLabels and not na(liq_lbl)
            label.set_x(liq_lbl, lbl_x1)
            liq_off2 = value * 0.001
            label.set_y(liq_lbl, isBuy ? value + liq_off2 : value - liq_off2)
            label.set_text(liq_lbl, (isBuy ? "▲  Buy Side Liquidity" : "▼  Sell Side Liquidity") + "  │  " + str.tostring(vol, format.volume))
    if crossed and not crossed[1]
        line.set_x2(lvl, n)
        line.set_style(lvl, line.style_dashed)
        if showLiqLabels and not na(liq_lbl)
            label.set_x(liq_lbl, lbl_x1)
            liq_off3 = value * 0.001
            label.set_y(liq_lbl, isBuy ? value + liq_off3 : value - liq_off3)
            label.set_text(liq_lbl, (isBuy ? "✓ BSL Swept" : "✓ SSL Swept") + "  │  " + str.tostring(vol, format.volume))
            label.set_color(liq_lbl, color.new(css, 55))
            label.set_textcolor(liq_lbl, color.new(color.white, 25))
    if target > liqFilterValue
        line.set_color(lvl, css)

liq_set_zone(condition, x, top, btm, count, vol, css) =>
    var box bx = na
    target = switch liqFilterOptions
        "Count"  => count
        "Volume" => vol
    if ta.crossover(target, liqFilterValue)
        bx := box.new(x, top, x + count, btm, border_color=na, bgcolor=css)
    if target > liqFilterValue
        box.set_right(bx, x + count)

var float ph_top     = na
var float ph_btm     = na
var bool  ph_crossed = false
var int   ph_x1      = 0
var box   ph_bx      = box.new(na, na, na, na, bgcolor=color.new(topAreaCss, 80), border_color=na)

var float pl_top     = na
var float pl_btm     = na
var bool  pl_crossed = false
var int   pl_x1      = 0
var box   pl_bx      = box.new(na, na, na, na, bgcolor=color.new(btmAreaCss, 80), border_color=na)

ph = ta.pivothigh(liqLength, liqLength)
pl = ta.pivotlow(liqLength,  liqLength)

[ph_count, ph_vol] = get_liq_counts(ph, ph_top, ph_btm)
[pl_count, pl_vol] = get_liq_counts(pl, pl_top, pl_btm)

if enableLiq
    if not na(ph) and showTop
        ph_top     := high[liqLength]
        ph_btm     := liqArea == "Wick Extremity" ? math.max(close[liqLength], open[liqLength]) : low[liqLength]
        ph_x1      := n - liqLength
        ph_crossed := false
        box.set_lefttop(ph_bx, ph_x1, ph_top)
        box.set_rightbottom(ph_bx, ph_x1, ph_btm)
    else
        ph_crossed := close > ph_top ? true : ph_crossed
        if ph_crossed
            box.set_right(ph_bx, ph_x1)
        else
            box.set_right(ph_bx, n + 3)

    if not na(pl) and showBtm
        pl_top     := liqArea == "Wick Extremity" ? math.min(close[liqLength], open[liqLength]) : high[liqLength]
        pl_btm     := low[liqLength]
        pl_x1      := n - liqLength
        pl_crossed := false
        box.set_lefttop(pl_bx, pl_x1, pl_top)
        box.set_rightbottom(pl_bx, pl_x1, pl_btm)
    else
        pl_crossed := close < pl_btm ? true : pl_crossed
        if pl_crossed
            box.set_right(pl_bx, pl_x1)
        else
            box.set_right(pl_bx, n + 3)

    if showTop
        liq_set_zone(ph, ph_x1, ph_top, ph_btm, ph_count, ph_vol, topAreaCss)
        liq_set_level(ph, ph_crossed, ph_top, ph_count, ph_vol, topCss, true)

    if showBtm
        liq_set_zone(pl, pl_x1, pl_top, pl_btm, pl_count, pl_vol, btmAreaCss)
        liq_set_level(pl, pl_crossed, pl_btm, pl_count, pl_vol, btmCss, false)

// ═══════════════════════════════════════════════════════════
//  ③  SMART MONEY CONCEPTS
// ═══════════════════════════════════════════════════════════
BULLISH_LEG = 1
BEARISH_LEG = 0
BULLISH     = +1
BEARISH     = -1

type smc_alerts
    bool internalBullishBOS        = false
    bool internalBearishBOS        = false
    bool internalBullishCHoCH      = false
    bool internalBearishCHoCH      = false
    bool swingBullishBOS           = false
    bool swingBearishBOS           = false
    bool swingBullishCHoCH         = false
    bool swingBearishCHoCH         = false
    bool internalBullishOrderBlock = false
    bool internalBearishOrderBlock = false
    bool swingBullishOrderBlock    = false
    bool swingBearishOrderBlock    = false
    bool equalHighs                = false
    bool equalLows                 = false
    bool bullishFairValueGap       = false
    bool bearishFairValueGap       = false

type trailingExtremes
    float top
    float bottom
    int   barTime
    int   barIndex
    int   lastTopTime
    int   lastBottomTime

type fairValueGap
    float top
    float bottom
    int   bias
    box   topBox
    box   bottomBox

type smc_trend
    int bias

type equalDisplay
    line  l_ine  = na
    label l_abel = na

type pivot
    float currentLevel
    float lastLevel
    bool  crossed
    int   barTime  = time
    int   barIndex = bar_index

type orderBlock
    float barHigh
    float barLow
    int   barTime
    int   bias

var pivot swingHigh               = pivot.new(na, na, false)
var pivot swingLow                = pivot.new(na, na, false)
var pivot internalHigh            = pivot.new(na, na, false)
var pivot internalLow             = pivot.new(na, na, false)
var pivot equalHigh               = pivot.new(na, na, false)
var pivot equalLow                = pivot.new(na, na, false)
var smc_trend swingTrend          = smc_trend.new(0)
var smc_trend internalTrend       = smc_trend.new(0)
var equalDisplay equalHighDisplay = equalDisplay.new()
var equalDisplay equalLowDisplay  = equalDisplay.new()
var array<fairValueGap> fairValueGaps      = array.new<fairValueGap>()
var array<float>  smc_parsedHighs          = array.new<float>()
var array<float>  smc_parsedLows           = array.new<float>()
var array<float>  smc_highs                = array.new<float>()
var array<float>  smc_lows                 = array.new<float>()
var array<int>    smc_times                = array.new<int>()
var trailingExtremes trailing              = trailingExtremes.new()
var array<orderBlock> swingOrderBlocks     = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks  = array.new<orderBlock>()
var array<box>   swingOrderBlocksBoxes     = array.new<box>()
var array<box>   internalOrderBlocksBoxes  = array.new<box>()
var swingBullishColor  = styleInput == MONOCHROME ? MONO_BULLISH : swingBullColorInput
var swingBearishColor  = styleInput == MONOCHROME ? MONO_BEARISH : swingBearColorInput
var fvgBullColor       = styleInput == MONOCHROME ? color.new(MONO_BULLISH,70) : fairValueGapsBullColorInput
var fvgBearColor       = styleInput == MONOCHROME ? color.new(MONO_BEARISH,70) : fairValueGapsBearColorInput
var premiumZoneColor2  = styleInput == MONOCHROME ? MONO_BEARISH : premiumZoneColorInput
var discountZoneColor2 = styleInput == MONOCHROME ? MONO_BULLISH : discountZoneColorInput
var int currentBarIndex = bar_index
var int lastBarIndex2   = bar_index
smc_alerts currentAlerts = smc_alerts.new()
var smc_initialTime      = time

if barstate.isfirst
    if showSwingOrderBlocksInput
        for index = 1 to swingOrderBlocksSizeInput
            swingOrderBlocksBoxes.push(box.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.right))
    if showInternalOrderBlocksInput
        for index = 1 to internalOrderBlocksSizeInput
            internalOrderBlocksBoxes.push(box.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.right))

bearishOBMitSrc   = orderBlockMitigationInput == CLOSE_M ? close : high
bullishOBMitSrc   = orderBlockMitigationInput == CLOSE_M ? close : low
atrMeasure        = ta.atr(200)
volatilityMeasure = orderBlockFilterInput == ATR_F ? atrMeasure : ta.cum(ta.tr) / bar_index
highVolBar        = (high - low) >= (2 * volatilityMeasure)
smc_parsedHigh    = highVolBar ? low  : high
smc_parsedLow     = highVolBar ? high : low

smc_parsedHighs.push(smc_parsedHigh)
smc_parsedLows.push(smc_parsedLow)
smc_highs.push(high)
smc_lows.push(low)
smc_times.push(time)

smc_leg(int sz) =>
    var leg2   = 0
    newLegHigh = high[sz] > ta.highest(sz)
    newLegLow  = low[sz]  < ta.lowest(sz)
    if newLegHigh
        leg2 := BEARISH_LEG
    else if newLegLow
        leg2 := BULLISH_LEG
    leg2

startOfNewLeg(int l)     => ta.change(l) != 0
startOfBearishLeg(int l) => ta.change(l) == -1
startOfBullishLeg(int l) => ta.change(l) == +1

smc_drawLabel(int lTime, float lPrice, string tag, color lColor, string lStyle) =>
    var label l2 = na
    if modeInput == PRESENT
        l2.delete()
    l2 := label.new(chart.point.new(lTime, na, lPrice), tag, xloc.bar_time,
         color=color.new(color.white, 100), textcolor=lColor, style=lStyle, size=size.small)

smc_drawEqHL(pivot piv, float lvl, int sz, bool eqH) =>
    equalDisplay ed = eqH ? equalHighDisplay : equalLowDisplay
    string tag2     = "EQL"
    color  eqColor  = swingBullishColor
    string lStyle2  = label.style_label_up
    if eqH
        tag2    := "EQH"
        eqColor := swingBearishColor
        lStyle2 := label.style_label_down
    if modeInput == PRESENT
        line.delete(ed.l_ine)
        label.delete(ed.l_abel)
    ed.l_ine  := line.new(chart.point.new(piv.barTime, na, piv.currentLevel),
         chart.point.new(time[sz], na, lvl), xloc=xloc.bar_time, color=eqColor, style=line.style_dotted)
    labelPos   = math.round(0.5 * (piv.barIndex + bar_index - sz))
    ed.l_abel := label.new(chart.point.new(na, labelPos, lvl), tag2, xloc.bar_index,
         color=color.new(color.white, 100), textcolor=eqColor, style=lStyle2, size=equalHighsLowsSizeInput)

smc_getStructure(int sz, bool eqHL = false, bool internal = false) =>
    curLeg   = smc_leg(sz)
    newPiv   = startOfNewLeg(curLeg)
    pivLow2  = startOfBullishLeg(curLeg)
    pivHigh2 = startOfBearishLeg(curLeg)
    if newPiv
        if pivLow2
            pivot piv2 = eqHL ? equalLow : internal ? internalLow : swingLow
            if eqHL and math.abs(piv2.currentLevel - low[sz]) < equalHighsLowsThresholdInput * atrMeasure
                smc_drawEqHL(piv2, low[sz], sz, false)
                currentAlerts.equalLows := true
            piv2.lastLevel    := piv2.currentLevel
            piv2.currentLevel := low[sz]
            piv2.crossed      := false
            piv2.barTime      := time[sz]
            piv2.barIndex     := bar_index[sz]
            if not eqHL and not internal
                trailing.bottom         := piv2.currentLevel
                trailing.barTime        := piv2.barTime
                trailing.barIndex       := piv2.barIndex
                trailing.lastBottomTime := piv2.barTime
            if showSwingsInput and not internal and not eqHL
                smc_drawLabel(time[sz], piv2.currentLevel,
                     piv2.currentLevel < piv2.lastLevel ? "LL" : "HL",
                     swingBullishColor, label.style_label_up)
        else
            pivot piv3 = eqHL ? equalHigh : internal ? internalHigh : swingHigh
            if eqHL and math.abs(piv3.currentLevel - high[sz]) < equalHighsLowsThresholdInput * atrMeasure
                smc_drawEqHL(piv3, high[sz], sz, true)
                currentAlerts.equalHighs := true
            piv3.lastLevel    := piv3.currentLevel
            piv3.currentLevel := high[sz]
            piv3.crossed      := false
            piv3.barTime      := time[sz]
            piv3.barIndex     := bar_index[sz]
            if not eqHL and not internal
                trailing.top         := piv3.currentLevel
                trailing.barTime     := piv3.barTime
                trailing.barIndex    := piv3.barIndex
                trailing.lastTopTime := piv3.barTime
            if showSwingsInput and not internal and not eqHL
                smc_drawLabel(time[sz], piv3.currentLevel,
                     piv3.currentLevel > piv3.lastLevel ? "HH" : "LH",
                     swingBearishColor, label.style_label_down)

smc_drawStructure(pivot piv4, string tag3, color sc, string ls, string lbStyle, string lbSize) =>
    var line  l3 = line.new(na, na, na, na, xloc=xloc.bar_time)
    var label l4 = label.new(na, na)
    if modeInput == PRESENT
        l3.delete()
        l4.delete()
    l3 := line.new(chart.point.new(piv4.barTime, na, piv4.currentLevel),
         chart.point.new(time, na, piv4.currentLevel), xloc.bar_time, color=sc, style=ls)
    l4 := label.new(chart.point.new(na, math.round(0.5 * (piv4.barIndex + bar_index)), piv4.currentLevel), tag3,
         xloc.bar_index, color=color.new(color.white, 100), textcolor=sc, style=lbStyle, size=lbSize)

smc_deleteOBs(bool internal = false) =>
    array<orderBlock> obs = internal ? internalOrderBlocks : swingOrderBlocks
    for [idx, ob] in obs
        bool crossed2 = false
        if bearishOBMitSrc > ob.barHigh and ob.bias == BEARISH
            crossed2 := true
            if internal
                currentAlerts.internalBearishOrderBlock := true
            else
                currentAlerts.swingBearishOrderBlock    := true
        else if bullishOBMitSrc < ob.barLow and ob.bias == BULLISH
            crossed2 := true
            if internal
                currentAlerts.internalBullishOrderBlock := true
            else
                currentAlerts.swingBullishOrderBlock    := true
        if crossed2
            obs.remove(idx)

smc_storeOB(pivot piv5, bool internal, int bias) =>
    if (not internal and showSwingOrderBlocksInput) or (internal and showInternalOrderBlocksInput)
        array<float> a2 = na
        int pIdx = na
        if bias == BEARISH
            a2   := smc_parsedHighs.slice(piv5.barIndex, bar_index)
            pIdx := piv5.barIndex + a2.indexof(a2.max())
        else
            a2   := smc_parsedLows.slice(piv5.barIndex, bar_index)
            pIdx := piv5.barIndex + a2.indexof(a2.min())
        orderBlock ob2         = orderBlock.new(smc_parsedHighs.get(pIdx), smc_parsedLows.get(pIdx), smc_times.get(pIdx), bias)
        array<orderBlock> obs2 = internal ? internalOrderBlocks : swingOrderBlocks
        if obs2.size() >= 100
            obs2.pop()
        obs2.unshift(ob2)

smc_drawOBs(bool internal = false) =>
    array<orderBlock> obs3 = internal ? internalOrderBlocks : swingOrderBlocks
    sz2 = obs3.size()
    if sz2 > 0
        maxOB  = internal ? internalOrderBlocksSizeInput : swingOrderBlocksSizeInput
        sliced = obs3.slice(0, math.min(maxOB, sz2))
        boxes2 = internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes
        for [idx2, ob3] in sliced
            obColor = styleInput == MONOCHROME ?
                 (ob3.bias == BEARISH ? color.new(MONO_BEARISH,80) : color.new(MONO_BULLISH,80)) :
                 internal ?
                 (ob3.bias == BEARISH ? internalBearishOrderBlockColor : internalBullishOrderBlockColor) :
                 (ob3.bias == BEARISH ? swingBearishOrderBlockColor    : swingBullishOrderBlockColor)
            bx2 = boxes2.get(idx2)
            bx2.set_top_left_point(     chart.point.new(ob3.barTime,   na, ob3.barHigh))
            bx2.set_bottom_right_point( chart.point.new(last_bar_time, na, ob3.barLow))
            bx2.set_border_color(internal ? na : obColor)
            bx2.set_bgcolor(obColor)
            ob_name2    = internal ? (ob3.bias == BULLISH ? "Internal Bullish OB" : "Internal Bearish OB") :
                                     (ob3.bias == BULLISH ? "Bullish OB" : "Bearish OB")
            ob_lbl_stl2 = ob3.bias == BULLISH ? label.style_label_lower_left : label.style_label_upper_left
            ob_lbl_y2   = ob3.bias == BULLISH ? ob3.barLow : ob3.barHigh
            ob_lbl_sz2  = internal ? size.tiny : size.small
            label.new(chart.point.new(ob3.barTime, na, ob_lbl_y2), ob_name2,
                 xloc=xloc.bar_time, style=ob_lbl_stl2,
                 color=color.new(obColor, 0), textcolor=color.white, size=ob_lbl_sz2)

smc_displayStructure(bool internal = false) =>
    var bool bullBar2 = true
    var bool bearBar2 = true
    if internalFilterConfluenceInput
        bullBar2 := high - math.max(close, open) > math.min(close, open - low)
        bearBar2 := high - math.max(close, open) < math.min(close, open - low)

    pivot piv6   = internal ? internalHigh : swingHigh
    smc_trend t2 = internal ? internalTrend : swingTrend
    ls2          = internal ? line.style_dashed : line.style_solid
    szStr        = internal ? internalStructureSize : swingStructureSize
    extra1       = internal ? internalHigh.currentLevel != swingHigh.currentLevel and bullBar2 : true
    bullC2       = styleInput == MONOCHROME ? MONO_BULLISH : internal ? internalBullColorInput : swingBullColorInput

    if ta.crossover(close, piv6.currentLevel) and not piv6.crossed and extra1
        string tag4 = t2.bias == BEARISH ? CHOCH : BOS
        if internal
            currentAlerts.internalBullishCHoCH := tag4 == CHOCH
            currentAlerts.internalBullishBOS   := tag4 == BOS
        else
            currentAlerts.swingBullishCHoCH    := tag4 == CHOCH
            currentAlerts.swingBullishBOS      := tag4 == BOS
        piv6.crossed := true
        t2.bias      := BULLISH
        dc1 = internal ?
             showInternalsInput and (showInternalBullInput == ALL or (showInternalBullInput == BOS and tag4 != CHOCH) or (showInternalBullInput == CHOCH and tag4 == CHOCH)) :
             showStructureInput and (showSwingBullInput == ALL or (showSwingBullInput == BOS and tag4 != CHOCH) or (showSwingBullInput == CHOCH and tag4 == CHOCH))
        if dc1
            smc_drawStructure(piv6, tag4, bullC2, ls2, label.style_label_down, szStr)
        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            smc_storeOB(piv6, internal, BULLISH)

    pivot piv7  = internal ? internalLow : swingLow
    extra2      = internal ? internalLow.currentLevel != swingLow.currentLevel and bearBar2 : true
    bearC2      = styleInput == MONOCHROME ? MONO_BEARISH : internal ? internalBearColorInput : swingBearColorInput

    if ta.crossunder(close, piv7.currentLevel) and not piv7.crossed and extra2
        string tag5 = t2.bias == BULLISH ? CHOCH : BOS
        if internal
            currentAlerts.internalBearishCHoCH := tag5 == CHOCH
            currentAlerts.internalBearishBOS   := tag5 == BOS
        else
            currentAlerts.swingBearishCHoCH    := tag5 == CHOCH
            currentAlerts.swingBearishBOS      := tag5 == BOS
        piv7.crossed := true
        t2.bias      := BEARISH
        dc2 = internal ?
             showInternalsInput and (showInternalBearInput == ALL or (showInternalBearInput == BOS and tag5 != CHOCH) or (showInternalBearInput == CHOCH and tag5 == CHOCH)) :
             showStructureInput and (showSwingBearInput == ALL or (showSwingBearInput == BOS and tag5 != CHOCH) or (showSwingBearInput == CHOCH and tag5 == CHOCH))
        if dc2
            smc_drawStructure(piv7, tag5, bearC2, ls2, label.style_label_up, szStr)
        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            smc_storeOB(piv7, internal, BEARISH)

smc_fvgBox(lt, rt, tp, bp, bc) =>
    box.new(chart.point.new(lt, na, tp),
         chart.point.new(rt + fairValueGapsExtendInput * (time - time[1]), na, bp),
         xloc=xloc.bar_time, border_color=bc, bgcolor=bc)

smc_deleteFVGs() =>
    for [idx3, fg] in fairValueGaps
        if (low < fg.bottom and fg.bias == BULLISH) or (high > fg.top and fg.bias == BEARISH)
            fg.topBox.delete()
            fg.bottomBox.delete()
            fairValueGaps.remove(idx3)

smc_drawFVGs() =>
    [lastClose2, lastOpen2, lastTime2, curHigh2, curLow2, curTime2, last2High2, last2Low2] =
         request.security(syminfo.tickerid, fairValueGapsTimeframeInput,
         [close[1], open[1], time[1], high[0], low[0], time[0], high[2], low[2]],
         lookahead=barmerge.lookahead_on)
    barDelta  = (curTime2 - lastTime2)
    isBullFVG = last2Low2 > curHigh2
    isBearFVG = last2High2 < curLow2
    threshold = fairValueGapsThresholdInput ? atrMeasure * 0.5 : 0.0
    if isBullFVG and (last2Low2 - curHigh2) > threshold
        fg = fairValueGap.new(last2Low2, curHigh2, BULLISH,
             smc_fvgBox(lastTime2, curTime2 + barDelta, last2Low2, (last2Low2 + curHigh2) / 2, fvgBullColor),
             smc_fvgBox(lastTime2, curTime2 + barDelta, (last2Low2 + curHigh2) / 2, curHigh2, fvgBullColor))
        fairValueGaps.unshift(fg)
        currentAlerts.bullishFairValueGap := true
    if isBearFVG and (curLow2 - last2High2) > threshold
        fg = fairValueGap.new(curLow2, last2High2, BEARISH,
             smc_fvgBox(lastTime2, curTime2 + barDelta, curLow2, (curLow2 + last2High2) / 2, fvgBearColor),
             smc_fvgBox(lastTime2, curTime2 + barDelta, (curLow2 + last2High2) / 2, last2High2, fvgBearColor))
        fairValueGaps.unshift(fg)
        currentAlerts.bearishFairValueGap := true

smc_lineStyle(string s) =>
    switch s
        DASHED_S => line.style_dashed
        DOTTED_S => line.style_dotted
        => line.style_solid

smc_drawLevels(string tf2, bool sameTF, string sty2, color lc) =>
    topL   = request.security(syminfo.tickerid, tf2, high[1],  lookahead=barmerge.lookahead_on)
    botL   = request.security(syminfo.tickerid, tf2, low[1],   lookahead=barmerge.lookahead_on)
    lTime3 = request.security(syminfo.tickerid, tf2, time[1],  lookahead=barmerge.lookahead_on)
    rTime3 = request.security(syminfo.tickerid, tf2, time,     lookahead=barmerge.lookahead_on)
    float parsedTop2  = sameTF ? high  : topL
    float parsedBot2  = sameTF ? low   : botL
    int   parsedLTime = sameTF ? time  : lTime3
    int   parsedRTime = sameTF ? time  : rTime3
    ls3 = smc_lineStyle(sty2)
    var line topLine = na
    var line botLine = na
    if timeframe.change(tf2) or barstate.isfirst
        topLine := line.new(chart.point.new(parsedLTime, na, parsedTop2),
             chart.point.new(parsedRTime, na, parsedTop2),
             xloc=xloc.bar_time, color=lc, style=ls3, extend=extend.right)
        botLine := line.new(chart.point.new(parsedLTime, na, parsedBot2),
             chart.point.new(parsedRTime, na, parsedBot2),
             xloc=xloc.bar_time, color=lc, style=ls3, extend=extend.right)

// ── Premium/Discount zone helpers (persistent boxes — updated each bar, not recreated) ──
smc_drawZone(float labelLevel, int labelIndex, float top, float bottom, string tag, color zoneColor, string lstyle) =>
    var label zl = label.new(na, na, text=tag, color=color.new(color.white,100),
         textcolor=zoneColor, style=lstyle, size=size.small)
    var box   zb = box.new(na, na, na, na,
         bgcolor=color.new(zoneColor,80), border_color=color.new(color.white,100),
         xloc=xloc.bar_time)
    zb.set_top_left_point(    chart.point.new(trailing.barTime, na, top))
    zb.set_bottom_right_point(chart.point.new(last_bar_time,    na, bottom))
    zl.set_point(chart.point.new(na, labelIndex, labelLevel))

smc_premiumDiscount() =>
    if not na(trailing.top) and not na(trailing.bottom)
        premTop = trailing.top
        premBot = 0.95 * trailing.top + 0.05 * trailing.bottom
        eqTop   = 0.525 * trailing.top + 0.475 * trailing.bottom
        eqBot   = 0.525 * trailing.bottom + 0.475 * trailing.top
        disTop  = 0.95 * trailing.bottom + 0.05 * trailing.top
        disBot  = trailing.bottom
        midIdx  = math.round(0.5 * (trailing.barIndex + last_bar_index))
        smc_drawZone(trailing.top,    midIdx,        premTop, premBot, "Premium",     premiumZoneColor2,        label.style_label_down)
        smc_drawZone(math.avg(trailing.top, trailing.bottom), last_bar_index, eqTop, eqBot, "Equilibrium", equilibriumZoneColorInput, label.style_label_left)
        smc_drawZone(trailing.bottom, midIdx,        disTop,  disBot,  "Discount",    discountZoneColor2,       label.style_label_up)

smc_highLowLabels() =>
    var label sthLabel    = na
    var label stlLabel    = na
    var label comboLabel  = na
    var int   lastSthTime = na
    var int   lastStlTime = na
    sthChanged = trailing.lastTopTime    != lastSthTime
    stlChanged = trailing.lastBottomTime != lastStlTime
    if not na(trailing.top) and not na(trailing.bottom)
        if trailing.lastTopTime == trailing.lastBottomTime
            if sthChanged or stlChanged
                label.delete(sthLabel)
                label.delete(stlLabel)
                label.delete(comboLabel)
                comboLabel  := label.new(chart.point.new(trailing.barTime, na, trailing.top), "STH | STL",
                     xloc=xloc.bar_time, style=label.style_label_down,
                     color=swingBearishColor, textcolor=color.white, size=size.small)
                lastSthTime := trailing.lastTopTime
                lastStlTime := trailing.lastBottomTime
        else
            if sthChanged
                label.delete(sthLabel)
                label.delete(comboLabel)
                sthLabel    := label.new(chart.point.new(trailing.barTime, na, trailing.top), "STH",
                     xloc=xloc.bar_time, style=label.style_label_down,
                     color=swingBearishColor, textcolor=color.white, size=size.small)
                lastSthTime := trailing.lastTopTime
            if stlChanged
                label.delete(stlLabel)
                label.delete(comboLabel)
                stlLabel    := label.new(chart.point.new(trailing.barTime, na, trailing.bottom), "STL",
                     xloc=xloc.bar_time, style=label.style_label_up,
                     color=swingBullishColor, textcolor=color.white, size=size.small)
                lastStlTime := trailing.lastBottomTime

if enableSMC
    // Update trailing extremes every bar for accurate Premium/Discount zones & Strong/Weak High/Low
    if showHighLowSwingsInput or showPremiumDiscountZonesInput
        trailing.top            := math.max(high, nz(trailing.top,  high))
        trailing.bottom         := math.min(low,  nz(trailing.bottom, low))
        trailing.lastTopTime    := trailing.top    == high ? time : trailing.lastTopTime
        trailing.lastBottomTime := trailing.bottom == low  ? time : trailing.lastBottomTime

    smc_getStructure(swingsLengthInput)
    smc_getStructure(equalHighsLowsLengthInput, eqHL=true)
    smc_getStructure(5, internal=true)
    smc_displayStructure(internal=false)
    smc_displayStructure(internal=true)
    smc_deleteOBs(internal=false)
    smc_deleteOBs(internal=true)

    if barstate.islastconfirmedhistory or barstate.islast
        smc_drawOBs(internal=false)
        smc_drawOBs(internal=true)

    if showFairValueGapsInput
        smc_deleteFVGs()
        smc_drawFVGs()
    if showDailyLevelsInput
        smc_drawLevels("D", timeframe.isdaily,   dailyLevelsStyleInput,   dailyLevelsColorInput)
    if showWeeklyLevelsInput
        smc_drawLevels("W", timeframe.isweekly,  weeklyLevelsStyleInput,  weeklyLevelsColorInput)
    if showMonthlyLevelsInput
        smc_drawLevels("M", timeframe.ismonthly, monthlyLevelsStyleInput, monthlyLevelsColorInput)
    if showPremiumDiscountZonesInput
        smc_premiumDiscount()
    if showHighLowSwingsInput
        smc_highLowLabels()

alertcondition(enableSMC and currentAlerts.internalBullishBOS,   "Internal Bullish BOS",   "Internal Bullish BOS")
alertcondition(enableSMC and currentAlerts.internalBearishBOS,   "Internal Bearish BOS",   "Internal Bearish BOS")
alertcondition(enableSMC and currentAlerts.internalBullishCHoCH, "Internal Bullish CHoCH", "Internal Bullish CHoCH")
alertcondition(enableSMC and currentAlerts.internalBearishCHoCH, "Internal Bearish CHoCH", "Internal Bearish CHoCH")
alertcondition(enableSMC and currentAlerts.swingBullishBOS,      "Swing Bullish BOS",      "Swing Bullish BOS")
alertcondition(enableSMC and currentAlerts.swingBearishBOS,      "Swing Bearish BOS",      "Swing Bearish BOS")
alertcondition(enableSMC and currentAlerts.swingBullishCHoCH,    "Swing Bullish CHoCH",    "Swing Bullish CHoCH")
alertcondition(enableSMC and currentAlerts.swingBearishCHoCH,    "Swing Bearish CHoCH",    "Swing Bearish CHoCH")
alertcondition(enableSMC and currentAlerts.equalHighs,           "Equal Highs",            "Equal Highs")
alertcondition(enableSMC and currentAlerts.equalLows,            "Equal Lows",             "Equal Lows")
alertcondition(enableSMC and currentAlerts.bullishFairValueGap,  "Bullish FVG",            "Bullish FVG")
alertcondition(enableSMC and currentAlerts.bearishFairValueGap,  "Bearish FVG",            "Bearish FVG")

// ═══════════════════════════════════════════════════════════
//  ④  MARCO POLO TOP DETECTIVE
// ═══════════════════════════════════════════════════════════

// ── State variables ──
var float marco_pLast      = 0.0
var int   marco_iLast      = 0
var bool  marco_isHighLast = false

// ── Deviation threshold (ATR-based) ──
marco_devThreshold = ta.atr(10) / close * 100 * marco_deviation

// ── Custom pivot detection ──
marco_pivots(src, length, isHigh) =>
    c   = nz(src[length])
    ok  = true
    for i = 0 to length
        if (isHigh and src[i] > c) or (not isHigh and src[i] < c)
            ok := false
            break
    pivotIndex = ok ? bar_index[length] : na
    pivotPrice = ok ? c : na
    [pivotIndex, pivotPrice]

[marco_iH, marco_pH] = marco_pivots(high, marco_depth, true)
[marco_iL, marco_pL] = marco_pivots(low,  marco_depth, false)

marco_calcDev(base, price) => 100 * (price - base) / price

// ── BBands for reversal confirmation ──
marco_basis = ta.sma(close, marco_bblength)
marco_dev2  = marco_bbmult * ta.stdev(close, marco_bblength)
marco_upper = marco_basis + marco_dev2
marco_lower = marco_basis - marco_dev2

// ── Pivot logic ──
bool marco_isTopPlot    = false
bool marco_isBottomPlot = false

if not na(marco_iH) or not na(marco_iL)
    marco_foundIndex = not na(marco_iH) ? marco_iH : marco_iL
    marco_foundPrice = not na(marco_iH) ? marco_pH : marco_pL
    marco_isHigh     = not na(marco_iH)
    marco_d          = marco_calcDev(marco_pLast, marco_foundPrice)
    if marco_isHighLast == marco_isHigh
        if marco_isHighLast ? marco_foundPrice > marco_pLast : marco_foundPrice < marco_pLast
            marco_iLast := marco_foundIndex
            marco_pLast := marco_foundPrice
    else
        if math.abs(marco_d) > marco_devThreshold or marco_pLast == 0.0
            if marco_isHigh
                marco_isTopPlot := true
            else
                marco_isBottomPlot := true
            marco_iLast      := marco_foundIndex
            marco_pLast      := marco_foundPrice
            marco_isHighLast := marco_isHigh

// ── Reversal bar signals (BBands 3-bar pattern) ──
marco_bullReversal = low[2]  < marco_lower[2] and close[2] < open[2] and
     close[1] > marco_lower[1] and close[1] > open[1] and close > high[1]
marco_bearReversal = high[2] > marco_upper[2] and close[2] > open[2] and
     close[1] < marco_upper[1] and close[1] < open[1] and close < low[1]

marco_isTop    = marco_isTopPlot    or marco_bearReversal
marco_isBottom = marco_isBottomPlot or marco_bullReversal

marco_textCol = marco_white ? color.white : color.black

// ── Plot shapes — using plotshape-equivalent: yloc.abovebar / yloc.belowbar ──
// Top Pivot & Bot Pivot (offset by depth bars back)
if enableMarco and marco_isTopPlot
    label.new(bar_index - marco_depth, high[marco_depth], "Top Pivot",
         style=label.style_label_down, yloc=yloc.abovebar,
         color=color.red, textcolor=marco_textCol, size=size.small)
if enableMarco and marco_isBottomPlot
    label.new(bar_index - marco_depth, low[marco_depth], "Bot Pivot",
         style=label.style_label_up, yloc=yloc.belowbar,
         color=color.new(#1616A7, 0), textcolor=marco_textCol, size=size.small)

// Bear Rev & Bull Rev (current bar — no offset)
if enableMarco and marco_bearReversal
    label.new(bar_index, high, "Bear Rev",
         style=label.style_label_down, yloc=yloc.abovebar,
         color=color.orange, textcolor=marco_textCol, size=size.tiny)
if enableMarco and marco_bullReversal
    label.new(bar_index, low, "Bull Rev",
         style=label.style_label_up, yloc=yloc.belowbar,
         color=color.lime, textcolor=color.black, size=size.tiny)

alertcondition(enableMarco and marco_isTop,    "Marco Top Detected",    "Marco Top Detector: Top/Bearish Reversal identified.")
alertcondition(enableMarco and marco_isBottom, "Marco Bottom Detected", "Marco Top Detector: Bottom/Bullish Reversal identified.")

// ═══════════════════════════════════════════════════════════
//  ⑤  ZIGZAG ENGINE
// ═══════════════════════════════════════════════════════════

// Line style helper (ZigZag)
zzg_lineStyle(string s) =>
    s == "----" ? line.style_dashed : s == "····" ? line.style_dotted : line.style_solid

// ── Swing ZigZag state (top-level) ──
var line           zzg_line  = na
var array<label>   zzg_lblsH = array.new<label>()
var array<label>   zzg_lblsL = array.new<label>()
var line           zzg_stem  = na
var int   zzg_dir   = 0
var float zzg_pivH  = na
var int   zzg_pivHT = na
var float zzg_pivL  = na
var int   zzg_pivLT = na
var float zzg_prevH = na
var float zzg_prevL = na
var int   zzg_flipB  = 0
var int   zzg_lastHB = -1
var int   zzg_lastLB = -1
var string zzg_lastHT = ""
var string zzg_lastLT = ""

// ── Internal ZigZag state (top-level — Pine v6 requires var outside if blocks) ──
var line           zzgi_line  = na
var array<label>   zzgi_lblsH = array.new<label>()
var array<label>   zzgi_lblsL = array.new<label>()
var line           zzgi_stem  = na
var int   zzgi_dir   = 0
var float zzgi_pivH  = na
var int   zzgi_pivHT = na
var float zzgi_pivL  = na
var int   zzgi_pivLT = na
var float zzgi_prevH = na
var float zzgi_prevL = na
var int   zzgi_flipB  = 0
var int   zzgi_lastHB = -1
var int   zzgi_lastLB = -1
var string zzgi_lastHT = ""
var string zzgi_lastLT = ""

zzg_hi = ta.highest(high, zzgDepth)
zzg_lo = ta.lowest(low,   zzgDepth)

if enableZZ and showZZG
    _isH = high >= zzg_hi
    _isL = low  <= zzg_lo
    if zzg_dir == 0
        if _isH
            zzg_dir   := 1
            zzg_pivH  := high
            zzg_pivHT := time
            zzg_line  := line.new(time, high, time, high, xloc=xloc.bar_time,
                 color=zzgBullColor, width=zzgWidth, style=zzg_lineStyle(zzgStyle))
            if zzgShowLabels
                if zzg_lblsH.size() >= 2
                    label.delete(zzg_lblsH.shift())
                zzg_lblsH.push(label.new(chart.point.new(time, na, high), "HH",
                     xloc.bar_time, color=zzgBearColor, textcolor=color.black,
                     style=label.style_label_lower_left, size=zzgLabelSize))
                zzg_lastHB := bar_index
                zzg_lastHT := "HH"
        else if _isL
            zzg_dir   := -1
            zzg_pivL  := low
            zzg_pivLT := time
            zzg_line  := line.new(time, low, time, low, xloc=xloc.bar_time,
                 color=zzgBearColor, width=zzgWidth, style=zzg_lineStyle(zzgStyle))
            if zzgShowLabels
                if zzg_lblsL.size() >= 2
                    label.delete(zzg_lblsL.shift())
                zzg_lblsL.push(label.new(chart.point.new(time, na, low), "LL",
                     xloc.bar_time, color=zzgBullColor, textcolor=color.black,
                     style=label.style_label_upper_left, size=zzgLabelSize))
                zzg_lastLB := bar_index
                zzg_lastLT := "LL"
    else if zzg_dir == 1
        if _isH and (high > zzg_pivH or bar_index - zzg_flipB < zzgBackstep)
            zzg_pivH  := high
            zzg_pivHT := time
            line.set_xy2(zzg_line, time, high)
            if zzgShowLabels
                if zzg_lblsH.size() > 0
                    label.delete(zzg_lblsH.pop())
                _zzg_htxt = na(zzg_prevH) ? "HH" : (high >= zzg_prevH ? "HH" : "LH")
                zzg_lblsH.push(label.new(chart.point.new(time, na, high),
                     _zzg_htxt,
                     xloc.bar_time, color=zzgBearColor, textcolor=color.black,
                     style=label.style_label_lower_left, size=zzgLabelSize))
                zzg_lastHB := bar_index
                zzg_lastHT := _zzg_htxt
        else if _isL and bar_index - zzg_flipB >= zzgBackstep
            zzg_prevH  := zzg_pivH
            zzg_dir    := -1
            zzg_flipB  := bar_index
            zzg_pivL   := low
            zzg_pivLT  := time
            zzg_line   := line.new(zzg_pivHT, zzg_pivH, time, low, xloc=xloc.bar_time,
                 color=zzgBearColor, width=zzgWidth, style=zzg_lineStyle(zzgStyle))
            if zzgShowLabels
                _zzg_ltxt = na(zzg_prevL) ? "LL" : (low <= zzg_prevL ? "LL" : "HL")
                if zzg_lblsL.size() > 0
                    label.delete(zzg_lblsL.pop())
                if zzg_lastHB == bar_index and zzg_lblsH.size() > 0
                    label.delete(zzg_lblsH.pop())
                zzg_lblsL.push(label.new(chart.point.new(time, na, low),
                     _zzg_ltxt,
                     xloc.bar_time, color=zzgBullColor, textcolor=color.black,
                     style=label.style_label_upper_left, size=zzgLabelSize))
                zzg_lastLB := bar_index
                zzg_lastLT := _zzg_ltxt
    else if zzg_dir == -1
        if _isL and (low < zzg_pivL or bar_index - zzg_flipB < zzgBackstep)
            zzg_pivL  := low
            zzg_pivLT := time
            line.set_xy2(zzg_line, time, low)
            if zzgShowLabels
                if zzg_lblsL.size() > 0
                    label.delete(zzg_lblsL.pop())
                _zzg_ltxt2 = na(zzg_prevL) ? "LL" : (low <= zzg_prevL ? "LL" : "HL")
                zzg_lblsL.push(label.new(chart.point.new(time, na, low),
                     _zzg_ltxt2,
                     xloc.bar_time, color=zzgBullColor, textcolor=color.black,
                     style=label.style_label_upper_left, size=zzgLabelSize))
                zzg_lastLB := bar_index
                zzg_lastLT := _zzg_ltxt2
        else if _isH and bar_index - zzg_flipB >= zzgBackstep
            zzg_prevL  := zzg_pivL
            zzg_dir    := 1
            zzg_flipB  := bar_index
            zzg_pivH   := high
            zzg_pivHT  := time
            zzg_line   := line.new(zzg_pivLT, zzg_pivL, time, high, xloc=xloc.bar_time,
                 color=zzgBullColor, width=zzgWidth, style=zzg_lineStyle(zzgStyle))
            if zzgShowLabels
                _zzg_htxt2 = na(zzg_prevH) ? "HH" : (high >= zzg_prevH ? "HH" : "LH")
                if zzg_lblsH.size() > 0
                    label.delete(zzg_lblsH.pop())
                if zzg_lastLB == bar_index and zzg_lblsL.size() > 0
                    label.delete(zzg_lblsL.pop())
                zzg_lblsH.push(label.new(chart.point.new(time, na, high),
                     _zzg_htxt2,
                     xloc.bar_time, color=zzgBearColor, textcolor=color.black,
                     style=label.style_label_lower_left, size=zzgLabelSize))
                zzg_lastHB := bar_index
                zzg_lastHT := _zzg_htxt2

// ── Internal ZigZag ──
zzgi_hi = ta.highest(high, zzgiDepth)
zzgi_lo = ta.lowest(low,   zzgiDepth)

if enableZZ and showZZG and zzgShowInternal
    _iH = high >= zzgi_hi
    _iL = low  <= zzgi_lo
    if zzgi_dir == 0
        if _iH
            zzgi_dir   := 1
            zzgi_pivH  := high
            zzgi_pivHT := time
            zzgi_line  := line.new(time, high, time, high, xloc=xloc.bar_time,
                 color=zzgiBullColor, width=zzgiWidth, style=zzg_lineStyle(zzgiStyle))
            if zzgShowLabels
                if zzgi_lblsH.size() >= 2
                    label.delete(zzgi_lblsH.shift())
                zzgi_lblsH.push(label.new(chart.point.new(time, na, high), "HH",
                     xloc.bar_time, color=zzgiBearColor, textcolor=color.black,
                     style=label.style_label_lower_right, size=size.tiny))
                zzgi_lastHB := bar_index
                zzgi_lastHT := "HH"
        else if _iL
            zzgi_dir   := -1
            zzgi_pivL  := low
            zzgi_pivLT := time
            zzgi_line  := line.new(time, low, time, low, xloc=xloc.bar_time,
                 color=zzgiBearColor, width=zzgiWidth, style=zzg_lineStyle(zzgiStyle))
            if zzgShowLabels
                if zzgi_lblsL.size() >= 2
                    label.delete(zzgi_lblsL.shift())
                zzgi_lblsL.push(label.new(chart.point.new(time, na, low), "LL",
                     xloc.bar_time, color=zzgiBullColor, textcolor=color.black,
                     style=label.style_label_upper_right, size=size.tiny))
                zzgi_lastLB := bar_index
                zzgi_lastLT := "LL"
    else if zzgi_dir == 1
        if _iH and (high > zzgi_pivH or bar_index - zzgi_flipB < zzgiBackstep)
            zzgi_pivH  := high
            zzgi_pivHT := time
            line.set_xy2(zzgi_line, time, high)
            if zzgShowLabels
                if zzgi_lblsH.size() > 0
                    label.delete(zzgi_lblsH.pop())
                _zzgi_htxt = na(zzgi_prevH) ? "HH" : (high >= zzgi_prevH ? "HH" : "LH")
                zzgi_lblsH.push(label.new(chart.point.new(time, na, high),
                     _zzgi_htxt,
                     xloc.bar_time, color=zzgiBearColor, textcolor=color.black,
                     style=label.style_label_lower_right, size=size.tiny))
                zzgi_lastHB := bar_index
                zzgi_lastHT := _zzgi_htxt
        else if _iL and bar_index - zzgi_flipB >= zzgiBackstep
            zzgi_prevH  := zzgi_pivH
            zzgi_dir    := -1
            zzgi_flipB  := bar_index
            zzgi_pivL   := low
            zzgi_pivLT  := time
            zzgi_line   := line.new(zzgi_pivHT, zzgi_pivH, time, low, xloc=xloc.bar_time,
                 color=zzgiBearColor, width=zzgiWidth, style=zzg_lineStyle(zzgiStyle))
            if zzgShowLabels
                _zzgi_ltxt = na(zzgi_prevL) ? "LL" : (low <= zzgi_prevL ? "LL" : "HL")
                if zzgi_lblsL.size() > 0
                    label.delete(zzgi_lblsL.pop())
                if zzgi_lastHB == bar_index and zzgi_lblsH.size() > 0
                    label.delete(zzgi_lblsH.pop())
                zzgi_lblsL.push(label.new(chart.point.new(time, na, low),
                     _zzgi_ltxt,
                     xloc.bar_time, color=zzgiBullColor, textcolor=color.black,
                     style=label.style_label_upper_right, size=size.tiny))
                zzgi_lastLB := bar_index
                zzgi_lastLT := _zzgi_ltxt
    else if zzgi_dir == -1
        if _iL and (low < zzgi_pivL or bar_index - zzgi_flipB < zzgiBackstep)
            zzgi_pivL  := low
            zzgi_pivLT := time
            line.set_xy2(zzgi_line, time, low)
            if zzgShowLabels
                if zzgi_lblsL.size() > 0
                    label.delete(zzgi_lblsL.pop())
                _zzgi_ltxt2 = na(zzgi_prevL) ? "LL" : (low <= zzgi_prevL ? "LL" : "HL")
                zzgi_lblsL.push(label.new(chart.point.new(time, na, low),
                     _zzgi_ltxt2,
                     xloc.bar_time, color=zzgiBullColor, textcolor=color.black,
                     style=label.style_label_upper_right, size=size.tiny))
                zzgi_lastLB := bar_index
                zzgi_lastLT := _zzgi_ltxt2
        else if _iH and bar_index - zzgi_flipB >= zzgiBackstep
            zzgi_prevL  := zzgi_pivL
            zzgi_dir    := 1
            zzgi_flipB  := bar_index
            zzgi_pivH   := high
            zzgi_pivHT  := time
            zzgi_line   := line.new(zzgi_pivLT, zzgi_pivL, time, high, xloc=xloc.bar_time,
                 color=zzgiBullColor, width=zzgiWidth, style=zzg_lineStyle(zzgiStyle))
            if zzgShowLabels
                _zzgi_htxt2 = na(zzgi_prevH) ? "HH" : (high >= zzgi_prevH ? "HH" : "LH")
                if zzgi_lblsH.size() > 0
                    label.delete(zzgi_lblsH.pop())
                if zzgi_lastLB == bar_index and zzgi_lblsL.size() > 0
                    label.delete(zzgi_lblsL.pop())
                zzgi_lblsH.push(label.new(chart.point.new(time, na, high),
                     _zzgi_htxt2,
                     xloc.bar_time, color=zzgiBearColor, textcolor=color.black,
                     style=label.style_label_lower_right, size=size.tiny))
                zzgi_lastHB := bar_index
                zzgi_lastHT := _zzgi_htxt2
````
