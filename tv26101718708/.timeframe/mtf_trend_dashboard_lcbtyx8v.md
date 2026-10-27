# MTF Trend Dashboard

- url: https://www.tradingview.com/script/LcBtYx8v/
- type: indicator
- pine_id: PUB;1f89a6f42622413cbe843d92f7f3b8aa
- version: 2.0

## Description

This indicator aggregates trend conditions from four user-selected timeframes into a single table, so you can read higher-timeframe context without switching charts.

How it works

Each timeframe is evaluated with three independent checks:


EMA trend — fast EMA above/below slow EMA (default 20/50)
RSI — above/below the 50 midline (default length 14)
MACD — MACD line above/below its signal line (12/26/9)


The three checks are combined into a simple score from -3 to +3. A score of +2 or higher is shown as BULL, -2 or lower as BEAR, and anything in between as FLAT. The table shows the raw RSI value and the state of each check per timeframe, so you can always see why a timeframe is rated the way it is.

Chart plots (all optional)


Fast/slow EMA of the current chart timeframe
Background highlight while all four timeframes are aligned in the same direction
A small marker on the bar where full alignment begins


Alerts

Two alert conditions are included: all timeframes aligned bullish, and all timeframes aligned bearish.

Repainting

By default, higher-timeframe values are taken from confirmed bars only ("Use confirmed bars only" setting), so the table does not change retroactively. If you disable this setting, the current (unclosed) higher-timeframe bar is used and its values can update until that bar closes.

Notes and limitations

This is a context/confluence tool, not a trading system. Alignment across timeframes describes current conditions only and implies nothing about future price movement. Test any idea thoroughly before using it in live trading.

## Source Code

````pine
//@version=6
// ============================================================
//  MTF Trend Dashboard
//  Aggregates trend conditions across multiple timeframes into one table
//  - Each timeframe is evaluated with EMA cross / RSI / MACD
//  - Optional non-repainting mode (confirmed bars only)
// ============================================================
indicator("MTF Trend Dashboard", overlay = true)

// ---------- Inputs ----------
grpTf = "Timeframes"
tf1 = input.timeframe("15",  "Timeframe 1", group = grpTf)
tf2 = input.timeframe("60",  "Timeframe 2", group = grpTf)
tf3 = input.timeframe("240", "Timeframe 3", group = grpTf)
tf4 = input.timeframe("D",   "Timeframe 4", group = grpTf)

grpCalc = "Calculation"
emaFastLen = input.int(20, "Fast EMA", minval = 1, group = grpCalc)
emaSlowLen = input.int(50, "Slow EMA", minval = 1, group = grpCalc)
rsiLen     = input.int(14, "RSI Length", minval = 1, group = grpCalc)
useConfirmed = input.bool(true, "Use confirmed bars only (non-repainting)", group = grpCalc)

grpUi = "Display"
posOpt  = input.string("Top Right", "Table position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = grpUi)
txtSize = input.string("Normal", "Text size", options = ["Small", "Normal", "Large"], group = grpUi)

colUp   = input.color(color.new(#26a69a, 0), "Bullish color", group = grpUi)
colDown = input.color(color.new(#ef5350, 0), "Bearish color", group = grpUi)
colNeut = input.color(color.new(#787b86, 0), "Neutral color", group = grpUi)

// ---------- Evaluation logic ----------
// idx = 1 evaluates on the previous (confirmed) bar
f_state(int idx) =>
    emaF = ta.ema(close, emaFastLen)
    emaS = ta.ema(close, emaSlowLen)
    r    = ta.rsi(close, rsiLen)
    [macdLine, sigLine, _] = ta.macd(close, 12, 26, 9)
    trendUp = emaF[idx] > emaS[idx]
    macdUp  = macdLine[idx] > sigLine[idx]
    [trendUp, r[idx], macdUp]

f_sec(simple string tf) =>
    // Fixed [1] (not realtime-dependent): historical bars would otherwise
    // receive the HTF close value early within each HTF period.
    int idx = useConfirmed ? 1 : 0
    [t, r, m] = request.security(syminfo.tickerid, tf, f_state(idx), lookahead = barmerge.lookahead_off)
    [t, r, m]

[t1, r1, m1] = f_sec(tf1)
[t2, r2, m2] = f_sec(tf2)
[t3, r3, m3] = f_sec(tf3)
[t4, r4, m4] = f_sec(tf4)

// ---------- Display utilities ----------
f_pos(string s) =>
    s == "Top Right" ? position.top_right :
     s == "Bottom Right" ? position.bottom_right :
     s == "Top Left" ? position.top_left : position.bottom_left

f_size(string s) =>
    s == "Small" ? size.small : s == "Large" ? size.large : size.normal

f_tfLabel(simple string tf) =>
    str.contains(tf, "D") or str.contains(tf, "W") or str.contains(tf, "M") ? tf :
     str.tonumber(tf) >= 60 ? str.tostring(str.tonumber(tf) / 60) + "H" : tf + "m"

// Score across the 3 checks (-3 to +3)
f_score(bool t, float r, bool m) =>
    (t ? 1 : -1) + (r > 50 ? 1 : -1) + (m ? 1 : -1)

f_scoreTxt(int sc) =>
    sc >= 2 ? "BULL" : sc <= -2 ? "BEAR" : "FLAT"

f_scoreCol(int sc) =>
    sc >= 2 ? colUp : sc <= -2 ? colDown : colNeut

// ---------- Table rendering ----------
var table tb = table.new(f_pos(posOpt), 5, 5, border_width = 1)

f_row(int row, simple string tf, bool t, float r, bool m) =>
    sc = f_score(t, r, m)
    table.cell(tb, 0, row, f_tfLabel(tf),          text_color = color.white, bgcolor = color.new(#363a45, 0),   text_size = f_size(txtSize))
    table.cell(tb, 1, row, t ? "UP" : "DOWN",     text_color = color.white, bgcolor = t ? colUp : colDown,     text_size = f_size(txtSize))
    table.cell(tb, 2, row, str.tostring(r, "#.0"), text_color = color.white, bgcolor = r > 50 ? colUp : colDown, text_size = f_size(txtSize))
    table.cell(tb, 3, row, m ? "UP" : "DOWN",     text_color = color.white, bgcolor = m ? colUp : colDown,     text_size = f_size(txtSize))
    table.cell(tb, 4, row, f_scoreTxt(sc),         text_color = color.white, bgcolor = f_scoreCol(sc),          text_size = f_size(txtSize))

if barstate.islast
    // Header
    table.cell(tb, 0, 0, "TF",   text_color = color.white, bgcolor = color.new(#131722, 0), text_size = f_size(txtSize))
    table.cell(tb, 1, 0, "EMA",  text_color = color.white, bgcolor = color.new(#131722, 0), text_size = f_size(txtSize))
    table.cell(tb, 2, 0, "RSI",  text_color = color.white, bgcolor = color.new(#131722, 0), text_size = f_size(txtSize))
    table.cell(tb, 3, 0, "MACD", text_color = color.white, bgcolor = color.new(#131722, 0), text_size = f_size(txtSize))
    table.cell(tb, 4, 0, "Score", text_color = color.white, bgcolor = color.new(#131722, 0), text_size = f_size(txtSize))
    // Rows per timeframe
    f_row(1, tf1, t1, r1, m1)
    f_row(2, tf2, t2, r2, m2)
    f_row(3, tf3, t3, r3, m3)
    f_row(4, tf4, t4, r4, m4)

// ---------- Alerts ----------
allUp   = f_score(t1, r1, m1) >= 2  and f_score(t2, r2, m2) >= 2  and f_score(t3, r3, m3) >= 2  and f_score(t4, r4, m4) >= 2
allDown = f_score(t1, r1, m1) <= -2 and f_score(t2, r2, m2) <= -2 and f_score(t3, r3, m3) <= -2 and f_score(t4, r4, m4) <= -2

alertcondition(allUp,   "All timeframes bullish", "MTF Dashboard: all timeframes aligned bullish")
alertcondition(allDown, "All timeframes bearish", "MTF Dashboard: all timeframes aligned bearish")

// ---------- Chart plots ----------
grpPlot = "Chart Plots"
showEma = input.bool(true, "Show EMAs (chart timeframe)", group = grpPlot)
showBg  = input.bool(true, "Highlight background on full alignment", group = grpPlot)
showSig = input.bool(true, "Mark start of full alignment", group = grpPlot)

chartEmaF = ta.ema(close, emaFastLen)
chartEmaS = ta.ema(close, emaSlowLen)
plot(showEma ? chartEmaF : na, "Fast EMA", color = color.new(#26a69a, 30), linewidth = 1)
plot(showEma ? chartEmaS : na, "Slow EMA", color = color.new(#787b86, 30), linewidth = 2)

bgcolor(showBg and allUp ? color.new(colUp, 90) : showBg and allDown ? color.new(colDown, 90) : na, title = "Alignment background")

plotshape(showSig and allUp and not allUp[1],   "Bullish alignment start", shape.triangleup,   location.belowbar, colUp,   size = size.tiny)
plotshape(showSig and allDown and not allDown[1], "Bearish alignment start", shape.triangledown, location.abovebar, colDown, size = size.tiny)
````
