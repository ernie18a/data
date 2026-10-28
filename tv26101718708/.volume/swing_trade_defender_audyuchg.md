# Swing Trade Defender

- url: https://www.tradingview.com/script/AUDyUchG-Swing-Trade-Defender/
- type: indicator
- pine_id: PUB;4fe6b42f831d4eed9d09a8fba684fd23
- version: 2.0

## Description

You're in a trade. Defender watches it for the five ways swing trades fail — plus an ATR trailing stop — and shows one status: OK, CAUTION, or EXIT.


Finding the trade is the easy half. The hard half is admitting when it stops working — and doing it before a small loss becomes a big one. Swing Trade Defender watches your open trade bar by bar and does the admitting for you.

Set your direction (long or short) and, if you want, your entry price. It handles the rest — it works on its own, nothing else required.

[b] Why five flags instead of one exit signal?[/b]

 Every one of these signals fires false alarms by itself — an RSI dip, a single heavy-volume red bar, a wick through the 20 EMA. 
Real trade failure rarely announces itself through one signal; it shows up as agreement between independent ones: trend, structure, momentum, participation, and volatility.

 So Defender treats them as a vote. One or two flags is a warning to pay attention; three is a failed trade by definition — enough independent evidence that the odds have flipped. The one exception is the ATR trail, which triggers EXIT on its own, because a stop is a stop. The voting logic — not any individual component — is the tool.

[b] The five failure flags — each worth 1 point[/b]

[list]
[*] [b]Trend break[/b] — price closes through the 20-EMA (the trend's home line) the wrong way.
[*] [b]Structure break[/b] — price takes out the prior swing low (for a long), the first crack in the pattern.
[*] [b]Momentum rollover[/b] — RSI falls back through 50 and keeps dropping.
[*] [b]Distribution[/b] — a down bar on 1.5× average volume or more: big sellers showing their hand.
[*] [b]Trail hit[/b] — price closes through the ATR trailing stop (a chandelier-style stop that ratchets up behind price, 2.5 × ATR-14 by default; ATR = average bar range).
[/list]

All five flip automatically for shorts — there a [i]close above[/i] the MA, a break of the prior [i]swing  high[/i],[i] rising RS[/i]I, and heavy buying (accumulation) are the danger signs.

 [b]How the status reads[/b]
[list]
[*] [b]OK[/b] — no flags. Let it work.
[*] [b]CAUTION[/b] (1–2 flags) — an orange triangle marks the bar. Hover it and a tooltip lists exactly which flags are up.
[*] [b]EXIT[/b] — 3 or more flags (you can set the threshold), [b]or any trail hit on its own[/b]. A red ✕ marks the bar, with a box listing what failed.
[/list]
Markers sit above the bar for longs and below it for shorts, so they never crowd the side your risk is on.

 [b]The status panel[/b]

One table shows the whole picture: status, flag count (x/5), each flag's own line (hold/break), the live ATR trail price, your entry, and open P/L when you've set an entry price.

[b] Alerts[/b]
Two built-in alert conditions — "Exit signal" and "Caution" — so TradingView can ping your phone instead of you watching the screen.

[b] Settings — defaults work out of the box[/b]

Tuned for swing trades held days to weeks:
[list]
[*] Trend MA length (20), swing lookback (8 bars), RSI length (14) and rollover level (50), volume spike multiple (1.5×).
[*]  ATR trail — length (14) and multiple (2.5).
[*]  Flags needed for EXIT (3 by default, 1–5).
[*]  Panel position/size, marker history on/off, optional background shading, dark/light theme, colors.
[/list]

⚠ Educational risk-management tool. EXIT means the trade has failed by these rules — whether to act is always your decision. It does not place orders, and a flag is not a prediction. Not financial advice.

## Source Code

````pine
//@version=6
// Swing Trade Defender — guards ONE trade (the chart symbol).
// Set your direction + entry; it watches 5 failure flags + an ATR trailing stop and
// flags CAUTION / EXIT.
//
// 2026-08-12 — display fix. The open P/L % row was formatted with "#.1". Only # and 0
// are digit placeholders in a Pine format string, so the digit after the decimal was
// printed literally and the value rounded to a whole number: +2.4% displayed as "+2.1%".
// The P/L calculation was always correct — only the printed text was wrong.
indicator("Swing Trade Defender", shorttitle="Defender", overlay=true, max_labels_count=200)

// ───────── Trade (the position you're guarding) ─────────
grpTrade = "Trade"
dir      = input.string("Long", "Direction", options=["Long","Short"], group=grpTrade)
entryPx  = input.price(0.0, "Entry price (optional — for Open P/L)", group=grpTrade)

grpTrend = "Signals"
maLen    = input.int(20, "Trend MA length (EMA)", minval=2, group=grpTrend)
swingLb  = input.int(8,  "Swing structure lookback", minval=2, group=grpTrend)
rsiLen   = input.int(14, "RSI length", minval=2, group=grpTrend)
rsiRoll  = input.int(50, "RSI rollover level", minval=1, maxval=99, group=grpTrend)
volMult  = input.float(1.5, "Volume spike x avg", minval=1.0, step=0.1, group=grpTrend)
volLen   = input.int(20, "Volume average length", minval=2, group=grpTrend)

grpStop  = "Trailing stop"
atrLen   = input.int(14, "ATR length", minval=1, group=grpStop)
atrMult  = input.float(2.5, "ATR trailing multiple", minval=0.5, step=0.1, group=grpStop)

grpScore = "Alerting"
exitScore = input.int(3, "Flags needed for EXIT", minval=1, maxval=5, group=grpScore)

grpDash = "Status Panel"
showPanel = input.bool(true, "Show status panel", group=grpDash)
panelPos  = input.string("Top Right", "Panel position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grpDash)
panelSize = input.string("Normal", "Panel text size", options=["Tiny","Small","Normal","Large"], group=grpDash)

grpMarks = "On-chart markers"
showPastLabels = input.bool(false, "Show past EXIT labels (off = latest only)", group=grpMarks)
showPastMarks  = input.bool(true,  "Show past ✕ / ▼ markers", group=grpMarks)
showShade      = input.bool(false, "Background shading", group=grpMarks)

grpTheme = "Theme & Colors"
darkMode  = input.bool(true, "Dark theme (uncheck for light charts)", group=grpTheme)
colMA     = input.color(#4789d1, "Trend MA line", group=grpTheme)
colTrail  = input.color(#f23645, "ATR trail line", group=grpTheme)
colExit   = input.color(#f23645, "EXIT", group=grpTheme, inline="c1")
colCaut   = input.color(#ff9800, "Caution", group=grpTheme, inline="c1")
colOK     = input.color(#089981, "OK", group=grpTheme, inline="c1")
maWidth   = input.int(2, "Trend MA width", minval=1, maxval=5, group=grpTheme)
trailWidth= input.int(1, "ATR trail width", minval=1, maxval=5, group=grpTheme)
labelSize = input.string("Small", "EXIT label size", options=["Tiny","Small","Normal","Large"], group=grpTheme)

isLong   = dir == "Long"
hasEntry = entryPx > 0

// ───────── Building blocks ─────────
ma  = ta.ema(close, maLen)
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)

priorSwingLow  = ta.lowest(low, swingLb)[1]
priorSwingHigh = ta.highest(high, swingLb)[1]

// ATR trailing stop (chandelier-style)
var float trail = na
if isLong
    longStop = ta.highest(high, atrLen) - atr * atrMult
    trail := na(trail) ? longStop : (close > trail ? math.max(trail, longStop) : longStop)
else
    shortStop = ta.lowest(low, atrLen) + atr * atrMult
    trail := na(trail) ? shortStop : (close < trail ? math.min(trail, shortStop) : shortStop)

// ───────── Failure flags ─────────
fTrend = isLong ? close < ma          : close > ma
fStruct= isLong ? low < priorSwingLow : high > priorSwingHigh
fMom   = isLong ? (rsi < rsiRoll and rsi < rsi[1]) : (rsi > (100 - rsiRoll) and rsi > rsi[1])
fDist  = isLong ? (close < open and volume > volAvg * volMult) : (close > open and volume > volAvg * volMult)
fTrail = isLong ? close < trail       : close > trail

score = (fTrend?1:0) + (fStruct?1:0) + (fMom?1:0) + (fDist?1:0) + (fTrail?1:0)

caution = score >= 1 and score < exitScore
exitSig = score >= exitScore or fTrail

// Open P/L from your entry
chartPL = hasEntry ? (isLong ? (close - entryPx) / entryPx * 100 : (entryPx - close) / entryPx * 100) : na

// ───────── Plots ─────────
plot(ma,    "Trend MA", color=colMA, linewidth=maWidth)
plot(trail, "ATR trail", color=color.new(colTrail, 30), style=plot.style_stepline, linewidth=trailWidth)

// Background shading — off by default for a clean chart.
bgcolor(showShade ? (exitSig ? color.new(colExit, 85) : caution ? color.new(colCaut, 90) : na) : na)

// EXIT marker — ABOVE the bar for longs, BELOW for shorts (history or latest only per "past markers")
markGate = showPastMarks or barstate.islast
exitNew  = markGate and exitSig and not exitSig[1]
plotshape(exitNew and isLong,     "EXIT (long)",  shape.xcross, location.abovebar, colExit, size=size.small, text="EXIT", textcolor=color.white)
plotshape(exitNew and not isLong, "EXIT (short)", shape.xcross, location.belowbar, colExit, size=size.small, text="EXIT", textcolor=color.white)

labelSz = switch labelSize
    "Tiny"  => size.tiny
    "Normal"=> size.normal
    "Large" => size.large
    =>         size.small

// Direction-aware wording: a short fails when momentum turns UP and buyers accumulate.
momTxt  = isLong ? "• Momentum down\n"  : "• Momentum up\n"
distTxt = isLong ? "• Distribution\n"   : "• Accumulation\n"

// EXIT info-box — anchors above the bar (long) or below it (short). Latest-only by default.
var label lastExit = na
if exitSig and not exitSig[1]
    txt = "Exit (" + str.tostring(score) + " flags)\n" +
          (fTrend  ? "• Trend break\n"   : "") +
          (fStruct ? "• Structure break\n": "") +
          (fMom    ? momTxt  : "") +
          (fDist   ? distTxt : "") +
          (fTrail  ? "• Trail hit"        : "")
    boxY  = isLong ? high : low
    boxSty = isLong ? label.style_label_down : label.style_label_up
    if showPastLabels
        label.new(bar_index, boxY, txt, style=boxSty, color=colExit, textcolor=color.white, size=labelSz)
    else
        label.delete(lastExit)
        lastExit := label.new(bar_index, boxY, txt, style=boxSty, color=colExit, textcolor=color.white, size=labelSz)

// CAUTION marker — orange triangle (▽ above for longs, △ below for shorts) with a hover tooltip.
var label lastCaut = na
if caution and not caution[1] and markGate
    cautTip = "CAUTION — " + str.tostring(score) + (score == 1 ? " flag raised\n" : " flags raised\n") +
          (fTrend  ? "• Trend break\n"    : "") +
          (fStruct ? "• Structure break\n": "") +
          (fMom    ? momTxt  : "") +
          (fDist   ? distTxt : "") +
          (fTrail  ? "• Trail hit"        : "")
    cY   = isLong ? high : low
    cSty = isLong ? label.style_triangledown : label.style_triangleup
    if showPastMarks
        label.new(bar_index, cY, "", style=cSty, color=colCaut, size=size.tiny, tooltip=cautTip)
    else
        label.delete(lastCaut)
        lastCaut := label.new(bar_index, cY, "", style=cSty, color=colCaut, size=size.tiny, tooltip=cautTip)

// ───────── Theme ─────────
// BlueBeck brand: navy #0a1527 · gold #c0a571 · blue #4789d1
c_navy   = #0a1527
c_gold   = #c0a571
c_bodyBg = darkMode ? color.new(#0e1a2f, 6) : color.new(#ffffff, 4)
c_lbl    = darkMode ? #9aa4b2 : #5b6470
c_txt    = darkMode ? #e8e8ec : #0a1527
c_grid   = darkMode ? color.new(#2a3950, 0) : color.new(#d0d4dc, 0)

// ───────── Status panel ─────────
ppos = switch panelPos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    =>                 position.bottom_right
psz = switch panelSize
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    =>         size.normal

f_flag(on) => on ? colExit : colOK

distLbl = isLong ? "Distribution" : "Accumulation"
momVal  = fMom ? (isLong ? "rolling" : "rising") : "ok"

var table p = table.new(ppos, 2, 10, border_width=1, border_color=c_grid, frame_color=c_gold, frame_width=1)

if showPanel and barstate.islast
    table.set_position(p, ppos)
    statusTxt = exitSig ? "EXIT" : caution ? "CAUTION" : "OK"
    statusCol = exitSig ? colExit : caution ? colCaut : colOK
    table.cell(p, 0, 0, "SWING TRADE DEFENDER", text_color=c_gold, bgcolor=c_navy, text_size=psz, text_halign=text.align_left)
    table.cell(p, 1, 0, isLong ? "LONG" : "SHORT", text_color=color.white, bgcolor=c_navy, text_size=psz, text_halign=text.align_right)
    table.cell(p, 0, 1, "Status", text_color=c_lbl, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 1, 1, statusTxt, text_color=color.white, bgcolor=statusCol, text_size=psz)
    table.cell(p, 0, 2, "Flags", text_color=c_lbl, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 1, 2, str.tostring(score) + " / 5", text_color=c_txt, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 0, 3, "Trend", text_color=c_lbl, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 1, 3, fTrend ? "break" : "hold", text_color=f_flag(fTrend), bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 0, 4, "Structure", text_color=c_lbl, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 1, 4, fStruct ? "break" : "hold", text_color=f_flag(fStruct), bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 0, 5, "Momentum", text_color=c_lbl, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 1, 5, momVal, text_color=f_flag(fMom), bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 0, 6, distLbl, text_color=c_lbl, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 1, 6, fDist ? "heavy" : "clear", text_color=f_flag(fDist), bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 0, 7, "ATR trail", text_color=c_lbl, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 1, 7, str.tostring(trail, format.mintick) + (fTrail ? "  ✗" : ""), text_color=fTrail ? colExit : c_txt, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 0, 8, "Entry", text_color=c_lbl, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 1, 8, hasEntry ? str.tostring(entryPx, format.mintick) : "—", text_color=c_txt, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 0, 9, "Open P/L", text_color=c_lbl, bgcolor=c_bodyBg, text_size=psz)
    table.cell(p, 1, 9, na(chartPL) ? "—" : (chartPL >= 0 ? "+" : "") + str.tostring(chartPL, "0.0") + "%", text_color=na(chartPL) ? c_lbl : chartPL >= 0 ? colOK : colExit, bgcolor=c_bodyBg, text_size=psz)

// ───────── Alerts ─────────
alertcondition(exitSig and not exitSig[1], "Exit signal", "Swing Trade Defender: trade failing — consider exit")
alertcondition(caution and not caution[1], "Caution", "Swing Trade Defender: warning flag raised")
````
