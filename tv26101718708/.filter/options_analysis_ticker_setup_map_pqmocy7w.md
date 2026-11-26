# Options Analysis Ticker Setup Map

- url: https://www.tradingview.com/script/PqMOCy7w-Options-Analysis-Ticker-Setup-Map/
- type: indicator
- pine_id: PUB;361693e086c94fddbcd82b6bc91549e0
- version: 1.0

## Description

1/12

Top watches for 5/13.

This board is very different than last night.

Market is sitting on a key gamma decision after CPI. SPY $736 is the line I care about. Above it, dips can get bought back toward $742/$745. Below it, things can open up fast toward $735/$730.

Calls and puts are both live.

2/12

[symbol="NASDAQ:FCEL"]NASDAQ:FCEL[/symbol]

Best momentum setup on the board, but also the easiest one to chase badly.

Flow was extremely call heavy, with repeated Jun 26 $19C sweeps and high SigScore prints.

I’m not touching a vertical open.

Want either a pullback toward $17.50 to $18.20 or a clean hold after the first 5 min.

Target zone is $20, then $22 to $25 if momentum keeps feeding.

3/12

[symbol="NASDAQ:DKNG"]NASDAQ:DKNG[/symbol]

This one is cleaner than people will think because the flow kept showing up in the same area.

The focus is the Aug 21 $30C.

Not a random one-off print. It looked like systematic accumulation.

Setup is simple enough: hold $24.50/$25 and let it work.

Targets are $27 first, then $30 if the flow is right.

4/12

[symbol="NYSE:GS"]NYSE:GS[/symbol]

One of the better large-cap names because it actually held up on a red CPI day.

That matters.

Flow was focused higher, especially around the $950 to $1,000 area.

I like this only if it holds the $945/$950 area.

First target $960. Bigger stretch is $985/$1,000.

Not interested if it loses $930.

5/12

[symbol="NYSE:BA"]NYSE:BA[/symbol]

Defense/industrial strength is still showing up.

BA held well relative to the market and the call flow was aimed at $245/$250.

The $250 area is the magnet.

Best setup is a dip toward $236 to $239 that buyers defend.

$245 first target.
$250 second target.

Below $230, the setup is off.

6/12

[symbol="NASDAQ:TSLA"]NASDAQ:TSLA[/symbol]

Inside close setup.

Not pretending this is clean by default. It needs resolution.

The upside case is built around $435/$440 and then $450 if it gets momentum.

Watching May 15 $440C.

Above $435, it can move fast.
Below $425, I do not want the long side.

This one needs market confirmation.

7/12

[symbol="AMEX:SOXL"]AMEX:SOXL[/symbol]

High risk, high beta, but the flow was interesting.

The key is $170.

If $170 holds, the Jun 5 $175C setup is live for a bounce toward $180, then $185 plus.

If $170 fails, I’m not trying to be early.

This is one where waiting 15 minutes probably saves money.

8/12

[symbol="NASDAQ:MARA"]NASDAQ:MARA[/symbol]

This is basically a BTC trigger trade.

If Bitcoin clears the $82K area, MARA can get very live.

Watching May 22 $13C.

Entry zone is $12.60 to $13.00.

Targets are $13.50, then $14/$15 if BTC confirms.

Below $11.50, no interest.

9/12

[symbol="NASDAQ:LRCX"]NASDAQ:LRCX[/symbol]

Semis pulled back, but LRCX still has the better structure versus a lot of the group.

Flow had late-day call interest, including longer-dated upside.

The clean trade is a reclaim/hold near $286 to $290.

Watching May 22 $295C.

Targets $300, then $310.

Below $280, pass.

10/12

[symbol="NASDAQ:MU"]NASDAQ:MU[/symbol]

This is the main put setup.

Not shorting a gap-down into the hole.

The trade is a bounce-fade.

Watching May 22 $750P if MU bounces into $750/$755 and rejects.

Targets are $735, then $720/$710.

Above $775, the put setup is invalid.

11/12

[symbol="NYSE:SNOW"]NYSE:SNOW[/symbol]

Inside close setup.

This is more conditional than the top names.

Needs to hold $148 and reclaim/hold $151.50 to $153.

Watching May 15 $155C for aggressive exposure.

First target $155.
Then $160 to $165 if it actually expands.

No chop trade.

12/12

My actual priority for 5/13:

1. [symbol="NASDAQ:FCEL"]NASDAQ:FCEL[/symbol] only after open confirms
2. [symbol="NASDAQ:DKNG"]NASDAQ:DKNG[/symbol] $30C continuation
3. [symbol="NYSE:GS"]NYSE:GS[/symbol] relative strength
4. [symbol="NYSE:BA"]NYSE:BA[/symbol] dip-hold into $245/$250
5. [symbol="NASDAQ:TSLA"]NASDAQ:TSLA[/symbol] above $435
6. [symbol="AMEX:SOXL"]AMEX:SOXL[/symbol] only if $170 holds
7. [symbol="NASDAQ:MARA"]NASDAQ:MARA[/symbol] only if BTC confirms
8. [symbol="NASDAQ:LRCX"]NASDAQ:LRCX[/symbol] semi reclaim
9. [symbol="NASDAQ:MU"]NASDAQ:MU[/symbol] puts on bounce rejection
10. [symbol="NYSE:SNOW"]NYSE:SNOW[/symbol] only above $151.50/$153

No open chase.
Levels first.
Contract second.

## Source Code

````pine
//@version=6
indicator("BullFlow 5/13 Institutional Setup Board | 10 Single-Ticker Map", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ======================================================
// BULLFLOW 5/13 INSTITUTIONAL SETUP BOARD
// Hardcoded single-ticker setup map for:
// FCEL, DKNG, GS, BA, TSLA, SOXL, MARA, LRCX, MU, SNOW
//
// Built to avoid plot-count errors:
// - GEX / trigger / target / invalidation levels use line objects.
// - Dashboard uses table objects.
// - Only EMA/VWAP are plotted.
// - Alerts use alertcondition plus optional dynamic alert() messages.
// ======================================================


// ======================================================
// INPUTS
// ======================================================

groupDisplay = "Display"
showLevels = input.bool(true, "Show Setup + GEX Levels", group = groupDisplay)
showLabels = input.bool(true, "Show Right-Side Level Labels", group = groupDisplay)
showDashboard = input.bool(true, "Show Dashboard", group = groupDisplay)
showSignalLabels = input.bool(true, "Show Signal Labels", group = groupDisplay)
showEMAs = input.bool(true, "Show EMA/VWAP Stack", group = groupDisplay)
showOR = input.bool(true, "Show Opening Range", group = groupDisplay)

dashPosOpt = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupDisplay)
dashSizeOpt = input.string("Small", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = groupDisplay)
labelSizeOpt = input.string("Small", "Level Label Size", options = ["Tiny", "Small", "Normal"], group = groupDisplay)
lookbackBars = input.int(350, "Level Line Lookback Bars", minval = 50, maxval = 1000, group = groupDisplay)
extendBars = input.int(115, "Level Line Extension Bars", minval = 20, maxval = 500, group = groupDisplay)
labelOffset = input.int(18, "Right Label Offset", minval = 5, maxval = 250, group = groupDisplay)
labelStagger = input.int(9, "Horizontal Label Stagger", minval = 0, maxval = 40, group = groupDisplay)

groupFilters = "Execution Filters"
rthSession = input.session("0930-1600", "RTH Session", group = groupFilters)
orMinutes = input.int(15, "Opening Range Minutes", minval = 1, maxval = 60, group = groupFilters)
useVWAPFilter = input.bool(true, "Require VWAP Alignment", group = groupFilters)
useEMAFilter = input.bool(true, "Require 9 EMA / 21 EMA Alignment", group = groupFilters)
useRVOLFilter = input.bool(false, "Require Relative Volume", group = groupFilters)
minRVOL = input.float(1.20, "Minimum RVOL", minval = 0.10, step = 0.05, group = groupFilters)
signalCooldownBars = input.int(5, "Signal Cooldown Bars", minval = 1, maxval = 100, group = groupFilters)

groupAlerts = "Alerts"
enableDynamicAlerts = input.bool(true, "Enable Dynamic alert() Messages", group = groupAlerts)
enableLevelTouchAlerts = input.bool(true, "Enable Level Touch Alerts", group = groupAlerts)
alertCooldownBars = input.int(3, "Dynamic Alert Cooldown Bars", minval = 1, maxval = 100, group = groupAlerts)

groupColors = "Colors"
cGexPos = input.color(color.rgb(0, 120, 65), "Positive GEX / Magnet", group = groupColors)
cGexNeg = input.color(color.rgb(185, 0, 20), "Negative GEX / Air Pocket", group = groupColors)
cTrigger = input.color(color.rgb(0, 95, 170), "Trigger / Confirmation", group = groupColors)
cTarget = input.color(color.rgb(0, 80, 200), "Target", group = groupColors)
cInvalid = input.color(color.rgb(205, 0, 0), "Invalidation", group = groupColors)
cEntry = input.color(color.rgb(230, 135, 0), "Entry Zone", group = groupColors)
cNeutral = input.color(color.rgb(20, 20, 20), "Neutral / Reference", group = groupColors)
cOR = input.color(color.rgb(95, 95, 95), "Opening Range", group = groupColors)


// ======================================================
// CORE INDICATORS
// ======================================================

ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
vwapVal = ta.vwap(hlc3)
volSma = ta.sma(volume, 20)
rvol = volSma > 0 ? volume / volSma : na

plot(showEMAs ? ema9 : na, "EMA 9", color = color.rgb(25, 135, 35), linewidth = 2)
plot(showEMAs ? ema21 : na, "EMA 21", color = color.rgb(0, 135, 210), linewidth = 2)
plot(showEMAs ? ema50 : na, "EMA 50", color = color.rgb(120, 80, 200), linewidth = 2)
plot(showEMAs ? ema200 : na, "EMA 200", color = color.rgb(230, 65, 130), linewidth = 2)
plot(showEMAs ? vwapVal : na, "VWAP", color = color.rgb(255, 140, 0), linewidth = 2)


// ======================================================
// SESSION / OPENING RANGE LOGIC
// ======================================================

isRTH = not na(time(timeframe.period, rthSession))
newRTH = isRTH and not isRTH[1]

var int rthStartTime = na
var float orHigh = na
var float orLow = na

if newRTH
    rthStartTime := time
    orHigh := high
    orLow := low

minutesFromOpen = isRTH and not na(rthStartTime) ? float(time - rthStartTime) / 60000.0 : na
withinOpeningRange = isRTH and not na(minutesFromOpen) and minutesFromOpen < orMinutes

if isRTH and withinOpeningRange and not newRTH
    orHigh := math.max(orHigh, high)
    orLow := math.min(orLow, low)

newDay = ta.change(time("D")) != 0


// ======================================================
// ARRAYS / DRAWING STATE
// ======================================================

var float[] lvlPrice = array.new_float()
var string[] lvlName = array.new_string()
var string[] lvlRole = array.new_string()

var line[] drawnLines = array.new_line()
var label[] drawnLabels = array.new_label()

f_dashPos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left" ? position.bottom_left :
     position.top_right

f_txtSize(string s) =>
    s == "Tiny" ? size.tiny :
     s == "Normal" ? size.normal :
     size.small

f_roleColor(string role) =>
    role == "GEX+" ? cGexPos :
     role == "GEX-" ? cGexNeg :
     role == "TRIGGER" ? cTrigger :
     role == "CONFIRM" ? cTrigger :
     role == "TARGET" ? cTarget :
     role == "INVALID" ? cInvalid :
     role == "ENTRY" ? cEntry :
     role == "OR" ? cOR :
     cNeutral

f_roleStyle(string role) =>
    role == "ENTRY" ? line.style_dotted :
     role == "TARGET" ? line.style_dashed :
     role == "OR" ? line.style_dotted :
     line.style_solid

f_roleWidth(string role) =>
    role == "GEX+" ? 2 :
     role == "GEX-" ? 2 :
     role == "TRIGGER" ? 2 :
     role == "CONFIRM" ? 2 :
     role == "INVALID" ? 2 :
     role == "TARGET" ? 2 :
     1

f_clearObjects() =>
    int lc = array.size(drawnLines)
    if lc > 0
        for i = 0 to lc - 1
            line.delete(array.get(drawnLines, i))
    array.clear(drawnLines)

    int lbCount = array.size(drawnLabels)
    if lbCount > 0
        for i = 0 to lbCount - 1
            label.delete(array.get(drawnLabels, i))
    array.clear(drawnLabels)

f_addLevel(float p, string name, string role) =>
    if not na(p)
        array.push(lvlPrice, p)
        array.push(lvlName, name)
        array.push(lvlRole, role)

f_drawLevel(float p, string name, string role, int idx) =>
    color col = f_roleColor(role)
    ls = f_roleStyle(role)
    int width = f_roleWidth(role)
    int x1 = bar_index - lookbackBars
    int x2 = bar_index + extendBars

    line ln = line.new(
         x1, p,
         x2, p,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = col,
         width = width,
         style = ls
     )

    array.push(drawnLines, ln)

    if showLabels
        int staggerX = labelOffset + ((idx % 4) * labelStagger)
        string txt = name + "  " + str.tostring(p, format.mintick)

        label lb = label.new(
             bar_index + staggerX,
             p,
             txt,
             xloc = xloc.bar_index,
             style = label.style_label_left,
             textcolor = color.white,
             color = col,
             size = f_txtSize(labelSizeOpt)
         )

        array.push(drawnLabels, lb)

f_touchLevel(int idx) =>
    enableLevelTouchAlerts and array.size(lvlPrice) > idx and high >= array.get(lvlPrice, idx) and low <= array.get(lvlPrice, idx)


// ======================================================
// TICKER-SPECIFIC CONFIGURATION
// ======================================================

array.clear(lvlPrice)
array.clear(lvlName)
array.clear(lvlRole)

string sym = str.upper(syminfo.ticker)

bool setupActive = false
int setupDir = 0

string setupRank = "N/A"
string setupGrade = "N/A"
string setupBias = "No setup mapped"
string setupCategory = "N/A"
string contract = "N/A"
string secondaryContract = "N/A"
string gexRead = "N/A"
string setupNote = "Switch to FCEL, DKNG, GS, BA, TSLA, SOXL, MARA, LRCX, MU, or SNOW."
string executionRule = "No mapped setup."

float entryLo = na
float entryHi = na
float longTrigger = na
float shortTrigger = na
float confirmLevel = na
float invalidLevel = na
float hardInvalid = na
float target1 = na
float target2 = na
float target3 = na


// ---------- FCEL ----------
if sym == "FCEL"
    setupActive := true
    setupDir := 1
    setupRank := "1"
    setupGrade := "A+ / 5-star momentum"
    setupBias := "Long Calls"
    setupCategory := "Hammer / momentum continuation"
    contract := "FCEL Jun26 19C"
    secondaryContract := "Jun26 18C for more delta"
    entryLo := 17.50
    entryHi := 18.20
    longTrigger := 18.20
    confirmLevel := 19.00
    invalidLevel := 16.50
    hardInvalid := 16.00
    target1 := 20.00
    target2 := 22.00
    target3 := 25.00
    gexRead := "+GEX regime. Max +GEX below spot at 15. Sparse gamma above 18."
    setupNote := "Momentum name. Wait for first 5m hold. No vertical open chase."
    executionRule := "Long only if 17.50-18.20 holds or 19 confirms."
    f_addLevel(15.00, "MAX +GEX / ITM WALL", "GEX+")
    f_addLevel(16.00, "HARD INVALID", "INVALID")
    f_addLevel(16.50, "INVALID CLOSE", "INVALID")
    f_addLevel(17.50, "ENTRY ZONE LOW", "ENTRY")
    f_addLevel(18.20, "ENTRY ZONE HIGH / TRIGGER", "TRIGGER")
    f_addLevel(19.00, "CONFIRM / 19C FLOW", "CONFIRM")
    f_addLevel(20.00, "TARGET 1", "TARGET")
    f_addLevel(22.00, "TARGET 2", "TARGET")
    f_addLevel(25.00, "TARGET 3 / STRETCH", "TARGET")


// ---------- DKNG ----------
if sym == "DKNG"
    setupActive := true
    setupDir := 1
    setupRank := "2"
    setupGrade := "A+ / 5-star accumulation"
    setupBias := "Long Calls"
    setupCategory := "Hammer / base breakout"
    contract := "DKNG Aug21 30C"
    secondaryContract := "DKNG Jun18 27C"
    entryLo := 24.50
    entryHi := 25.20
    longTrigger := 25.20
    confirmLevel := 27.00
    invalidLevel := 23.50
    hardInvalid := 22.50
    target1 := 27.00
    target2 := 30.00
    target3 := na
    gexRead := "Max +GEX at 30. 25 is near-term floor. Light negative below 23.50."
    setupNote := "Best if 24.50-25.20 accepts. 30 is the flow/GEX magnet."
    executionRule := "Long above 25.20 with VWAP/9EMA. Avoid if 23.50 fails."
    f_addLevel(22.50, "NEG GEX / HARD RISK", "GEX-")
    f_addLevel(23.50, "INVALID / NEG GEX", "INVALID")
    f_addLevel(24.50, "ENTRY ZONE LOW", "ENTRY")
    f_addLevel(25.00, "GEX FLOOR / SUPPORT", "GEX+")
    f_addLevel(25.20, "ENTRY ZONE HIGH / TRIGGER", "TRIGGER")
    f_addLevel(27.00, "TARGET 1 / CONFIRM", "CONFIRM")
    f_addLevel(30.00, "MAX +GEX / TARGET 2", "GEX+")


// ---------- GS ----------
if sym == "GS"
    setupActive := true
    setupDir := 1
    setupRank := "3"
    setupGrade := "A+ / 5-star relative strength"
    setupBias := "Long Calls"
    setupCategory := "Hammer / financial relative strength"
    contract := "GS May22 950C"
    secondaryContract := "GS May22 960C"
    entryLo := 945.00
    entryHi := 950.00
    longTrigger := 950.00
    confirmLevel := 960.00
    invalidLevel := 930.00
    hardInvalid := 920.00
    target1 := 960.00
    target2 := 985.00
    target3 := 1000.00
    gexRead := "Strong positive GEX. Max +GEX at 950. Upside flow at 985/1000."
    setupNote := "Best if 945-950 holds. Financial RS name."
    executionRule := "Long over 950 or on 945-950 support hold. No chase into 985."
    f_addLevel(920.00, "HARD INVALID", "INVALID")
    f_addLevel(930.00, "INVALID CLOSE", "INVALID")
    f_addLevel(940.00, "MINOR NEG GEX / RISK", "GEX-")
    f_addLevel(945.00, "ENTRY LOW", "ENTRY")
    f_addLevel(950.00, "MAX +GEX / TRIGGER", "GEX+")
    f_addLevel(960.00, "TARGET 1 / CONFIRM", "CONFIRM")
    f_addLevel(985.00, "TARGET 2 / FLOW STRIKE", "TARGET")
    f_addLevel(1000.00, "TARGET 3 / FLOW STRIKE", "TARGET")


// ---------- BA ----------
if sym == "BA"
    setupActive := true
    setupDir := 1
    setupRank := "4"
    setupGrade := "A / 4.5-star call continuation"
    setupBias := "Long Calls"
    setupCategory := "Hammer / defense relative strength"
    contract := "BA Jun18 250C"
    secondaryContract := "BA Aug21 250C"
    entryLo := 236.00
    entryHi := 239.00
    longTrigger := 240.00
    confirmLevel := 245.00
    invalidLevel := 230.00
    hardInvalid := 227.50
    target1 := 245.00
    target2 := 250.00
    target3 := 255.00
    gexRead := "Positive GEX staircase at 240/245/250. Max +GEX at 250."
    setupNote := "Cleaner liquid long if 236-239 holds and 240 reclaims."
    executionRule := "Long over 240 or support hold. Invalidate under 230."
    f_addLevel(227.50, "HARD RISK / NEG GEX", "GEX-")
    f_addLevel(230.00, "INVALID / NEG GEX", "INVALID")
    f_addLevel(236.00, "ENTRY LOW", "ENTRY")
    f_addLevel(239.00, "ENTRY HIGH", "ENTRY")
    f_addLevel(240.00, "GEX STEP / TRIGGER", "GEX+")
    f_addLevel(245.00, "GEX STEP / TARGET 1", "GEX+")
    f_addLevel(250.00, "MAX +GEX / TARGET 2", "GEX+")
    f_addLevel(255.00, "STRETCH TARGET", "TARGET")


// ---------- TSLA ----------
if sym == "TSLA"
    setupActive := true
    setupDir := 1
    setupRank := "5"
    setupGrade := "A- / liquid gamma setup"
    setupBias := "Long Calls"
    setupCategory := "Inside close / compression"
    contract := "TSLA May15 440C"
    secondaryContract := "TSLA May22 440C"
    entryLo := 432.00
    entryHi := 436.00
    longTrigger := 435.00
    confirmLevel := 440.00
    invalidLevel := 425.00
    hardInvalid := 420.00
    target1 := 440.00
    target2 := 450.00
    target3 := na
    gexRead := "Negative gamma pocket near 425-430. 440/450 are major +GEX magnets."
    setupNote := "Only if QQQ confirms. Inside close needs directional resolution."
    executionRule := "Long over 435 with VWAP/9EMA. Invalidate below 425."
    f_addLevel(420.00, "HARD INVALID", "INVALID")
    f_addLevel(425.00, "INVALID / NEG GEX", "GEX-")
    f_addLevel(430.00, "NEG GEX POCKET", "GEX-")
    f_addLevel(432.00, "ENTRY LOW", "ENTRY")
    f_addLevel(435.00, "LONG TRIGGER", "TRIGGER")
    f_addLevel(436.00, "ENTRY HIGH", "ENTRY")
    f_addLevel(440.00, "TARGET 1 / +GEX", "GEX+")
    f_addLevel(450.00, "MAX +GEX / TARGET 2", "GEX+")


// ---------- SOXL ----------
if sym == "SOXL"
    setupActive := true
    setupDir := 1
    setupRank := "6"
    setupGrade := "A- / high-risk dip-buy"
    setupBias := "Long Calls"
    setupCategory := "Hammer / leveraged semi bounce"
    contract := "SOXL Jun05 175C"
    secondaryContract := "N/A"
    entryLo := 171.00
    entryHi := 174.00
    longTrigger := 175.00
    confirmLevel := 180.00
    invalidLevel := 168.00
    hardInvalid := 165.00
    target1 := 180.00
    target2 := 185.00
    target3 := 195.00
    gexRead := "Max -GEX near 170. Bounce works only if 170 holds."
    setupNote := "3x ETF. Wait first 15m. Do not buy if 170 fails."
    executionRule := "Long only after 170 hold and 175 reclaim."
    f_addLevel(165.00, "HARD INVALID", "INVALID")
    f_addLevel(168.00, "INVALID CLOSE", "INVALID")
    f_addLevel(170.00, "MAX -GEX / LINE IN SAND", "GEX-")
    f_addLevel(171.00, "ENTRY LOW", "ENTRY")
    f_addLevel(174.00, "ENTRY HIGH", "ENTRY")
    f_addLevel(175.00, "FLOW STRIKE / TRIGGER", "TRIGGER")
    f_addLevel(180.00, "TARGET 1 / CONFIRM", "CONFIRM")
    f_addLevel(185.00, "TARGET 2 / +GEX", "TARGET")
    f_addLevel(195.00, "MAX +GEX / STRETCH", "GEX+")


// ---------- MARA ----------
if sym == "MARA"
    setupActive := true
    setupDir := 1
    setupRank := "7"
    setupGrade := "A- / BTC-linked momentum"
    setupBias := "Long Calls"
    setupCategory := "Hammer / crypto beta"
    contract := "MARA May22 13C"
    secondaryContract := "MARA May22 14C"
    entryLo := 12.60
    entryHi := 13.00
    longTrigger := 13.00
    confirmLevel := 13.50
    invalidLevel := 11.50
    hardInvalid := 11.00
    target1 := 13.50
    target2 := 14.00
    target3 := 15.00
    gexRead := "Positive GEX at 12.50/13.50/14. BTC breakout is the accelerator."
    setupNote := "Best only if BTC confirms. Avoid if 12.50 fails."
    executionRule := "Long above 13 with BTC support. Hard risk under 11.50."
    f_addLevel(11.00, "HARD INVALID", "INVALID")
    f_addLevel(11.50, "INVALID / NEG GEX", "GEX-")
    f_addLevel(12.50, "GEX SUPPORT", "GEX+")
    f_addLevel(12.60, "ENTRY LOW", "ENTRY")
    f_addLevel(13.00, "LONG TRIGGER / FLOW", "TRIGGER")
    f_addLevel(13.50, "TARGET 1 / +GEX", "GEX+")
    f_addLevel(14.00, "MAX +GEX / TARGET 2", "GEX+")
    f_addLevel(15.00, "STRETCH TARGET", "TARGET")


// ---------- LRCX ----------
if sym == "LRCX"
    setupActive := true
    setupDir := 1
    setupRank := "8"
    setupGrade := "A- / semi dip-buy"
    setupBias := "Long Calls"
    setupCategory := "Hammer / high-base pullback"
    contract := "LRCX May22 295C"
    secondaryContract := "LRCX May22 300C"
    entryLo := 286.00
    entryHi := 290.00
    longTrigger := 290.00
    confirmLevel := 295.00
    invalidLevel := 280.00
    hardInvalid := 267.50
    target1 := 300.00
    target2 := 307.50
    target3 := 310.00
    gexRead := "300-310 is the magnet cluster. 267.5/260 are downside air pockets."
    setupNote := "Needs semi tape support. Best over 290 with 295 confirm."
    executionRule := "Long over 290/295. Invalidate below 280."
    f_addLevel(260.00, "DEEP NEG GEX", "GEX-")
    f_addLevel(267.50, "HARD INVALID / NEG GEX", "GEX-")
    f_addLevel(280.00, "INVALID CLOSE", "INVALID")
    f_addLevel(286.00, "ENTRY LOW", "ENTRY")
    f_addLevel(290.00, "ENTRY HIGH / TRIGGER", "TRIGGER")
    f_addLevel(295.00, "CONTRACT / CONFIRM", "CONFIRM")
    f_addLevel(300.00, "TARGET 1 / +GEX", "GEX+")
    f_addLevel(307.50, "TARGET 2 / +GEX", "GEX+")
    f_addLevel(310.00, "MAX +GEX / TARGET 3", "GEX+")


// ---------- MU ----------
if sym == "MU"
    setupActive := true
    setupDir := -1
    setupRank := "9"
    setupGrade := "A / primary put setup"
    setupBias := "Long Puts"
    setupCategory := "Shooter / bearish continuation"
    contract := "MU May22 750P"
    secondaryContract := "MU May22 740P"
    entryLo := 750.00
    entryHi := 755.00
    shortTrigger := 750.00
    confirmLevel := 735.00
    invalidLevel := 775.00
    hardInvalid := 800.00
    target1 := 735.00
    target2 := 720.00
    target3 := 710.00
    gexRead := "Negative gamma zone 720-790. Max +GEX at 800. Max -GEX much lower."
    setupNote := "Do not chase gap-down. Best entry is bounce into 750-755 rejection."
    executionRule := "Short only after bounce rejection. Invalid over 775."
    f_addLevel(800.00, "MAX +GEX / HARD INVALID", "GEX+")
    f_addLevel(775.00, "INVALID CLOSE", "INVALID")
    f_addLevel(770.00, "NEG GEX", "GEX-")
    f_addLevel(760.00, "NEG GEX", "GEX-")
    f_addLevel(755.00, "BOUNCE ENTRY HIGH", "ENTRY")
    f_addLevel(750.00, "PUT TRIGGER / FLOW", "TRIGGER")
    f_addLevel(740.00, "NEG GEX", "GEX-")
    f_addLevel(735.00, "TARGET 1 / CONFIRM", "CONFIRM")
    f_addLevel(730.00, "NEG GEX", "GEX-")
    f_addLevel(720.00, "TARGET 2 / GEX TARGET", "TARGET")
    f_addLevel(710.00, "TARGET 3", "TARGET")
    f_addLevel(650.00, "MAX -GEX EXTREME", "GEX-")


// ---------- SNOW ----------
if sym == "SNOW"
    setupActive := true
    setupDir := 1
    setupRank := "10"
    setupGrade := "B+ / conditional inside close"
    setupBias := "Long Calls"
    setupCategory := "Inside close / GEX pin"
    contract := "SNOW May15 155C"
    secondaryContract := "SNOW Jun18 160C"
    entryLo := 151.50
    entryHi := 153.00
    longTrigger := 153.00
    confirmLevel := 155.00
    invalidLevel := 148.00
    hardInvalid := 140.00
    target1 := 155.00
    target2 := 160.00
    target3 := 165.00
    gexRead := "155 is near-term +GEX pin. 160/165 are June magnets. Danger below 148."
    setupNote := "Conditional. Needs 153 reclaim and 155 confirmation."
    executionRule := "Long only above 153/155. Avoid if 148 fails."
    f_addLevel(140.00, "DEEP NEG GEX / HARD RISK", "GEX-")
    f_addLevel(143.00, "NEG GEX", "GEX-")
    f_addLevel(146.00, "NEG GEX", "GEX-")
    f_addLevel(148.00, "INVALID CLOSE", "INVALID")
    f_addLevel(149.00, "GEX SUPPORT", "GEX+")
    f_addLevel(150.00, "GEX SUPPORT", "GEX+")
    f_addLevel(151.50, "ENTRY LOW", "ENTRY")
    f_addLevel(153.00, "ENTRY HIGH / TRIGGER", "TRIGGER")
    f_addLevel(155.00, "MAX +GEX / TARGET 1", "GEX+")
    f_addLevel(160.00, "TARGET 2 / JUNE +GEX", "GEX+")
    f_addLevel(165.00, "TARGET 3 / JUNE +GEX", "GEX+")


// ======================================================
// FILTERS / SIGNALS
// ======================================================

rvolOk = not useRVOLFilter or (not na(rvol) and rvol >= minRVOL)

longVWAPOk = not useVWAPFilter or close > vwapVal
shortVWAPOk = not useVWAPFilter or close < vwapVal

longEMAOk = not useEMAFilter or (close > ema9 and ema9 >= ema21)
shortEMAOk = not useEMAFilter or (close < ema9 and ema9 <= ema21)

longFilterOk = longVWAPOk and longEMAOk and rvolOk
shortFilterOk = shortVWAPOk and shortEMAOk and rvolOk

var int lastSignalBar = na
canSignal = na(lastSignalBar) or bar_index - lastSignalBar >= signalCooldownBars

longCross = not na(longTrigger) and ta.crossover(close, longTrigger)
longConfirmCross = not na(confirmLevel) and ta.crossover(close, confirmLevel)
shortCross = not na(shortTrigger) and ta.crossunder(close, shortTrigger)
shortConfirmCross = not na(confirmLevel) and ta.crossunder(close, confirmLevel)

longTriggerSignal = setupActive and setupDir == 1 and isRTH and barstate.isconfirmed and canSignal and longCross and longFilterOk
longConfirmSignal = setupActive and setupDir == 1 and isRTH and barstate.isconfirmed and canSignal and longConfirmCross and longFilterOk

shortTriggerSignal = setupActive and setupDir == -1 and isRTH and barstate.isconfirmed and canSignal and shortCross and shortFilterOk
shortConfirmSignal = setupActive and setupDir == -1 and isRTH and barstate.isconfirmed and canSignal and shortConfirmCross and shortFilterOk

invalidSignal = setupActive and isRTH and barstate.isconfirmed and not na(invalidLevel) and (setupDir == 1 ? close < invalidLevel : close > invalidLevel)
hardInvalidSignal = setupActive and isRTH and barstate.isconfirmed and not na(hardInvalid) and (setupDir == 1 ? close < hardInvalid : close > hardInvalid)

target1Hit = setupActive and isRTH and not na(target1) and (setupDir == 1 ? high >= target1 and high[1] < target1 : low <= target1 and low[1] > target1)
target2Hit = setupActive and isRTH and not na(target2) and (setupDir == 1 ? high >= target2 and high[1] < target2 : low <= target2 and low[1] > target2)
target3Hit = setupActive and isRTH and not na(target3) and (setupDir == 1 ? high >= target3 and high[1] < target3 : low <= target3 and low[1] > target3)

if longTriggerSignal or longConfirmSignal or shortTriggerSignal or shortConfirmSignal or invalidSignal or hardInvalidSignal or target1Hit or target2Hit or target3Hit
    lastSignalBar := bar_index


// ======================================================
// LEVEL TOUCH ALERT CONDITIONS
// ======================================================

lvl01Touch = setupActive and isRTH and f_touchLevel(0)
lvl02Touch = setupActive and isRTH and f_touchLevel(1)
lvl03Touch = setupActive and isRTH and f_touchLevel(2)
lvl04Touch = setupActive and isRTH and f_touchLevel(3)
lvl05Touch = setupActive and isRTH and f_touchLevel(4)
lvl06Touch = setupActive and isRTH and f_touchLevel(5)
lvl07Touch = setupActive and isRTH and f_touchLevel(6)
lvl08Touch = setupActive and isRTH and f_touchLevel(7)
lvl09Touch = setupActive and isRTH and f_touchLevel(8)
lvl10Touch = setupActive and isRTH and f_touchLevel(9)
lvl11Touch = setupActive and isRTH and f_touchLevel(10)
lvl12Touch = setupActive and isRTH and f_touchLevel(11)

anyLevelTouch = lvl01Touch or lvl02Touch or lvl03Touch or lvl04Touch or lvl05Touch or lvl06Touch or lvl07Touch or lvl08Touch or lvl09Touch or lvl10Touch or lvl11Touch or lvl12Touch


// ======================================================
// ALERTCONDITIONS
// ======================================================

alertcondition(longTriggerSignal, "BullFlow Long Trigger", "BullFlow setup: long trigger fired. Check dashboard and level labels.")
alertcondition(longConfirmSignal, "BullFlow Long Confirmation", "BullFlow setup: long confirmation fired. Check dashboard and level labels.")
alertcondition(shortTriggerSignal, "BullFlow Short Trigger", "BullFlow setup: short trigger fired. Check dashboard and level labels.")
alertcondition(shortConfirmSignal, "BullFlow Short Confirmation", "BullFlow setup: short confirmation fired. Check dashboard and level labels.")
alertcondition(invalidSignal, "BullFlow Invalidation", "BullFlow setup: invalidation fired. Check dashboard and level labels.")
alertcondition(hardInvalidSignal, "BullFlow Hard Invalidation", "BullFlow setup: hard invalidation fired. Check dashboard and level labels.")
alertcondition(target1Hit, "BullFlow Target 1 Hit", "BullFlow setup: target 1 hit.")
alertcondition(target2Hit, "BullFlow Target 2 Hit", "BullFlow setup: target 2 hit.")
alertcondition(target3Hit, "BullFlow Target 3 Hit", "BullFlow setup: target 3 hit.")
alertcondition(anyLevelTouch, "BullFlow Any Level Touch", "BullFlow setup: one mapped level was touched. Check dashboard and level labels.")

alertcondition(lvl01Touch, "BullFlow Level 01 Touch", "BullFlow setup: Level 01 touched.")
alertcondition(lvl02Touch, "BullFlow Level 02 Touch", "BullFlow setup: Level 02 touched.")
alertcondition(lvl03Touch, "BullFlow Level 03 Touch", "BullFlow setup: Level 03 touched.")
alertcondition(lvl04Touch, "BullFlow Level 04 Touch", "BullFlow setup: Level 04 touched.")
alertcondition(lvl05Touch, "BullFlow Level 05 Touch", "BullFlow setup: Level 05 touched.")
alertcondition(lvl06Touch, "BullFlow Level 06 Touch", "BullFlow setup: Level 06 touched.")
alertcondition(lvl07Touch, "BullFlow Level 07 Touch", "BullFlow setup: Level 07 touched.")
alertcondition(lvl08Touch, "BullFlow Level 08 Touch", "BullFlow setup: Level 08 touched.")
alertcondition(lvl09Touch, "BullFlow Level 09 Touch", "BullFlow setup: Level 09 touched.")
alertcondition(lvl10Touch, "BullFlow Level 10 Touch", "BullFlow setup: Level 10 touched.")
alertcondition(lvl11Touch, "BullFlow Level 11 Touch", "BullFlow setup: Level 11 touched.")
alertcondition(lvl12Touch, "BullFlow Level 12 Touch", "BullFlow setup: Level 12 touched.")


// ======================================================
// DYNAMIC ALERTS
// Use TradingView alert type: "Any alert() function call"
// ======================================================

var int lastDynAlertBar = na
canDynAlert = na(lastDynAlertBar) or bar_index - lastDynAlertBar >= alertCooldownBars

if enableDynamicAlerts and barstate.isconfirmed and setupActive and canDynAlert
    if longTriggerSignal
        alert(sym + " LONG TRIGGER | " + contract + " | Close " + str.tostring(close, format.mintick) + " | Trigger " + str.tostring(longTrigger, format.mintick), alert.freq_once_per_bar_close)
        lastDynAlertBar := bar_index
    else if longConfirmSignal
        alert(sym + " LONG CONFIRM | " + contract + " | Close " + str.tostring(close, format.mintick) + " | Confirm " + str.tostring(confirmLevel, format.mintick), alert.freq_once_per_bar_close)
        lastDynAlertBar := bar_index
    else if shortTriggerSignal
        alert(sym + " SHORT TRIGGER | " + contract + " | Close " + str.tostring(close, format.mintick) + " | Trigger " + str.tostring(shortTrigger, format.mintick), alert.freq_once_per_bar_close)
        lastDynAlertBar := bar_index
    else if shortConfirmSignal
        alert(sym + " SHORT CONFIRM | " + contract + " | Close " + str.tostring(close, format.mintick) + " | Confirm " + str.tostring(confirmLevel, format.mintick), alert.freq_once_per_bar_close)
        lastDynAlertBar := bar_index
    else if invalidSignal
        alert(sym + " INVALIDATION | " + contract + " | Close " + str.tostring(close, format.mintick) + " | Invalid " + str.tostring(invalidLevel, format.mintick), alert.freq_once_per_bar_close)
        lastDynAlertBar := bar_index
    else if target1Hit
        alert(sym + " TARGET 1 HIT | " + contract + " | T1 " + str.tostring(target1, format.mintick), alert.freq_once_per_bar_close)
        lastDynAlertBar := bar_index
    else if target2Hit
        alert(sym + " TARGET 2 HIT | " + contract + " | T2 " + str.tostring(target2, format.mintick), alert.freq_once_per_bar_close)
        lastDynAlertBar := bar_index
    else if target3Hit
        alert(sym + " TARGET 3 HIT | " + contract + " | T3 " + str.tostring(target3, format.mintick), alert.freq_once_per_bar_close)
        lastDynAlertBar := bar_index
    else if anyLevelTouch
        alert(sym + " LEVEL TOUCH | Check right-side GEX/setup labels | Close " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
        lastDynAlertBar := bar_index


// ======================================================
// SIGNAL LABELS
// ======================================================

if showSignalLabels and longTriggerSignal
    label.new(bar_index, low, "LONG\nTRIGGER", style = label.style_label_up, color = cTrigger, textcolor = color.white, size = size.small)

if showSignalLabels and longConfirmSignal
    label.new(bar_index, low, "LONG\nCONFIRM", style = label.style_label_up, color = cGexPos, textcolor = color.white, size = size.small)

if showSignalLabels and shortTriggerSignal
    label.new(bar_index, high, "PUT\nTRIGGER", style = label.style_label_down, color = cInvalid, textcolor = color.white, size = size.small)

if showSignalLabels and shortConfirmSignal
    label.new(bar_index, high, "PUT\nCONFIRM", style = label.style_label_down, color = cGexNeg, textcolor = color.white, size = size.small)

if showSignalLabels and invalidSignal
    label.new(bar_index, close, "INVALID", style = label.style_label_left, color = cInvalid, textcolor = color.white, size = size.small)

if showSignalLabels and target1Hit
    label.new(bar_index, close, "T1", style = label.style_label_left, color = cTarget, textcolor = color.white, size = size.small)

if showSignalLabels and target2Hit
    label.new(bar_index, close, "T2", style = label.style_label_left, color = cTarget, textcolor = color.white, size = size.small)

if showSignalLabels and target3Hit
    label.new(bar_index, close, "T3", style = label.style_label_left, color = cTarget, textcolor = color.white, size = size.small)


// ======================================================
// DRAW LEVELS + OR
// ======================================================

if barstate.islast
    f_clearObjects()

    if showLevels and setupActive
        int n = array.size(lvlPrice)
        if n > 0
            for i = 0 to n - 1
                f_drawLevel(array.get(lvlPrice, i), array.get(lvlName, i), array.get(lvlRole, i), i)

    if showOR and isRTH and not na(orHigh) and not na(orLow)
        f_drawLevel(orHigh, "OR HIGH", "OR", array.size(lvlPrice) + 1)
        f_drawLevel(orLow, "OR LOW", "OR", array.size(lvlPrice) + 2)


// ======================================================
// DASHBOARD
// ======================================================

var table dash = table.new(f_dashPos(dashPosOpt), 3, 16, frame_color = color.black, frame_width = 1, border_color = color.rgb(120, 120, 120), border_width = 1)

f_cell(int c, int r, string txt, color bg, color tx) =>
    table.cell(dash, c, r, txt, bgcolor = bg, text_color = tx, text_size = f_txtSize(dashSizeOpt))

string dirText = setupDir == 1 ? "LONG CALLS" : setupDir == -1 ? "LONG PUTS" : "N/A"
string entryText = not na(entryLo) and not na(entryHi) ? str.tostring(entryLo, format.mintick) + " - " + str.tostring(entryHi, format.mintick) : "N/A"
string triggerText = setupDir == 1 ? str.tostring(longTrigger, format.mintick) : setupDir == -1 ? str.tostring(shortTrigger, format.mintick) : "N/A"
string targetsText = not na(target1) ? str.tostring(target1, format.mintick) + " / " + str.tostring(target2, format.mintick) + (not na(target3) ? " / " + str.tostring(target3, format.mintick) : "") : "N/A"
string invalidText = not na(invalidLevel) ? str.tostring(invalidLevel, format.mintick) + (not na(hardInvalid) ? " | hard " + str.tostring(hardInvalid, format.mintick) : "") : "N/A"

string filterText = setupDir == 1 ? 
     (longFilterOk ? "PASS" : "WAIT") :
     setupDir == -1 ?
     (shortFilterOk ? "PASS" : "WAIT") :
     "N/A"

string orText = not na(orHigh) and not na(orLow) ? "H " + str.tostring(orHigh, format.mintick) + " | L " + str.tostring(orLow, format.mintick) : "Building"

string signalState = "NO MAP"
color signalBg = color.rgb(210, 210, 210)

if setupActive
    if invalidSignal or hardInvalidSignal
        signalState := "INVALID"
        signalBg := cInvalid
    else if target3Hit
        signalState := "TARGET 3 HIT"
        signalBg := cTarget
    else if target2Hit
        signalState := "TARGET 2 HIT"
        signalBg := cTarget
    else if target1Hit
        signalState := "TARGET 1 HIT"
        signalBg := cTarget
    else if setupDir == 1 and close >= confirmLevel
        signalState := "LONG CONFIRMED"
        signalBg := cGexPos
    else if setupDir == 1 and close >= longTrigger
        signalState := "LONG TRIGGERED"
        signalBg := cTrigger
    else if setupDir == -1 and close <= confirmLevel
        signalState := "PUT CONFIRMED"
        signalBg := cGexNeg
    else if setupDir == -1 and close <= shortTrigger
        signalState := "PUT TRIGGERED"
        signalBg := cTrigger
    else
        signalState := "WAIT FOR TRIGGER"
        signalBg := color.rgb(235, 235, 235)

if barstate.islast and showDashboard
    color headerBg = color.rgb(0, 0, 0)
    color headerTx = color.white
    color rowA = color.rgb(255, 255, 255)
    color rowB = color.rgb(238, 238, 238)
    color keyBg = color.rgb(225, 225, 225)
    color black = color.rgb(0, 0, 0)

    f_cell(0, 0, "BullFlow 5/13 PRO", headerBg, headerTx)
    f_cell(1, 0, setupActive ? sym : "UNMAPPED", headerBg, headerTx)
    f_cell(2, 0, setupActive ? "Rank " + setupRank : "No setup", headerBg, headerTx)

    f_cell(0, 1, "Bias", keyBg, black)
    f_cell(1, 1, dirText, rowA, black)
    f_cell(2, 1, setupGrade, rowA, black)

    f_cell(0, 2, "Category", keyBg, black)
    f_cell(1, 2, setupCategory, rowB, black)
    f_cell(2, 2, setupBias, rowB, black)

    f_cell(0, 3, "Primary", keyBg, black)
    f_cell(1, 3, contract, rowA, black)
    f_cell(2, 3, secondaryContract, rowA, black)

    f_cell(0, 4, "Entry", keyBg, black)
    f_cell(1, 4, entryText, rowB, black)
    f_cell(2, 4, "No open chase", rowB, black)

    f_cell(0, 5, "Trigger", keyBg, black)
    f_cell(1, 5, triggerText, rowA, black)
    f_cell(2, 5, "Confirm " + str.tostring(confirmLevel, format.mintick), rowA, black)

    f_cell(0, 6, "Invalid", keyBg, black)
    f_cell(1, 6, invalidText, rowB, black)
    f_cell(2, 6, "Close basis", rowB, black)

    f_cell(0, 7, "Targets", keyBg, black)
    f_cell(1, 7, targetsText, rowA, black)
    f_cell(2, 7, setupDir == 1 ? "Scale into strength" : "Cover into flush", rowA, black)

    f_cell(0, 8, "GEX Read", keyBg, black)
    f_cell(1, 8, gexRead, rowB, black)
    f_cell(2, 8, "Levels plotted", rowB, black)

    f_cell(0, 9, "VWAP / EMA", keyBg, black)
    f_cell(1, 9, filterText, filterText == "PASS" ? color.rgb(210, 245, 215) : color.rgb(255, 235, 190), black)
    f_cell(2, 9, "RVOL " + str.tostring(rvol, "#.##"), rowA, black)

    f_cell(0, 10, "Opening Range", keyBg, black)
    f_cell(1, 10, orText, rowB, black)
    f_cell(2, 10, withinOpeningRange ? "Building" : "Set", rowB, black)

    f_cell(0, 11, "Signal State", keyBg, black)
    f_cell(1, 11, signalState, signalBg, signalBg == color.rgb(235, 235, 235) ? black : color.white)
    f_cell(2, 11, setupActive ? "Active map" : "No map", setupActive ? rowA : color.rgb(255, 210, 210), black)

    f_cell(0, 12, "Setup Note", keyBg, black)
    f_cell(1, 12, setupNote, rowB, black)
    f_cell(2, 12, "", rowB, black)

    f_cell(0, 13, "Execution", keyBg, black)
    f_cell(1, 13, executionRule, rowA, black)
    f_cell(2, 13, "", rowA, black)

    f_cell(0, 14, "Alerts", keyBg, black)
    f_cell(1, 14, "Trigger / Confirm / Invalid / Targets", rowB, black)
    f_cell(2, 14, "Level 01-12", rowB, black)

    f_cell(0, 15, "Watchlist", keyBg, black)
    f_cell(1, 15, "FCEL DKNG GS BA TSLA", rowA, black)
    f_cell(2, 15, "SOXL MARA LRCX MU SNOW", rowA, black)
````
