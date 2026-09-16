<!-- tradingview-pine-id: PUB;e23c65c50ba547f9867f25851e8eaff8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Unicorn Model - Clean Pro

Source: https://www.tradingview.com/script/wai5wdMl-ICT-Unicorn-Model-Clean-Pro-2026-dbarda/

## Description

ndicator Name: ICT Unicorn Model - Clean Pro (Clean Unicorn)
Overview
The Clean Unicorn indicator is an advanced, automated technical analysis tool designed for TradingView built on Pine Script v6. It automates one of the most powerful institutional trading concepts from ICT (Inner Circle Trader): The Unicorn Model.

The indicator combines multiple high-probability price-action elements—Liquidity Sweeps, Displacement, Breaker Blocks, and Fair Value Gaps (FVG)—into a single, clean visual setup to help day traders spot high-confluence entry zones without cluttering the chart.

Key Features & Logic
True Confluence Mapping: Identifies the precise overlapping zone where a structural Breaker Block meets a Fair Value Gap (FVG) following a strong institutional push.

Advanced Noise & Fakeout Filtering:

Displacement Multiplier: Ensures the expansion candle is significantly larger than the average body size.

Candle Body Ratio Filter: Filters out candles with long wicks of indecision, ensuring only clean, high-momentum breakout candles trigger a setup.

Dynamic Mitigation Boxes:

Active boxes automatically stretch to the right in real time as time passes.

Once price returns to test (mitigate) the zone, the box changes transparency and locks its state, keeping your chart clean and organized.

Built-In Cooldown Protection: Prevents over-trading by enforcing a minimum bar distance between successive signals.

Real-Time Alert Support: Fully integrated alert conditions for both Unicorn BUY and Unicorn SELL events so you can connect them straight to your mobile notifications.

---

## Source Code

````pine
//@version=6
indicator("ICT Unicorn Model - Clean Pro", shorttitle="Clean Unicorn", overlay=true, max_boxes_count=100, max_lines_count=100)

//=====================================================
// INPUTS
//=====================================================
grp = "Unicorn Settings"
tf = input.timeframe("1", "Timeframe", group=grp)
lookback = input.int(15, "Liquidity Lookback Bars", minval=5, group=grp)
minDisp = input.float(1.4, "Displacement Multiplier", minval=1.0, step=0.1, group=grp, tooltip="סף מומנטום גבוה יותר כדי לסנן נרות חלשים")
minBodyRatio = input.float(0.65, "Min Candle Body Ratio", minval=0.5, maxval=0.9, step=0.05, group=grp, tooltip="דורש נר פריצה נקי בלי פתילים ארוכים מידי")
cooldownBars = input.int(8, "Cooldown Bars", minval=1, group=grp)

goldColor = #FFD700

//=====================================================
// CORE FUNCTION 
//=====================================================
f_unicorn() =>
    recentLow = ta.lowest(low, lookback)[1]
    recentHigh = ta.highest(high, lookback)[1]

    var int barsSinceLowSweep = 999
    var int barsSinceHighSweep = 999

    barsSinceLowSweep  += 1
    barsSinceHighSweep += 1

    if low <= recentLow
        barsSinceLowSweep := 0
    if high >= recentHigh
        barsSinceHighSweep := 0

    bool sweptLowRecent = barsSinceLowSweep <= 4
    bool sweptHighRecent = barsSinceHighSweep <= 4

    // בדיקת עוצמת נר (דיספלייסמנט אמיתי + יחס גוף לנר גבוה כדי למנוע פתילים)
    body = math.abs(close - open)
    candleRange = high - low
    bodyRatio = candleRange > 0 ? body / candleRange : 0
    avgBody = ta.sma(body, 20)
    
    isStrongDisplacement = (body > avgBody * minDisp) and (bodyRatio >= minBodyRatio) and (close != open)

    // FVG 
    bullFvg = (low > high[2]) and isStrongDisplacement and close > open
    bearFvg = (high < low[2]) and isStrongDisplacement and close < open

    bool validBull = sweptLowRecent and bullFvg
    bool validBear = sweptHighRecent and bearFvg

    float zoneTop = na
    float zoneBottom = na

    if validBull
        zoneTop := math.max(high[2], high[1])
        zoneBottom := math.min(low, low[1])
    else if validBear
        zoneTop := math.max(high, high[1])
        zoneBottom := math.min(low[2], low[1])

    [validBull, validBear, zoneTop, zoneBottom]

//=====================================================
// REQUEST SECURITY
//=====================================================
[sBull, sBear, sTop, sBottom] = request.security(
     syminfo.tickerid,
     tf,
     f_unicorn(),
     lookahead=barmerge.lookahead_off
     )

//=====================================================
// ACTIVE BOXES MANAGEMENT (MITIGATION)
//=====================================================
type ActiveBox
    box     b
    float   top
    float   bottom
    bool    isBull

var ActiveBox[] activeBoxes = array.new<ActiveBox>()

var int lastBullBar = -999
var int lastBearBar = -999

bool allowBull = (bar_index - lastBullBar) > cooldownBars
bool allowBear = (bar_index - lastBearBar) > cooldownBars

if sBull and barstate.isconfirmed and allowBull
    lastBullBar := bar_index
    box newBox = box.new(
         left=bar_index - 1,
         top=sTop,
         right=bar_index,
         bottom=sBottom,
         bgcolor=color.new(color.green, 85),
         border_color=goldColor,
         border_width=2,
         border_style=line.style_solid
     )
    label.new(
         bar_index,
         sTop,
         "🦄 Unicorn BUY",
         color=color.green,
         textcolor=goldColor,
         style=label.style_label_down,
         size=size.small
     )
    array.push(activeBoxes, ActiveBox.new(newBox, sTop, sBottom, true))

if sBear and barstate.isconfirmed and allowBear
    lastBearBar := bar_index
    box newBox = box.new(
         left=bar_index - 1,
         top=sTop,
         right=bar_index,
         bottom=sBottom,
         bgcolor=color.new(color.red, 85),
         border_color=goldColor,
         border_width=2,
         border_style=line.style_solid
     )
    label.new(
         bar_index,
         sBottom,
         "🦄 Unicorn SELL",
         color=color.red,
         textcolor=goldColor,
         style=label.style_label_up,
         size=size.small
     )
    array.push(activeBoxes, ActiveBox.new(newBox, sTop, sBottom, false))

if array.size(activeBoxes) > 0
    for i = array.size(activeBoxes) - 1 to 0
        ActiveBox ab = array.get(activeBoxes, i)
        box b = ab.b
        float t = ab.top
        float bo = ab.bottom
        bool isB = ab.isBull

        bool mitigated = isB ? (low <= t and high >= bo) : (high >= bo and low <= t)

        if not mitigated
            box.set_right(b, bar_index)
        else
            box.set_bgcolor(b, color.new(isB ? color.green : color.red, 92))
            array.remove(activeBoxes, i)

//=====================================================
// ALERTS
//=====================================================
alertcondition(sBull, title="Unicorn BUY", message="Unicorn BUY Zone detected!")
alertcondition(sBear, title="Unicorn SELL", message="Unicorn SELL Zone detected!")
````
