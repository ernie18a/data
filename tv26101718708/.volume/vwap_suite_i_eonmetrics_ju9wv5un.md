# VWAP Suite I EonMetrics

- url: https://www.tradingview.com/script/jU9wV5un-VWAP-Suite-I-EonMetrics/
- type: indicator
- pine_id: PUB;f4bfc5331162442d908d753bb3c80a0c
- version: 1.0

## Description

VWAP Suite

VWAP Suite plots three independently anchored Volume-Weighted Average Price lines — Session, Weekly and Monthly — with volume-weighted deviation bands and the previous period's VWAP close kept on the chart as a reference level. Everything is computed from first principles at each anchor, so every line resets exactly where its period starts.

https://www.tradingview.com/x/xkoOt8Zq/

🔶[b]WHAT VWAP IS[/b]

VWAP is the average price of the period weighted by how much volume traded at each price. It answers one question: "what is the fair average price actually paid since the anchor?" That is why institutional execution desks benchmark fills against it, and why price so often reacts when it returns there — it is the level where the average participant in the period is at break-even. Above the VWAP the average buyer of the period is in profit; below it, under water.

🔶[b]WHAT IT DOES[/b]

Three anchors — Session (resets each trading day), Weekly and Monthly VWAP, each with its own toggle and color. Intraday traders typically work with Session, swing traders add Weekly, and Monthly serves as the higher-timeframe fair-value reference. Anchors that make no sense on the current chart timeframe (e.g. a Session VWAP on a daily chart) hide themselves automatically.

Deviation bands — ±1σ, ±2σ and optional ±3σ around ONE chosen anchor. The deviation is volume-weighted and anchored to the same period as the VWAP it wraps — not a rolling standard deviation — which is the statistically consistent way to band a VWAP (the same math TradingView's built-in VWAP bands use). ±2σ is the classic stretched-price reference; the optional gradient fill keeps the zones readable without clutter.

Previous VWAP Close — the exact level where the Session (or Weekly) VWAP finished its previous period, drawn flat through the current one. The same idea as previous day high/low, but volume-based: yesterday's fair price is a natural magnet and reaction level for today. Few VWAP tools carry this level forward — it is the reason this suite exists.

🔶[b]HOW IT IS CALCULATED[/b]

From each anchor the script accumulates three sums bar by bar: volume × price, volume, and volume × price². VWAP = Σ(volume × price) / Σ(volume). The band deviation comes from the volume-weighted variance Σ(volume × price²)/Σ(volume) − VWAP². At every period rollover the previous VWAP value is captured first, then the sums reset to zero. Values only update on confirmed data — there is no repainting logic anywhere in the script.

🔶[b]ALERTS[/b]

Seven alert conditions: price crossing each of the three VWAPs, price touching the +2σ or −2σ band, and price crossing the previous Session or previous Week VWAP close.

🔶[b]HOW TO USE[/b]

1. Pick your anchors — Session for intraday, add Weekly for swing context.
2. Choose which anchor carries the deviation bands (Bands Around).
3. Keep Previous Session VWAP on — reactions at yesterday's fair price are the cleanest thing this tool shows.
4. Set alerts on the crossings you actually trade around.

🔶[b]SETTINGS[/b]

Source (price input, hlc3 default) · Anchors (Session / Weekly / Monthly, each with color) · Deviation Bands (anchor selector, ±1σ/±2σ/±3σ toggles, gradient fill) · Previous VWAP Close (Session / Weekly levels).

🔶[b]HONEST LIMITATIONS[/b]

On CFDs and spot forex the data feed reports TICK volume (number of price updates), not true traded volume. VWAP built on tick volume is still the standard practice on those markets and tracks the real one closely on liquid symbols, but you should know what feeds the math. On symbols with no volume data at all the script deliberately shows nothing rather than fake a line. VWAP is a descriptive average, not a prediction — this tool draws levels, it does not generate signals.

Part of the EonMetrics toolset.

## Source Code

````pine
//@version=6
indicator('EonMetrics VWAP Suite', 'VWAP Suite by EonMetrics', overlay=true)

// VWAP Suite by EonMetrics — anchored VWAPs + volume-weighted deviation bands
// (open-source).
//
// Three independent VWAPs, each anchored to its own period:
//   • Session VWAP — resets at each new trading day
//   • Weekly VWAP  — resets at each new week
//   • Monthly VWAP — resets at each new month
// plus:
//   • ±1σ / ±2σ / ±3σ deviation bands around ONE chosen anchor. The deviation is
//     VOLUME-WEIGHTED (computed from the same accumulators as the VWAP itself,
//     anchored to the same period) — not a rolling stdev.
//   • Previous VWAP Close — the level where the Session / Weekly VWAP finished its
//     previous period, drawn as a flat line through the current period. Works like
//     PDH/PDL but volume-based: a natural magnet/reaction level.
//
// All math is manual accumulation from the anchor (Σ vol·price, Σ vol, Σ vol·price²)
// — not ta.vwap — so every anchor resets exactly on its own rollover.
// No signals, no targets: levels only. Annotation, not advice.
//
// VOLUME NOTE: on CFDs and forex the exchange reports TICK volume, not real traded
// volume. VWAP built on tick volume is still widely used, but be aware of what
// feeds it. On symbols with NO volume at all the script shows nothing (na-guard).

// ═════════════════════════════════════════════════════════════════════════════
//  SOURCE
// ═════════════════════════════════════════════════════════════════════════════
grpSrc = 'Source'

srcInp = input.source(hlc3, 'Price Source', group=grpSrc,
  tooltip = 'Price fed into the VWAP accumulation. hlc3 (default) is the classic choice; close makes the VWAP hug the closing prints.')

// ═════════════════════════════════════════════════════════════════════════════
//  ANCHORS
// ═════════════════════════════════════════════════════════════════════════════
grpAnch = 'Anchors'

showD = input.bool(true, 'Session VWAP', inline='aD', group=grpAnch)
colD  = input.color(#2196f3, '', inline='aD', group=grpAnch,
  tooltip = 'Resets at each new trading day (the symbol\'s own session). The intraday workhorse.')

showW = input.bool(true, 'Weekly VWAP', inline='aW', group=grpAnch)
colW  = input.color(#ff9800, '', inline='aW', group=grpAnch,
  tooltip = 'Resets at each new week. Swing-trading anchor.')

showM = input.bool(false, 'Monthly VWAP', inline='aM', group=grpAnch)
colM  = input.color(#9c27b0, '', inline='aM', group=grpAnch,
  tooltip = 'Resets at each new month. Position/HTF anchor — most useful on H1 and above.')

// ═════════════════════════════════════════════════════════════════════════════
//  DEVIATION BANDS
// ═════════════════════════════════════════════════════════════════════════════
grpBand = 'Deviation Bands'

bandAnchor = input.string('Session', 'Bands Around', options=['Session', 'Weekly', 'Monthly'], group=grpBand,
  tooltip = 'Which anchor the ±σ bands wrap. Bands on one anchor only — all three at once is unreadable. The deviation is volume-weighted and anchored to the same period as the VWAP it wraps.')

show1 = input.bool(true,  '±1σ', inline='b1', group=grpBand)
show2 = input.bool(true,  '±2σ', inline='b1', group=grpBand)
show3 = input.bool(false, '±3σ', inline='b1', group=grpBand,
  tooltip = 'Which deviation levels to draw. ±2σ is the classic mean-reversion reference; ±3σ marks statistically stretched prints.')

showFill = input.bool(true, 'Gradient Fill Between Bands', group=grpBand,
  tooltip = 'Soft background shading across the band zones, from the VWAP outward — lightest at the VWAP, darkening toward the edges. Purely cosmetic.')

// ═════════════════════════════════════════════════════════════════════════════
//  PREVIOUS VWAP CLOSE
// ═════════════════════════════════════════════════════════════════════════════
grpPrev = 'Previous VWAP Close'

showPrevD = input.bool(true, 'Previous Session VWAP', inline='pD', group=grpPrev)
colPrevD  = input.color(color.new(#2196f3, 40), '', inline='pD', group=grpPrev,
  tooltip = 'The value the Session VWAP ended yesterday with, drawn flat through today. A volume-based reference level, same idea as PDH/PDL.')

showPrevW = input.bool(false, 'Previous Week VWAP', inline='pW', group=grpPrev)
colPrevW  = input.color(color.new(#ff9800, 40), '', inline='pW', group=grpPrev,
  tooltip = 'The value the Weekly VWAP ended last week with, drawn flat through this week.')

// ═════════════════════════════════════════════════════════════════════════════
//  ROLLOVER DETECTION
// ═════════════════════════════════════════════════════════════════════════════
// timeframe.change('1D') is true on the first bar of each new period — the
// canonical non-repaint rollover trigger (same pattern as our Killzones /
// Liquidity Toolkit previous-period machinery).
newD = timeframe.change('1D')
newW = timeframe.change('1W')
newM = timeframe.change('1M')

// Anchors only make sense when the chart TF is below the anchor period —
// on a daily chart a "session VWAP" would reset every single bar.
tfSec   = timeframe.in_seconds()
okD     = tfSec < timeframe.in_seconds('1D')
okW     = tfSec < timeframe.in_seconds('1W')
okM     = tfSec < timeframe.in_seconds('1M')

// ═════════════════════════════════════════════════════════════════════════════
//  VWAP ENGINE — manual accumulation from the anchor
// ═════════════════════════════════════════════════════════════════════════════
// Per anchor we keep three running sums, reset on rollover:
//   sumPV  = Σ (src · volume)          → VWAP     = sumPV / sumV
//   sumV   = Σ  volume
//   sumPV2 = Σ (src² · volume)         → variance = sumPV2/sumV − VWAP²
// The variance formula is the standard volume-weighted one (same math as
// TradingView's built-in VWAP bands). max(·,0) guards float noise before sqrt.

vol = nz(volume)

// ── session ──────────────────────────────────────────────────────────────────
var float dPV  = 0.0
var float dV   = 0.0
var float dPV2 = 0.0
var float prevVwapD = na

if newD
    // capture yesterday's final VWAP BEFORE resetting the accumulators
    prevVwapD := dV > 0 ? dPV / dV : na
    dPV  := 0.0
    dV   := 0.0
    dPV2 := 0.0
dPV  += srcInp * vol
dV   += vol
dPV2 += srcInp * srcInp * vol

vwapD = okD and dV > 0 ? dPV / dV : na
devD  = okD and dV > 0 ? math.sqrt(math.max(dPV2 / dV - vwapD * vwapD, 0)) : na

// ── weekly ───────────────────────────────────────────────────────────────────
var float wPV  = 0.0
var float wV   = 0.0
var float wPV2 = 0.0
var float prevVwapW = na

if newW
    prevVwapW := wV > 0 ? wPV / wV : na
    wPV  := 0.0
    wV   := 0.0
    wPV2 := 0.0
wPV  += srcInp * vol
wV   += vol
wPV2 += srcInp * srcInp * vol

vwapW = okW and wV > 0 ? wPV / wV : na
devW  = okW and wV > 0 ? math.sqrt(math.max(wPV2 / wV - vwapW * vwapW, 0)) : na

// ── monthly ──────────────────────────────────────────────────────────────────
var float mPV  = 0.0
var float mV   = 0.0
var float mPV2 = 0.0

if newM
    mPV  := 0.0
    mV   := 0.0
    mPV2 := 0.0
mPV  += srcInp * vol
mV   += vol
mPV2 += srcInp * srcInp * vol

vwapM = okM and mV > 0 ? mPV / mV : na
devM  = okM and mV > 0 ? math.sqrt(math.max(mPV2 / mV - vwapM * vwapM, 0)) : na

// ═════════════════════════════════════════════════════════════════════════════
//  BAND SELECTION
// ═════════════════════════════════════════════════════════════════════════════
bandBase = bandAnchor == 'Weekly' ? vwapW : bandAnchor == 'Monthly' ? vwapM : vwapD
bandDev  = bandAnchor == 'Weekly' ? devW  : bandAnchor == 'Monthly' ? devM  : devD
bandCol  = bandAnchor == 'Weekly' ? colW  : bandAnchor == 'Monthly' ? colM  : colD
// bands hidden when their anchor's own toggle is off
bandOn   = bandAnchor == 'Weekly' ? showW : bandAnchor == 'Monthly' ? showM : showD

up1 = bandOn and show1 ? bandBase + 1 * bandDev : na
dn1 = bandOn and show1 ? bandBase - 1 * bandDev : na
up2 = bandOn and show2 ? bandBase + 2 * bandDev : na
dn2 = bandOn and show2 ? bandBase - 2 * bandDev : na
up3 = bandOn and show3 ? bandBase + 3 * bandDev : na
dn3 = bandOn and show3 ? bandBase - 3 * bandDev : na

// ═════════════════════════════════════════════════════════════════════════════
//  PLOTS
// ═════════════════════════════════════════════════════════════════════════════
// plot.style_linebr breaks the line over na stretches (weekend closes, symbols
// with missing volume) instead of bridging the gap with a false diagonal.

plot(showD ? vwapD : na, 'Session VWAP', color=colD, linewidth=2, style=plot.style_linebr)
plot(showW ? vwapW : na, 'Weekly VWAP',  color=colW, linewidth=2, style=plot.style_linebr)
plot(showM ? vwapM : na, 'Monthly VWAP', color=colM, linewidth=2, style=plot.style_linebr)

pU1 = plot(up1, '+1σ', color=color.new(bandCol, 55), linewidth=1, style=plot.style_linebr)
pD1 = plot(dn1, '−1σ', color=color.new(bandCol, 55), linewidth=1, style=plot.style_linebr)
pU2 = plot(up2, '+2σ', color=color.new(bandCol, 40), linewidth=1, style=plot.style_linebr)
pD2 = plot(dn2, '−2σ', color=color.new(bandCol, 40), linewidth=1, style=plot.style_linebr)
pU3 = plot(up3, '+3σ', color=color.new(bandCol, 25), linewidth=1, style=plot.style_linebr)
pD3 = plot(dn3, '−3σ', color=color.new(bandCol, 25), linewidth=1, style=plot.style_linebr)

// Hidden center line = the wrapped anchor's own VWAP. Used only as a fill edge so
// the inner VWAP↔±1σ zone can be shaded. Kept invisible (the visible VWAP is
// already drawn above) — this is purely a fill anchor.
pMid = plot(bandOn ? bandBase : na, 'Bands Center', display=display.none)

// Stepped gradient: lightest next to the VWAP (96), darkening outward
// (92 at 1σ-2σ, 86 at 2σ-3σ) so the eye reads "further from fair value = stronger".
fill(pMid, pU1, color = showFill and show1 ? color.new(bandCol, 96) : na, title='Upper VWAP-1σ Fill')
fill(pMid, pD1, color = showFill and show1 ? color.new(bandCol, 96) : na, title='Lower VWAP-1σ Fill')
fill(pU1, pU2, color = showFill ? color.new(bandCol, 92) : na, title='Upper 1σ-2σ Fill')
fill(pD1, pD2, color = showFill ? color.new(bandCol, 92) : na, title='Lower 1σ-2σ Fill')
fill(pU2, pU3, color = showFill ? color.new(bandCol, 86) : na, title='Upper 2σ-3σ Fill')
fill(pD2, pD3, color = showFill ? color.new(bandCol, 86) : na, title='Lower 2σ-3σ Fill')

// previous VWAP closes — flat levels through the current period
plot(showPrevD and okD ? prevVwapD : na, 'Prev Session VWAP', color=colPrevD, linewidth=1, style=plot.style_linebr)
plot(showPrevW and okW ? prevVwapW : na, 'Prev Week VWAP',    color=colPrevW, linewidth=1, style=plot.style_linebr)

// ═════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═════════════════════════════════════════════════════════════════════════════
// ta.cross* must run unconditionally in global scope (execution-model rule).
crossVwapD  = ta.cross(close, vwapD)
crossVwapW  = ta.cross(close, vwapW)
crossVwapM  = ta.cross(close, vwapM)
crossPrevD  = ta.cross(close, prevVwapD)
crossPrevW  = ta.cross(close, prevVwapW)
// band touch = the bar's range reached the level (wick counts), evaluated on
// the full ±2σ levels regardless of the display toggle
touchUp2 = bandOn and not na(bandBase) ? high >= bandBase + 2 * bandDev and high[1] < bandBase[1] + 2 * bandDev[1] : false
touchDn2 = bandOn and not na(bandBase) ? low  <= bandBase - 2 * bandDev and low[1]  > bandBase[1] - 2 * bandDev[1] : false

alertcondition(crossVwapD, title='1. Price crossed Session VWAP', message='VWAP Suite: price crossed the Session VWAP.')
alertcondition(crossVwapW, title='2. Price crossed Weekly VWAP',  message='VWAP Suite: price crossed the Weekly VWAP.')
alertcondition(crossVwapM, title='3. Price crossed Monthly VWAP', message='VWAP Suite: price crossed the Monthly VWAP.')
alertcondition(touchUp2,   title='4. Price touched +2σ band',     message='VWAP Suite: price touched the +2σ deviation band.')
alertcondition(touchDn2,   title='5. Price touched −2σ band',     message='VWAP Suite: price touched the −2σ deviation band.')
alertcondition(crossPrevD, title='6. Price crossed Prev Session VWAP', message='VWAP Suite: price crossed the previous session\'s VWAP close.')
alertcondition(crossPrevW, title='7. Price crossed Prev Week VWAP',    message='VWAP Suite: price crossed the previous week\'s VWAP close.')
````
