# Bullish Duo Tracker - FriMon + WedThu + BIAS - PREMIUM

- url: https://www.tradingview.com/script/vaDrToPM/
- type: indicator
- pine_id: PUB;ded1c273ede74830a61fb5a63544fcb3
- version: 1.0

## Description

Title for Publishing:
Bullish Duo Tracker - FriMon + WedThu + BIAS [77% WR] | Best for SPY, QQQ & ETFs

Full Description:

🔥 BULLISH DUO TRACKER - PREMIUM | The 2 Most Bullish Days of The Week
Tired of guessing the daily bias? This indicator does the work for you.

After analyzing thousands of setups on SPY, QQQ, MAGS, XLK, XLE, XLRE, XLV and all major sector ETFs, I found two repeating bullish patterns with a 70%+ statistical edge. This indicator tracks them live, shows you the exact levels, and gives you a real-time BIAS.

No repaint. No guessing. Pure price action statistics.

PROVEN STATS (Real chart data from this indicator):

MAGS: 181 Setups | 77.35% Combined WR (81.48% on Fri-Mon)
SPY: 1735 Setups | 72.74% Combined WR
QQQ: 1433 Setups | 73.55% Combined WR (75.52% on Fri-Mon)
Works amazing on: SPY, QQQ, DIA, IWM, XLK (Chips/Tech), XLE (Energy), XLRE (Real Estate), XLV (Defensive), XLF, SMH, MAGS
This is not a 100% holy grail. It's a powerful statistical bias that puts probability in your favor when trading indices.

💡 HOW IT WORKS - The 2 Trackers
1. Fri-Mon Tracker (Top Right Table - Blue)
The classic weekly momentum play.
Logic: IF Friday's High > Thursday's High -> Monday = Bullish Setup
Win Condition: Monday hits Friday's High OR closes Green (Close > Open).
Why it works? Institutions push higher into the weekend. If Friday takes out Thursday, Monday continuation is highly probable.

2. Wed-Thu Tracker (Middle Right Table - Yellow)
The mid-week power play.
Logic: IF Wednesday's High > Monday's High -> Thursday = Bullish Setup
Win Condition: Thursday hits Wednesday's High OR closes Green.
Why it works? Early week strength (Mon) + mid-week breakout (Wed) = Thursday follow-through. Perfect for 0DTE.

3. TOTAL COMBINED (Bottom Right Table - Purple)
Your overall edge. Shows total setups and combined win rate for complete transparency.

🎯 TODAY'S BIAS PANEL & HOW TO TRADE IT
The indicator tells you exactly what to expect. No active setup = NEUTRAL.

3 Ways To Trade The BIAS:

Option A: The Aggressive Breakout (Scalper)
Best for: Day Traders, 0DTE Options
When BIAS is BULLISH, wait for a break and hold above the dashed level (FRI High or WED High). Target: Next resistance / 1-2R. Stop: Below the day's low or recent box.
Visual: Enter when price hits FRI: 772.28 or WED: 769.41

Option B: The Conservative Green Close (High WR)
Best for: Higher win rate, less stress
Don't chase the breakout. Just align with the bias. If BIAS is bullish, only take long positions on Monday/Thursday and expect a green close. You can take partials at the high and hold for the close.

Option C: The BIAS Filter (For Your Existing Strategy)
Best for: Any trader
Use this as a filter. Only take your long setups (VWAP bounce, ORB, EMA pullback) when TODAY BIAS is BULLISH. Skip long trades on NEUTRAL days. This alone will boost your win rate dramatically on indices.

⚙️ SETTINGS EXPLAINED
TRACKERS Group:

Show Fri-Mon Tracker / Show Wed-Thu Tracker: Enable/disable each system. You can trade only Fri-Mon if you only trade Mondays.
TABLES - DISPLAY ON RIGHT:

Show Table - Fri-Mon (Top Right): Blue table
Show Table - Wed-Thu (Middle Right): Yellow table
Show Table - TOTAL Combined (Bottom Right): Purple table - your total edge
Show Today BIAS Panel: The label that says TODAY: BULLISH... or NEUTRAL
Show Green/Red Background: Paints Monday/Thursday background GREEN when winning (Hit High OR Green) and RED when not. Instant visual feedback.
VISUALS - PREMIUM:

Enable Premium Boxes & Levels: Draws the premium high boxes and dotted breakout levels
Thu High / Fri High / Mon High / Wed High: Customize colors for perfect chart clarity
Win Border / Loss Border: Colors for the WR tables
📈 WHY IT'S PERFECT FOR INDICES & ETFs
Indices and big ETFs have strong institutional weekly cycles. Unlike random small caps, SPY, QQQ, MAGS, and sector ETFs like XLE, XLRE respect weekly highs. This is not a pattern for forex or low-volume stocks - it was built for and tested on the biggest ETFs in the market.

Best Timeframe: 1D, but use it to set bias on 5m / 15m / 1H for entries.

If you find this useful, please Like, Comment, and Follow for more high-WR statistical tools. Your support keeps these premium indicators free!

Disclaimer: This is for educational purposes only. Past performance with 70%+ win rate does not guarantee future results. Always use proper risk management. This is not financial advice.

Tags: #SPY #QQQ #DayTrading #Indices #StatisticalEdge #MAGS #ETFs

[image]https://www.tradingview.com/x/L3T9YBHG/[/image][image]https://www.tradingview.com/x/4do9yLmL/[/image]

## Source Code

````pine
// @version=6
indicator("Bullish Duo Tracker - FriMon + WedThu + BIAS - PREMIUM", shorttitle="Bullish Duo Tracker PREMIUM V6", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// TRACKERS
groupTrack = "TRACKERS"
showFriMon = input.bool(true, "Show Fri-Mon Tracker", group=groupTrack)
showWedThu = input.bool(true, "Show Wed-Thu Tracker", group=groupTrack)

// TABLES - ALL ON RIGHT SIDE
groupTables = "TABLES - DISPLAY ON RIGHT"
showTableFM = input.bool(true, "Show Table - Fri-Mon (Top Right)", group=groupTables)
showTableWT = input.bool(true, "Show Table - Wed-Thu (Middle Right)", group=groupTables)
showTableCombined = input.bool(true, "Show Table - TOTAL Combined (Bottom Right)", group=groupTables)
showBiasPanel = input.bool(true, "Show Today BIAS Panel", group=groupTables)
showBg = input.bool(true, "Show Green/Red Background (Community Visual)", group=groupTables)

// VISUALS
groupVis = "VISUALS - PREMIUM"
enablePremiumVisuals = input.bool(true, "Enable Premium Boxes & Levels", group=groupVis)
thuColor = input.color(#2962FF, "Thu High", group=groupVis)
friColor = input.color(#FFD60A, "Fri High", group=groupVis)
monColor = input.color(#2962FF, "Mon High (for WedThu)", group=groupVis)
wedColor = input.color(#FFD60A, "Wed High", group=groupVis)
winBorder = input.color(#089981, "Win Border", group=groupVis)
lossBorder = input.color(#F23645, "Loss Border", group=groupVis)

d_high = request.security(syminfo.tickerid, "D", high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
d_close = request.security(syminfo.tickerid, "D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
d_open = request.security(syminfo.tickerid, "D", open, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

var float today_h = na
var float thur_h = na
var float fri_h = na
var float mon_open = na
var int setupsFM = 0
var int winsFM = 0
var bool activeFM = false
var float mon_h = na
var float wed_h = na
var float thu_open = na
var int setupsWT = 0
var int winsWT = 0
var bool activeWT = false

var box thuBox = na, var box friBox = na, var box monHighBox = na, var box wedBox = na
var line friLevel = na, var line wedLevel = na
var label thuLab = na, var label friLab = na, var label monHighLab = na, var label wedLab = na
var label biasLabel = na

new_day = ta.change(time("D"))!= 0

if new_day
    prev = dayofweek[1]
    if prev == dayofweek.monday and activeFM
        if (today_h >= fri_h) or (close[1] > mon_open)
            winsFM += 1
    if prev == dayofweek.thursday and activeWT
        if (today_h >= wed_h) or (close[1] > thu_open)
            winsWT += 1
    if prev == dayofweek.thursday
        thur_h := today_h
    if prev == dayofweek.friday
        fri_h := today_h
    if prev == dayofweek.monday
        mon_h := today_h
    if prev == dayofweek.wednesday
        wed_h := today_h
    if dayofweek == dayofweek.tuesday
        thur_h := na
        fri_h := na
    if dayofweek == dayofweek.monday or dayofweek == dayofweek.sunday
        mon_h := na
        wed_h := na
        activeWT := false
    if dayofweek == dayofweek.monday
        mon_open := open
        if not na(thur_h) and not na(fri_h) and fri_h > thur_h
            activeFM := true
            setupsFM += 1
        else
            activeFM := false
    if dayofweek == dayofweek.thursday
        thu_open := open
        if not na(mon_h) and not na(wed_h) and wed_h > mon_h
            activeWT := true
            setupsWT += 1
        else
            activeWT := false
    today_h := high
else
    today_h := na(today_h)? high : math.max(today_h, high)

// Green/Red Background - Community Visual
color bg = na
if dayofweek == dayofweek.monday and activeFM and showFriMon
    bg := (d_high >= fri_h) or (d_close > d_open)? color.new(color.green, 85) : color.new(color.red, 85)
if dayofweek == dayofweek.thursday and activeWT and showWedThu
    bg := (d_high >= wed_h) or (d_close > d_open)? color.new(color.green, 85) : color.new(color.red, 85)
bgcolor(showBg? bg : na, title="Green/Red Background")

// Premium Boxes
if enablePremiumVisuals and showFriMon and new_day and dayofweek[1] == dayofweek.thursday
    if not na(thuBox)
        box.delete(thuBox)
        label.delete(thuLab)
    thuBox := box.new(left=bar_index-1, top=thur_h, right=bar_index+15, bottom=thur_h - syminfo.mintick*10, xloc=xloc.bar_index, bgcolor=color.new(thuColor,85), border_color=thuColor, border_width=2)
    thuLab := label.new(x=bar_index, y=thur_h, text="THU: " + str.tostring(thur_h, format.mintick), style=label.style_label_left, color=color.new(thuColor,0), textcolor=color.white, size=size.tiny)

if enablePremiumVisuals and showFriMon and new_day and dayofweek[1] == dayofweek.friday
    if not na(friBox)
        box.delete(friBox)
        label.delete(friLab)
        line.delete(friLevel)
    friBox := box.new(left=bar_index-1, top=fri_h, right=bar_index+15, bottom=fri_h - syminfo.mintick*10, xloc=xloc.bar_index, bgcolor=color.new(friColor,88), border_color=friColor, border_style=line.style_dashed)
    friLevel := line.new(x1=bar_index-1, y1=fri_h, x2=bar_index+20, y2=fri_h, xloc=xloc.bar_index, color=friColor, style=line.style_dotted, width=2)
    friLab := label.new(x=bar_index, y=fri_h, text="FRI: " + str.tostring(fri_h, format.mintick), style=label.style_label_left, color=color.new(friColor,0), textcolor=color.black, size=size.tiny)

if enablePremiumVisuals and showWedThu and new_day and dayofweek[1] == dayofweek.monday
    if not na(monHighBox)
        box.delete(monHighBox)
        label.delete(monHighLab)
    monHighBox := box.new(left=bar_index-1, top=mon_h, right=bar_index+15, bottom=mon_h - syminfo.mintick*10, xloc=xloc.bar_index, bgcolor=color.new(monColor,85), border_color=monColor)
    monHighLab := label.new(x=bar_index, y=mon_h, text="MON: " + str.tostring(mon_h, format.mintick), style=label.style_label_left, color=color.new(monColor,0), textcolor=color.white, size=size.tiny)

if enablePremiumVisuals and showWedThu and new_day and dayofweek[1] == dayofweek.wednesday
    if not na(wedBox)
        box.delete(wedBox)
        label.delete(wedLab)
        line.delete(wedLevel)
    wedBox := box.new(left=bar_index-1, top=wed_h, right=bar_index+15, bottom=wed_h - syminfo.mintick*10, xloc=xloc.bar_index, bgcolor=color.new(wedColor,88), border_color=wedColor, border_style=line.style_dashed)
    wedLevel := line.new(x1=bar_index-1, y1=wed_h, x2=bar_index+20, y2=wed_h, xloc=xloc.bar_index, color=wedColor, style=line.style_dotted, width=2)
    wedLab := label.new(x=bar_index, y=wed_h, text="WED: " + str.tostring(wed_h, format.mintick), style=label.style_label_left, color=color.new(wedColor,0), textcolor=color.black, size=size.tiny)

// TABLES - RIGHT SIDE STACKED - V6 READY
var table tableFM = na
var table tableWT = na
var table tableCombined = na

if barstate.islast
    if not na(tableFM)
        table.delete(tableFM)
    if not na(tableWT)
        table.delete(tableWT)
    if not na(tableCombined)
        table.delete(tableCombined)

    if showTableFM and showFriMon
        tableFM := table.new(position.top_right, 2, 3, border_width=1)
        float wrFM = setupsFM > 0? winsFM / setupsFM * 100 : 0
        table.cell(tableFM, 0, 0, "Fri-Mon Setups", bgcolor=#2962FF, text_color=color.white)
        table.cell(tableFM, 1, 0, str.tostring(setupsFM), bgcolor=color.black, text_color=color.white)
        table.cell(tableFM, 0, 1, "Wins", bgcolor=#2962FF, text_color=color.white)
        table.cell(tableFM, 1, 1, str.tostring(winsFM), bgcolor=color.black, text_color=color.white)
        table.cell(tableFM, 0, 2, "Win Rate", bgcolor=#2962FF, text_color=color.white)
        table.cell(tableFM, 1, 2, str.tostring(math.round(wrFM, 2)) + "%", bgcolor=wrFM >= 50? color.new(winBorder, 20) : color.new(lossBorder, 20), text_color=color.white)

    if showTableWT and showWedThu
        tableWT := table.new(position.middle_right, 2, 3, border_width=1)
        float wrWT = setupsWT > 0? winsWT / setupsWT * 100 : 0
        table.cell(tableWT, 0, 0, "Wed-Thu Setups", bgcolor=#FFD60A, text_color=color.black)
        table.cell(tableWT, 1, 0, str.tostring(setupsWT), bgcolor=color.black, text_color=color.white)
        table.cell(tableWT, 0, 1, "Wins", bgcolor=#FFD60A, text_color=color.black)
        table.cell(tableWT, 1, 1, str.tostring(winsWT), bgcolor=color.black, text_color=color.white)
        table.cell(tableWT, 0, 2, "Win Rate", bgcolor=#FFD60A, text_color=color.black)
        table.cell(tableWT, 1, 2, str.tostring(math.round(wrWT, 2)) + "%", bgcolor=wrWT >= 50? color.new(winBorder, 20) : color.new(lossBorder, 20), text_color=color.white)

    if showTableCombined
        tableCombined := table.new(position.bottom_right, 2, 3, border_width=2)
        int totalSetups = setupsFM + setupsWT
        int totalWins = winsFM + winsWT
        float wrTot = totalSetups > 0? totalWins / totalSetups * 100 : 0
        table.cell(tableCombined, 0, 0, "TOTAL Setups", bgcolor=color.new(color.purple, 0), text_color=color.white)
        table.cell(tableCombined, 1, 0, str.tostring(totalSetups), bgcolor=color.black, text_color=color.white)
        table.cell(tableCombined, 0, 1, "TOTAL Wins", bgcolor=color.new(color.purple, 0), text_color=color.white)
        table.cell(tableCombined, 1, 1, str.tostring(totalWins), bgcolor=color.black, text_color=color.white)
        table.cell(tableCombined, 0, 2, "COMBINED WR", bgcolor=color.new(color.purple, 0), text_color=color.white)
        table.cell(tableCombined, 1, 2, str.tostring(math.round(wrTot, 2)) + "%", bgcolor=wrTot >= 50? color.new(winBorder, 0) : color.new(lossBorder, 0), text_color=color.white)

// BIAS PANEL
if showBiasPanel
    string biasText = "TODAY: NEUTRAL - No Active Setup"
    color biasCol = color.gray
    if dayofweek == dayofweek.monday and activeFM and showFriMon
        float wr = setupsFM > 0? winsFM / setupsFM * 100 : 0
        biasText := "TODAY BIAS: BULLISH Fri-Mon (" + str.tostring(math.round(wr, 1)) + "% WR) | Expect: Hit Fri High " + str.tostring(fri_h, format.mintick) + " OR Green Close"
        biasCol := winBorder
    if dayofweek == dayofweek.thursday and activeWT and showWedThu
        float wr = setupsWT > 0? winsWT / setupsWT * 100 : 0
        biasText := "TODAY BIAS: BULLISH Wed-Thu (" + str.tostring(math.round(wr, 1)) + "% WR) | Expect: Hit Wed High " + str.tostring(wed_h, format.mintick) + " OR Green Close"
        biasCol := winBorder
    if not na(biasLabel)
        label.delete(biasLabel)
    biasLabel := label.new(x=bar_index, y=low, text=biasText, style=label.style_label_up, color=color.new(biasCol, 0), textcolor=color.white, size=size.small)
````
