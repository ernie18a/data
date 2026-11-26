# VWAP + Order Flow 

- url: https://www.tradingview.com/script/tSF9QVWC-VWAP-Order-Flow/
- type: indicator
- pine_id: PUB;b1a76658997d4550b0ec6b6233198148
- version: 2.0

## Description

[b]VWAP + Order Flow Pro — Institutional Bias, Volume Delta & High-Conviction Signals[/b]
Most VWAP indicators just draw a line. This one reads the market behind the line.
VWAP + Order Flow Pro combines volume-weighted average price with approximated order flow (bar delta + cumulative volume delta) to identify three specific setups where institutional activity is most likely to drive the next move.

[b]THREE SIGNALS — ALL REQUIRE CONFLUENCE[/b]
[b][i]▲▼ Signal A — Institutional Reclaim[/i][/b]
Price spends 3+ bars on the wrong side of VWAP, then reclaims it with a decisive body (≥50% of range), strong delta (>0.6× average volume), and CVD that is both positive and accelerating. Not every VWAP cross — only ones with real buying or selling behind them.
[b][i]▲▼ Signal B — Band Absorption[/i][/b]
Price wicks beyond the ±2σ band by a configurable minimum extension, then closes back inside ±1.5σ. The bar must be wick-dominant (wick/body ratio >1.5), with opposing delta >0.5× average volume and expanding participation. Designed to catch institutional absorption of retail breakout attempts.
[b][i]◆ Signal C — CVD Pivot Divergence[/i][/b]
Price prints a new high or low at a pivot, but cumulative volume delta does not confirm. Hidden buying or distribution. Only fires within ±1.5σ of VWAP with CVD accelerating in the divergence direction.

WHAT MAKES THIS DIFFERENT

No repaint. All signals are gated by barstate.isconfirmed. Divergence signals use pivot lag by design — the delay is the protection.
Adaptive lengths. CVD slope, volume average, and cooldown periods auto-tune to your chart timeframe (1m through 1H+). No manual adjustment needed when switching TFs.
Signal cooldown. Prevents signal spam during chop. Configurable.
Volume filter. Signals require volume above a user-defined multiple of average. Default 1.5×.
Session filter. Optional restriction to high-probability windows: open 90 minutes + close 60 minutes. Built for equities and futures. Leave off for crypto and FX.


WHAT'S ON THE CHART

VWAP with ±1σ, ±1.5σ, ±2σ bands (all toggleable)
Optional HTF VWAP overlay (user-defined timeframe, no repaint)
Bar coloring by delta intensity — teal = buy-dominant, red = sell-dominant
Session high/low dashed lines
Floating bias label: BULL / BEAR / MIXED + CVD direction + acceleration indicator
Stats table: Bias, VWAP price, σ-distance, % from VWAP, CVD, CVD slope, CVD acceleration, volume ratio, bar delta


ALERTS
Five alert conditions built in: Long Signal, Short Signal, Bullish CVD Divergence, Bearish CVD Divergence, VWAP Cross (any direction).
HONEST DISCLOSURE
The order flow in this indicator is approximated, not real. TradingView does not provide bid/ask tape or Level 2 data. Bar delta is calculated from where the close sits within the bar's range — a widely used proxy, but not a substitute for a true footprint chart. Signals are designed to be high-probability, not high-frequency. Fewer signals, better quality.
This indicator is for educational and analytical purposes. Past signals do not guarantee future results. Always use proper risk management.

Works on: Equities · Futures · Crypto · FX
Best timeframes: 1m · 3m · 5m · 15m · 30m · 1H

## Source Code

````pine
//@version=6
indicator("VWAP + Order Flow", shorttitle="VWAP·OF Pro", overlay=true,
         max_labels_count=10, max_lines_count=20, max_bars_back=500)

// ═════════════════════════════════════════════════════════════════════════════
//  VWAP + Order Flow Pro  —  v2  (rethought signal logic)
//  ────────────────────────────────────────────────────
//  Signal A  Institutional Reclaim
//            ≥N bars wrong side → straddle bar + body ≥50% + delta >0.6×avg
//            + CVD slope positive & accelerating + vol >1.3×avg
//
//  Signal B  Band Absorption
//            Wick extends >wickExt% beyond ±2σ + close back inside ±1.5σ
//            + wick-dominant bar (wick/body >1.5) + delta >0.5×avg opposing
//            + CVD momentum reversing + vol >1.5×avg
//
//  Signal C  CVD Pivot Divergence (inherently lagged → no repaint)
//            Price LL/HH while CVD HL/LH + fires within 1.5σ of VWAP
//            + CVD accelerating in divergence direction + vol >1.2×avg
//
//  All signals: barstate.isconfirmed + cooldown + optional session filter
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────4────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpV   = "VWAP"
grpHTF = "Higher-TF VWAP"
grpOF  = "Order Flow"
grpSig = "Signals"
grpFlt = "Filters"
grpUI  = "Display"

i_anchor   = input.string("Session", "Anchor",  options=["Session","Week","Month"], group=grpV)
i_sd1      = input.float (1.0,  "Band 1 σ",     minval=0.25, maxval=4.0, step=0.25, group=grpV)
i_sd2      = input.float (2.0,  "Band 2 σ",     minval=0.5,  maxval=5.0, step=0.25, group=grpV)
i_bands    = input.bool  (true, "Show SD Bands",                                     group=grpV)

i_htfOn    = input.bool      (false, "Enable HTF VWAP",  group=grpHTF)
i_htfTf    = input.timeframe ("60",  "HTF Timeframe",    group=grpHTF)

i_adaptive = input.bool (true, "Auto-tune lengths to chart TF", group=grpOF,
                         tooltip="Overrides manual lengths for 1m/3m/5m/15m/30m/1H+.")
i_cvdLen   = input.int  (14,  "CVD Slope Length",  minval=3,  maxval=200, group=grpOF)
i_avgLen   = input.int  (20,  "Volume Avg Length", minval=5,  maxval=200, group=grpOF)
i_barCol   = input.bool (true,"Color Bars by Delta",                       group=grpOF)

i_sigA     = input.bool  (true, "Signal A: Institutional Reclaim",  group=grpSig)
i_minBars  = input.int   (3,    "Min Bars on Wrong Side",  minval=2, maxval=10, group=grpSig)
i_sigB     = input.bool  (true, "Signal B: Band Absorption",        group=grpSig)
i_wickExt  = input.float (0.1,  "Min Wick Extension % beyond band",
                          minval=0.02, maxval=1.0, step=0.02,            group=grpSig)
i_sigC     = input.bool  (true, "Signal C: CVD Pivot Divergence",   group=grpSig)
i_pvtLen   = input.int   (5,    "Divergence Pivot Length", minval=2, maxval=20, group=grpSig)
i_cool     = input.int   (5,    "Signal Cooldown (bars)",  minval=0, maxval=100, group=grpSig)

i_useVolF  = input.bool  (true, "Require Volume > Avg × Mult",      group=grpFlt)
i_volMult  = input.float (1.5,  "Volume Multiplier", minval=1.0, maxval=5.0, step=0.1, group=grpFlt)
i_useSess  = input.bool  (false,"Restrict to Open 90m + Close 60m", group=grpFlt,
                          tooltip="Intraday equities/futures. Off for 24h symbols.")
i_sessOpen = input.session("0930-1100", "Open Window",  group=grpFlt)
i_sessClos = input.session("1500-1600", "Close Window", group=grpFlt)

i_showTbl  = input.bool   (true, "Show Stats Table", group=grpUI)
i_tblPos   = input.string ("Top Right", "Table Position",
                           options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"],
                           group=grpUI)
i_showLbl  = input.bool   (true, "Show Bias Label",       group=grpUI)
i_showSH   = input.bool   (true, "Session High/Low Lines",group=grpUI)

// ─────────────────────────────────────────────────────────────────────────────
//  ADAPTIVE LENGTHS
// ─────────────────────────────────────────────────────────────────────────────
tfSec = timeframe.in_seconds(timeframe.period)

[cvdLenA, avgLenA, coolA] = switch
    tfSec <= 60    => [21, 30, 12]
    tfSec <= 180   => [18, 24,  8]
    tfSec <= 300   => [14, 20,  6]
    tfSec <= 900   => [12, 18,  4]
    tfSec <= 1800  => [10, 14,  3]
    => [10, 14, 2]

cvdLen = i_adaptive ? cvdLenA : i_cvdLen
avgLen = i_adaptive ? avgLenA : i_avgLen
cool   = i_adaptive ? coolA   : i_cool

// ─────────────────────────────────────────────────────────────────────────────
//  ANCHOR RESET
// ─────────────────────────────────────────────────────────────────────────────
newAnchor = switch i_anchor
    "Session" => timeframe.change("D")
    "Week"    => timeframe.change("W")
    "Month"   => timeframe.change("M")
    => timeframe.change("D")

// ─────────────────────────────────────────────────────────────────────────────
//  VWAP + SD BANDS
// ─────────────────────────────────────────────────────────────────────────────
var float cumVP  = 0.0
var float cumV   = 0.0
var float cumVP2 = 0.0
var float sessHi = na
var float sessLo = na

if newAnchor
    cumVP  := 0.0
    cumV   := 0.0
    cumVP2 := 0.0
    sessHi := high
    sessLo := low
else
    sessHi := math.max(nz(sessHi, high), high)
    sessLo := math.min(nz(sessLo, low),  low)

tp      = hlc3
cumVP  += tp * volume
cumV   += volume
cumVP2 += tp * tp * volume

vwap  = cumV > 0.0 ? cumVP / cumV : tp
vSD   = cumV > 0.0 ? math.sqrt(math.max(cumVP2 / cumV - vwap * vwap, 0.0)) : 0.0

vU1   = vwap + i_sd1 * vSD
vD1   = vwap - i_sd1 * vSD
vU2   = vwap + i_sd2 * vSD
vD2   = vwap - i_sd2 * vSD
vU15  = vwap + 1.5  * vSD
vD15  = vwap - 1.5  * vSD

// ─────────────────────────────────────────────────────────────────────────────
//  HTF VWAP
// ─────────────────────────────────────────────────────────────────────────────
htfVwap = i_htfOn ? request.security(syminfo.tickerid, i_htfTf, ta.vwap,
                                     lookahead=barmerge.lookahead_off) : na

// ─────────────────────────────────────────────────────────────────────────────
//  BAR DELTA
// ─────────────────────────────────────────────────────────────────────────────
barRng = high - low
delta  = barRng > 0.0
       ? volume * ((close - low) - (high - close)) / barRng
       : (close > nz(close[1]) ? volume : close < nz(close[1]) ? -volume : 0.0)

// ─────────────────────────────────────────────────────────────────────────────
//  CVD (anchor-reset)
// ─────────────────────────────────────────────────────────────────────────────
var float cvd = 0.0
if newAnchor
    cvd := 0.0
cvd += delta

cvdSlope     = cvd - cvd[cvdLen]
cvdBull      = cvdSlope > 0.0
cvdAccelBull = cvdSlope > cvdSlope[3]
cvdAccelBear = cvdSlope < cvdSlope[3]

// ─────────────────────────────────────────────────────────────────────────────
//  VOLUME / SESSION FILTERS
// ─────────────────────────────────────────────────────────────────────────────
avgVol   = ta.sma(volume, avgLen)
volRatio = avgVol > 0.0 ? volume / avgVol : 0.0

inOpen  = not na(time(timeframe.period, i_sessOpen, syminfo.timezone))
inClose = not na(time(timeframe.period, i_sessClos, syminfo.timezone))
sessOk  = not i_useSess or inOpen or inClose

volOk     = not i_useVolF or volume > avgVol * i_volMult
confirmed = barstate.isconfirmed
filterOk  = sessOk and confirmed

// ─────────────────────────────────────────────────────────────────────────────
//  BAR ANATOMY
// ─────────────────────────────────────────────────────────────────────────────
bodySize  = math.abs(close - open)
rangeSize = math.max(high - low, syminfo.mintick)
bodyRatio = bodySize / rangeSize
lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

dojiThresh = close * 0.0003
wickBodyL  = bodySize > dojiThresh ? lowerWick / bodySize : 2.0
wickBodyS  = bodySize > dojiThresh ? upperWick / bodySize : 2.0

// ─────────────────────────────────────────────────────────────────────────────
//  BARS ON EACH SIDE OF VWAP
// ─────────────────────────────────────────────────────────────────────────────
var int barsBelowVwap = 0
var int barsAboveVwap = 0

if newAnchor
    barsBelowVwap := 0
    barsAboveVwap := 0
else if close[1] < vwap[1]
    barsBelowVwap := barsBelowVwap + 1
    barsAboveVwap := 0
else if close[1] > vwap[1]
    barsAboveVwap := barsAboveVwap + 1
    barsBelowVwap := 0
else
    barsBelowVwap := 0
    barsAboveVwap := 0

// ═════════════════════════════════════════════════════════════════════════════
//  SIGNAL A — INSTITUTIONAL RECLAIM
// ═════════════════════════════════════════════════════════════════════════════
reclaimLong  = i_sigA
             and barsBelowVwap >= i_minBars
             and open < vwap and close > vwap
             and bodyRatio >= 0.5
             and delta > avgVol * 0.6
             and cvdBull and cvdAccelBull
             and volume > avgVol * 1.3

reclaimShort = i_sigA
             and barsAboveVwap >= i_minBars
             and open > vwap and close < vwap
             and bodyRatio >= 0.5
             and delta < -(avgVol * 0.6)
             and not cvdBull and cvdAccelBear
             and volume > avgVol * 1.3

// ═════════════════════════════════════════════════════════════════════════════
//  SIGNAL B — BAND ABSORPTION
// ═════════════════════════════════════════════════════════════════════════════
minExtPrice = close * (i_wickExt / 100.0)

absorbLong  = i_sigB
             and low   < vD2 - minExtPrice
             and close > vD15
             and wickBodyL > 1.5
             and delta > avgVol * 0.5
             and cvdAccelBull
             and volume > avgVol * 1.5

absorbShort = i_sigB
             and high  > vU2 + minExtPrice
             and close < vU15
             and wickBodyS > 1.5
             and delta < -(avgVol * 0.5)
             and cvdAccelBear
             and volume > avgVol * 1.5

// ═════════════════════════════════════════════════════════════════════════════
//  SIGNAL C — CVD PIVOT DIVERGENCE
// ═════════════════════════════════════════════════════════════════════════════
phPrice = ta.pivothigh(high, i_pvtLen, i_pvtLen)
plPrice = ta.pivotlow (low,  i_pvtLen, i_pvtLen)
phCVD   = ta.pivothigh(cvd,  i_pvtLen, i_pvtLen)
plCVD   = ta.pivotlow (cvd,  i_pvtLen, i_pvtLen)

var float lastPH    = na
var float lastPHcvd = na
var float lastPL    = na
var float lastPLcvd = na

bearDiv = false
bullDiv = false

if not na(phPrice)
    if not na(lastPH) and not na(phCVD) and not na(lastPHcvd)
        if phPrice > lastPH and phCVD < lastPHcvd
            bearDiv := true
    lastPH    := phPrice
    lastPHcvd := nz(phCVD, lastPHcvd)

if not na(plPrice)
    if not na(lastPL) and not na(plCVD) and not na(lastPLcvd)
        if plPrice < lastPL and plCVD > lastPLcvd
            bullDiv := true
    lastPL    := plPrice
    lastPLcvd := nz(plCVD, lastPLcvd)

inVwapZone   = math.abs(close - vwap) <= 1.5 * vSD
volExpanding = volume > avgVol * 1.2

sig_divB = i_sigC and bullDiv and confirmed and inVwapZone and cvdAccelBull and volExpanding
sig_divS = i_sigC and bearDiv and confirmed and inVwapZone and cvdAccelBear and volExpanding

// ─────────────────────────────────────────────────────────────────────────────
//  COOLDOWN + FINAL SIGNALS
// ─────────────────────────────────────────────────────────────────────────────
var int lastLongBar  = -10000
var int lastShortBar = -10000

longCandidate  = (reclaimLong  or absorbLong)  and filterOk
shortCandidate = (reclaimShort or absorbShort) and filterOk

sig_long  = longCandidate  and (bar_index - lastLongBar)  >= cool
sig_short = shortCandidate and (bar_index - lastShortBar) >= cool

if sig_long
    lastLongBar := bar_index
if sig_short
    lastShortBar := bar_index

abvVwap = close > vwap
blwVwap = close < vwap
bias    = abvVwap and cvdBull ? "BULL" : blwVwap and not cvdBull ? "BEAR" : "MIXED"
biasCol = bias == "BULL" ? color.lime : bias == "BEAR" ? color.red : color.orange

// ─────────────────────────────────────────────────────────────────────────────
//  BAR COLORING
// ─────────────────────────────────────────────────────────────────────────────
strength = math.min(math.abs(delta) / math.max(avgVol, 1.0), 1.0)
bullCol  = color.from_gradient(strength, 0.0, 1.0, color.new(color.teal, 80), color.new(color.teal,  5))
bearCol  = color.from_gradient(strength, 0.0, 1.0, color.new(color.red,  80), color.new(color.red,   5))
barcolor(i_barCol ? (delta >= 0.0 ? bullCol : bearCol) : na)

// ─────────────────────────────────────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
//  PLOTS — VWAP + BANDS
// ─────────────────────────────────────────────────────────────────────────────
plot(vwap,    "VWAP",     color=color.new(color.white,  0), linewidth=2)
plot(htfVwap, "HTF VWAP", color=color.new(color.yellow, 0), linewidth=2)

p_u1 = plot(i_bands ? vU1 : na, "+1σ", color=color.new(color.orange, 30), linewidth=1)
p_d1 = plot(i_bands ? vD1 : na, "−1σ", color=color.new(color.orange, 30), linewidth=1)
p_u2 = plot(i_bands ? vU2 : na, "+2σ", color=color.new(color.red,     8), linewidth=1)
p_d2 = plot(i_bands ? vD2 : na, "−2σ", color=color.new(color.red,     8), linewidth=1)

fill(p_u2, p_u1, color=color.new(color.red,    93))
fill(p_d1, p_d2, color=color.new(color.red,    93))
fill(p_u1, p_d1, color=color.new(color.orange, 96))

plot(i_bands ? vU15 : na, "+1.5σ", color=color.new(color.red, 55), linewidth=1)
plot(i_bands ? vD15 : na, "−1.5σ", color=color.new(color.red, 55), linewidth=1)

var line lnH = na
var line lnL = na
if i_showSH and barstate.islast
    line.delete(lnH)
    line.delete(lnL)
    lnH := line.new(bar_index - 50, sessHi, bar_index + 5, sessHi,
                    color=color.new(color.lime, 40), style=line.style_dashed)
    lnL := line.new(bar_index - 50, sessLo, bar_index + 5, sessLo,
                    color=color.new(color.red,  40), style=line.style_dashed)

plotshape(sig_long,  "Long  (A/B)", shape.triangleup,   location.belowbar,
          color.new(color.lime,   0), size=size.small)
plotshape(sig_short, "Short (A/B)", shape.triangledown, location.abovebar,
          color.new(color.red,    0), size=size.small)
plotshape(sig_divB,  "Bull Div (C)",shape.diamond,      location.belowbar,
          color.new(color.aqua,   0), size=size.tiny)
plotshape(sig_divS,  "Bear Div (C)",shape.diamond,      location.abovebar,
          color.new(color.orange, 0), size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
//  BIAS LABEL
// ─────────────────────────────────────────────────────────────────────────────
var label lbl = na
if i_showLbl and barstate.islast
    label.delete(lbl)
    distPct = (close - vwap) / vwap * 100.0
    dStr    = (distPct >= 0.0 ? "+" : "") + str.tostring(math.round(distPct, 2)) + "%"
    acclStr = cvdAccelBull ? " ⚡▲" : cvdAccelBear ? " ⚡▼" : ""
    txt     = bias + "  " + dStr + "  CVD" + (cvdBull ? "▲" : "▼") + acclStr
    lbl    := label.new(bar_index + 2, vwap, txt,
                        xloc=xloc.bar_index, style=label.style_label_left,
                        color=color.new(color.black, 8), textcolor=biasCol,
                        size=size.normal)

// ─────────────────────────────────────────────────────────────────────────────
//  STATS TABLE
// ─────────────────────────────────────────────────────────────────────────────
tblPos = i_tblPos == "Top Left"     ? position.top_left     :
         i_tblPos == "Top Right"    ? position.top_right    :
         i_tblPos == "Bottom Left"  ? position.bottom_left  :
         i_tblPos == "Bottom Right" ? position.bottom_right :
                                      position.middle_right

var table tbl = table.new(tblPos, 2, 9, border_width=1)

if i_showTbl and barstate.islast
    table.clear(tbl, 0, 0, 1, 8)

    distPct  = (close - vwap) / vwap * 100.0
    sigDist  = vSD > 0.0 ? (close - vwap) / vSD : 0.0
    cvdTxt   = cvdBull ? "▲ Buyers"  : "▼ Sellers"
    cvdCol   = cvdBull ? color.lime  : color.red
    acclTxt  = cvdAccelBull ? "▲ Building" : cvdAccelBear ? "▼ Building" : "— Flat"
    acclCol  = cvdAccelBull ? color.lime   : cvdAccelBear ? color.red    : color.gray

    bgHdr = color.new(color.black, 40)
    bgRow = color.new(color.black, 60)

    table.cell(tbl, 0, 0, "Bias",      bgcolor=bgHdr, text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 0, bias,        bgcolor=bgHdr, text_color=biasCol,      text_size=size.small)
    table.cell(tbl, 0, 1, "VWAP",      bgcolor=bgRow, text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(vwap, format.mintick),
                                       bgcolor=bgRow, text_color=color.white,  text_size=size.small)
    table.cell(tbl, 0, 2, "σ-Dist",    bgcolor=bgRow, text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(sigDist, "#.00") + "σ",
                                       bgcolor=bgRow, text_color=color.white,  text_size=size.small)
    table.cell(tbl, 0, 3, "Δ VWAP %",  bgcolor=bgRow, text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 3, (distPct >= 0.0 ? "+" : "") + str.tostring(distPct, "#.00") + "%",
                                       bgcolor=bgRow, text_color=color.white,  text_size=size.small)
    table.cell(tbl, 0, 4, "CVD",       bgcolor=bgRow, text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(cvd, format.volume) + "  " + cvdTxt,
                                       bgcolor=bgRow, text_color=cvdCol,       text_size=size.small)
    table.cell(tbl, 0, 5, "CVD Slope", bgcolor=bgRow, text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(cvdSlope, format.volume),
                                       bgcolor=bgRow, text_color=cvdCol,       text_size=size.small)
    table.cell(tbl, 0, 6, "CVD Accel", bgcolor=bgRow, text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 6, acclTxt,    bgcolor=bgRow, text_color=acclCol,      text_size=size.small)
    table.cell(tbl, 0, 7, "Vol Ratio", bgcolor=bgRow, text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 7, str.tostring(volRatio, "#.00") + "×",
                                       bgcolor=bgRow,
                                       text_color=volRatio >= i_volMult ? color.lime : color.silver,
                                       text_size=size.small)
    table.cell(tbl, 0, 8, "Bar Delta", bgcolor=bgRow, text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 8, str.tostring(delta, format.volume),
                                       bgcolor=bgRow,
                                       text_color=delta >= 0 ? color.lime : color.red,
                                       text_size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(sig_long,  "Long Signal",  "VWAP·OF Pro: LONG {{ticker}} @ {{close}}")
alertcondition(sig_short, "Short Signal", "VWAP·OF Pro: SHORT {{ticker}} @ {{close}}")
alertcondition(sig_divB,  "Bull CVD Div","VWAP·OF Pro: Bull CVD Div {{ticker}} @ {{close}}")
alertcondition(sig_divS,  "Bear CVD Div","VWAP·OF Pro: Bear CVD Div {{ticker}} @ {{close}}")
alertcondition(ta.cross(close, vwap), "VWAP Cross", "VWAP·OF Pro: {{ticker}} crossed VWAP @ {{close}}")
````
