# Undertow [vole]

- url: https://www.tradingview.com/script/kyj889z9-Undertow-vole/
- type: indicator
- pine_id: PUB;2071f39f5654471d84d7583a7133e562
- version: 1.0

## Description

[b]OVERVIEW[/b]

Undertow looks at who is moving price rather than where price is going. It keeps two volume readings apart: the crowd, read on the loud bars where volume expands, and the quiet money, read on the calm bars where volume contracts. The upside event is the bar on which the quiet side turns decisively up while the crowd is still on the selling side. The downside event is the mirror and is off by default. The core computation follows the Koncorde indicator on TradingView, credited to its author.


[b]HOW IT WORKS[/b]

Bar by bar, the indicator builds two running price indices. One moves only on bars where volume rises compared with the bar before, which is the crowd. The other moves only on bars where volume falls, which is the quiet money. Each is compared with its own smoothed average and scaled to its recent range. The crowd reading is then added to a blended trend reading made from a momentum measure, a volume-weighted momentum measure, the position of price inside a wide band and a stochastic position. The upside event is registered when the quiet reading crosses above the average of the trend reading while it is already positive and the crowd reading is still negative. The downside event needs the quiet reading to cross below zero while the crowd is above both the trend reading and its average. Three filters thin the reports. The strength filter asks the quiet reading to be below the trend average on the downside. The candle filter asks the bar to close in the event's direction. The position guard keeps a side quiet after it has fired until the other side fires. A profile sets how much history is weighed. Where a chart carries no volume, the bar's own range is used instead.


[image]https://www.tradingview.com/x/7c7HcpGK/[/image]
[i]An L marker on a 15m Bitcoin chart, on the bar where the quiet side of volume turns up while the crowd is still selling.[/i]


[b]WHAT YOU'LL SEE ON THE CHART[/b]

[list]
[*][b]Signal markers[/b] — a filled L label below the bar for the upside event, and a filled S label above the bar for the downside event when it is switched on. State-change markers, not instructions.
[/list]

[image]https://www.tradingview.com/x/aV2AZQex/[/image]
[i]The same marker on a 15m Ethereum chart. Events are reported rarely, with long quiet stretches between markers.[/i]


[b]BEST FOR[/b]

[b]Markets:[/b] Crypto, US Stocks, Commodity.
[b]Timeframes:[/b] Crypto 15m–1D; US Stocks 1h–1D; Commodity 1h.


[b]ALERTS[/b]

[list]
[*]Quiet accumulation confirmed
[*]Quiet distribution confirmed
[/list]


[b]OPEN SOURCE[/b]

The source code is open and published under the Mozilla Public License 2.0, so it can be read, checked and reused under those terms.


[b]CREDIT[/b]

The core computation follows Koncorde by Blai5, as published on TradingView by manboto. This script is a separate adaptation: it keeps the crowd and quiet-money readings apart and reports one event per state change.


[b]ACCESS[/b]

Free, open-source script.


[b]DISCLAIMER[/b]

[i]This indicator is a technical analysis tool, not investment advice. The author is not a registered investment adviser, broker or dealer. Nothing here is a recommendation to buy, sell or hold any instrument. What you see on the chart is the output of a calculation you configured. Any decision you take from it is yours. Past behaviour of an indicator — including anything you observe in historical bars or in a backtest, which is a simulation — does not indicate future results. Trading carries a real risk of loss, including your entire capital. Charting uses TradingView® technology. TradingView is unaffiliated with the author. For educational purposes only. Not investment advice.[/i]

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════
//  Undertow
//  v1.0.1 · 2026-10-01
//  Open source, Mozilla Public License 2.0
//
//  Measures : Who is moving price, not where price is going. Two volume
//             readings are kept apart — the crowd, read on the loud bars
//             where volume expands, and the quiet money, read on the calm
//             bars where volume contracts. The upside event is the bar on
//             which the quiet side turns decisively up while the crowd is
//             still on the selling side; the downside event is the bar on
//             which the quiet side turns to selling while the crowd is still
//             buying.
//  Not      : This is not investment advice.
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("Undertow [vole]", shorttitle="Undertow [vole]", overlay=true, behind_chart=false, max_bars_back=300)

// ── THEME ─────────────────────────────────────────────────────
// [§3.1] design tokens — do not edit per-indicator.
C_UP       = #26A69A
C_DOWN     = #EF5350
C_NEUTRAL  = #787B86
C_ACCENT   = #F0B90B
C_INFO     = #2962FF
C_TEXT     = #D1D4DC
C_TEXT_DIM = #787B86
C_BG       = #131722
C_BORDER   = #2A2E39

// [§4.1] Group names and their order are fixed. Unused groups are omitted.
G_CORE   = "◆━━━━━━━ Calculation ━━━━━━━◆"
G_FILTER = "◆━━━━━━━ Filters ━━━━━━━◆"
G_VISUAL = "◆━━━━━━━ Appearance ━━━━━━━◆"
G_ALERT  = "◆━━━━━━━ Alerts ━━━━━━━◆"

// [§5.1] Primary pair — NEW names, same grammar (noun + past verb); not yet
//        in the §5.1 dictionary, flagged for operator approval.
//        Source: "AL" (kalabalık satarken büyük para alıma geçti),
//                "ÇIK" (kalabalık alırken büyük para satışa geçti).
A_ACCUM = "Quiet accumulation confirmed"
A_DISTR = "Quiet distribution confirmed"

// ── INPUTS ────────────────────────────────────────────────────
// [§4.4.1] exposure: preset — no numeric input. The Profile dropdown scales
//          the lookback windows as one set; every other parameter is fixed
//          in CALC (operator: "parametreleri değiştirmesin").

i_useHA   = input.bool(false, "Use Heikin Ashi Candles", group = G_CORE,
     tooltip = "Feeds the whole engine with Heikin Ashi candles instead of regular ones, whatever candle type the chart itself shows. Both volume readings, the trend blend and its average all read the same smoothed candles.")
i_profile = input.string("Default", "Profile", group = G_CORE,
     options = ["Day Trade", "Default", "Investor"],
     tooltip = "Sets how much history the engine weighs. Day Trade uses the shortest stretch and reports most often, for intraday charts. Default is the setting the engine was built on. Investor uses the longest stretch and reports least often, for daily charts and above.")

// Filters — direction switches change which side is reported. [§4.3.1]
i_trackUp   = input.bool(true, "Track Upside", group = G_FILTER,
     tooltip = "Reports the bar on which the quiet side of volume turns decisively up while the crowd is still on the selling side. Spot use keeps only this switch on.")
i_trackDown = input.bool(false, "Track Downside", group = G_FILTER,
     tooltip = "Reports the bar on which the quiet side of volume turns to selling while the crowd is still buying. Off by default; the source treated this as a caution for an open upside position rather than a signal of its own.")
// [§0.3 step 4] Noise filters — operator request 2026-10-01. All three off
//   reproduces the source's signal set exactly.
i_useStrength = input.bool(true, "Use Strength Filter", group = G_FILTER,
     tooltip = "A downside event must also see the quiet side below the trend average, not merely below zero. The upside rule already demands this by construction, so this filter only thins the downside.")
i_useCandle   = input.bool(true, "Use Candle Filter", group = G_FILTER,
     tooltip = "The signal bar must close in the direction of the event: up for an upside event, down for a downside event. Reads the engine's candles, so Heikin Ashi when that switch is on.")
i_useGuard    = input.bool(true, "Use Position Guard", group = G_FILTER,
     tooltip = "After an event on one side, that side stays quiet until the other side fires. Stops the same side repeating while nothing has changed. The other side resets the guard even when it is not tracked.")

// Appearance — nothing here may change the signal. [§4.2]
i_showMarkers = input.bool(true, "Show Signal Markers", group = G_VISUAL,
     tooltip = "Draws the L / S label under or over the bar where the event was confirmed.")
i_colUp       = input.color(C_UP, "Bullish Color", group = G_VISUAL)
i_colDown     = input.color(C_DOWN, "Bearish Color", group = G_VISUAL)

// Alerts
i_alertOn = input.string("Bar Close", "Alert On", group = G_ALERT,
     options = ["Bar Close", "Intrabar"],
     tooltip = "Bar Close waits for the bar to finish and cannot change afterwards. Intrabar fires earlier and can revert before the bar closes.")

// ── CALC ──────────────────────────────────────────────────────

// [§1.5 L3] Fixed settings — the source's defaults. Never published.
BB_MULT  = 4.0          // band width multiplier (source: bbMult) — shape parameter, not scaled
ST_SM    = 1            // stochastic smoothing (source: stSm) — shape parameter, not scaled
// Fixed behaviour switches, at the source's defaults:
//   RSI/BB/Stokastik kaynağı = close, MFI kaynağı = close → fixed to the engine's
//     close (input.source is incompatible with full-HA, §2.7-5).
//   Trend MA tipi = EMA → only EMA is carried.

// [§1.5 L3] Profile map — never published. One scale over the whole window
//   set (momentum lengths, band length, stochastic length, trend average,
//   quiet/loud volume index smoothing and its ranking range). Only Default
//   is operator-given.
//   Day Trade : ×0.5 — PROVISIONAL / ÖLÇÜLMEDİ, agent proposal 2026-10-01
//   Default   : ×1   — OPERATÖR VERDİ 2026-10-01 (source defaults)
//   Investor  : ×2   — PROVISIONAL / ÖLÇÜLMEDİ, agent proposal 2026-10-01
//   Single-line ternaries keep the `simple int` quality (§2.6).
LEN_RM   = i_profile == "Day Trade" ? 29 : i_profile == "Investor" ? 114 : 57   // RSI & MFI length (source: lenRM 57)
BB_LEN   = i_profile == "Day Trade" ? 20 : i_profile == "Investor" ? 78  : 39   // band length (source: bbLen 39)
ST_LEN   = i_profile == "Day Trade" ? 17 : i_profile == "Investor" ? 68  : 34   // stochastic length (source: stLen 34)
MA_LEN   = i_profile == "Day Trade" ? 13 : i_profile == "Investor" ? 52  : 26   // trend average length (source: maLen 26)
VI_LEN   = i_profile == "Day Trade" ? 16 : i_profile == "Investor" ? 62  : 31   // volume index smoothing (source: viLen 31)
VI_RANGE = i_profile == "Day Trade" ? 29 : i_profile == "Investor" ? 116 : 58   // volume index min-max range (source: viRange 58)

// [§2.7] Heikin Ashi — all or nothing. Every price the engine reads comes
//   from this one call: the close for the momentum blend and the volume
//   indices, highs / lows for the stochastic, open / close for the tick-
//   volume fallback. Volume itself is the same series under both tickers.
//   Chart TF, so no [1] offset is needed (§2.3-3). Signals are independent
//   of the chart's own candle type.
srcTicker = i_useHA ? ticker.heikinashi(syminfo.tickerid) : syminfo.tickerid
[cO, cH, cL, cC] = request.security(srcTicker, timeframe.period, [open, high, low, close], lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)

// Volume with tick-volume fallback — 1:1 with the source. Instruments that
// report no volume use the bar's own range in ticks instead.
float tick = syminfo.mintick
float rng  = cC - cO
var float s_tickRng = tick
s_tickRng := math.abs(rng) < tick ? s_tickRng : rng
float vol = nz(volume) == 0 ? math.abs(s_tickRng) / tick : volume

// Volume indices — hand-rolled, 1:1 with the source (so the fallback volume
// is honoured). The loud index advances only on bars where volume expands,
// the quiet index only on bars where volume contracts.
float roc = nz(cC[1]) != 0 ? (cC - cC[1]) / cC[1] : 0.0
var float s_loudIdx  = 1.0
var float s_quietIdx = 1.0
if vol > nz(vol[1])
    s_loudIdx := s_loudIdx * (1 + roc)
if vol < nz(vol[1])
    s_quietIdx := s_quietIdx * (1 + roc)

float loudMa   = ta.ema(s_loudIdx, VI_LEN)
float loudRng  = ta.highest(loudMa, VI_RANGE) - ta.lowest(loudMa, VI_RANGE)
float oscLoud  = loudRng != 0 ? (s_loudIdx - loudMa) * 100 / loudRng : 0.0

float quietMa  = ta.ema(s_quietIdx, VI_LEN)
float quietRng = ta.highest(quietMa, VI_RANGE) - ta.lowest(quietMa, VI_RANGE)
float oscQuiet = quietRng != 0 ? (s_quietIdx - quietMa) * 100 / quietRng : 0.0

// Trend blend — 1:1 with the source. ta.mfi reads the built-in volume, which
// is identical under the HA ticker; in the no-volume fallback it is na and
// takes the source's neutral 50.
float rsiV  = ta.rsi(cC, LEN_RM)
float mfiV  = nz(ta.mfi(cC, LEN_RM), 50)
float basis = ta.sma(cC, BB_LEN)
float dev   = BB_MULT * ta.stdev(cC, BB_LEN)
float oscBB = dev != 0 ? (cC - basis) / (2 * dev) * 100 : 0.0
float llS   = ta.lowest(cL, ST_LEN)
float hhS   = ta.highest(cH, ST_LEN)
float stoc  = ta.sma(hhS != llS ? 100 * (cC - llS) / (hhS - llS) : 50.0, ST_SM)

float trend    = (rsiV + mfiV + oscBB + stoc / 3) / 2
float bigMoney = oscQuiet            // quiet side (source: bigMoney = oscNeg)
float crowd    = trend + oscLoud     // loud side  (source: crowd = trend + oscPos)
float trendMa  = ta.ema(trend, MA_LEN)

// ── STATE / SIGNAL ────────────────────────────────────────────

// Non-repaint [§2.3-1]: with "Bar Close" a signal counts on a confirmed bar
// only, so it settles once and never revises. "Intrabar" trades that
// finality for speed.
confirmed = i_alertOn == "Bar Close" ? barstate.isconfirmed : true

// Upside — 1:1 with the source "AL": the quiet side crosses above the trend
// average while already positive, and the crowd is still negative.
rawUp   = ta.crossover(bigMoney, trendMa) and crowd < 0 and bigMoney > 0 and confirmed
// Downside — 1:1 with the source "ÇIK": the quiet side crosses below zero
// while the crowd is above both the trend and its average.
rawDown = ta.crossunder(bigMoney, 0) and crowd > trend and crowd > trendMa and confirmed

// [§0.3 step 4] Filters — each a toggle; off = source behaviour.
// Strength: the downside mirror of what the upside rule already contains
// (quiet side beyond the trend average, not just past zero).
// Candle: the signal bar closes in the event's direction, on the engine's candles.
fUp   = rawUp   and (not i_useCandle or cC > cO)
fDown = rawDown and (not i_useStrength or bigMoney < trendMa) and (not i_useCandle or cC < cO)

// Position guard: one latch for the last reported side. A side repeats only
// after the other side has fired. The latch moves on filtered events of
// either side regardless of the Track switches, so an untracked side still
// releases the guard; it moves on confirmed bars only (rawUp/rawDown carry
// `confirmed`), so it never revises.
var int s_side = 0
gUp   = fUp   and (not i_useGuard or s_side != 1)
gDown = fDown and (not i_useGuard or s_side != -1)
if gUp
    s_side := 1
if gDown
    s_side := -1

// [§4.3.1] Report by side. Undertow has no persistent up/down state — a
//   signal is a point event and nothing "ends" — so §4.3.1-3's exit event
//   does not apply; an untracked side is simply not reported. Recorded in
//   identity.yaml.
sigUp   = gUp   and i_trackUp
sigDown = gDown and i_trackDown

// ── PLOT ──────────────────────────────────────────────────────
// [§3.2] Output budget: 2 primary shapes + 2 alertcondition = 4. [§2.4]
//   The source's two data-window plots (Büyük para / Kalabalık) are not
//   drawn: each is an intermediate score (§1.5.2-3).

// PRIMARY signals — filled label carrying the direction letter. [§3.5.1]
//   L / S are permitted on the indicator's own surface only (manifesto §4.4.1).
//   plotshape, not label.new: no object cap, no cleanup, no extra cost. [§2.4]
plotshape(i_showMarkers and sigUp, title = A_ACCUM, style = shape.labelup,
          location = location.belowbar, color = i_colUp, textcolor = C_TEXT,
          text = "L", size = size.small)
plotshape(i_showMarkers and sigDown, title = A_DISTR, style = shape.labeldown,
          location = location.abovebar, color = i_colDown, textcolor = C_TEXT,
          text = "S", size = size.small)

// ── DASHBOARD ─────────────────────────────────────────────────
// None. The source's table carried hit rate and average forward return per
// signal against an all-bars baseline (performance figures — §3.3, manifesto
// §6). It belongs in a private research copy.

// ── ALERTS ────────────────────────────────────────────────────
// [§3.5.1-3] Primary pair first.
alertcondition(sigUp,   title = A_ACCUM, message = "{{ticker}} {{interval}} — quiet accumulation confirmed")
alertcondition(sigDown, title = A_DISTR, message = "{{ticker}} {{interval}} — quiet distribution confirmed")

// [§5.3] One payload shape across every indicator. The L / S letters
//        never appear here — manifesto §4.4.1. vals is empty: both volume
//        readings and the trend blend are intermediate scores (§1.5.2-4) and
//        nothing else is drawn. px is the chart's real close, not the Heikin
//        Ashi close (§5.3).
f_payload(string ev, string st) =>
    string j = '{"src":"tv","ind":"undertow","ver":"1.0.0"'
    j := j + ',"ev":"' + ev + '"'
    j := j + ',"sym":"' + syminfo.tickerid + '"'
    j := j + ',"tf":"' + timeframe.period + '"'
    j := j + ',"t":"' + str.tostring(time_close) + '"'
    j := j + ',"px":"' + str.tostring(close, format.mintick) + '"'
    j := j + ',"state":"' + st + '"'
    j := j + ',"vals":{}}'
    j

alertFreq = i_alertOn == "Bar Close" ? alert.freq_once_per_bar_close : alert.freq_once_per_bar

if sigUp
    alert(f_payload(A_ACCUM, "up"), alertFreq)
if sigDown
    alert(f_payload(A_DISTR, "down"), alertFreq)
````
