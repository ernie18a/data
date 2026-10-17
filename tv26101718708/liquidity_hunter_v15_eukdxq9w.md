# Liquidity Hunter v1.5

- url: https://www.tradingview.com/script/EuKdxQ9w-Liquidity-Hunter-v1-5/
- type: indicator
- pine_id: PUB;9289b4a9f35c4ad7a2d134413528a124
- version: 1.0

## Description

[b]Liquidity Hunter v1.5
[/b]
Part of the Hunters Framework ... WHERE / WHEN / WHY
Liquidity Hunter answers WHERE ... where are the levels that matter?

Detects buyside and sellside liquidity zones from clustered swing highs/lows, then tracks how price interacts with them: approaching, sweeping, or breaking through.

Built on the LuxAlgo Buyside/Sellside Liquidity concept (CC BY-NC-SA 4.0) with significant enhancements for practical trading.

[b]WHAT IT SHOWS
[/b]
Liquidity zones are drawn where multiple swing highs or lows cluster at similar prices. These are levels where stop orders accumulate ... the fuel that moves price. The indicator detects these clusters and tracks their lifecycle.

Labels use intuitive directional naming:
- Buy Zone (green) ... sellside liquidity at swing lows. Price sweeps below, grabs stops, bounces up. You buy here.
- Sell Zone (red) ... buyside liquidity at swing highs. Price sweeps above, grabs stops, rejects down. You sell here.

[b]ENHANCED FEATURES
[/b]
Touch Count (Strength Weighting)
Each level shows how many times price has tested it. More touches = more stops accumulated = stronger reaction expected. Labels display the count: "Buy Zone [5]" means 5 touches.
- 7+ touches = STRONG
- 5-6 touches = MODERATE
- Below 5 = WEAK

Sweep vs Break Detection
Not all liquidity interactions are equal.
- Sweep = price wicks through the level but closes back inside. Stops triggered, reversal likely. Orange markers.
- Break = price closes through the level. Structure broken, level invalidated. Level turns gray.
- Arrow signals appear on confirmed sweeps for clear visual entry cues.

EMA Sweep Filter
Filters sweep signals by EMA trend alignment. Only fires when the sweep direction agrees with the EMA trend.
- With Trend mode: buy sweeps valid above EMA, sell sweeps valid below EMA
- Counter Trend mode: opposite (works for specific instruments)
- Configurable EMA length (default 50)
- Diamond-shaped arrows distinguish EMA-filtered signals from raw sweeps
- Backtested on BTC 1H with EMA50: 76.5% WR, PF 4.87

Proximity Alerts
Alerts fire when price approaches a level within a configurable ATR distance (default 2x ATR). Gives you time to prepare before the sweep happens. Optional proximity zone bands show the trigger area.

Liquidity Voids
Detects gaps in the candle structure where price moved fast with no resting orders. These voids tend to get filled. Toggle on/off with bull/bear coloring.

WaveTrend Context in Alerts
When enabled, every alert includes the current WaveTrend state (bull/bear, WT2 level, overbought/oversold). This gives you instant confluence without checking another indicator. Works with Trend Hunter settings (channel 9, average 12, SMA 3).

Nearest Level Display
Dashboard showing distance to the nearest Buy Zone and Sell Zone with touch count and strength rating. Configurable position and size.

[b]ALERTS[/b]

11 individual alertconditions for granular webhook/notification setup:

Sweep signals (raw):
- Buy Zone Swept (potential long)
- Sell Zone Swept (potential short)
- Any Sweep Signal

EMA-filtered sweeps:
- EMA BUY ... sweep + trend aligned
- EMA SELL ... sweep + trend aligned
- Any EMA Sweep Signal

Structure breaks:
- Buy Zone Broken (bearish structure break)
- Sell Zone Broken (bullish structure break)

Proximity:
- Approaching Buy Zone
- Approaching Sell Zone
- Approaching Any Level

All alert messages include level price, touch count, strength rating, and WT state.

HOW IT FITS THE FRAMEWORK

The Hunters Framework uses three indicators together:
1. Liquidity Hunter (this indicator) ... finds WHERE the key levels are
2. Trend Hunter ... finds WHEN to enter (WaveTrend MTF alignment, dots, pullbacks)
3. RSI+StochRSI ... tells you WHY (momentum divergence, confirmation)

Workflow: Liquidity Hunter shows you the battlefield (where stops sit). Trend Hunter tells you when the army is marching (trend direction + timing). RSI confirms whether the momentum supports the trade.

[b]SETTINGS[/b]

Detection Length ... swing detection lookback (default 7, range 3-13)
Margin ... how close swing points must be to cluster (default 6.9)
EMA Length ... trend filter for sweep signals (default 50)
EMA Mode ... With Trend or Counter Trend
Mode ... Present (live levels only) or Historical (all levels)
Visible Levels ... how many levels to display (default 3)

Colors follow standard convention ... green for buy opportunities, red for sell opportunities. Fully configurable.

[b]CREDITS
[/b]
Based on Buyside & Sellside Liquidity by LuxAlgo (CC BY-NC-SA 4.0). Enhanced with touch counting, sweep/break distinction, EMA sweep filter, proximity alerts, WaveTrend context, and directional labeling.

## Source Code

````pine
// Liquidity Hunter v1.5
// Original concept by LuxAlgo (CC BY-NC-SA 4.0)
// Enhanced: touch count, sweep/break detection, proximity alerts, WT context, EMA sweep filter
//
// Hunters Framework:
//   Liquidity Hunter ... finds WHERE (levels)
//   Trend Hunter     ... finds WHEN (timing)
//   RSI Divergence   ... tells you WHY (momentum shift)
//
// Version History:
//   v1.5  ... Pine v6 upgrade
//           Clean status line (all inputs display=display.none)
//           No functional changes from v1.0
//   v1.0  ... Initial release
//           Touch count (strength weighting) on labels
//           Sweep vs Break distinction (wick reject vs structural break)
//           Proximity alerts (configurable ATR distance)
//           EMA-filtered sweep signals (BTC 1H: 76.5% WR, PF 4.87 with EMA50)
//           WT state included in alerts for cross-indicator confluence
//           Nearest buyside/sellside level distance display
//           Clear labeling (Buy Zone / Sell Zone with intuitive colors)
//           Arrow signals on sweep reversals
//           10 individual alertconditions for granular alert setup

//@version=6
indicator("Liquidity Hunter v1.5", "LiqHunter v1.5", overlay=true, max_lines_count=500, max_boxes_count=500, max_bars_back=3000)

//──────────────────────────────────────────────────────────────
// SETTINGS
//──────────────────────────────────────────────────────────────
liqGrp = 'Liquidity Detection'
liqLen = input.int(7, title='Detection Length', minval=3, maxval=13, inline='LIQ', group=liqGrp, display=display.none)
liqMar = 10 / input.float(6.9, 'Margin', minval=4, maxval=9, step=0.1, inline='LIQ', group=liqGrp, display=display.none)

// Colors are swapped from ICT convention for intuitive reading
// Buyside (swing highs) = Sell Zone = RED ... price likely to reject down
// Sellside (swing lows) = Buy Zone = GREEN ... price likely to bounce up
liqBuy = input.bool(true, 'Buyside Liquidity Zones, Margin', inline='Buyside', group=liqGrp, display=display.none)
marBuy = input.float(2.3, '', minval=1.5, maxval=10, step=.1, inline='Buyside', group=liqGrp, display=display.none)
cLIQ_B = input.color(color.new(#f23645, 0), '', inline='Buyside', group=liqGrp, display=display.none)

liqSel = input.bool(true, 'Sellside Liquidity Zones, Margin', inline='Sellside', group=liqGrp, display=display.none)
marSel = input.float(2.3, '', minval=1.5, maxval=10, step=.1, inline='Sellside', group=liqGrp, display=display.none)
cLIQ_S = input.color(color.new(#4caf50, 0), '', inline='Sellside', group=liqGrp, display=display.none)

lqVoid = input.bool(false, 'Liquidity Voids, Bullish', inline='void', group=liqGrp, display=display.none)
cLQV_B = input.color(color.new(#4caf50, 0), '', inline='void', group=liqGrp, display=display.none)
cLQV_S = input.color(color.new(#f23645, 0), 'Bearish', inline='void', group=liqGrp, display=display.none)
lqText = input.bool(false, 'Label', inline='void', group=liqGrp, display=display.none)

mode   = input.string('Present', title='Mode', options=['Present', 'Historical'], inline='MOD', group=liqGrp, display=display.none)
visLiq = input.int(3, '    # Visible Levels', minval=1, maxval=50, inline='MOD', group=liqGrp, display=display.none)

// ── Enhanced Settings ──
grpEnhanced = 'Enhanced Features'
useAltLabels  = input.bool(true,  'Use Clear Labels (Buy Zone / Sell Zone)', group=grpEnhanced, display=display.none, tooltip='Replaces ICT terminology with directional labels: Sellside = Buy Zone, Buyside = Sell Zone')
showTouches   = input.bool(true,  'Show Touch Count on Labels', group=grpEnhanced, display=display.none)
showSweepMark = input.bool(true,  'Mark Swept Levels', group=grpEnhanced, display=display.none)
showArrows    = input.bool(true,  'Show Sweep Arrows', group=grpEnhanced, display=display.none)
cSwept        = input.color(color.new(#ff9800, 0), 'Sweep Color', inline='sweep', group=grpEnhanced, display=display.none)
cBroken       = input.color(color.new(color.gray, 50), 'Broken Color', inline='sweep', group=grpEnhanced, display=display.none)

// ── EMA Sweep Filter ──
grpEMA = 'EMA Sweep Filter'
emaFilterEnable    = input.bool(true,   'Enable EMA Sweep Filter', group=grpEMA, display=display.none, tooltip='Only fires when sweep direction aligns with EMA trend. Backtested on BTC 1H: 76.5% WR with EMA50.')
emaFilterLen       = input.int(50,      'EMA Length', minval=5, maxval=200, group=grpEMA, display=display.none)
emaFilterMode      = input.string('With Trend', 'Mode', options=['With Trend', 'Counter Trend'], group=grpEMA, display=display.none, tooltip='With Trend: buy above EMA, sell below. Counter: opposite.')
emaShowLine        = input.bool(true,   'Show EMA Line', group=grpEMA, display=display.none)
cEMA               = input.color(color.new(#ff9800, 30), 'EMA Color', group=grpEMA, display=display.none)
showEMASweepArrows = input.bool(true,   'Show EMA-Filtered Arrows', group=grpEMA, display=display.none)
cEMABuy            = input.color(color.new(#00e676, 0), 'EMA Buy Arrow', inline='emacol', group=grpEMA, display=display.none)
cEMASell           = input.color(color.new(#ff1744, 0), 'EMA Sell Arrow', inline='emacol', group=grpEMA, display=display.none)

// ── Proximity Alerts ──
grpProx = 'Proximity Alerts'
proxEnable   = input.bool(true,   'Enable Proximity Alerts', group=grpProx, display=display.none)
proxATR      = input.float(2.0,   'Proximity Distance (x ATR)', minval=0.5, maxval=10.0, step=0.5, group=grpProx, display=display.none)
proxShowLine = input.bool(true,   'Show Proximity Zone', group=grpProx, display=display.none, tooltip='Draws a faint band around each level showing the proximity alert trigger zone')

// ── Nearest Level Info ──
grpInfo = 'Nearest Level Display'
showNearest = input.bool(true, 'Show Nearest Level Distance', group=grpInfo, display=display.none)
nearestPos  = input.string('Bottom Right', 'Position', options=['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group=grpInfo, display=display.none)
nearestSize = input.string('Normal', 'Size', options=['Small', 'Normal', 'Large'], group=grpInfo, display=display.none)

// ── WT Context for Alerts ──
grpWTCtx = 'WaveTrend Context (for alerts)'
wtEnable  = input.bool(true,  'Include Trend State in Alerts', group=grpWTCtx, display=display.none)
wtChLen   = input.int(9,      'WT Channel Length', group=grpWTCtx, display=display.none)
wtAvgLen  = input.int(12,     'WT Average Length', group=grpWTCtx, display=display.none)
wtMALen   = input.int(3,      'WT2 SMA Length', group=grpWTCtx, display=display.none)
wtOBLevel = input.int(53,     'WT Overbought', group=grpWTCtx, display=display.none)
wtOSLevel = input.int(-53,    'WT Oversold', group=grpWTCtx, display=display.none)

//──────────────────────────────────────────────────────────────
// GENERAL CALCULATIONS
//──────────────────────────────────────────────────────────────
maxSize = 50
atr     = ta.atr(10)
atr200  = ta.atr(200)
per     = mode == 'Present' ? last_bar_index - bar_index <= 500 : true

// EMA for sweep filter
emaVal = ta.ema(close, emaFilterLen)
plot(emaFilterEnable and emaShowLine ? emaVal : na, title='Sweep EMA', color=cEMA, linewidth=2)

//──────────────────────────────────────────────────────────────
// WAVETREND CALCULATION (for alert context only)
//──────────────────────────────────────────────────────────────
var float wtVal1 = na
var float wtVal2 = na
var string wtState = "..."

if wtEnable
    wt_ap  = hlc3
    wt_esa = ta.ema(wt_ap, wtChLen)
    wt_d   = ta.ema(math.abs(wt_ap - wt_esa), wtChLen)
    wt_ci  = (wt_ap - wt_esa) / (0.015 * wt_d)
    wtVal1 := ta.ema(wt_ci, wtAvgLen)
    wtVal2 := ta.sma(wtVal1, wtMALen)
    
    if wtVal1 >= wtVal2
        if wtVal2 <= wtOSLevel
            wtState := "BULL (Oversold)"
        else if wtVal2 >= wtOBLevel
            wtState := "BULL (Overbought)"
        else
            wtState := "BULL"
    else
        if wtVal2 >= wtOBLevel
            wtState := "BEAR (Overbought)"
        else if wtVal2 <= wtOSLevel
            wtState := "BEAR (Oversold)"
        else
            wtState := "BEAR"

//──────────────────────────────────────────────────────────────
// USER DEFINED TYPES
//──────────────────────────────────────────────────────────────
type ZZ
    int   [] d
    int   [] x
    float [] y

type bar
    float o = open
    float h = high
    float l = low
    float c = close
    int   i = bar_index

type liq
    box   bx
    box   bxz
    box   bxt
    bool  brZ
    bool  brL
    line  ln
    line  lne
    int   touches
    bool  swept
    bool  proxAlerted
    string lblText

//──────────────────────────────────────────────────────────────
// VARIABLES
//──────────────────────────────────────────────────────────────
var ZZ aZZ = ZZ.new(
 array.new<int>(maxSize, 0),
 array.new<int>(maxSize, 0),
 array.new<float>(maxSize, na)
 )

bar b = bar.new()

var liq[] b_liq_B = array.new<liq>(1, liq.new(box(na), box(na), box(na), false, false, line(na), line(na), 0, false, false, ""))
var liq[] b_liq_S = array.new<liq>(1, liq.new(box(na), box(na), box(na), false, false, line(na), line(na), 0, false, false, ""))

var b_liq_V = array.new_box()

var int dir = na, var int x1 = na, var float y1 = na, var int x2 = na, var float y2 = na

// Signal flags ... reset each bar
var bool buySweepSignal  = false
var bool sellSweepSignal = false
var bool buyBreakSignal  = false
var bool sellBreakSignal = false
var bool proxBuySignal   = false
var bool proxSellSignal  = false
var bool emaBuySweep     = false
var bool emaSellSweep    = false

buySweepSignal  := false
sellSweepSignal := false
buyBreakSignal  := false
sellBreakSignal := false
proxBuySignal   := false
proxSellSignal  := false
emaBuySweep     := false
emaSellSweep    := false

//──────────────────────────────────────────────────────────────
// METHODS
//──────────────────────────────────────────────────────────────
method in_out(ZZ aZZ, int _d, int _x, float _y) =>
    aZZ.d.unshift(_d), aZZ.x.unshift(_x), aZZ.y.unshift(_y), aZZ.d.pop(), aZZ.x.pop(), aZZ.y.pop()

max_bars_back(time, 1000)

//──────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
//──────────────────────────────────────────────────────────────
f_alertMsg(string _type, string _action, float _level, int _touches, string _strength) =>
    msg = _action + " | " + syminfo.ticker + " | " + timeframe.period
    msg := msg + "\nLevel: " + str.tostring(_level, format.mintick) + " (" + _type + ")"
    msg := msg + "\nStrength: " + str.tostring(_touches) + " touches (" + _strength + ")"
    msg := msg + "\nPrice: " + str.tostring(close, format.mintick)
    msg := msg + "\nDistance: " + str.tostring(math.abs(close - _level) / atr, "#.#") + " ATR"
    if wtEnable
        msg := msg + "\nTrend: " + wtState + " | WT1: " + str.tostring(wtVal1, "#.#") + " WT2: " + str.tostring(wtVal2, "#.#")
    msg

f_strength(int _touches) =>
    _touches >= 7 ? "STRONG" : _touches >= 5 ? "MODERATE" : "WEAK"

f_labelText(bool _isBuyside, int _touches) =>
    typeText = ""
    if useAltLabels
        typeText := _isBuyside ? "Sell Zone" : "Buy Zone"
    else
        typeText := _isBuyside ? "Buyside liquidity" : "Sellside liquidity"
    if showTouches
        typeText := typeText + " [" + str.tostring(_touches) + "]"
    typeText

//──────────────────────────────────────────────────────────────
// BUYSIDE LIQUIDITY DETECTION (Swing Highs = Sell Zone)
//──────────────────────────────────────────────────────────────
x2 := b.i - 1
ph = ta.pivothigh(liqLen, 1)
pl = ta.pivotlow(liqLen, 1)

if not na(ph)
    dir := aZZ.d.get(0)
    x1  := aZZ.x.get(0)
    y1  := aZZ.y.get(0)
    y2  := nz(high[1])

    if dir < 1
        aZZ.in_out(1, x2, y2)
    else
        if dir == 1 and ph > y1
            aZZ.x.set(0, x2), aZZ.y.set(0, y2)

    if per
        count = 0
        st_P  = 0.
        st_B  = 0
        minP  = 0.
        maxP  = 10e6

        for i = 0 to maxSize - 1
            if aZZ.d.get(i) == 1
                if aZZ.y.get(i) > ph + (atr / liqMar)
                    break
                else
                    if aZZ.y.get(i) > ph - (atr / liqMar) and aZZ.y.get(i) < ph + (atr / liqMar)
                        count += 1
                        st_B := aZZ.x.get(i)
                        st_P := aZZ.y.get(i)
                        if aZZ.y.get(i) > minP
                            minP := aZZ.y.get(i)
                        if aZZ.y.get(i) < maxP
                            maxP := aZZ.y.get(i)

        if count > 2
            getB = b_liq_B.get(0)

            if st_B == getB.bx.get_left()
                getB.bx.set_top(math.avg(minP, maxP) + (atr / liqMar))
                getB.bx.set_rightbottom(b.i + 10, math.avg(minP, maxP) - (atr / liqMar))
                getB.touches := count
                getB.lblText := f_labelText(true, count)
                getB.bxt.set_text(getB.lblText)
            else
                labelTxt = f_labelText(true, count)
                b_liq_B.unshift(
                 liq.new(
                   box.new(st_B, math.avg(minP, maxP) + (atr / liqMar), b.i + 10, math.avg(minP, maxP) - (atr / liqMar), bgcolor=#00000000, border_color=#00000000),
                   box.new(na, na, na, na, bgcolor=#00000000, border_color=#00000000),
                   box.new(st_B, st_P, b.i + 10, st_P, text=labelTxt, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_bottom, text_color=color.new(cLIQ_B, 25), bgcolor=#00000000, border_color=#00000000),
                   false,
                   false,
                   line.new(st_B, st_P, b.i - 1, st_P, color=color.new(cLIQ_B, 0)),
                   line.new(b.i - 1, st_P, na, st_P, color=color.new(cLIQ_B, 0), style=line.style_dotted),
                   count,
                   false,
                   false,
                   labelTxt)
                 )

                strength = f_strength(count)
                alert(f_alertMsg("Sell Zone", "LEVEL DETECTED", st_P, count, strength))

            if b_liq_B.size() > visLiq
                getLast = b_liq_B.pop()
                getLast.bx.delete()
                getLast.bxz.delete()
                getLast.bxt.delete()
                getLast.ln.delete()
                getLast.lne.delete()

//──────────────────────────────────────────────────────────────
// SELLSIDE LIQUIDITY DETECTION (Swing Lows = Buy Zone)
//──────────────────────────────────────────────────────────────
if not na(pl)
    dir := aZZ.d.get(0)
    x1  := aZZ.x.get(0)
    y1  := aZZ.y.get(0)
    y2  := nz(low[1])

    if dir > -1
        aZZ.in_out(-1, x2, y2)
    else
        if dir == -1 and pl < y1
            aZZ.x.set(0, x2), aZZ.y.set(0, y2)

    if per
        count = 0
        st_P  = 0.
        st_B  = 0
        minP  = 0.
        maxP  = 10e6

        for i = 0 to maxSize - 1
            if aZZ.d.get(i) == -1
                if aZZ.y.get(i) < pl - (atr / liqMar)
                    break
                else
                    if aZZ.y.get(i) > pl - (atr / liqMar) and aZZ.y.get(i) < pl + (atr / liqMar)
                        count += 1
                        st_B := aZZ.x.get(i)
                        st_P := aZZ.y.get(i)
                        if aZZ.y.get(i) > minP
                            minP := aZZ.y.get(i)
                        if aZZ.y.get(i) < maxP
                            maxP := aZZ.y.get(i)

        if count > 2
            getB = b_liq_S.get(0)

            if st_B == getB.bx.get_left()
                getB.bx.set_top(math.avg(minP, maxP) + (atr / liqMar))
                getB.bx.set_rightbottom(b.i + 10, math.avg(minP, maxP) - (atr / liqMar))
                getB.touches := count
                getB.lblText := f_labelText(false, count)
                getB.bxt.set_text(getB.lblText)
            else
                labelTxt = f_labelText(false, count)
                b_liq_S.unshift(
                 liq.new(
                   box.new(st_B, math.avg(minP, maxP) + (atr / liqMar), b.i + 10, math.avg(minP, maxP) - (atr / liqMar), bgcolor=#00000000, border_color=#00000000),
                   box.new(na, na, na, na, bgcolor=#00000000, border_color=#00000000),
                   box.new(st_B, st_P, b.i + 10, st_P, text=labelTxt, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_top, text_color=color.new(cLIQ_S, 25), bgcolor=#00000000, border_color=#00000000),
                   false,
                   false,
                   line.new(st_B, st_P, b.i - 1, st_P, color=color.new(cLIQ_S, 0)),
                   line.new(b.i - 1, st_P, na, st_P, color=color.new(cLIQ_S, 0), style=line.style_dotted),
                   count,
                   false,
                   false,
                   labelTxt)
                 )

                strength = f_strength(count)
                alert(f_alertMsg("Buy Zone", "LEVEL DETECTED", st_P, count, strength))

            if b_liq_S.size() > visLiq
                getLast = b_liq_S.pop()
                getLast.bx.delete()
                getLast.bxz.delete()
                getLast.bxt.delete()
                getLast.ln.delete()
                getLast.lne.delete()

//──────────────────────────────────────────────────────────────
// LEVEL MANAGEMENT: Sweep vs Break + Proximity Alerts
//──────────────────────────────────────────────────────────────
var float nearestBuyDist  = na
var float nearestBuyLevel = na
var int   nearestBuyTouch = 0
var float nearestSelDist  = na
var float nearestSelLevel = na
var int   nearestSelTouch = 0

nearestBuyDist  := 10e6
nearestSelDist  := 10e6
nearestBuyLevel := na
nearestSelLevel := na

// ── Buyside levels (above price = Sell Zone) ──
for i = 0 to b_liq_B.size() - 1
    x = b_liq_B.get(i)

    if not x.brL
        x.lne.set_x2(b.i)
        
        levelPrice = x.ln.get_y1()
        distToLevel = levelPrice - b.c

        if distToLevel > 0 and distToLevel < nearestBuyDist
            nearestBuyDist  := distToLevel
            nearestBuyLevel := levelPrice
            nearestBuyTouch := x.touches

        // ── Proximity alert ──
        if proxEnable and not x.proxAlerted
            if math.abs(b.c - levelPrice) <= proxATR * atr and math.abs(b.c - levelPrice) > 0
                x.proxAlerted := true
                proxSellSignal := true
                strength = f_strength(x.touches)
                typeName = useAltLabels ? "Sell Zone" : "Buyside"
                alert(f_alertMsg("Sell Zone", "APPROACHING " + typeName, levelPrice, x.touches, strength))

        if x.proxAlerted and math.abs(b.c - levelPrice) > proxATR * atr * 1.5
            x.proxAlerted := false

        // ── Breach detection ──
        if b.h > x.bx.get_top()
            x.brL := true
            x.brZ := true

            // Sweep: wick above but close below = SELL signal
            if b.c < levelPrice
                x.swept := true
                sellSweepSignal := true
                x.bxz.set_lefttop(b.i - 1, math.min(levelPrice + marBuy * atr, b.h))
                x.bxz.set_rightbottom(b.i + 1, levelPrice)
                x.bxz.set_bgcolor(color.new(cSwept, showSweepMark ? 70 : 100))
                
                if showSweepMark
                    x.lblText := x.lblText + " SWEPT"
                    x.bxt.set_text(x.lblText)
                    x.bxt.set_text_color(color.new(cSwept, 15))

                strength = f_strength(x.touches)
                alert(f_alertMsg("Sell Zone", "SWEPT ... SELL SIGNAL", levelPrice, x.touches, strength))

            // Break: close above = structural break
            else
                x.swept := false
                sellBreakSignal := true
                x.bxz.set_lefttop(b.i - 1, math.min(levelPrice + marBuy * atr, b.h))
                x.bxz.set_rightbottom(b.i + 1, levelPrice)
                x.bxz.set_bgcolor(color.new(cLIQ_B, liqBuy ? 73 : 100))

                if showSweepMark
                    x.lblText := x.lblText + " BROKEN"
                    x.bxt.set_text(x.lblText)
                    x.bxt.set_text_color(color.new(cBroken, 0))
                    x.ln.set_color(cBroken)
                    x.lne.set_color(cBroken)

                strength = f_strength(x.touches)
                alert(f_alertMsg("Sell Zone", "BROKEN (Close through)", levelPrice, x.touches, strength))

    else if x.brZ
        if b.l > x.ln.get_y1() - marBuy * atr and b.h < x.ln.get_y1() + marBuy * atr
            x.bxz.set_right(b.i + 1)
            x.bxz.set_top(math.max(b.h, x.bxz.get_top()))
            if liqBuy
                x.lne.set_x2(b.i + 1)
        else
            x.brZ := false

// ── Sellside levels (below price = Buy Zone) ──
for i = 0 to b_liq_S.size() - 1
    x = b_liq_S.get(i)

    if not x.brL
        x.lne.set_x2(b.i)
        
        levelPrice = x.ln.get_y1()
        distToLevel = b.c - levelPrice

        if distToLevel > 0 and distToLevel < nearestSelDist
            nearestSelDist  := distToLevel
            nearestSelLevel := levelPrice
            nearestSelTouch := x.touches

        // ── Proximity alert ──
        if proxEnable and not x.proxAlerted
            if math.abs(b.c - levelPrice) <= proxATR * atr and math.abs(b.c - levelPrice) > 0
                x.proxAlerted := true
                proxBuySignal := true
                strength = f_strength(x.touches)
                typeName = useAltLabels ? "Buy Zone" : "Sellside"
                alert(f_alertMsg("Buy Zone", "APPROACHING " + typeName, levelPrice, x.touches, strength))

        if x.proxAlerted and math.abs(b.c - levelPrice) > proxATR * atr * 1.5
            x.proxAlerted := false

        // ── Breach detection ──
        if b.l < x.bx.get_bottom()
            x.brL := true
            x.brZ := true

            // Sweep: wick below but close above = BUY signal
            if b.c > levelPrice
                x.swept := true
                buySweepSignal := true
                x.bxz.set_lefttop(b.i - 1, levelPrice)
                x.bxz.set_rightbottom(b.i + 1, math.max(levelPrice - marSel * atr, b.l))
                x.bxz.set_bgcolor(color.new(cSwept, showSweepMark ? 70 : 100))

                if showSweepMark
                    x.lblText := x.lblText + " SWEPT"
                    x.bxt.set_text(x.lblText)
                    x.bxt.set_text_color(color.new(cSwept, 15))

                strength = f_strength(x.touches)
                alert(f_alertMsg("Buy Zone", "SWEPT ... BUY SIGNAL", levelPrice, x.touches, strength))

            // Break: close below = structural break
            else
                x.swept := false
                buyBreakSignal := true
                x.bxz.set_lefttop(b.i - 1, levelPrice)
                x.bxz.set_rightbottom(b.i + 1, math.max(levelPrice - marSel * atr, b.l))
                x.bxz.set_bgcolor(color.new(cLIQ_S, liqSel ? 73 : 100))

                if showSweepMark
                    x.lblText := x.lblText + " BROKEN"
                    x.bxt.set_text(x.lblText)
                    x.bxt.set_text_color(color.new(cBroken, 0))
                    x.ln.set_color(cBroken)
                    x.lne.set_color(cBroken)

                strength = f_strength(x.touches)
                alert(f_alertMsg("Buy Zone", "BROKEN (Close through)", levelPrice, x.touches, strength))

    else if x.brZ
        if b.l > x.ln.get_y1() - marSel * atr and b.h < x.ln.get_y1() + marSel * atr
            x.bxz.set_rightbottom(b.i + 1, math.min(b.l, x.bxz.get_bottom()))
            if liqSel
                x.lne.set_x2(b.i + 1)
        else
            x.brZ := false

//──────────────────────────────────────────────────────────────
// SWEEP ARROW SIGNALS (raw ... unfiltered)
//──────────────────────────────────────────────────────────────
plotshape(showArrows and buySweepSignal  ? low  : na, title="Buy Sweep",  style=shape.triangleup,   location=location.belowbar, color=color.new(#4caf50, 0), size=size.small, text="BUY",  textcolor=color.new(#4caf50, 0))
plotshape(showArrows and sellSweepSignal ? high : na, title="Sell Sweep", style=shape.triangledown, location=location.abovebar, color=color.new(#f23645, 0), size=size.small, text="SELL", textcolor=color.new(#f23645, 0))

//──────────────────────────────────────────────────────────────
// EMA-FILTERED SWEEP SIGNALS
//──────────────────────────────────────────────────────────────
if emaFilterEnable
    if emaFilterMode == 'With Trend'
        emaBuySweep  := buySweepSignal  and close > emaVal
        emaSellSweep := sellSweepSignal and close < emaVal
    else
        emaBuySweep  := buySweepSignal  and close < emaVal
        emaSellSweep := sellSweepSignal and close > emaVal

// EMA-filtered arrows (diamond shape to distinguish from raw sweep triangles)
plotshape(showEMASweepArrows and emaBuySweep  ? low  : na, title="EMA Buy Sweep",  style=shape.diamond, location=location.belowbar, color=cEMABuy,  size=size.normal, text="EMA\nBUY",  textcolor=cEMABuy)
plotshape(showEMASweepArrows and emaSellSweep ? high : na, title="EMA Sell Sweep", style=shape.diamond, location=location.abovebar, color=cEMASell, size=size.normal, text="EMA\nSELL", textcolor=cEMASell)

// ── EMA Sweep rich alerts ──
if emaBuySweep
    strength = "..."
    levelPrice = 0.0
    touches = 0
    for i = 0 to b_liq_S.size() - 1
        x = b_liq_S.get(i)
        if x.swept and x.brL
            levelPrice := x.ln.get_y1()
            touches := x.touches
            strength := f_strength(touches)
            break
    
    msg = "EMA SWEEP BUY | " + syminfo.ticker + " | " + timeframe.period
    msg := msg + "\nLevel: " + str.tostring(levelPrice, format.mintick) + " (" + str.tostring(touches) + " touches, " + strength + ")"
    msg := msg + "\nEMA" + str.tostring(emaFilterLen) + ": " + str.tostring(emaVal, format.mintick) + " (price " + (emaFilterMode == "With Trend" ? "ABOVE" : "BELOW") + ")"
    msg := msg + "\nEntry: " + str.tostring(close, format.mintick)
    msg := msg + "\nSL: below " + str.tostring(low, format.mintick) + " (sweep wick)"
    if wtEnable
        msg := msg + "\nTrend: " + wtState
    alert(msg)

if emaSellSweep
    strength = "..."
    levelPrice = 0.0
    touches = 0
    for i = 0 to b_liq_B.size() - 1
        x = b_liq_B.get(i)
        if x.swept and x.brL
            levelPrice := x.ln.get_y1()
            touches := x.touches
            strength := f_strength(touches)
            break
    
    msg = "EMA SWEEP SELL | " + syminfo.ticker + " | " + timeframe.period
    msg := msg + "\nLevel: " + str.tostring(levelPrice, format.mintick) + " (" + str.tostring(touches) + " touches, " + strength + ")"
    msg := msg + "\nEMA" + str.tostring(emaFilterLen) + ": " + str.tostring(emaVal, format.mintick) + " (price " + (emaFilterMode == "With Trend" ? "BELOW" : "ABOVE") + ")"
    msg := msg + "\nEntry: " + str.tostring(close, format.mintick)
    msg := msg + "\nSL: above " + str.tostring(high, format.mintick) + " (sweep wick)"
    if wtEnable
        msg := msg + "\nTrend: " + wtState
    alert(msg)

//──────────────────────────────────────────────────────────────
// LIQUIDITY VOIDS
//──────────────────────────────────────────────────────────────
if lqVoid and per
    bull = b.l - high[2] > atr200 and b.l > high[2] and close[1] > high[2]
    bear = low[2] - b.h > atr200 and b.h < low[2] and close[1] < low[2]

    if bull
        l = 13
        if bull[1]
            st = math.abs(b.l - low[1]) / l
            for i = 0 to l - 1
                array.push(b_liq_V, box.new(b.i - 2, low[1] + i * st, b.i, low[1] + (i + 1) * st, border_color=na, bgcolor=color.new(cLQV_B, 90)))
        else
            st = math.abs(b.l - high[2]) / l
            for i = 0 to l - 1
                if lqText and i == 0
                    array.push(b_liq_V, box.new(b.i - 2, high[2] + i * st, b.i, high[2] + (i + 1) * st, text='Liquidity Void   ', text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_bottom, text_color=na, border_color=na, bgcolor=color.new(cLQV_B, 90)))
                else
                    array.push(b_liq_V, box.new(b.i - 2, high[2] + i * st, b.i, high[2] + (i + 1) * st, border_color=na, bgcolor=color.new(cLQV_B, 90)))

    if bear
        l = 13
        if bear[1]
            st = math.abs(high[1] - b.h) / l
            for i = 0 to l - 1
                array.push(b_liq_V, box.new(b.i - 2, b.h + i * st, b.i, b.h + (i + 1) * st, border_color=na, bgcolor=color.new(cLQV_S, 90)))
        else
            st = math.abs(low[2] - b.h) / l
            for i = 0 to l - 1
                if lqText and i == l - 1
                    array.push(b_liq_V, box.new(b.i - 2, b.h + i * st, b.i, b.h + (i + 1) * st, text='Liquidity Void   ', text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_top, text_color=na, border_color=na, bgcolor=color.new(cLQV_S, 90)))
                else
                    array.push(b_liq_V, box.new(b.i - 2, b.h + i * st, b.i, b.h + (i + 1) * st, border_color=na, bgcolor=color.new(cLQV_S, 90)))

if b_liq_V.size() > 0
    qt = b_liq_V.size()
    for bn = qt - 1 to 0
        if bn < b_liq_V.size()
            cb = b_liq_V.get(bn)
            ba = math.avg(cb.get_bottom(), cb.get_top())

            if math.sign(close[1] - ba) != math.sign(b.c - ba) or math.sign(close[1] - ba) != math.sign(b.l - ba) or math.sign(close[1] - ba) != math.sign(b.h - ba)
                b_liq_V.remove(bn)
            else
                cb.set_right(b.i + 1)
                if b.i - cb.get_left() > 21
                    cb.set_text_color(color.new(color.gray, 25))

//──────────────────────────────────────────────────────────────
// NEAREST LEVEL INFO TABLE
//──────────────────────────────────────────────────────────────
if showNearest and barstate.islast
    tblPos = switch nearestPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

    tblSize = switch nearestSize
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

    var tblN = table.new(tblPos, 4, 4, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 50), force_overlay=true)

    table.cell(tblN, 0, 0, "Level",    text_color=color.white, text_size=tblSize, bgcolor=color.new(color.gray, 60))
    table.cell(tblN, 1, 0, "Price",    text_color=color.white, text_size=tblSize, bgcolor=color.new(color.gray, 60))
    table.cell(tblN, 2, 0, "Dist",     text_color=color.white, text_size=tblSize, bgcolor=color.new(color.gray, 60))
    table.cell(tblN, 3, 0, "Strength", text_color=color.white, text_size=tblSize, bgcolor=color.new(color.gray, 60))

    sellLabel = useAltLabels ? "Sell Zone" : "Buyside"
    if not na(nearestBuyLevel)
        buyDist = str.tostring(nearestBuyDist / atr, "#.#") + " ATR"
        buyStr = f_strength(nearestBuyTouch)
        _bgB = color.new(cLIQ_B, 80)
        table.cell(tblN, 0, 1, sellLabel,                                   text_color=cLIQ_B,      text_size=tblSize, bgcolor=_bgB)
        table.cell(tblN, 1, 1, str.tostring(nearestBuyLevel, format.mintick), text_color=color.white, text_size=tblSize, bgcolor=_bgB)
        table.cell(tblN, 2, 1, buyDist,                                     text_color=color.white, text_size=tblSize, bgcolor=_bgB)
        table.cell(tblN, 3, 1, buyStr + " (" + str.tostring(nearestBuyTouch) + ")", text_color=color.white, text_size=tblSize, bgcolor=_bgB)
    else
        table.cell(tblN, 0, 1, sellLabel, text_color=cLIQ_B,      text_size=tblSize, bgcolor=color.new(color.gray, 80))
        table.cell(tblN, 1, 1, "...",     text_color=color.gray,   text_size=tblSize, bgcolor=color.new(color.gray, 80))
        table.cell(tblN, 2, 1, "...",     text_color=color.gray,   text_size=tblSize, bgcolor=color.new(color.gray, 80))
        table.cell(tblN, 3, 1, "...",     text_color=color.gray,   text_size=tblSize, bgcolor=color.new(color.gray, 80))

    buyLabel = useAltLabels ? "Buy Zone" : "Sellside"
    if not na(nearestSelLevel)
        selDist = str.tostring(nearestSelDist / atr, "#.#") + " ATR"
        selStr = f_strength(nearestSelTouch)
        _bgS = color.new(cLIQ_S, 80)
        table.cell(tblN, 0, 2, buyLabel,                                     text_color=cLIQ_S,      text_size=tblSize, bgcolor=_bgS)
        table.cell(tblN, 1, 2, str.tostring(nearestSelLevel, format.mintick), text_color=color.white, text_size=tblSize, bgcolor=_bgS)
        table.cell(tblN, 2, 2, selDist,                                      text_color=color.white, text_size=tblSize, bgcolor=_bgS)
        table.cell(tblN, 3, 2, selStr + " (" + str.tostring(nearestSelTouch) + ")", text_color=color.white, text_size=tblSize, bgcolor=_bgS)
    else
        table.cell(tblN, 0, 2, buyLabel,  text_color=cLIQ_S,      text_size=tblSize, bgcolor=color.new(color.gray, 80))
        table.cell(tblN, 1, 2, "...",     text_color=color.gray,   text_size=tblSize, bgcolor=color.new(color.gray, 80))
        table.cell(tblN, 2, 2, "...",     text_color=color.gray,   text_size=tblSize, bgcolor=color.new(color.gray, 80))
        table.cell(tblN, 3, 2, "...",     text_color=color.gray,   text_size=tblSize, bgcolor=color.new(color.gray, 80))

    if wtEnable
        wtBg = wtVal1 >= wtVal2 ? color.new(color.green, 80) : color.new(color.red, 80)
        wtTc = wtVal1 >= wtVal2 ? color.lime : color.red
        table.cell(tblN, 0, 3, "Trend",                           text_color=color.white, text_size=tblSize, bgcolor=wtBg)
        table.cell(tblN, 1, 3, str.tostring(wtVal1, "#.#"),       text_color=wtTc,        text_size=tblSize, bgcolor=wtBg)
        table.cell(tblN, 2, 3, wtState,                            text_color=wtTc,        text_size=tblSize, bgcolor=wtBg)
        table.cell(tblN, 3, 3, "",                                 text_color=color.white, text_size=tblSize, bgcolor=wtBg)

//──────────────────────────────────────────────────────────────
// ALERT CONDITIONS
//──────────────────────────────────────────────────────────────
// Raw sweep signals
alertcondition(buySweepSignal,                        title="BUY ... Buy Zone Swept",              message="{{ticker}} {{interval}} ... Buy Zone swept (wick reject), potential long")
alertcondition(sellSweepSignal,                       title="SELL ... Sell Zone Swept",             message="{{ticker}} {{interval}} ... Sell Zone swept (wick reject), potential short")
alertcondition(buySweepSignal or sellSweepSignal,     title="Any Sweep Signal",                    message="{{ticker}} {{interval}} ... Liquidity sweep detected")

// Break signals
alertcondition(buyBreakSignal,                        title="Buy Zone Broken (Bearish)",           message="{{ticker}} {{interval}} ... Buy Zone broken, bearish structure break")
alertcondition(sellBreakSignal,                       title="Sell Zone Broken (Bullish)",          message="{{ticker}} {{interval}} ... Sell Zone broken, bullish structure break")

// Proximity
alertcondition(proxBuySignal,                         title="Approaching Buy Zone",                message="{{ticker}} {{interval}} ... Price approaching Buy Zone, prepare for long")
alertcondition(proxSellSignal,                        title="Approaching Sell Zone",               message="{{ticker}} {{interval}} ... Price approaching Sell Zone, prepare for short")
alertcondition(proxBuySignal or proxSellSignal,       title="Approaching Any Level",               message="{{ticker}} {{interval}} ... Price approaching liquidity level")

// EMA-filtered sweep signals
alertcondition(emaBuySweep,                           title="EMA BUY ... Sweep + Trend Aligned",   message="{{ticker}} {{interval}} ... EMA-filtered buy sweep (trend-aligned long)")
alertcondition(emaSellSweep,                          title="EMA SELL ... Sweep + Trend Aligned",  message="{{ticker}} {{interval}} ... EMA-filtered sell sweep (trend-aligned short)")
alertcondition(emaBuySweep or emaSellSweep,           title="Any EMA Sweep Signal",                message="{{ticker}} {{interval}} ... EMA-filtered liquidity sweep")
````
