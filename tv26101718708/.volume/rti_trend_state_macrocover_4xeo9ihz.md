# RTI Trend State + MacroCover

- url: https://www.tradingview.com/script/4xeo9IhZ/
- type: indicator
- pine_id: PUB;67b59fc5a32a47b084707f14030deacb
- version: 4.0

## Description

[b]RTI Trend State + MacroCover[/b]

A trend-state oscillator built on the [b]Relative Trend Index (RTI)[/b] — a stochastic-position measure of where price sits inside its recent high/low range, then EMA-smoothed:

[pine]raw = 100 * (close - lowest(low, n)) / (highest(high, n) - lowest(low, n))
RTI = EMA(raw, smooth)   ->   a 0-100 line[/pine]

[b]How the state works[/b]
The 0-100 RTI is converted into a persistent [b]LONG / FLAT / SHORT[/b] state through a [b]hysteresis band[/b], so it does not flip on noise around the mid-line:
[list]
[*]RTI above the upper band  ->  [b]LONG[/b]
[*]RTI below the lower band  ->  [b]SHORT[/b]
[*]in between  ->  [i]holds[/i] the last state
[/list]
The gap between the two bands is the hysteresis — widen it for fewer, steadier flips; narrow it for a more reactive read.

[b]MacroCover (optional long bias)[/b]
When the state would be SHORT but price trades [b]above a slow EMA[/b] (default 200), the short is [i]covered[/i] to [b]FLAT[/b] — i.e. it won't fight the higher-timeframe uptrend. Turn MacroCover off for a symmetric long/short reading.

[b]On the chart[/b]
[list]
[*]The [b]RTI line[/b] (0-100) colored by state: green long, red short, gray flat.
[*]Dashed [b]upper/lower bands[/b] and a dotted mid-line.
[*][b]State background[/b] tint and [b]flip markers[/b] where the state changes.
[*]A compact [b]table[/b] with the current RTI value, state and macro side.
[*]The RTI value plus [code]state_-1_0_1[/code] and [code]ema_macro[/code] are available in the Data Window for tooltips and cross-checks.
[/list]

[b]Inputs[/b]
[list]
[*][i]RTI engine[/i] — Lookback n (30), EMA smoothing (3), upper/lower bands (55 / 45).
[*][i]MacroCover[/i] — on/off and macro EMA length (200).
[*][i]Timeframe[/i] — use the chart timeframe, or lock the calculation to a fixed resolution.
[*][i]Visual[/i] — toggle the state background, flip markers and table.
[/list]

[b]Notes[/b]
[list]
[*]Works on any symbol and any timeframe.
[*][b]Non-repainting[/b]: values are computed on confirmed bars, and the optional higher-timeframe request uses lookahead_off.
[*]This is a discretionary / confluence tool, not financial advice or a complete trading system.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JaMona
//@version=6
// =============================================================================
//  RTI Trend State + MacroCover  (+ Laguerre confluence + Top-down 1D gate)
// =============================================================================
//
//  WHAT IT DOES
//  ------------
//  RTI (Relative Trend Index) measures where price sits inside its own recent
//  range — a stochastic-style position — smooths it, and converts it into a
//  PERSISTENT LONG / FLAT / SHORT state using a hysteresis band:
//
//      raw = 100 * (close - lowest(low, n)) / (highest(high, n) - lowest(low, n))
//      rti = ema(raw, smooth)
//      LONG if rti > upper band ; SHORT if rti < lower band ;
//      BETWEEN the bands the previous state is HELD.
//
//  The hysteresis is the point: the state only changes on a real excursion out of
//  the band, not on every oscillation around a midline. That keeps the read stable
//  in noise, at the cost of turning slightly later than a raw crossover.
//
//  MACROCOVER (long bias)
//  ----------------------
//  If the state is SHORT while close is above the macro EMA, it covers to FLAT.
//  Rationale: shorting against the macro trend is where this family of range-position
//  signals tends to bleed. It never blocks longs — only shorts above the EMA.
//
//  LAGUERRE CONFLUENCE
//  -------------------
//  A 4-pole Ehlers Laguerre filter gives a second, independent trend read (the
//  slope of the filter). When the RTI state and the Laguerre slope AGREE, the read
//  has higher conviction — highlighted with a dot on the line and in the table.
//  The two are correlated but not identical; their AGREEMENT is the useful part,
//  not either one on its own.
//
//  TOP-DOWN 1D GATE (optional, ON by default)
//  ------------------------------------------
//  A higher-timeframe sanity check. It reads the AlphaTrend state of the PREVIOUS
//  COMPLETED DAY and, when the chart-timeframe state CONTRADICTS it (long here /
//  short on the daily, or vice versa), forces FLAT.
//
//  It never opens positions — it only removes the ones fighting the daily trend.
//
//  What to expect, honestly: the gate cuts a large share of the signals and, in my
//  own testing, consistently reduced drawdown — but it also gives up upside during
//  clean, sustained trends, precisely because it sits out the counter-daily entries
//  that sometimes work. Its benefit is concentrated in choppy and adverse regimes.
//
//  I could NOT establish it as a statistically significant return edge: it was the
//  best of many variants I tried, and once that selection is accounted for, the
//  statistical claim does not hold. What is consistent is the mechanism — fewer
//  trades, lower drawdown — so treat the gate as a RISK-MANAGEMENT overlay, not as
//  an alpha generator. Turn it off if you want the raw signal. Test it on your own
//  market and timeframe before relying on it.
//
//  NON-REPAINTING
//  --------------
//  The RTI, MacroCover and Laguerre are computed on the chart timeframe only — there
//  is no higher-timeframe request for the signal, so there is nothing there to repaint.
//  The gate makes the single request in the script, and it is built to be safe:
//  requesting `state[1]` inside request.security() REPAINTS on the realtime bar —
//  it returns the FORMING day's state instead of yesterday's (closed bars are fine,
//  the live bar flips mid-session). This script instead requests the daily state and
//  latches yesterday's FINAL value at each day change, so the gate is constant
//  intraday and uses only past data.
//
//  USAGE
//  -----
//  Works on any symbol and timeframe. Defaults are a starting point, not a
//  recommendation — the bands, lengths and the gate all change the character of the
//  signal and should be adapted to what you trade.
//  Not financial advice; for research and education.
// =============================================================================

indicator("RTI Trend State + MacroCover", shorttitle="RTI+MC", overlay=false)

grpE  = "RTI engine"
n     = input.int(30,  "Lookback n",        minval=2,  group=grpE, tooltip="Range window for the highest/lowest channel. Larger = slower and fewer flips.")
sm    = input.int(3,   "EMA smoothing",     minval=1,  group=grpE, tooltip="EMA applied to the raw 0-100 reading.")
hi    = input.float(55,"Upper band hi",     minval=50, maxval=100, group=grpE, tooltip="rti above this => LONG state. Widening the bands means fewer, later flips.")
lo    = input.float(45,"Lower band lo",     minval=0,  maxval=50,  group=grpE, tooltip="rti below this => SHORT state. Between the two bands the state is HELD (hysteresis).")

grpM  = "MacroCover (long bias)"
useMC = input.bool(true, "Cover shorts above the macro EMA", group=grpM, tooltip="If close > EMA(macro length), do not hold a SHORT: switch to FLAT. Longs are never blocked.")
mcLen = input.int(200, "Macro EMA",         minval=20, group=grpM)

grpL  = "Laguerre confluence"
useLag = input.bool(true, "Enable Laguerre read", group=grpL, tooltip="4-pole Ehlers Laguerre filter as a second trend read. Confluence = the RTI state agrees with the Laguerre slope.")
gLag   = input.float(0.6, "Laguerre gamma", step=0.05, minval=0.05, maxval=0.95, group=grpL, tooltip="Damping of the Laguerre filter. Lower = faster and noisier, higher = smoother and slower.")
lagSh  = input.int(2,   "Slope shift",      minval=1, maxval=5,     group=grpL, tooltip="How many bars back the slope of the filter is measured over.")

grpG  = "Top-down 1D gate"
useG    = input.bool(true, "Enable 1D gate (daily AlphaTrend)", group=grpG, tooltip="If the chart-timeframe state CONTRADICTS the AlphaTrend of the PREVIOUS COMPLETED DAY, force FLAT. It never opens positions, it only removes those fighting the daily trend. Expect noticeably fewer signals and smaller drawdowns, at the cost of upside during clean trends. Treat it as a risk overlay, not as an edge — turn it off for the raw signal.")
atCoeff = input.float(1.0, "  AlphaTrend coefficient", step=0.1, group=grpG, tooltip="ATR multiplier of the AlphaTrend band.")
atAp    = input.int(14,  "  AlphaTrend ATR length", minval=1, group=grpG)
atMom   = input.int(14,  "  AlphaTrend MFI/RSI length", minval=1, group=grpG, tooltip="Momentum gauge: MFI when volume is available, RSI otherwise.")

grpV  = "Visual"
showBG   = input.bool(true, "State background",   group=grpV)
showSig  = input.bool(true, "Flip markers",       group=grpV)
showConf = input.bool(true, "Confluence dots",    group=grpV)
showGat  = input.bool(true, "Mark bars vetoed by the 1D gate", group=grpV)
showTbl  = input.bool(true, "State table",        group=grpV)

f_rti(_h, _l, _c) =>
    hh  = ta.highest(_h, n)
    ll  = ta.lowest(_l, n)
    rng = hh - ll
    raw = 100.0 * (_c - ll) / (rng == 0 ? na : rng)
    ta.ema(raw, sm)

f_signal() =>
    _rti = f_rti(high, low, close)
    _ema = ta.ema(close, mcLen)
    var int st = 0
    dirn = _rti > hi ? 1 : _rti < lo ? -1 : 0
    if dirn != 0
        st := dirn
    _state = (useMC and st < 0 and close > _ema) ? 0 : st
    // Seeded with `close`, not 0: an IIR filter started at 0 climbs toward price for
    // ~20 bars, which forces a spurious LONG slope read at the start of the history.
    var float L0 = na
    var float L1 = na
    var float L2 = na
    var float L3 = na
    L0 := (1 - gLag) * close + gLag * nz(L0[1], close)
    L1 := -gLag * L0 + nz(L0[1], close) + gLag * nz(L1[1], close)
    L2 := -gLag * L1 + nz(L1[1], close) + gLag * nz(L2[1], close)
    L3 := -gLag * L2 + nz(L2[1], close) + gLag * nz(L3[1], close)
    lag = (L0 + 2 * L1 + 2 * L2 + L3) / 6.0
    var int lst = 0
    ld = math.sign(lag - lag[lagSh])
    if ld != 0
        lst := int(ld)
    _lstate = (useMC and lst < 0 and close > _ema) ? 0 : lst
    [_rti, _state, _ema, _lstate]

// AlphaTrend state, used only as the daily read for the gate:
//   atr = sma(tr, len) ; upT = low - atr*coeff ; downT = high + atr*coeff
//   at is recursive, driven by momentum (MFI >= 50 -> follow the up band, else the down band)
//   state = +1 from crossover(at, at[2]) until crossunder(at, at[2]).
// Both crosses are evaluated on EVERY bar (never inside a conditional branch) so their
// internal state stays consistent.
f_at_state() =>
    atrv  = ta.sma(ta.tr, atAp)
    upT   = low  - atrv * atCoeff
    downT = high + atrv * atCoeff
    mfiV  = ta.mfi(hlc3, atMom)
    rsiV  = ta.rsi(close, atMom)
    volMA = ta.sma(volume, 20)
    mom   = (not na(volMA) and volMA > 0) ? mfiV : rsiV
    var float at = na
    at := na(at[1]) ? hl2 : (na(mom) ? at[1] : (mom >= 50 ? (upT < at[1] ? at[1] : upT) : (downT > at[1] ? at[1] : downT)))
    buyX  = ta.crossover(at, at[2])
    sellX = ta.crossunder(at, at[2])
    var int ast = 0
    if buyX
        ast := 1
    else if sellX
        ast := -1
    ast

[rti, stBase, ema_m, lC] = f_signal()
lagSt = useLag ? lC : 0

// ---- Top-down 1D gate ----
// Daily state INCLUDING the forming day (this one does move intraday, by design).
atNow = request.security(syminfo.tickerid, "D", f_at_state(), lookahead=barmerge.lookahead_off)
// Latch YESTERDAY's FINAL state at each day change: on the first chart bar of a new day,
// atNow[1] is the value from the last bar of the previous day = that day's final state.
// Constant intraday, past data only -> no repaint, including the realtime bar.
isNewDay = ta.change(time("D")) != 0
var int at1d = na
if isNewDay
    at1d := int(nz(atNow[1], nz(at1d, 0)))

vetoed  = useG and not na(at1d) and ((stBase > 0 and at1d < 0) or (stBase < 0 and at1d > 0))
state   = vetoed ? 0 : stBase

conf    = useLag and state != 0 and state == lagSt

colUp = color.new(#26a69a, 0)
colDn = color.new(#ef5350, 0)
colFl = color.new(color.gray, 0)
colVt = color.new(#ffb74d, 0)
cLine = state > 0 ? colUp : state < 0 ? colDn : (vetoed ? colVt : colFl)

// The line carries the state; the dots on it carry the two per-bar qualifiers
// (Laguerre agreement, gate veto). Single-bar events live on the bottom/top rows.
plot(rti, "RTI", color=cLine, linewidth=2)
plot(showConf and conf ? rti : na, "Confluence", color=cLine, style=plot.style_circles, linewidth=3)
plot(showGat and vetoed ? rti : na, "Vetoed by the 1D gate", color=colVt, style=plot.style_circles, linewidth=3)
hline(hi, "hi",  color=color.new(color.teal, 40), linestyle=hline.style_dashed)
hline(lo, "lo",  color=color.new(color.red,  40), linestyle=hline.style_dashed)
hline(50, "mid", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

bg = state > 0 ? color.new(#26a69a, 88) : state < 0 ? color.new(#ef5350, 88) : (vetoed ? color.new(#ffb74d, 85) : na)
bgcolor(showBG ? bg : na, title="State background")

flipUp = state > 0 and state[1] <= 0
flipDn = state < 0 and state[1] >= 0
flipFl = state == 0 and state[1] != 0
plotshape(showSig and flipUp, "Long flip",   style=shape.triangleup,   location=location.bottom, color=colUp, size=size.tiny)
plotshape(showSig and flipDn, "Short flip",  style=shape.triangledown, location=location.top,    color=colDn, size=size.tiny)
plotshape(showSig and flipFl, "Cover/Flat",  style=shape.xcross,       location=location.bottom, color=colFl, size=size.tiny)

var table tb = table.new(position.top_right, 2, 6, border_width=1)
if showTbl and barstate.islast
    txt  = state > 0 ? "LONG" : state < 0 ? "SHORT" : (vetoed ? "FLAT (vetoed)" : "FLAT")
    col  = state > 0 ? colUp   : state < 0 ? colDn   : (vetoed ? colVt : colFl)
    ltxt = lagSt > 0 ? "LONG" : lagSt < 0 ? "SHORT" : "FLAT"
    lcol = lagSt > 0 ? colUp   : lagSt < 0 ? colDn   : colFl
    ctxt = conf ? (state > 0 ? "AGREE UP" : "AGREE DN") : "-"
    ccol = conf ? col : color.new(color.gray, 30)
    a1txt = na(at1d) ? "n/a" : at1d > 0 ? "LONG" : at1d < 0 ? "SHORT" : "FLAT"
    a1col = na(at1d) ? color.new(color.gray, 30) : at1d > 0 ? colUp : at1d < 0 ? colDn : colFl
    gtxt  = not useG ? "off" : vetoed ? "VETOING" : "pass"
    table.cell(tb, 0, 0, "RTI",        text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(tb, 1, 0, str.tostring(rti, "#.0"), text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(tb, 0, 1, "State",      text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(tb, 1, 1, txt,          text_color=color.white, bgcolor=col)
    table.cell(tb, 0, 2, "Laguerre",   text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(tb, 1, 2, useLag ? ltxt : "off", text_color=color.white, bgcolor=useLag ? lcol : color.new(color.gray, 30))
    table.cell(tb, 0, 3, "Confluence", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(tb, 1, 3, ctxt,         text_color=color.white, bgcolor=ccol)
    table.cell(tb, 0, 4, "Daily AT (prev)", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(tb, 1, 4, a1txt,        text_color=color.white, bgcolor=a1col)
    table.cell(tb, 0, 5, "1D gate",    text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(tb, 1, 5, gtxt,         text_color=color.white, bgcolor=vetoed ? colVt : color.new(color.black, 40))

alertcondition(flipUp, "RTI flip LONG",  "RTI: turned LONG")
alertcondition(flipDn, "RTI flip SHORT", "RTI: turned SHORT")
alertcondition(flipFl, "RTI cover/flat", "RTI: went FLAT")
alertcondition(conf and not conf[1], "RTI+Laguerre confluence", "RTI and Laguerre agree on trend direction")
alertcondition(vetoed and not vetoed[1], "1D gate starts vetoing", "RTI: the 1D gate vetoes the position (chart timeframe contradicts yesterday's daily AlphaTrend)")

plot(state,  "state_-1_0_1", display=display.data_window)
plot(stBase, "state_ungated", display=display.data_window)
plot(at1d,   "daily_at_prev", display=display.data_window)
plot(vetoed ? 1 : 0, "vetoed", display=display.data_window)
plot(lagSt,  "laguerre_-1_0_1", display=display.data_window)
plot(conf ? 1 : 0, "confluence", display=display.data_window)
plot(ema_m,  "ema_macro",    display=display.data_window)
````
