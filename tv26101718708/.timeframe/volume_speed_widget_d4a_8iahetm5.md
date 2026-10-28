# Volume Speed Widget [D4A]

- url: https://www.tradingview.com/script/8IahEtM5-Volume-Speed-Widget-D4A/
- type: indicator
- pine_id: PUB;88857f345ad247d69b5ba23f208c7692
- version: 1.0

## Description

[b]INTRODUCTION[/b]

This is a fork of popular Trading View script made by [url=https://www.tradingview.com/script/ZMdZlGaJ-Volume-Speed-By-MUQWISHI/]MUQWISHI[/url].

This version offers several changes and new additions which are not available in original script.
Key changes:
- smaller widget size, which makes it more convenient for smaller screens and resolutions (laptop or smartphone), main reason for this fork
- toned down the graphics to make it less distracting
- toned down the flash effect (can be turned off as well)
- Speed Volume (AVG) which is probably the most useful part of the widget has background color changing with increasing or decreasing speed
- added Relative Speed (REL) which is more meaningful metrics (able to compare speeds across different assets)
- added 2 types of CVD (cumulative volume delta) to help gauge market short-time volume trend. 
- CVD background color changes depending on positive or negative value (3 CVD display modes are available) 
- When large orders are displayed, along with their numerical values there are also direction colored circles displayed
- Small rectangle markers are added to indicate increasing or decreasing values throughout the available metrics
- Volume can be displayed as % of total instead of only raw value

[b]The Purpose of the script[/b], as per original author:
The “Volume Dynamic Scale Bar” is a method for determining the dominance of volume flow over a selected length and timeframe, indicating whether buyers or sellers are in control. In addition, it detects the average speed of volume flow over a specified period

[b]Who is this script for?[/b]
- short term traders who want to use more accurate volume data when making trading decision, eg. scalpers, day traders
- best used on 1m or 5m charts
- this script can help when deciding to enter or exit position, eg. volume speed increase may indicate institutional participation and volume decrease may indicate low interest from major players

[b]IMPORTANT[/b]
To use full potential of the script, you need the following:
- access to 1 second volume chart data which is available through Trading view subscription plans (Premium, Ultimate), 30 days free trial is available (no TV relationship, just friendly advice)
- trade an asset with real volume data through dependable broker (often additional paid option), or through a prop firm account (paid option as well)

If you don't have the above you can still use the script in a limited way, eg. on 5m or higher timeframe using 1m as your lower timeframe source of volume data.

[b]SETTINGS[/b]
- Lower Timeframe - the timeframe from which volume data is pulled from, recommended 1 second (if you have access)
- Length - how much data is pulled at once (also used for LTF CVD computation)
- Widget location - location of the widget on the chart
- Size - the size of text in the majority of values displayed (apart from Speed, which has separate variable)
- Volume Up / Down - main colors for positive and negative volume
- Accent - additional colors used for various indicators in the widget
- Background & Text - background and text colors respectively
- AVG Vol. Threshold and BG Color Dials - thresholds and corresponding colors are provided to customize Speed display
- Text - text size variable for Speed AVG and REL
- Volume Speed Multipliers - multipliers for various markets to customize displayed raw Speed values so they are meaningful to the trader
- Enable Relative Speed - useful to see what's the ratio of current raw speed to average speed over the Baseline Period
- Baseline Period - choose which period should be used to calculate relative volume speed
- Make the Volume Scale Bar Spaced - toggles different version of volume bar display 
- Display Volume as Percent of Total - display percent instead of raw number
- Enable 3-Second Flash When Volume is Greater Than Average by X Times - when enabled, the widget "flashes" when large orders are discovered
- Enable CVD (Cumulative Volume Delta) - enables display of chart CVD and LTF CVD
- Cumulation Type - three methods of calculating CVD are provided: SUM, EMA (default) and SMA
- Length - how many chart bars are used to calculate chart CVD
- CVD Source - which CVD type to display in the widget
- CVD BG Color Based On - which CVD should the background color of CVD (bottom row) be based on (LTF or chart)

Default settings of the script have been tuned using the asset of MNQ1! and dark theme in TV. You may tune the widget accordingly to your asset and preferred color scheme.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dub4art

//@version=6
indicator("Volume Speed Widget", "VolSpeedT", overlay = true)

var g_VS1 = "Volume Speed Widget"
manual_tf = input.timeframe("1S", "Lower Timeframe", inline = 'ltf1', group = g_VS1, display = display.none,  tooltip = "Note:\nIf the selected timeframe is invalid (higher than chart), the indicator will automatically switch to 1 second.")
rowLen = input.int(60, "    Length", 1, 300, inline = 'ltf1', group = g_VS1, display = display.none) + 2
pltPos = input.string("Bottom Right", "Widget Location",  ["Top Right" , "Middle Right"  , "Bottom Right" , "Top Center" , "Bottom Center" , "Bottom Left" ], inline = "0", group = g_VS1, display = display.none)
pltSiz = input.int(10, "    Size", 0, inline = "0", group = g_VS1, display = display.none)
upXCC = input.color(#335D26 , "Volume Up / Down", group = g_VS1, inline = "1")
dnXCC = input.color(color.maroon, "", group = g_VS1, inline = "1")
upACol = input.color(color.green , "Accent", group = g_VS1, inline = "3")
dnACol = input.color(#E71A64 , "", group = g_VS1, inline = "3")
tBgCol = input.color(color.new(#000000,100), "    Background", group = g_VS1, inline = "3", display = display.none)
tTxCol = input.color(#ffffff, "    Text", group = g_VS1, inline = "3", display = display.none)

vs_size = input.int(12, "AVG Vol. Speed Threshold and BG Color Dials    Text", group=g_VS1)
thr1 = input.int(20, "    Parking Speed <", 0, inline = 'lvl1', group = g_VS1)
col1 = input.color(color.new(color.gray, 80), '    BG', inline = 'lvl1', group = g_VS1) // low transparent
thr2 = input.int(20, "    City Speed >=", 0, inline = 'lvl2', group = g_VS1)
col2 = input.color(color.new(color.green, 70), '    BG', inline = 'lvl2', group = g_VS1) // normal green
thr3 = input.int(60, "    Country Speed >=", 0, inline = 'lvl3', group = g_VS1)
col3 = input.color(color.new(color.orange, 70), '    BG', inline = 'lvl3', group = g_VS1) // high red
thr4 = input.int(100, "    Highway Speed >=", 0, inline = 'lvl4', group = g_VS1)
col4 = input.color(color.new(color.red, 70), '    BG', inline = 'lvl4', group = g_VS1) // high orange
thr5 = input.int(200, "    Racing Speed >=", 0, inline = 'lvl5', group = g_VS1)
col5 = input.color(color.new(color.fuchsia, 70), '    BG', inline = 'lvl5', group = g_VS1, tooltip = "All Speeds in units/LTF, eg. 20 units/s or 20 units/5s, depending on selected LTF")
mCommod = input.float(10, "Volume Speed Multipliers:        Commodities", minval = 0, inline = "vsm1", group = g_VS1, tooltip = "Multipliers can be used to help customize displayed raw Speed reaadings and dial colors for specific asset type")
mCrypto = input.int(1000, "    Crypto", minval = 0, inline = "vsm2", group = g_VS1)
mForex = input.int(10, "    Forex", minval = 0, inline = "vsm2", group = g_VS1)
mFutures = input.int(1, "    Futures", minval = 0, inline = "vsm3", group = g_VS1)
mStocks = input.int(1, "    Stocks", minval = 0, inline = "vsm3", group = g_VS1)

relSpdOn = input.bool(false, "Enable Relative Speed (REL)", inline = 'relspeed', group=g_VS1, tooltip = "Displays current AVG Speed as a ratio of this asset's own baseline speed over a longer reference period (eg. 5m, 1h, 1D).\n\n1 = trading at its usual pace for that period.\n1.5 = trading 50% faster than usual.\n0.5  = trading at half the usual pace.\n\nBecause it's a self-relative ratio rather than a raw units/second value, it can be compared across different assets, unlike raw speed which depends heavily on each instrument's typical volume.")
relSpdTF = input.timeframe("60", "    Baseline Period", inline = 'relspeed', group=g_VS1, tooltip = "Reference timeframe used to compute this asset's normal speed baseline. Pick a period long enough to be a stable average, eg. 5m, 1h or 1D.\n\nNote: must be higher than the chart timeframe. If it isn't, the chart's own timeframe is used instead.")
space = input.bool(false, "Make The Volume Scale Bar Spaced",    group = g_VS1)
percen = input.bool(true, "Display Volume as Percent of Total",    group = g_VS1)

cFlsh = input.bool(true, "Enable a 3-Second Flash When Volume Is", group = g_VS1) // Flash
vFlsh = input.float(3,   "       Greater Than Average by X Times", 1, 100, inline = "5", display = display.none, group = g_VS1, 
         tooltip = "For Example:\nFlashes when selected timeframe volume is...\n   2 (Double the average volume)." +
                   "\n   3 (Triple the average volume).\n   8 (8 Times the average volume).\n   and so...")

chartCVD = input.bool(true, "Enable CVD (Cumulative Volume Delta)", group=g_VS1, tooltip = "This enables two types of CVD:\n\nChart CVD - longer time span - data taken from chart timeframe, eg. 50 * 1m candles\n\nLTF CVD - shorter time span - data taken from intrabar lower timeframe candles, eg. 60 * 1s candles")
string cum_type = input.string("EMA", "Cumulation Type", inline = 'cvd1', group=g_VS1, options = ["SUM", "EMA", "SMA"], tooltip="Chart CVD is calculated using chart timeframe data over a period specified by Length parameter")
var cum_length = input.int(50, "    Length", inline = 'cvd1', group=g_VS1, minval=1)
cvdSource = input.string("Both", "CVD Source", options=["Chart TF", "LTF", "Both"], inline = 'norm2', group=g_VS1, tooltip="Chart TF  — CVD from chart timeframe candle data (original).\nLTF-CVD from lower timeframe tick data (same source as Volume Speed).\nBoth - Show both values side-by-side for comparison.")
cvdBg = input.string("Chart", "CVD BG Color Based on", options=["Chart", "LTF"], inline = 'norm2', group=g_VS1)

string gmt_tz  = 'America/New_York' // timezone

type tape
    int    tim  = na 
    int    chg  = na 
    float  last = na 
    float  vol  = na 

method volIndexof(array<tape> a, x) => 
    out = -1
    for [index, value] in a
        if value.vol == x
            out := index 
            break 
    out 

// Set-Up Strings Format Based on Historical Values 
varip strFormat = array.new<string>(2, "0")

// +++++ Max Digits 
maxDig(x1, x2) => 
    str.length(x1) > str.length(x2) ? x1 : x2

// +++++ Get Price Format 
strTick(x) => 
    str.tostring(x, str.replace(str.tostring(syminfo.mintick), "1", "0"))

// +++++ Volume Format
// Number of Digits 
rDigits(x1, x2) =>
    var lft = 0, var out = "" 
    if str.contains(x2, ".")
        out := "0." 
        nLft = str.length(str.split(x2, ".").get(1))
        if nLft > lft
            lft := nLft
            for i = 1 to lft
                out += "0"

    str.length(x1) < str.length(out) ? out : x1

// Get Volume Format 
strVol(x) =>
    if x > 999999 
        str.tostring(x, format.volume) 
    else 
        volFormat = strFormat.get(1)
        str.tostring(x, volFormat)

// Get Timeframe Format
strTF(y) =>
    x   = y
    out = string(na)
    if timeframe.in_seconds(x) == timeframe.in_seconds("")
        x := timeframe.period

    if str.contains(x, "D") or str.contains(x, "W") or str.contains(x, "M") or str.contains(x, "S")
        out := str.length(x) == 1 ? "1" + x : x
    else
        out := str.tonumber(x) % 60 == 0 ? str.tostring(str.tonumber(x) / 60) + "H" : x + "min"
    out
  
// Import Data
var tf =  timeframe.in_seconds(manual_tf) > timeframe.in_seconds(timeframe.period) ? "1S" : manual_tf
[cls, tim, vol] = request.security_lower_tf(syminfo.tickerid, tf, [close, time, volume], true, ignore_invalid_timeframe = true, calc_bars_count = rowLen * 2)

var string safeRelSpdTF = timeframe.in_seconds(relSpdTF) > timeframe.in_seconds(timeframe.period) ? relSpdTF : timeframe.period
baselineVol = request.security(syminfo.tickerid, safeRelSpdTF, volume, lookahead = barmerge.lookahead_off)
baselineSecs = timeframe.in_seconds(safeRelSpdTF)
baselineSpeed = baselineSecs > 0 ? baselineVol / baselineSecs : na
 
// Stack Lower Timeframe Data
var tapeData = array.new<tape>(na)
if  vol.size() > 0 and vol.size() == cls.size()

    // Slice Variables
    sIdx = cls.size() - rowLen < 0 ? 0 : cls.size() - rowLen
    eIdx = cls.size()

    tim0 = tim.slice(sIdx, eIdx) // Time
    vol0 = vol.slice(sIdx, eIdx) // Volume
    cls0 = cls.slice(sIdx, eIdx) // Close

    // Process LTF Data 
    for i = 0 to cls0.size() - 1
        cTim = int(tim0.get(i))
        cVol = vol0.get(i)
        cCls = cls0.get(i)

        // Price Change 
        var int chg = 0
        if tapeData.size() > 0
            pCls = tapeData.get(0).last
            if pCls != cCls
                chg := (cCls - pCls)/pCls > 0 ? 1 : -1
        
        if not na(cVol) and cVol > 0
            // Add Element To "tapeData" Array
            tapeData.unshift(tape.new(cTim, chg, cCls, cVol))

            if barstate.islast
                strFormat.set(1, rDigits(strFormat.get(1), str.tostring(cVol)))

        // Remove Exceeded Elements
        while tapeData.size() > rowLen
            tapeData.pop()

// Calculate Speed
speed(x1, x2) =>
    var ltf  = strTF(tf)

    // Speed 
    varip spMin = 0.0, varip spMax = 0.0, varip spTim = timenow

    speed = barstate.isrealtime ? x1/x2 : 0

    spMin := spMin == 0 ? speed : math.min(speed, spMin)
    spMax := spMax == 0 ? speed : math.max(speed, spMax)

    // Return 
    [strVol(math.round(speed, 6)),
     strVol(math.round(spMin, 6)),
     strVol(math.round(spMax, 6)),
     str.format_time(spTim, "HH:mm:ss  yyyy-MM-dd", gmt_tz)]

// Table Location & Size
locNsze(x) => 
    y   = str.split(str.lower(x), " ")
    out = ""
    for i = 0 to y.size() - 1
        out += y.get(i)
        if i != y.size() - 1
            out += "_"
    out

// Cumulative Volume Delta logic
bullCandle = (open < close)
price_spread = math.max(high - low, syminfo.mintick)
upper_wick_length = bullCandle ? (high-close) : (high-open)
lower_wick_length = bullCandle ? (open-low) : (close-low)
body_length = price_spread - (upper_wick_length + lower_wick_length)

upper_wick_percent = (upper_wick_length / price_spread)
lower_wick_percent = (lower_wick_length / price_spread)
body_percent = (body_length / price_spread)

var effective_wick_divisor = 2 
wicks_percent = (upper_wick_percent + lower_wick_percent)
effective_wick_portion = (wicks_percent / effective_wick_divisor)
dominant_candle_portion = (body_percent + effective_wick_portion)

volume_buy  = volume * (    bullCandle ? dominant_candle_portion : effective_wick_portion)
volume_sell = volume * (not bullCandle ? dominant_candle_portion : effective_wick_portion)

volume_delta = (volume_buy - volume_sell)

volume_isBullish = (volume_delta > 0)
volume_isBearish = (volume_delta < 0)

volume_buy_cumulative_sum = math.sum(volume_buy, cum_length)
volume_buy_cumulative_ema = ta.ema(volume_buy, cum_length)
volume_buy_cumulative_sma = ta.sma(volume_buy, cum_length)
volume_sell_cumulative_sum = math.sum(volume_sell, cum_length)
volume_sell_cumulative_ema = ta.ema(volume_sell, cum_length)
volume_sell_cumulative_sma = ta.sma(volume_sell, cum_length)

volume_buy_cumulative = switch cum_type
    "SUM" => volume_buy_cumulative_sum
    "EMA" => volume_buy_cumulative_ema
    "SMA" => volume_buy_cumulative_sma
    
volume_sell_cumulative = switch cum_type
    "SUM" => volume_sell_cumulative_sum
    "EMA" => volume_sell_cumulative_ema
    "SMA" => volume_sell_cumulative_sma

volume_delta_cumulative = (volume_buy_cumulative - volume_sell_cumulative) 

volume_cumulative_isBullish = (volume_delta_cumulative > 0) 
volume_cumulative_isBearish = (volume_delta_cumulative < 0)
cvdn = volume_delta_cumulative 

cvdDir = volume_delta_cumulative > volume_delta_cumulative[1] ? "   ▲" : volume_delta_cumulative < volume_delta_cumulative[1] ? "   ▼" : na

var float ltf_buy_vol_acc  = 0.0
var float ltf_sell_vol_acc = 0.0

if barstate.islast and tapeData.size() > 0
    float b = 0.0
    float s = 0.0
    for i = 0 to tapeData.size() - 1
        el = tapeData.get(i)
        if el.chg > 0
            b += el.vol
        else if el.chg < 0
            s += el.vol
        else
            b += el.vol * 0.5
            s += el.vol * 0.5
    ltf_buy_vol_acc  := b
    ltf_sell_vol_acc := s

ltf_volume_delta = ltf_buy_vol_acc - ltf_sell_vol_acc
ltf_cvd_isBullish = ltf_volume_delta > 0
ltf_cvd_isBearish = ltf_volume_delta < 0

ltf_total_vol  = ltf_buy_vol_acc + ltf_sell_vol_acc
ltf_cvdDir     = ltf_volume_delta > ltf_volume_delta[1] ? "   ▲" : ltf_volume_delta < ltf_volume_delta[1] ? "   ▼" : na
ltf_cvdn = ltf_volume_delta

// Create Table
var table plt = na

// Get Cell Function
cell(col, row, txt, w, h, color, txtCol, tip) =>
    plt.cell(col, row, txt, w, h, txtCol, bgcolor = color, text_size = pltSiz, text_formatting = text.format_bold)
    if tip != ""
        plt.cell_set_tooltip(col, row, tip)

// Draw Table
if barstate.islast
    if tapeData.size() > 0
        plt.delete()
        plt := table.new(locNsze(pltPos), 52, 4, tBgCol, #00000000, 2, color.new(tBgCol, 100), space ? 1 : 0)

        // Coollect Up & Down Volume 
        upVol = .0
        dnVol = .0
        for i = 0 to tapeData.size() - 3
            element = tapeData.get(i)
            if element.chg > 0
                upVol += element.vol 
            else
                dnVol += element.vol 
        
        span  = (timenow - tapeData.get(-3).tim)/(1000 * timeframe.in_seconds(tf))
        smVol = upVol + dnVol
        upVolP = upVol / smVol * 100
        dnVolP = 100 - upVolP
        avVol = smVol/(tapeData.size()-2)

        // Up & Down Volumes Columns
        strFormat.set(0, maxDig(strFormat.get(0), maxDig(strVol(upVol), strVol(dnVol))))

        cell(0, 3, "+" + strFormat.get(0) + "+", 0, 0.0001, color(na), color(na),   "Total Up Volume")
        cell(51, 3, "+" + strFormat.get(0) + "+", 0, 0.0001, color(na), color(na), "Total Down Volume")

        cell(0, 1, percen ? str.tostring(upVolP, "#") + " %": strVol(upVol), 0, 0, upXCC, tTxCol, "Total Up Volume")
        cell(51, 1, percen ? str.tostring(dnVolP, "#") + " %": strVol(dnVol), 0, 0, dnXCC, tTxCol, "Total Down Volume")

        cell(0, 0, upVol > dnVol ? "▲" : na, 0, 0,  color(na), upACol, "Total Up Volume")
        cell(51, 0, dnVol > upVol ? "▼" : na, 0, 0,  color(na), dnACol, "Total Down Volume")

        // Volume Dynamic Scale Bar
        upStng = math.round(upVol/smVol * 50)
        dnStng = 50 - upStng

        var upCol = array.new<color>(100, upXCC)
        var dnCol = array.new<color>(100, dnXCC)
        for i = 0 to 49
            cell(1 + i, 0, "", 0.3, 0, color(na), color(na), "")
            cell(1 + i, 2, "", 0.3, 0, color(na), color(na), "")
            cell(1 + i, 3, "", 0.3, 0.0001, color(na), color(na), "")
            if i < upStng 
                cell(1  + i, 1, "", 0.3, 0, upCol.get(i), tTxCol,  "")
            if i < dnStng
                cell(50 - i, 1, "", 0.3, 0, dnCol.get(i), tTxCol,  "")

        // Average Speed
        [avgSp2, minSp, maxSp, timSp] = speed(smVol, span)
        plt.merge_cells(10, 0, 40, 0)
        avgSp = str.tonumber(avgSp2)
        avgSpd = syminfo.type == "crypto" ? avgSp * mCrypto : syminfo.type == "forex" ? avgSp * mForex : syminfo.type == "futures" ? avgSp * mFutures : syminfo.type == "commodities" ? avgSp * mCommod : syminfo.type == "stocks" ? avgSp * mStocks : avgSp
        avgSpInc = avgSp > avgSp[1] ? "   ▲" : na
        avgSpDec = avgSp < avgSp[1] ? "   ▼" : na
        avgSpDir = avgSp > avgSp[1] ? "   ▲" : avgSp < avgSp[1] ? "   ▼" : na
        relSpd = relSpdOn and not na(baselineSpeed) and baselineSpeed != 0 ? (avgSp / baselineSpeed) : na
        relSpdDir = na(relSpd) ? na : relSpd > relSpd[1] ? "   ▲" : relSpd < relSpd[1] ? "   ▼" : na
       
        color astxc = avgSpd >= thr5 ? col5 : avgSpd >= thr4 and avgSpd < thr5 ? col4 : avgSpd >= thr3 and avgSpd < thr4 ? col3 : avgSpd >= thr2 and avgSpd < thr3 ? col2 : col1
        string spdstr = relSpdOn ? "Speed: AVG  " + str.tostring(avgSpd, "#") + avgSpDir  + "    REL  " + str.tostring(relSpd, "#.#") + relSpdDir : "Speed AVG  " + str.tostring(avgSpd, "#") + avgSpDir
        plt.cell(10, 0, spdstr, 0, 0, bgcolor=astxc,  text_color = color.white, text_size = vs_size,  tooltip = "MAX Speed " + maxSp + "\nMIN  Speed " + minSp + "\n\n\nsince " + timSp) // bgcolor = astxc

        // Bottom Info
        plt.merge_cells(2, 2, 49, 2)
        bool show_chart_cvd = chartCVD and (cvdSource == "Chart TF" or cvdSource == "Both")
        bool show_ltf_cvd   = chartCVD and (cvdSource == "LTF"      or cvdSource == "Both")

        color cvd_color = if not chartCVD
            color.new(color.gray, 80)
        else if show_ltf_cvd and cvdBg == "LTF"
            ltf_cvd_isBullish ? color.new(upXCC, 50) : ltf_cvd_isBearish ? color.new(dnXCC, 50) : color.new(color.gray, 80)
        else if cvdBg == "Chart"
            volume_cumulative_isBullish ? color.new(upXCC, 50) : volume_cumulative_isBearish ? color.new(dnXCC, 50) : color.new(color.gray, 80)

        if barstate.isrealtime
            string cvdYes = "" // CVD portion of the status string
            if chartCVD
                if show_chart_cvd and show_ltf_cvd
                    cvdYes := "    CVD " + str.tostring(cvdn, "#.#") + cvdDir + "    CVD-L " + str.tostring(ltf_cvdn, "#.#") + ltf_cvdDir
                else if show_chart_cvd
                    cvdYes := "    CVD " + str.tostring(cvdn, "#.#") + cvdDir
                else if show_ltf_cvd
                    cvdYes := "    CVD-L " + str.tostring(ltf_cvdn, "#.#") + ltf_cvdDir
            cell(2, 2, "Vol " + strVol(smVol) + cvdYes, 0, 0, cvd_color, tTxCol, "")

            // Flash
            if cFlsh
                varip spkTim = 0.0
                varip spkDic = 0.0
                varip spkVol = 0.0
                lstVol = tapeData.get(0).vol
                if lstVol >= avVol * vFlsh
                    dir     = tapeData.get(0).chg
                    spkTim := timenow + 3000
                    spkDic := dir
                    spkVol := lstVol

                if tapeData.volIndexof(spkVol) != -1
                    if spkDic > 0
                        cell(0, 2, "◉", 0, 0, color(na), upACol, "")
                        cell(1, 2, strVol(spkVol), 0, 0, color(na), tTxCol, "Recorded - Most Recent \nUp Volume Is Graeter Than " + str.tostring(vFlsh) + " Times of the Total Average Volume")
                    if spkDic < 0
                        cell(51, 2, "◉", 0, 0, color(na), dnACol, "")
                        cell(50, 2, strVol(spkVol), 0, 0, color(na), tTxCol, "Recorded - Most Recent \nDown Volume Is Graeter Than " + str.tostring(vFlsh) + " Times of the Total Average Volume")

                if spkTim > timenow + 2000
                    plt.set_frame_color(spkDic > 0 ? color.new(upACol, 30) : color.new(dnACol, 30))
                    plt.set_bgcolor(spkDic > 0 ? color.new(upACol, 90) : color.new(dnACol, 90))
                else if spkTim > timenow + 1000
                    plt.set_frame_color(spkDic > 0 ? color.new(upACol, 30) : color.new(dnACol, 30))
                    plt.set_bgcolor(spkDic > 0 ? color.new(upACol, 90) : color.new(dnACol, 90))
                else if spkTim > timenow
                    plt.set_frame_color(spkDic > 0 ? color.new(upACol, 50) : color.new(dnACol, 50))
                    plt.set_bgcolor(spkDic > 0 ? color.new(upACol, 90) : color.new(dnACol, 90))
                else 
                    plt.set_bgcolor(tBgCol)
        else
            cell(2, 2, "⚠ This Tool Performs During Live Market", 0, 0, color(na), color.red, "")
````
