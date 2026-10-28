# Momentum + 75M Volume Breakout

- url: https://www.tradingview.com/script/jnVUFp2y-Momentum-75M-Volume-Breakout/
- type: indicator
- pine_id: PUB;0fd6d268933e4863af64e557272cf031
- version: 1.0

## Description

This looks for Momentum along with Volatility and Volume breakout in 75 M time frame

## Source Code

````pine
//@version=6
// =============================================================
// Momentum + 75M Volume Breakout Scanner
// -------------------------------------------------------------
// Daily filters (any of):
//   6M RoC > 50%  OR  3M RoC > 40%  OR  1M RoC > 7%
// AND on DAILY:
//   (ATR(20) / Daily Close) × 100  >  5%
// AND on the 75-min chart:
//   price stretched: C > 9/21/50/200 EMA*1.015  OR  C > 4DH*1.05
//   AND C > O (green bar)
//   AND CBV > 105-EMA(vol) + 3·SD(vol)         ← "3SDV" volume blow-out
//
// HOW TO USE
//   1. Apply on a 75-minute chart (TV Pro+ for custom interval).
//   2. Right-click the indicator > Add alert > select
//      "Momentum + Volume Breakout" > frequency: ONCE PER BAR CLOSE.
//   3. Open Data Window (Ctrl+Alt+D / Cmd+Opt+D) to inspect every
//      internal value (EMAs, markups, ATR, ATR%, volume metrics,
//      each boolean leg, and the final signal) at cursor position.
// =============================================================
indicator("Momentum + 75M Volume Breakout", overlay=true, max_bars_back=1000)

// ---------- INPUTS ----------
gMom = "Daily Momentum (RoC)"
roc6mTh = input.float(50.0, "6-Month RoC % >",         group=gMom)
roc3mTh = input.float(40.0, "3-Month RoC % >",         group=gMom)
roc1mTh = input.float(7.0,  "1-Month RoC % > (CTO)",   group=gMom)

gVol = "Volatility (ATR % of Close — daily)"
atrLen   = input.int(20,    "ATR Length (daily)",      group=gVol)
atrPctTh = input.float(5.0, "ATR % of Close >",        group=gVol)

gCut = "Cutting (Price Stretch)"
emaBufPct = input.float(1.5, "EMA Buffer %",           group=gCut)
dhBufPct  = input.float(5.0, "4-Day-High Breakout %",  group=gCut)

gVB = "Volume Breakout (3SDV)"
volEmaLen = input.int(105, "Volume EMA Length",        group=gVB)
sdMult    = input.float(3.0,"SD Multiplier",           group=gVB)

emaBuf = emaBufPct / 100.0
dhBuf  = dhBufPct  / 100.0

// ---------- DAILY CONTEXT (lookahead-safe) ----------
// Trading-day approximations: 6M≈126, 3M≈63, 1M≈21
// dh4      = prior 4-day high (excludes today)
// atrD     = 20-period Wilder ATR on daily bars
// atrPct   = (atrD / dailyClose) × 100
[roc6m, roc3m, roc1m, dh4, atrD, atrPct] = request.security(
     syminfo.tickerid, "D",
     [(close / close[126] - 1) * 100,
      (close / close[63]  - 1) * 100,
      (close / close[21]  - 1) * 100,
      ta.highest(high, 4)[1],
      ta.atr(atrLen),
      (ta.atr(atrLen) / close) * 100],
     lookahead = barmerge.lookahead_off)

momentumOK = (roc6m > roc6mTh) or (roc3m > roc3mTh) or (roc1m > roc1mTh)

// ---------- 75-MIN INDICATORS ----------
volOK  = atrPct > atrPctTh

ema9   = ta.ema(close, 9)
ema21  = ta.ema(close, 21)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

cuttingOK = (close > ema9   * (1 + emaBuf) or
             close > ema21  * (1 + emaBuf) or
             close > ema50  * (1 + emaBuf) or
             close > ema200 * (1 + emaBuf) or
             close > dh4    * (1 + dhBuf))

greenOK = close > open

vEma = ta.ema(volume, volEmaLen)
vSd  = ta.stdev(volume, volEmaLen)
threshold3SDV = vEma + sdMult * vSd
volBreakoutOK = volume > threshold3SDV

// ---------- FINAL ----------
signal = momentumOK and volOK and cuttingOK and greenOK and volBreakoutOK

// ---------- ON-CHART VISUALS ----------
plot(ema9,   "EMA 9",   color=color.new(color.yellow, 0))
plot(ema21,  "EMA 21",  color=color.new(color.orange, 0))
plot(ema50,  "EMA 50",  color=color.new(color.aqua,   0))
plot(ema200, "EMA 200", color=color.new(color.red,    0))

// Historical + live signal arrows — Pine renders one on every past
// bar where `signal` was true, automatically covering the last 100+
// bars (and more if zoomed out).
plotshape(signal, "Signal Arrow", style=shape.triangleup,
          location=location.belowbar, color=color.lime,
          size=size.normal, text="GO", textcolor=color.white)
bgcolor(signal ? color.new(color.green, 80) : na, title="Signal Bg")

// ---------- DATA WINDOW (off-chart values for cursor inspection) ----------
// These don't render on the chart; they only show up in the Data Window
// (View → Data Window, or Ctrl+Alt+D / Cmd+Opt+D) at the cursor location.
plot(ema9   * (1 + emaBuf),  "EMA9 × 1.015",    display=display.data_window)
plot(ema21  * (1 + emaBuf),  "EMA21 × 1.015",   display=display.data_window)
plot(ema50  * (1 + emaBuf),  "EMA50 × 1.015",   display=display.data_window)
plot(ema200 * (1 + emaBuf),  "EMA200 × 1.015",  display=display.data_window)
plot(dh4,                    "4-Day High",      display=display.data_window)
plot(dh4    * (1 + dhBuf),   "4DH × 1.05",      display=display.data_window)

plot(roc6m,                  "6M RoC %",        display=display.data_window)
plot(roc3m,                  "3M RoC %",        display=display.data_window)
plot(roc1m,                  "1M RoC %",        display=display.data_window)

plot(atrD,                   "ATR(20) daily",   display=display.data_window)
plot(atrPct,                 "ATR % of Close",  display=display.data_window)

plot(volume,                 "Volume",          display=display.data_window)
plot(vEma,                   "Vol EMA(105)",    display=display.data_window)
plot(vSd,                    "Vol SD(105)",     display=display.data_window)
plot(threshold3SDV,          "3SDV threshold",  display=display.data_window)
plot(volume / threshold3SDV, "Vol / 3SDV",      display=display.data_window)

// Booleans as 1/0 so you can see exactly which legs are passing
plot(momentumOK    ? 1 : 0, "✓ Momentum",       display=display.data_window)
plot(volOK         ? 1 : 0, "✓ Volatility",     display=display.data_window)
plot(cuttingOK     ? 1 : 0, "✓ Cutting",        display=display.data_window)
plot(greenOK       ? 1 : 0, "✓ Green bar",      display=display.data_window)
plot(volBreakoutOK ? 1 : 0, "✓ Vol breakout",   display=display.data_window)
plot(signal        ? 1 : 0, "★ FINAL Signal",   display=display.data_window)

// ---------- DIAGNOSTIC TABLE (always-on, top-right) ----------
var table dbg = table.new(position.top_right, 2, 8, border_width=1)
if barstate.islast
    table.cell(dbg, 0, 0, "6M RoC %",      bgcolor=color.gray, text_color=color.white)
    table.cell(dbg, 1, 0, str.tostring(roc6m,  "#.##"))
    table.cell(dbg, 0, 1, "3M RoC %",      bgcolor=color.gray, text_color=color.white)
    table.cell(dbg, 1, 1, str.tostring(roc3m,  "#.##"))
    table.cell(dbg, 0, 2, "1M RoC %",      bgcolor=color.gray, text_color=color.white)
    table.cell(dbg, 1, 2, str.tostring(roc1m,  "#.##"))
    table.cell(dbg, 0, 3, "ATR(20) daily", bgcolor=color.gray, text_color=color.white)
    table.cell(dbg, 1, 3, str.tostring(atrD,    "#.##"))
    table.cell(dbg, 0, 4, "ATR % Close",   bgcolor=color.gray, text_color=color.white)
    table.cell(dbg, 1, 4, str.tostring(atrPct,  "#.##"),
               bgcolor = volOK ? color.new(color.green, 70) : color.new(color.red, 70))
    table.cell(dbg, 0, 5, "Vol / 3SDV",    bgcolor=color.gray, text_color=color.white)
    table.cell(dbg, 1, 5, str.tostring(volume / threshold3SDV, "#.##"),
               bgcolor = volBreakoutOK ? color.new(color.green, 70) : color.new(color.red, 70))
    table.cell(dbg, 0, 6, "Cutting",       bgcolor=color.gray, text_color=color.white)
    table.cell(dbg, 1, 6, cuttingOK ? "YES" : "NO",
               bgcolor = cuttingOK ? color.new(color.green, 50) : color.new(color.red, 50))
    table.cell(dbg, 0, 7, "Signal",        bgcolor=color.gray, text_color=color.white)
    table.cell(dbg, 1, 7, signal ? "YES" : "NO",
               bgcolor = signal ? color.green : color.red, text_color=color.white)

// ---------- ALERT ----------
alertcondition(signal, title="Momentum + Volume Breakout",
     message="🚀 {{ticker}} 75M signal | C={{close}} | check 9/21/50/200 EMA stretch + 3SDV vol blow-out")
````
