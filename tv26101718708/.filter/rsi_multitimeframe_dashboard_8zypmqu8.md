# RSI Multi-Timeframe Dashboard

- url: https://www.tradingview.com/script/8ZYPMQU8-RSI-Multi-Timeframe-Dashboard/
- type: indicator
- pine_id: PUB;6a20fe21d00245ef8c70aa9334851f38
- version: 1.0

## Description

RSI Multi-Timeframe Dashboard

[b]═══════════════════════════════════════════
WHAT IT DOES
═══════════════════════════════════════════[/b]
This tool displays the Relative Strength Index (RSI) of up to six timeframes
at once in a compact on-chart table, so you can judge momentum across the
whole timeframe stack without switching charts. Instead of reading RSI on a
single timeframe, you see how short-, medium- and higher-timeframe momentum
line up — and a consensus row summarises the overall picture.

It is designed as a CONFLUENCE tool: a way to see whether the broader market
agrees with what you're seeing on your trading timeframe.

[b]═══════════════════════════════════════════
HOW IT WORKS
═══════════════════════════════════════════[/b]
RSI is calculated with the standard Wilder method (default length 14) on each
selected timeframe using request.security(). Each row is classified into a zone:

- Overbought  — RSI at or above the overbought level (default 70)
- Oversold    — RSI at or below the oversold level (default 30)
- Bullish     — RSI above the midline (default 50)
- Bearish     — RSI below the midline (default 50)

The "ALL" row aggregates only the enabled timeframes:
- If every enabled timeframe is oversold  → "STRONG BUY ZONE"
- If every enabled timeframe is overbought → "STRONG SELL ZONE"
- Otherwise it shows the majority bias and a score, e.g. "BULLISH (4/5)"

These are descriptions of momentum conditions — not instructions to buy or sell.

[b]═══════════════════════════════════════════
HOW TO USE IT IN A TRADE
═══════════════════════════════════════════[/b]
The core idea is alignment. Higher-timeframe RSI defines the bias; lower-timeframe
RSI helps with timing inside that bias.

Example long workflow:
1. Bias — Confirm the higher timeframes (e.g. 4H, Daily) are Bullish (above the
   midline). This says the dominant momentum favours longs.
2. Timing — Wait for a lower timeframe (e.g. 5m/15m) to dip toward Oversold and
   turn back up, offering a pullback entry in the direction of the higher-TF bias.
3. Confluence — A "BULLISH (5/5)" or rising consensus score adds conviction;
   a "MIXED" reading is a reason to wait.
4. Management — Define your stop from price structure (recent swing), not from
   RSI alone, and size the position to your own risk rules.

The short workflow is the mirror image (higher TFs Bearish, lower TF rallies into
Overbought and rolls over).

Things to respect:
- RSI can remain Overbought in a strong uptrend (and Oversold in a strong
  downtrend) for a long time. "Overbought" is not automatically "sell."
- Counter-trend signals (e.g. Oversold while higher TFs are Bearish) are
  lower-probability and best avoided or treated as scalps only.
- This indicator does not place trades, set stops, or manage risk for you.

[b]═══════════════════════════════════════════
SETTINGS
═══════════════════════════════════════════[/b]
- RSI — length, source, and the overbought / oversold / midline levels.
- Timeframes to monitor — up to 6 slots, each with an on/off toggle and its own
  timeframe. Set them equal to or higher than your chart timeframe.
- Style — table position, text size, and your own bullish / bearish colours.

[b]═══════════════════════════════════════════
ALERTS
═══════════════════════════════════════════[/b]
- All timeframes oversold
- All timeframes overbought
- Consensus turned bullish (majority crossed above the midline)
- Consensus turned bearish (majority crossed below the midline)

[b]═══════════════════════════════════════════
NOTES, REPAINTING & LIMITATIONS
═══════════════════════════════════════════[/b]
- Monitored timeframes should be greater than or equal to your chart timeframe;
  requesting a lower timeframe is not meaningful.
- Repainting: values use lookahead_off, so a higher-timeframe RSI updates live
  until that bar closes — this is intended for real-time reading. The reading on
  a closed higher-TF bar is final.
- RSI is a momentum oscillator, not a forecast. This dashboard organises that
  information across timeframes; it does not predict price.

This script is published open-source. Study it, learn from it, and adapt it to
your own process. It is provided for educational purposes only and is not
financial advice. Past behaviour of any indicator does not guarantee future
results — always do your own analysis and manage your risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © traderdsr36

//@version=6
// ════════════════════════════════════════════════════════════════════════
//  RSI Multi-Timeframe Dashboard
//  Reads RSI across up to 6 timeframes at once and shows a consensus bias.
//  Use it as CONFLUENCE — agreement across timeframes, not a single signal.
// ════════════════════════════════════════════════════════════════════════
indicator("RSI Multi-Timeframe Dashboard", "RSI MTF", overlay = true)

// ───────────────────────── RSI SETTINGS ────────────────────────────────
gR     = "RSI"
rsiLen = input.int(14, "RSI Length", minval = 1, group = gR)
src    = input.source(close, "Source", group = gR)
obLvl  = input.int(70, "Overbought level", minval = 50, maxval = 100, group = gR)
osLvl  = input.int(30, "Oversold level",   minval = 0,  maxval = 50,  group = gR)
midLvl = input.int(50, "Midline (trend bias)", minval = 1, maxval = 99, group = gR)

// ───────────────────────── TIMEFRAME SLOTS ─────────────────────────────
g1 = "Timeframes to monitor"
e1 = input.bool(true,  "", inline = "t1", group = g1)
t1 = input.timeframe("5",   "Slot 1", inline = "t1", group = g1)
e2 = input.bool(true,  "", inline = "t2", group = g1)
t2 = input.timeframe("15",  "Slot 2", inline = "t2", group = g1)
e3 = input.bool(true,  "", inline = "t3", group = g1)
t3 = input.timeframe("60",  "Slot 3", inline = "t3", group = g1)
e4 = input.bool(true,  "", inline = "t4", group = g1)
t4 = input.timeframe("240", "Slot 4", inline = "t4", group = g1)
e5 = input.bool(true,  "", inline = "t5", group = g1)
t5 = input.timeframe("D",   "Slot 5", inline = "t5", group = g1)
e6 = input.bool(false, "", inline = "t6", group = g1)
t6 = input.timeframe("W",   "Slot 6", inline = "t6", group = g1)

// ───────────────────────── STYLE ───────────────────────────────────────
gS    = "Style"
posIn = input.string("Top Right", "Table position", group = gS,
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"])
szIn  = input.string("Normal", "Text size", group = gS,
     options = ["Tiny", "Small", "Normal", "Large"])
buyCol  = input.color(#26a69a, "Bullish / Buy", inline = "cc", group = gS)
sellCol = input.color(#ef5350, "Bearish / Sell", inline = "cc", group = gS)

tblPos = switch posIn
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    =>                position.top_right

tblSz = switch szIn
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    =>          size.normal

// ───────────────────── PER-TIMEFRAME RSI ENGINE ────────────────────────
rsiSeries = ta.rsi(src, rsiLen)
r1 = request.security(syminfo.tickerid, t1, rsiSeries, lookahead = barmerge.lookahead_off)
r2 = request.security(syminfo.tickerid, t2, rsiSeries, lookahead = barmerge.lookahead_off)
r3 = request.security(syminfo.tickerid, t3, rsiSeries, lookahead = barmerge.lookahead_off)
r4 = request.security(syminfo.tickerid, t4, rsiSeries, lookahead = barmerge.lookahead_off)
r5 = request.security(syminfo.tickerid, t5, rsiSeries, lookahead = barmerge.lookahead_off)
r6 = request.security(syminfo.tickerid, t6, rsiSeries, lookahead = barmerge.lookahead_off)

// ───────────────────────── CLASSIFICATION ──────────────────────────────
f_zoneTxt(r) =>
    na(r) ? "-" : r >= obLvl ? "Overbought" : r <= osLvl ? "Oversold" :
     r >= midLvl ? "Bullish" : "Bearish"

f_zoneCol(r) =>
    na(r)            ? color.new(color.gray, 60) :
     r >= obLvl      ? sellCol :
     r <= osLvl      ? buyCol  :
     r >= midLvl     ? color.new(buyCol, 55) :
                       color.new(sellCol, 55)

// Consensus scoring across ENABLED slots only
f_en(en)      => en ? 1 : 0
f_bull(en, r) => en and not na(r) and r >= midLvl ? 1 : 0
f_ob(en, r)   => en and not na(r) and r >= obLvl  ? 1 : 0
f_os(en, r)   => en and not na(r) and r <= osLvl  ? 1 : 0

total = f_en(e1) + f_en(e2) + f_en(e3) + f_en(e4) + f_en(e5) + f_en(e6)
bullN = f_bull(e1, r1) + f_bull(e2, r2) + f_bull(e3, r3) + f_bull(e4, r4) + f_bull(e5, r5) + f_bull(e6, r6)
obN   = f_ob(e1, r1) + f_ob(e2, r2) + f_ob(e3, r3) + f_ob(e4, r4) + f_ob(e5, r5) + f_ob(e6, r6)
osN   = f_os(e1, r1) + f_os(e2, r2) + f_os(e3, r3) + f_os(e4, r4) + f_os(e5, r5) + f_os(e6, r6)
bearN = total - bullN

overallTxt = total == 0 ? "-" :
     osN == total  ? "STRONG BUY ZONE"  :
     obN == total  ? "STRONG SELL ZONE" :
     bullN > bearN ? "BULLISH (" + str.tostring(bullN) + "/" + str.tostring(total) + ")" :
     bearN > bullN ? "BEARISH (" + str.tostring(bearN) + "/" + str.tostring(total) + ")" :
                     "MIXED"
overallCol = total == 0 ? color.gray :
     osN == total  ? buyCol :
     obN == total  ? sellCol :
     bullN > bearN ? color.new(buyCol, 25) :
     bearN > bullN ? color.new(sellCol, 25) :
                     color.new(color.gray, 30)

// ───────────────────────── TABLE RENDER ────────────────────────────────
var table dash = table.new(tblPos, 3, 9, border_width = 1, border_color = color.new(color.gray, 60))

f_row(rowIdx, en, tf, r) =>
    if en
        zc = f_zoneCol(r)
        table.cell(dash, 0, rowIdx, tf, text_color = chart.fg_color, bgcolor = color.new(color.gray, 90), text_size = tblSz)
        table.cell(dash, 1, rowIdx, na(r) ? "-" : str.tostring(r, "#.0"), text_color = chart.fg_color, bgcolor = color.new(zc, 80), text_size = tblSz)
        table.cell(dash, 2, rowIdx, f_zoneTxt(r), text_color = chart.fg_color, bgcolor = zc, text_size = tblSz)

if barstate.islast
    table.clear(dash, 0, 0, 2, 8)
    table.cell(dash, 0, 0, "TF",   text_color = chart.fg_color, bgcolor = color.new(color.gray, 70), text_size = tblSz)
    table.cell(dash, 1, 0, "RSI",  text_color = chart.fg_color, bgcolor = color.new(color.gray, 70), text_size = tblSz)
    table.cell(dash, 2, 0, "Zone", text_color = chart.fg_color, bgcolor = color.new(color.gray, 70), text_size = tblSz)
    f_row(1, e1, t1, r1)
    f_row(2, e2, t2, r2)
    f_row(3, e3, t3, r3)
    f_row(4, e4, t4, r4)
    f_row(5, e5, t5, r5)
    f_row(6, e6, t6, r6)
    table.cell(dash, 0, 7, "ALL", text_color = chart.fg_color, bgcolor = color.new(color.gray, 50), text_size = tblSz)
    table.cell(dash, 1, 7, "▶",   text_color = chart.fg_color, bgcolor = color.new(color.gray, 50), text_size = tblSz)
    table.cell(dash, 2, 7, overallTxt, text_color = color.white, bgcolor = overallCol, text_size = tblSz)

// ───────────────────────── ALERTS ──────────────────────────────────────
allBuy   = total > 0 and osN == total
allSell  = total > 0 and obN == total
flipBull = ta.crossover(bullN, bearN)
flipBear = ta.crossunder(bullN, bearN)

alertcondition(allBuy,   "All TF Oversold",   "All monitored timeframes are oversold")
alertcondition(allSell,  "All TF Overbought", "All monitored timeframes are overbought")
alertcondition(flipBull, "Consensus turned bullish", "Majority of timeframes turned bullish (RSI > midline)")
alertcondition(flipBear, "Consensus turned bearish", "Majority of timeframes turned bearish (RSI < midline)")
````
