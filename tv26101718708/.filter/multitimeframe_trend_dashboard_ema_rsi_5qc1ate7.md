# Multi-Timeframe Trend Dashboard - EMA & RSI

- url: https://www.tradingview.com/script/5Qc1Ate7-Multi-Timeframe-Trend-Dashboard-EMA-RSI/
- type: indicator
- pine_id: PUB;0a423151688c449f83752d51497bf659
- version: 1.0

## Description

OVERVIEW
This dashboard shows the trend and momentum state of the current symbol on up to five timeframes in a single table, so you can see whether the lower and higher timeframes agree without switching charts. Each timeframe gets a simple, transparent score, and an overall line summarises how aligned they are. Optional alerts fire when every enabled timeframe agrees, or when that agreement ends.

WHAT MAKES IT DIFFERENT
- By default every reading comes from the last CLOSED bar of each timeframe, so the table does not flicker while higher-timeframe bars are still forming, and historical readings match what was shown in real time. A live mode is available and clearly labelled as repainting.
- The score uses three simple rules that you can check yourself, with no hidden weighting.
- Timeframes below the chart timeframe are flagged and excluded instead of quietly returning misleading values.

HOW IT WORKS
For each selected timeframe the script requests the fast EMA, slow EMA, RSI and close, then scores three conditions:
- EMA trend: fast EMA above slow EMA = +1, below = -1.
- Price position: close above slow EMA = +1, below = -1 (the distance from the slow EMA is shown in %).
- Momentum: RSI above 50 = +1, below 50 = -1. Overbought/oversold levels add an OB/OS tag but do not change the score.
Each timeframe therefore scores from -3 to +3. A timeframe counts as bullish when its score is at or above the chosen threshold (default +2) and as bearish when it is at or below the negative threshold. The Bias row shows "Aligned bullish/bearish" when every enabled, available timeframe agrees, "Leaning" when one side has more timeframes, and "Mixed" otherwise. It also shows the total score out of the maximum possible.

Closed-bars mode requests each value offset by one bar with lookahead enabled. This is the standard non-repainting method for higher-timeframe data: it returns the most recently completed bar of that timeframe on both historical and real-time bars. Live mode requests the current bar without lookahead, so values update tick by tick and can change until each bar closes.

HOW TO USE
1. Choose up to five timeframes, from lowest to highest (defaults: 15m, 1H, 4H, 1D, 1W), and use a chart timeframe equal to or lower than the smallest one.
2. Use the higher timeframes to define directional context and the lower ones to judge timing. For example, a trader might only look for long setups while the higher timeframes are bullish, and wait for a lower timeframe to turn bullish again after a pullback.
3. "Mixed" readings point to a range or a transition between trends, where trend-following approaches tend to be less reliable.
4. Set alerts with "All timeframes bullish", "All timeframes bearish" or "Alignment lost". These alerts are evaluated on confirmed chart bars.

INPUTS
Timeframes
- Five enable boxes and timeframe selectors.
Trend & momentum settings
- Fast EMA length, Slow EMA length, RSI length, RSI overbought/oversold.
- Closed bars only (no repaint): on by default. Turn it off for live, repainting values.
- Plot chart-timeframe EMAs: optionally draws the two EMAs on the chart.
Table
- Position, text size, show distance from slow EMA, and bullish/bearish/neutral colors.
Alignment
- Score needed to count as trending (1-3).
- Highlight chart background when aligned.

LIMITATIONS
- In closed-bars mode, each timeframe reflects its last completed bar. A daily reading does not include today's developing bar, and a timeframe equal to the chart timeframe lags by one bar. This delay is the price of avoiding repainting.
- EMA and RSI are lagging measures. Alignment describes the current state of price; it does not forecast future direction, and aligned conditions can reverse at any time.
- Higher timeframes need enough history to calculate the slow EMA. Rows show "no data" until that history is available.
- Timeframes lower than the chart timeframe are shown as unavailable.
- Readings depend on the symbol's data feed and session settings, so different brokers' symbols can show slightly different values.

This script is for educational and informational purposes only and is not financial advice. Trading CFDs and forex involves significant risk of loss.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0
// © cfdtools
//
// Multi-Timeframe Trend Dashboard - EMA & RSI
// Summarises the trend state of the chart symbol on up to five timeframes in one
// table: fast/slow EMA relationship, price position versus the slow EMA (with
// distance in %), RSI level/zone, and a -3..+3 score per timeframe, plus an
// overall alignment readout and alerts when all enabled timeframes agree.
// By default only closed higher-timeframe bars are used, so values do not repaint.

indicator("Multi-Timeframe Trend Dashboard - EMA & RSI", shorttitle = "MTF Trend Dashboard", overlay = true)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
GRP_TF  = "Timeframes"
GRP_IND = "Trend & momentum settings"
GRP_TBL = "Table"
GRP_ALN = "Alignment"

en1 = input.bool(true, "", inline = "tf1", group = GRP_TF)
tf1 = input.timeframe("15", "Timeframe 1", inline = "tf1", group = GRP_TF)
en2 = input.bool(true, "", inline = "tf2", group = GRP_TF)
tf2 = input.timeframe("60", "Timeframe 2", inline = "tf2", group = GRP_TF)
en3 = input.bool(true, "", inline = "tf3", group = GRP_TF)
tf3 = input.timeframe("240", "Timeframe 3", inline = "tf3", group = GRP_TF)
en4 = input.bool(true, "", inline = "tf4", group = GRP_TF)
tf4 = input.timeframe("D", "Timeframe 4", inline = "tf4", group = GRP_TF)
en5 = input.bool(true, "", inline = "tf5", group = GRP_TF, tooltip = "Tick a box to include that timeframe. Timeframes lower than the chart timeframe are shown as unavailable and excluded from the totals; use a chart timeframe equal to or lower than the smallest timeframe you want to read.")
tf5 = input.timeframe("W", "Timeframe 5", inline = "tf5", group = GRP_TF)

fastLen    = input.int(20, "Fast EMA length", minval = 1, group = GRP_IND)
slowLen    = input.int(50, "Slow EMA length", minval = 2, group = GRP_IND, tooltip = "EMA trend is bullish when the fast EMA is above the slow EMA and bearish when below.")
rsiLen     = input.int(14, "RSI length", minval = 2, group = GRP_IND)
rsiOb      = input.float(70.0, "RSI overbought", minval = 50.0, maxval = 100.0, step = 1.0, inline = "rsi", group = GRP_IND)
rsiOs      = input.float(30.0, "oversold", minval = 0.0, maxval = 50.0, step = 1.0, inline = "rsi", group = GRP_IND, tooltip = "RSI above 50 counts as bullish momentum and below 50 as bearish. The overbought/oversold levels only add an OB/OS tag to the RSI cell; they do not change the score.")
closedOnly = input.bool(true, "Closed bars only (no repaint)", group = GRP_IND, tooltip = "Enabled: every timeframe reports the values of its last CLOSED bar, so nothing changes until that bar is complete and historical readings match what was shown in real time. Disabled: values update live from the still-forming bar of each timeframe and can change (repaint) until it closes.")
plotEmas   = input.bool(false, "Plot chart-timeframe EMAs", group = GRP_IND)

tblPosIn = input.string("Top right", "Position", options = ["Top right", "Top left", "Top center", "Middle right", "Bottom right", "Bottom left"], group = GRP_TBL)
tblTxtIn = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = GRP_TBL)
showDist = input.bool(true, "Show distance from slow EMA (%)", group = GRP_TBL)
colBull  = input.color(#26A69A, "Bullish", inline = "c", group = GRP_TBL)
colBear  = input.color(#EF5350, "Bearish", inline = "c", group = GRP_TBL)
colNeut  = input.color(#787B86, "Neutral", inline = "c", group = GRP_TBL)

minScore  = input.int(2, "Score needed to count as trending", minval = 1, maxval = 3, group = GRP_ALN, tooltip = "A timeframe counts as bullish when its score is at least this value, and bearish when it is at most the negative of this value. Alignment requires every enabled, available timeframe to agree.")
showBg    = input.bool(false, "Highlight chart background when aligned", group = GRP_ALN)

// ─────────────────────────────────────────────────────────────────────────────
// Data requests
// Closed-bars mode uses the documented non-repainting form: expression[1]
// together with lookahead_on, which returns the last completed bar of the
// requested timeframe on historical and realtime bars alike.
// Live mode uses lookahead_off with no offset (may repaint while bars form).
// ─────────────────────────────────────────────────────────────────────────────
int OFS = closedOnly ? 1 : 0
LA      = closedOnly ? barmerge.lookahead_on : barmerge.lookahead_off

mtfData() =>
    float eF = ta.ema(close, fastLen)
    float eS = ta.ema(close, slowLen)
    float r  = ta.rsi(close, rsiLen)
    [eF[OFS], eS[OFS], r[OFS], close[OFS]]

[f1, s1, r1, c1] = request.security(syminfo.tickerid, tf1, mtfData(), lookahead = LA)
[f2, s2, r2, c2] = request.security(syminfo.tickerid, tf2, mtfData(), lookahead = LA)
[f3, s3, r3, c3] = request.security(syminfo.tickerid, tf3, mtfData(), lookahead = LA)
[f4, s4, r4, c4] = request.security(syminfo.tickerid, tf4, mtfData(), lookahead = LA)
[f5, s5, r5, c5] = request.security(syminfo.tickerid, tf5, mtfData(), lookahead = LA)

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
normTf(string tf) =>
    tf == "" ? timeframe.period : tf

tfLabel(string tf) =>
    string t   = normTf(tf)
    string res = t
    bool hasUnit = str.contains(t, "D") or str.contains(t, "W") or str.contains(t, "M") or str.contains(t, "S")
    if hasUnit
        res := str.length(t) == 1 ? "1" + t : t
    else
        float m = str.tonumber(t)
        if not na(m)
            int mi = int(m)
            res := mi >= 60 and mi % 60 == 0 ? str.tostring(mi / 60, "#") + "H" : str.tostring(mi) + "m"
    res

// true when the requested timeframe is lower than the chart timeframe
isLowerTf(string tf) =>
    timeframe.in_seconds(normTf(tf)) < timeframe.in_seconds(timeframe.period)

hasData(float eF, float eS, float r, float c) =>
    not na(eF) and not na(eS) and not na(r) and not na(c)

// -3..+3: EMA cross state, close vs slow EMA, RSI vs 50
tfScore(float eF, float eS, float r, float c) =>
    int s = 0
    if hasData(eF, eS, r, c)
        s += eF > eS ? 1 : eF < eS ? -1 : 0
        s += c > eS ? 1 : c < eS ? -1 : 0
        s += r > 50.0 ? 1 : r < 50.0 ? -1 : 0
    s

scoreColor(int s) =>
    s >= minScore ? colBull : s <= -minScore ? colBear : s > 0 ? color.new(colBull, 50) : s < 0 ? color.new(colBear, 50) : colNeut

// ─────────────────────────────────────────────────────────────────────────────
// Per-timeframe state (evaluated on every bar so alerts work)
// ─────────────────────────────────────────────────────────────────────────────
bool lo1 = isLowerTf(tf1)
bool lo2 = isLowerTf(tf2)
bool lo3 = isLowerTf(tf3)
bool lo4 = isLowerTf(tf4)
bool lo5 = isLowerTf(tf5)

bool v1 = en1 and not lo1 and hasData(f1, s1, r1, c1)
bool v2 = en2 and not lo2 and hasData(f2, s2, r2, c2)
bool v3 = en3 and not lo3 and hasData(f3, s3, r3, c3)
bool v4 = en4 and not lo4 and hasData(f4, s4, r4, c4)
bool v5 = en5 and not lo5 and hasData(f5, s5, r5, c5)

int sc1 = tfScore(f1, s1, r1, c1)
int sc2 = tfScore(f2, s2, r2, c2)
int sc3 = tfScore(f3, s3, r3, c3)
int sc4 = tfScore(f4, s4, r4, c4)
int sc5 = tfScore(f5, s5, r5, c5)

int nValid = (v1 ? 1 : 0) + (v2 ? 1 : 0) + (v3 ? 1 : 0) + (v4 ? 1 : 0) + (v5 ? 1 : 0)
int nBull  = (v1 and sc1 >= minScore ? 1 : 0) + (v2 and sc2 >= minScore ? 1 : 0) + (v3 and sc3 >= minScore ? 1 : 0) + (v4 and sc4 >= minScore ? 1 : 0) + (v5 and sc5 >= minScore ? 1 : 0)
int nBear  = (v1 and sc1 <= -minScore ? 1 : 0) + (v2 and sc2 <= -minScore ? 1 : 0) + (v3 and sc3 <= -minScore ? 1 : 0) + (v4 and sc4 <= -minScore ? 1 : 0) + (v5 and sc5 <= -minScore ? 1 : 0)
int total  = (v1 ? sc1 : 0) + (v2 ? sc2 : 0) + (v3 ? sc3 : 0) + (v4 ? sc4 : 0) + (v5 ? sc5 : 0)

bool allBull = nValid > 0 and nBull == nValid
bool allBear = nValid > 0 and nBear == nValid

bool alignBull = barstate.isconfirmed and allBull and not allBull[1]
bool alignBear = barstate.isconfirmed and allBear and not allBear[1]
bool alignLost = barstate.isconfirmed and not allBull and not allBear and (allBull[1] or allBear[1])

alertcondition(alignBull, "All timeframes bullish", "{{ticker}}: all enabled timeframes are aligned bullish (confirmed bar).")
alertcondition(alignBear, "All timeframes bearish", "{{ticker}}: all enabled timeframes are aligned bearish (confirmed bar).")
alertcondition(alignLost, "Alignment lost", "{{ticker}}: multi-timeframe alignment is no longer in place (confirmed bar).")

bgcolor(showBg and allBull ? color.new(colBull, 92) : showBg and allBear ? color.new(colBear, 92) : color(na), title = "Alignment background")

float chartFast = ta.ema(close, fastLen)
float chartSlow = ta.ema(close, slowLen)
plot(plotEmas ? chartFast : na, "Fast EMA (chart TF)", color = color.new(colBull, 0), linewidth = 1)
plot(plotEmas ? chartSlow : na, "Slow EMA (chart TF)", color = color.new(colBear, 0), linewidth = 1)

// ─────────────────────────────────────────────────────────────────────────────
// Table
// ─────────────────────────────────────────────────────────────────────────────
string tblPos = switch tblPosIn
    "Top left"     => position.top_left
    "Top center"   => position.top_center
    "Middle right" => position.middle_right
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_right

string tblTxt = switch tblTxtIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

color TBL_BG   = color.new(#131722, 5)
color TBL_HEAD = color.new(#2A2E39, 0)
color TBL_TXT  = color.new(#D1D4DC, 0)

var table dash = table.new(tblPos, 5, 7, bgcolor = TBL_BG, frame_color = TBL_HEAD, frame_width = 1, border_color = TBL_HEAD, border_width = 1)

cellTxt(int col, int row, string txt, color tCol, color bg) =>
    table.cell(dash, col, row, txt, text_color = tCol, bgcolor = bg, text_size = tblTxt, text_halign = text.align_center)

drawRow(int row, string tf, bool lowerTf, float eF, float eS, float r, float c, int sc) =>
    cellTxt(0, row, tfLabel(tf), TBL_TXT, TBL_HEAD)
    if lowerTf
        cellTxt(1, row, "below chart TF", colNeut, TBL_BG)
        cellTxt(2, row, "-", colNeut, TBL_BG)
        cellTxt(3, row, "-", colNeut, TBL_BG)
        cellTxt(4, row, "-", colNeut, TBL_BG)
    else if not hasData(eF, eS, r, c)
        cellTxt(1, row, "no data", colNeut, TBL_BG)
        cellTxt(2, row, "-", colNeut, TBL_BG)
        cellTxt(3, row, "-", colNeut, TBL_BG)
        cellTxt(4, row, "-", colNeut, TBL_BG)
    else
        string emaTxt = eF > eS ? "Bull ▲" : eF < eS ? "Bear ▼" : "Flat"
        color  emaCol = eF > eS ? colBull : eF < eS ? colBear : colNeut
        float  dist   = (c - eS) / eS * 100.0
        string posTxt = (c > eS ? "Above" : c < eS ? "Below" : "At") + (showDist ? " (" + (dist >= 0 ? "+" : "") + str.tostring(dist, "0.00") + "%)" : "")
        color  posCol = c > eS ? colBull : c < eS ? colBear : colNeut
        string zone   = r >= rsiOb ? " OB" : r <= rsiOs ? " OS" : ""
        color  rsiCol = r > 50.0 ? colBull : r < 50.0 ? colBear : colNeut
        cellTxt(1, row, emaTxt, color.white, color.new(emaCol, 25))
        cellTxt(2, row, posTxt, posCol, TBL_BG)
        cellTxt(3, row, str.tostring(r, "0.0") + zone, rsiCol, TBL_BG)
        cellTxt(4, row, (sc > 0 ? "+" : "") + str.tostring(sc), color.white, scoreColor(sc))

if barstate.islast
    table.clear(dash, 0, 0, 4, 6)
    cellTxt(0, 0, "TF", TBL_TXT, TBL_HEAD)
    cellTxt(1, 0, "EMA " + str.tostring(fastLen) + "/" + str.tostring(slowLen), TBL_TXT, TBL_HEAD)
    cellTxt(2, 0, "Price vs EMA " + str.tostring(slowLen), TBL_TXT, TBL_HEAD)
    cellTxt(3, 0, "RSI " + str.tostring(rsiLen), TBL_TXT, TBL_HEAD)
    cellTxt(4, 0, "Score", TBL_TXT, TBL_HEAD)

    int row = 1
    if en1
        drawRow(row, tf1, lo1, f1, s1, r1, c1, sc1)
        row += 1
    if en2
        drawRow(row, tf2, lo2, f2, s2, r2, c2, sc2)
        row += 1
    if en3
        drawRow(row, tf3, lo3, f3, s3, r3, c3, sc3)
        row += 1
    if en4
        drawRow(row, tf4, lo4, f4, s4, r4, c4, sc4)
        row += 1
    if en5
        drawRow(row, tf5, lo5, f5, s5, r5, c5, sc5)
        row += 1

    string biasTxt = nValid == 0 ? "No data" : allBull ? "Aligned bullish" : allBear ? "Aligned bearish" : nBull > nBear ? "Leaning bullish" : nBear > nBull ? "Leaning bearish" : "Mixed"
    color  biasCol = allBull ? colBull : allBear ? colBear : nBull > nBear ? color.new(colBull, 50) : nBear > nBull ? color.new(colBear, 50) : colNeut
    string countTxt = "Bull " + str.tostring(nBull) + " / Bear " + str.tostring(nBear) + " of " + str.tostring(nValid)
    cellTxt(0, row, "Bias", TBL_TXT, TBL_HEAD)
    cellTxt(1, row, biasTxt, color.white, biasCol)
    cellTxt(2, row, countTxt, TBL_TXT, TBL_BG)
    cellTxt(3, row, closedOnly ? "closed bars" : "live (repaints)", colNeut, TBL_BG)
    cellTxt(4, row, (total > 0 ? "+" : "") + str.tostring(total) + "/" + str.tostring(nValid * 3), color.white, biasCol)
````
