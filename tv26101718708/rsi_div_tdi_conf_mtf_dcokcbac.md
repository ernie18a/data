# RSI - Div - TDI (Conf + MTF)

- url: https://www.tradingview.com/script/dCOkcbac-RSI-Div-TDI-Conf-MTF/
- type: indicator
- pine_id: PUB;411feda6d0d547c9a72f19efab0564a8
- version: 1.0

## Description

# RSI/TDI Multi-Timeframe Confirmed Divergences

**What it is**

A momentum tool that detects RSI divergences and — this is the point of the script — only reports them once they are confirmed on bar close, then checks whether the same divergence is occurring on several timeframes at once. It is built on the well-known RSI + TDI framework, but its purpose is not to re-display RSI or the TDI; it is to solve two specific problems with ordinary divergence scripts: they repaint while a bar is forming, and they treat a noisy 1-minute divergence the same as a broad 4-hour one. This script addresses both.

---

**What is original here (and why it is not just a mashup)**

Most open-source divergence indicators evaluate the divergence on the live, still-forming bar. That means a divergence can appear, then disappear before the candle closes — it repaints, and you cannot trust what you see in real time. This script gates every divergence to confirmed bars (it only commits a signal when the candle has closed), so a printed signal is final and will not vanish.

On top of that, it adds a multi-timeframe agreement engine that does not exist in the built-in or common divergence scripts:

- It runs the identical divergence calculation on up to five user-selected timeframes.
- It latches each timeframe's result only when that timeframe's own bar closes, so the cross-timeframe reading does not flicker as higher bars form.
- It uses a recency window so a higher-timeframe divergence stays "active" long enough to line up with the chart timeframe (since divergences on different timeframes rarely print on the same candle).
- It counts how many timeframes agree and recolors the signal when the count crosses a threshold you set.

That combination — non-repainting confirmation plus per-timeframe close-latched divergence agreement with a colored confluence output — is the original behavior, and the reason the components are bundled into one script rather than used separately.

---

**How the pieces work together**

Each component has a job; none is decorative:

- **RSI** is the momentum gauge — it measures whether recent buying or selling has more force.
- **The TDI Bollinger Bands on RSI** give that momentum a volatility/mean context, so you can see when RSI is stretched relative to its own recent range, not just relative to fixed levels.
- **The divergence detector** is the actual signal: it compares price extremes against RSI extremes and flags when they disagree.
- **The confirmation gate** removes the repainting so the signal is trustworthy.
- **The multi-timeframe layer** is the filter that separates a throwaway low-timeframe divergence from a broad, meaningful one — the higher the agreement, the more independent momentum readings are calling the same exhaustion at once.

Used together they answer one question: *is momentum genuinely exhausting here, across enough of the market to matter?*

---

**The concept behind the calculation**

A divergence is price and momentum disagreeing. A trend continues while each push carries more force than the last; when price makes a new extreme but RSI does not, the force behind the move is fading.

Over a lookback window the script tracks the running highest and lowest price and the RSI reading at those points, then:

- **Bullish divergence:** price makes a lower low, but RSI does not make a matching new low and begins turning up — selling pressure is drying up.
- **Bearish divergence:** price makes a higher high, but RSI fails to confirm with a higher high and rolls over — buying pressure is drying up.

The signal is therefore a read on **momentum exhaustion**, not a guaranteed turn. The higher-timeframe layer matters because a higher-timeframe RSI aggregates far more order flow into one reading, so a divergence there reflects a broad shift in control rather than local noise.

---

**How to use it**

- Add it to a separate pane and run it on the timeframe you trade.
- A dot marks a confirmed divergence (green = bullish, red = bearish). The dot only appears once the bar has closed.
- A purple dot means the divergence is present on multiple timeframes at once — the higher-conviction case.
- Treat it as exhaustion/reversal context. It is most useful combined with a price level (a prior high/low, support/resistance) and your own entry confirmation, rather than as a standalone buy/sell. Optional alerts are included for single-timeframe and multi-timeframe divergences.

---

**Settings**

- **RSI Length / Lookback** — the momentum period and the window the divergence is measured against.
- **Confirmed divergences only** — keep on for non-repainting signals; turn off to see live (flickering) divergences earlier.
- **Compare timeframes (up to 5)** — the timeframes checked for agreement, each with an on/off toggle.
- **Timeframes needed for purple** — how many must agree before the dot recolors.
- **Other-TF recency** — how long another timeframe's divergence stays active so it can align with the chart.
- **Colors** — every plot (RSI line, bands, divergence dots, agreement color, pivots) is user-configurable.
- TDI Bollinger Band length/type, second RSI, and overbought/oversold levels are included for context and configurable.

---

**Notes and limitations**

- Signals are non-repainting on the chart timeframe because they confirm on close. Higher-timeframe components naturally finalize only when their own bar closes, which is expected multi-timeframe behavior — read the multi-timeframe agreement on closed bars.
- Divergence indicates momentum exhaustion, which does not guarantee an immediate reversal; trends can remain divergent for some time. Use confirmation.
- This script is for analysis and education and is not financial advice.

---

**Credits**

Built on the open-source RSI and Traders Dynamic Index (TDI) divergence approach. Original RSI/TDI divergence logic credit to QuantTherapyThe confirmed-on-close handling and the multi-timeframe divergence-agreement engine are additions in this version.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────
// RSI / TDI / Div — Confirmed + Multi-Timeframe (purple on agreement)
// Faithful v6 conversion of the original. Same RSI lengths, TDI Bollinger
// bands, sharkfins, divergence logic, pivots and label behaviour.
//   • Confirmed-only: a divergence paints only once the candle CLOSES (no flicker)
//   • Multi-TF: when the same-direction divergence is live on enough timeframes,
//     the dot turns PURPLE instead of red/green.
// ─────────────────────────────────────────────────────────────────────────
indicator(title="RSI - Div - TDI (Conf + MTF)", shorttitle="RSI / TDI / Div (MTF)", overlay=false)

rsiLength     = input.int(14, "RSI Length", minval=1)
rsiLength2    = input.int(7,  "RSI Length 2", minval=1)
rsiOverbought = input.int(75, "RSI Overbought", minval=0, maxval=100)
rsiOversold   = input.int(25, "RSI Oversold",   minval=0, maxval=100)
rsiSource     = input.source(close, "RSI Source")

bb_length     = input.int(34, "BB Length", minval=1)
bb_type       = input.string("EMA", "BB Type", options=["SMA","EMA","WMA","DEMA","TEMA","TRIMA","KAMA","T3"])
bb_std        = input.float(1.6185, "BB std.", minval=0)

gC = "🎨 Colors"
colRsiNorm = input.color(color.orange, "RSI line", group=gC)
colRsiExt  = input.color(color.red,    "RSI line (OB/OS)", group=gC)
colRsi2    = input.color(color.yellow, "RSI 2", group=gC)
colBand    = input.color(#972999,      "Bollinger bands", group=gC)
colBull    = input.color(color.green,  "Bull divergence", group=gC)
colBear    = input.color(color.red,    "Bear divergence", group=gC)
colPurple  = input.color(color.purple, "Multi-TF agreement", group=gC)
colPivot   = input.color(color.blue,   "Pivot", group=gC)

rsi  = ta.rsi(rsiSource, rsiLength)
rsi2 = ta.rsi(rsiSource, rsiLength2)
hline(rsiOverbought, "Overbought", color=color.red)
hline(rsiOversold,   "Oversold",   color=color.lime)

rsiColor = (rsi > rsiOverbought or rsi < rsiOversold) ? colRsiExt : colRsiNorm
plot(rsi,  "RSI",  color=rsiColor, linewidth=2)
plot(rsi2, "RSI2", color=color.new(colRsi2, 90), linewidth=1)

kama(src, len) =>
    xvnoise = math.abs(src - src[1])
    nfastend = 0.666
    nslowend = 0.0645
    nsignal = math.abs(src - src[len])
    nnoise = math.sum(xvnoise, len)
    nefratio = nnoise != 0 ? nsignal / nnoise : 0
    nsmooth = math.pow(nefratio * (nfastend - nslowend) + nslowend, 2)
    nAMA = 0.0
    nAMA := nz(nAMA[1]) + nsmooth * (src - nz(nAMA[1]))

t3(src, len) =>
    xe1_1 = ta.ema(src,   len)
    xe2_1 = ta.ema(xe1_1, len)
    xe3_1 = ta.ema(xe2_1, len)
    xe4_1 = ta.ema(xe3_1, len)
    xe5_1 = ta.ema(xe4_1, len)
    xe6_1 = ta.ema(xe5_1, len)
    b_1 = 0.7
    c1_1 = -b_1*b_1*b_1
    c2_1 = 3*b_1*b_1+3*b_1*b_1*b_1
    c3_1 = -6*b_1*b_1-3*b_1-3*b_1*b_1*b_1
    c4_1 = 1+3*b_1+b_1*b_1*b_1+3*b_1*b_1
    c1_1 * xe6_1 + c2_1 * xe5_1 + c3_1 * xe4_1 + c4_1 * xe3_1

variant(type, src, len) =>
    v1 = ta.sma(src, len)
    v2 = ta.ema(src, len)
    v3 = 2 * v2 - ta.ema(v2, len)
    v4 = 3 * (v2 - ta.ema(v2, len)) + ta.ema(ta.ema(v2, len), len)
    v5 = ta.wma(src, len)
    v6 = ta.sma(ta.sma(src, math.ceil(len / 2)), math.floor(len / 2) + 1)
    v7 = kama(src, len)
    v8 = t3(src, len)
    type=="EMA"?v2 : type=="DEMA"?v3 : type=="TEMA"?v4 : type=="WMA"?v5 : type=="TRIMA"?v6 : type=="KAMA"?v7 : type=="T3"?v8 : v1

// BB Calculation
bb_basis = variant(bb_type, rsi, bb_length)
bb_dev   = bb_std * ta.stdev(rsi, bb_length)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev
plot(bb_upper, "Upper Band", color=color.new(colBand, 55), linewidth=1)
plot(bb_lower, "Lower Band", color=color.new(colBand, 55), linewidth=1)
plot(bb_basis, "Mid Band",   color=color.new(colBand, 55), linewidth=1)

// Sharkfins
rsiUp   = rsi + 7
rsiDown = rsi - 7
shark   = input.bool(true, "Show Sharkfins?")
plotshape(shark ? ((bb_upper<rsi and rsiOverbought<rsi) ? rsiUp   : na) : na, "SharkFin1", color=color.new(color.red,    75), style=shape.triangledown, location=location.absolute, size=size.tiny)
plotshape(shark ? ((bb_upper<rsi and rsiOverbought>rsi) ? rsiUp   : na) : na, "SharkFin2", color=color.new(color.orange, 85), style=shape.triangledown, location=location.absolute, size=size.tiny)
plotshape(shark ? ((bb_lower>rsi and rsiOversold>rsi)   ? rsiDown : na) : na, "SharkFin3", color=color.new(color.lime,   75), style=shape.triangleup,   location=location.absolute, size=size.tiny)
plotshape(shark ? ((bb_lower>rsi and rsiOversold<rsi)   ? rsiDown : na) : na, "SharkFin4", color=color.new(color.orange, 85), style=shape.triangleup,   location=location.absolute, size=size.tiny)

// ─── DIVERGENCE INPUTS ───────────────────────────────────────────────────
div           = input.bool(true,  "Show Divergences?")
confirmedOnly = input.bool(true,  "Confirmed divergences only (no flicker)?")
piv           = input.bool(false, "Hide pivots?")
shrt          = input.bool(true,  "Shorter labels?")
xbars         = input.int(90, "Div lookback period (bars)?", minval=1)

// ─── MULTI-TIMEFRAME (purple on agreement) ───────────────────────────────
gM        = "⬤ Multi-Timeframe Purple"
purpleOn  = input.bool(true, "Purple dot when multiple TFs agree", group=gM)
purpleMin = input.int(2, "Timeframes needed for purple", minval=2, maxval=6, group=gM, tooltip="Counts THIS chart plus the timeframes below. 2 = this chart and one other agree.")
divRec    = input.int(15, "Other-TF recency (their bars)", minval=1, maxval=100, group=gM, tooltip="A divergence on another timeframe stays 'live' for this many of its own bars, so it can line up with the dot on this chart.")
emt1 = input.bool(true,  "", group=gM, inline="m1")
mtf1 = input.timeframe("5",   "Compare TF 1", group=gM, inline="m1")
emt2 = input.bool(true,  "", group=gM, inline="m2")
mtf2 = input.timeframe("15",  "Compare TF 2", group=gM, inline="m2")
emt3 = input.bool(true,  "", group=gM, inline="m3")
mtf3 = input.timeframe("30",  "Compare TF 3", group=gM, inline="m3")
emt4 = input.bool(true,  "", group=gM, inline="m4")
mtf4 = input.timeframe("60",  "Compare TF 4", group=gM, inline="m4")
emt5 = input.bool(true,  "", group=gM, inline="m5")
mtf5 = input.timeframe("240", "Compare TF 5", group=gM, inline="m5")

// Same divergence logic, reusable for other timeframes. Returns whether a
// bull / bear divergence is live (within recency), optionally confirmed-only.
f_divActive(int rlen, int xb, int rec, bool conf) =>
    float r = ta.rsi(close, rlen)
    int hbF = math.abs(ta.highestbars(r, xb))
    int lbF = math.abs(ta.lowestbars(r, xb))
    float hiP = na
    float hiR = na
    float loP = na
    float loR = na
    hiP := hbF == 0 ? close : na(hiP[1]) ? close : hiP[1]
    hiR := hbF == 0 ? r     : na(hiR[1]) ? r     : hiR[1]
    loP := lbF == 0 ? close : na(loP[1]) ? close : loP[1]
    loR := lbF == 0 ? r     : na(loR[1]) ? r     : loR[1]
    if close > hiP
        hiP := close
    if r > hiR
        hiR := r
    if close < loP
        loP := close
    if r < loR
        loR := r
    bool dBear = hiP[1] > hiP[2] and r[1] < hiR and r <= r[1]
    bool dBull = loP[1] < loP[2] and r[1] > loR and r >= r[1]
    bool ok = not conf or barstate.isconfirmed
    var int bullBar = na
    var int bearBar = na
    if dBull and ok
        bullBar := bar_index
    if dBear and ok
        bearBar := bar_index
    bool bullOn = not na(bullBar) and bar_index - bullBar <= rec
    bool bearOn = not na(bearBar) and bar_index - bearBar <= rec
    [bullOn, bearOn]

[m1b, m1s] = request.security(syminfo.tickerid, mtf1, f_divActive(rsiLength, xbars, divRec, confirmedOnly))
[m2b, m2s] = request.security(syminfo.tickerid, mtf2, f_divActive(rsiLength, xbars, divRec, confirmedOnly))
[m3b, m3s] = request.security(syminfo.tickerid, mtf3, f_divActive(rsiLength, xbars, divRec, confirmedOnly))
[m4b, m4s] = request.security(syminfo.tickerid, mtf4, f_divActive(rsiLength, xbars, divRec, confirmedOnly))
[m5b, m5s] = request.security(syminfo.tickerid, mtf5, f_divActive(rsiLength, xbars, divRec, confirmedOnly))

float mc = timeframe.in_seconds(timeframe.period)
bool u1 = emt1 and timeframe.in_seconds(mtf1) != mc
bool u2 = emt2 and timeframe.in_seconds(mtf2) != mc
bool u3 = emt3 and timeframe.in_seconds(mtf3) != mc
bool u4 = emt4 and timeframe.in_seconds(mtf4) != mc
bool u5 = emt5 and timeframe.in_seconds(mtf5) != mc
int otherBull = (u1 and m1b ? 1 : 0) + (u2 and m2b ? 1 : 0) + (u3 and m3b ? 1 : 0) + (u4 and m4b ? 1 : 0) + (u5 and m5b ? 1 : 0)
int otherBear = (u1 and m1s ? 1 : 0) + (u2 and m2s ? 1 : 0) + (u3 and m3s ? 1 : 0) + (u4 and m4s ? 1 : 0) + (u5 and m5s ? 1 : 0)

// ─── CHART DIVERGENCE (draws the dot) — original logic, confirmed-gated ───
int hbC = math.abs(ta.highestbars(rsi, xbars))
int lbC = math.abs(ta.lowestbars(rsi, xbars))
float hiP = na
float hiR = na
float loP = na
float loR = na
hiP := hbC == 0 ? close : na(hiP[1]) ? close : hiP[1]
hiR := hbC == 0 ? rsi   : na(hiR[1]) ? rsi   : hiR[1]
loP := lbC == 0 ? close : na(loP[1]) ? close : loP[1]
loR := lbC == 0 ? rsi   : na(loR[1]) ? rsi   : loR[1]
if close > hiP
    hiP := close
if rsi > hiR
    hiR := rsi
if close < loP
    loP := close
if rsi < loR
    loR := rsi

bool pivoth = hiR == hiR[2] and hiR[2] != hiR[3]
bool pivotl = loR == loR[2] and loR[2] != loR[3]
bool divbear = hiP[1] > hiP[2] and rsi[1] < hiR and rsi <= rsi[1]
bool divbull = loP[1] < loP[2] and rsi[1] > loR and rsi >= rsi[1]

// confirmed gate (no flicker) + multi-TF agreement
divConf  = not confirmedOnly or barstate.isconfirmed
sBear    = divbear and divConf
sBull    = divbull and divConf
purpleBull = purpleOn and sBull and (1 + otherBull) >= purpleMin
purpleBear = purpleOn and sBear and (1 + otherBear) >= purpleMin
color cBull = purpleBull ? colPurple : colBull
color cBear = purpleBear ? colPurple : colBear

// Alerts
alertcondition(sBear, "Bear div", "Bear div")
alertcondition(sBull, "Bull div", "Bull div")
alertcondition(purpleBear, "Bear div · multi-TF", "Bearish divergence agreed across multiple timeframes")
alertcondition(purpleBull, "Bull div · multi-TF", "Bullish divergence agreed across multiple timeframes")

// Plots — Longer labels
plotshape(div ? (shrt ? na : (sBear ? rsi[1] + 1 : na)) : na, "Bear", location=location.absolute, style=shape.circle, color=cBear, size=size.tiny, text="Bear", textcolor=color.white, offset=-1)
plotshape(div ? (shrt ? na : (sBull ? rsi[1] - 1 : na)) : na, "Bull", location=location.absolute, style=shape.circle, color=cBull, size=size.tiny, text="Bull", textcolor=color.white, offset=-1)
plotshape(div ? (piv ? na : (shrt ? na : (pivoth ? hiR + 1 : na))) : na, "PivotH", location=location.absolute, style=shape.circle, color=color.new(colPivot, 50), size=size.tiny, text="Pivot", textcolor=color.white, offset=-2)
plotshape(div ? (piv ? na : (shrt ? na : (pivotl ? loR - 1 : na))) : na, "PivotL", location=location.absolute, style=shape.circle, color=color.new(colPivot, 50), size=size.tiny, text="Pivot", textcolor=color.white, offset=-2)

// Plots — Shorter labels
plotshape(div ? (shrt ? (sBear ? rsi[1] + 3 : na) : na) : na, "BearS", location=location.absolute, style=shape.circle, color=cBear, size=size.tiny, offset=-1)
plotshape(div ? (shrt ? (sBull ? rsi[1] - 3 : na) : na) : na, "BullS", location=location.absolute, style=shape.circle, color=cBull, size=size.tiny, offset=-1)
plotshape(div ? (piv ? na : (shrt ? (pivoth ? hiR + 3 : na) : na)) : na, "PivotHS", location=location.absolute, style=shape.circle, color=color.new(colPivot, 60), size=size.tiny, offset=-2)
plotshape(div ? (piv ? na : (shrt ? (pivotl ? loR - 3 : na) : na)) : na, "PivotLS", location=location.absolute, style=shape.circle, color=color.new(colPivot, 60), size=size.tiny, offset=-2)
````
