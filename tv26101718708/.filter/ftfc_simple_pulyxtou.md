# FTFC Simple

- url: https://www.tradingview.com/script/PuLYxtou-FTFC-Simple/
- type: indicator
- pine_id: PUB;e257dde31dab4176b10f4825b9ff8b82
- version: 1.0

## Description

FTFC Signal — Full Timeframe Continuity (60m · D · W · M)

Indicator twin of the backtested "FTFC Full Timeframe Continuity" strategy. Same engine — same presets, debounce, loss cooldown, ETF-shorts rule — but built as an indicator: no TradingView order arrows, alerts fire, and it exposes sortable Screener columns.

How it scores
Compares price to the open of four timeframes — 60-minute, Daily, Weekly, Monthly. Each aligned timeframe = +1 (close above open) or −1 (below). Sum = a continuity score from −4 (all four bearish) to +4 (all four bullish). Full continuity = all timeframes pointing the same way.

Signal engine (bar-close, identical to strategy)
- Long when score ≥ entry threshold, price-strength and open-spread filters pass
- Short when score ≤ threshold (optional Monthly-red gate)
- Debounce — score must hold N bars before a signal fires (kills chop)
- Loss cooldown — blocks re-entry N bars after a losing exit
- Simulated position state drives entry/exit/reverse; no repaint

Presets
- Auto — maps thresholds, debounce, cooldown from your chart timeframe
- Long-bias (best 1h)
- Majority stop-and-reverse (best 2022+)
- Long-only wide-hold (max profit factor / single stocks / ≥ 4h)
- Custom — every threshold exposed

On the chart
- Price-pane trade marks — teal ▲ long, coral ▼ short, red ▼ exit; brighter = more timeframes aligned at entry
- Optional FTFC status panel — per-timeframe direction, % from each open, live score meter, position P/L, active filters
- Optional tradable-tickers table — edge-screened names with strategy-minus-buy&hold margins

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Claude
//@version=6
// FTFC SIGNAL — indicator twin of the "FTFC 60/D/W/M — Full Timeframe Continuity" strategy.
// IDENTICAL engine (same presets, debounce, loss cooldown, ETF-shorts rule), but as an
// indicator: NO TradingView order arrows/labels ever, and alerts work. Use the strategy
// version for backtesting; use this one for clean charts + alerts.
// INSTALL: TV Pine Editor → Open → Create new indicator → paste this file → Save.
indicator("FTFC Signal", shorttitle="FTFC", overlay=true, max_labels_count=200)

string PRESET_AUTO = "Auto (by chart timeframe)"
string PRESET_A = "Long-bias (best ≤1h)"
string PRESET_B = "Majority stop-and-reverse (best 2022+)"
string PRESET_C = "Long-only wide-hold (max PF / single stocks / ≥4h)"
string preset = input.string(PRESET_AUTO, "Preset", options=[PRESET_AUTO, PRESET_A, PRESET_B, PRESET_C, "Custom"], group="Strategy")
int persistIn = input.int(2, "Signal debounce (bars)", minval=1, maxval=8, group="Strategy",
     tooltip="Ignored by Auto preset (maps from chart TF: ≤30m→3, 1h→2, 2h-12h→1, 1D+→2).")
int coolIn = input.int(-1, "Loss cooldown (bars, −1 = auto)", minval=-1, maxval=50, group="Strategy",
     tooltip="After a LOSING exit, block re-entry this many bars. −1 = auto: wide-hold 6 (≤1h) / 12 (higher); long-bias intraday 0.")
bool showBest = input.bool(false, "Show tradable-tickers table on price chart", group="Strategy")
bool showPanel = input.bool(false, "Show FTFC status panel", group="Strategy")
bool showMarks = input.bool(true, "Price-pane trade marks", group="Strategy",
     tooltip="Teal ▲ = long entry, coral ▼ = short entry, red ▼ = exit. Brighter = stronger FTFC score at entry. No TV order paint — this is an indicator.")

int   cEntL = input.int(0,  "Long when score ≥",  minval=-4, maxval=4, step=2, group="Custom")
int   cExL  = input.int(-2, "Exit long at score ≤", minval=-4, maxval=4, step=2, group="Custom")
bool  cSh   = input.bool(true, "Shorts enabled", group="Custom")
int   cEntS = input.int(-2, "Short when score ≤", minval=-4, maxval=4, step=2, group="Custom")
int   cExS  = input.int(2,  "Cover short at score ≥", minval=-4, maxval=4, step=2, group="Custom")
bool  cGate = input.bool(true, "Shorts need Monthly red", group="Custom")
float cStr  = input.float(0.1, "Min |close − D open| %", step=0.05, group="Custom")
float cClus = input.float(0.0, "Min D/W/M open spread %", step=0.05, group="Custom")

int tfSec = timeframe.in_seconds()
bool autoScalp    = tfSec <= 1800
bool autoIntraday = tfSec <= 3600
bool autoSwing    = tfSec > 3600 and tfSec < 86400
bool symEtf = syminfo.type == "fund" or syminfo.type == "index" or syminfo.type == "cfd"

bool isAuto = preset == PRESET_AUTO
bool isA = preset == PRESET_A or (isAuto and autoIntraday)
bool isB = preset == PRESET_B
bool isC = preset == PRESET_C or (isAuto and not autoIntraday)

int   entL   = isA ? 0 : isB ? 2 : isC ? 2 : cEntL
int   exL    = isA ? -2 : isB ? -2 : isC ? -4 : cExL
bool  shOn   = isA ? (isAuto ? symEtf : true) : isB ? true : isC ? false : cSh
int   entS   = isA ? -2 : isB ? -2 : cEntS
int   exS    = isA ? 2 : isB ? 2 : cExS
bool  gateM  = isA ? true : isB ? true : isC ? false : cGate
float strMin = isA ? 0.1 : isB ? 0.15 : isC ? 0.15 : cStr
float clMin  = isA ? 0.0 : isB ? 0.20 : isC ? 0.0 : cClus
int   persist = isAuto ? (autoScalp ? 3 : autoIntraday ? 2 : autoSwing ? 1 : 2) : persistIn
int   cool    = coolIn >= 0 ? coolIn : (isC ? (autoIntraday ? 6 : 12) : 0)

f_open(string tf) => request.security(syminfo.tickerid, tf, open, barmerge.gaps_off, barmerge.lookahead_on)
string tf60 = tfSec >= 3600 ? timeframe.period : "60"
float o60 = f_open(tf60), float oD = f_open("D"), float oW = f_open("W"), float oM = f_open("M")

int s60 = close >= o60 ? 1 : -1
int sD  = close >= oD  ? 1 : -1
int sW  = close >= oW  ? 1 : -1
int sM  = close >= oM  ? 1 : -1
int score = s60 + sD + sW + sM

float d60 = (close - o60) / o60 * 100
float dD  = (close - oD)  / oD  * 100
float dW  = (close - oW)  / oW  * 100
float dM  = (close - oM)  / oM  * 100

bool strengthOK = math.abs(dD) >= strMin
float openHi = math.max(oD, math.max(oW, oM)), float openLo = math.min(oD, math.min(oW, oM))
bool spreadOK = (openHi - openLo) / openLo * 100 >= clMin

// ═══ SIGNAL ENGINE (position simulated — bar-close semantics identical to strategy) ═══
bool wantLraw = score >= entL and strengthOK and spreadOK
bool wantSraw = shOn and score <= entS and (not gateM or sM == -1) and strengthOK and spreadOK

var int lC = 0, var int sC = 0, var int eC = 0, var int cC = 0
lC := wantLraw ? lC + 1 : 0
sC := wantSraw ? sC + 1 : 0
eC := (score <= exL) ? eC + 1 : 0
cC := (score >= exS) ? cC + 1 : 0

bool wantLong   = lC >= persist
bool wantShort  = sC >= persist
bool exitLongC  = eC >= persist
bool exitShortC = cC >= persist

var int pos = 0
var float epx = na
var int coolLeft = 0
coolLeft := math.max(coolLeft - 1, 0)

bool longOK  = wantLong  and coolLeft == 0 and (pos == 0 or (pos < 0 and exitShortC))
bool shortOK = wantShort and coolLeft == 0 and (pos == 0 or (pos > 0 and exitLongC))

bool closingL = pos > 0 and exitLongC and not shortOK
bool closingS = pos < 0 and exitShortC and not longOK

if closingL or closingS
    if (closingL and close < epx) or (closingS and close > epx)
        coolLeft := cool
    pos := 0
    epx := na
if longOK
    pos := 1
    epx := close
else if shortOK
    pos := -1
    epx := close

bool enteredL = pos == 1 and pos[1] != 1
bool enteredS = pos == -1 and pos[1] != -1
bool wentFlat = pos == 0 and pos[1] != 0

// ═══════════════════════════ UI ═════════════════════════════
color TEAL   = color.rgb(0, 229, 160)
color CORAL  = color.rgb(255, 92, 122)
color TEAL_D = color.rgb(0, 122, 94)
color CORAL_D= color.rgb(158, 52, 76)
color INK    = color.rgb(13, 15, 20)
color PANEL  = color.rgb(20, 23, 31)
color CHIP   = color.rgb(31, 36, 48)
color MUTE   = color.rgb(138, 147, 166)
color FAINT  = color.rgb(58, 64, 80)

// Marker strength = FTFC score at entry (# of 60m/D/W/M aligned): brighter = more timeframes agree
color longCol  = color.from_gradient(score,  0, 4, color.new(TEAL, 55), TEAL)
color shortCol = color.from_gradient(score, -4, 0, CORAL, color.new(CORAL, 55))
plotshape(showMarks and enteredL, "Long entry", shape.triangleup, location.belowbar, longCol, size=size.small)
plotshape(showMarks and enteredS, "Short entry", shape.triangledown, location.abovebar, shortCol, size=size.small)
plotshape(showMarks and wentFlat, "Exit", shape.triangledown, location.abovebar, color.red, size=size.small)

// ═══════════════════════════ ALERTS (work in indicators) ═══════════════════
alertcondition(pos == 1 and pos[1] != 1, "FTFC Long entry", "FTFC: LONG {{ticker}} @ {{close}} ({{interval}})")
alertcondition(pos == -1 and pos[1] != -1, "FTFC Short entry", "FTFC: SHORT {{ticker}} @ {{close}} ({{interval}})")
alertcondition(pos == 0 and pos[1] != 0, "FTFC Exit", "FTFC: EXIT {{ticker}} @ {{close}} ({{interval}})")

// ═══════════════════════ PINE SCREENER COLUMNS ════════════════════════════
// display.none = off the chart, but exposed as sortable/filterable Screener columns.
// Screener columns come ONLY from plot() (not plotshape/table/alertcondition).
plot(score, "FTFC score", display=display.none)          // −4..+4 timeframe alignment
plot(pos,   "Position",   display=display.none)          // +1 long · −1 short · 0 flat
plot(d60,   "60m %",      display=display.none)
plot(dD,    "D %",        display=display.none)
plot(dW,    "W %",        display=display.none)
plot(dM,    "M %",        display=display.none)

// ── Formatting helpers ──
f_fmt(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.00") + "%"
f_m(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "#") + "p"

// ── Info panel ──
var table pnl = showPanel ? table.new(position.top_right, 4, 5, bgcolor=PANEL, border_width=2, border_color=INK, frame_width=1, frame_color=FAINT) : table(na)
if showPanel and barstate.islast
    string presetTag = (isAuto ? "AUTO · " : "") + (isA ? "LONG-BIAS" : isB ? "MAJORITY SAR" : isC ? "LONG-ONLY" : "CUSTOM") + (shOn ? "" : " · no shorts")
    table.cell(pnl, 0, 0, "⧉ FTFC", text_color=color.white, text_size=size.small, bgcolor=PANEL, text_halign=text.align_left)
    table.merge_cells(pnl, 1, 0, 3, 0)
    table.cell(pnl, 1, 0, presetTag, text_color=MUTE, text_size=size.tiny, bgcolor=PANEL, text_halign=text.align_right)
    string[] names = array.from(tfSec >= 3600 ? "TF" : "60", "D", "W", "M")
    int[]    sts   = array.from(s60, sD, sW, sM)
    float[]  dists = array.from(d60, dD, dW, dM)
    for i = 0 to 3
        int st = array.get(sts, i)
        table.cell(pnl, i, 1, array.get(names, i) + (st == 1 ? " ▲" : " ▼"),
             text_color=st == 1 ? TEAL : CORAL, text_size=size.tiny, bgcolor=CHIP)
        table.cell(pnl, i, 2, f_fmt(array.get(dists, i)),
             text_color=st == 1 ? color.new(TEAL, 25) : color.new(CORAL, 25), text_size=size.tiny,
             bgcolor=st == 1 ? color.new(TEAL_D, 82) : color.new(CORAL_D, 82))
    int fill = (score + 4) / 2
    string meter = ""
    for i = 1 to 4
        meter += i <= fill ? "▰" : "▱"
    table.merge_cells(pnl, 0, 3, 3, 3)
    table.cell(pnl, 0, 3, "SCORE  " + meter + "  " + (score > 0 ? "+" : "") + str.tostring(score) + (coolLeft > 0 ? "  · cooldown " + str.tostring(coolLeft) : ""),
         text_color=score >= 2 ? TEAL : score <= -2 ? CORAL : MUTE, text_size=size.small, bgcolor=PANEL)
    string posTxt = pos > 0 ? "LONG · " + str.tostring(epx, format.mintick) + " · " + f_fmt((close / epx - 1) * 100) :
         pos < 0 ? "SHORT · " + str.tostring(epx, format.mintick) + " · " + f_fmt((epx / close - 1) * 100) : "FLAT · waiting for continuity"
    color posCol = pos != 0 ? color.white : MUTE
    color posBg  = pos > 0 ? color.new(TEAL_D, 55) : pos < 0 ? color.new(CORAL_D, 55) : PANEL
    table.merge_cells(pnl, 0, 4, 3, 4)
    table.cell(pnl, 0, 4, posTxt, text_color=posCol, text_size=size.tiny, bgcolor=posBg,
         tooltip="Filters — strength " + (strengthOK ? "✓" : "✗") + " · open spread " + (spreadOK ? "✓" : "✗") + " · debounce " + str.tostring(persist) + " · cooldown " + str.tostring(cool))

// ── Tradable-tickers table (price chart) — two-column, hidden by default ──
var table best = table.new(position.bottom_right, 10, 10, bgcolor=PANEL, border_width=2,
     border_color=INK, frame_width=1, frame_color=FAINT)
if barstate.islast and showBest
    string[] bT = array.from("HIMS", "MU",   "ORCL", "QCOM", "IREN", "GLW",  "META", "NVDA", "QQQ",
         "MSFT", "AMZN", "MRVL", "SPY",  "TSLA", "GOOGL", "CRWD", "INTC", "LRCX")
    string[] bC = array.from("1h wide 1.7", "1h wide 4.1", "1h wide 2.7", "1h wide 2.2", "1h wide 1.7", "1h wide 4.7",
         "30m L0X-2 p3", "15m L0X-4 p1", "4h L2X-4 p1",
         "15m L0X-4 p1", "15m L0X-4 p2", "1h wide 2.1", "30m LB+S p2", "30m SAR+S p1",
         "1h wide 2.5", "1h wide 1.9", "1h wide 3.8", "1h wide 3.6")
    float[] e25 = array.from(134.4, 115.7, 115.0, 73.8, 43.0, 41.5, 35.7, 25.8, 20.7, 20.4, 18.8, 9.9, 8.9, 7.8, -8.0, -36.0, -87.5, -119.8)
    float[] e1y = array.from(128.8, -179.5, 54.7, 35.1, 110.6, -41.9, 10.2, -21.3, -3.4, 17.8, 9.1, -110.4, -19.4, -34.2, -14.0, -29.8, -101.8, -90.5)
    float[] e90 = array.from(-25.4, 4.5, 42.3, 22.8, 45.3, -20.1, -7.7, -3.1, -1.0, 12.8, -3.6, 10.1, -2.4, 17.0, -4.8, -18.8, -30.9, -3.7)
    table.merge_cells(best, 0, 0, 1, 0)
    table.cell(best, 0, 0, "⧉ TRADABLE", text_color=color.white, text_size=size.tiny, bgcolor=PANEL, text_halign=text.align_left,
         tooltip="Edge-screened: 18 of 50+ tested pass. Margins = strategy − B&H pct pts: '25 holdout / 1Y / 90D (Jul '26). 'wide N' = Long-only wide-hold preset, holdout PF N.")
    for blk = 0 to 1
        int c0 = blk * 5
        table.cell(best, c0 + 2, 0, "'25", text_color=MUTE, text_size=size.tiny, bgcolor=PANEL, text_halign=text.align_right)
        table.cell(best, c0 + 3, 0, "1Y", text_color=MUTE, text_size=size.tiny, bgcolor=PANEL, text_halign=text.align_right)
        table.cell(best, c0 + 4, 0, "90D", text_color=MUTE, text_size=size.tiny, bgcolor=PANEL, text_halign=text.align_right)
    table.cell(best, 5, 0, "", bgcolor=PANEL)
    table.cell(best, 6, 0, "", bgcolor=PANEL)
    for i = 0 to 17
        int c0 = i < 9 ? 0 : 5
        int rw = 1 + (i % 9)
        bool me = syminfo.ticker == array.get(bT, i)
        color rowBg = me ? color.new(TEAL_D, 70) : PANEL
        color txt = me ? color.white : MUTE
        table.cell(best, c0 + 0, rw, (me ? "▶ " : "") + array.get(bT, i), text_color=me ? TEAL : txt, text_size=size.tiny, bgcolor=rowBg, text_halign=text.align_left)
        table.cell(best, c0 + 1, rw, array.get(bC, i), text_color=txt, text_size=size.tiny, bgcolor=rowBg)
        float[] cols = array.from(array.get(e25, i), array.get(e1y, i), array.get(e90, i))
        for j = 0 to 2
            float v = array.get(cols, j)
            table.cell(best, c0 + 2 + j, rw, f_m(v), text_color=v >= 0 ? TEAL : CORAL, text_size=size.tiny, bgcolor=rowBg, text_halign=text.align_right)
````
