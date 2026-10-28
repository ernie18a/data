# Scalp The React

- url: https://www.tradingview.com/script/FrTKn1z9-Scalp-The-React/
- type: indicator
- pine_id: PUB;33bc7fd846c9486d91b5fd057a8f35d4
- version: 1.0

## Description

Scalp The React (STR) is an advanced, all-in-one market structure and liquidity mapping framework. Designed for scalpers, intraday traders, and swing traders, this indicator dynamically builds actionable "Reaction Zones," Fibonacci projection targets, and liquidity sweep setups based on real-time market structure breaks and session timings.

Instead of relying on static, manual drawings, STR automatically identifies structural pivots, determines the market bias, and projects forward-looking target zones to give you a complete roadmap of where the price is likely to react.

🌟 Core Features & Modules
1. Dynamic Fibonacci Setup Modes
The heart of STR is its adaptive Fibonacci projection engine. Depending on your trading style, you can choose how the indicator anchors its High/Low legs to draw the target zones.

Scalp Mode: A step-by-step approach. It waits for the current 0 or 1 boundaries of the active setup to be completely broken before anchoring a new Fibonacci leg.
Intraday Mode: Focuses purely on trend reversals. It maps new Fibonacci projection zones only when a Change of Character (CHoCH) occurs.
HTF (Higher Timeframe) Mode: Top-down analysis made easy. It grabs the exact High and Low of the previous Higher Timeframe candle (e.g., 4H) and projects intraday zones based on that HTF range.
Session Mode: Perfect for session-to-session liquidity traders. It automatically tracks the High and Low of specific trading sessions (Asia, London, New York). The moment a session ends, it instantly projects the Fibonacci scheme based on the current market bias. (Labels explicitly tell you if a level is the "Asia High" or "London Low").
First 4H Mode: An opening range breakout approach. It maps the High and Low of the day's first 4 hours (e.g., 03:00 - 07:00) and projects the roadmap for the rest of the day.

https://www.tradingview.com/x/wI90rlEZ/

2. Target & Liquidity Zones
Whenever a new setup is confirmed, the indicator plots highly specific mathematical zones:

Magnetic Retest Level (0.5): The fair-value equilibrium of the anchor leg.
Reaction Zone (1.47 - 1.55): The primary Take Profit and reaction box.
External Reaction Zone (2.56 - 2.64): The extended macro target box.
Liquidity Sweep Box (-0.21 to -0.29): Placed exactly opposite to the breakout direction. If the price pushes into this zone and closes back inside the range, the indicator marks a precise Sweep (x) label, signaling a potential liquidity trap / reversal.
3. Market Structure Engine (BOS & CHoCH)
The script continuously scans for fractal highs and lows. It draws "Candidate" levels and waits for the price to break them (wick or body close based on your preference). Once broken, it permanently stamps the chart with BOS (Break of Structure) or CHoCH (Change of Character) labels and lines, keeping a clean historical record of the trend state.

4. Kinetic MA Trail & Bias Engine
To avoid plotting setups against the broader trend, the indicator uses a "Kinetic MA." This is a macro moving average that trails the price uniquely by filtering out noise using Supertrend and ATR logic.

When the price is above the Kinetic MA, the macro bias is Bullish.
When the price is below the Kinetic MA, the macro bias is Bearish.
Note: This internal bias is what dictates the direction of the Session and First 4H Fibonacci projections.
5. Advanced FVG / Breaker Engine
A built-in Fair Value Gap (FVG) and Breaker block extraction module.

Displays the last N unmitigated gaps.
Overlap Filter: Automatically hides overlapping FVGs to keep the chart incredibly clean.
Raid Detection: Marks an "x" inside the gap if the price aggressively wicks into it (a liquidity raid) but fails to close beyond it.
Supports mitigation filtering by Wick, Body Close, or Average line.
⚙️ How to Use It?
Select your Mode: If you trade the London/New York overlaps, set the Fib Mode to "Session". If you are a pure price-action scalper, set it to "Scalp" or "Intraday".
Follow the Liquidity: Look for setups where the price breaks structure, pulls back into the yellow Magnetic Level (0.5), or sweeps the Red Liquidity Box (-0.21 to -0.29) before targeting the Green Reaction Zones.
Align with the Kinetic MA: Use the glowing Kinetic MA band to stay on the right side of the macro trend.
⚠️ Disclaimer
For Educational Purposes Only:
The "Scalp The React" indicator and all its built-in features (including Fibonacci zones, market structure labels, moving averages, and FVG detection) are provided strictly for educational and informational purposes.

Not Financial Advice:
This script does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. Trading in financial markets (including cryptocurrencies, forex, stocks, and commodities) involves a high degree of risk and may not be suitable for all investors. You could lose some or all of your initial investment.

No Guarantee of Results:
Past performance of any trading system or methodology is not necessarily indicative of future results. The zones, labels, and signals generated by this script are based on mathematical formulas and historical price action; they do not predict the future.

User Responsibility:
By using this script, you acknowledge that you are solely responsible for your own trading decisions. Always conduct your own research (DYOR), practice strict risk management, and consult with a certified financial advisor before making any trading or investment decisions. The author of this script assumes no responsibility for any trading losses incurred.

## Source Code

````pine
//@version=6
indicator("Scalp The React", shorttitle="STR", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//==================== TYPES ====================
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

//==================== WATERMARK ====================
var table wm = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(wm, 0, 0, "Scalp The React\nby erdensedat", text_color=color.new(color.gray, 70), text_size=size.large, text_halign=text.align_right)

//==================== FIBONACCI SETTINGS ====================
grpFib = "Fibonacci / Targets"
showFib = input.bool(true, "Show Fib Zones", group=grpFib)
fibMode = input.string("Session", "Fib Setup Mode", options=["Scalp", "Intraday", "HTF", "Session", "First 4H"], tooltip="Scalp: Waits for current setup 0 or 1 levels to be broken before creating a new one.\nIntraday: Creates a setup ONLY on CHoCH (trend reversal) breaks.\nHTF: Uses the High/Low of the previous Higher Timeframe candle.\nSession: Uses the High/Low of the last completed trading session.\nFirst 4H: Uses the High/Low of the day's first 4 hours.", group=grpFib)
htfRes  = input.timeframe("240", "HTF Resolution (if HTF Mode)", group=grpFib)

fib01Col = input.color(#00bcd4, "Fib 0 & 1 Lines", group=grpFib)
fib50Col = input.color(color.yellow, "Fib Retest (0.5) Line", group=grpFib)
tp1Col   = input.color(color.new(color.green, 80), "Reaction Zone (1.47-1.55)", group=grpFib)
tp2Col   = input.color(color.new(color.green, 60), "External Reaction Zone (2.56-2.64)", group=grpFib)
negCol   = input.color(color.new(color.red, 80), "Liquidity Box (-0.21 to -0.29)", group=grpFib)

//==================== SESSION SETTINGS ====================
grpSession = "Session Settings (If Session/First 4H Mode)"
sessAsia   = input.session("0000-0700", "Asia Session", group=grpSession)
sessLondon = input.session("1100-1445", "London Session", group=grpSession)
sessNY     = input.session("1500-2200", "New York Session", group=grpSession)
sessFirst4H= input.session("0300-0700", "First 4H Session (If First 4H Mode)", group=grpSession)
sessTz     = input.string("Europe/Istanbul", "Session Timezone", group=grpSession)

//==================== FVG SETTINGS ====================
grpFVG = "FAIR VALUE GAP"
fvg_enable   = input.bool(true, "Display FVG", inline="1", group=grpFVG, tooltip="Display fair value gap")
what_fvg     = input.string("FVG", "", inline="1", group=grpFVG, tooltip="Display fair value gap", options=["FVG", "Breakers"])
fvg_num      = input.int(2, "Show Last", inline="1a", group=grpFVG, tooltip="Number of fvg to show", minval=0)
fvg_upcss    = input.color(color.new(#089981, 80), "", inline="1", group=grpFVG)
fvg_dncss    = input.color(color.new(#f23645, 80), "", inline="1", group=grpFVG)
fvg_src      = input.string("Close", "Mitigation", inline="3", group=grpFVG, tooltip="[Close] Use the close of the body as trigger\n\n[Wick] Use the extreme point of the body as trigger", options=["Close", "Wick", "Avg"])
fvgthresh    = input.float(0, "Threshold", tooltip="Filter out non significative FVG", group=grpFVG, inline="asd", minval=0, maxval=2, step=0.1)
fvgoverlap   = input.bool(true, "Hide Overlap", tooltip="Hide overlapping FVG", group=grpFVG)
fvgline      = input.bool(true, "Show Mid-Line", group=grpFVG)
fvgextend    = input.bool(false, "Extend FVG", group=grpFVG)
dispraid     = input.bool(false, "Display Raids", inline="raid", group=grpFVG)

//==================== CORE ====================
grpCore = "Core (BLVL)"
len         = input.int(10, "Fractal Length", minval=3, maxval=51, group=grpCore)
barsToRight = input.int(10, "Bars to Right", minval=1, maxval=300, group=grpCore)
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpCore)

//==================== PERFORMANCE ====================
grpPerf = "Performance"
calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpPerf)
maxKeep      = input.int(2500, "Max Stored Broken (hard cap)", minval=100, maxval=20000, group=grpPerf)
showLastN    = input.int(5, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=grpPerf)

//==================== KINETIC MA TRAIL (MACRO) ====================
grpMA = "Moving Average"
show_ma = input.bool(false, "Show Moving Average?", group=grpMA)
ma_type = input.string("WMA", "MA Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"], group=grpMA)
ma_len  = input.int(20, "MA Length", group=grpMA)
bull_c = input.color(#089981, "MA Up Glow", group=grpMA)
bear_c = input.color(#f23645, "MA Down Glow", group=grpMA)

grpVWAP = "VWAP"
showVwap = input.bool(false, "Show VWAP?", group=grpVWAP)
vwapCol  = input.color(color.blue, "VWAP Color", group=grpVWAP)

// VWAP Calculation
var float vwapValue = na
if showVwap
    vwapValue := ta.vwap(close)
plot(showVwap ? vwapValue : na, "VWAP", color=vwapCol, linewidth=2)

//==================== CANDIDATE STYLE ====================
grpCand = "Candidate (Pre-break)"
candCol     = input.color(color.new(color.black, 60), "Candidate Color", group=grpCand)
candW       = input.int(1, "Candidate Width", minval=1, maxval=5, group=grpCand)
candStyleS  = input.string("Dotted", "Candidate Style", options=["Solid","Dashed","Dotted"], group=grpCand)

showCandText = input.bool(false, "Show Candidate Text", group=grpCand)
candTxtUp    = input.string("BOS ↑", "Candidate UP Text", group=grpCand)
candTxtDn    = input.string("BOS ↓", "Candidate DN Text", group=grpCand)
candTxtColUp = input.color(color.rgb(8,153,129), "Candidate UP Text Color", group=grpCand)
candTxtColDn = input.color(color.new(color.red, 0), "Candidate DN Text Color", group=grpCand)

//==================== BROKEN STYLE ====================
grpBrk = "Broken (Post-break)"
brkUpCol   = input.color(color.rgb(8,153,129), "Broken UP Color (#089981)", group=grpBrk)
brkDnCol   = input.color(color.new(color.red, 0), "Broken DN Color", group=grpBrk)
brkW       = input.int(1, "Broken Width", minval=1, maxval=5, group=grpBrk)
brkStyleS  = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBrk)

//==================== LABELS ====================
grpLbl = "BOS/CHoCH Labels"
lbOn     = input.bool(true, "Show BOS/CHoCH Labels", group=grpLbl)
lbSzS    = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=grpLbl)
lbBg     = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpLbl)
lbTxtUp  = input.color(color.rgb(8,153,129), "UP Label Text Color", group=grpLbl)
lbTxtDn  = input.color(color.new(color.red, 0), "DN Label Text Color", group=grpLbl)

//==================== HELPERS ====================
f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

f_ma(string type, series float src, int length) =>
    switch type
        "SMA"  => ta.sma(src, length)
        "EMA"  => ta.ema(src, length)
        "WMA"  => ta.wma(src, length)
        "HMA"  => ta.hma(src, length)
        "VWMA" => ta.vwma(src, length)
        "RMA"  => ta.rma(src, length)
        => ta.ema(src, length)

//==================== KINETIC MA TRAIL ENGINE ====================
[st_at, d_at] = ta.supertrend(2.0, 10)
is_up = d_at < 0
atr_v = ta.atr(14)

macro_ma_base = f_ma(ma_type, close, ma_len)
var float ma_trail = na
if is_up
    ma_trail := na(ma_trail[1]) ? macro_ma_base : math.max(macro_ma_base, nz(ma_trail[1]))
else
    ma_trail := na(ma_trail[1]) ? macro_ma_base : math.min(macro_ma_base, nz(ma_trail[1]))
ma_is_bull = close > ma_trail

p_ma  = plot(show_ma ? ma_trail : na, "Kinetic MA", color=ma_is_bull ? color.new(bull_c, 30) : color.new(bear_c, 30), linewidth=1)
p_mao = plot(show_ma ? ma_trail + (ma_is_bull ? -atr_v*0.5 : atr_v*0.5) : na, "MA Offset", display=display.none)
fill(p_ma, p_mao, ma_is_bull ? color.new(bull_c, 90) : color.new(bear_c, 90))

//==================== PERF GATE ====================
inCalc = true
if calcLastBars == 0
    inCalc := true
else
    inCalc := bar_index >= last_bar_index - calcLastBars

//==================== ODD LEN + P ====================
L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)

//==================== TIME EXTEND ====================
tfSec = timeframe.in_seconds(timeframe.period)
extMs = tfSec * 1000 * barsToRight

candStyle = f_ls(candStyleS)
brkStyle  = f_ls(brkStyleS)
lbSize    = f_sz(lbSzS)

//==================== PIVOTS (CONFIRMED) ====================
phVal = ta.pivothigh(high, p, p)
plVal = ta.pivotlow(low,  p, p)
phHit = not na(phVal)
plHit = not na(plVal)

//==================== CANDIDATE STATE ====================
var float upLvl = na
var int   upT   = na
var bool  upBroken = false
var line  upLine = na
var label upCandLb = na

var float dnLvl = na
var int   dnT   = na
var bool  dnBroken = false
var line  dnLine = na
var label dnCandLb = na

var int os = 0  

var line[]  brkLines = array.new_line()
var label[] brkLabs  = array.new_label()

f_trimBroken() =>
    if showLastN > 0
        while array.size(brkLines) > showLastN
            line oldLn = array.shift(brkLines)
            label oldLb = array.shift(brkLabs)
            if not na(oldLn)
                line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)
    while array.size(brkLines) > maxKeep
        line oldLn = array.shift(brkLines)
        label oldLb = array.shift(brkLabs)
        if not na(oldLn)
            line.delete(oldLn)
        if not na(oldLb)
            label.delete(oldLb)

f_pushBroken(line ln, label lb) =>
    array.push(brkLines, ln)
    array.push(brkLabs,  lb)
    f_trimBroken()

//==================== FIBONACCI STATE ====================
var line fib0Line  = na
var line fib1Line  = na
var line fib50Line = na
var label fib50Lbl = na
var label sessHLbl = na
var label sessLLbl = na
var box  tp1Box    = na
var box  tp2Box    = na
var box  negBox    = na

var float lockedFibLow = na
var float lockedFibHigh = na
var int   lockedFibT = na
var int   fibDir = 0 // 1 for bullish setup, -1 for bearish setup

var float activeExtremeTop = na
var float activeExtremeBot = na
var float activeLiquidityTop = na
var float activeLiquidityBot = na

// Track latest pivots to construct legs upon break
var float lastPH = na
var int   lastPHT = na
var float lastPL = na
var int   lastPLT = na

// Track Session Name for Labels
var string lastSessName = ""

//==================== SESSION TRACKING ENGINE ====================
f_inSession(string sess) => not na(time(timeframe.period, sess, sessTz))

inAsia   = f_inSession(sessAsia)
inLondon = f_inSession(sessLondon)
inNY     = f_inSession(sessNY)
inFirst4H= f_inSession(sessFirst4H)

var float asiaH = na, var float asiaL = na, var int asiaT = na
var float lonH  = na, var float lonL  = na, var int lonT  = na
var float nyH   = na, var float nyL   = na, var int nyT   = na
var float f4hH  = na, var float f4hL  = na, var int f4hT  = na

// Detect session start and end explicitly
bool isAsiaStart = inAsia and not inAsia[1]
bool isAsiaEnd   = not inAsia and inAsia[1]

bool isLonStart  = inLondon and not inLondon[1]
bool isLonEnd    = not inLondon and inLondon[1]

bool isNYStart   = inNY and not inNY[1]
bool isNYEnd     = not inNY and inNY[1]

bool isF4HStart  = inFirst4H and not inFirst4H[1]
bool isF4HEnd    = not inFirst4H and inFirst4H[1]

// Update Asia High/Low
if isAsiaStart
    asiaH := high, asiaL := low, asiaT := time
else if inAsia
    asiaH := math.max(nz(asiaH, high), high)
    if low < nz(asiaL, low) or na(asiaL)
        asiaL := low
        asiaT := time

// Update London High/Low
if isLonStart
    lonH := high, lonL := low, lonT := time
else if inLondon
    lonH := math.max(nz(lonH, high), high)
    if low < nz(lonL, low) or na(lonL)
        lonL := low
        lonT := time

// Update NY High/Low
if isNYStart
    nyH := high, nyL := low, nyT := time
else if inNY
    nyH := math.max(nz(nyH, high), high)
    if low < nz(nyL, low) or na(nyL)
        nyL := low
        nyT := time

// Update First 4H High/Low
if isF4HStart
    f4hH := high, f4hL := low, f4hT := time
else if inFirst4H
    f4hH := math.max(nz(f4hH, high), high)
    if low < nz(f4hL, low) or na(f4hL)
        f4hL := low
        f4hT := time

// Current bias approximation for session engine
int currentBias = ma_is_bull ? 1 : -1


//==================== CREATE / REPLACE CANDIDATES ====================
if inCalc
    if phHit
        if not na(upLine) and not upBroken
            line.delete(upLine)
        if not na(upCandLb)
            label.delete(upCandLb)

        upLvl := phVal
        upT   := time[p]
        upBroken := false
        
        lastPH := phVal
        lastPHT := time[p]

        upLine := line.new(upT, upLvl, time + extMs, upLvl, xloc=xloc.bar_time, extend=extend.none, color=candCol, style=candStyle, width=candW)

        if showCandText
            upCandLb := label.new(upT, upLvl, candTxtUp, xloc=xloc.bar_time, style=label.style_label_down, textcolor=candTxtColUp, color=lbBg, size=lbSize)
        else
            upCandLb := na

    if plHit
        if not na(dnLine) and not dnBroken
            line.delete(dnLine)
        if not na(dnCandLb)
            label.delete(dnCandLb)

        dnLvl := plVal
        dnT   := time[p]
        dnBroken := false
        
        lastPL := plVal
        lastPLT := time[p]

        dnLine := line.new(dnT, dnLvl, time + extMs, dnLvl, xloc=xloc.bar_time, extend=extend.none, color=candCol, style=candStyle, width=candW)

        if showCandText
            dnCandLb := label.new(dnT, dnLvl, candTxtDn, xloc=xloc.bar_time, style=label.style_label_up, textcolor=candTxtColDn, color=lbBg, size=lbSize)
        else
            dnCandLb := na

//==================== EXTEND LIVE CANDIDATES & FIBS ====================
if inCalc
    if not na(upLine) and not upBroken
        line.set_x2(upLine, time + extMs)
    if not na(dnLine) and not dnBroken
        line.set_x2(dnLine, time + extMs)
        
    if showFib
        if not na(fib0Line)
            line.set_x2(fib0Line, time + extMs)
        if not na(fib1Line)
            line.set_x2(fib1Line, time + extMs)
        if not na(fib50Line)
            line.set_x2(fib50Line, time + extMs)
        if not na(fib50Lbl)
            label.set_x(fib50Lbl, time + extMs)
        if not na(sessHLbl)
            label.set_x(sessHLbl, time + extMs)
        if not na(sessLLbl)
            label.set_x(sessLLbl, time + extMs)
        if not na(tp1Box)
            box.set_right(tp1Box, time + extMs)
        if not na(tp2Box)
            box.set_right(tp2Box, time + extMs)
        if not na(negBox)
            box.set_right(negBox, time + extMs)

//==================== BREAK CONDITIONS ====================
brkUp = false
brkDn = false

if inCalc
    if not na(upLvl) and not upBroken
        if requireBody
            brkUp := close > upLvl
        else
            brkUp := high > upLvl

    if not na(dnLvl) and not dnBroken
        if requireBody
            brkDn := close < dnLvl
        else
            brkDn := low < dnLvl

//==================== HTF ENGINE ====================
bool isNewHtf = ta.change(time(htfRes)) != 0
float htfH = request.security(syminfo.tickerid, htfRes, high[1], lookahead=barmerge.lookahead_on)
float htfL = request.security(syminfo.tickerid, htfRes, low[1], lookahead=barmerge.lookahead_on)
float htfC = request.security(syminfo.tickerid, htfRes, close[1], lookahead=barmerge.lookahead_on)
float htfO = request.security(syminfo.tickerid, htfRes, open[1], lookahead=barmerge.lookahead_on)
int htfT = request.security(syminfo.tickerid, htfRes, time[1], lookahead=barmerge.lookahead_on)

//==================== APPLY BREAKS & LOCK FIBS ====================
bool createNewFib = false

if inCalc
    if brkUp
        upBroken := true

        if not na(upLine)
            line.set_color(upLine, brkUpCol)
            line.set_style(upLine, brkStyle)
            line.set_width(upLine, brkW)
            line.set_x2(upLine, time)
        if not na(upCandLb)
            label.delete(upCandLb)
            upCandLb := na

        bool isChoch = (os == -1)
        if os == 0
            isChoch := true

        label lb = na
        if lbOn
            string txt = isChoch ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=lbSize)
        f_pushBroken(upLine, lb)
        
        bool canLockNewFib = false
        if fibMode == "Scalp"
            if na(activeExtremeTop) or na(activeExtremeBot)
                canLockNewFib := true
            else if close > activeExtremeTop or close < activeExtremeBot
                canLockNewFib := true
        else if fibMode == "Intraday"
            if isChoch
                canLockNewFib := true
        
        if showFib and not na(lastPL) and canLockNewFib and fibMode != "HTF" and fibMode != "Session" and fibMode != "First 4H"
            lockedFibLow := lastPL
            lockedFibHigh := upLvl
            lockedFibT := lastPLT
            fibDir := 1
            activeExtremeTop := math.max(lastPL, upLvl)
            activeExtremeBot := math.min(lastPL, upLvl)
            lastSessName := ""
            createNewFib := true
            
        upLine := na
        os := 1

    if brkDn
        dnBroken := true

        if not na(dnLine)
            line.set_color(dnLine, brkDnCol)
            line.set_style(dnLine, brkStyle)
            line.set_width(dnLine, brkW)
            line.set_x2(dnLine, time)
        if not na(dnCandLb)
            label.delete(dnCandLb)
            dnCandLb := na
            
        bool isChoch = (os == 1)
        if os == 0
            isChoch := true 

        label lb = na
        if lbOn
            string txt = isChoch ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=lbSize)
        f_pushBroken(dnLine, lb)
        
        bool canLockNewFib = false
        if fibMode == "Scalp"
            if na(activeExtremeTop) or na(activeExtremeBot)
                canLockNewFib := true
            else if close > activeExtremeTop or close < activeExtremeBot
                canLockNewFib := true
        else if fibMode == "Intraday"
            if isChoch
                canLockNewFib := true
        
        if showFib and not na(lastPH) and canLockNewFib and fibMode != "HTF" and fibMode != "Session" and fibMode != "First 4H"
            lockedFibLow := dnLvl
            lockedFibHigh := lastPH
            lockedFibT := lastPHT
            fibDir := -1
            activeExtremeTop := math.max(lastPH, dnLvl)
            activeExtremeBot := math.min(lastPH, dnLvl)
            lastSessName := ""
            createNewFib := true

        dnLine := na
        os := -1
        
    // Trigger HTF Fib Generation on New HTF Candle
    if fibMode == "HTF" and isNewHtf and not na(htfH)
        lockedFibLow := htfL
        lockedFibHigh := htfH
        lockedFibT := htfT
        // If HTF closed higher than it opened -> Bullish Leg, else Bearish Leg
        fibDir := (htfC >= htfO) ? 1 : -1
        lastSessName := ""
        createNewFib := true

    // Trigger Session Fib Generation directly at Session Ends
    if fibMode == "Session"
        if isAsiaEnd and not na(asiaH)
            lockedFibLow := asiaL
            lockedFibHigh := asiaH
            lockedFibT := asiaT
            fibDir := currentBias
            lastSessName := "Asia"
            createNewFib := true
            
        if isLonEnd and not na(lonH)
            lockedFibLow := lonL
            lockedFibHigh := lonH
            lockedFibT := lonT
            fibDir := currentBias
            lastSessName := "London"
            createNewFib := true
            
        if isNYEnd and not na(nyH)
            lockedFibLow := nyL
            lockedFibHigh := nyH
            lockedFibT := nyT
            fibDir := currentBias
            lastSessName := "New York"
            createNewFib := true

    // Trigger First 4H Fib Generation directly at First 4H Ends
    if fibMode == "First 4H"
        if isF4HEnd and not na(f4hH)
            lockedFibLow := f4hL
            lockedFibHigh := f4hH
            lockedFibT := f4hT
            fibDir := currentBias
            lastSessName := "First 4H"
            createNewFib := true

//==================== UPDATE LOCKED FIBONACCI DRAWINGS ====================
if inCalc and showFib
    if createNewFib and fibDir != 0
        float diff = math.abs(lockedFibHigh - lockedFibLow)
        float startY = fibDir == 1 ? lockedFibLow : lockedFibHigh
        float dir = fibDir
        
        float lvl_0   = startY + dir * diff * 0
        float lvl_1   = startY + dir * diff * 1
        float lvl_05  = startY + dir * diff * 0.5
        float lvl_147 = startY + dir * diff * 1.47
        float lvl_155 = startY + dir * diff * 1.55
        float lvl_256 = startY + dir * diff * 2.56
        float lvl_264 = startY + dir * diff * 2.64
        float lvl_neg21 = startY + dir * diff * -0.21
        float lvl_neg29 = startY + dir * diff * -0.29
        
        activeLiquidityTop := math.max(lvl_neg21, lvl_neg29)
        activeLiquidityBot := math.min(lvl_neg21, lvl_neg29)
        
        int drawT = time
        
        if not na(fib0Line)
            line.delete(fib0Line)
        if not na(fib1Line)
            line.delete(fib1Line)
        if not na(fib50Line)
            line.delete(fib50Line)
        if not na(fib50Lbl)
            label.delete(fib50Lbl)
        if not na(sessHLbl)
            label.delete(sessHLbl)
        if not na(sessLLbl)
            label.delete(sessLLbl)
        if not na(tp1Box)
            box.delete(tp1Box)
        if not na(tp2Box)
            box.delete(tp2Box)
        if not na(negBox)
            box.delete(negBox)
            
        fib0Line  := line.new(drawT, lvl_0, time + extMs, lvl_0, xloc=xloc.bar_time, color=fib01Col, style=line.style_dashed)
        fib1Line  := line.new(drawT, lvl_1, time + extMs, lvl_1, xloc=xloc.bar_time, color=fib01Col, style=line.style_dashed)
        
        fib50Line := line.new(drawT, lvl_05, time + extMs, lvl_05, xloc=xloc.bar_time, color=fib50Col, style=line.style_solid)
        fib50Lbl  := label.new(time + extMs, lvl_05, "Magnetic Level", xloc=xloc.bar_time, style=label.style_label_left, textcolor=fib50Col, color=color.new(color.white, 100), size=size.small)
        
        if (fibMode == "Session" or fibMode == "First 4H") and lastSessName != ""
            sessHLbl := label.new(time + extMs, lockedFibHigh, lastSessName + " High", xloc=xloc.bar_time, style=label.style_label_left, textcolor=chart.fg_color, color=color.new(chart.bg_color, 100), size=size.small)
            sessLLbl := label.new(time + extMs, lockedFibLow, lastSessName + " Low", xloc=xloc.bar_time, style=label.style_label_left, textcolor=chart.fg_color, color=color.new(chart.bg_color, 100), size=size.small)
            
        tp1Box    := box.new(drawT, lvl_155, time + extMs, lvl_147, xloc=xloc.bar_time, border_color=na, bgcolor=tp1Col, text="Reaction Zone", text_color=chart.fg_color, text_halign=text.align_right, text_size=size.small)
        tp2Box    := box.new(drawT, lvl_264, time + extMs, lvl_256, xloc=xloc.bar_time, border_color=na, bgcolor=tp2Col, text="External Reaction Zone", text_color=chart.fg_color, text_halign=text.align_right, text_size=size.small)
        negBox    := box.new(drawT, lvl_neg21, time + extMs, lvl_neg29, xloc=xloc.bar_time, border_color=na, bgcolor=negCol, text="Liquidity", text_color=chart.fg_color, text_halign=text.align_right, text_size=size.small)

//==================== SWEEP LOGIC ====================
if inCalc and showFib and not na(activeLiquidityTop) and not na(activeLiquidityBot) and not createNewFib
    if fibDir == 1
        // Bullish Setup -> Liquidity is below 0. 
        // Sweep if price drops below liquidity zone top and closes above it.
        if low < activeLiquidityTop and close >= activeLiquidityTop
            label.new(bar_index, low, "x", style=label.style_label_up, color=#00000000, textcolor=color.green, size=size.small)
    else if fibDir == -1
        // Bearish Setup -> Liquidity is above 0.
        // Sweep if price pushes above liquidity zone bottom and closes below it.
        if high > activeLiquidityBot and close <= activeLiquidityBot
            label.new(bar_index, high, "x", style=label.style_label_down, color=#00000000, textcolor=color.red, size=size.small)

//==================== FVG ENGINE ====================
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

if fvg_enable
    dFVG()
````
