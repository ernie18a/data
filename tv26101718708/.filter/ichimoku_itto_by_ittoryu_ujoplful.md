# Ichimoku Itto by [Itto-Ryu]

- url: https://www.tradingview.com/script/ujoplFUL-Ichimoku-Itto-by-Itto-Ryu/
- type: indicator
- pine_id: PUB;60206f89851445509082cb7dc940878c
- version: 1.0

## Description

Ichimoku Itto ("one glance, one cut") is an Ichimoku Kinko Hyo tool built to be read at a glance. A standard Ichimoku chart draws five lines and leaves the interpretation to the reader. Itto keeps the classic math and adds a layer that turns those lines into one clear reading per bar.

This script is for technical education and chart study only. It is not financial advice and gives no buy or sell recommendation.


WHAT IS DIFFERENT FROM A STANDARD ICHIMOKU

1. One score instead of five lines to judge
The standard indicator shows Tenkan, Kijun, Chikou and the Kumo, and the reader checks each relationship by eye. Itto checks five relationships on every bar and adds them into one score from -100% to +100%, plus a plain trend label (STRONG UP … CHOP ZONE).

2. A built-in chop zone
Classic Ichimoku has no "no reading" state, so every crossing looks equally important. Itto marks a chop zone when price is inside the Kumo or the score is near zero. In that zone the Kijun turns gray, candles turn amber and no marks print.

3. Kijun slope as part of the reading
Most Ichimoku tools ignore whether the Kijun is rising, falling or flat. Itto scores the slope, so a flat Kijun lowers the reading even when price sits above the cloud.

4. A stricter Chikou test
The usual check compares Chikou with the close of the bar it is plotted against. Itto requires the close to clear the HIGH (or LOW) of that bar, so Chikou counts only when it is clear of price, not just touching it.

5. Equilibrium Magnets
In Ichimoku theory a flat Kijun or flat Senkou Span B marks a balance price that technicians watch as a magnet level. The standard indicator does not highlight these levels. Itto draws them automatically as dashed lines extended to the right.

6. Kumo thickness in words
The cloud's thickness is ranked against the last 252 bars and shown as Thin, Normal or Thick, instead of leaving the reader to judge it by eye.

7. Sanyaku in plain English
The classic "Sanyaku Koten / Gyakuten" (three signals agree) is labeled "3/3 Aligned Up / Down" and shown for four timeframes at once.

8. A multi-timeframe table that reads the same everywhere
Each timeframe row shows the latest closed bar of that timeframe, so the table gives the same answer on a 1H, 4H, D or W chart.

9. A cleaner chart by default
Only the Kijun ("the blade") and the Kumo are drawn by default. The blade is colored by the score and candles are colored by trend, so the reading is visible without the table. All other Ichimoku lines can be turned on.


HOW THE SCORE WORKS

Each check adds +1 (up), -1 (down) or 0 (neutral). Five checks give a score from -5 to +5, shown as -100% to +100% (each point = 20%).

1. Price vs the current Kumo: above = +1, below = -1, inside = 0
2. Tenkan vs Kijun: Tenkan above = +1, below = -1
3. Chikou: close above the high of the bar it is plotted against = +1, below that bar's low = -1, otherwise 0 (a stricter test than close-vs-close)
4. Future Kumo color: Senkou A above Senkou B = +1, below = -1
5. Kijun slope: Kijun higher than 5 bars ago = +1, lower = -1, flat = 0

Trend row in the dashboard:
• STRONG UP: +80% or more · UP: +60% · SIDEWAYS UP: +40%
• STRONG DOWN: -80% or less · DOWN: -60% · SIDEWAYS DOWN: -40%
• CHOP ZONE · NO ACTION: price inside the Kumo, or the score is between -20% and +20%. The chop zone overrides the score.

3/3 Aligned = checks 1, 2 and 3 all point the same way on the same bar. The label prints only on the first bar it becomes true.

Kumo thickness = the gap between Senkou A and B under the current bar, ranked against the last 252 bars: Thin (bottom 20%), Normal, Thick (top 20%). Technicians often treat a thick Kumo as a stronger support or resistance zone and a thin Kumo as easier to cross.


ON THE CHART

• Kijun "blade" line: green-to-red gradient by score, gray in the chop zone
• Kumo: shaded cloud, projected forward like the built-in Ichimoku (on by default)
• Tenkan, Chikou and the Senkou span lines: off by default, turn on under Lines
• ▲ Strong Up / ▼ Strong Down: score crossed the Strong threshold outside the chop zone
• 3/3 Aligned Up / Down labels: the three core signals agree
• Dashed orange line: Kijun magnet (Kijun flat for 8+ bars)
• Dashed purple line: Span B magnet (Senkou Span B flat for 8+ bars, drawn at its projected position)
• Candle colors: green / red / amber, or "Strength shades" (darker = stronger)


DASHBOARD

• Score: the chart's own timeframe, current bar
• Zone: Trending or Chop
• Kumo: Thin / Normal / Thick
• TF table (default 1H, 4H, D, W): score and 3/3 Aligned state for each timeframe
• Trend: the summary label described above

Important: every row in the TF table shows the latest CLOSED bar of that timeframe, so the table reads the same on any chart timeframe. The Score and Trend rows show the chart's current bar, which may still be forming. On a 1H chart, the Score row can therefore differ from the 1H row until the bar closes. Each timeframe has its own Kumo and lines, so a 1H reading and a D reading can point in different directions. That is normal. After switching timeframes the table needs a moment to load.


WHICH TIMEFRAME

Ichimoku was designed for the Daily chart. The Classic settings (9 / 26 / 52) match calendar spans on D: about 1.5 weeks, 1 month and 2 months of a 6-day trading week. For markets that trade 5 days a week there is a "5-Day Week" preset (7 / 22 / 44), and a "Crypto" preset (20 / 60 / 120) for 24/7 markets.

On intraday charts the same math works as plain bar counts, without the calendar meaning. Many technicians read D as the main chart and W as the bigger picture. The TF table shows both. No timeframe is claimed to be more accurate than another.


SETTINGS

Ichimoku
• Preset: Classic (default) / 5-Day Week / Crypto
• Kijun slope lookback: 5 bars

Signals
• Strong threshold: 4 (= 80%)
• Chop score band: 1 (= 20%)
• Show Strong Up / Down marks, Show 3/3 Aligned labels

Equilibrium Magnets
• Flat bars: 8 · Keep last: 6 lines (oldest deleted first)

Lines
• Tenkan, Chikou, Senkou spans (off), Kumo (on), Table (on) with size Tiny / Small / Normal / Large
• Color candles by trend (on): 3 colors or Strength shades

Colors: all line, cloud, candle and chop colors can be changed.
MTF table: four timeframes, default 60 / 240 / D / W.


ALERTS

Strong Up · Strong Down · Aligned Up · Aligned Down · Enter Chop · Exit Chop. All alerts fire on confirmed (closed) bars only.


WHO IT IS FOR

• Traders and students learning Ichimoku who want the five parts read in one place
• Chart readers who want a clear "chop / no reading" filter before studying a chart

Not for:
• Anyone looking for automatic entries, exits, targets or position sizing. The script draws none of these.
• Heikin Ashi, Renko or other non-standard chart types


COMMON MISTAKES

• Treating "Strong Up / Strong Down" as an instruction. It describes the Ichimoku state on a closed bar, nothing more.
• Ignoring the chop zone. Inside the Kumo the five checks often disagree and the score swings.
• Comparing the Score row with the same-timeframe row in the TF table on a forming bar (see Dashboard).
• Reading the projected Kumo as a forecast. It is plotted forward by design. It does not predict price.


DISCLOSURE

• Pine Script version: v6
• Open-source under the Mozilla Public License 2.0
• Repaint: NO for marks, labels, magnets and alerts, which are set only on confirmed bars. The Kijun color and candle colors on the live bar can change until that bar closes. The Kumo is plotted forward and the Chikou backward by the standard Ichimoku offsets. Plotted values do not change after a bar closes.
• Multi-timeframe: the TF table uses request.security and request.security_lower_tf to read the latest closed bar of each timeframe. It is shown on the last bar only and is not used for any mark, label or alert.
• Chart type: standard candles or bars only. Not for Heikin Ashi, Renko, Range, Kagi or Point & Figure.
• Original work: the score, chop zone, magnets and dashboard are the author's own logic built on the public Ichimoku Kinko Hyo method (Goichi Hosoda). No third-party code is reused.

Developed by Thiranat Ngamchitcharoen (Itto-Ryu).


DISCLAIMER

This indicator is published for educational and informational purposes only. It is not financial, investment or trading advice and does not recommend buying or selling any instrument. Signals and labels describe past and current chart conditions; they do not predict future prices. Past behavior of any indicator does not guarantee future results. Trading involves risk, including the loss of capital. You are solely responsible for your own decisions. Test any idea on your own data before relying on it.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Itto-Ryu
//@version=6
indicator("Ichimoku Itto by [Itto-Ryu]", shorttitle = "Ichi Itto", overlay = true, max_lines_count = 50, max_labels_count = 100)

// ==== CORE:BEGIN ====
// Ken-Tai core — shared functions only. Injected by build.py; edit src/core.pine, not dist/.

// ---- 4.1 Presets ----
// Returns [tenkan, kijun, spanB, displacement] for "Classic", "5-Day Week" or "Crypto".
kt_preset(simple string name) =>
    int t = name == "5-Day Week" ? 7 : name == "Crypto" ? 20 : 9
    int k = name == "5-Day Week" ? 22 : name == "Crypto" ? 60 : 26
    int b = name == "5-Day Week" ? 44 : name == "Crypto" ? 120 : 52
    int d = name == "5-Day Week" ? 22 : name == "Crypto" ? 30 : 26
    [t, k, b, d]

// ---- 4.2 Ichimoku math ----
kt_donchian(int len) => math.avg(ta.lowest(low, len), ta.highest(high, len))

// kumoA/kumoB = cloud under the current bar (TradingView built-in offset = disp - 1).
kt_ichimoku(int tLen, int kLen, int bLen, int disp) =>
    float tenkan = kt_donchian(tLen)
    float kijun = kt_donchian(kLen)
    float ssaRaw = math.avg(tenkan, kijun)
    float ssbRaw = kt_donchian(bLen)
    float kumoA = ssaRaw[disp - 1]
    float kumoB = ssbRaw[disp - 1]
    [tenkan, kijun, ssaRaw, ssbRaw, kumoA, kumoB]

// Chikou vs the price it is plotted against, no lookahead: +1 / -1 / 0.
kt_chikou(int disp) => close > high[disp - 1] ? 1 : close < low[disp - 1] ? -1 : 0

kt_inKumo(float kumoA, float kumoB) => close <= math.max(kumoA, kumoB) and close >= math.min(kumoA, kumoB)

// ---- 4.3 Itto Score ----
// Returns [score, c1 kumo, c2 TK, c3 chikou, c4 future kumo, c5 kijun slope]; score is na until the cloud exists.
kt_score(float tenkan, float kijun, float ssaRaw, float ssbRaw, float kumoA, float kumoB, int disp, int slopeLen) =>
    float kTop = math.max(kumoA, kumoB)
    float kBot = math.min(kumoA, kumoB)
    int c1 = close > kTop ? 1 : close < kBot ? -1 : 0
    int c2 = tenkan > kijun ? 1 : tenkan < kijun ? -1 : 0
    int c3 = kt_chikou(disp)
    int c4 = ssaRaw > ssbRaw ? 1 : ssaRaw < ssbRaw ? -1 : 0
    int c5 = kijun > kijun[slopeLen] ? 1 : kijun < kijun[slopeLen] ? -1 : 0
    bool warm = not na(kumoA) and not na(kumoB) and not na(kijun[slopeLen]) and not na(high[disp - 1])
    int score = warm ? c1 + c2 + c3 + c4 + c5 : na
    [score, c1, c2, c3, c4, c5]

// 三役: +1 = Sanyaku Koten (all three +1), -1 = Sanyaku Gyakuten, 0 = neither.
kt_sanyaku(int c1, int c2, int c3) => c1 == 1 and c2 == 1 and c3 == 1 ? 1 : c1 == -1 and c2 == -1 and c3 == -1 ? -1 : 0

kt_kumoThickPct(float kumoA, float kumoB, int rankLen) => ta.percentrank(math.abs(kumoA - kumoB), rankLen)

// Dashboard variant: the latest CLOSED bar of tf, the same on every chart TF (tf above or below the chart).
// Display-only: the HTF branch reads the current HTF bar only once time_close <= timenow (bar finished),
// so use the result on barstate.islast only — never for historical signals.
kt_mtf(string tf, float src) =>
    bool lower = timeframe.in_seconds(tf) < timeframe.in_seconds(timeframe.period)
    [hCur, hPrev, hEnd] = request.security(syminfo.tickerid, tf, [src, src[1], time_close], lookahead = barmerge.lookahead_on)
    array<float> lVals = request.security_lower_tf(syminfo.tickerid, lower ? tf : timeframe.period, src)
    array<int> lEnds = request.security_lower_tf(syminfo.tickerid, lower ? tf : timeframe.period, time_close)
    float lLast = na
    if lower and lVals.size() > 0
        for i = lVals.size() - 1 to 0
            if lEnds.get(i) <= timenow
                lLast := lVals.get(i)
                break
    lower ? lLast : hEnd <= timenow ? hCur : hPrev
// ==== CORE:END ====

// ═══════════════ INPUTS ═══════════════
const string G_ICHI = "Ichimoku"
const string G_CUT = "Signals"
const string G_MAG = "Equilibrium Magnets"
const string G_SHOW = "Lines"
const string G_COL = "Colors"
const string G_MTF = "MTF table"

string iPreset = input.string("Classic", "Preset", options = ["Classic", "5-Day Week", "Crypto"], group = G_ICHI, tooltip = "Tenkan / Kijun / Span B / Displacement.\nClassic 9/26/52/26 · 5-Day Week 7/22/44/22 · Crypto 20/60/120/30")
int iSlopeLen = input.int(5, "Kijun slope lookback", minval = 1, group = G_ICHI, tooltip = "Score component 5 compares Kijun with its value this many bars ago. Equal = flat = 0.")

int iCut = input.int(4, "Strong threshold", minval = 2, maxval = 5, group = G_CUT, tooltip = "A Strong Up mark prints on the confirmed bar where the score crosses up through +threshold (Strong Down: down through -threshold) outside the chop zone. 4 = 80%.")
int iNoCutBand = input.int(1, "Chop score band", minval = 0, maxval = 3, group = G_CUT, tooltip = "Chop zone = price inside the Kumo OR |score| <= this value (1 = 20%). No Strong marks print in the zone and the blade turns gray.")
bool iShowCuts = input.bool(true, "Show Strong Up / Down marks", group = G_CUT, tooltip = "Triangle marks on the confirmed bar where the score crosses the Strong threshold outside the chop zone.")
bool iShowSanyaku = input.bool(true, "Show 3/3 Aligned labels", group = G_CUT, tooltip = "3/3 Aligned Up: price above Kumo, Tenkan above Kijun and Chikou above price, all on the same bar. Aligned Down is the mirror. Classic Ichimoku calls these Sanyaku Koten / Gyakuten.")

bool iShowMag = input.bool(true, "Show magnets", group = G_MAG, tooltip = "Equilibrium levels: a horizontal line when Kijun (or Senkou Span B) stays flat for N bars. Span B lines start at the projected position.")
int iFlatLen = input.int(8, "Flat bars", minval = 2, group = G_MAG, tooltip = "How many bars in a row the Kijun (or Span B) must stay at the same level before a magnet line is drawn.")
int iMagKeep = input.int(6, "Keep last", minval = 1, maxval = 20, group = G_MAG, tooltip = "Oldest magnet is deleted when a new one is added.")

bool iShowTenkan = input.bool(false, "Tenkan", group = G_SHOW, inline = "l1")
bool iShowChikou = input.bool(false, "Chikou", group = G_SHOW, inline = "l1", tooltip = "Optional Ichimoku lines. The Kijun (blade) is always shown.")
bool iShowSpans = input.bool(false, "Senkou spans", group = G_SHOW, inline = "l2")
bool iShowKumo = input.bool(true, "Kumo", group = G_SHOW, inline = "l2", tooltip = "Senkou spans = the two cloud edge lines. Kumo = the shaded cloud, projected forward like the built-in Ichimoku.")
bool iShowTable = input.bool(true, "Table", group = G_SHOW, inline = "tbl")
string iTableSize = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_SHOW, inline = "tbl", tooltip = "Dashboard on/off and text size.")
bool iColorBars = input.bool(true, "Color candles by trend", group = G_SHOW, inline = "bar", tooltip = "Up = green, Down = red, Chop zone = amber (uses the Colors below).\n3 colors: one shade per direction.\nStrength shades: Strong = full color, Up/Down = lighter, Sideways = lightest.")
string iBarStyle = input.string("3 colors", "", options = ["3 colors", "Strength shades"], group = G_SHOW, inline = "bar")

color iColUp = input.color(#26A69A, "Score +5", group = G_COL, inline = "c1")
color iColDn = input.color(#EF5350, "Score -5", group = G_COL, inline = "c1")
color iColNeutral = input.color(#787B86, "Chop (blade)", group = G_COL, inline = "c1", tooltip = "Up / Down colors are used by the blade, candles, marks and dashboard. Chop (blade) = Kijun color in the chop zone.")
color iColTenkan = input.color(#2962FF, "Tenkan", group = G_COL, inline = "c2")
color iColChikou = input.color(#B2B5BE, "Chikou", group = G_COL, inline = "c2", tooltip = "Colors of the optional Tenkan and Chikou lines.")
color iColMagK = input.color(#FFB74D, "Kijun magnet", group = G_COL, inline = "c3")
color iColMagB = input.color(#BA68C8, "Span B magnet", group = G_COL, inline = "c3", tooltip = "Colors of the Equilibrium Magnet lines.")
color iColKumoUp = input.color(#26A69A73, "Kumo up", group = G_COL, inline = "c4")
color iColKumoDn = input.color(#EF535073, "Kumo down", group = G_COL, inline = "c4")
color iColChop = input.color(#FFB300, "Chop zone", group = G_COL, inline = "c4", tooltip = "Cloud colors (with transparency) and the chop-zone color used by candles and the dashboard.")

string iTf1 = input.timeframe("60", "TF 1", group = G_MTF, inline = "t1")
string iTf2 = input.timeframe("240", "TF 2", group = G_MTF, inline = "t1", tooltip = "Rows 1 and 2 of the dashboard table (default 1H and 4H).")
string iTf3 = input.timeframe("D", "TF 3", group = G_MTF, inline = "t2")
string iTf4 = input.timeframe("W", "TF 4", group = G_MTF, inline = "t2", tooltip = "Timeframes in the dashboard table. Each row shows the latest closed bar of that timeframe, on any chart timeframe.")

// ═══════════════ CALCULATIONS ═══════════════
[tLen, kLen, bLen, disp] = kt_preset(iPreset)
[tenkan, kijun, ssaRaw, ssbRaw, kumoA, kumoB] = kt_ichimoku(tLen, kLen, bLen, disp)
[score, c1, c2, c3, c4, c5] = kt_score(tenkan, kijun, ssaRaw, ssbRaw, kumoA, kumoB, disp, iSlopeLen)
int sanyaku = na(score) ? 0 : kt_sanyaku(c1, c2, c3)
bool inKumo = kt_inKumo(kumoA, kumoB)
float thickPct = kt_kumoThickPct(kumoA, kumoB, 252)

float mScore1 = kt_mtf(iTf1, score)
float mScore2 = kt_mtf(iTf2, score)
float mScore3 = kt_mtf(iTf3, score)
float mScore4 = kt_mtf(iTf4, score)
float mSan1 = kt_mtf(iTf1, sanyaku)
float mSan2 = kt_mtf(iTf2, sanyaku)
float mSan3 = kt_mtf(iTf3, sanyaku)
float mSan4 = kt_mtf(iTf4, sanyaku)

int kFlat = ta.barssince(kijun != kijun[1]) + 1
int bFlat = ta.barssince(ssbRaw != ssbRaw[1]) + 1

// ═══════════════ CONDITIONS ═══════════════
bool noCut = na(score) or inKumo or math.abs(score) <= iNoCutBand
bool hasPrev = not na(score[1])
bool cutLong = barstate.isconfirmed and hasPrev and not noCut and score >= iCut and score[1] < iCut
bool cutShort = barstate.isconfirmed and hasPrev and not noCut and score <= -iCut and score[1] > -iCut
bool sanUp = barstate.isconfirmed and sanyaku == 1 and sanyaku[1] != 1
bool sanDn = barstate.isconfirmed and sanyaku == -1 and sanyaku[1] != -1
bool enterNoCut = barstate.isconfirmed and noCut and not noCut[1]
bool exitNoCut = barstate.isconfirmed and not noCut and noCut[1]

// ═══════════════ PLOTS ═══════════════
color bladeCol = noCut ? iColNeutral : color.from_gradient(score, -5, 5, iColDn, iColUp)
plot(kijun, "Kijun (Blade)", bladeCol, 2)

// Candles follow the Trend row: chop = amber, otherwise green / red (optionally shaded by strength)
color dirCol = noCut ? iColChop : score > 0 ? iColUp : score < 0 ? iColDn : iColNeutral
int barTransp = noCut or iBarStyle == "3 colors" ? 0 : math.abs(score) >= iCut ? 0 : math.abs(score) >= 3 ? 30 : 60
barcolor(iColorBars ? color.new(dirCol, barTransp) : na, title = "Trend candles")
plot(iShowTenkan ? tenkan : na, "Tenkan", iColTenkan, 1)
plot(iShowChikou ? close : na, "Chikou", iColChikou, 1, offset = -(disp - 1))
pA = plot(iShowSpans or iShowKumo ? ssaRaw : na, "Senkou A", iShowSpans ? color.new(iColUp, 40) : na, 1, offset = disp - 1)
pB = plot(iShowSpans or iShowKumo ? ssbRaw : na, "Senkou B", iShowSpans ? color.new(iColDn, 40) : na, 1, offset = disp - 1)
fill(pA, pB, iShowKumo ? (ssaRaw > ssbRaw ? iColKumoUp : iColKumoDn) : na, "Kumo")

// When an Aligned label prints on the same bar, the Strong text moves into that label so the texts do not overlap
bool sanUpLbl = iShowSanyaku and sanUp
bool sanDnLbl = iShowSanyaku and sanDn
plotshape(iShowCuts and cutLong and not sanUpLbl, "Strong Up", shape.triangleup, location.belowbar, iColUp, size = size.small, text = "Strong Up", textcolor = iColUp)
plotshape(iShowCuts and cutShort and not sanDnLbl, "Strong Down", shape.triangledown, location.abovebar, iColDn, size = size.small, text = "Strong Down", textcolor = iColDn)
plotshape(iShowCuts and cutLong and sanUpLbl, "Strong Up + Aligned", shape.triangleup, location.belowbar, iColUp, size = size.small, display = display.pane)
plotshape(iShowCuts and cutShort and sanDnLbl, "Strong Down + Aligned", shape.triangledown, location.abovebar, iColDn, size = size.small, display = display.pane)
plot(score, "Itto Score", display = display.data_window)

float atr14 = ta.atr(14)
if sanUpLbl
    label.new(bar_index, low - 1.5 * atr14, (iShowCuts and cutLong ? "Strong Up\n" : "") + "3/3 Aligned Up", style = label.style_label_up, color = color.new(iColUp, 80), textcolor = iColUp, size = size.tiny)
if sanDnLbl
    label.new(bar_index, high + 1.5 * atr14, (iShowCuts and cutShort ? "Strong Down\n" : "") + "3/3 Aligned Down", style = label.style_label_down, color = color.new(iColDn, 80), textcolor = iColDn, size = size.tiny)

// Equilibrium Magnets — one shared array, oldest deleted first
var array<line> magnets = array.new<line>()
f_addMagnet(int x1, float y, color col) =>
    magnets.push(line.new(x1, y, x1 + 1, y, extend = extend.right, color = col, style = line.style_dashed, width = 1))
    if magnets.size() > iMagKeep
        line.delete(magnets.shift())
if iShowMag and barstate.isconfirmed and kFlat == iFlatLen
    f_addMagnet(bar_index - iFlatLen + 1, kijun, iColMagK)
if iShowMag and barstate.isconfirmed and bFlat == iFlatLen
    f_addMagnet(bar_index - iFlatLen + disp, ssbRaw, iColMagB)

// Table — English only
const color C_HEAD = #1E3A5F
const color C_GOLD = #FFD54F
const color C_ROW1 = #1C2030
const color C_ROW2 = #232838
const color C_SUB = #2E3450
const color C_SUBTXT = #90CAF9
const color C_LBL = #B2B5BE
// Score shown as % of the ±5 maximum (+3 → +60%)
f_pct(float v) => na(v) ? "—" : (v > 0 ? "+" : "") + str.tostring(v * 20, "#") + "%"
f_sanText(float v) => na(v) ? "—" : v == 1 ? "Up" : v == -1 ? "Down" : "None"
f_sanCol(float v) => v == 1 ? iColUp : v == -1 ? iColDn : iColNeutral
f_scoreCol(float v) => na(v) ? iColNeutral : color.from_gradient(v, -5, 5, iColDn, iColUp)
f_tint(color c) => color.new(c, 78)
f_tfLabel(string tf) =>
    int sec = timeframe.in_seconds(tf)
    sec >= 3600 and sec < 86400 and sec % 3600 == 0 ? str.tostring(sec / 3600, "#") + "H" : tf
// Trend summary from the score; the no-cut zone overrides it
f_trend(float s, bool chop) =>
    string txt = chop ? "CHOP ZONE · NO ACTION" : s >= iCut ? "STRONG UP" : s >= 3 ? "UP" : s > 0 ? "SIDEWAYS UP" : s <= -iCut ? "STRONG DOWN" : s <= -3 ? "DOWN" : s < 0 ? "SIDEWAYS DOWN" : "SIDEWAYS"
    color bg = chop ? iColChop : s >= iCut ? iColUp : s >= 3 ? color.new(iColUp, 30) : s > 0 ? color.new(iColUp, 60) : s <= -iCut ? iColDn : s <= -3 ? color.new(iColDn, 30) : s < 0 ? color.new(iColDn, 60) : iColNeutral
    [txt, bg, chop ? #131722 : color.white]

string tblSize = iTableSize == "Tiny" ? size.tiny : iTableSize == "Normal" ? size.normal : iTableSize == "Large" ? size.large : size.small
var table tbl = table.new(position.top_right, 3, 10, bgcolor = C_ROW1, frame_color = C_HEAD, frame_width = 2, border_color = color.new(#000000, 100), border_width = 1)
f_cell(int c, int r, string t, color fg, color bg) =>
    tbl.cell(c, r, t, text_color = fg, bgcolor = bg, text_size = tblSize, text_halign = c == 0 ? text.align_left : text.align_center)
f_row(int r, string a, string b, color bCol, string c, color cCol) =>
    color rowBg = r % 2 == 0 ? C_ROW2 : C_ROW1
    f_cell(0, r, a, C_LBL, rowBg)
    f_cell(1, r, b, bCol, b == "" ? rowBg : f_tint(bCol))
    f_cell(2, r, c, cCol, c == "" ? rowBg : f_tint(cCol))
f_mtfRow(int r, string tf, float s, float san) =>
    f_row(r, f_tfLabel(tf), f_pct(s), f_scoreCol(s), f_sanText(san), f_sanCol(san))

if iShowTable and barstate.islast
    string thick = na(thickPct) ? "—" : thickPct < 20 ? "Thin" : thickPct > 80 ? "Thick" : "Normal"
    color thickCol = na(thickPct) ? iColNeutral : thickPct < 20 ? #FFB74D : thickPct > 80 ? #64B5F6 : #90A4AE
    f_cell(0, 0, "ICHIMOKU ITTO · One Glance, One Cut", C_GOLD, C_HEAD)
    tbl.merge_cells(0, 0, 2, 0)
    f_row(1, "Score", f_pct(score), f_scoreCol(score), "", na)
    f_row(2, "Zone", noCut ? "Chop" : "Trending", noCut ? iColChop : f_scoreCol(score), "", na)
    f_row(3, "Kumo", thick, thickCol, "", na)
    tbl.merge_cells(1, 1, 2, 1)
    tbl.merge_cells(1, 2, 2, 2)
    tbl.merge_cells(1, 3, 2, 3)
    f_cell(0, 4, "TF", C_SUBTXT, C_SUB)
    f_cell(1, 4, "Score", C_SUBTXT, C_SUB)
    f_cell(2, 4, "Aligned", C_SUBTXT, C_SUB)
    f_mtfRow(5, iTf1, mScore1, mSan1)
    f_mtfRow(6, iTf2, mScore2, mSan2)
    f_mtfRow(7, iTf3, mScore3, mSan3)
    f_mtfRow(8, iTf4, mScore4, mSan4)
    [trendTxt, trendBg, trendFg] = f_trend(score, noCut)
    f_cell(0, 9, "Trend", C_GOLD, C_HEAD)
    f_cell(1, 9, trendTxt, trendFg, trendBg)
    tbl.merge_cells(1, 9, 2, 9)

// ═══════════════ ALERTS ═══════════════
alertcondition(cutLong, "Strong Up", "Ichimoku Itto: score crossed up through the Strong threshold on {{ticker}} {{interval}}")
alertcondition(cutShort, "Strong Down", "Ichimoku Itto: score crossed down through the Strong threshold on {{ticker}} {{interval}}")
alertcondition(sanUp, "Aligned Up", "Ichimoku Itto: 3/3 Aligned Up (price, Tenkan/Kijun, Chikou) on {{ticker}} {{interval}}")
alertcondition(sanDn, "Aligned Down", "Ichimoku Itto: 3/3 Aligned Down (price, Tenkan/Kijun, Chikou) on {{ticker}} {{interval}}")
alertcondition(enterNoCut, "Enter Chop", "Ichimoku Itto: entered the chop zone on {{ticker}} {{interval}}")
alertcondition(exitNoCut, "Exit Chop", "Ichimoku Itto: left the chop zone on {{ticker}} {{interval}}")
````
