# Volume Bubbles & Trap Indicator

- url: https://www.tradingview.com/script/aTYnFy9V-Volume-Bubbles-Trap-Indicator/
- type: indicator
- pine_id: PUB;f7aea0a5439f4c8aac6d083150730f2d
- version: 3.0

## Description

█ [b]Overview: Volume Bubbles & Trap Indicator[/b] is designed to bring lower-timeframe (LTF) volume data onto the chart to identify where significant institutional effort occurred—and more importantly, when those participants are caught on the wrong side of the market. This script deconstructs the candle to find the exact price level where the maximum effort took place, plots it dynamically, and tracks whether that level holds or fails.

🧠 [b]How It Calculates:[/b]
The script operates by pulling data from a lower timeframe to analyze the micro-structure of the current candle.

Effort Calculation: It breaks down the LTF candle into three price vectors: the real body (Open to Close), the lower rejection (Low to Close), and the upper rejection (High to Close). It identifies which of these three ranges is the largest to pinpoint where buyers or sellers exerted the maximum "effort."

Volume & Weighted Average: To determine if the volume is significant for the efforts put, the script maintains a rolling array of past volume and ranges. The script uses a weighted average basis of the volume and effort to calculate the predictable trend of upcoming price.

Rankings: Based on how current volume and effort compare to historical averages, the script categorizes nodes into four tiers:

Type 3 (Major Impact): Maximum volume and maximum effort compared to history.

Type 2 (Moderate Impact): Maximum effort with volume significantly above the weighted average.

Type 1 (Minor Impact): Volume above average with moderate effort.

Type 0 (Absorption/Exhaustion): High volume with very low effort (absorption), or low volume with high effort (exhaustion / low Liquidity Spike).

🎯 The Trap: A trap occurs when a significant volume zone is established by one side (e.g., buyers pushing the price up), but the price subsequently reverses and closes below that zone's bottom boundary. This traps the breakout buyers in a losing position, often forcing them to liquidate and accelerating the reversal.

█ [b]How to Read This Indicator:[/b]
The script provides three primary visual cues on the chart:

Bubbles (Volume Impact): The size of the bubble corresponds to the ranking (Type 3 = largest, Type 1 = smallest). Green bubbles indicate bullish effort; Red indicate bearish effort. Yellow/White bubbles warn of absorption or exhaustion.

Zones (Levels): When a Type 1, 2, or 3 event occurs, a zone is drawn projecting the effort zone forward in time for a set number of bars (the "Trap Pair Window").

Trap Markers ('T'): If the price breaches and closes sustain on the wrong side of an active zone (e.g., closing below a bullish buyer box), a "T" appears inside the box to indicate the zone has failed.

🎯 [b]Pro Tip:[/b]
This indicator is most powerful when combined with Supply and Demand or Support and Resistance indicator's.

█ [b]Critical Information & Limitations:[/b]
Volume Data Dependency: This script relies entirely on volume data to calculate effort, weighted averages, and node sizes. It will not function correctly low / No volume charts.

Liquidity Impact: On highly illiquid assets, the lower timeframe data may be sparse or non-existent. This will cause erratic bubble sizing and false trap signals due to extreme spikes in relative effort. It performs best on highly liquid indices, major crypto pairs, and high-volume equities. 

█ [b]Alerts:[/b]
The script includes built-in alerts to notify you of critical volume flow shifts:

Major/Minor Buyers Trapped: Fires when the price closes below an active bullish effort zone.

Major/Minor Sellers Trapped: Fires when the price closes above an active bearish effort zone.

Major Buyers Level Tested: Fires when the price dips into (but does not necessarily break) an active bullish zone.

Major Sellers Level Tested: Fires when the price rallies into (but does not necessarily break) an active bearish zone.

█ [b]Trend Candles:[/b]

In addition to the localized trap zones and bubbles, the indicator overlays custom Trend Candles.

How to Read Them:

[b]Green Candles:[/b] Indicate that the net Cumulative Volume Weighted Delta (CVWD) flow is currently positive (bullish buying pressure is dominant).

[b]Red Candles:[/b] Indicate that the net Cumulative Volume Weighted Delta (CVWD) is negative (bearish selling pressure is in control).

█ [b]Disclaimer
Not Financial Advice:[/b] This Pine Script indicator is provided for educational and analytical purposes only. Trading financial markets involves significant risk of loss and is not suitable for all investors. Past performance of any trading system or methodology is not indicative of future results. Always use proper risk management, test indicators in a simulated environment before risking real capital, and consult with a qualified financial advisor regarding your specific financial situation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeWiseWithEase

//@version=6
indicator("Volume Bubbles & Trap Indicator", shorttitle = "BE_VFT0.2", max_labels_count = 500, max_boxes_count = 500, overlay = true, behind_chart = false)

useCustomTF = input.bool(true,    "Use Custom Lower Timeframe", group = "Timeframe")
customTF    = input.timeframe("15S", "Custom Timeframe", active = useCustomTF, group = "Timeframe")

window_bar  = input.int(20, "Trap Pair Window", minval = 3, maxval = 40,step = 1, group = "Pairing Window")

bBuyColor = input.color(color.green, "Bullish Bubble & Zone Color", inline = "Lvl1", group = "display")
bBuyZn = input.color(color.blue, "", inline = "Lvl1", group = "display")
bSellColor = input.color(color.red, "Bearish Bubble & Zone Color", inline = "Lvl2", group = "display")
bSellZn = input.color(color.fuchsia, "", inline = "Lvl2", group = "display")
clrAbsorbtion = input.color(color.yellow, "Absorbtion Bubble & Zone Color", inline = "Lvl3", group = "display")
clrExhaution = input.color(color.white, "Exhaution Bubble Color", inline = "Lvl4", group = "display")

showBStrength = input.bool(true,"Show Bubble Strength Index", group = "display")
lblTransp = input.int(65, "Bubble Transparency", minval = 1, maxval = 100,step = 1, group = "display")
bxUnTestedTransp = input.int(70, "Fresh Zone's Transparency", minval = 1, maxval = 100,step = 1, group = "display")
bxTestedTransp = input.int(90, "Fade Tested Zone Transparency", minval = 1, maxval = 100,step = 1, group = "display")

showZones = input.bool(true,"Show Zones", group = "Other Settings")
showMultiTFema = input.bool(true,"Show EMA Lines", group = "Other Settings")
showTrendCandles = input.bool(true,"Show TrendCandles", group = "Other Settings")
syncDisplay = input.bool(true,"Show Recent vs History ?", group = "Other Settings")

var int chart_sec                   = timeframe.in_seconds(timeframe.period)
var string lowerTimeframe = switch
    useCustomTF          => customTF
    timeframe.isseconds  => "1S"
    timeframe.isintraday => "1"
    timeframe.isdaily    => "5"
    => "60"

var int ltm = timeframe.in_seconds(lowerTimeframe)

type vInfo
    float v = volume
    float o = open
    float h = high
    float l = low
    float c = close
    int t = time
    float pc = na

type vfpData
    float v = na
    float l = na
    float r = na
    int t = na
    bool isBullish = false
    int b_type = na 
    int bi = 999999
    label b = na
    box z = na
    float zt = na
    float zb = na
    bool isTrapped = false
    color c = na
    bool isTested = false
    bool isTrapAlertFired = false
    bool isTestAlertFired = false
    color zc = na
    bool isAbsorved = false

var ops_effortArray = array.new_float(3, 0)
var ops_vfd_arr = array.new<vfpData>(int(15 * (chart_sec / ltm)),  na)
var int mapCounter = ops_vfd_arr.size()
var ops_vol_arr = array.new<float>(mapCounter,  0)
var ops_rng_arr = array.new<float>(mapCounter,  0)
var ops_wt_arr = array.new<float>(mapCounter,  0)
var ops_vd_arr = array.new<float>(mapCounter,  0)
var ops_bubbles_arr = array.new<vfpData>(400,  na)
varip ops_bubTrk = array.new_int(1, -2)
varip ops_vfTrk = array.new_int(1, -2)
varip ops_prVolEff = array.new_int(1, 0)
varip ops_dataLoaded = array.new_bool(1, false)
var ops_EMA = array.new_float(5, na)
var ops_BubLoopEnd = array.new_int(1, 0)

if barstate.isfirst
    if na(volume)
        runtime.error("No Volume Detected!  Current Chart dose not have any volume Information to analyse")
    for [c, d] in ops_vfd_arr
        ops_vfd_arr.set(c, vfpData.new())
    for [g, h] in ops_bubbles_arr
        ops_bubbles_arr.set(g, vfpData.new())

fxGetNextLoadBubble(array<vfpData> Bb) =>
    int Output = na
    for [index, b] in Bb
        if na(b.v) or b.bi == 999999
            Output := index
            break
    Output

fxComputeEMA(float PrEMA, float src) =>
    float alpha = 2 / 21
    float sum = na(PrEMA) ? src : alpha * src + (1.0 - alpha) * nz(PrEMA)
    math.round_to_mintick(sum)

method trackTrapBubbles(array<vfpData> id, array<int> tracker, bool isIdx, array<int> leTracker)=>
    bool triggerSorting = false
    for d = leTracker.first() to 0 by 1
        data = id.get(d)
        if na(data) or na(data.b_type)
            continue
        
        if data.b_type >= 1 and bar_index > data.bi and bar_index <= data.bi + window_bar
            if data.isBullish
                if not data.isTrapped and close <= data.zb - data.r
                    if isIdx
                        box.set_text(data.z, "T")
                        box.set_bgcolor(data.z, color.new(data.zc, bxTestedTransp))
                        box.set_text_color(data.z, data.zc)
                    data.isTrapped := true
                    if not data.isTrapAlertFired and data.b_type >= 2
                        data.isTrapAlertFired := true
                        string alrtTxt = str.format("Buy Trap Detected\nVolume Chunk: {0}\nLevel: {1}\nLTP: {2}", data.b_type == 2 ? "Medium" : "Large", data.l, close)
                        alert(alrtTxt, alert.freq_once_per_bar)
                else if data.isTrapped and close > data.zt + data.r
                    if isIdx
                        box.set_text(data.z, "R")
                        box.set_bgcolor(data.z, color.new(data.zc, bxUnTestedTransp))
            else
                if not data.isTrapped and close >= data.zt + data.r
                    if isIdx
                        box.set_text(data.z, "T")
                        box.set_bgcolor(data.z, color.new(data.zc, bxTestedTransp))
                        box.set_text_color(data.z, data.zc)
                    data.isTrapped := true
                    if not data.isTrapAlertFired and data.b_type >= 2
                        data.isTrapAlertFired := true
                        string alrtTxt = str.format("Sell Trap Detected\nVolume Chunk: {0}\nLevel: {1}\nLTP: {2}", data.b_type == 2 ? "Medium" : "Large", data.l, close)
                        alert(alrtTxt, alert.freq_once_per_bar)  
                else if data.isTrapped and close < data.zb - data.r
                    if isIdx
                        box.set_text(data.z, "R")
                        box.set_bgcolor(data.z, color.new(data.zc, bxUnTestedTransp))
        else if data.b_type < 3 and bar_index >= data.bi + (window_bar * (syncDisplay ? 2 : 8))
            if isIdx
                if not na(data.z)
                    box.delete(data.z)
                if not na(data.b)
                    label.delete(data.b)
            id.set(d, vfpData.new())
            if not triggerSorting
                triggerSorting := true
        else if data.b_type < 3 and data.b_type >= 1 and bar_index >= data.bi + window_bar and data.isTrapped
            if isIdx
                box.set_bgcolor(data.z, color.new(data.zc, bxTestedTransp))
        
        if data.b_type == 3 and bar_index > data.bi
            if data.isBullish
                if low <= data.zt
                    data.isTested := true
                    if not data.isTestAlertFired
                        data.isTestAlertFired := true
                        string alrtTxt = str.format("Price Tested the Major Buyers Level: {0}", data.zt)
                        alert(alrtTxt, alert.freq_once_per_bar)
                if data.isTested and not data.isAbsorved and close < data.zb
                    data.isAbsorved := true
                    if isIdx
                        box.set_extend(data.z, extend.none)
                if bar_index >= data.bi + (window_bar * (syncDisplay ? 2 : 8)) and data.isAbsorved
                    if isIdx
                        if not na(data.z)
                            box.delete(data.z)
                        if not na(data.b)
                            label.delete(data.b)
                    id.set(d, vfpData.new())
                    if not triggerSorting
                        triggerSorting := true
            else
                if high >= data.zb
                    data.isTested := true
                    if not data.isTestAlertFired
                        data.isTestAlertFired := true
                        string alrtTxt = str.format("Price Tested the Major Sellers Level: {0}", data.zb)
                        alert(alrtTxt, alert.freq_once_per_bar)
                if data.isTested and not data.isAbsorved and close > data.zt
                    data.isAbsorved := true
                    if isIdx
                        box.set_extend(data.z, extend.none)
                if bar_index >= data.bi + (window_bar * (syncDisplay ? 2 : 8)) and data.isAbsorved
                    if isIdx
                        if not na(data.z)
                            box.delete(data.z)
                        if not na(data.b)
                            label.delete(data.b)
                    id.set(d, vfpData.new())
                    if not triggerSorting
                        triggerSorting := true
    if triggerSorting
        id.sort(sort_field = "bi")
        int NextLoadIdx = fxGetNextLoadBubble(id)
        if not na(NextLoadIdx)
            tracker.set(0, NextLoadIdx - 1)
            leTracker.set(0, math.max(0, NextLoadIdx - 1))
        else
            tracker.set(0, -1)
            leTracker.set(0, id.size() - 1)
    id

method fxCreateVolBubble(array<vfpData> id, array<int> tracker, vfpData newVal, color clr, int sz, color zClr, bool isIdx, array<int> leTracker)=>
    int where2Load = tracker.first() + 1
    bool wrap = where2Load == id.size()
    if where2Load == -1 or where2Load == id.size()
        tracker.set(0, 0)
        where2Load := 0
    else
        tracker.set(0, where2Load)
    leTracker.set(0, wrap ? id.size() - 1 : math.max(leTracker.first(), where2Load))
    
    vfpData oldNode = id.get(where2Load)
    if not na(oldNode)
        if not na(oldNode.b)
            label.delete(oldNode.b)
        if not na(oldNode.z)
            box.delete(oldNode.z)

    vfpData newChartInfo = vfpData.new(newVal.v, newVal.l, newVal.r, newVal.t, newVal.isBullish, newVal.b_type, newVal.bi, zt = newVal.zt, zb = newVal.zb, isTrapped = false, zc = zClr, c = clr)
    newChartInfo.b := label.new(newVal.t, newVal.l, showBStrength ? str.tostring(newVal.b_type) : "", xloc.bar_time, yloc.price, color.new(newChartInfo.c, lblTransp), label.style_circle, newChartInfo.zc, sz, text.align_center, text_formatting = text.format_bold)
    if newVal.b_type >= 1 and isIdx
        newChartInfo.z := box.new(newVal.bi, newVal.zt, newVal.bi + window_bar, newVal.zb, color.new(color.white, 100), 1, line.style_solid, newVal.b_type < 3 ? extend.none : extend.right, xloc.bar_index, color.new(newChartInfo.zc, bxUnTestedTransp), "", size.small, color.white, text.align_right, text.align_center, text_formatting = text.format_bold)
    id.set(where2Load, newChartInfo)
    id

method loadData(array<vfpData> id, vfpData newVal, array<float> vol_arr, array<float> rng_arr, array<float> wt_arr, array<float> vd_arr, array<int> vfTrk, array<bool> dataLoaded, array<int> prVolEff, array<vfpData> bubbles_arr, array<int> bubTrk, bool isIdx, array<int> leTracker)=>
    int where2Load = vfTrk.first() + 1
    if where2Load == -1 or where2Load == id.size()
        vfTrk.set(0, 0)
        where2Load := 0
    else
        vfTrk.set(0, where2Load)
    bool isDataLoaded  = array.every(dataLoaded)
    if not isDataLoaded and bar_index > 0 and where2Load == 0
        dataLoaded.set(0, true)
        isDataLoaded := true
    if isDataLoaded
        float WA = array.sum(wt_arr) / array.sum(rng_arr)
        float rangeMax = rng_arr.max()
        bool isMaxVol = newVal.v > vol_arr.max()
        bool isMaxEfrt = newVal.r > rangeMax
        bool isGWA = newVal.v > WA * 1.75

        if isMaxVol and isMaxEfrt
            // log.info("Volume with Impact")
            prVolEff.set(0, 3)
            newVal.b_type := 3
            bubbles_arr.fxCreateVolBubble(bubTrk, newVal, newVal.isBullish ? bBuyColor : bSellColor, 18, newVal.isBullish ? bBuyZn : bSellZn, isIdx, leTracker)
        else if isMaxEfrt and isGWA
            // log.info("Moderate Volume with Impact")
            prVolEff.set(0, 2)
            newVal.b_type := 2
            bubbles_arr.fxCreateVolBubble(bubTrk, newVal, newVal.isBullish ? bBuyColor : bSellColor, 12, newVal.isBullish ? bBuyZn : bSellZn, isIdx, leTracker)
        else if isGWA and newVal.r >= rangeMax * 0.75 
            // log.info("Moderate Volume with Moderate Impact")
            prVolEff.set(0, 1)
            newVal.b_type := 1
            bubbles_arr.fxCreateVolBubble(bubTrk, newVal, newVal.isBullish ? bBuyColor : bSellColor, 7, newVal.isBullish ? bBuyZn : bSellZn, isIdx, leTracker)
        else if (isMaxVol or newVal.v >= WA * 1.6) and newVal.r <= rng_arr.avg() * 0.4 and (prVolEff.first() >= 1 or newVal.v > vol_arr.max() * 3) 
            // log.info("Volume Absorbtion")
            if newVal.v < vol_arr.max() * 3
                prVolEff.set(0, 0)
                newVal.b_type := 0
                bubbles_arr.fxCreateVolBubble(bubTrk, newVal, clrAbsorbtion, 10, clrAbsorbtion, isIdx, leTracker)
            else
                prVolEff.set(0, 0)//DO NOT ALLOW PLOTTING Absorbtion ON NEXT CANDLE
                newVal.b_type := 1
                bubbles_arr.fxCreateVolBubble(bubTrk, newVal, clrAbsorbtion, 10, newVal.isBullish ? bBuyZn : bSellZn, isIdx, leTracker)
        else if newVal.v < WA * 0.75 and newVal.r > rng_arr.avg()
            // log.error("Volume Exhaution")
            prVolEff.set(0, 0)
            newVal.b_type := 0
            bubbles_arr.fxCreateVolBubble(bubTrk, newVal, clrExhaution, 10, clrExhaution, isIdx, leTracker)
        else
            prVolEff.set(0, 0)
    float weightVolue = (newVal.v / 1000) * newVal.r
    vol_arr.set(where2Load, newVal.v)
    rng_arr.set(where2Load, newVal.r)
    wt_arr.set(where2Load, weightVolue )
    vd_arr.set(where2Load, newVal.isBullish ? weightVolue : weightVolue * -1 )
    id.set(where2Load, newVal)

method fxVolumefootPrint(array<vInfo> id, array<float> eArr, array<vfpData> vfd_arr, array<float> vol_arr, array<float> rng_arr, array<float> wt_arr, array<float> vd_arr, array<int> vfTrk, array<bool> dataLoaded, array<int> prVolEff, array<vfpData> bubbles_arr, array<int> bubTrk, bool isIdx, array<int> leTracker)=>
    for [index, vData] in id
        float dBody = math.abs(vData.o - vData.c)
        float dl2C = math.abs(vData.l - vData.c)
        float dh2C = math.abs(vData.h - vData.c)
        eArr.set(0, dBody)
        eArr.set(1, dl2C)
        eArr.set(2, dh2C)
        bool isGreen = vData.o < vData.c
        bool isRed = vData.c < vData.o
        float mxEffort = eArr.max()
        if isGreen or (not isRed and vData.c > vData.pc)
            if mxEffort == dBody
                vfpData newVal = vfpData.new(vData.v, vData.o, mxEffort, vData.t, true, bi = bar_index, zt = vData.o + (mxEffort * 0.5), zb = vData.o)
                vfd_arr.loadData(newVal, vol_arr, rng_arr, wt_arr, vd_arr, vfTrk, dataLoaded, prVolEff, bubbles_arr, bubTrk, isIdx, leTracker)
            else if mxEffort == dl2C
                vfpData newVal = vfpData.new(vData.v, vData.l, mxEffort, vData.t, true, bi = bar_index, zt = math.max(vData.o, vData.l + (mxEffort * 0.5)), zb = vData.l)
                vfd_arr.loadData(newVal, vol_arr, rng_arr, wt_arr, vd_arr, vfTrk, dataLoaded, prVolEff, bubbles_arr, bubTrk, isIdx, leTracker)
            else if mxEffort == dh2C
                vfpData newVal = vfpData.new(vData.v, vData.h, mxEffort, vData.t, false, bi = bar_index, zb = math.min(vData.o, vData.h - (mxEffort * 0.5)), zt = vData.h)
                vfd_arr.loadData(newVal, vol_arr, rng_arr, wt_arr, vd_arr, vfTrk, dataLoaded, prVolEff, bubbles_arr, bubTrk, isIdx, leTracker)
        else if isRed or (not isGreen and vData.c < vData.pc)
            if mxEffort == dBody
                vfpData newVal = vfpData.new(vData.v, vData.o, mxEffort, vData.t, false, bi = bar_index, zb = vData.o - (mxEffort * 0.5), zt = vData.o)
                vfd_arr.loadData(newVal, vol_arr, rng_arr, wt_arr, vd_arr, vfTrk, dataLoaded, prVolEff, bubbles_arr, bubTrk, isIdx, leTracker)
            else if mxEffort == dl2C
                vfpData newVal = vfpData.new(vData.v, vData.l, mxEffort, vData.t, true, bi = bar_index, zt = math.max(vData.o, vData.l + (mxEffort * 0.5)), zb = vData.l)
                vfd_arr.loadData(newVal, vol_arr, rng_arr, wt_arr, vd_arr, vfTrk, dataLoaded, prVolEff, bubbles_arr, bubTrk, isIdx, leTracker)
            else if mxEffort == dh2C
                vfpData newVal = vfpData.new(vData.v, vData.h, mxEffort, vData.t, false, bi = bar_index, zb = math.min(vData.o, vData.h - (mxEffort * 0.5)), zt = vData.h)
                vfd_arr.loadData(newVal, vol_arr, rng_arr, wt_arr, vd_arr, vfTrk, dataLoaded, prVolEff, bubbles_arr, bubTrk, isIdx, leTracker)
        mxEffort
    
method isDivisible(string reqTF) =>
    int reqIntTF = timeframe.in_seconds(reqTF)
    int chartIntTF = timeframe.in_seconds(timeframe.period)
    showMultiTFema and (chartIntTF < reqIntTF) and (reqIntTF % chartIntTF == 0)

var bool can15 = isDivisible("15")
var bool can25 = isDivisible("25")
var bool can75 = isDivisible("75")
var bool can125 = isDivisible("125")
var bool can1D = isDivisible("1D")

bool is15 = can15 and time_close == time_close("15")
bool is25 = can25 and time_close == time_close("25")
bool is75 = can75 and time_close == time_close("75")
bool is125 = can125 and time_close == time_close("125")
bool is1D = can1D and session.islastbar

if barstate.isconfirmed
    ops_vArray = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, vInfo.new(pc = nz(close[1], close) ))

    ops_vArray.fxVolumefootPrint(ops_effortArray, ops_vfd_arr, ops_vol_arr, ops_rng_arr, ops_wt_arr, ops_vd_arr, ops_vfTrk, ops_dataLoaded, ops_prVolEff, ops_bubbles_arr, ops_bubTrk, showZones, ops_BubLoopEnd)
    ops_bubbles_arr.trackTrapBubbles(ops_bubTrk, showZones, ops_BubLoopEnd)
    if is15
        EMA15 = fxComputeEMA(array.get(ops_EMA, 0), close)
        array.set(ops_EMA, 0, EMA15)
    if is25
        EMA25 = fxComputeEMA(array.get(ops_EMA, 1), close)
        array.set(ops_EMA, 1, EMA25)
    if is75
        EMA75 = fxComputeEMA(array.get(ops_EMA, 2), close)
        array.set(ops_EMA, 2, EMA75)
    if is125
        EMA125 = fxComputeEMA(array.get(ops_EMA, 3), close)
        array.set(ops_EMA, 3, EMA125)
    if is1D
        EMA1D = fxComputeEMA(array.get(ops_EMA, 4), close)
        array.set(ops_EMA, 4, EMA1D)

float ops_volTrend = ops_vd_arr.sum()
color ops_barColor = ops_volTrend > 0 ? color.new(bBuyColor, showTrendCandles ? 0 : 100) : color.new(bSellColor, showTrendCandles ? 0 : 100)
plot(ops_volTrend, "OPS_CVD", color = ops_barColor, linewidth = 1, display = display.status_line)
plotcandle(open, high, low, close, "VolTrendCandles", ops_barColor, ops_barColor, bordercolor = ops_barColor, display = display.pane )
plot(ops_EMA.get(0), "EMA15", color = color.silver, linewidth = 1)
plot(ops_EMA.get(1), "EMA25", color = color.white, linewidth = 1)
plot(ops_EMA.get(2), "EMA75", color = color.aqua, linewidth = 1)
plot(ops_EMA.get(3), "EMA125", color = color.blue, linewidth = 1)
plot(ops_EMA.get(4), "EMA1D", color = color.yellow, linewidth = 1)
plot(showMultiTFema ? ta.ema(close, 20) : na, "EMA", color = color.fuchsia, linewidth = 1)
````
