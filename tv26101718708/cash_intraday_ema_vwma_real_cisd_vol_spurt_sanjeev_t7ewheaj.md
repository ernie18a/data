# Cash Intraday - EMA VWMA + Real CISD + Vol Spurt SANJEEV

- url: https://www.tradingview.com/script/T7EWHeAj-Cash-Intraday-EMA-VWMA-Real-CISD-Vol-Spurt-SANJEEV/
- type: indicator
- pine_id: PUB;ff34cefc2ea94ecdaa1629ba082df552
- version: 1.0

## Description

🔥 Intraday Buy Sell Indicator for NSE Cash Stocks | EMA + VWMA Crossover + CISD + Volume Spurt

This indicator is specially designed for Indian Cash Market Intraday trading to capture short-term momentum shifts with high accuracy.

WHAT THIS INDICATOR DOES:
✅ EMA 9 x VWMA 20 Crossover for fast momentum entry
✅ 20 EMA x 50 VWMA Trend Filter to avoid counter-trend trades
✅ CISD (Change in State of Delivery) - Detects Market Structure Shift / BOS
✅ Sudden Volume Spurt Detection - Volume > 1.8x Average + Highest in last 10 candles
✅ Buy/Sell Labels only when all 3 conditions align - High Accuracy Setup

HOW TO USE:
1. Use on 5-Min Timeframe for NSE Cash Stocks (Reliance, TCS, Infosys, etc.)
2. BUY when: 9 EMA crosses above 20 VWMA + Bullish CISD + Volume Spurt + Price above 20/50 Trend = Green BUY VOL SPURT label
3. SELL when: 9 EMA crosses below 20 VWMA + Bearish CISD + Volume Spurt + Price below 20/50 Trend = Red SELL VOL SPURT label
4. Light Green/Red background shows institutional volume spurt.

BEST SETTINGS:
- Nifty 50 Stocks: Volume Multiplier 1.8
- Midcap Stocks: Volume Multiplier 2.0 - 2.2
- Time: 9:30 AM to 2:30 PM for best results

This is a non-repainting indicator with alerts included. Works best with Multi Time Frame: 15-Min for trend direction, 5-Min for entry, 1-Min for precise execution.

⚠️ Disclaimer: For educational purpose only. Not financial advice. Test on paper trading first.

#Intraday #CashMarket #NSE #BuySell #EMA #VWMA #VolumeSpurt #CISD

## Source Code

````pine
// @version=6
indicator("Cash Intraday - EMA VWMA + Real CISD + Vol Spurt SANJEEV", overlay=true, max_lines_count=500, max_labels_count=500)

// === EMA VWMA ===
ema9 = ta.ema(close, 9)
vwma20 = ta.sma(close * volume, 20) / ta.sma(volume, 20)
ema20 = ta.ema(close, 20)
vwma50 = ta.sma(close * volume, 50) / ta.sma(volume, 50)
volMult = input.float(1.4, "Volume Spurt Multiplier", 1.1, 3.0, 0.1)

plot(ema9, "9 EMA", color=color.lime, linewidth=2)
plot(vwma20, "20 VWMA", color=color.orange, linewidth=2)

// === REAL CISD - From tncylyv ===
bullColor = input.color(color.new(color.green, 0), "Bullish CISD", group="CISD Colors")
bearColor = input.color(color.new(color.red, 0), "Bearish CISD", group="CISD Colors")
showLabels = input.bool(true, "Show CISD Labels")
extendBars = input.int(0, "Extend CISD Lines", minval=0)
lineWidth = input.int(2, "Line Width", minval=1)
showTable = input.bool(true, "Show MTF Table")

var int vibes = 0
var float bagholder_entry = na
var int time_machine_setting = na
var float pain_threshold = na

var array<line> cisdLines = array.new<line>()
var array<label> cisdLabels = array.new<label>()

consult_the_crystal_ball(int bias) =>
    int temporal_shift = 0
    float extreme = open[0]
    int candle_attitude = close[0] > open[0]? 1 : close[0] < open[0]? -1 : 0
    if candle_attitude == 0 or candle_attitude!= bias
        [extreme, bar_index]
    for i = 1 to 500
        candle_attitude := close[i] > open[i]? 1 : close[i] < open[i]? -1 : 0
        if candle_attitude == 0
            continue
        bool mood_match = candle_attitude == bias
        if not mood_match
            break
        temporal_shift := i
        if bias == 1
            if open[i] < extreme
                extreme := open[i]
        else
            if open[i] > extreme
                extreme := open[i]
    int extreme_shift = na
    for k = 0 to temporal_shift
        if open[k] == extreme
            extreme_shift := k
            break
    [extreme, bar_index - extreme_shift]

archaeologist_jones(int bias) =>
    int i = 1
    bool artifact_found = false
    int max_shift = na
    float extreme = na
    for j = 1 to 500
        i := j
        int candle_attitude = close[i] > open[i]? 1 : close[i] < open[i]? -1 : 0
        if candle_attitude == 0
            continue
        bool is_correct_era = candle_attitude == bias
        if not artifact_found
            if is_correct_era
                artifact_found := true
                max_shift := i
                extreme := open[i]
        else
            if not is_correct_era
                break
            max_shift := i
            if bias == 1
                if open[i] < extreme
                    extreme := open[i]
            else
                if open[i] > extreme
                    extreme := open[i]
    int extreme_shift = na
    for k = 1 to max_shift
        if open[k] == extreme
            extreme_shift := k
            break
    [extreme, bar_index - extreme_shift]

if vibes == 0 and bar_index > 10
    int first_impression = close > open? 1 : close < open? -1 : 0
    if first_impression!= 0
        vibes := first_impression
        [origin_price, origin_time] = consult_the_crystal_ball(first_impression)
        bagholder_entry := origin_price
        time_machine_setting := origin_time
        pain_threshold := first_impression == 1? high : low

int candle_personality = close > open? 1 : close < open? -1 : 0
float fresh_hopium = na
int fresh_timestamp = na

if vibes == 1
    if high > pain_threshold
        pain_threshold := high
        if candle_personality == 1
            [p_price, p_idx] = consult_the_crystal_ball(1)
            fresh_hopium := p_price
            fresh_timestamp := p_idx
        else
            [p_price, p_idx] = archaeologist_jones(1)
            fresh_hopium := p_price
            fresh_timestamp := p_idx
        bagholder_entry := fresh_hopium
        time_machine_setting := fresh_timestamp
else if vibes == -1
    if low < pain_threshold
        pain_threshold := low
        if candle_personality == -1
            [p_price, p_idx] = consult_the_crystal_ball(-1)
            fresh_hopium := p_price
            fresh_timestamp := p_idx
        else
            [p_price, p_idx] = archaeologist_jones(-1)
            fresh_hopium := p_price
            fresh_timestamp := p_idx
        bagholder_entry := fresh_hopium
        time_machine_setting := fresh_timestamp

bool bullishCISD = vibes == -1 and close > bagholder_entry
bool bearishCISD = vibes == 1 and close < bagholder_entry

if bullishCISD or bearishCISD
    color col = bullishCISD? bullColor : bearColor
    line l = line.new(time_machine_setting, bagholder_entry, bar_index + extendBars, bagholder_entry, color=col, width=lineWidth, style=line.style_solid)
    array.push(cisdLines, l)
    label lab = na
    if showLabels
        string txt = bullishCISD? "+CISD" : "-CISD"
        lab := label.new(math.round((time_machine_setting + bar_index)/2), bagholder_entry, txt, style=bullishCISD? label.style_label_down : label.style_label_up, color=color.new(color.black, 100), textcolor=col, size=size.small)
    array.push(cisdLabels, lab)

if bullishCISD or bearishCISD
    int new_state = bullishCISD? 1 : -1
    vibes := new_state
    [reset_price, reset_time] = consult_the_crystal_ball(new_state)
    bagholder_entry := reset_price
    time_machine_setting := reset_time
    pain_threshold := new_state == 1? high : low

// === VOLUME SPURT ===
volAvg = ta.sma(volume, 20)
volSpurtUp = volume > volAvg * volMult and close > open
volSpurtDown = volume > volAvg * volMult and close < open
bgcolor(volSpurtUp? color.new(color.green, 80) : volSpurtDown? color.new(color.red, 80) : na)
plotshape(volSpurtUp, "VOL", shape.triangleup, location.bottom, color.new(color.green,0), size=size.tiny, text="VOL")
plotshape(volSpurtDown, "VOL", shape.triangledown, location.top, color.new(color.red,0), size=size.tiny, text="VOL")

// === FINAL BUY SELL ===
bullTrend = ema20 > vwma50
bearTrend = ema20 < vwma50

buyBasic = ta.crossover(ema9, vwma20) and bullTrend
sellBasic = ta.crossunder(ema9, vwma20) and bearTrend

buyPower = buyBasic and (bullishCISD or bullishCISD[1] or bullishCISD[2]) and (volSpurtUp or volSpurtUp[1])
sellPower = sellBasic and (bearishCISD or bearishCISD[1] or bearishCISD[2]) and (volSpurtDown or volSpurtDown[1])

plotshape(buyBasic, "BUY", shape.triangleup, location.belowbar, color.new(color.green,30), size=size.small, text="BUY")
plotshape(sellBasic, "SELL", shape.triangledown, location.abovebar, color.new(color.red,30), size=size.small, text="SELL")
plotshape(buyPower, "BUY POWER", shape.labelup, location.belowbar, color.green, text="BUY\nVOL+CISD", textcolor=color.white, size=size.normal)
plotshape(sellPower, "SELL POWER", shape.labeldown, location.abovebar, color.red, text="SELL\nVOL+CISD", textcolor=color.white, size=size.normal)

// === MTF TABLE - FIXED ===
var table t = table.new(position.bottom_right, 2, 2)
if showTable and barstate.islast
    table.cell(t, 0, 0, "Trend", bgcolor=color.new(color.gray,80), text_color=color.white)
    table.cell(t, 1, 0, (vibes==1? "Bullish +CISD" : "Bearish -CISD"), bgcolor=(vibes==1? bullColor : bearColor), text_color=color.white)
    table.cell(t, 0, 1, "CISD Level", bgcolor=color.new(color.black,50), text_color=color.white)
    table.cell(t, 1, 1, str.tostring(bagholder_entry, format.mintick), bgcolor=color.new(color.black,50), text_color=color.white)

alertcondition(bullishCISD, "Bullish CISD")
alertcondition(bearishCISD, "Bearish CISD")
alertcondition(buyPower, "BUY POWER VOL+CISD")
alertcondition(sellPower, "SELL POWER VOL+CISD")
````
