# Pullback with key Levels

- url: https://www.tradingview.com/script/MNq36E1Q/
- type: indicator
- pine_id: PUB;06e577bbbfd2475eb3019ea6c9516246
- version: 7.0

## Description

Pullback With Key Levels By Piyacham

Logic Overview:

Trend Determination:
BUY: EMA14 is above EMA60.
SELL: EMA14 is below EMA60.

Grading System:
Grade A: The trend is strong; price is trading "beyond" the fast EMA (Above EMA14 for BUY, Below EMA14 for SELL).
Grade B: The price is in a retracement zone between the two EMAs.
Grade C: The price has crossed below the slow EMA (for BUY) or above it (for SELL), suggesting a potential trend weakness or reversal.

Timeframes: The dashboard automatically tracks M1, M3, M5, H1, and H4 regardless of your current chart timeframe.

Key Features:
Configurable EMAs: You can change the lengths of both EMAs in the settings.
Customizable Dashboard: You can move the dashboard to any corner of the chart and adjust colors for the text and headers.
Visual Clarity: The dashboard cells are color-coded based on the trend (Green for BUY, Red for SELL) for quick scanning.
Jul 24
Release Notes
The upgrade version of Trend Grading Dashboard V1.0

This version add this following features
+ Add grading of TF Day in to dashboard and also
+ add alert feature
- Signal BUY : Present when the candle stick of specific timeframe shift momentum from SELL to BUY
- Signal SELL : Present when the candle stick of specific timeframe shift momentum from BUY to SELL

Key Levels Added:
- Multi Time frame Supply and Demand Zone
- Wick of Previous Day as Old High / Old Low
- Support/Resistance of Candle Stick (Days)
- Buy and Sell Signal when sweep back

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org
// © LuxAlgo (Trend Grading Dashboard, modified) + Supply and Demand Zones — merged
// Merged indicator: Trend Grading Dashboard V4.0 + Supply and Demand Zones + White Box Trader / Yesterday Levels (optional)

//@version=6
indicator("Pullback With Key Levels V1.0", shorttitle = "PB with Key Levels", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =========================================================================
// ===================  SECTION 1: TREND GRADING DASHBOARD  ==============
// =========================================================================

// --- Constants ---
string GRP_EMA  = "EMA Settings"
string GRP_DASH = "Dashboard Settings"

// --- Inputs ---
int emaLen1 = input.int(14, "EMA 1 Length", minval = 1, group = GRP_EMA, tooltip = "Length for the fast EMA")
int emaLen2 = input.int(60, "EMA 2 Length", minval = 1, group = GRP_EMA, tooltip = "Length for the slow EMA")
showEmaLines = input.bool(true, "แสดงเส้น EMA 14 / EMA 60", group = GRP_EMA, tooltip = "ติ๊กเพื่อแสดงเส้น EMA 14, EMA 60 และแถบสีระหว่างเส้น เอาติ๊กออกเพื่อซ่อน (ตารางและสัญญาณยังคำนวณตามปกติ)")

enableSignalSetting = input.bool(false, title="Enable Signal Buy/Sell when momentum shift", group = GRP_EMA)
bullSignal  = input.color(color.white, "Bullish Cross Color", tooltip = "Candle color when price crosses above EMA 14", group = GRP_EMA)
bearSignal  = input.color(color.white, "Bearish Cross Color", tooltip = "Candle color when price crosses below EMA 14", group = GRP_EMA)

color bullColor = input.color(#089981, "Bullish Color", group = GRP_EMA)
color bearColor = input.color(#f23645, "Bearish Color", group = GRP_EMA)

showDash    = input.bool(true, "Show Dashboard Table", group = GRP_DASH, tooltip = "Turn off to highly speed up Backtesting")
string tablePos    = input.string("top_right", "Dashboard Position", options = ["top_right", "bottom_right", "top_left", "bottom_left"], group = GRP_DASH)
color  textColorDash = input.color(color.white, "Text Color", group = GRP_DASH)
color  headerColor = input.color(color.gray, "Header Color", group = GRP_DASH)

// --- Types ---
type MarketState
    float e1
    float e2
    float price

// --- Calculations ---
ema14 = ta.ema(close, emaLen1)
ema60 = ta.ema(close, emaLen2)

priceCrossUp   = ta.crossover(close, ema14)
priceCrossDown = ta.crossunder(close, ema14)
emaCrossUp     = ema14 > ema60

getState() =>
    MarketState.new(ta.ema(close, emaLen1), ta.ema(close, emaLen2), close)

// Fetching data for multiple timeframes (only loads when dashboard is enabled)
m1  = showDash ? request.security(syminfo.tickerid, "1", getState()) : na
m3  = showDash ? request.security(syminfo.tickerid, "3", getState()) : na
m5  = showDash ? request.security(syminfo.tickerid, "5", getState()) : na
h1  = showDash ? request.security(syminfo.tickerid, "60", getState()) : na
h4  = showDash ? request.security(syminfo.tickerid, "240", getState()) : na
d1  = showDash ? request.security(syminfo.tickerid, "D", getState()) : na

// --- Logic Function ---
getTrendAndGrade(MarketState state) =>
    string trend = "N/A"
    string grade = "N/A"
    color  c     = color.gray

    if not na(state) and not na(state.e1) and not na(state.e2)
        bool isBuy = state.e1 > state.e2
        trend := isBuy ? "BUY" : "SELL"
        c     := isBuy ? bullColor : bearColor

        if isBuy
            grade := state.price > state.e1 ? "A" : (state.price > state.e2 ? "B" : "C")
        else
            grade := state.price < state.e1 ? "A" : (state.price < state.e2 ? "B" : "C")

    [trend, grade, c]

// Helper to fill row
fillRow(table dash, int row, string tfName, MarketState m, color txt) =>
    [t, g, c] = getTrendAndGrade(m)
    table.cell(dash, 0, row, tfName, text_color = txt)
    table.cell(dash, 1, row, t, bgcolor = c, text_color = color.white)
    table.cell(dash, 2, row, g, text_color = txt)

// --- Plotting ---
p1 = plot(ema14, "EMA 14", color = emaCrossUp ? bullColor : bearColor, linewidth = 2, display = showEmaLines ? display.all : display.none)
p2 = plot(ema60, "EMA 60", color = color.gray, linewidth = 1, display = showEmaLines ? display.all : display.none)

fill(p1, p2, ema14 > ema60 ? color.new(bullColor, 80) : color.new(bearColor, 80), "EMA Cross Shading", display = showEmaLines ? display.all : display.none)

barcolor(priceCrossUp ? bullSignal : priceCrossDown ? bearSignal : na, title = "Price Cross EMA 14")

// Dashboard table
var table dash = table.new(tablePos, 3, 7, frame_color = color.gray, frame_width = 1, border_color = color.gray, border_width = 1)

if barstate.islast and showDash
    table.cell(dash, 0, 0, "TF", bgcolor = headerColor, text_color = textColorDash)
    table.cell(dash, 1, 0, "Trend", bgcolor = headerColor, text_color = textColorDash)
    table.cell(dash, 2, 0, "Grade", bgcolor = headerColor, text_color = textColorDash)

    fillRow(dash, 1, "M1", m1, textColorDash)
    fillRow(dash, 2, "M3", m3, textColorDash)
    fillRow(dash, 3, "M5", m5, textColorDash)
    fillRow(dash, 4, "H1", h1, textColorDash)
    fillRow(dash, 5, "H4", h4, textColorDash)
    fillRow(dash, 6, "D1", d1, textColorDash)

// --- Alerts ---
alertcondition(priceCrossUp or priceCrossDown, title="Momentum Shift Alert", message="Momentum Shift Alert | Price crossed EMA 14")

if priceCrossUp
    alert("Momentum Shift Alert | Bullish - Price crossed above EMA 14 (Bullish Momentum)!", alert.freq_once_per_bar)

if priceCrossDown
    alert("Momentum Shift Alert | Bearish - Price crossed below EMA 14 (Bearish Momentum)!", alert.freq_once_per_bar)

buyCondition  = priceCrossUp and enableSignalSetting
sellCondition = priceCrossDown and enableSignalSetting

plotshape(series=buyCondition, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="BUY", textcolor=color.white)
plotshape(series=sellCondition, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL", textcolor=color.white)

// ----------------------- EMA CROSSING (EMA 1 x EMA 2) -----------------------
string GRP_CROSS = "EMA Crossing (EMA 14 x EMA 60)"
enableCrossing = input.bool(false, "เปิดใช้งาน Crossing (EMA 14 ตัด EMA 60)", group = GRP_CROSS, tooltip = "เปิดเพื่อแสดงสัญญาณ Crossing บนกราฟและให้ Alert ชื่อ Crossing ทำงาน ค่าเริ่มต้น: ปิด")
crossUpColor   = input.color(#00c853, "สีสัญญาณ Crossing ขึ้น (EMA 14 ตัดขึ้นเหนือ EMA 60)", group = GRP_CROSS)
crossDownColor = input.color(#d50000, "สีสัญญาณ Crossing ลง (EMA 14 ตัดลงใต้ EMA 60)", group = GRP_CROSS)

bool rawCrossUp   = ta.crossover(ema14, ema60)
bool rawCrossDown = ta.crossunder(ema14, ema60)
bool crossingUp   = enableCrossing and rawCrossUp
bool crossingDown = enableCrossing and rawCrossDown

plotshape(crossingUp,   title = "Crossing Up",   style = shape.labelup,   location = location.belowbar, color = crossUpColor,   size = size.small, text = "Crossing", textcolor = color.white)
plotshape(crossingDown, title = "Crossing Down", style = shape.labeldown, location = location.abovebar, color = crossDownColor, size = size.small, text = "Crossing", textcolor = color.white)

// ชื่อ TF ของกราฟสำหรับข้อความ alert
string crossTf = timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? "H" + str.tostring(int(timeframe.multiplier / 60)) : "M" + str.tostring(timeframe.multiplier)) : timeframe.period

alertcondition(crossingUp or crossingDown, title = "Crossing", message = "Crossing | EMA 14 ตัด EMA 60 | {{ticker}} {{interval}}")

// alert() แบบระบุทิศทางและ TF (เลือก "Any alert() function call" ตอนตั้ง alert)
if crossingUp
    alert("Crossing | " + syminfo.ticker + " | Bullish - EMA " + str.tostring(emaLen1) + " ตัดขึ้นเหนือ EMA " + str.tostring(emaLen2) + " | TF: " + crossTf, alert.freq_once_per_bar_close)

if crossingDown
    alert("Crossing | " + syminfo.ticker + " | Bearish - EMA " + str.tostring(emaLen1) + " ตัดลงใต้ EMA " + str.tostring(emaLen2) + " | TF: " + crossTf, alert.freq_once_per_bar_close)



// =========================================================================
// ===================  SECTION 2: SUPPLY AND DEMAND ZONES  ==============
// =========================================================================

// --- Inputs ---
candleDifferenceScale = input.float(defval = 1.8, minval = 1, title = 'Zone Difference Scale', tooltip = 'The scale of how much a candle needs to be larger than a previous to be considered a zone. (candleChange / candleChange[1] > {value}, minimum value 1.0, default 1.8)', group = 'Zone Settings')

zoneOffset = input.int(defval = 15, minval = 0, title="Zone Extension", group = 'Display Settings', tooltip = 'How much to extend zones to the right of latest bar. (In bars)')
displayLowerTFZones = input.bool(false, title="Display Lower Timeframe Zones", group = 'Display Settings', tooltip = 'Whether to or not to display zones from a lower timeframe. ie. 2h zones on 4h timeframe (Recommended OFF).')

supplyEnable = input.bool(true, title = "Enable Supply Zones", group = "Zone Personalization")
supplyColor = input.color(defval = color.rgb(242, 54, 69, 70), title = 'Supply Background Color', group = 'Zone Personalization')
supplyBorderColor = input.color(defval = color.rgb(209, 212, 220, 90), title = 'Supply Border Color', group = 'Zone Personalization')

demandEnable = input.bool(true, title = "Enable Demand Zones", group = "Zone Personalization")
demandColor = input.color(defval = color.rgb(76, 175, 80, 70), title = 'Demand Background Color', group = 'Zone Personalization')
demandBorderColor = input.color(defval = color.rgb(209, 212, 220, 80), title = 'Demand Border Color', group = 'Zone Personalization')

textEnable = input.bool(true, title = "Display Text", group = 'Text Settings')
displayHL = input.bool(false, title="Display High/Low", group = 'Text Settings', tooltip = 'Whether to or not to display the tops and bottoms of a zone as text. ie. Top: 4000.00 Bottom: 3900.00.')
textColorSD = input.color(defval = color.rgb(255, 255, 255), title = 'Text Color', group = 'Text Settings')
textSizeInput = input.string("Small", title="Text Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group = 'Text Settings')
halignInput = input.string("Right", title="Horizontal Alignment", options=["Left", "Center", "Right"], group = 'Text Settings')
supplyValignInput = input.string("Bottom", title="Vertical Alignment (Supply)", options=["Top", "Center", "Bottom"], group = 'Text Settings')
demandValignInput = input.string("Top", title="Vertical Alignment (Demand)", options=["Top", "Center", "Bottom"], group = 'Text Settings')

displayFormingZones = input.bool(false, title="Show Forming Zones", group = 'Timeframe Options', tooltip = 'Shows zones that could potentially form (unclosed candles)')
display30m = input.bool(false, title="Show 30m Zones", group = 'Timeframe Options')
display45m = input.bool(false, title="Show 45m Zones", group = 'Timeframe Options')
display1h = input.bool(true, title="Show 1h Zones", group = 'Timeframe Options')
display2h = input.bool(false, title="Show 2h Zones", group = 'Timeframe Options')
display3h = input.bool(false, title="Show 3h Zones", group = 'Timeframe Options')
display4h = input.bool(true, title="Show 4h Zones", group = 'Timeframe Options')
displayD = input.bool(false, title="Show Daily Zones", group = 'Timeframe Options')
displayW = input.bool(false, title="Show Weekly Zones", group = 'Timeframe Options')

// --- Variables ---
currentTimeframe = timeframe.period

if currentTimeframe == 'D'
    currentTimeframe := '1440'
if currentTimeframe == 'W'
    currentTimeframe := '10080'
if displayLowerTFZones
    currentTimeframe := '1'

momentCTD = math.round(time(timeframe.period) + (zoneOffset * 60000 * str.tonumber(currentTimeframe)))

var string textSize = size.small
if textSizeInput == 'Auto'
    textSize := size.auto
if textSizeInput == 'Tiny'
    textSize := size.tiny
if textSizeInput == 'Small'
    textSize := size.small
if textSizeInput == 'Normal'
    textSize := size.normal
if textSizeInput == 'Large'
    textSize := size.large
if textSizeInput == 'Huge'
    textSize := size.huge

var string halign = text.align_right
if halignInput == 'Left'
    halign := text.align_left
if halignInput == 'Center'
    halign := text.align_center
if halignInput == 'Right'
    halign := text.align_right

var string supplyValign = text.align_bottom
if supplyValignInput == 'Bottom'
    supplyValign := text.align_bottom
if supplyValignInput == 'Center'
    supplyValign := text.align_center
if supplyValignInput == 'Top'
    supplyValign := text.align_top

var string demandValign = text.align_top
if demandValignInput == 'Bottom'
    demandValign := text.align_bottom
if demandValignInput == 'Center'
    demandValign := text.align_center
if demandValignInput == 'Top'
    demandValign := text.align_top

var box[] supply_HT = array.new_box()
var box[] demand_HT = array.new_box()

// --- Plotting zones ---
createSupplyDemandZones(timeframe) =>

    [open_HT, high_HT, low_HT, close_HT] = request.security(syminfo.tickerid, timeframe, [open[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

    var timeframeFormatted = ''

    if timeframe == '1'
        timeframeFormatted := '1m'
    else if timeframe == '3'
        timeframeFormatted := '3m'
    else if timeframe == '5'
        timeframeFormatted := '5m'
    else if timeframe == '15'
        timeframeFormatted := '15m'
    else if timeframe == '30'
        timeframeFormatted := '30m'
    else if timeframe == '45'
        timeframeFormatted := '45m'
    else if timeframe == '60'
        timeframeFormatted := '1h'
    else if timeframe == '120'
        timeframeFormatted := '2h'
    else if timeframe == '180'
        timeframeFormatted := '3h'
    else if timeframe == '240'
        timeframeFormatted := '4h'
    else if timeframe == 'D'
        timeframeFormatted := 'D'
    else if timeframe == 'W'
        timeframeFormatted := 'W'

    redCandle_HT = close_HT < open_HT
    greenCandle_HT = close_HT > open_HT
    neutralCandle_HT = close_HT == open_HT
    candleChange_HT = math.abs(close_HT - open_HT)

    var float bottomBox_HT = na
    var float topBox_HT = na
    momentCTD_HT = time(timeframe)[2]

    if (((redCandle_HT and greenCandle_HT[1]) or (redCandle_HT and neutralCandle_HT[1])) and (candleChange_HT / candleChange_HT[1]) >= candleDifferenceScale and (barstate.isconfirmed[1] or displayFormingZones) and supplyEnable and close_HT[1] >= close_HT and open_HT[1] <= open_HT)
        if displayFormingZones and barstate.isconfirmed[1] == false
            timeframeFormatted := timeframeFormatted + '(Forming)'
        if displayHL
            timeframeFormatted := timeframeFormatted + '\nTop: ' + str.tostring(topBox_HT) + '\nBottom: ' + str.tostring(open_HT[1])

        if high_HT >= high_HT[1]
            topBox_HT := high_HT
        else
            topBox_HT := high_HT[1]

        box supply = box.new(left=momentCTD_HT, top=topBox_HT, right=momentCTD, bgcolor=supplyColor, bottom=open_HT[1], xloc=xloc.bar_time)
        box.set_border_color(supply, supplyBorderColor)
        if textEnable
            box.set_text(supply, timeframeFormatted)
            box.set_text_size(supply, textSize)
            box.set_text_color(supply, textColorSD)
            box.set_text_halign(supply, halign)
            box.set_text_valign(supply, supplyValign)
        array.push(supply_HT, supply)

    if (((greenCandle_HT and redCandle_HT[1]) or (greenCandle_HT and neutralCandle_HT[1])) and (candleChange_HT / candleChange_HT[1]) >= candleDifferenceScale and (barstate.isconfirmed[1] or displayFormingZones) and demandEnable and close_HT[1] <= close_HT and open_HT[1] >= open_HT)
        if displayFormingZones and barstate.isconfirmed[1] == false
            timeframeFormatted := timeframeFormatted + ' (Forming)'
        if displayHL
            timeframeFormatted := timeframeFormatted + '\nTop: ' + str.tostring(open_HT[1]) + '\nBottom: ' + str.tostring(bottomBox_HT)

        if low_HT <= low_HT[1]
            bottomBox_HT := low_HT
        else
            bottomBox_HT := low_HT[1]

        box demand = box.new(left=momentCTD_HT, top=open_HT[1], right=momentCTD, bottom=bottomBox_HT, bgcolor=demandColor, xloc=xloc.bar_time)
        box.set_border_color(demand, demandBorderColor)
        if textEnable
            box.set_text(demand, timeframeFormatted)
            box.set_text_size(demand, textSize)
            box.set_text_color(demand, textColorSD)
            box.set_text_halign(demand, halign)
            box.set_text_valign(demand, demandValign)
        array.push(demand_HT, demand)

// --- Initiation ---
if display30m and str.tonumber(currentTimeframe) <= 30
    createSupplyDemandZones('30')
if display45m and str.tonumber(currentTimeframe) <= 45
    createSupplyDemandZones('45')
if display1h and str.tonumber(currentTimeframe) <= 60
    createSupplyDemandZones('60')
if display2h and str.tonumber(currentTimeframe) <= 120
    createSupplyDemandZones('120')
if display3h and str.tonumber(currentTimeframe) <= 180
    createSupplyDemandZones('180')
if display4h and str.tonumber(currentTimeframe) <= 240
    createSupplyDemandZones('240')
if displayD and str.tonumber(currentTimeframe) <= 1440
    createSupplyDemandZones('D')
if displayW and str.tonumber(currentTimeframe) <= 10080
    createSupplyDemandZones('W')
    // createSupplyDemandZones('M') // enabling this will break replay mode

// --- Remove broken supply zones ---
i = 0
while i < array.size(supply_HT) and array.size(supply_HT) > 0
    box currentBox = array.get(supply_HT, i)
    float breakLevel = box.get_top(currentBox)
    if high > breakLevel
        array.remove(supply_HT, i)
        box.delete(currentBox)
        int(na)
    else
        box.set_right(currentBox, momentCTD)
        i += 1
        int(na)

// --- Remove broken demand zones ---
i2 = 0
while i2 < array.size(demand_HT) and array.size(demand_HT) > 0
    box currentBox = array.get(demand_HT, i2)
    float breakLevel = box.get_bottom(currentBox)
    if low < breakLevel
        array.remove(demand_HT, i2)
        box.delete(currentBox)
        int(na)
    else
        box.set_right(currentBox, momentCTD)
        i2 += 1
        int(na)


// =========================================================================
// =========  SECTION 3: WHITE BOX TRADER + YESTERDAY LEVELS (OPTIONAL)  =====
// =========================================================================

// --- Master switch ---
string GRP_PDH = "White Box + Yesterday Levels"
enablePdhModule = input.bool(true, "เปิดใช้งานโมดูลนี้ทั้งหมด (White Box + Yesterday Levels)", group = GRP_PDH, tooltip = "เปิด/ปิด Section 3 ทั้งหมด (กรอบขาว H1, เส้นแบ่งวัน, เส้นระดับราคาของเมื่อวาน)")
showWhiteBox    = input.bool(false, "แสดงกรอบขาว H1 (White Box)", group = GRP_PDH)

// --- Box settings ---
boxBorderColor  = input.color(color.white, title = "Box Border Color", group = "Box Settings")
boxBgColor      = input.color(color.white, title = "Box Fill Color", group = "Box Settings")
boxTransparency = input.int(90, title = "Box Fill Transparency (0-100)", minval = 0, maxval = 100, group = "Box Settings", display = display.none)

// --- Yesterday levels settings ---
showYestLevels = input.bool(true, title = "แสดงเส้นระดับราคาของเมื่อวาน (ทุกวัน)", group = "Yesterday Levels Settings", display = display.none)
yestWickColor  = input.color(color.yellow, title = "สีเส้นปลายไส้ (High/Low)", group = "Yesterday Levels Settings")
yestBodyColor  = input.color(color.orange, title = "สีเส้นเนื้อเทียน (Body High/Low)", group = "Yesterday Levels Settings")
yestStyleStr   = input.string("Solid", title = "ประเภทของเส้น", options = ["Solid", "Dashed", "Dotted"], group = "Yesterday Levels Settings", display = display.none)
yestLineWidth  = input.int(1, title = "ขนาดของเส้น (ความหนา)", minval = 1, maxval = 5, group = "Yesterday Levels Settings", display = display.none)
extendBars     = input.int(10, title = "ขยายเส้นวันล่าสุดไปด้านหน้า (จำนวนแท่ง)", minval = 0, group = "Yesterday Levels Settings", display = display.none)
resText        = input.string("แนวต้าน", title = "ข้อความเมื่อราคาอยู่ใต้เส้น", group = "Yesterday Levels Settings", display = display.none)
supText        = input.string("แนวรับ", title = "ข้อความเมื่อราคาอยู่เหนือเส้น", group = "Yesterday Levels Settings", display = display.none)
yestTextColor  = input.color(color.white, title = "สีข้อความปลายเส้น", group = "Yesterday Levels Settings")
pdhText        = input.string("Old Day High", title = "Old Day High", group = "Yesterday Levels Settings", display = display.none)
pdlText        = input.string("Old Day Low", title = "Old Day Low", group = "Yesterday Levels Settings", display = display.none)

boxOn  = enablePdhModule and showWhiteBox
yestOn = enablePdhModule and showYestLevels

// ฟังก์ชันแปลงตัวเลือกประเภทเส้น
f_getLineStyle(_style) =>
    switch _style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// ----------------------- WHITE BOX TRADER (H1 BOX SYSTEM) -----------------------
f_calcH1Boxes() =>
    isBullish = close > open
    isBearish = close < open
    bodyMax   = math.max(close, open)
    bodyMin   = math.min(close, open)

    // ชั่วโมงของแท่งเทียน (เวลาไทย)
    currentHour = hour(time, "UTC+7")

    // ช่วงเวลาที่อนุญาตให้หาแท่งเบรก (07:00 ถึง 03:00 ของวันถัดไป)
    isInTimeWindow = (currentHour >= 7 and currentHour <= 23) or (currentHour >= 0 and currentHour <= 3)

    // แท่ง 03:00 เป็นจุดสิ้นสุดการยืดกรอบของวัน
    isCutoffBar = (currentHour == 3)

    // ขึ้นวันใหม่
    isNewDay = ta.change(time("D")) != 0

    // เงื่อนไขแท่งเบรก แบบ 1 และ แบบ 2
    breakType1      = (isBullish and close[1] < open[1]) or (isBearish and close[1] > open[1])
    breakType2_Up   = isBullish and (close[1] > open[1]) and (bodyMax <= high[1])
    breakType2_Down = isBearish and (close[1] < open[1]) and (bodyMin >= low[1])
    breakType2      = breakType2_Up or breakType2_Down
    isBreakCandle   = breakType1 or breakType2

    var bool inCycle = false
    var float bTop   = na
    var float bBot   = na
    var int startT   = na

    // จบรอบ: เนื้อปิดหลุดกรอบ หรือ ถึงแท่ง 03:00 น.
    bool isCycleEnded = inCycle and (bodyMax > bTop or bodyMin < bBot or isCutoffBar)

    bool startNewBox = false
    bool endBox      = false

    if isNewDay
        inCycle := false
        endBox  := true
    else if isCycleEnded
        inCycle := false
        endBox  := true
    else if isBreakCandle and not inCycle and isInTimeWindow and not isCutoffBar
        bTop        := high
        bBot        := low
        startT      := time
        inCycle     := true
        startNewBox := true

    [startNewBox, endBox, startT, time, bTop, bBot, isCutoffBar]

// รองรับ M15 / M5 และให้ H1 ประมวลผลโดยตรง
[sec_Start, sec_End, sec_StartTime, sec_EndTime, sec_Top, sec_Bot, sec_Cutoff] = request.security(syminfo.tickerid, "60", f_calcH1Boxes(), gaps = barmerge.gaps_off)
[loc_Start, loc_End, loc_StartTime, loc_EndTime, loc_Top, loc_Bot, loc_Cutoff] = f_calcH1Boxes()

isH1 = timeframe.period == "60"

h1Start     = isH1 ? loc_Start     : sec_Start
h1End       = isH1 ? loc_End       : sec_End
h1StartTime = isH1 ? loc_StartTime : sec_StartTime
h1Top       = isH1 ? loc_Top       : sec_Top
h1Bot       = isH1 ? loc_Bot       : sec_Bot

// --- วาด Box และเส้นแบ่งวัน ---
var box whiteBox = na
var bool isBoxActive = false

bool isH1TimeChanged = ta.change(h1StartTime) != 0
bool isNewDayChart   = ta.change(time("D")) != 0

// เมื่อเกิดกรอบใหม่ของ H1
if boxOn and h1Start and isH1TimeChanged
    whiteBox := box.new(
         left         = h1StartTime,
         top          = h1Top,
         right        = time,
         bottom       = h1Bot,
         xloc         = xloc.bar_time,
         border_color = boxBorderColor,
         border_width = 1,
         bgcolor      = color.new(boxBgColor, boxTransparency)
     )
    isBoxActive := true

// ขยายกรอบไปทางขวาจนจบรอบ
if boxOn and isBoxActive and not na(whiteBox)
    box.set_right(whiteBox, time)
    if h1End
        isBoxActive := false

// เส้นแนวตั้งแบ่งวันใหม่
if enablePdhModule and isNewDayChart
    line.new(
         x1     = time,
         y1     = low,
         x2     = time,
         y2     = high,
         xloc   = xloc.bar_time,
         extend = extend.both,
         color  = color.new(color.gray, 60),
         style  = line.style_dashed,
         width  = 1
     )

// ----------------------- YESTERDAY LEVELS -----------------------
f_calcYesterday() =>
    _h  = high[1]
    _l  = low[1]
    _bh = math.max(open[1], close[1])
    _bl = math.min(open[1], close[1])
    [_h, _l, _bh, _bl]

[yestHigh, yestLow, yestBodyHigh, yestBodyLow] = request.security(syminfo.tickerid, "D", f_calcYesterday(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

// เวลาล่วงหน้าสำหรับยืดเส้นในวันล่าสุด
barTimeDiff = ta.change(time)
var int timeStep = na
if not na(barTimeDiff)
    timeStep := barTimeDiff
int futureTime = time + (nz(timeStep, 60000) * extendBars)

var line l_yestHigh   = na
var line l_yestLow    = na
var line l_yestBodyHi = na
var line l_yestBodyLo = na

// ขึ้นวันใหม่ → วาดเส้น 4 เส้นใหม่
if yestOn and isNewDayChart
    lineStyleChoice = f_getLineStyle(yestStyleStr)

    l_yestHigh   := line.new(x1 = time, y1 = yestHigh,     x2 = time, y2 = yestHigh,     xloc = xloc.bar_time, color = yestWickColor, style = lineStyleChoice, width = yestLineWidth)
    l_yestBodyHi := line.new(x1 = time, y1 = yestBodyHigh, x2 = time, y2 = yestBodyHigh, xloc = xloc.bar_time, color = yestBodyColor, style = lineStyleChoice, width = yestLineWidth)
    l_yestBodyLo := line.new(x1 = time, y1 = yestBodyLow,  x2 = time, y2 = yestBodyLow,  xloc = xloc.bar_time, color = yestBodyColor, style = lineStyleChoice, width = yestLineWidth)
    l_yestLow    := line.new(x1 = time, y1 = yestLow,      x2 = time, y2 = yestLow,      xloc = xloc.bar_time, color = yestWickColor, style = lineStyleChoice, width = yestLineWidth)

// ยืดเส้นไปทางขวา (แท่งสุดท้ายยืดไปข้างหน้าตาม extendBars)
if yestOn and not na(l_yestHigh)
    targetTime = barstate.islast ? futureTime : time

    line.set_x2(l_yestHigh,   targetTime)
    line.set_x2(l_yestBodyHi, targetTime)
    line.set_x2(l_yestBodyLo, targetTime)
    line.set_x2(l_yestLow,    targetTime)

// --- Label แนวรับ/แนวต้าน ตามราคาปัจจุบัน ---
var label lbl_yestHigh   = na
var label lbl_yestLow    = na
var label lbl_yestBodyHi = na
var label lbl_yestBodyLo = na

if yestOn and barstate.islast
    transBg = color.new(color.white, 100)

    txt_High   = pdhText
    txt_BodyHi = close > yestBodyHigh ? supText : resText
    txt_BodyLo = close > yestBodyLow  ? supText : resText
    txt_Low    = pdlText

    if na(lbl_yestHigh)
        lbl_yestHigh   := label.new(x = futureTime, y = yestHigh,     text = txt_High,   xloc = xloc.bar_time, textcolor = yestTextColor, color = transBg, style = label.style_label_left, size = size.normal)
        lbl_yestBodyHi := label.new(x = futureTime, y = yestBodyHigh, text = txt_BodyHi, xloc = xloc.bar_time, textcolor = yestTextColor, color = transBg, style = label.style_label_left, size = size.normal)
        lbl_yestBodyLo := label.new(x = futureTime, y = yestBodyLow,  text = txt_BodyLo, xloc = xloc.bar_time, textcolor = yestTextColor, color = transBg, style = label.style_label_left, size = size.normal)
        lbl_yestLow    := label.new(x = futureTime, y = yestLow,      text = txt_Low,    xloc = xloc.bar_time, textcolor = yestTextColor, color = transBg, style = label.style_label_left, size = size.normal)
    else
        label.set_xy(lbl_yestHigh,   futureTime, yestHigh)
        label.set_text(lbl_yestHigh, txt_High)

        label.set_xy(lbl_yestBodyHi, futureTime, yestBodyHigh)
        label.set_text(lbl_yestBodyHi, txt_BodyHi)

        label.set_xy(lbl_yestBodyLo, futureTime, yestBodyLow)
        label.set_text(lbl_yestBodyLo, txt_BodyLo)

        label.set_xy(lbl_yestLow,    futureTime, yestLow)
        label.set_text(lbl_yestLow,  txt_Low)

// =========================================================================
// ======  SECTION 3B: SWEEP & REJECT ALERTS (Old High / Old Low)  =========
// =========================================================================
// ทำงานบน Timeframe ของกราฟที่เปิดอยู่ (เปลี่ยน TF กราฟ = เปลี่ยน TF ที่ใช้ดูแท่งปิดจบ)
// SELL: ราคา sweep Old High (high > Old High) แล้วแท่งเทียนปิดจบใต้ Old High
// BUY : ราคา sweep Old Low  (low  < Old Low ) แล้วแท่งเทียนปิดจบเหนือ Old Low
// ใช้ Old High/Low ของวันปัจจุบันชุดเดียวกับเส้นที่วาด และรีเซ็ตสถานะทุกวันใหม่
// (ต้องเปิดโมดูล White Box + Yesterday Levels ด้านบนก่อน)

string GRP_SWEEP = "Sweep Alerts (Old High / Old Low)"
enableSweepAlert = input.bool(true, "เปิดใช้งาน Sweep Alert", group = GRP_SWEEP, tooltip = "ต้องเปิดโมดูล White Box + Yesterday Levels ด้วย ใช้ Timeframe ของกราฟที่เปิดอยู่")
showSweepMarks   = input.bool(true, "แสดงสัญลักษณ์บนกราฟ", group = GRP_SWEEP)
showOnlyToday    = input.bool(true, "แสดงสัญลักษณ์เฉพาะวันปัจจุบัน", group = GRP_SWEEP, tooltip = "เปิด: เมื่อขึ้นวันใหม่ สัญลักษณ์ของวันก่อนจะถูกลบ เหลือเฉพาะวันปัจจุบัน (ใน Bar Replay จะเป็นวันที่ replay อยู่)")
sweepSizeStr    = input.string("Small", "ขนาดป้าย Sweep", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_SWEEP)
sweepBearColor   = input.color(#FF5252, "สีป้าย Sweep Old High (แดง)", group = GRP_SWEEP)
sweepBullColor   = input.color(#4CAF50, "สีป้าย Sweep Old Low (เขียว)",   group = GRP_SWEEP)

bool sweepOn = enablePdhModule and enableSweepAlert

string sweepLblSize = switch sweepSizeStr
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.tiny

var bool sweptHi = false
var bool sweptLo = false
bool bearSel = false
bool bullSel = false

if sweepOn
    if isNewDayChart
        sweptHi := false
        sweptLo := false

    if high > yestHigh
        sweptHi := true
    if low < yestLow
        sweptLo := true

    // ตัดสินเฉพาะแท่งที่ปิดจบแล้ว
    if barstate.isconfirmed
        if sweptHi and close < yestHigh
            bearSel := true
            sweptHi := false
        if sweptLo and close > yestLow
            bullSel := true
            sweptLo := false

// ชื่อ TF ของกราฟสำหรับแสดงในข้อความ alert
string tfName = timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? "H" + str.tostring(int(timeframe.multiplier / 60)) : "M" + str.tostring(timeframe.multiplier)) : timeframe.period

// สัญลักษณ์บนกราฟ: ใช้ label เพื่อเคลียร์ของวันก่อนเมื่อขึ้นวันใหม่ได้
var array<label> sweepLbls = array.new<label>()
if showSweepMarks
    if showOnlyToday and isNewDayChart
        for lb in sweepLbls
            label.delete(lb)
        array.clear(sweepLbls)
    if bearSel
        array.push(sweepLbls, label.new(bar_index, high, "Sweep", style = label.style_label_down, color = sweepBearColor, textcolor = color.white, size = sweepLblSize))
    if bullSel
        array.push(sweepLbls, label.new(bar_index, low, "Sweep", style = label.style_label_up, color = sweepBullColor, textcolor = color.white, size = sweepLblSize))

alertcondition(bearSel or bullSel, title = "Sweep", message = "Sweep | Sweep Old High/Old Low แล้วแท่งปิดกลับ")

// alert() แบบระบุ TF (เลือก "Any alert() function call" ตอนตั้ง alert)
if bearSel
    alert("Sweep | " + syminfo.ticker + " | Sweep Old High แล้วปิดกลับใต้เส้น | TF: " + tfName + " | Old High = " + str.tostring(yestHigh, format.mintick), alert.freq_once_per_bar_close)

if bullSel
    alert("Sweep | " + syminfo.ticker + " | Sweep Old Low แล้วปิดกลับเหนือเส้น | TF: " + tfName + " | Old Low = " + str.tostring(yestLow, format.mintick), alert.freq_once_per_bar_close)


// =========================================================================
// ===============  SECTION 4: FAIR VALUE GAP [Chai V2] (OPTIONAL)  =========
// =========================================================================
// Original: Fair Value Gap [Chai V2] © Treduminati (Mozilla Public License 2.0)

string GRP_FVG = "Fair Value Gap (FVG)"
fvgEnabled           = input.bool(false, "เปิดใช้งาน Fair Value Gap (FVG)", group = GRP_FVG, tooltip = "เปิด/ปิด Section 4 ทั้งหมด (FVG, iFVG) ค่าเริ่มต้น: ปิด")
fvgBullColor         = input.color(color.new(color.green, 75), "Bullish FVG Color", group = GRP_FVG)
fvgBearColor         = input.color(color.new(color.red, 75), "Bearish FVG Color", group = GRP_FVG)
fvgIColor            = input.color(color.new(color.aqua, 75), "iFVG Color", group = GRP_FVG)

fvgShowMidline       = input.bool(true, "แสดงเส้นกลาง (dashed)", group = GRP_FVG)
fvgShowIFvg          = input.bool(true, "แสดง iFVG", group = GRP_FVG)
fvgMaxActive         = input.int(3, "จำนวน FVG ที่ยังไม่ถูกทะลุสูงสุด (bull + bear รวมกัน)", minval = 1, group = GRP_FVG)
fvgMaxIFvg           = input.int(1, "จำนวน iFVG ที่แสดงสูงสุด", minval = 1, group = GRP_FVG)

fvgExtendBars        = input.int(5, "FVG: ยืดไปทางขวาถึงแท่งปัจจุบัน + X แท่ง", minval = 0, group = GRP_FVG)
fvgIExtendBars       = input.int(5, "iFVG: ยืดไปทางขวาถึงแท่งปัจจุบัน + X แท่ง", minval = 0, group = GRP_FVG)

fvgTextPosY          = input.string("Middle", "ตำแหน่งข้อความ (แนวตั้ง)", options = ["Top", "Middle", "Bottom"], group = GRP_FVG)
fvgTextPosX          = input.string("Right", "ตำแหน่งข้อความ (แนวนอน)", options = ["Left", "Middle", "Right"], group = GRP_FVG)
fvgTextColor         = input.color(color.white, "สีข้อความ", group = GRP_FVG)
fvgTextSizeIn        = input.string("Normal", "ขนาดข้อความ", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_FVG)

fvgBullBorder = color.new(fvgBullColor, 100)
fvgBearBorder = color.new(fvgBearColor, 100)
fvgIBorder    = color.new(fvgIColor,    100)

//----------------------------------------------------
// Arrays
//----------------------------------------------------
var box[]   fvgBullBoxes   = array.new_box()
var label[] fvgBullLabels  = array.new_label()
var line[]  fvgBullLines   = array.new_line()
var int[]   fvgBullLeftIdx = array.new_int()

var box[]   fvgBearBoxes   = array.new_box()
var label[] fvgBearLabels  = array.new_label()
var line[]  fvgBearLines   = array.new_line()
var int[]   fvgBearLeftIdx = array.new_int()

var box[]   fvgIBoxes   = array.new_box()
var label[] fvgILabels  = array.new_label()
var line[]  fvgILines   = array.new_line()
var int[]   fvgILeftIdx = array.new_int()
var int[]   fvgIDir     = array.new_int()  // +1 bullish iFVG, -1 bearish iFVG

//----------------------------------------------------
// Helper
//----------------------------------------------------
f_fvgTextY(_pos, _top, _bot) =>
    y = (_top + _bot) / 2.0
    if _pos == "Top"
        y := _top
    else if _pos == "Bottom"
        y := _bot
    y

f_fvgTextX(_pos, _left, _right) =>
    x = math.floor((_left + _right) / 2)
    if _pos == "Left"
        x := _left
    else if _pos == "Right"
        x := _right
    x

f_fvgTextSize(_s) =>
    sz = size.normal
    if _s == "Tiny"
        sz := size.tiny
    else if _s == "Small"
        sz := size.small
    else if _s == "Large"
        sz := size.large
    else if _s == "Huge"
        sz := size.huge
    sz

fvgTextSize = f_fvgTextSize(fvgTextSizeIn)

//----------------------------------------------------
// Prune aktive FVGs
//----------------------------------------------------
f_fvgPrune() =>
    while (array.size(fvgBullBoxes) + array.size(fvgBearBoxes)) > fvgMaxActive
        if array.size(fvgBullBoxes) > 0 and (array.size(fvgBearBoxes) == 0 or array.get(fvgBullLeftIdx, 0) <= array.get(fvgBearLeftIdx, 0))
            box.delete(array.get(fvgBullBoxes, 0))
            label.delete(array.get(fvgBullLabels, 0))
            line.delete(array.get(fvgBullLines, 0))
            array.remove(fvgBullBoxes, 0)
            array.remove(fvgBullLabels, 0)
            array.remove(fvgBullLines, 0)
            array.remove(fvgBullLeftIdx, 0)
        else
            box.delete(array.get(fvgBearBoxes, 0))
            label.delete(array.get(fvgBearLabels, 0))
            line.delete(array.get(fvgBearLines, 0))
            array.remove(fvgBearBoxes, 0)
            array.remove(fvgBearLabels, 0)
            array.remove(fvgBearLines, 0)
            array.remove(fvgBearLeftIdx, 0)

//----------------------------------------------------
// FVG → iFVG
//----------------------------------------------------
f_fvgToIFvg(_bx, _lb, _ln, _leftIdx, _dir) =>
    right = bar_index + fvgIExtendBars
    box.set_right(_bx, right)
    box.set_bgcolor(_bx, fvgIColor)
    box.set_border_color(_bx, fvgIBorder)

    if not na(_ln)
        line.set_x2(_ln, right)
        line.set_color(_ln, fvgIColor)

    label.set_text(_lb, "iFVG")
    label.set_x(_lb, f_fvgTextX(fvgTextPosX, box.get_left(_bx), right))
    label.set_y(_lb, f_fvgTextY(fvgTextPosY, box.get_top(_bx), box.get_bottom(_bx)))
    label.set_textcolor(_lb, fvgTextColor)
    label.set_size(_lb, fvgTextSize)
    label.set_color(_lb, color.new(color.black, 100))

    array.push(fvgIBoxes, _bx)
    array.push(fvgILabels, _lb)
    array.push(fvgILines, _ln)
    array.push(fvgILeftIdx, _leftIdx)
    array.push(fvgIDir, _dir)

    if array.size(fvgIBoxes) > fvgMaxIFvg
        box.delete(array.get(fvgIBoxes, 0))
        label.delete(array.get(fvgILabels, 0))
        line.delete(array.get(fvgILines, 0))
        array.remove(fvgIBoxes, 0)
        array.remove(fvgILabels, 0)
        array.remove(fvgILines, 0)
        array.remove(fvgILeftIdx, 0)
        array.remove(fvgIDir, 0)

//----------------------------------------------------
// Laufende Aktualisierung
//----------------------------------------------------
fvgNewRight  = bar_index + fvgExtendBars
fvgNewRightI = bar_index + fvgIExtendBars

if array.size(fvgBullBoxes) > 0
    for fi = 0 to array.size(fvgBullBoxes) - 1
        bx = array.get(fvgBullBoxes, fi)
        lb = array.get(fvgBullLabels, fi)
        ln = array.get(fvgBullLines, fi)
        box.set_right(bx, fvgNewRight)
        label.set_x(lb, f_fvgTextX(fvgTextPosX, box.get_left(bx), fvgNewRight))
        if not na(ln)
            line.set_x2(ln, fvgNewRight)

if array.size(fvgBearBoxes) > 0
    for fi = 0 to array.size(fvgBearBoxes) - 1
        bx = array.get(fvgBearBoxes, fi)
        lb = array.get(fvgBearLabels, fi)
        ln = array.get(fvgBearLines, fi)
        box.set_right(bx, fvgNewRight)
        label.set_x(lb, f_fvgTextX(fvgTextPosX, box.get_left(bx), fvgNewRight))
        if not na(ln)
            line.set_x2(ln, fvgNewRight)

if array.size(fvgIBoxes) > 0
    for fi = 0 to array.size(fvgIBoxes) - 1
        bx = array.get(fvgIBoxes, fi)
        lb = array.get(fvgILabels, fi)
        ln = array.get(fvgILines, fi)
        box.set_right(bx, fvgNewRightI)
        label.set_x(lb, f_fvgTextX(fvgTextPosX, box.get_left(bx), fvgNewRightI))
        if not na(ln)
            line.set_x2(ln, fvgNewRightI)

//----------------------------------------------------
// Hauptlogik – nur Bar Close
//----------------------------------------------------
if barstate.isconfirmed and fvgEnabled
    fvgEnoughHist = bar_index >= 2
    fvgBullCond = fvgEnoughHist and (low > high[2])
    fvgBearCond = fvgEnoughHist and (high < low[2])

    // iFVG invalidieren
    if array.size(fvgIBoxes) > 0
        for fi = array.size(fvgIBoxes) - 1 to 0
            bx  = array.get(fvgIBoxes, fi)
            lb  = array.get(fvgILabels, fi)
            ln  = array.get(fvgILines, fi)
            dir = array.get(fvgIDir, fi)

            top = box.get_top(bx)
            bot = box.get_bottom(bx)

            invalid = (dir == 1 and close < bot) or (dir == -1 and close > top)
            if invalid
                box.delete(bx)
                label.delete(lb)
                line.delete(ln)
                array.remove(fvgIBoxes, fi)
                array.remove(fvgILabels, fi)
                array.remove(fvgILines, fi)
                array.remove(fvgILeftIdx, fi)
                array.remove(fvgIDir, fi)

    // Bullish FVG invalidieren
    if array.size(fvgBullBoxes) > 0
        for fi = array.size(fvgBullBoxes) - 1 to 0
            bx = array.get(fvgBullBoxes, fi)
            lb = array.get(fvgBullLabels, fi)
            ln = array.get(fvgBullLines, fi)
            li = array.get(fvgBullLeftIdx, fi)

            if close < box.get_bottom(bx)
                if fvgShowIFvg
                    f_fvgToIFvg(bx, lb, ln, li, -1)
                else
                    box.delete(bx)
                    label.delete(lb)
                    line.delete(ln)

                array.remove(fvgBullBoxes, fi)
                array.remove(fvgBullLabels, fi)
                array.remove(fvgBullLines, fi)
                array.remove(fvgBullLeftIdx, fi)

    // Bearish FVG invalidieren
    if array.size(fvgBearBoxes) > 0
        for fi = array.size(fvgBearBoxes) - 1 to 0
            bx = array.get(fvgBearBoxes, fi)
            lb = array.get(fvgBearLabels, fi)
            ln = array.get(fvgBearLines, fi)
            li = array.get(fvgBearLeftIdx, fi)

            if close > box.get_top(bx)
                if fvgShowIFvg
                    f_fvgToIFvg(bx, lb, ln, li, 1)
                else
                    box.delete(bx)
                    label.delete(lb)
                    line.delete(ln)

                array.remove(fvgBearBoxes, fi)
                array.remove(fvgBearLabels, fi)
                array.remove(fvgBearLines, fi)
                array.remove(fvgBearLeftIdx, fi)

    // Neue Bullish FVG
    if fvgBullCond
        left = bar_index - 2
        mid  = (low + high[2]) / 2.0
        b = box.new(left, low, fvgNewRight, high[2], bgcolor = fvgBullColor, border_color = fvgBullBorder)
        l = label.new(
            f_fvgTextX(fvgTextPosX, left, fvgNewRight),
            f_fvgTextY(fvgTextPosY, low, high[2]),
            "+ FVG",
            style = label.style_label_center,
            textcolor = fvgTextColor,
            size = fvgTextSize,
            color = color.new(color.black, 100)
        )
        ln = fvgShowMidline ? line.new(left, mid, fvgNewRight, mid, color = fvgBullColor, style = line.style_dashed) : na
        array.push(fvgBullBoxes, b)
        array.push(fvgBullLabels, l)
        array.push(fvgBullLines, ln)
        array.push(fvgBullLeftIdx, left)
        f_fvgPrune()

    // Neue Bearish FVG
    if fvgBearCond
        left = bar_index - 2
        mid  = (low[2] + high) / 2.0
        b = box.new(left, low[2], fvgNewRight, high, bgcolor = fvgBearColor, border_color = fvgBearBorder)
        l = label.new(
            f_fvgTextX(fvgTextPosX, left, fvgNewRight),
            f_fvgTextY(fvgTextPosY, low[2], high),
            "- FVG",
            style = label.style_label_center,
            textcolor = fvgTextColor,
            size = fvgTextSize,
            color = color.new(color.black, 100)
        )
        ln = fvgShowMidline ? line.new(left, mid, fvgNewRight, mid, color = fvgBearColor, style = line.style_dashed) : na
        array.push(fvgBearBoxes, b)
        array.push(fvgBearLabels, l)
        array.push(fvgBearLines, ln)
        array.push(fvgBearLeftIdx, left)
        f_fvgPrune()


// =========================================================================
// ====================  SECTION 5: CISD (+CISD / -CISD)  ===================
// =========================================================================
// +CISD: ราคาปิดเหนือราคาเปิดของแท่งแรกในชุดแท่งแดงล่าสุด (ชุดแท่งขาลงที่ติดกัน)
// -CISD: ราคาปิดใต้ราคาเปิดของแท่งแรกในชุดแท่งเขียวล่าสุด (ชุดแท่งขาขึ้นที่ติดกัน)
// เส้นที่ยังไม่ถูกทะลุจะยืดไปข้างหน้า เมื่อถูกทะลุ (แท่งปิดจบ) เส้นจะหยุดที่แท่งนั้นพร้อมข้อความ

string GRP_CISD = "CISD (+CISD / -CISD)"
cisdEnabled       = input.bool(true, "เปิดใช้งาน CISD", group = GRP_CISD, tooltip = "เปิด/ปิด Section 5 ทั้งหมด ใช้ Timeframe ของกราฟที่เปิดอยู่")
cisdBullLineColor = input.color(#4CAF50, "สีเส้น +CISD", group = GRP_CISD)
cisdBearLineColor = input.color(#FF5252, "สีเส้น -CISD", group = GRP_CISD)
cisdBullTextColor = input.color(#4CAF50, "สีข้อความ +CISD", group = GRP_CISD)
cisdBearTextColor = input.color(#FF5252, "สีข้อความ -CISD", group = GRP_CISD)
cisdLineWidth     = input.int(1, "ความหนาเส้น", minval = 1, maxval = 5, group = GRP_CISD)
cisdSizeStr       = input.string("Small", "ขนาดข้อความ", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_CISD)
cisdExtendBars    = input.int(5, "ยืดเส้นที่ยังไม่ถูกทะลุไปข้างหน้า (จำนวนแท่ง)", minval = 0, group = GRP_CISD)
cisdMaxHist       = input.int(6, "จำนวนเส้นที่ถูกทะลุแล้วที่เก็บไว้บนกราฟ", minval = 0, maxval = 100, group = GRP_CISD)
cisdShowPanel     = input.bool(true, "แสดงกล่องสถานะ CISD ล่าสุด (CISD ตอนนี้)", group = GRP_CISD, tooltip = "แสดง Buy เมื่อสัญญาณล่าสุดเป็น +CISD และ Sell เมื่อสัญญาณล่าสุดเป็น -CISD")
cisdPanelPosStr   = input.string("Bottom Right", "ตำแหน่งกล่องสถานะ", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = GRP_CISD)

string cisdLblSize = switch cisdSizeStr
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.tiny

var int   cisdLastDir = 0
var int   cisdCurrent = 0   // สัญญาณล่าสุด: 1 = +CISD (Buy), -1 = -CISD (Sell)
var float cisdBearLvl = na   // ระดับ +CISD ที่รอทะลุ (open ของชุดแท่งแดงล่าสุด)
var line  cisdBearLn  = na
var label cisdBearLb  = na
var float cisdBullLvl = na   // ระดับ -CISD ที่รอทะลุ (open ของชุดแท่งเขียวล่าสุด)
var line  cisdBullLn  = na
var label cisdBullLb  = na
var array<line>  cisdHistLn = array.new<line>()
var array<label> cisdHistLb = array.new<label>()

if cisdEnabled and barstate.isconfirmed
    int cisdDir = close > open ? 1 : close < open ? -1 : cisdLastDir

    // เริ่มชุดแท่งใหม่ → ตั้งระดับใหม่แทนระดับเดิมที่ยังไม่ถูกทะลุ
    if cisdDir != cisdLastDir
        if cisdDir == -1
            if not na(cisdBearLn)
                line.delete(cisdBearLn)
                label.delete(cisdBearLb)
            cisdBearLvl := open
            cisdBearLn  := line.new(bar_index, open, bar_index + cisdExtendBars, open, color = cisdBullLineColor, width = cisdLineWidth)
            cisdBearLb  := label.new(bar_index + cisdExtendBars, open, "+CISD", style = label.style_label_left, color = color.new(color.black, 100), textcolor = cisdBullTextColor, size = cisdLblSize)
        else if cisdDir == 1
            if not na(cisdBullLn)
                line.delete(cisdBullLn)
                label.delete(cisdBullLb)
            cisdBullLvl := open
            cisdBullLn  := line.new(bar_index, open, bar_index + cisdExtendBars, open, color = cisdBearLineColor, width = cisdLineWidth)
            cisdBullLb  := label.new(bar_index + cisdExtendBars, open, "-CISD", style = label.style_label_left, color = color.new(color.black, 100), textcolor = cisdBearTextColor, size = cisdLblSize)
        cisdLastDir := cisdDir

    // +CISD ถูกทะลุ: ปิดเหนือ open ของชุดแท่งแดง
    if not na(cisdBearLvl) and close > cisdBearLvl
        line.set_x2(cisdBearLn, bar_index)
        label.set_x(cisdBearLb, bar_index)
        array.push(cisdHistLn, cisdBearLn)
        array.push(cisdHistLb, cisdBearLb)
        cisdCurrent := 1
        cisdBearLvl := na
        cisdBearLn  := na
        cisdBearLb  := na

    // -CISD ถูกทะลุ: ปิดใต้ open ของชุดแท่งเขียว
    if not na(cisdBullLvl) and close < cisdBullLvl
        line.set_x2(cisdBullLn, bar_index)
        label.set_x(cisdBullLb, bar_index)
        array.push(cisdHistLn, cisdBullLn)
        array.push(cisdHistLb, cisdBullLb)
        cisdCurrent := -1
        cisdBullLvl := na
        cisdBullLn  := na
        cisdBullLb  := na

    // จำกัดจำนวนเส้นที่ถูกทะลุแล้ว
    while array.size(cisdHistLn) > cisdMaxHist
        line.delete(array.shift(cisdHistLn))
        label.delete(array.shift(cisdHistLb))

// ยืดเส้นที่ยังรอทะลุไปข้างหน้าตามแท่งปัจจุบัน
if cisdEnabled
    if not na(cisdBearLn)
        line.set_x2(cisdBearLn, bar_index + cisdExtendBars)
        label.set_x(cisdBearLb, bar_index + cisdExtendBars)
    if not na(cisdBullLn)
        line.set_x2(cisdBullLn, bar_index + cisdExtendBars)
        label.set_x(cisdBullLb, bar_index + cisdExtendBars)

// --- กล่องสถานะ CISD ล่าสุด ---
string cisdPanelPos = switch cisdPanelPosStr
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    => position.bottom_right

var table cisdTbl = cisdShowPanel ? table.new(cisdPanelPos, 1, 3, bgcolor = #1E222D, border_color = #434651, border_width = 1, frame_color = #434651, frame_width = 1) : na

if cisdEnabled and cisdShowPanel and barstate.islast
    string cisdTfTxt = timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(int(timeframe.multiplier / 60)) + "H" : str.tostring(timeframe.multiplier) + "M") : timeframe.period
    string cisdNowTxt = cisdCurrent == 1 ? "Buy" : cisdCurrent == -1 ? "Sell" : "-"
    table.cell(cisdTbl, 0, 0, syminfo.ticker + ", " + cisdTfTxt, text_color = #B2B5BE, text_size = size.small, bgcolor = #1E222D)
    table.cell(cisdTbl, 0, 1, "CISD ตอนนี้", text_color = color.white, text_size = size.small, bgcolor = #434651)
    color cisdNowCol = cisdCurrent == 1 ? cisdBullTextColor : cisdCurrent == -1 ? cisdBearTextColor : color.white
    table.cell(cisdTbl, 0, 2, cisdNowTxt, text_color = cisdNowCol, text_size = size.normal, bgcolor = #1E222D)


// =========================================================================
// ===========  SECTION 6: FIBO PULLBACK จาก SWING (OPTIONAL)  =============
// =========================================================================
// หา Swing High / Swing Low ล่าสุดบน TF ของกราฟที่เปิดอยู่ (เปลี่ยน TF กราฟ = ใช้ Swing ของ TF นั้น)
// แล้วขีดเส้นประบางๆ ที่ระดับ Fibo เพื่อคาดการณ์ระยะการพักตัว (Pullback)
// ขาขึ้น (Low -> High): วัดลงมาจาก High | ขาลง (High -> Low): วัดขึ้นไปจาก Low
// ค่าเริ่มต้น: ปิด

string GRP_FBO = "Fibo Pullback (Swing)"
fboEnabled    = input.bool(false, "เปิดใช้งาน Fibo Pullback", group = GRP_FBO, tooltip = "เปิด/ปิด Section 6 ทั้งหมด (เส้น Fibo จาก Swing ล่าสุดบน TF ของกราฟ) ค่าเริ่มต้น: ปิด")
fboSwingLen   = input.int(5, "Swing Length (จำนวนแท่งซ้าย/ขวา)", minval = 2, group = GRP_FBO, tooltip = "ยิ่งมาก Swing ยิ่งใหญ่และเกิดน้อยลง ยิ่งน้อย Swing ยิ่งถี่")
fboLevelsStr  = input.string("0.382, 0.5, 0.618, 0.786", "ระดับ Fibo ที่ต้องการ (คั่นด้วย ,)", group = GRP_FBO)
fboStyleStr   = input.string("Dashed", "รูปแบบเส้น", options = ["Dashed", "Dotted"], group = GRP_FBO)
fboColor      = input.color(color.new(#ffb300, 10), "สีเส้น Fibo", group = GRP_FBO)
fboShowLabels = input.bool(true, "แสดงตัวเลข Fibo และราคา", group = GRP_FBO)
fboLblSizeStr = input.string("Normal", "ขนาดตัวอักษร Fibo", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_FBO)
fboShowLeg    = input.bool(true, "แสดงเส้นขา Swing (ประ)", group = GRP_FBO)
fboExtendBars = input.int(15, "ยืดเส้นไปทางขวา (จำนวนแท่ง)", minval = 0, group = GRP_FBO)

float fboPh = ta.pivothigh(high, fboSwingLen, fboSwingLen)
float fboPl = ta.pivotlow(low, fboSwingLen, fboSwingLen)

var float fboHi    = na
var int   fboHiIdx = na
var float fboLo    = na
var int   fboLoIdx = na

if not na(fboPh)
    fboHi    := fboPh
    fboHiIdx := bar_index - fboSwingLen
if not na(fboPl)
    fboLo    := fboPl
    fboLoIdx := bar_index - fboSwingLen

string fboLblSize = switch fboLblSizeStr
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    => size.normal

string fboLineStyle = fboStyleStr == "Dotted" ? line.style_dotted : line.style_dashed

var array<line>  fboLines = array.new<line>()
var array<label> fboLbls  = array.new<label>()
var line         fboLegLn = na

if barstate.islast
    for fboL in fboLines
        line.delete(fboL)
    fboLines.clear()
    for fboLb in fboLbls
        label.delete(fboLb)
    fboLbls.clear()
    line.delete(fboLegLn)

    if fboEnabled and not na(fboHi) and not na(fboLo) and fboHi > fboLo
        bool  fboUp  = fboHiIdx > fboLoIdx
        float fboRng = fboHi - fboLo
        int   fboX1  = math.max(fboHiIdx, fboLoIdx)
        int   fboX2  = bar_index + fboExtendBars

        if fboShowLeg
            fboLegLn := line.new(math.min(fboHiIdx, fboLoIdx), fboUp ? fboLo : fboHi, fboX1, fboUp ? fboHi : fboLo, color = color.new(fboColor, 40), style = line.style_dashed, width = 1)

        string[] fboParts = str.split(fboLevelsStr, ",")
        for fboP in fboParts
            float fboR = str.tonumber(str.trim(fboP))
            if not na(fboR)
                float fboPx = fboUp ? fboHi - fboR * fboRng : fboLo + fboR * fboRng
                fboLines.push(line.new(fboX1, fboPx, fboX2, fboPx, color = fboColor, style = fboLineStyle, width = 1))
                if fboShowLabels
                    fboLbls.push(label.new(fboX2, fboPx, str.tostring(fboR) + "  " + str.tostring(fboPx, format.mintick), style = label.style_label_left, color = color.new(color.white, 100), textcolor = fboColor, size = fboLblSize))
````
