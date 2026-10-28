# CPI Gate Regime v3.1 (SMA)

- url: https://www.tradingview.com/script/5AkMU95d-CPI-Gate-Regime-v3-1-SMA/
- type: indicator
- pine_id: PUB;84def996b75348b1afc944b1638064ee
- version: 1.0

## Description

CPI Gate Regime v3.1 (SMA)

A daily trend + macro-regime dashboard built for trading TQQQ, using QQQ as the regime instrument. The trend signal runs on the TQQQ chart you apply it to; the bear-market classifier deliberately measures the underlying index (QQQ), because the index defines the market regime while the leveraged ETF is only the vehicle.

What chart to use it on

Apply it to the TQQQ daily chart (or another QQQ-tracking vehicle you trade). The moving-average signal computes on the chart symbol — on TQQQ, the lines are TQQQ's own 200-day and 20-day SMAs. The bear latch, however, always reads QQQ's drawdown, regardless of chart symbol. This is intentional: a −15% drawdown in QQQ corresponds to roughly a −40% move in TQQQ, and measuring the regime on the noisier 3x series would latch it on ordinary corrections. Index for the regime, leveraged ETF for the trade.

The idea

Not all bear markets are the same shape. Fast crashes in low-inflation environments (2018, 2020) tend to V-bottom, and a fast re-entry catches the recovery early. Grinding bears in high-inflation environments (2000–02, 2022) chop down for months, and the same fast re-entry buys every failed rally. The differentiator used here: when CPI is above ~3%, the central bank is constrained (cutting into hot inflation is hard), so declines are more likely to grind. When CPI is below 3%, policy support is available and declines are more likely to snap back.

Trend signal (two-speed, on the chart symbol — TQQQ)

200-day and 20-day simple moving averages of the daily close, computed on daily bars regardless of chart timeframe. Lines plot green when the close is above them, red when below.
The rule: LONG when the close is above the 200-day SMA, or (below it) above the 20-day SMA; FLAT only below both. Above the 200-day the position is locked long and the 20-day is ignored — the fast line only becomes active below the 200, where it serves as the early re-entry during a recovery.
In a latched GRIND bear (see below), the 20-day re-entry is disabled entirely — only a full 200-day reclaim signals a buy.
Signals on the chart

Exactly two marker types, printed only when the complete system flips: a green BUY label below the bar, a red SELL label above it. No markers on ordinary 20-day crosses (they don't change the position above the 200-day), and no markers on 20-day re-entries during a grind bear (the system refuses those trades). What you see marked is what the rule set actually does. Signals form on the daily close; execution is assumed at the next open.

The latched bear regime (the "CPI gate", on QQQ)

A bear LATCHES when QQQ closes 15% or more below its trailing 2-year high.
At that moment — once — the classifier checks CPI YoY: above the gate (default 3%) = GRIND, below = SNAP.
Latched means latched: the mode does not flip-flop with daily data. One-way upgrade only: SNAP can become GRIND if CPI heats up mid-bear, never the reverse.
The latch releases when QQQ recovers to within 5% of its 2-year high.
Effect on signals: GRIND kills the fast re-entry (200-day reclaim only); SNAP keeps the normal two-speed.
Dashboard (early warnings, top right)

CPI YoY vs the gate (ECONOMICS:USIRYY)
FINRA margin debt YoY — manual input; elevated / blow-off thresholds
High-yield credit spread (FRED:BAMLH0A0HYM2) — waking / stress thresholds
QQQ drawdown from its 2-year peak — heads-up at −10%, trigger at −15%
Regime label escalates: CALM → FRAGILITY BUILDING (hot CPI + elevated margin) → STRESS IGNITING (credit spreads waking) → BEAR: SNAP or GRIND (latched)
Only the −15% / CPI latch changes the signals; the other rows are context so a latch never arrives as a surprise.

Inputs

All thresholds are configurable: SMA lengths, CPI gate %, margin elevated/blow-off %, HY spread waking/stress (bps), drawdown heads-up/trigger %, and the CPI / HY spread symbols. Margin debt YoY is entered manually (FINRA publishes monthly).

Notes

Designed on daily bars; on intraday charts the signal stays locked to daily data. The bear-latch state on historical bars is computed from the chart's loaded history, so labels at the far left edge of a short history may differ from a fully loaded chart; current-bar state is unaffected. For educational purposes — this is a regime framework, not financial advice. Test any rule set yourself before trading it.

v3.1 — markers now show only full-system BUY/SELL signals (including the grind-bear gate); removed the 20-day cross dots and 200-day flip triangles.

## Source Code

````pine
//@version=6
// CPI GATE REGIME v3.1 - close-SMA canon (FVB retired 2026-08-18, see tqqq-sma-bot
// docs/SIGNAL_CANON.md). Signal = the LIVE bot's rule: close vs the 200-day and
// 20-day SMAs of the DAILY close (green = close above the line). Two-speed:
// LONG above SMA200, or (below it) above SMA20; FLAT below both — and in a
// latched GRIND bear the 20-day re-entry is DEAD (200-reclaim only).
// v3.1 (Aleks): markers are ONLY the full-system BUY/SELL flips — no dots on
// 20-SMA crosses, no 200-flip triangles. Lines still color green/red.
// Both SMAs computed on DAILY bars regardless of chart timeframe.
indicator("CPI Gate Regime v3.1 (SMA)", overlay = true)

// ---------------- SETTINGS ----------------
lenSlow    = input.int(200, "slow SMA (daily)")
lenFast    = input.int(20, "fast SMA (daily)")
marginYoY  = input.float(54.0, "FINRA margin YoY % (manual)", step = 0.5)
cpiGate    = input.float(3.0, "CPI grind gate %")
marginElev = input.float(40.0, "Margin elevated %")
marginBlow = input.float(60.0, "Margin blow-off %")
spreadWake = input.float(450.0, "HY spread waking (bps)")
spreadHot  = input.float(600.0, "HY spread stress (bps)")
ddHeadsUp  = input.float(-10.0, "QQQ drawdown heads-up %")
ddTrigger  = input.float(-15.0, "QQQ drawdown trigger %")
cpiSym     = input.symbol("ECONOMICS:USIRYY", "CPI YoY symbol")
hySym      = input.symbol("FRED:BAMLH0A0HYM2", "HY spread symbol")

// ---------------- DAILY-LOCKED SMA SIGNAL ----------------
// On a DAILY chart, compute directly on chart bars: honest in bar replay
// (request.security does not truncate properly in replay). On other TFs,
// fall back to the security call to keep the 200/20-DAY lock.
smaSig(int length) =>
    float basis = ta.sma(close, length)
    bool grn = not na(basis) and close > basis
    [basis, grn]

tid = syminfo.tickerid
off = barmerge.lookahead_off
isD = timeframe.isdaily
[sSlowC, gSlowC] = smaSig(lenSlow)
[sFastC, gFastC] = smaSig(lenFast)
[sSlowS, gSlowS] = request.security(tid, "D", smaSig(lenSlow), lookahead = off)
[sFastS, gFastS] = request.security(tid, "D", smaSig(lenFast), lookahead = off)
smaSlow = isD ? sSlowC : sSlowS
smaFast = isD ? sFastC : sFastS
green200 = isD ? gSlowC : gSlowS
green20  = isD ? gFastC : gFastS

c200 = green200 ? #089981 : #F23645
c20  = green20 ? #089981 : #F23645

plot(smaSlow, "SMA200 (daily)", color = c200, linewidth = 2)
plot(smaFast, "SMA20 (daily)", color = color.new(c20, 30), linewidth = 1)

// ---------------- REGIME DATA ----------------
cpiYoY = request.security(cpiSym, "M", close, lookahead = off)
hyBps = request.security(hySym, "D", close, lookahead = off) * 100
qqqHi = ta.highest(close, 504)
[qqqC, qqqPk] = request.security("QQQ", "D", [close, qqqHi], lookahead = off)
qqqDD = (qqqC / qqqPk - 1) * 100

cpiHot = cpiYoY > cpiGate
mgElev = marginYoY >= marginElev
mgBlow = marginYoY >= marginBlow
spWake = hyBps >= spreadWake
spHot  = hyBps >= spreadHot
ddWarn = qqqDD <= ddHeadsUp
ddTrig = qqqDD <= ddTrigger

// LATCHED bear regime (Aleks's rule): mode decided ONCE at the -15% trigger,
// held until QQQ recovers to within 5% of its trailing 2yr high. One-way:
// snap can upgrade to grind mid-bear, never downgrade.
var bool inBear = false
var bool bearGrind = false
if not inBear and ddTrig
    inBear := true
    bearGrind := cpiHot
if inBear and qqqDD >= -5.0
    inBear := false
if inBear and not bearGrind and cpiHot
    bearGrind := true

// ---------------- SYSTEM BUY / SELL SIGNALS ----------------
// The COMPLETE rule, exactly as the live bot trades it: two-speed target
// (LONG above SMA200, or below it above SMA20; FLAT below both), EXCEPT in a
// latched GRIND bear where the 20-day re-entry is DEAD and only a 200-SMA
// reclaim buys. Markers print ONLY when this full-system target flips —
// a 20-SMA cross while price is above the 200 changes nothing and plots nothing.
sysLong = bearGrind ? green200 : (green200 or green20)
buySig  = sysLong and not sysLong[1]
sellSig = not sysLong and sysLong[1]
plotshape(buySig, "BUY signal", shape.labelup, location.belowbar,
     color.new(color.green, 0), size = size.small, text = "BUY", textcolor = color.white)
plotshape(sellSig, "SELL signal", shape.labeldown, location.abovebar,
     color.new(color.red, 0), size = size.small, text = "SELL", textcolor = color.white)

var string regime = ""
var color regCol = color.green
if inBear
    regime := bearGrind ? "BEAR: GRIND (latched)" : "BEAR: SNAP (latched)"
    regCol := color.red
else if spWake
    regime := "STRESS IGNITING"
    regCol := color.orange
else if cpiHot and mgElev
    regime := "FRAGILITY BUILDING"
    regCol := color.yellow
else
    regime := "CALM"
    regCol := color.green

// ---------------- DASHBOARD ----------------
var table t = table.new(position.top_right, 3, 7, border_width = 1)
chk(bool bad) => bad ? "X" : "OK"
chkCol(bool bad) => bad ? color.new(color.red, 20) : color.new(color.green, 60)
sSm = size.small

cpiTxt = str.tostring(cpiYoY, "#.#") + "%"
mgTxt  = str.tostring(marginYoY, "#.#") + "%" + (mgBlow ? " BLOW-OFF" : "")
hyTxt  = str.tostring(hyBps, "#") + " bps"
ddTxt  = str.tostring(qqqDD, "#.#") + "%"
mgCol  = mgBlow ? color.new(color.red, 0) : chkCol(mgElev)
hyCol  = spHot ? color.new(color.red, 0) : chkCol(spWake)
ddCol  = ddTrig ? color.new(color.red, 0) : chkCol(ddWarn)
g200Col = green200 ? color.new(color.green, 60) : color.new(color.red, 20)
g20Col  = green20 ? color.new(color.green, 60) : color.new(color.red, 20)

if barstate.islast
    table.cell(t, 0, 0, "REGIME v3", text_color = color.white,
         bgcolor = color.new(color.black, 20), text_size = sSm)
    table.cell(t, 1, 0, regime, text_color = color.black,
         bgcolor = regCol, text_size = sSm)
    table.cell(t, 2, 0, "", bgcolor = regCol)
    fg = chart.fg_color
    table.cell(t, 0, 1, "CPI YoY", text_color = fg, text_size = sSm)
    table.cell(t, 1, 1, cpiTxt, text_color = fg, text_size = sSm)
    table.cell(t, 2, 1, chk(cpiHot), text_color = fg, bgcolor = chkCol(cpiHot), text_size = sSm)
    table.cell(t, 0, 2, "Margin YoY (manual)", text_color = fg, text_size = sSm)
    table.cell(t, 1, 2, mgTxt, text_color = fg, text_size = sSm)
    table.cell(t, 2, 2, chk(mgElev), text_color = fg, bgcolor = mgCol, text_size = sSm)
    table.cell(t, 0, 3, "HY spread", text_color = fg, text_size = sSm)
    table.cell(t, 1, 3, hyTxt, text_color = fg, text_size = sSm)
    table.cell(t, 2, 3, chk(spWake), text_color = fg, bgcolor = hyCol, text_size = sSm)
    table.cell(t, 0, 4, "QQQ dd (2yr peak)", text_color = fg, text_size = sSm)
    table.cell(t, 1, 4, ddTxt, text_color = fg, text_size = sSm)
    table.cell(t, 2, 4, chk(ddWarn), text_color = fg, bgcolor = ddCol, text_size = sSm)
    table.cell(t, 0, 5, "SMA 200D", text_color = fg, text_size = sSm)
    table.cell(t, 1, 5, green200 ? "GREEN" : "RED", text_color = fg, text_size = sSm)
    table.cell(t, 2, 5, green200 ? "OK" : "X", text_color = fg, bgcolor = g200Col, text_size = sSm)
    table.cell(t, 0, 6, "SMA 20D", text_color = fg, text_size = sSm)
    table.cell(t, 1, 6, green20 ? "GREEN" : "RED", text_color = fg, text_size = sSm)
    table.cell(t, 2, 6, green20 ? "OK" : "X", text_color = fg, bgcolor = g20Col, text_size = sSm)
````
