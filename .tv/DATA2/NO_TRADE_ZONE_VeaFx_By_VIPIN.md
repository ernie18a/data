<!-- tradingview-pine-id: PUB;ba41af9db04241ac81c07ea892d6cade -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# NO TRADE ZONE VeaFx By VIPIN

Source: https://www.tradingview.com/script/g69zQChf-NO-TRADE-ZONE-VeaFx-By-VIPIN/

## Description

🔹 How It Works

* The indicator monitors a 60-minute price window.
* It calculates the High and Low of that complete 60-minute period.
* If the total High–Low range is $15 or less, the area is identified as a NO TRADE ZONE.
* The zone is displayed as a box with a subtle “NO TRADE ZONE” watermark inside the box.
* The watermark stays behind the candles so that price action remains clearly visible.
* The box continues extending as long as price remains within the identified range.
* The zone ends when a candle closes above the High or below the Low of the zone.
* After a breakout or breakdown, a 60-minute cooldown period is applied before another No Trade Zone can be created.

🔹 Designed For

* XAUUSD / Gold
* Market consolidation detection
* Avoiding trades during tight-range conditions
* Identifying potential breakout areas
* 5-minute and 15-minute chart analysis

⚠️ Disclaimer

This indicator is for educational, research, and market-analysis purposes only. It is not financial advice and does not provide guaranteed or “sure-shot” trading signals. A No Trade Zone does not guarantee that a breakout will occur or predict its direction.

Always perform your own analysis, backtest the indicator, consider spread/slippage and broker-specific pricing, and use proper risk management. Trade responsibly.

---

## Source Code

````pine
//@version=6
indicator("NO TRADE ZONE VeaFx By VIPIN", overlay=true, max_boxes_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

maxRange = input.float(15.0, "Maximum Range ($)", step=0.1)
cooldownMinutes = input.int(60, "Cooldown After Breakout (Minutes)", minval=60)

showWatermark = input.bool(true, "Show Watermark")
watermarkText = input.string("NO TRADE ZONE", "Watermark Text")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 60 MINUTE WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

windowTime = time("60")
newWindow = ta.change(windowTime) != 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VARIABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float windowHigh = na
var float windowLow = na
var int windowStartBar = na

var bool zoneActive = false

var float zoneHigh = na
var float zoneLow = na

var box ntzBox = na

// Cooldown
var int cooldownStart = na
var bool cooldownActive = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INITIALIZE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if na(windowHigh)
    windowHigh := high
    windowLow := low
    windowStartBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COOLDOWN CHECK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if cooldownActive

    cooldownElapsed = (time - cooldownStart) / 60000.0

    if cooldownElapsed >= cooldownMinutes
        cooldownActive := false
        cooldownStart := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLLECT 60M RANGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not zoneActive

    windowHigh := math.max(windowHigh, high)
    windowLow := math.min(windowLow, low)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPLETED 60M WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newWindow and not zoneActive

    finalRange = windowHigh - windowLow

    if finalRange <= maxRange and not cooldownActive

        zoneHigh := windowHigh
        zoneLow := windowLow

        zoneActive := true

        //━━━━━━━━━━━━━━━━━━━━━━━━━━
        // CREATE WATERMARK BOX
        //━━━━━━━━━━━━━━━━━━━━━━━━━━

        ntzBox := box.new(
             left=windowStartBar,
             top=zoneHigh,
             right=bar_index,
             bottom=zoneLow,
             border_color=color.red,
             border_width=2,
             bgcolor=color.new(color.red, 90),
             text=showWatermark ? watermarkText : "",
             text_color=color.new(color.white, 65),
             text_size=size.large,
             text_halign=text.align_center,
             text_valign=text.align_center)

    // Start next 60M window
    windowHigh := high
    windowLow := low
    windowStartBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXTEND BOX
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if zoneActive

    box.set_right(ntzBox, bar_index)

    // Keep watermark centered inside box
    box.set_text(ntzBox, showWatermark ? watermarkText : "")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKOUT / BREAKDOWN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if zoneActive

    breakoutUp = close > zoneHigh
    breakoutDown = close < zoneLow

    if breakoutUp or breakoutDown

        box.set_right(ntzBox, bar_index)

        // End zone
        zoneActive := false

        zoneHigh := na
        zoneLow := na

        ntzBox := na

        //━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 60 MINUTE COOLDOWN
        //━━━━━━━━━━━━━━━━━━━━━━━━━━

        cooldownActive := true
        cooldownStart := time
````
