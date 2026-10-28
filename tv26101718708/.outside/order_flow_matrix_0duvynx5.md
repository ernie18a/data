# Order Flow Matrix

- url: https://www.tradingview.com/script/0duVYnx5-Order-Flow-Matrix/
- type: indicator
- pine_id: PUB;b21c35d9b741432c923cfd13b8decdc8
- version: 1.0

## Description

Order Flow Matrix
[url=https://www.tradingview.com/u/Michael_Fx_Trader/]https://www.tradingview.com/u/Michael_Fx_Trader/[/url]

Section 1 - What This Indicator Is

Order Flow Matrix is a multi-timeframe dashboard that estimates whether buyers or sellers are in control on the symbol you are viewing. It reads candle data and volume on five timeframes at the same time (default M15, M30, H1, H4 and D1), turns them into simple scores, and shows the result in one large table in the center of the chart. It was designed mainly for XAUUSD (gold), but it works on any symbol that has volume data.

Important: this is not real order flow. Pine Script has no access to real order book data or to what banks, funds or institutions are doing. Every number in the dashboard is an estimate built only from the open, high, low, close and volume of the chart. Nothing in the table is typed in by hand; every value is calculated from chart data.
[image]https://www.tradingview.com/x/NjwDpSsu/[/image]



Section 2 - Why It Was Built

Most traders check several timeframes by switching charts again and again, and they judge volume, trend, momentum and structure separately. This takes time and the pieces are rarely compared in one place. Order Flow Matrix puts the main questions in one table: who is pushing price (volume delta), is buying pressure building up over time (CVD), is price above or below the trend (EMA), what is the swing structure (pivots), and what is the overall weighted bias across timeframes.



Section 3 - Why It Is Not Just a Mashup

Every part of the script feeds one common scoring model. Volume delta, CVD, EMA bias and pivot structure are converted into 0 to 100 scores, weighted, and combined into one bull percentage per timeframe, and then into one overall percentage. The Technical Snapshot section (RSI, EMA distance, fair value gap, order block and relative volume) is a separate read-only section on the same dashboard so you can confirm the bias without opening other indicators. The calculations, scoring and layout were written from scratch for this script.
[image]https://www.tradingview.com/x/NjwDpSsu/[/image]


Section 4 - How It Works Step by Step

Step 1: For each of the five timeframes the script requests data with request. security, using one request per timeframe, with lookahead off and gaps off. There is no future data leak.

Step 2: On every bar the volume is split into estimated buy volume and sell volume (see Section 5).

Step 3: Delta is the sum of buy volume minus sell volume over the lookback (default 10 bars). It is scored from 0 to 100 by comparing it with the average absolute delta of the last 100 bars. A delta of zero gives a score of 50.

Step 4: CVD (cumulative volume delta) is compared with its own EMA and its 5-bar slope. Rising scores 100, Flat scores 50, Falling scores 0.

Step 5: EMA bias uses the fast EMA (default 50) and slow EMA (default 200). Price above the fast EMA with the fast above the slow is bullish (100). The mirror case is bearish (0). Everything else is neutral (50).

Step 6: Structure uses the last two confirmed pivot highs and the last two confirmed pivot lows. Higher highs with higher lows is bullish (100), lower highs with lower lows is bearish (0), otherwise Range (50).

Step 7: The four scores are combined with weights (default Delta 35, CVD 25, EMA 20, Structure 20) into the bull percentage of that timeframe. Bear percentage is 100 minus bull percentage.

Step 8: The timeframe bias is Bull if the bull percentage is 60 or more, Bear if it is 40 or less, and Neutral in between. The thresholds can be changed.

Step 9: The overall score is the weighted average of the timeframe bull percentages (default weights 10, 15, 20, 25, 30, normalized automatically over the visible rows).



Section 5 - Volume Delta Methods

Candle position: buy volume equals volume multiplied by (close minus low) divided by (high minus low), and sell volume equals volume multiplied by (high minus close) divided by (high minus low). If high equals low, the volume is split 50 and 50.

Candle direction: the whole volume goes to buyers if the candle closes above its open, to sellers if it closes below, and 50 and 50 if equal.

Lower timeframe (intrabar): every candle of a lower timeframe (default 1 minute) inside the bar is classified by close versus open. This needs a TradingView plan that supports that lower timeframe. If the data is not available, the script automatically falls back to the Candle position method, and the tooltip tells you which method was used.



Section 6 - The Main Dashboard

Each row is one timeframe. The columns are:

Timeframe - the label, for example M15, H1, D1.

Volume Delta (est.) - an arrow and the estimated net volume, for example up arrow plus 2.4K or down arrow minus 1.2K. Hover to see estimated buy volume, sell volume, the lookback and the method used.

CVD Trend - Rising, Falling or Flat.

EMA 50/200 - Above, Below or Mixed.

Structure - Higher high, Lower low or Range. Hover to see the last pivot high and pivot low comparison.

Bias - Bull, Bear or Neutral with a percentage, for example Bull 70 percent. Hover to see the four component scores, their weights and the weight of this timeframe in the overall score.

Green cells are bullish, red cells are bearish and grey cells are neutral or unavailable. Each cell is colored by its own component, so the table works like a heat map.



Section 7 - The Overall Bar

Under the timeframe rows there is a segmented bar made of 20 cells. The number of green cells equals the overall bull percentage divided by 5, and the remaining cells are red. Under the bar the exact text is shown, for example Bulls 62 percent and Bears 38 percent. This is the weighted result of all visible timeframes.



Section 8 - The Technical Snapshot

This second block gives one more row per timeframe, calculated on that timeframe:

RSI - the value with a label: Bullish above 50, Bearish below 50, Overbought at 70 or more, Oversold at 30 or less. Cell color is bullish at 55 or more and bearish at 45 or less.

Dist. EMA 50 - how far price is from the fast EMA in percent.

Last FVG - the most recent three-candle fair value gap (bullish when the low is above the high two bars earlier, bearish when the high is below the low two bars earlier), and whether price is above, inside or below it. Hover to see the zone prices.

Last Order Block - the last opposite candle before an impulse candle (body at least 1.5 times ATR by default), shown as intact, tapped or broken. Hover to see the zone prices.

Rel. Vol - the current bar volume divided by the 20-bar average volume, with High at 1.5x or more and Low below 0.5x.



Section 9 - How To Analyze With It

1) Start with the Overall bar. A value above 60 percent means most weighted timeframes lean bullish, below 40 percent means they lean bearish, and values in the middle mean the market is mixed.

2) Check alignment. The strongest situation is when all timeframes show the same bias. Mixed colors between lower and higher timeframes usually mean a pullback or a range.

3) Look at higher timeframes first (H4 and D1) to see the main direction, then use M15, M30 and H1 to time entries in that direction.

4) Compare delta and CVD. If delta is positive and CVD is Rising, buying pressure is consistent. If price rises while delta is negative and CVD is Falling, the move has weak support.

5) Use the Structure and EMA columns to confirm direction. Bull bias with Higher high and price Above the EMAs is a cleaner picture than Bull bias with Range structure.

6) Use the Technical Snapshot to avoid chasing. RSI at Overbought or Oversold, a large distance from the EMA, or price sitting inside an order block or fair value gap can warn you that a reaction is near.

7) Always manage risk with your own stop loss and position size. This dashboard shows bias, it is not an entry or exit signal.



Section 10 - Live Mode and Confirmed Mode

By default the dashboard is in live mode: every row uses the current forming bar, so values move up and down with price. If you switch on Use confirmed (closed) HTF bars only, every row reads the previous closed bar of its timeframe and the values stay fixed until the next bar closes. Both modes avoid lookahead. Live values can change before a bar closes, so a Bull reading on a forming bar can become Neutral by the close.



Section 11 - Settings

Timeframes: five timeframe inputs, a show checkbox and a weight for each, and the confirmed bars option.

Volume Delta: delta method, intrabar timeframe, delta lookback, and K and M number format.

CVD: EMA smoothing length.

Trend: fast and slow EMA lengths.

Structure: pivot length.

Scoring: weights of Delta, CVD, EMA and Structure, and the bull and bear thresholds.

Technical Snapshot: show or hide, RSI length, ATR length and the order block impulse size.

Style and Size: dashboard position (default center), dashboard width and height in percent of the chart (default large so it covers most of the chart while leaving the top and bottom free for the symbol name and time axis), theme (auto, dark, light), text size (auto scales with the dashboard), bull, bear and neutral colors, and tooltips on or off.



Section 12 - Alerts

Alerts are available for: overall bulls crossing above the bull threshold, overall bulls crossing below the bear threshold, all visible timeframes Bull at the same time, all visible timeframes Bear at the same time, and a bias flip on the third timeframe (H1 by default). Each message includes the symbol and the overall bull percentage.



Section 13 - Limitations

Volume on forex and gold is tick volume, not real traded volume, so buy and sell volume are estimates.

The intrabar method depends on your TradingView plan and on how much lower timeframe history is available.

CVD starts from the first loaded bar, so it can look different if you load more or less history.

In live mode values can change until the bar closes.

The dashboard is large by default and can cover candles. Reduce its width and height, or move it to a corner, if you want to see price behind it.

This indicator is for education and analysis only. It is not financial advice and it does not guarantee any result.



Section 14 - Original Script Declaration

Script name: Order Flow Matrix
Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Rights: All rights reserved by Michael_Fx_Trader.
Language: Pine Script version 6



Section 15 - Author Verification and Originality Statement

1) This indicator is an original implementation written from scratch for Michael_Fx_Trader.

2) No source code from any other TradingView script, library or open-source project has been copied, adapted, translated or reused. No third-party library is imported.

3) Every calculation uses only built-in Pine Script functions (request.security, request.security_lower_tf, ta functions, math functions and table functions). The building blocks (EMA, RSI, pivots, cumulative volume delta, fair value gaps and order blocks) are generic, publicly known technical analysis concepts, implemented here with independent logic, naming, scoring and layout.

4) The scoring model, the delta methods and the code are the author's own design.

5) The author is the sole owner of the script and holds the publishing rights to it.



Section 16 - Honesty Declaration

This indicator does not show real bank, hedge fund or institutional order flow. Pine Script has no access to real order book or participant data. Everything shown is an estimate built from candle data and volume. Nothing in the dashboard is hardcoded or invented; every value is calculated from chart data.

## Source Code

````pine
// =====================================================================================================
//  ORDER FLOW MATRIX  (OFM)
// =====================================================================================================
//
//  ORIGINAL SCRIPT DECLARATION
//  ---------------------------
//  Script name ...... Order Flow Matrix
//  Author ........... Michael_Fx_Trader
//  Publisher ........ Michael_Fx_Trader
//  Rights ........... All rights reserved by Michael_Fx_Trader.
//  Language ......... Pine Script(R) version 6
//
//  AUTHOR VERIFICATION AND ORIGINALITY STATEMENT
//  ---------------------------------------------
//  1. This indicator is an ORIGINAL implementation written from scratch for Michael_Fx_Trader.
//  2. No source code from any other TradingView script, library or open-source project has been copied,
//     adapted, translated or reused. No third-party library is imported.
//  3. Every calculation uses only built-in Pine Script functions (request.security,
//     request.security_lower_tf, ta.*, math.*, table.*). The building blocks (EMA, RSI, pivots,
//     cumulative volume delta, fair value gaps, order blocks) are generic, publicly known
//     technical-analysis concepts, implemented here with independent logic, naming, scoring and layout.
//  4. The reference screenshot supplied by the author was used only as a visual layout guide
//     (rows, columns, colors). The scoring model, the delta methods and the code are the author's own design.
//  5. The author is the sole owner of the script and holds the publishing rights to it.
//
//  HONESTY DECLARATION
//  -------------------
//  This indicator does NOT show real bank, hedge fund or institutional order flow. Pine Script has no access
//  to real order-book or participant data. Everything shown is an ESTIMATE built from candle data and
//  volume (tick volume on forex / gold). Nothing in the dashboard is hardcoded or invented; every value is
//  calculated from chart data.
//
//  This script is for educational and analytical purposes only. It is not financial advice.
// =====================================================================================================

//@version=6
indicator(title = "Order Flow Matrix", shorttitle = "OFM", overlay = true, max_bars_back = 500)

// =====================================================================================================
// SECTION 1 - CONSTANTS
// =====================================================================================================
const string M_POS = "Candle position"
const string M_DIR = "Candle direction"
const string M_LTF = "Lower timeframe (intrabar)"

const string G_TF  = "Timeframes"
const string G_DLT = "Volume delta"
const string G_CVD = "CVD"
const string G_TRD = "Trend"
const string G_STR = "Structure"
const string G_SCR = "Scoring"
const string G_TEC = "Technical snapshot"
const string G_STY = "Style and size"

// Table geometry: 23 columns. Normal rows use merged cells; the overall bar uses 20 narrow cells.
const int N_COLS = 23

// =====================================================================================================
// SECTION 2 - INPUTS
// =====================================================================================================

// ---- Timeframes ----
tf1 = input.timeframe("15",  "Timeframe 1", group = G_TF, inline = "t1")
tf2 = input.timeframe("30",  "Timeframe 2", group = G_TF, inline = "t2")
tf3 = input.timeframe("60",  "Timeframe 3", group = G_TF, inline = "t3")
tf4 = input.timeframe("240", "Timeframe 4", group = G_TF, inline = "t4")
tf5 = input.timeframe("D",   "Timeframe 5", group = G_TF, inline = "t5")

showTf1 = input.bool(true, "Show", group = G_TF, inline = "t1")
showTf2 = input.bool(true, "Show", group = G_TF, inline = "t2")
showTf3 = input.bool(true, "Show", group = G_TF, inline = "t3")
showTf4 = input.bool(true, "Show", group = G_TF, inline = "t4")
showTf5 = input.bool(true, "Show", group = G_TF, inline = "t5")

wTf1 = input.float(10.0, "Weight", minval = 0.0, group = G_TF, inline = "t1", tooltip = "Weight of this timeframe in the overall score. Weights of the visible timeframes are normalized automatically so that they sum to 100.")
wTf2 = input.float(15.0, "Weight", minval = 0.0, group = G_TF, inline = "t2")
wTf3 = input.float(20.0, "Weight", minval = 0.0, group = G_TF, inline = "t3")
wTf4 = input.float(25.0, "Weight", minval = 0.0, group = G_TF, inline = "t4")
wTf5 = input.float(30.0, "Weight", minval = 0.0, group = G_TF, inline = "t5")

confirmedOnly = input.bool(false, "Use confirmed (closed) HTF bars only", group = G_TF, tooltip = "OFF (default): LIVE mode. Every timeframe row uses the current, still-forming bar, so all values move up and down with every price tick. ON: every row reads the previous CLOSED bar of that timeframe, so values stay fixed until the next bar closes.")

// ---- Volume delta ----
deltaMethod = input.string(M_POS, "Delta method", options = [M_POS, M_DIR, M_LTF], group = G_DLT, tooltip = "Candle position: buyVol = volume x (close - low) / (high - low), sellVol = volume x (high - close) / (high - low); 50/50 if high == low.\nCandle direction: whole volume goes to buy if close > open, to sell if close < open, 50/50 if equal.\nLower timeframe (intrabar): every intrabar candle on the chosen lower timeframe is classified by close vs open. Needs a TradingView plan that supports the chosen lower timeframe; if the data is unavailable the script falls back to Candle position automatically.")
ltfIn       = input.timeframe("1", "Intrabar timeframe", group = G_DLT, tooltip = "Lower timeframe used only by the 'Lower timeframe (intrabar)' method. It must be lower than every visible timeframe row. Intrabar history depth depends on your TradingView plan.")
dLen        = input.int(10, "Delta lookback (bars)", minval = 1, maxval = 200, group = G_DLT, tooltip = "Number of bars (on each timeframe) summed to get the volume delta.")
useKM       = input.bool(true, "Show delta in K / M format", group = G_DLT)

// ---- CVD ----
cLen = input.int(20, "CVD smoothing length (EMA)", minval = 2, group = G_CVD, tooltip = "CVD trend = Rising when CVD is above its EMA and the 5-bar CVD slope is positive; Falling when the opposite; otherwise Flat.")

// ---- Trend ----
fLen = input.int(50,  "Fast EMA length", minval = 2, group = G_TRD)
sLen = input.int(200, "Slow EMA length", minval = 2, group = G_TRD)

// ---- Structure ----
pLen = input.int(5, "Pivot length", minval = 1, maxval = 50, group = G_STR, tooltip = "Left and right bars for ta.pivothigh / ta.pivotlow on each timeframe. The last two confirmed pivot highs and lows decide the structure.")

// ---- Scoring ----
wD = input.float(35.0, "Weight: Delta",     minval = 0.0, group = G_SCR, tooltip = "Component weights inside each timeframe. They are normalized automatically.")
wC = input.float(25.0, "Weight: CVD",       minval = 0.0, group = G_SCR)
wE = input.float(20.0, "Weight: EMA",       minval = 0.0, group = G_SCR)
wS = input.float(20.0, "Weight: Structure", minval = 0.0, group = G_SCR)
thrBull = input.float(60.0, "Bull threshold (bull % >=)", minval = 50.0, maxval = 100.0, group = G_SCR)
thrBear = input.float(40.0, "Bear threshold (bull % <=)", minval = 0.0,  maxval = 50.0,  group = G_SCR)

// ---- Technical snapshot (RSI, EMA distance, FVG, order block, relative volume) ----
showTech = input.bool(true, "Show technical snapshot section", group = G_TEC)
rLen     = input.int(14, "RSI length", minval = 2, group = G_TEC)
atrLen   = input.int(14, "ATR length (order block impulse)", minval = 2, group = G_TEC)
impMult  = input.float(1.5, "Order block impulse (body >= x ATR)", minval = 0.5, step = 0.1, group = G_TEC, tooltip = "A bullish (bearish) order block is the last bearish (bullish) candle before an impulse candle whose body is at least this many ATRs. A fair value gap is a 3-candle gap: bullish when low > high[2], bearish when high < low[2]. Both are evaluated on each timeframe row.")

// ---- Style and size ----
tblPos     = input.string("middle_center", "Dashboard position", options = ["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group = G_STY, tooltip = "Default: centered on the chart.")
dashW      = input.float(88.0, "Dashboard width (% of chart width)", minval = 20.0, maxval = 100.0, step = 1.0, group = G_STY, tooltip = "Make the dashboard wider or narrower. Default is large so it covers most of the chart.")
dashH      = input.float(80.0, "Dashboard height (% of chart height)", minval = 20.0, maxval = 100.0, step = 1.0, group = G_STY, tooltip = "Make the dashboard taller or shorter. The top and bottom margins stay free for the symbol name, legend and time axis.")
themeIn    = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = G_STY, tooltip = "Auto follows the chart background color.")
textSizeIn = input.string("auto", "Text size", options = ["auto", "tiny", "small", "normal", "large", "huge"], group = G_STY, tooltip = "Auto scales the text with the cell size, so the text grows and shrinks together with the dashboard.")
bullCol    = input.color(#16C784, "Bull color", group = G_STY)
bearCol    = input.color(#F23645, "Bear color", group = G_STY)
neutCol    = input.color(#6B7280, "Neutral color", group = G_STY)
showTips   = input.bool(true, "Show tooltips on cells", group = G_STY)

// =====================================================================================================
// SECTION 3 - DERIVED SETTINGS
// =====================================================================================================
int off = confirmedOnly ? 1 : 0

// Component weights (normalized to sum 100)
float wCompTot = wD + wC + wE + wS
float nD = wCompTot > 0 ? wD / wCompTot * 100.0 : 25.0
float nC = wCompTot > 0 ? wC / wCompTot * 100.0 : 25.0
float nE = wCompTot > 0 ? wE / wCompTot * 100.0 : 25.0
float nS = wCompTot > 0 ? wS / wCompTot * 100.0 : 25.0

// Timeframe weights (normalized over the visible rows)
float rw1 = showTf1 ? wTf1 : 0.0
float rw2 = showTf2 ? wTf2 : 0.0
float rw3 = showTf3 ? wTf3 : 0.0
float rw4 = showTf4 ? wTf4 : 0.0
float rw5 = showTf5 ? wTf5 : 0.0
float rwSum = rw1 + rw2 + rw3 + rw4 + rw5
float nw1 = rwSum > 0 ? rw1 / rwSum * 100.0 : 0.0
float nw2 = rwSum > 0 ? rw2 / rwSum * 100.0 : 0.0
float nw3 = rwSum > 0 ? rw3 / rwSum * 100.0 : 0.0
float nw4 = rwSum > 0 ? rw4 / rwSum * 100.0 : 0.0
float nw5 = rwSum > 0 ? rw5 / rwSum * 100.0 : 0.0

string txtSize = switch textSizeIn
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    "huge"   => size.huge
    =>          size.auto

// Dark / light theme (Auto reads the chart background luminance)
float bgLum = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
bool isDark = themeIn == "Dark" or (themeIn == "Auto" and bgLum < 128)

// Cell geometry in % of the chart. Filled in on the last bar once the number of rows is known.
float colW = dashW / N_COLS
float rowH = 4.0

// =====================================================================================================
// SECTION 4 - HELPER FUNCTIONS
// =====================================================================================================

// Converts a timeframe string into a short label (M15, H1, D1 ...)
f_tfLabel(string tf) =>
    int sec = timeframe.in_seconds(tf)
    string out = ""
    if sec < 3600
        out := "M" + str.tostring(math.round(sec / 60))
    else if sec < 86400
        out := "H" + str.tostring(math.round(sec / 3600))
    else if sec < 604800
        out := "D" + str.tostring(math.round(sec / 86400))
    else if sec < 2592000
        out := "W" + str.tostring(math.round(sec / 604800))
    else
        out := "MN"
    out

// Formats a number as +2.4K / -1.2M (or a plain integer when K/M is switched off)
f_fmt(float v) =>
    float a = math.abs(v)
    string body = str.tostring(a, "#")
    if useKM
        if a >= 1000000000.0
            body := str.tostring(a / 1000000000.0, "#.##") + "B"
        else if a >= 1000000.0
            body := str.tostring(a / 1000000.0, "#.##") + "M"
        else if a >= 1000.0
            body := str.tostring(a / 1000.0, "#.#") + "K"
    na(v) ? "n/a" : (v < 0 ? "-" : "+") + body

// Maps the delta method code used for a bar to readable text
f_methodTxt(int us) =>
    switch us
        0 => M_POS
        1 => M_DIR
        2 => M_LTF + " (" + ltfIn + ")"
        3 => M_POS + " (intrabar data unavailable, fallback)"
        => "n/a"

// Cell background by state: 1 bull, -1 bear, 0 neutral, anything else = n/a
f_bg(int st) =>
    color c = na
    if isDark
        c := st == 1 ? color.new(bullCol, 0) : st == -1 ? color.new(bearCol, 0) : st == 0 ? color.new(neutCol, 0) : color.new(#4B5563, 0)
    else
        c := st == 1 ? #4ADE80 : st == -1 ? #F87171 : st == 0 ? #D1D5DB : #E5E7EB
    c

// Cell text color by state
f_tc(int st) =>
    color c = na
    if isDark
        c := st == 1 or st == -1 or st == 0 ? #FFFFFF : #9CA3AF
    else
        c := st == 1 ? #052E16 : st == -1 ? #450A0A : st == 0 ? #1F2937 : #6B7280
    c

// Converts a bull % into a bias code: 1 bull, -1 bear, 0 neutral, 9 unavailable
f_biasCode(float p) =>
    na(p) ? 9 : p >= thrBull ? 1 : p <= thrBear ? -1 : 0

// Weighted bull % of one timeframe from its four component states
f_bullPct(float dS, int c, int e, int sh, int sl) =>
    float cS = c == 1 ? 100.0 : c == -1 ? 0.0 : 50.0
    float eS = e == 1 ? 100.0 : e == -1 ? 0.0 : 50.0
    float sS = sh == 1 and sl == 1 ? 100.0 : sh == -1 and sl == -1 ? 0.0 : 50.0
    na(dS) ? na : (dS * nD + cS * nC + eS * nE + sS * nS) / (nD + nC + nE + nS)

// Splits the bar volume into estimated buy / sell volume. Returns [buyVol, sellVol, methodUsedCode].
f_split(string method, string ltf) =>
    float vol = nz(volume)
    float rng = high - low
    float bPos = rng > 0 ? vol * (close - low) / rng : vol * 0.5
    float sPos = rng > 0 ? vol * (high - close) / rng : vol * 0.5
    float bDir = close > open ? vol : close == open ? vol * 0.5 : 0.0
    float sDir = close < open ? vol : close == open ? vol * 0.5 : 0.0
    float bIb = na
    float sIb = na
    if method == M_LTF
        // Intrabar volume classified by close vs open on the chosen lower timeframe (nested request, Pine v6 dynamic requests)
        array<float> bArr = request.security_lower_tf("", ltf, close > open ? volume : close == open ? volume * 0.5 : 0.0, ignore_invalid_symbol = true, ignore_invalid_timeframe = true)
        array<float> sArr = request.security_lower_tf("", ltf, close < open ? volume : close == open ? volume * 0.5 : 0.0, ignore_invalid_symbol = true, ignore_invalid_timeframe = true)
        bIb := na(bArr) ? na : bArr.sum()
        sIb := na(sArr) ? na : sArr.sum()
    bool ibOk = not na(bIb) and not na(sIb) and (bIb + sIb) > 0
    float b = method == M_DIR ? bDir : method == M_LTF ? (ibOk ? bIb : bPos) : bPos
    float s = method == M_DIR ? sDir : method == M_LTF ? (ibOk ? sIb : sPos) : sPos
    int used = method == M_DIR ? 1 : method == M_LTF ? (ibOk ? 2 : 3) : 0
    [b, s, used]

// All per-timeframe calculations. Executed INSIDE request.security so it runs on the requested timeframe.
// Returns 20 values:
//  [buySum, sellSum, delta, deltaScore, cvdTrend, emaBias, structHigh, structLow, methodUsed,
//   rsi, emaDistPct, fvgDir, fvgState, fvgTop, fvgBottom, obDir, obState, obTop, obBottom, relVolume]
// cvdTrend / emaBias: 1 bullish, -1 bearish, 0 neutral.  structHigh / structLow: 1 higher, -1 lower, 0 unknown.
// fvgDir / obDir: 1 bullish zone, -1 bearish zone, 0 none.  fvgState / obState: 1 price above zone, 0 inside, -1 below.
f_calc(string method, string ltf, int dl, int cl, int fl, int sl, int pl, int rl, int al, float im, int offs) =>
    [b, s, used] = f_split(method, ltf)
    float net = b - s

    // 1) Volume delta over the lookback and its score (0-100, 50 = neutral)
    float bSum = math.sum(b, dl)
    float sSum = math.sum(s, dl)
    float delta = bSum - sSum
    float avgAbs = ta.sma(math.abs(delta), 100)
    float dScore = na
    if not na(delta)
        dScore := avgAbs > 0 ? math.max(0.0, math.min(100.0, 50.0 + 25.0 * delta / avgAbs)) : 50.0

    // 2) CVD trend
    float cvd = ta.cum(net)
    float cvdE = ta.ema(cvd, cl)
    float slope = cvd - cvd[5]
    int cvdT = cvd > cvdE and slope > 0 ? 1 : cvd < cvdE and slope < 0 ? -1 : 0

    // 3) EMA bias and distance from the fast EMA
    float ef = ta.ema(close, fl)
    float es = ta.ema(close, sl)
    int emaB = close > ef and ef > es ? 1 : close < ef and ef < es ? -1 : 0
    float efDist = ef > 0 ? (close / ef - 1.0) * 100.0 : na

    // 4) Structure from the last two confirmed pivot highs / lows
    float ph = ta.pivothigh(high, pl, pl)
    float pv = ta.pivotlow(low, pl, pl)
    float h0 = ta.valuewhen(not na(ph), ph, 0)
    float h1 = ta.valuewhen(not na(ph), ph, 1)
    float l0 = ta.valuewhen(not na(pv), pv, 0)
    float l1 = ta.valuewhen(not na(pv), pv, 1)
    int sH = na(h0) or na(h1) ? 0 : h0 > h1 ? 1 : h0 < h1 ? -1 : 0
    int sL = na(l0) or na(l1) ? 0 : l0 > l1 ? 1 : l0 < l1 ? -1 : 0

    // 5) RSI
    float rsiV = ta.rsi(close, rl)

    // 6) Relative volume (current bar volume / 20-bar average)
    float volN = nz(volume)
    float volAvg = ta.sma(volN, 20)
    float rVol = volAvg > 0 ? volN / volAvg : na

    // 7) Latest fair value gap (3-candle gap) and where price sits relative to it
    bool bullFvg = low > high[2]
    bool bearFvg = high < low[2]
    float bfTop = ta.valuewhen(bullFvg, low, 0)
    float bfBot = ta.valuewhen(bullFvg, high[2], 0)
    float sfTop = ta.valuewhen(bearFvg, low[2], 0)
    float sfBot = ta.valuewhen(bearFvg, high, 0)
    int bfAge = ta.barssince(bullFvg)
    int sfAge = ta.barssince(bearFvg)
    int fvgDir = na(bfAge) and na(sfAge) ? 0 : na(sfAge) ? 1 : na(bfAge) ? -1 : bfAge <= sfAge ? 1 : -1
    float fvgTop = fvgDir == 1 ? bfTop : fvgDir == -1 ? sfTop : na
    float fvgBot = fvgDir == 1 ? bfBot : fvgDir == -1 ? sfBot : na
    int fvgSt = fvgDir == 0 ? 0 : close > fvgTop ? 1 : close < fvgBot ? -1 : 0

    // 8) Latest order block: last opposite candle before an impulse candle (body >= im x ATR)
    float atrV = ta.atr(al)
    bool bullImp = close > open and (close - open) >= im * atrV and close[1] < open[1]
    bool bearImp = close < open and (open - close) >= im * atrV and close[1] > open[1]
    float boTop = ta.valuewhen(bullImp, high[1], 0)
    float boBot = ta.valuewhen(bullImp, low[1], 0)
    float soTop = ta.valuewhen(bearImp, high[1], 0)
    float soBot = ta.valuewhen(bearImp, low[1], 0)
    int boAge = ta.barssince(bullImp)
    int soAge = ta.barssince(bearImp)
    int obDir = na(boAge) and na(soAge) ? 0 : na(soAge) ? 1 : na(boAge) ? -1 : boAge <= soAge ? 1 : -1
    float obTop = obDir == 1 ? boTop : obDir == -1 ? soTop : na
    float obBot = obDir == 1 ? boBot : obDir == -1 ? soBot : na
    int obSt = obDir == 0 ? 0 : close > obTop ? 1 : close < obBot ? -1 : 0

    // offs = 1 -> read the previous CLOSED bar of the requested timeframe, offs = 0 -> live bar
    [bSum[offs], sSum[offs], delta[offs], dScore[offs], cvdT[offs], emaB[offs], sH[offs], sL[offs], used[offs], rsiV[offs], efDist[offs], fvgDir[offs], fvgSt[offs], fvgTop[offs], fvgBot[offs], obDir[offs], obSt[offs], obTop[offs], obBot[offs], rVol[offs]]

// One merged cell. Height follows the dashboard height setting.
f_cell(table t, int col, int row, int span, string txt, color bg, color tc, string tip, bool bold) =>
    table.cell(t, col, row, txt, height = rowH, text_color = tc, text_halign = text.align_center, text_valign = text.align_center, text_size = txtSize, bgcolor = bg, tooltip = showTips ? tip : "", text_formatting = bold ? text.format_bold : text.format_none)
    if span > 1
        table.merge_cells(t, col, row, col + span - 1, row)

// One timeframe row of the main dashboard
f_drawRow(table t, int r, string lbl, float nw, float bS, float sS, float dl, float dScore, int cv, int em, int sh, int sl, int us, float pct) =>
    bool ok = not na(dl)
    int dSt = not ok ? 9 : dl > 0 ? 1 : dl < 0 ? -1 : 0
    int cSt = not ok ? 9 : nz(cv)
    int eSt = not ok ? 9 : nz(em)
    int sSt = not ok ? 9 : (sh == 1 and sl == 1) ? 1 : (sh == -1 and sl == -1) ? -1 : 0
    int bSt = f_biasCode(pct)

    string dTxt = not ok ? "n/a" : (dl > 0 ? "▲ " : dl < 0 ? "▼ " : "■ ") + f_fmt(dl)
    string cTxt = not ok ? "n/a" : cv == 1 ? "Rising" : cv == -1 ? "Falling" : "Flat"
    string eTxt = not ok ? "n/a" : em == 1 ? "Above" : em == -1 ? "Below" : "Mixed"
    string sTxt = not ok ? "n/a" : sSt == 1 ? "Higher high" : sSt == -1 ? "Lower low" : "Range"
    string bTxt = na(pct) ? "n/a" : pct >= thrBull ? "Bull " + str.tostring(math.round(pct)) + "%" : pct <= thrBear ? "Bear " + str.tostring(math.round(100.0 - pct)) + "%" : "Neutral " + str.tostring(math.round(math.max(pct, 100.0 - pct))) + "%"

    string hiTxt = sh == 1 ? "Higher high" : sh == -1 ? "Lower high" : "n/a"
    string loTxt = sl == 1 ? "Higher low" : sl == -1 ? "Lower low" : "n/a"
    string tipD = "Estimated buy volume: " + f_fmt(bS) + "\nEstimated sell volume: " + f_fmt(sS) + "\nLookback: " + str.tostring(dLen) + " bars\nMethod: " + f_methodTxt(us)
    string tipS = "Last pivot high vs previous: " + hiTxt + "\nLast pivot low vs previous: " + loTxt
    string tipB = "Component scores (0-100, 100 = fully bullish)\nDelta: " + str.tostring(dScore, "#.#") + "  (weight " + str.tostring(nD, "#.#") + "%)\nCVD: " + (cv == 1 ? "100" : cv == -1 ? "0" : "50") + "  (weight " + str.tostring(nC, "#.#") + "%)\nEMA: " + (em == 1 ? "100" : em == -1 ? "0" : "50") + "  (weight " + str.tostring(nE, "#.#") + "%)\nStructure: " + (sSt == 1 ? "100" : sSt == -1 ? "0" : "50") + "  (weight " + str.tostring(nS, "#.#") + "%)\nTimeframe bull %: " + str.tostring(pct, "#.#") + "\nTimeframe weight in overall: " + str.tostring(nw, "#.#") + "%"

    color lblBg = isDark ? #1F2937 : #E5E7EB
    color lblTc = isDark ? #FFFFFF : #111827
    f_cell(t, 0,  r, 3, lbl,  lblBg,      lblTc,      "Timeframe " + lbl, true)
    f_cell(t, 3,  r, 5, dTxt, f_bg(dSt),  f_tc(dSt),  tipD, true)
    f_cell(t, 8,  r, 4, cTxt, f_bg(cSt),  f_tc(cSt),  "CVD vs its EMA(" + str.tostring(cLen) + ") and 5-bar slope", true)
    f_cell(t, 12, r, 4, eTxt, f_bg(eSt),  f_tc(eSt),  "Close vs EMA " + str.tostring(fLen) + " and EMA " + str.tostring(fLen) + " vs EMA " + str.tostring(sLen), true)
    f_cell(t, 16, r, 4, sTxt, f_bg(sSt),  f_tc(sSt),  tipS, true)
    f_cell(t, 20, r, 3, bTxt, f_bg(bSt),  f_tc(bSt),  tipB, true)

// One timeframe row of the technical snapshot (RSI, EMA distance, FVG, order block, relative volume)
f_drawTech(table t, int r, string lbl, float rs, float ed, int fd, int fs, float ft, float fb, int od, int os, float ot, float ob, float rv) =>
    int fDir = nz(fd)
    int oDir = nz(od)
    int fSt = nz(fs)
    int oSt = nz(os)

    // RSI
    int rSt = na(rs) ? 9 : rs >= 55 ? 1 : rs <= 45 ? -1 : 0
    string rTxt = na(rs) ? "n/a" : str.tostring(rs, "#.#") + (rs >= 70 ? "  Overbought" : rs <= 30 ? "  Oversold" : rs > 50 ? "  Bullish" : rs < 50 ? "  Bearish" : "")

    // Distance from the fast EMA
    int eSt = na(ed) ? 9 : ed > 0 ? 1 : ed < 0 ? -1 : 0
    string eTxt = na(ed) ? "n/a" : (ed >= 0 ? "+" : "") + str.tostring(ed, "#.##") + "%"

    // Latest fair value gap
    int fCol = fDir == 0 ? 9 : fDir
    string fTxt = fDir == 0 ? "None" : (fDir == 1 ? "Bull FVG" : "Bear FVG") + (fSt == 1 ? " (price above)" : fSt == -1 ? " (price below)" : " (price inside)")
    string fTip = fDir == 0 ? "No fair value gap found" : "Zone: " + str.tostring(fb, format.mintick) + " - " + str.tostring(ft, format.mintick) + "\n3-candle gap, most recent one on this timeframe"

    // Latest order block
    bool oBroken = (oDir == 1 and oSt == -1) or (oDir == -1 and oSt == 1)
    int oCol = oDir == 0 ? 9 : oBroken ? 0 : oDir
    string oTxt = oDir == 0 ? "None" : (oDir == 1 ? "Bull OB" : "Bear OB") + (oBroken ? " (broken)" : oSt == 0 ? " (tapped)" : " (intact)")
    string oTip = oDir == 0 ? "No order block found" : "Zone: " + str.tostring(ob, format.mintick) + " - " + str.tostring(ot, format.mintick) + "\nLast opposite candle before an impulse candle (body >= " + str.tostring(impMult, "#.#") + " x ATR)"

    // Relative volume
    int vCol = na(rv) ? 9 : 0
    string vTxt = na(rv) ? "n/a" : str.tostring(rv, "#.##") + "x" + (rv >= 1.5 ? "  High" : rv < 0.5 ? "  Low" : "")

    color lblBg = isDark ? #1F2937 : #E5E7EB
    color lblTc = isDark ? #FFFFFF : #111827
    f_cell(t, 0,  r, 3, lbl,  lblBg,      lblTc,      "Timeframe " + lbl, true)
    f_cell(t, 3,  r, 4, rTxt, f_bg(rSt),  f_tc(rSt),  "RSI(" + str.tostring(rLen) + "): >= 55 bullish, <= 45 bearish, 70 / 30 = overbought / oversold", true)
    f_cell(t, 7,  r, 4, eTxt, f_bg(eSt),  f_tc(eSt),  "Close distance from EMA " + str.tostring(fLen), true)
    f_cell(t, 11, r, 5, fTxt, f_bg(fCol), f_tc(fCol), fTip, true)
    f_cell(t, 16, r, 5, oTxt, f_bg(oCol), f_tc(oCol), oTip, true)
    f_cell(t, 21, r, 2, vTxt, f_bg(vCol), f_tc(vCol), "Bar volume / 20-bar average volume (tick volume on forex / gold)", true)

// =====================================================================================================
// SECTION 5 - HIGHER-TIMEFRAME REQUESTS (ONE security call per timeframe, tuple result)
// =====================================================================================================
// lookahead_off + gaps_off: no future leak. With "confirmed bars only" the values are offset by one HTF bar inside f_calc.
[bS1, sS1, dl1, ds1, cv1, em1, sh1, sl1, us1, rs1, ed1, fd1, fs1, ft1, fb1, od1, os1, ot1, ob1, rv1] = request.security(syminfo.tickerid, tf1, f_calc(deltaMethod, ltfIn, dLen, cLen, fLen, sLen, pLen, rLen, atrLen, impMult, off), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[bS2, sS2, dl2, ds2, cv2, em2, sh2, sl2, us2, rs2, ed2, fd2, fs2, ft2, fb2, od2, os2, ot2, ob2, rv2] = request.security(syminfo.tickerid, tf2, f_calc(deltaMethod, ltfIn, dLen, cLen, fLen, sLen, pLen, rLen, atrLen, impMult, off), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[bS3, sS3, dl3, ds3, cv3, em3, sh3, sl3, us3, rs3, ed3, fd3, fs3, ft3, fb3, od3, os3, ot3, ob3, rv3] = request.security(syminfo.tickerid, tf3, f_calc(deltaMethod, ltfIn, dLen, cLen, fLen, sLen, pLen, rLen, atrLen, impMult, off), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[bS4, sS4, dl4, ds4, cv4, em4, sh4, sl4, us4, rs4, ed4, fd4, fs4, ft4, fb4, od4, os4, ot4, ob4, rv4] = request.security(syminfo.tickerid, tf4, f_calc(deltaMethod, ltfIn, dLen, cLen, fLen, sLen, pLen, rLen, atrLen, impMult, off), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[bS5, sS5, dl5, ds5, cv5, em5, sh5, sl5, us5, rs5, ed5, fd5, fs5, ft5, fb5, od5, os5, ot5, ob5, rv5] = request.security(syminfo.tickerid, tf5, f_calc(deltaMethod, ltfIn, dLen, cLen, fLen, sLen, pLen, rLen, atrLen, impMult, off), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// =====================================================================================================
// SECTION 6 - SCORES (calculated on every bar so that alerts work)
// =====================================================================================================
float pct1 = f_bullPct(ds1, cv1, em1, sh1, sl1)
float pct2 = f_bullPct(ds2, cv2, em2, sh2, sl2)
float pct3 = f_bullPct(ds3, cv3, em3, sh3, sl3)
float pct4 = f_bullPct(ds4, cv4, em4, sh4, sl4)
float pct5 = f_bullPct(ds5, cv5, em5, sh5, sl5)

// Overall bull % = weighted average of the timeframe bull % values (only visible, available rows)
float aw1 = showTf1 and not na(pct1) ? nw1 : 0.0
float aw2 = showTf2 and not na(pct2) ? nw2 : 0.0
float aw3 = showTf3 and not na(pct3) ? nw3 : 0.0
float aw4 = showTf4 and not na(pct4) ? nw4 : 0.0
float aw5 = showTf5 and not na(pct5) ? nw5 : 0.0
float awSum = aw1 + aw2 + aw3 + aw4 + aw5
float overallBull = awSum > 0 ? (nz(pct1) * aw1 + nz(pct2) * aw2 + nz(pct3) * aw3 + nz(pct4) * aw4 + nz(pct5) * aw5) / awSum : na
float overallBear = na(overallBull) ? na : 100.0 - overallBull

int bc1 = f_biasCode(pct1)
int bc2 = f_biasCode(pct2)
int bc3 = f_biasCode(pct3)
int bc4 = f_biasCode(pct4)
int bc5 = f_biasCode(pct5)

bool anyVis = showTf1 or showTf2 or showTf3 or showTf4 or showTf5
bool allBull = anyVis and (not showTf1 or bc1 == 1) and (not showTf2 or bc2 == 1) and (not showTf3 or bc3 == 1) and (not showTf4 or bc4 == 1) and (not showTf5 or bc5 == 1)
bool allBear = anyVis and (not showTf1 or bc1 == -1) and (not showTf2 or bc2 == -1) and (not showTf3 or bc3 == -1) and (not showTf4 or bc4 == -1) and (not showTf5 or bc5 == -1)

// Hidden plots: they only feed the {{plot()}} placeholders of the alerts
plot(overallBull, "Overall Bull %", display = display.none)
plot(overallBear, "Overall Bear %", display = display.none)

// =====================================================================================================
// SECTION 7 - TABLE DRAWING (last bar only)
// =====================================================================================================
f_pos(string p) =>
    switch p
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right"  => position.bottom_right
        => position.middle_center

var table ofmTbl = na

if barstate.islast
    if not na(ofmTbl)
        table.delete(ofmTbl)

    int nVis = (showTf1 ? 1 : 0) + (showTf2 ? 1 : 0) + (showTf3 ? 1 : 0) + (showTf4 ? 1 : 0) + (showTf5 ? 1 : 0)
    // Row 0 is a hair-thin "ruler" row that fixes the column widths; the visible rows share the dashboard height.
    int nRows = 1 + 2 + nVis + 2 + (showTech ? 2 + nVis : 0)
    rowH := dashH / (nRows - 1)

    ofmTbl := table.new(f_pos(tblPos), N_COLS, nRows, bgcolor = #0B1220, frame_color = #0B1220, frame_width = 1, border_color = #0B1220, border_width = 1)

    // Ruler row: gives every column the same width (dashboard width / 23)
    for c = 0 to N_COLS - 1
        table.cell(ofmTbl, c, 0, "", width = colW, height = 0.05, bgcolor = #0B1220)

    // Row 1: title
    f_cell(ofmTbl, 0, 1, N_COLS, "Bull vs Bear panel - " + syminfo.ticker, #0B1220, #FFFFFF, "Order Flow Matrix by Michael_Fx_Trader", true)

    // Row 2: column headers
    color hdrBg = #0B1220
    color hdrTc = #9CA3AF
    f_cell(ofmTbl, 0,  2, 3, "Timeframe",                                   hdrBg, hdrTc, "", false)
    f_cell(ofmTbl, 3,  2, 5, "Volume delta (est.)",                         hdrBg, hdrTc, "", false)
    f_cell(ofmTbl, 8,  2, 4, "CVD trend",                                   hdrBg, hdrTc, "", false)
    f_cell(ofmTbl, 12, 2, 4, "EMA " + str.tostring(fLen) + "/" + str.tostring(sLen), hdrBg, hdrTc, "", false)
    f_cell(ofmTbl, 16, 2, 4, "Structure",                                   hdrBg, hdrTc, "", false)
    f_cell(ofmTbl, 20, 2, 3, "Bias",                                        hdrBg, hdrTc, "", false)

    // Timeframe rows
    int r = 3
    if showTf1
        f_drawRow(ofmTbl, r, f_tfLabel(tf1), nw1, bS1, sS1, dl1, ds1, cv1, em1, sh1, sl1, us1, pct1)
        r += 1
    if showTf2
        f_drawRow(ofmTbl, r, f_tfLabel(tf2), nw2, bS2, sS2, dl2, ds2, cv2, em2, sh2, sl2, us2, pct2)
        r += 1
    if showTf3
        f_drawRow(ofmTbl, r, f_tfLabel(tf3), nw3, bS3, sS3, dl3, ds3, cv3, em3, sh3, sl3, us3, pct3)
        r += 1
    if showTf4
        f_drawRow(ofmTbl, r, f_tfLabel(tf4), nw4, bS4, sS4, dl4, ds4, cv4, em4, sh4, sl4, us4, pct4)
        r += 1
    if showTf5
        f_drawRow(ofmTbl, r, f_tfLabel(tf5), nw5, bS5, sS5, dl5, ds5, cv5, em5, sh5, sl5, us5, pct5)
        r += 1

    // Overall row: label + 20-cell segmented bar (green = bulls, red = bears)
    color lblBg = isDark ? #1F2937 : #E5E7EB
    color lblTc = isDark ? #FFFFFF : #111827
    f_cell(ofmTbl, 0, r, 3, "Overall", lblBg, lblTc, "Weighted multi-timeframe score", true)
    int greenN = na(overallBull) ? 0 : math.round(overallBull / 5.0)
    for i = 0 to 19
        color segCol = na(overallBull) ? color.new(#4B5563, 0) : i < greenN ? color.new(bullCol, 0) : color.new(bearCol, 0)
        table.cell(ofmTbl, 3 + i, r, "", width = colW, height = rowH, bgcolor = segCol)
    r += 1

    // Overall text row
    string ovTxt = na(overallBull) ? "Bulls n/a | Bears n/a" : "Bulls " + str.tostring(math.round(overallBull)) + "% | Bears " + str.tostring(math.round(overallBear)) + "%"
    f_cell(ofmTbl, 0, r, N_COLS, ovTxt, lblBg, lblTc, "Overall = weighted average of the timeframe bull % values", true)
    r += 1

    // Technical snapshot block
    if showTech
        f_cell(ofmTbl, 0, r, N_COLS, "Technical snapshot - RSI, EMA, FVG, order block, volume", hdrBg, #FFFFFF, "Each row is calculated on its own timeframe", true)
        r += 1
        f_cell(ofmTbl, 0,  r, 3, "Timeframe",                                      hdrBg, hdrTc, "", false)
        f_cell(ofmTbl, 3,  r, 4, "RSI (" + str.tostring(rLen) + ")",               hdrBg, hdrTc, "", false)
        f_cell(ofmTbl, 7,  r, 4, "Dist. EMA " + str.tostring(fLen),                hdrBg, hdrTc, "", false)
        f_cell(ofmTbl, 11, r, 5, "Last FVG",                                       hdrBg, hdrTc, "", false)
        f_cell(ofmTbl, 16, r, 5, "Last order block",                               hdrBg, hdrTc, "", false)
        f_cell(ofmTbl, 21, r, 2, "Rel. vol",                                       hdrBg, hdrTc, "", false)
        r += 1
        if showTf1
            f_drawTech(ofmTbl, r, f_tfLabel(tf1), rs1, ed1, fd1, fs1, ft1, fb1, od1, os1, ot1, ob1, rv1)
            r += 1
        if showTf2
            f_drawTech(ofmTbl, r, f_tfLabel(tf2), rs2, ed2, fd2, fs2, ft2, fb2, od2, os2, ot2, ob2, rv2)
            r += 1
        if showTf3
            f_drawTech(ofmTbl, r, f_tfLabel(tf3), rs3, ed3, fd3, fs3, ft3, fb3, od3, os3, ot3, ob3, rv3)
            r += 1
        if showTf4
            f_drawTech(ofmTbl, r, f_tfLabel(tf4), rs4, ed4, fd4, fs4, ft4, fb4, od4, os4, ot4, ob4, rv4)
            r += 1
        if showTf5
            f_drawTech(ofmTbl, r, f_tfLabel(tf5), rs5, ed5, fd5, fs5, ft5, fb5, od5, os5, ot5, ob5, rv5)
            r += 1

// =====================================================================================================
// SECTION 8 - ALERTS
// =====================================================================================================
alertcondition(ta.crossover(overallBull, thrBull),  "OFM: Overall bulls above bull threshold", 'Order Flow Matrix | {{ticker}} | Overall bulls % crossed ABOVE the bull threshold | Overall bulls: {{plot("Overall Bull %")}}%')
alertcondition(ta.crossunder(overallBull, thrBear), "OFM: Overall bulls below bear threshold", 'Order Flow Matrix | {{ticker}} | Overall bulls % crossed BELOW the bear threshold | Overall bulls: {{plot("Overall Bull %")}}%')
alertcondition(allBull and not allBull[1],          "OFM: All visible timeframes Bull",        'Order Flow Matrix | {{ticker}} | ALL visible timeframes are Bull | Overall bulls: {{plot("Overall Bull %")}}%')
alertcondition(allBear and not allBear[1],          "OFM: All visible timeframes Bear",        'Order Flow Matrix | {{ticker}} | ALL visible timeframes are Bear | Overall bulls: {{plot("Overall Bull %")}}%')
alertcondition((bc3 == 1 and bc3[1] == -1) or (bc3 == -1 and bc3[1] == 1), "OFM: Timeframe 3 (H1) bias flip", 'Order Flow Matrix | {{ticker}} | Timeframe 3 (default H1) bias flipped Bull/Bear | Overall bulls: {{plot("Overall Bull %")}}%')
````
