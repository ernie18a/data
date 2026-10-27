# SICK MODE [erdensedat]

- url: https://www.tradingview.com/script/ydrxGg6r-SICK-MODE-erdensedat/
- type: indicator
- pine_id: PUB;5127c60efdda4c0aaab78ea5d097dedd
- version: 2.0

## Description

Welcome to SICK MODE, the most comprehensive all-in-one Smart Money Concepts (SMC) and Liquidity tracking suite designed for serious traders. This indicator eliminates chart clutter by unifying the most powerful institutional trading concepts into one highly customizable and dynamic script.

Whether you are a day trader, scalper, or swing trader, SICK MODE continuously scans the market to provide you with actionable setups, dynamic bias shifts, and high-probability points of interest (POIs).

Here is a complete breakdown of everything SICK MODE offers and how it helps you build a solid trading setup:

🔥 Core Features & Setup Generators
1. Dual-Layer Market Structure (BOS & CHoCH)

What it is: SICK MODE tracks both Internal (minor) and External (major) Market Structure simultaneously.
How it helps: It automatically labels Break of Structure (BOS) and Change of Character (CHoCH). Internal structure (dashed lines) helps you find early entries, while external structure (solid thick lines) keeps you aligned with the higher timeframe macro trend. It also identifies Strong and Weak swing highs and lows, so you know which levels are likely to hold or be swept.
2. Advanced Liquidity Engine (BSL, SSL, IDM & Turtle Soup)

What it is: Identifies Buy-Side Liquidity (BSL), Sell-Side Liquidity (SSL), and Inducement (IDM) levels.
How it helps: Instead of cluttering your chart with endless lines, it keeps only the most relevant (default 3) liquidity levels. When a level is swept and price reverses, it signals a Turtle Soup (X / TS) entry, giving you a high-probability reversal setup.
3. Next-Gen Fair Value Gap (FVG) & Raid Engine

What it is: A highly advanced FVG detection system that completely removes overlapping noise.
How it helps: It plots precise bullish and bearish imbalances, with options to show mid-lines and extend mitigated gaps. The best part? The Display Raids feature automatically detects when an FVG is pierced (raided) to trigger a quick scalp reversal, printing a precise "x" marker.
4. Institutional Order Blocks & Rejection Blocks

What it is: Detects highly specific Order Blocks (OB) and Rejection Blocks (RB/Wick Blocks).
How it helps: When price mitigates an Order Block, it automatically shifts to a Breaker Block (BB) or Mitigated Block (MB), changing color to let you know the liquidity has been transferred. It actively looks for retests, giving you sniper entry zones.
5. SMT Divergence (Smart Money Tool)

What it is: Automatically compares the current asset with a correlated ticker (e.g., comparing NQ with ES).
How it helps: If the current asset makes a Higher High but the correlated asset makes a Lower High, SICK MODE draws an SMT Divergence line. This is a massive institutional footprint indicating underlying weakness or strength before a reversal.
6. Automated Support & Resistance Engine

What it is: A dynamic S/R system that counts multiple touches on a specific price level.
How it helps: The more price touches a level, the thicker the S/R line becomes. If the level is broken with conviction, the line is removed. Perfect for spotting retail liquidity buildups.
7. Sessions, Killzones & Daily Open

What it is: Highlights Asia, London, and NY Killzones, plus the essential New York Midnight Open line.
How it helps: It tracks unbroken Session Highs and Lows for up to a user-defined amount of days. The dashboard will automatically calculate the distance and show you the "Next Session Target", acting as a magnet for your Take Profits.
8. Advanced Live Dashboard

What it is: A sleek, non-intrusive HUD panel.
How it helps: Instantly gives you the ultimate top-down view:
Current Bias & HTF Bias: (Bullish / Bearish / Neutral)
Active Session: Tells you what session you are in or waiting for.
Next Target: The closest unmitigated session high/low.
Last Action: Prints the exact last institutional event (e.g., "Bullish Sweep/TS", "Bearish FVG Created").
Setup Info: Gives you a direct instruction (e.g., "Look for lows to take LONG").
9. Comprehensive Alert System

What it is: Never miss a setup with built-in dynamic alerts.
How it helps: Set alerts for OB Creation, OB Retests, FVG Creation, FVG Raids, Rejection Blocks, and Turtle Soup (Sweep) triggers straight to your phone or PC.
💡 How to build a setup using SICK MODE?
Check the Dashboard: Ensure your Current Bias and HTF Bias align.
Wait for a Liquidity Purge: Look for a BSL/SSL Sweep or an FVG Raid signal (X).
Confirm the Shift: Wait for a minor (Internal) CHoCH to form in your intended direction.
Enter on Mitigation: Enter on the newly formed Order Block (OB), Rejection Block (RB), or FVG.
Target: Use the "Next Session Target" from the Dashboard or unmitigated liquidity lines for Take Profit.


⚠️ DISCLAIMER:
This Pine Script® indicator is provided for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Trading in the financial markets (including forex, crypto, stocks, and commodities) involves a high level of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always conduct your own research, use proper risk management, and consult with a certified financial advisor before making any real-money trading decisions. The author assumes no responsibility for any financial losses incurred while using this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
// © erdensedat
//@version=6
indicator("SICK MODE [erdensedat]", shorttitle="SICK MODE", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ==============================================================================
// 1. INPUTS
// ==============================================================================

// --- General Settings ---
string GRP_GEN    = "General Settings"
string lblSizeInp = input.string("Small", "Global Label Size", options=["Tiny", "Small", "Normal", "Large"], group=GRP_GEN)
int boxExtend     = input.int(1, "Box Extend Right (Bars)", minval=0, maxval=20, group=GRP_GEN)

f_get_lbl_size(str) =>
    str == "Tiny" ? size.tiny : str == "Small" ? size.small : str == "Normal" ? size.normal : size.large
lblSize = f_get_lbl_size(lblSizeInp)

// --- Swing Points (Foundation) ---
string GRP_SWINGS = "Foundation: Swing Points"
int pivotLength   = input.int(5, "Internal Pivot Length", tooltip="Number of bars used to confirm a swing high/low", group=GRP_SWINGS)
int extPivotLength= input.int(15, "External Pivot Length", tooltip="Number of bars for external market structure", group=GRP_SWINGS)
bool showSwings   = input.bool(true, "Show Swing Points", group=GRP_SWINGS)
color colSwingH   = input.color(color.new(#f23645, 0), "Swing High Color", group=GRP_SWINGS)
color colSwingL   = input.color(color.new(#089981, 0), "Swing Low Color", group=GRP_SWINGS)

// --- Market Structure ---
string GRP_MS     = "Market Structure: BOS & CHoCH"
bool showMS       = input.bool(true, "Show Internal BOS / CHoCH", group=GRP_MS)
bool showExtMS    = input.bool(true, "Show External BOS / CHoCH", group=GRP_MS)
bool showStrongWeak = input.bool(true, "Show Strong/Weak H/L", group=GRP_MS)
color colBullMS   = input.color(color.new(#089981, 0), "Bullish Internal MS", group=GRP_MS)
color colBearMS   = input.color(color.new(#f23645, 0), "Bearish Internal MS", group=GRP_MS)
color colBullExtMS= input.color(color.new(#089981, 0), "Bullish External MS", group=GRP_MS)
color colBearExtMS= input.color(color.new(#f23645, 0), "Bearish External MS", group=GRP_MS)

// --- Fibonacci ---
string GRP_FIB    = "Fibonacci Engine"
bool showFibInt   = input.bool(false, "Show Fast Scalp Fibonacci (Internal)", group=GRP_FIB)
bool showFibExt   = input.bool(false, "Show Intraday Fibonacci (External)", group=GRP_FIB)
string fibTrendOpt= input.string("Auto", "Fibonacci Trend Mode", options=["Auto", "Manual Bullish", "Manual Bearish"], tooltip="Auto: Above Daily Open = Bullish, Below = Bearish", group=GRP_FIB)
int fibOffset     = input.int(5, "Fibonacci Label Offset", group=GRP_FIB)
string fibLblSizeInp = input.string("Small", "Fibonacci Label Size", options=["Tiny", "Small", "Normal", "Large"], group=GRP_FIB)

bool showFib0     = input.bool(true, "Show 0 / 1 Levels", inline="f1", group=GRP_FIB)
color colFib01    = input.color(color.new(color.white, 0), "", inline="f1", group=GRP_FIB)

bool showFib618   = input.bool(true, "Show 0.618 / 0.764 Levels", inline="f2", group=GRP_FIB)
color colFibGold  = input.color(color.new(color.yellow, 0), "", inline="f2", group=GRP_FIB)

bool showFibOther = input.bool(true, "Show Other Levels (0.236, 0.382, 0.5, 1.382, 1.618)", inline="f3", group=GRP_FIB)
color colFibOther = input.color(color.new(#5272be, 0), "", inline="f3", group=GRP_FIB)

// --- Liquidity (Sweeps & IDM) ---
string GRP_LIQ    = "Liquidity: Sweeps & IDM"
bool showLiq      = input.bool(true, "Show BSL / SSL / Sweeps", group=GRP_LIQ)
int maxLiqLines   = input.int(3, "Max BSL/SSL Lines (Each)", minval=1, maxval=20, group=GRP_LIQ)
color colBSL      = input.color(color.new(#f23645, 0), "BSL Color", group=GRP_LIQ)
color colSSL      = input.color(color.new(#089981, 0), "SSL Color", group=GRP_LIQ)
bool showIDM      = input.bool(true, "Show Inducement (IDM)", group=GRP_LIQ)
color colIDM      = input.color(color.new(#5272be, 0), "IDM Color", group=GRP_LIQ)

// --- Key Levels & SR ---
string GRP_LEVELS = "Key Levels: HTF Pivots & SR"
bool showSR       = input.bool(false, "Show Support/Resistance Engine", group=GRP_LEVELS)
bool showPDH_PDL  = input.bool(true, "Show PDH / PDL", group=GRP_LEVELS)
bool showPWH_PWL  = input.bool(false, "Show PWH / PWL", group=GRP_LEVELS)
bool showDO       = input.bool(false, "Show Daily Open (D)", group=GRP_LEVELS)
bool showWO       = input.bool(false, "Show Weekly Open (W)", group=GRP_LEVELS)
bool showMO       = input.bool(false, "Show Monthly Open (M)", group=GRP_LEVELS)

color colDaily    = input.color(color.new(color.gray, 0), "Daily Color", group=GRP_LEVELS)
color colWeekly   = input.color(color.new(color.orange, 0), "Weekly Color", group=GRP_LEVELS)
color colMonthly  = input.color(color.new(color.purple, 0), "Monthly Color", group=GRP_LEVELS)

// --- Imbalance (FVG) ---
string GRP_FVG    = "Liquidity: Imbalance (FVG)"
bool fvg_enable   = input.bool(true, "Display FVG", inline="1", group=GRP_FVG, tooltip="Display fair value gap")
string what_fvg   = input.string("FVG", "", inline="1", group=GRP_FVG, options=["FVG", "Breakers"])
int fvg_num       = input.int(3, "Show Last", inline="1a", group=GRP_FVG, tooltip="Number of fvg to show", minval=0)
color fvg_upcss   = input.color(color.new(#089981, 80), "", inline="1", group=GRP_FVG)
color fvg_dncss   = input.color(color.new(#f23645, 80), "", inline="1", group=GRP_FVG)
string fvg_src    = input.string("Close", "Mitigation", inline="3", group=GRP_FVG, tooltip="[Close] Use the close of the body as trigger\n[Wick] Use the extreme point of the body as trigger", options=["Close", "Wick", "Avg"])
float fvgthresh   = input.float(0, "Threshold", tooltip="Filter out non significative FVG", group=GRP_FVG, inline="asd", minval=0, maxval=2, step=0.1)
bool fvgoverlap   = input.bool(true, "Hide Overlap", tooltip="Hide overlapping FVG", group=GRP_FVG)
bool fvgline      = input.bool(true, "Show Mid-Line", group=GRP_FVG)
bool fvgextend    = input.bool(false, "Extend FVG", group=GRP_FVG)
bool dispraid     = input.bool(true, "Display Raids", inline="raid", group=GRP_FVG)

// --- Institutional Blocks ---
string GRP_OB     = "Institutional: Blocks (OB/MB/RB)"
bool showOB       = input.bool(true, "Show Order Blocks (OB -> BB)", group=GRP_OB)
color colBullOB   = input.color(color.new(#2962FF, 80), "Bullish OB", group=GRP_OB)
color colBearOB   = input.color(color.new(#E91E63, 80), "Bearish OB", group=GRP_OB)
color colBrokenBB = input.color(color.new(color.gray, 80), "Broken BB Color", group=GRP_OB)
bool showRB       = input.bool(true, "Show Rejection Blocks (RB)", group=GRP_OB)
color colBullRB   = input.color(color.new(#00BCD4, 80), "Bullish RB", group=GRP_OB)
color colBearRB   = input.color(color.new(#FF9800, 80), "Bearish RB", group=GRP_OB)
int maxBoxesBlock = input.int(3, "Max Boxes", minval=1, maxval=50, group=GRP_OB)

// --- Indicators (MAs & VWAP) ---
string GRP_INDS   = "Indicators: VWAP & Moving Averages"
bool showVWAP     = input.bool(false, "Show Daily VWAP", group=GRP_INDS)
color colVWAP     = input.color(color.new(#E91E63, 0), "VWAP Color", group=GRP_INDS)

bool showMA1      = input.bool(false, "Show MA 1", group=GRP_INDS)
string typeMA1    = input.string("SMA", "MA 1 Type", options=["SMA", "EMA"], group=GRP_INDS)
int lenMA1        = input.int(50, "MA 1 Length", group=GRP_INDS)
color colMA1      = input.color(color.new(#2962FF, 0), "MA 1 Color", group=GRP_INDS)

bool showMA2      = input.bool(false, "Show MA 2", group=GRP_INDS)
string typeMA2    = input.string("EMA", "MA 2 Type", options=["SMA", "EMA"], group=GRP_INDS)
int lenMA2        = input.int(200, "MA 2 Length", group=GRP_INDS)
color colMA2      = input.color(color.new(#FF9800, 0), "MA 2 Color", group=GRP_INDS)

// --- Time & Sessions ---
string GRP_SESS   = "Time: Sessions & Killzones"
bool showSess     = input.bool(false, "Show Sessions Background", group=GRP_SESS)
bool showSessHL   = input.bool(false, "Show Session Highs/Lows", group=GRP_SESS)
int maxSessDays   = input.int(2, "Max Days for Unbroken Session H/L", minval=1, maxval=5, group=GRP_SESS)

string sessAsia   = input.session("2000-0100", "Asia Session (NY Time)", group=GRP_SESS)
string sessLondon = input.session("0400-0800", "London Killzone (NY Time)", group=GRP_SESS)
string sessNY     = input.session("0900-1600", "NY Killzone (NY Time)", group=GRP_SESS)
color colAsia     = input.color(color.new(#FF9800, 95), "Asia Color", group=GRP_SESS)
color colLondon   = input.color(color.new(#00BCD4, 95), "London Color", group=GRP_SESS)
color colNY       = input.color(color.new(#E91E63, 95), "NY Color", group=GRP_SESS)

bool showNYOpen   = input.bool(true, "Show NY Midnight Open Line", group=GRP_SESS)
color colNYOpen   = input.color(color.new(#b8b8b8, 0), "NY Midnight Color", group=GRP_SESS)

// --- POI & Execution ---
string GRP_POI    = "Execution: POI, Bias & Entry"
bool showBias     = input.bool(true, "Show Advanced Dashboard", group=GRP_POI)
string htfBiasRes = input.timeframe("D", "HTF Bias Timeframe", group=GRP_POI)
string panelPos   = input.string("Top Right", "Panel Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=GRP_POI)
string panelSizeInp = input.string("Normal", "Panel Size", options=["Tiny", "Small", "Normal", "Large"], group=GRP_POI)
color colBiasBull = input.color(color.new(#089981, 0), "Bull Bias Color", group=GRP_POI)
color colBiasBear = input.color(color.new(#f23645, 0), "Bear Bias Color", group=GRP_POI)
bool showTurtle   = input.bool(false, "Show Turtle Soup Entries (Sweep Signals)", group=GRP_POI)

string GRP_SMT    = "Execution: SMT Divergence"
bool showSMT      = input.bool(true, "Show SMT Divergence", group=GRP_SMT)
string smtTicker  = input.symbol("NASDAQ:NDX", "Correlated Ticker (for SMT)", group=GRP_SMT)
color colSMT      = input.color(color.new(#9C27B0, 0), "SMT Label Color", group=GRP_SMT)

// --- Watermark ---
string GRP_WM     = "Watermark"
bool showWM       = input.bool(true, "Show Watermark", group=GRP_WM)
color colWM       = input.color(color.new(color.gray, 80), "Watermark Color", group=GRP_WM)

// --- Alerts ---
string GRP_ALERTS = "Alerts"
bool altOBCreate  = input.bool(true, "Alert: Order Block Created", group=GRP_ALERTS)
bool altRB        = input.bool(true, "Alert: Rejection Block Created", group=GRP_ALERTS)
bool altTS        = input.bool(true, "Alert: Turtle Soup (TS) Triggered", group=GRP_ALERTS)
bool altOBRetest  = input.bool(true, "Alert: Order Block Retest", group=GRP_ALERTS)
bool altFVG       = input.bool(true, "Alert: FVG Created", group=GRP_ALERTS)
bool altFVGRaid   = input.bool(true, "Alert: FVG Raid", group=GRP_ALERTS)

// ==============================================================================
// Helper functions for full opacity colors & table sizes
// ==============================================================================
f_opaque(color c) => color.new(c, 0)
f_get_tbl_size(str) =>
    str == "Tiny" ? size.tiny : str == "Small" ? size.small : str == "Normal" ? size.normal : size.large
tblSize = f_get_tbl_size(panelSizeInp)

string tblPos = panelPos == "Top Right" ? position.top_right : panelPos == "Bottom Right" ? position.bottom_right : panelPos == "Top Left" ? position.top_left : position.bottom_left

// Global Last Action Variable
var string lastAction = "None"
var color lastActionCol = color.gray

// ==============================================================================
// INDICATORS (VWAP & MAs)
// ==============================================================================

// Custom Session VWAP to ensure perfect calculation without anchor variables issue
var float sumSrcVol = 0.0
var float sumVol = 0.0
if ta.change(time("D")) != 0
    sumSrcVol := 0.0
    sumVol := 0.0
sumSrcVol += hlc3 * volume
sumVol += volume
float sessionVWAP = sumSrcVol / sumVol

float ma1 = typeMA1 == "SMA" ? ta.sma(close, lenMA1) : ta.ema(close, lenMA1)
float ma2 = typeMA2 == "SMA" ? ta.sma(close, lenMA2) : ta.ema(close, lenMA2)

plot(showVWAP ? sessionVWAP : na, "Session VWAP", color=colVWAP, linewidth=2)
plot(showMA1 ? ma1 : na, "MA 1", color=colMA1, linewidth=2)
plot(showMA2 ? ma2 : na, "MA 2", color=colMA2, linewidth=2)

// ==============================================================================
// HTF BIAS LOGIC (Simple EMA Cross for HTF Bias context)
// ==============================================================================
f_htf_bias() =>
    ta.ema(close, 9) > ta.ema(close, 21) ? 1 : -1
htfTrend = request.security(syminfo.tickerid, htfBiasRes, f_htf_bias())

// ==============================================================================
// 2. TIME & SESSIONS (Unbroken HL & NY Open)
// ==============================================================================

bool inAsia = not na(time(timeframe.period, sessAsia, "America/New_York"))
bool inLondon = not na(time(timeframe.period, sessLondon, "America/New_York"))
bool inNY = not na(time(timeframe.period, sessNY, "America/New_York"))

float timeVal = hour(time, "America/New_York") + minute(time, "America/New_York") / 60.0

string currentActiveSession = inAsia ? "Asia" : inLondon ? "London" : inNY ? "NY" : na
if na(currentActiveSession)
    if timeVal >= 1.0 and timeVal < 4.0
        currentActiveSession := "Waiting for London Opening"
    else if timeVal >= 8.0 and timeVal < 9.0
        currentActiveSession := "Waiting for NY Opening"
    else
        currentActiveSession := "Waiting for Asia Opening"

bgcolor(showSess and inAsia ? colAsia : na, title="Asia Session")
bgcolor(showSess and inLondon ? colLondon : na, title="London Killzone")
bgcolor(showSess and inNY ? colNY : na, title="NY Killzone")

type SessHL
    float price
    line ln
    label lbl
    bool isHigh
    int dayTime
    color col
    string name

var SessHL[] sessHLArray = array.new<SessHL>()
int currentDayTime = time("D", "0000-0000:1234567", "America/New_York")

f_track_sess(bool inSess, string name, color col) =>
    var float h = na
    var float l = na
    bool justStarted = inSess and not inSess[1]
    bool justEnded = not inSess and inSess[1]
    
    if justStarted
        h := high
        l := low
    if inSess
        h := math.max(h, high)
        l := math.min(l, low)
    if justEnded
        if showSessHL
            lnh = line.new(bar_index, h, bar_index, h, color=col, style=line.style_dashed)
            lblh = label.new(bar_index, h, name + " H", color=color.new(color.white, 100), textcolor=f_opaque(col), style=label.style_label_left, size=lblSize)
            array.push(sessHLArray, SessHL.new(h, lnh, lblh, true, currentDayTime, col, name))
            
            lnl = line.new(bar_index, l, bar_index, l, color=col, style=line.style_dashed)
            lbll = label.new(bar_index, l, name + " L", color=color.new(color.white, 100), textcolor=f_opaque(col), style=label.style_label_left, size=lblSize)
            array.push(sessHLArray, SessHL.new(l, lnl, lbll, false, currentDayTime, col, name))
        else
            // Track internally for target logic even if hidden
            array.push(sessHLArray, SessHL.new(h, line(na), label(na), true, currentDayTime, col, name))
            array.push(sessHLArray, SessHL.new(l, line(na), label(na), false, currentDayTime, col, name))

f_track_sess(inAsia, "Asia", color.new(#FF9800, 0))
f_track_sess(inLondon, "London", color.new(#00BCD4, 0))
f_track_sess(inNY, "NY", color.new(#E91E63, 0))

string targetText = "None"

// Manage Session H/L Array
for i = array.size(sessHLArray) - 1 to 0
    if array.size(sessHLArray) > 0
        s = array.get(sessHLArray, i)
        daysOld = (currentDayTime - s.dayTime) / 86400000
        
        isBroken = false
        if s.isHigh and high > s.price
            isBroken := true
        if not s.isHigh and low < s.price
            isBroken := true
            
        if isBroken or daysOld >= maxSessDays
            if not na(s.ln)
                line.delete(s.ln)
                label.delete(s.lbl)
            array.remove(sessHLArray, i)
        else
            if not na(s.ln)
                line.set_x2(s.ln, bar_index + 1)
                label.set_x(s.lbl, bar_index + 2)

// Find closest unbroken session pivot
float minDistance = 99999999.9
for i = 0 to (array.size(sessHLArray) == 0 ? na : array.size(sessHLArray) - 1)
    if array.size(sessHLArray) > 0
        s = array.get(sessHLArray, i)
        dist = math.abs(close - s.price)
        if dist < minDistance
            minDistance := dist
            targetText := s.name + (s.isHigh ? " High (" : " Low (") + str.tostring(s.price, format.mintick) + ")"

var float nyOpenPrice = na
var line nyOpenLine = na
var label nyOpenLabel = na

bool isNewDayNY = ta.change(currentDayTime) != 0

if isNewDayNY
    nyOpenPrice := open
    if na(nyOpenLine)
        nyOpenLine := line.new(bar_index, nyOpenPrice, bar_index, nyOpenPrice, color=colNYOpen, style=line.style_dotted)
        nyOpenLabel := label.new(bar_index, nyOpenPrice, "NY M", color=color.new(color.white, 100), textcolor=f_opaque(colNYOpen), style=label.style_label_left, size=lblSize)
    else
        line.set_xy1(nyOpenLine, bar_index, nyOpenPrice)

if showNYOpen and not na(nyOpenPrice) and not na(nyOpenLine)
    line.set_xy2(nyOpenLine, bar_index + 1, nyOpenPrice)
    label.set_xy(nyOpenLabel, bar_index + 2, nyOpenPrice)
else if not na(nyOpenLine)
    line.set_x1(nyOpenLine, na)
    label.set_x(nyOpenLabel, na)

// ==============================================================================
// 3. FOUNDATION: SWING HIGH / SWING LOW, MS & SMT
// ==============================================================================

float ph = ta.pivothigh(high, pivotLength, pivotLength)
float pl = ta.pivotlow(low, pivotLength, pivotLength)

float extPH = ta.pivothigh(high, extPivotLength, extPivotLength)
float extPL = ta.pivotlow(low, extPivotLength, extPivotLength)

int minorPivotLen = math.max(1, int(pivotLength / 2))
float minorPH = ta.pivothigh(high, minorPivotLen, minorPivotLen)
float minorPL = ta.pivotlow(low, minorPivotLen, minorPivotLen)

float smtHigh = request.security(smtTicker, timeframe.period, high)
float smtLow  = request.security(smtTicker, timeframe.period, low)

var float lastPH = na, var int lastPHBar = na, var float lastPH_SMT = na
var float lastPL = na, var int lastPLBar = na, var float lastPL_SMT = na
var int trend = 0 // Bias

var float lastExtPH = na, var int lastExtPHBar = na
var float lastExtPL = na, var int lastExtPLBar = na
var int extTrend = 0 // External Bias

// Arrays to store strong/weak labels for historical reference
var label[] phLabelArray = array.new_label()
var label[] plLabelArray = array.new_label()
var float[] phPriceArray = array.new_float()
var float[] plPriceArray = array.new_float()

// Stack labels by using string concatenation instead of moving Y axis
var string[] pivotLabels = array.new_string()

if not na(ph)
    array.clear(pivotLabels)
    if showSwings
        array.push(pivotLabels, "SH")
    
    float currentPH_SMT = smtHigh[pivotLength]
    if showSMT and not na(lastPH)
        bool hh = ph > lastPH
        bool lh = ph < lastPH
        bool smt_hh = currentPH_SMT > lastPH_SMT
        bool smt_lh = currentPH_SMT < lastPH_SMT
        
        if (hh and smt_lh) or (lh and smt_hh)
            line.new(lastPHBar, lastPH, bar_index[pivotLength], ph, color=colSMT, style=line.style_dashed)
            array.push(pivotLabels, "SMT")

    lastPH := ph, lastPHBar := bar_index[pivotLength], lastPH_SMT := currentPH_SMT
    
    if array.size(pivotLabels) > 0
        lbl = label.new(bar_index[pivotLength], ph, array.join(pivotLabels, "\n"), color=color.new(color.black, 100), textcolor=f_opaque(colSwingH), style=label.style_label_down, size=lblSize)
        array.push(phLabelArray, lbl)
        array.push(phPriceArray, ph)
        
        // Keep array size manageable
        if array.size(phLabelArray) > 5
            array.shift(phLabelArray)
            array.shift(phPriceArray)

if not na(pl)
    array.clear(pivotLabels)
    if showSwings
        array.push(pivotLabels, "SL")
        
    float currentPL_SMT = smtLow[pivotLength]
    if showSMT and not na(lastPL)
        bool ll = pl < lastPL
        bool hl = pl > lastPL
        bool smt_ll = currentPL_SMT < lastPL_SMT
        bool smt_hl = currentPL_SMT > lastPL_SMT
        
        if (ll and smt_hl) or (hl and smt_ll)
            line.new(lastPLBar, lastPL, bar_index[pivotLength], pl, color=colSMT, style=line.style_dashed)
            array.push(pivotLabels, "SMT")

    lastPL := pl, lastPLBar := bar_index[pivotLength], lastPL_SMT := currentPL_SMT
    
    if array.size(pivotLabels) > 0
        lbl = label.new(bar_index[pivotLength], pl, array.join(pivotLabels, "\n"), color=color.new(color.black, 100), textcolor=f_opaque(colSwingL), style=label.style_label_up, size=lblSize)
        array.push(plLabelArray, lbl)
        array.push(plPriceArray, pl)
        
        if array.size(plLabelArray) > 5
            array.shift(plLabelArray)
            array.shift(plPriceArray)

// External Structure Updates
if not na(extPH)
    lastExtPH := extPH, lastExtPHBar := bar_index[extPivotLength]
if not na(extPL)
    lastExtPL := extPL, lastExtPLBar := bar_index[extPivotLength]

bool crossUp = ta.crossover(close, lastPH)
bool crossDn = ta.crossunder(close, lastPL)

bool crossExtUp = ta.crossover(close, lastExtPH)
bool crossExtDn = ta.crossunder(close, lastExtPL)

// Internal MS
if showMS
    if crossUp
        isBOS = trend == 1
        trend := 1
        line.new(lastPHBar, lastPH, bar_index, lastPH, color=colBullMS, style=line.style_dashed)
        label.new(int(math.avg(lastPHBar, bar_index)), lastPH, isBOS ? "BOS" : "CHoCH", color=color.new(color.black, 100), textcolor=f_opaque(colBullMS), style=label.style_label_down, size=lblSize)
        
        if showStrongWeak and array.size(plLabelArray) > 0
            label targetLbl = array.get(plLabelArray, array.size(plLabelArray) - 1)
            string curTxt = label.get_text(targetLbl)
            if not str.contains(curTxt, "Strong")
                label.set_text(targetLbl, "Strong L\n" + curTxt)
                
        lastPH := na
        lastAction := isBOS ? "Bullish BOS" : "Bullish CHoCH"
        lastActionCol := colBullMS
        
    if crossDn
        isBOS = trend == -1
        trend := -1
        line.new(lastPLBar, lastPL, bar_index, lastPL, color=colBearMS, style=line.style_dashed)
        label.new(int(math.avg(lastPLBar, bar_index)), lastPL, isBOS ? "BOS" : "CHoCH", color=color.new(color.black, 100), textcolor=f_opaque(colBearMS), style=label.style_label_up, size=lblSize)
        
        if showStrongWeak and array.size(phLabelArray) > 0
            label targetLbl = array.get(phLabelArray, array.size(phLabelArray) - 1)
            string curTxt = label.get_text(targetLbl)
            if not str.contains(curTxt, "Strong")
                label.set_text(targetLbl, "Strong H\n" + curTxt)
                
        lastPL := na
        lastAction := isBOS ? "Bearish BOS" : "Bearish CHoCH"
        lastActionCol := colBearMS

// External MS
if showExtMS
    if crossExtUp
        isBOS = extTrend == 1
        extTrend := 1
        line.new(lastExtPHBar, lastExtPH, bar_index, lastExtPH, color=colBullExtMS, style=line.style_solid, width=2)
        label.new(int(math.avg(lastExtPHBar, bar_index)), lastExtPH, isBOS ? "Ext BOS" : "Ext CHoCH", color=color.new(color.black, 100), textcolor=f_opaque(colBullExtMS), style=label.style_label_down, size=lblSize)
        lastExtPH := na
        
    if crossExtDn
        isBOS = extTrend == -1
        extTrend := -1
        line.new(lastExtPLBar, lastExtPL, bar_index, lastExtPL, color=colBearExtMS, style=line.style_solid, width=2)
        label.new(int(math.avg(lastExtPLBar, bar_index)), lastExtPL, isBOS ? "Ext BOS" : "Ext CHoCH", color=color.new(color.black, 100), textcolor=f_opaque(colBearExtMS), style=label.style_label_up, size=lblSize)
        lastExtPL := na

// Weak Highs / Lows (If a high failed to break low, and was broken)
if showStrongWeak
    for i = 0 to (array.size(phLabelArray) == 0 ? na : array.size(phLabelArray) - 1)
        if array.size(phLabelArray) > 0
            lbl = array.get(phLabelArray, i)
            prc = array.get(phPriceArray, i)
            if high > prc and not na(lbl)
                string curTxt = label.get_text(lbl)
                if not str.contains(curTxt, "Weak") and not str.contains(curTxt, "Strong")
                    label.set_text(lbl, "Weak H\n" + curTxt)
                    
    for i = 0 to (array.size(plLabelArray) == 0 ? na : array.size(plLabelArray) - 1)
        if array.size(plLabelArray) > 0
            lbl = array.get(plLabelArray, i)
            prc = array.get(plPriceArray, i)
            if low < prc and not na(lbl)
                string curTxt = label.get_text(lbl)
                if not str.contains(curTxt, "Weak") and not str.contains(curTxt, "Strong")
                    label.set_text(lbl, "Weak L\n" + curTxt)


// ==============================================================================
// 3A. FIBONACCI ENGINE
// ==============================================================================
var float fibIntPH = na
var int fibIntPHBar = na
var float fibIntPL = na
var int fibIntPLBar = na
var float fibExtPH = na
var int fibExtPHBar = na
var float fibExtPL = na
var int fibExtPLBar = na

if not na(ph)
    fibIntPH := ph
    fibIntPHBar := bar_index[pivotLength]
if not na(pl)
    fibIntPL := pl
    fibIntPLBar := bar_index[pivotLength]
if not na(extPH)
    fibExtPH := extPH
    fibExtPHBar := bar_index[extPivotLength]
if not na(extPL)
    fibExtPL := extPL
    fibExtPLBar := bar_index[extPivotLength]

var line[] fibLinesInt = array.new_line()
var label[] fibLabelsInt = array.new_label()
var line[] fibLinesExt = array.new_line()
var label[] fibLabelsExt = array.new_label()

f_draw_fibo(float p1, float p2, int b1, int b2, bool isBull, line[] lns, label[] lbls) =>
    for ln in lns
        line.delete(ln)
    for lb in lbls
        label.delete(lb)
    array.clear(lns)
    array.clear(lbls)
    
    if not na(p1) and not na(p2) and b1 != b2
        float startP = isBull ? p2 : p1
        float endP = isBull ? p1 : p2
        
        float diff = startP - endP
        float minVal = math.min(startP, endP)
        
        float[] levels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.764, 1.0, 1.382, 1.618)
        
        int startBar = math.min(b1, b2)
        
        for lvl in levels
            color col = color.gray
            bool shouldDraw = false
            if (lvl == 0.0 or lvl == 1.0) and showFib0
                col := colFib01
                shouldDraw := true
            else if (lvl == 0.618 or lvl == 0.764) and showFib618
                col := colFibGold
                shouldDraw := true
            else if (lvl != 0.0 and lvl != 1.0 and lvl != 0.618 and lvl != 0.764) and showFibOther
                col := colFibOther
                shouldDraw := true
                
            if shouldDraw
                float val = isBull ? startP - (startP - endP) * lvl : endP + (startP - endP) * lvl
                ln = line.new(startBar, val, bar_index + fibOffset, val, color=col, style=line.style_dotted)
                lb = label.new(bar_index + fibOffset, val, str.tostring(lvl) + " (" + str.tostring(val, format.mintick) + ")", color=color.new(color.white, 100), textcolor=f_opaque(col), style=label.style_label_left, size=f_get_lbl_size(fibLblSizeInp))
                array.push(lns, ln)
                array.push(lbls, lb)

// Track daily open for Auto mode
var float dailyOpenForFib = na
if ta.change(time("D")) != 0
    dailyOpenForFib := open

bool isFibBullish = true
if fibTrendOpt == "Auto"
    if close >= dailyOpenForFib
        isFibBullish := true
    else
        isFibBullish := false
else if fibTrendOpt == "Manual Bullish"
    isFibBullish := true
else
    isFibBullish := false

// Draw Fibs on update
if showFibInt and not na(fibIntPH) and not na(fibIntPL)
    f_draw_fibo(fibIntPH, fibIntPL, fibIntPHBar, fibIntPLBar, isFibBullish, fibLinesInt, fibLabelsInt)
else if not showFibInt
    for ln in fibLinesInt
        line.delete(ln)
    for lb in fibLabelsInt
        label.delete(lb)
    array.clear(fibLinesInt)
    array.clear(fibLabelsInt)

if showFibExt and not na(fibExtPH) and not na(fibExtPL)
    f_draw_fibo(fibExtPH, fibExtPL, fibExtPHBar, fibExtPLBar, isFibBullish, fibLinesExt, fibLabelsExt)
else if not showFibExt
    for ln in fibLinesExt
        line.delete(ln)
    for lb in fibLabelsExt
        label.delete(lb)
    array.clear(fibLinesExt)
    array.clear(fibLabelsExt)

// ==============================================================================
// 3B. SUPPORT / RESISTANCE ENGINE
// ==============================================================================
type SRLevel
    float price
    int count
    line ln
    bool isRes
    int lastHitBar

var SRLevel[] srArray = array.new<SRLevel>()

f_update_sr(float p, bool isRes) =>
    bool found = false
    float threshold = ta.tr * 1.5
    if array.size(srArray) > 0
        for i = 0 to array.size(srArray) - 1
            sr = array.get(srArray, i)
            if math.abs(sr.price - p) <= threshold and sr.isRes == isRes
                sr.price := (sr.price * sr.count + p) / (sr.count + 1)
                sr.count += 1
                sr.lastHitBar := bar_index - pivotLength
                found := true
                
                if sr.count == 2
                    sr.ln := line.new(sr.lastHitBar, sr.price, bar_index, sr.price, color=color.new(isRes ? color.red : color.green, 30), style=line.style_solid, width=1)
                else if sr.count > 2 and not na(sr.ln)
                    line.set_y1(sr.ln, sr.price)
                    line.set_y2(sr.ln, sr.price)
                    line.set_width(sr.ln, math.min(4, sr.count - 1))
                break
    if not found
        array.push(srArray, SRLevel.new(p, 1, line(na), isRes, bar_index - pivotLength))

if showSR
    if not na(ph)
        f_update_sr(ph, true)
    if not na(pl)
        f_update_sr(pl, false)
        
    for i = array.size(srArray) - 1 to 0
        if array.size(srArray) > 0
            sr = array.get(srArray, i)
            if not na(sr.ln)
                line.set_x2(sr.ln, bar_index)
                
            // Break logic
            if (sr.isRes and close > sr.price) or (not sr.isRes and close < sr.price)
                if not na(sr.ln)
                    line.delete(sr.ln)
                array.remove(srArray, i)
            else if bar_index - sr.lastHitBar > 300
                if not na(sr.ln)
                    line.delete(sr.ln)
                array.remove(srArray, i)

// ==============================================================================
// 4. LIQUIDITY: SWEEPS, BSL/SSL & IDM
// ==============================================================================

type LiqLevel
    float price
    int barIndex
    bool isBSL
    line ln
    label lbl

var LiqLevel[] liqArray = array.new<LiqLevel>()
var float pendingIDM_High = na, var int pendingIDM_HighBar = na
var float pendingIDM_Low = na, var int pendingIDM_LowBar = na

if not na(minorPH)
    pendingIDM_High := minorPH, pendingIDM_HighBar := bar_index[minorPivotLen]
if not na(minorPL)
    pendingIDM_Low := minorPL, pendingIDM_LowBar := bar_index[minorPivotLen]

bool tsBullAlert = false
bool tsBearAlert = false

if showLiq
    if not na(ph)
        array.push(liqArray, LiqLevel.new(ph, bar_index[pivotLength], true, line.new(bar_index[pivotLength], ph, bar_index, ph, color=colBSL, style=line.style_dotted), label.new(bar_index[pivotLength], ph, "BSL", color=color.new(color.black, 100), textcolor=f_opaque(colBSL), style=label.style_label_right, size=lblSize)))
    if not na(pl)
        array.push(liqArray, LiqLevel.new(pl, bar_index[pivotLength], false, line.new(bar_index[pivotLength], pl, bar_index, pl, color=colSSL, style=line.style_dotted), label.new(bar_index[pivotLength], pl, "SSL", color=color.new(color.black, 100), textcolor=f_opaque(colSSL), style=label.style_label_right, size=lblSize)))

    for i = array.size(liqArray) - 1 to 0
        if array.size(liqArray) > 0
            lq = array.get(liqArray, i)
            line.set_x2(lq.ln, bar_index)
            
            isHit = false
            isSweep = false
            
            if lq.isBSL and high >= lq.price
                isHit := true
                if close < lq.price
                    isSweep := true
            else if not lq.isBSL and low <= lq.price
                isHit := true
                if close > lq.price
                    isSweep := true
                    
            if isHit
                if isSweep
                    // Combine X and TS in one label if both active
                    string sweepTxt = "X"
                    if showTurtle
                        sweepTxt := lq.isBSL ? "X\n▼ TS" : "X\n▲ TS"
                    
                    label.new(bar_index, lq.price, sweepTxt, color=color.new(color.black, 100), textcolor=f_opaque(lq.isBSL ? colBSL : colSSL), style=lq.isBSL ? label.style_label_down : label.style_label_up, size=lblSize)
                    
                    if lq.isBSL
                        tsBearAlert := true
                        lastAction := "Bearish Sweep/TS"
                        lastActionCol := colBiasBear
                    else
                        tsBullAlert := true
                        lastAction := "Bullish Sweep/TS"
                        lastActionCol := colBiasBull

                line.delete(lq.ln), label.delete(lq.lbl)
                array.remove(liqArray, i)

    int bslCount = 0
    int sslCount = 0
    if array.size(liqArray) > 0
        for i = array.size(liqArray) - 1 to 0
            lq = array.get(liqArray, i)
            if lq.isBSL
                bslCount += 1
                if bslCount > maxLiqLines
                    line.delete(lq.ln)
                    label.delete(lq.lbl)
                    array.remove(liqArray, i)
            else
                sslCount += 1
                if sslCount > maxLiqLines
                    line.delete(lq.ln)
                    label.delete(lq.lbl)
                    array.remove(liqArray, i)


if showIDM
    if trend == 1 and not na(pendingIDM_Low) and low <= pendingIDM_Low
        line.new(pendingIDM_LowBar, pendingIDM_Low, bar_index, pendingIDM_Low, color=colIDM, style=line.style_dashed)
        label.new(int(math.avg(pendingIDM_LowBar, bar_index)), pendingIDM_Low, "IDM", color=color.new(color.white, 100), textcolor=f_opaque(colIDM), style=label.style_label_up, size=lblSize)
        pendingIDM_Low := na
        lastAction := "IDM Swept (Bull)"
        lastActionCol := colIDM
        
    if trend == -1 and not na(pendingIDM_High) and high >= pendingIDM_High
        line.new(pendingIDM_HighBar, pendingIDM_High, bar_index, pendingIDM_High, color=colIDM, style=line.style_dashed)
        label.new(int(math.avg(pendingIDM_HighBar, bar_index)), pendingIDM_High, "IDM", color=color.new(color.white, 100), textcolor=f_opaque(colIDM), style=label.style_label_down, size=lblSize)
        pendingIDM_High := na
        lastAction := "IDM Swept (Bear)"
        lastActionCol := colIDM

// ==============================================================================
// 6. INSTITUTIONAL BLOCKS & NEW FVG ENGINE
// ==============================================================================

type FVG
    float top     = na
    float btm     = na
    int   loc     = bar_index
    bool  isbb    = false
    int   bbloc   = na
    bool  israid  = false
    float raidy   = na
    int   raidloc = na
    int   raidx2  = na
    bool  active  = false
    color raidcs  = na

type store
    line    [] ln
    label   [] lb
    box     [] bx
    linefill[] lf

var store bin = store.new(array.new<line>(), array.new<label>(), array.new<box>(), array.new<linefill>())

if barstate.islast
    for obj in bin.ln
        obj.delete()
    for obj in bin.lb
        obj.delete()
    for obj in bin.bx
        obj.delete()
    
    bin.ln.clear()
    bin.lb.clear()
    bin.bx.clear()

ghl() => [high[2], low[2], close[1], open[1], close, open, high, low, high[1], low[1], ta.atr(200)]

overlapFVG(FVG[] blFVG, FVG[] brFVG) =>
    if blFVG.size() > 1
        for i = blFVG.size() - 1 to 1
            stuff = blFVG.get(i)
            current = blFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => blFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => blFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => blFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => blFVG.remove(i)

    if brFVG.size() > 1
        for i = brFVG.size() - 1 to 1
            stuff = brFVG.get(i)
            current = brFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => brFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => brFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => brFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => brFVG.remove(i)

    if blFVG.size() > 0 and brFVG.size() > 0
        for i = blFVG.size() - 1 to 0
            stuff = blFVG.get(i)
            current = brFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => blFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => blFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => blFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => blFVG.remove(i)

    if blFVG.size() > 0 and brFVG.size() > 0
        for i = brFVG.size() - 1 to 0
            stuff = brFVG.get(i)
            current = blFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => brFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => brFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => brFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => brFVG.remove(i)

method dispFVG(FVG fvg, int i, bool bull) =>
    ext = fvgextend ? extend.right : extend.none
    if not fvg.isbb
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = time, border_color = na, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time, extend = ext))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), xloc = xloc.bar_time, color = color.new(bull ? fvg_upcss : fvg_dncss, 0), extend = ext))
        if dispraid
            bin.ln.unshift(line.new(x1 = fvg.raidloc, x2 = fvg.raidx2, y1 = fvg.raidy, y2 = fvg.raidy, xloc = xloc.bar_time, color = fvg.raidcs))
            bin.lb.unshift(label.new(x = int(math.avg(fvg.raidloc, fvg.raidx2)), y = fvg.raidy, text = "x", xloc = xloc.bar_time, textcolor = fvg.raidcs, style = bull ? label.style_label_up : label.style_label_down, size = size.small, color = #ffffff00))

    else
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = fvg.bbloc, border_color = na, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time))
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.bbloc, right = time, border_color = bull ? fvg_dncss : fvg_upcss, bgcolor = bull ? fvg_dncss : fvg_upcss, xloc = xloc.bar_time, extend = ext))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = fvg.bbloc, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_upcss : fvg_dncss, 0), xloc = xloc.bar_time))
            bin.ln.unshift(line.new(x1 = fvg.bbloc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_dncss : fvg_upcss, 0), xloc = xloc.bar_time, extend = ext, style = line.style_dashed))

dFVG() =>
    [h2, l2, c1, o1, c, o, h, l, h1, l1, fvatr] = ghl()
    var FVG[] blFVG = array.new<FVG>()
    var FVG[] brFVG = array.new<FVG>()
    bool upfvg = false
    bool dnfvg = false
    float blth = l1 + (fvatr[1] * fvgthresh)
    float brth = h1 - (fvatr[1] * fvgthresh)
    
    bool fBullCr = false
    bool fBearCr = false
    bool rBullCr = false
    bool rBearCr = false

    cc = ta.change(time) != 0

    switch
        what_fvg == "FVG" or what_fvg == "Breakers" =>
            if l > h2 and cc and c1 > blth
                upfvg := true
                
            if l2 > h and cc and c1 < brth
                dnfvg := true

    if upfvg[1]
        if blFVG.size() > 0
            fvg = blFVG.get(0)
            if fvg.israid == true and fvg.active == false
                fvg.active  := true
                fvg.raidloc := na
                fvg.raidx2  := na
                fvg.raidy   := na
                fvg.raidcs  := #ffffff00

        blFVG.unshift(FVG.new(top = l[1], btm = h2[1], loc = time[3]))
        fBullCr := true

    if dnfvg[1]
        if brFVG.size() > 0
            fvg = brFVG.get(0)
            if fvg.israid == true and fvg.active == false
                fvg.active  := true
                fvg.raidloc := na
                fvg.raidx2  := na
                fvg.raidy   := na
                fvg.raidcs  := #ffffff00

        brFVG.unshift(FVG.new(top = l2[1], btm = h[1], loc = time[3]))
        fBearCr := true

    if blFVG.size() > 0
        for [i, fvg] in blFVG
            if not fvg.isbb
                if fvg_src == "Close" ? math.min(c, o) < fvg.btm : fvg_src == "Wick" ? l < fvg.btm : fvg_src == "Avg" ? l < math.avg(fvg.top, fvg.btm) : false
                    fvg.isbb := true
                    fvg.bbloc := time
                    if what_fvg == "FVG"
                        blFVG.remove(i)
            else
                if (fvg_src == "Close" ? math.max(c, o) > fvg.top : fvg_src == "Wick" ? h > fvg.top : fvg_src == "Avg" ? h > math.avg(fvg.top, fvg.btm) : false) and what_fvg == "Breakers"
                    blFVG.remove(i)
                    
    if brFVG.size() > 0
        for [i, fvg] in brFVG
            if not fvg.isbb
                if (fvg_src == "Close" ? math.max(c, o) > fvg.top : fvg_src == "Wick" ? h > fvg.top : fvg_src == "Avg" ? h > math.avg(fvg.top, fvg.btm) : false)
                    fvg.isbb := true
                    fvg.bbloc := time
                    if what_fvg == "FVG"
                        brFVG.remove(i)
            else
                if (fvg_src == "Close" ? math.min(c, o) < fvg.btm : fvg_src == "Wick" ? l < fvg.btm : fvg_src == "Avg" ? l < math.avg(fvg.top, fvg.btm) : false) and what_fvg == "Breakers"
                    brFVG.remove(i)
                    
    if fvgoverlap
        overlapFVG(blFVG, brFVG)

    if dispraid
        for [i, fvg] in blFVG
            if not fvg.israid and not fvg.isbb
                if low < fvg.top and close > fvg.top
                    fvg.israid  := true
                    fvg.raidloc := time
                    fvg.raidx2  := time
                    fvg.raidy   := low
                    fvg.raidcs  := chart.fg_color
                    rBullCr     := true
            else
                if low <= fvg.raidy and fvg.active == false and not fvg.isbb
                    fvg.active := true
                    fvg.raidx2 := time
                else
                    if fvg.active == false and not fvg.isbb
                        fvg.raidx2 := time

        for [i, fvg] in brFVG
            if not fvg.israid and not fvg.isbb
                if high > fvg.btm and close < fvg.btm and not fvg.isbb
                    fvg.israid  := true
                    fvg.raidloc := time
                    fvg.raidy   := high
                    fvg.raidx2  := time
                    fvg.raidcs  := chart.fg_color
                    rBearCr     := true
            else
                if high >= fvg.raidy and fvg.active == false and not fvg.isbb
                    fvg.active := true
                    fvg.raidx2 := time
                else
                    if fvg.active == false and not fvg.isbb
                        fvg.raidx2 := time

    if barstate.islast
        if blFVG.size() > 0 and fvg_num > 0
            for i = 0 to math.min(fvg_num - 1, blFVG.size() - 1)
                fvg = blFVG.get(i)
                dispFVG(fvg, i, true)

        if brFVG.size() > 0 and fvg_num > 0
            for i = 0 to math.min(fvg_num - 1, brFVG.size() - 1)
                fvg = brFVG.get(i)
                dispFVG(fvg, i, false)

    [fBullCr, fBearCr, rBullCr, rBearCr]


bool fvgBullCreated = false
bool fvgBearCreated = false
bool raidBullCreated = false
bool raidBearCreated = false

if fvg_enable
    [fBull, fBear, rBull, rBear] = dFVG()
    fvgBullCreated := fBull
    fvgBearCreated := fBear
    raidBullCreated := rBull
    raidBearCreated := rBear


// Order Blocks Code follows...
type Block
    box bx
    label lbl
    bool isBull
    bool isMitigated
    string bType
    bool retested

var Block[] blockArray = array.new<Block>()

bool isBullFVG_basic = low[0] > high[2] and close[1] > high[2]
bool isBearFVG_basic = high[0] < low[2] and close[1] < low[2]

bool bullOB_Cond = isBullFVG_basic and close[2] < open[2]
bool bearOB_Cond = isBearFVG_basic and close[2] > open[2]

float bodyTop = math.max(open, close)
float bodyBot = math.min(open, close)
float upperWick = high - bodyTop
float lowerWick = bodyBot - low
float candleRange = high - low

bool isBullRB = not na(pl) and (lowerWick > candleRange * 0.5)
bool isBearRB = not na(ph) and (upperWick > candleRange * 0.5)

bool rbAlert = false
bool obBullAlert = false
bool obBearAlert = false

if showOB
    if bullOB_Cond
        array.push(blockArray, Block.new(box.new(bar_index[2], high[2], bar_index, low[2], bgcolor=colBullOB, border_color=color.new(colBullOB, 50)), label.new(bar_index, (high[2] + low[2]) / 2, "OB", color=color.new(color.white, 100), textcolor=f_opaque(colBullOB), style=label.style_label_left, size=lblSize), true, false, "OB", false))
        lastAction := "Bullish OB Created"
        lastActionCol := colBiasBull
        obBullAlert := true
    if bearOB_Cond
        array.push(blockArray, Block.new(box.new(bar_index[2], high[2], bar_index, low[2], bgcolor=colBearOB, border_color=color.new(colBearOB, 50)), label.new(bar_index, (high[2] + low[2]) / 2, "OB", color=color.new(color.white, 100), textcolor=f_opaque(colBearOB), style=label.style_label_left, size=lblSize), false, false, "OB", false))
        lastAction := "Bearish OB Created"
        lastActionCol := colBiasBear
        obBearAlert := true

if showRB
    if isBullRB
        array.push(blockArray, Block.new(box.new(bar_index[pivotLength], bodyBot[pivotLength], bar_index, low[pivotLength], bgcolor=colBullRB, border_color=color.new(colBullRB, 50)), label.new(bar_index, (bodyBot[pivotLength] + low[pivotLength]) / 2, "RB", color=color.new(color.white, 100), textcolor=f_opaque(colBullRB), style=label.style_label_left, size=lblSize), true, false, "RB", false))
        rbAlert := true
        lastAction := "Bullish RB Created"
        lastActionCol := colBiasBull
    if isBearRB
        array.push(blockArray, Block.new(box.new(bar_index[pivotLength], high[pivotLength], bar_index, bodyTop[pivotLength], bgcolor=colBearRB, border_color=color.new(colBearRB, 50)), label.new(bar_index, (high[pivotLength] + bodyTop[pivotLength]) / 2, "RB", color=color.new(color.white, 100), textcolor=f_opaque(colBearRB), style=label.style_label_left, size=lblSize), false, false, "RB", false))
        rbAlert := true
        lastAction := "Bearish RB Created"
        lastActionCol := colBiasBear

bool obRetestBull = false
bool obRetestBear = false

if showOB or showRB
    if array.size(blockArray) > maxBoxesBlock * 2
        removed = array.shift(blockArray)
        box.delete(removed.bx), label.delete(removed.lbl)
        
    for i = 0 to (array.size(blockArray) == 0 ? na : array.size(blockArray) - 1)
        if array.size(blockArray) > 0
            blk = array.get(blockArray, i)
            if not blk.isMitigated
                top = box.get_top(blk.bx)
                bot = box.get_bottom(blk.bx)
                
                if not blk.retested and bar_index > box.get_left(blk.bx)
                    if blk.isBull and low <= top and high >= bot
                        blk.retested := true
                        obRetestBull := true
                    if not blk.isBull and high >= bot and low <= top
                        blk.retested := true
                        obRetestBear := true
                
                isMitigated = (blk.isBull and close < bot) or (not blk.isBull and close > top)
                if isMitigated
                    blk.isMitigated := true
                    if blk.bType == "OB"
                        label.set_text(blk.lbl, "BB")
                    else if blk.bType == "RB"
                        label.set_text(blk.lbl, "MB")
                    box.set_bgcolor(blk.bx, colBrokenBB)
                    box.set_border_color(blk.bx, color.new(colBrokenBB, 50))
                    label.set_textcolor(blk.lbl, f_opaque(colBrokenBB))
                else
                    box.set_right(blk.bx, bar_index + boxExtend)
                    label.set_x(blk.lbl, bar_index + boxExtend + 1)

// ==============================================================================
// 7. POI & ADVANCED DASHBOARD
// ==============================================================================

if showBias
    var table biasTable = table.new(tblPos, 2, 6, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.new(color.gray, 80))
    if barstate.islast
        // Bias
        string biasText = trend == 1 ? "BULLISH" : trend == -1 ? "BEARISH" : "NEUTRAL"
        color biasCol = trend == 1 ? colBiasBull : trend == -1 ? colBiasBear : color.gray
        
        string htfText = htfTrend == 1 ? "BULLISH" : htfTrend == -1 ? "BEARISH" : "NEUTRAL"
        color htfCol = htfTrend == 1 ? colBiasBull : htfTrend == -1 ? colBiasBear : color.gray
        
        string setupText = trend == 1 ? "Look for lows to take LONG" : trend == -1 ? "Look for highs to take SHORT" : "Wait for setup"
        color setupCol = trend == 1 ? colBiasBull : trend == -1 ? colBiasBear : color.gray

        // Headers
        table.cell(biasTable, 0, 0, "Current Bias", text_color=color.gray, text_size=tblSize)
        table.cell(biasTable, 1, 0, biasText, text_color=biasCol, text_size=tblSize, text_halign=text.align_right)
        
        table.cell(biasTable, 0, 1, htfBiasRes + " HTF Bias", text_color=color.gray, text_size=tblSize)
        table.cell(biasTable, 1, 1, htfText, text_color=htfCol, text_size=tblSize, text_halign=text.align_right)
        
        table.cell(biasTable, 0, 2, "Active Session", text_color=color.gray, text_size=tblSize)
        table.cell(biasTable, 1, 2, currentActiveSession, text_color=color.white, text_size=tblSize, text_halign=text.align_right)
        
        table.cell(biasTable, 0, 3, "Next Session Target", text_color=color.gray, text_size=tblSize)
        table.cell(biasTable, 1, 3, targetText, text_color=color.orange, text_size=tblSize, text_halign=text.align_right)
        
        table.cell(biasTable, 0, 4, "Last Action", text_color=color.gray, text_size=tblSize)
        table.cell(biasTable, 1, 4, lastAction, text_color=lastActionCol, text_size=tblSize, text_halign=text.align_right)
        
        table.cell(biasTable, 0, 5, "Setup Info", text_color=color.gray, text_size=tblSize)
        table.cell(biasTable, 1, 5, setupText, text_color=setupCol, text_size=tblSize, text_halign=text.align_right)

// ==============================================================================
// 8. WATERMARK
// ==============================================================================

var table wmTable = table.new(position.bottom_center, 1, 1)
if showWM
    if barstate.islast
        table.cell(wmTable, 0, 0, "erdensedat", text_color=colWM, text_size=size.huge)

// ==============================================================================
// 9. ALERTS
// ==============================================================================

if altOBCreate and obBullAlert
    alert("Bullish Order Block Created", alert.freq_once_per_bar)
if altOBCreate and obBearAlert
    alert("Bearish Order Block Created", alert.freq_once_per_bar)

if altRB and rbAlert
    alert("Rejection Block Created", alert.freq_once_per_bar)

if altTS and tsBullAlert
    alert("Bullish Turtle Soup (TS) Triggered", alert.freq_once_per_bar)
if altTS and tsBearAlert
    alert("Bearish Turtle Soup (TS) Triggered", alert.freq_once_per_bar)

if altOBRetest and obRetestBull
    alert("Bullish Order Block Retested", alert.freq_once_per_bar)
if altOBRetest and obRetestBear
    alert("Bearish Order Block Retested", alert.freq_once_per_bar)

if altFVG and fvgBullCreated
    alert("Bullish FVG Created", alert.freq_once_per_bar)
if altFVG and fvgBearCreated
    alert("Bearish FVG Created", alert.freq_once_per_bar)
    
if altFVGRaid and raidBullCreated
    alert("Bullish FVG Raided", alert.freq_once_per_bar)
if altFVGRaid and raidBearCreated
    alert("Bearish FVG Raided", alert.freq_once_per_bar)
````
