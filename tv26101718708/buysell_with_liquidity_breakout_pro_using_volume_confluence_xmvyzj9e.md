# Buy-Sell with Liquidity Breakout PRO using Volume Confluence

- url: https://www.tradingview.com/script/XmVyzj9e-Buy-Sell-with-Liquidity-Breakout-PRO-using-Volume-Confluence/
- type: indicator
- pine_id: PUB;90c42db8ecef40958ad0d2b4e219ea3c
- version: 1.0

## Description

[b]# Liquidity Breakout PRO with Volume Confirmation — Swing Edition [/b]

[i]A professional major swing breakout indicator designed to identify important liquidity breakout and breakdown zones using confirmed swing highs, confirmed swing lows, volume confluence, smart stop-loss modes, Fibonacci-based targets, and historical risk-reward boxes.

This indicator is built for traders who want cleaner breakout signals, structured trade planning, and visual performance review directly on the chart.[/i]

--------------------------------------------------

[b]## What This Indicator Does[/b]

[i]Liquidity Breakout PRO helps identify major breakout and breakdown opportunities after price crosses an important confirmed swing level.

Instead of reacting to every small move, this indicator focuses on major swing highs and swing lows. These levels often act as liquidity zones where stop orders, breakout traders, and institutional activity may become visible.

When price closes above a confirmed major swing high, the indicator marks a bullish breakout setup.

When price closes below a confirmed major swing low, the indicator marks a bearish breakdown setup.
[/i]

[b]Each confirmed signal comes with:[/b]

✅Entry level
✅Stop-loss level
✅Fibonacci-based target levels
✅Risk zone
✅Reward zone
✅Historical risk-reward box
✅Volume confirmation
✅Dashboard panel

--------------------------------------------------

[b]## Core Concept[/b]

https://www.tradingview.com/x/gNUj7vE0/

[i]Markets often move from one liquidity zone to another.

A major swing high usually represents an area where sellers previously defended price. When price closes above that area with volume confirmation, it may suggest breakout strength.

A major swing low usually represents an area where buyers previously defended price. When price closes below that area with volume confirmation, it may suggest breakdown weakness.[/i]

[b]This indicator is designed around that simple idea:[/b]

✅Identify major liquidity level
✅Wait for confirmed close beyond that level
✅Check volume confluence
✅Plot entry, stop loss, and Fibonacci targets
✅Keep the setup on chart for future performance review

--------------------------------------------------

[b][b]## Key Features[/b][/b]

📊 1. [b]Major Swing Detection[/b]

[i]The indicator uses confirmed pivot highs and pivot lows to identify important swing levels.

These are not random support and resistance lines. They are confirmed swing points based on user-defined left and right pivot strength.

This helps reduce noise and focuses only on important market structure level[/i]s.

--------------------------------------------------

📊 [b]2. Non-Repainting Logic[/b]

[i]Signals are generated only after candle close.

The indicator uses confirmed pivot levels and candle-close breakout confirmation. This means signals are not designed to appear and disappear during live candle movement.

Important note: pivot-based swing levels naturally confirm after the selected right-side candles are completed. This delay helps improve swing reliability and reduces false signals.[/i]

--------------------------------------------------

📊 [b]3. Volume Confluence[/b]

[i]Breakout signals become stronger when supported by volume.

The indicator includes a volume filter that checks whether current volume is greater than the average volume multiplied by the selected volume multiplier.

This helps avoid weak breakout attempts where price crosses a level without strong participation.[/i]

--------------------------------------------------

📊 [b]4. ATR Breakout Buffer[/b]

[i]Many breakouts fail because price barely crosses a level and then quickly reverses.

To reduce such weak signals, the indicator includes an optional ATR-based breakout buffer.

This means price must close beyond the swing level with a minimum volatility-adjusted distance before a signal is generated.[/i]

--------------------------------------------------

📊 [b]5. Multiple Stop-Loss Modes[/b]

[i]Different traders use different stop-loss styles, so this indicator provides multiple SL calculation modes.[/i]

https://www.tradingview.com/x/djmBNp7V/

[b]Available stop-loss modes:[/b]

✅Previous Candle
✅ATR
✅Major Swing Level
✅Breakout Candle
✅Previous Candle + ATR Buffer

[i]This gives flexibility for intraday traders, swing traders, and positional traders.[/i]

--------------------------------------------------

## [b]Stop-Loss Modes Explained[/b]

📊 [b]Previous Candle[/b]

[list]
[*][i]For a buy breakout, stop loss is placed below the previous candle low.
[*]
[*]For a sell breakdown, stop loss is placed above the previous candle high.
[/list]

This is useful for traders who prefer tighter and structure-based stop losses.[/i]

--------------------------------------------------

[b]📊 ATR[/b]

[i][list]
[*]For a buy breakout, stop loss is calculated below entry using ATR.
[*]
[*]For a sell breakdown, stop loss is calculated above entry using ATR.
[/list]

This is useful for traders who want volatility-adjusted stop losses.[/i]

--------------------------------------------------

[b]📊Major Swing Level[/b]

[i][list]
[*]For a buy breakout, stop loss is placed near the last confirmed major swing low.
[*]
[*]For a sell breakdown, stop loss is placed near the last confirmed major swing high.
[/list]

This is useful for traders who prefer wider structure-based stops.[/i]

--------------------------------------------------

[b]📊 Breakout Candle[/b]

[i][list]
[*]For a buy breakout, stop loss is placed below the breakout candle low.
[*]
[*]For a sell breakdown, stop loss is placed above the breakout candle high.
[/list]

This is useful when traders want the breakout candle itself to define risk.[/i]

--------------------------------------------------

[b]📊 Previous Candle + ATR Buffer[/b]

[i]This mode uses the previous candle high or low with an added ATR cushion.

[list]
[*]For a buy breakout, stop loss is placed below the previous candle low with ATR buffer.
[*]
[*]For a sell breakdown, stop loss is placed above the previous candle high with ATR buffer.
[*]
[/list]
This is a balanced stop-loss method because it gives slightly more breathing room than a pure previous candle stop.[/i]

--------------------------------------------------

[b]##Separate Fibonacci Target Calculation[/b]

[i]One important feature of this indicator is that Fibonacci targets are calculated separately from stop loss.

This means if stop loss becomes wider, targets do not automatically become wider.

Targets are based on a separate target range calculation, not on risk distance.

This avoids unrealistic target expansion when using wide stop-loss methods.[/i]

--------------------------------------------------

https://www.tradingview.com/x/8KDV8cb7/

[b]## Fibonacci Target Base Options[/b]

[i]The indicator provides different target base modes:[/i]

✅Major Swing Range
✅Breakout Candle Range
✅ATR Range

[b]📊Major Swing Range[/b]

[i]Targets are calculated using the range between the latest major swing high and major swing low.

This is suitable for swing trading and higher timeframes.[/i]

[b]📊Breakout Candle Range[/b]

[i]Targets are calculated using the breakout candle range.

This is useful for intraday traders who want more practical and closer targets.[/i]

[b]📊 ATR Range[/b]

[i]Targets are calculated using ATR.

This gives volatility-adjusted target levels.
[/i]
--------------------------------------------------

[b]## Risk-Reward Boxes[/b]

[i]Every confirmed signal plots a visual risk-reward structure on the chart.[/i]

[i]✅The red box shows the risk zone.

✅The green box shows the reward zone.

✅Fibonacci target zones are displayed visually so traders can instantly understand where TP1, TP2, and TP3 are placed.

Historical boxes can remain on the chart, allowing traders to review past signal performance visually. Those who dont want any noise on the chart can opt out from historical boxes in the Settings menu. [/i]

[b]This helps users observe:[/b]

✅Which signals reached target
✅Which signals hit stop loss
✅How price reacted after breakout
✅How often TP1, TP2, or TP3 was reached
✅Whether breakout continuation was strong or weak

--------------------------------------------------

[b]## Visual Features[/b]

[i]This indicator includes multiple visual enhancements:[/i]

✅Premium color themes
✅Risk-reward box styles
✅Layered Fibonacci target zones
✅Signal candle highlight
✅Breakout background flash
✅Signal glow effect
✅Custom line styles
✅Dashboard panel
✅Historical setup plotting

[i]These features are designed to make the chart more readable, more professional, and easier to analyze.[/i]

--------------------------------------------------

[b]## Best Default Settings[/b]

[b]For a balanced setup:[/b]

[list]
[*]Pivot Left Strength: 20
[*]Pivot Right Strength: 20
[*]ATR Breakout Buffer: ON
[*]ATR Buffer Multiplier: 0.15
[*]Volume Confluence: ON
[*]Volume Multiplier: 1.3
[*]Stop Loss Mode: Previous Candle + ATR Buffer
[*]SL Buffer ATR Multiplier: 0.20
[*]Fibonacci Target Base: Major Swing Range
[*]Targets: 1.0 / 1.618 / 2.618
[*]Keep Previous Target/SL Boxes: ON
[/list]

--------------------------------------------------

[b]## Suggested Intraday Settings[/b]

[b]For 15-minute or lower timeframes:[/b]

[list]
[*]Pivot Left Strength: 10
[*]Pivot Right Strength: 10
[*]ATR Breakout Buffer: 0.10
[*]Volume Multiplier: 1.2
[*]Stop Loss Mode: Previous Candle or Previous Candle + ATR Buffer
[*]Fibonacci Target Base: Breakout Candle Range
[*]Risk-Reward Box Extension: 20–25 bars
[/list]

--------------------------------------------------

[b]## Suggested Swing Trading Settings[/b]

[b]For 1H, 4H, or daily charts:[/b]


[list]
[*]Pivot Left Strength: 20–30
[*]Pivot Right Strength: 20–30
[*]ATR Breakout Buffer: 0.15–0.30
[*]Volume Multiplier: 1.3–1.5
[*]Stop Loss Mode: Previous Candle + ATR Buffer or Major Swing Level
[*]Fibonacci Target Base: Major Swing Range
[*]Risk-Reward Box Extension: 25–40 bars
[/list]


--------------------------------------------------

## How To Use

1. Wait for a major swing high or swing low to form.

2. Let price break and close beyond the swing level.

3. Check whether the signal is volume confirmed.

4. Observe the plotted entry, stop loss, and Fibonacci targets.

5. Use the risk-reward box to understand the trade structure.

6. Avoid taking signals directly into strong nearby support or resistance.

7. Use higher timeframe trend direction for stronger confirmation.

--------------------------------------------------

https://www.tradingview.com/x/IcfPShG2/

[b]## Bullish Signal[/b]

[i]A bullish breakout signal appears when price closes above a confirmed major swing high with required confluence.

This suggests that buyers may be taking control above a previous liquidity zone.[/i]

--------------------------------------------------

https://www.tradingview.com/x/L0xOkiwM/

[b]## Bearish Signal[/b]

[i]A bearish breakdown signal appears when price closes below a confirmed major swing low with required confluence.

This suggests that sellers may be taking control below a previous liquidity zone.[/i]

--------------------------------------------------

[b]## Best Use Cases[/b]

📊Breakout trading

📊Liquidity breakout analysis

📊Market structure trading

📊Swing high and swing low breakout setups

📊Intraday breakout confirmation

📊Multi-timeframe analysis

📊Risk-reward planning

--------------------------------------------------

[b]⚠️  Important Notes [/b] 

⚠️ No indicator can predict the market with certainty.

⚠️ This tool is designed to help with structure, confirmation, and visual trade planning.

⚠️ Always combine signals with market context, higher timeframe direction, support and resistance, risk management, and your own trading plan.

⚠️ Avoid using any breakout signal blindly. This indicator itself suggests that using Stoploss is more important than Targets. Always use stoploss to protect the capital. 

--------------------------------------------------

[b]Trading Rules & Best Practices[/b]

[b]✅ When to Use This Indicator[/b]

[list=1]
[*]Trend-Following Setups: Use on trending charts where swing levels have clear structure

[*]Breakout Trading: Ideal for breakout traders targeting support/resistance breaks

[*]Range Identification: Works well when price oscillates between major highs/lows

[*]Multi-Timeframe Analysis: Use higher timeframes (4H, 1D) to identify major swings for entry on lower timeframes
[/list]


[b]⚠️ When NOT to Use[/b]


[list=1]
[*]Choppy/Ranging Markets: In sideways markets, many false breakouts may occur

[*]Low Liquidity Assets: Volume filter may never trigger; consider disabling it

[*]Highly Volatile Instruments: Increase ATR buffer multiplier to reduce noise
[/list]

--------------------------------------------------

[b]## Risk Disclaimer[/b]

This indicator is for educational and analytical purposes only. It does not provide financial advice, investment advice, or guaranteed trading signals.
Trading and investing involve risk. Always use proper risk management and do your own analysis before taking any trade.

--------------------------------------------------




[i]Test it on different timeframes and comment which SL mode works best for your trading style.

Feedback and improvement suggestions are welcome. [/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © InvestyourAsset


//@version=6
indicator("Liquidity Breakout PRO with Volume Confluence by InvestyourAsset", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// =====================================================
// INPUT GROUPS
// =====================================================
grpSwing  = "01. Swing Settings"
grpBreak  = "02. Breakout Filters"
grpVol    = "03. Volume Confluence"
grpSL     = "04. Stop Loss Settings"
grpTP     = "05. Fibonacci Target Settings"
grpVisual = "06. Visual Effects"
grpDash   = "07. Dashboard"

// =====================================================
// SWING INPUTS
// =====================================================
leftLen  = input.int(20, "Pivot Left Strength", minval=1, group=grpSwing)
rightLen = input.int(20, "Pivot Right Strength", minval=1, group=grpSwing)

// =====================================================
// BREAKOUT FILTER
// =====================================================
useAtrBuffer = input.bool(true, "Use ATR Breakout Buffer", group=grpBreak)
atrLen       = input.int(14, "ATR Length", minval=1, group=grpBreak)
atrBufferMul = input.float(0.15, "ATR Breakout Buffer Multiplier", step=0.05, group=grpBreak)

// =====================================================
// VOLUME CONFLUENCE
// =====================================================
useVolFilter = input.bool(true, "Use Volume Confluence", group=grpVol)
volLen       = input.int(20, "Volume Average Length", minval=1, group=grpVol)
volMult      = input.float(1.3, "Volume Multiplier", step=0.1, group=grpVol)

// =====================================================
// STOP LOSS SETTINGS
// =====================================================
slMode = input.string(
     "Previous Candle + ATR Buffer",
     "Stop Loss Calculation Mode",
     options=[
         "Previous Candle",
         "ATR",
         "Major Swing Level",
         "Breakout Candle",
         "Previous Candle + ATR Buffer"
     ],
     group=grpSL
)

slAtrMult       = input.float(1.5, "ATR Stop Loss Multiplier", step=0.1, group=grpSL)
slBufferAtrMult = input.float(0.20, "SL Buffer ATR Multiplier", step=0.05, group=grpSL)

// =====================================================
// FIBONACCI TARGET SETTINGS
// =====================================================
fibTarget1 = input.float(1.0, "Target 1 Fib Extension", step=0.1, group=grpTP)
fibTarget2 = input.float(1.618, "Target 2 Fib Extension", step=0.001, group=grpTP)
fibTarget3 = input.float(2.618, "Target 3 Fib Extension", step=0.001, group=grpTP)

targetRangeMode = input.string(
     "Major Swing Range",
     "Fibonacci Target Base",
     options=["Major Swing Range", "Breakout Candle Range", "ATR Range"],
     group=grpTP
)

// =====================================================
// VISUAL SETTINGS
// =====================================================
visualTheme = input.string(
     "Premium Dark",
     "Color Theme",
     options=["Premium Dark", "Neon", "Gold", "Minimal", "TradingView", "Custom"],
     group=grpVisual
)

customBullColor    = input.color(color.lime, "Custom Bull Color", group=grpVisual)
customBearColor    = input.color(color.red, "Custom Bear Color", group=grpVisual)
customNeutralColor = input.color(color.white, "Custom Neutral Color", group=grpVisual)

boxStyle = input.string(
     "Glass",
     "Risk/Reward Box Style",
     options=["Solid", "Soft", "Glass", "Outline"],
     group=grpVisual
)

rewardBoxMode = input.string(
     "Layered Fib Zones",
     "Target Box Mode",
     options=["Single Reward Box", "Layered Fib Zones"],
     group=grpVisual
)

lineStyleInput = input.string(
     "Solid",
     "Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=grpVisual
)

labelSizeInput = input.string(
     "Normal",
     "Signal Label Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=grpVisual
)

showSwingLevels      = input.bool(true, "Show Active Major Swing Levels", group=grpVisual)
showSwingLabels      = input.bool(true, "Show Major Swing Labels", group=grpVisual)
showRiskReward       = input.bool(true, "Show Risk Reward Boxes", group=grpVisual)
showSignalGlow       = input.bool(true, "Show Signal Glow", group=grpVisual)
showSignalCandle     = input.bool(true, "Highlight Signal Candle", group=grpVisual)
showBackgroundFlash  = input.bool(true, "Show Background Flash on Signal", group=grpVisual)
showBoxText          = input.bool(true, "Show Text Inside Boxes", group=grpVisual)
keepHistoricalSetups = input.bool(true, "Keep Previous Target/SL Boxes", group=grpVisual)

boxBars       = input.int(25, "Risk Reward Box Extension Bars", minval=5, group=grpVisual)
levelLineBars = input.int(15, "Breakout Level Line Bars", minval=5, group=grpVisual)

// =====================================================
// DASHBOARD
// =====================================================
showDashboard = input.bool(true, "Show Dashboard", group=grpDash)

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=grpDash
)

// =====================================================
// HELPER FUNCTIONS
// =====================================================
f_lineStyle(_style) =>
    _style == "Dashed" ? line.style_dashed :
     _style == "Dotted" ? line.style_dotted :
     line.style_solid

f_labelSize(_size) =>
    _size == "Tiny" ? size.tiny :
     _size == "Small" ? size.small :
     _size == "Large" ? size.large :
     size.normal

f_tablePos(_pos) =>
    _pos == "Top Left" ? position.top_left :
     _pos == "Bottom Right" ? position.bottom_right :
     _pos == "Bottom Left" ? position.bottom_left :
     position.top_right

// =====================================================
// THEME COLORS
// =====================================================
color bullColor = switch visualTheme
    "Premium Dark" => color.rgb(0, 200, 120)
    "Neon" => color.rgb(0, 255, 170)
    "Gold" => color.rgb(212, 175, 55)
    "Minimal" => color.rgb(76, 175, 80)
    "TradingView" => color.rgb(41, 98, 255)
    "Custom" => customBullColor

color bearColor = switch visualTheme
    "Premium Dark" => color.rgb(255, 80, 90)
    "Neon" => color.rgb(255, 40, 120)
    "Gold" => color.rgb(180, 70, 45)
    "Minimal" => color.rgb(244, 67, 54)
    "TradingView" => color.rgb(255, 82, 82)
    "Custom" => customBearColor

color neutralColor = switch visualTheme
    "Premium Dark" => color.rgb(230, 230, 230)
    "Neon" => color.rgb(220, 255, 255)
    "Gold" => color.rgb(255, 235, 170)
    "Minimal" => color.rgb(210, 210, 210)
    "TradingView" => color.rgb(255, 255, 255)
    "Custom" => customNeutralColor

int riskTransp = switch boxStyle
    "Solid" => 72
    "Soft" => 84
    "Glass" => 90
    "Outline" => 100

int rewardTransp = switch boxStyle
    "Solid" => 72
    "Soft" => 84
    "Glass" => 90
    "Outline" => 100

int boxBorderWidth = boxStyle == "Outline" ? 2 : 1

// =====================================================
// MAJOR SWING DETECTION
// =====================================================
ph = ta.pivothigh(high, leftLen, rightLen)
pl = ta.pivotlow(low, leftLen, rightLen)

var float lastMajorHigh = na
var float lastMajorLow  = na

var int lastMajorHighBar = na
var int lastMajorLowBar  = na

var float brokenHighLevel = na
var float brokenLowLevel  = na

var line highLevelLine = na
var line lowLevelLine  = na

// Latest setup objects for optional deletion
var box riskBox    = na
var box rewardBox1 = na
var box rewardBox2 = na
var box rewardBox3 = na

var line breakLine = na
var line entryLine = na
var line slLine    = na
var line tp1Line   = na
var line tp2Line   = na
var line tp3Line   = na

var label signalLabel = na
var label entryLabel  = na
var label slLabel     = na
var label tp1Label    = na
var label tp2Label    = na
var label tp3Label    = na

// Latest dashboard values
var string lastSignalText = "Waiting"
var string lastSLMode     = "N/A"
var float lastEntry       = na
var float lastSL          = na
var float lastTP1         = na
var float lastTP2         = na
var float lastTP3         = na
var float lastRR1         = na
var float lastRR2         = na
var float lastRR3         = na

// =====================================================
// ATR + VOLUME
// =====================================================
atrValue = ta.atr(atrLen)
buffer   = useAtrBuffer ? atrValue * atrBufferMul : 0.0

volAvg      = ta.sma(volume, volLen)
volumeValid = volume > volAvg * volMult
volumeConfluence = not useVolFilter or volumeValid

// =====================================================
// TARGET RANGE CALCULATION
// =====================================================
// Targets are independent from stop loss.
// Bigger SL will not increase target distance.

majorSwingRange = not na(lastMajorHigh) and not na(lastMajorLow) ? math.abs(lastMajorHigh - lastMajorLow) : atrValue
breakoutCandleRange = math.abs(high - low)
atrRange = atrValue

fibBaseRange = switch targetRangeMode
    "Major Swing Range" => majorSwingRange
    "Breakout Candle Range" => breakoutCandleRange
    "ATR Range" => atrRange

fibBaseRange := math.max(fibBaseRange, syminfo.mintick)

// =====================================================
//  MAJOR HIGH
// =====================================================
if not na(ph)
    lastMajorHigh := ph
    lastMajorHighBar := bar_index - rightLen
    brokenHighLevel := na

    if showSwingLevels
        if not na(highLevelLine)
            line.delete(highLevelLine)

        highLevelLine := line.new(
             x1=lastMajorHighBar,
             y1=lastMajorHigh,
             x2=bar_index,
             y2=lastMajorHigh,
             extend=extend.right,
             color=color.new(bullColor, 35),
             width=2,
             style=f_lineStyle(lineStyleInput)
        )

    if showSwingLabels
        label.new(
             x=lastMajorHighBar,
             y=lastMajorHigh,
             text="Swing High",
             style=label.style_label_down,
             color=color.new(bullColor, 10),
             textcolor=color.white,
             size=size.tiny
        )

// =====================================================
//  MAJOR LOW
// =====================================================
if not na(pl)
    lastMajorLow := pl
    lastMajorLowBar := bar_index - rightLen
    brokenLowLevel := na

    if showSwingLevels
        if not na(lowLevelLine)
            line.delete(lowLevelLine)

        lowLevelLine := line.new(
             x1=lastMajorLowBar,
             y1=lastMajorLow,
             x2=bar_index,
             y2=lastMajorLow,
             extend=extend.right,
             color=color.new(bearColor, 35),
             width=2,
             style=f_lineStyle(lineStyleInput)
        )

    if showSwingLabels
        label.new(
             x=lastMajorLowBar,
             y=lastMajorLow,
             text="Swing Low",
             style=label.style_label_up,
             color=color.new(bearColor, 10),
             textcolor=color.white,
             size=size.tiny
        )

// =====================================================
// NON-REPAINTING BREAKOUT LOGIC
// =====================================================
bullBreakRaw = not na(lastMajorHigh) and close > lastMajorHigh + buffer and close[1] <= lastMajorHigh + buffer
bearBreakRaw = not na(lastMajorLow) and close < lastMajorLow - buffer and close[1] >= lastMajorLow - buffer

bullSignal = barstate.isconfirmed and bullBreakRaw and volumeConfluence and (na(brokenHighLevel) or brokenHighLevel != lastMajorHigh)
bearSignal = barstate.isconfirmed and bearBreakRaw and volumeConfluence and (na(brokenLowLevel) or brokenLowLevel != lastMajorLow)

// =====================================================
// CHART VISUAL EFFECTS
// =====================================================
barcolor(showSignalCandle ? bullSignal ? bullColor : bearSignal ? bearColor : na : na)

bgcolor(
     showBackgroundFlash ?
     bullSignal ? color.new(bullColor, 88) :
     bearSignal ? color.new(bearColor, 88) :
     na : na
)

plotshape(
     showSignalGlow and bullSignal,
     title="Bullish Signal Glow",
     style=shape.circle,
     location=location.belowbar,
     color=color.new(bullColor, 70),
     size=size.large
)

plotshape(
     showSignalGlow and bullSignal,
     title="Bullish Signal Dot",
     style=shape.circle,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
)

plotshape(
     showSignalGlow and bearSignal,
     title="Bearish Signal Glow",
     style=shape.circle,
     location=location.abovebar,
     color=color.new(bearColor, 70),
     size=size.large
)

plotshape(
     showSignalGlow and bearSignal,
     title="Bearish Signal Dot",
     style=shape.circle,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
)

// =====================================================
// DELETE OLD OBJECTS ONLY IF HISTORY MODE IS OFF
// =====================================================
if (bullSignal or bearSignal) and not keepHistoricalSetups
    if not na(riskBox)
        box.delete(riskBox)
    if not na(rewardBox1)
        box.delete(rewardBox1)
    if not na(rewardBox2)
        box.delete(rewardBox2)
    if not na(rewardBox3)
        box.delete(rewardBox3)

    if not na(breakLine)
        line.delete(breakLine)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)

    if not na(signalLabel)
        label.delete(signalLabel)
    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(slLabel)
        label.delete(slLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tp3Label)
        label.delete(tp3Label)

// =====================================================
// BULLISH BREAKOUT SETUP
// =====================================================
if bullSignal
    brokenHighLevel := lastMajorHigh

    entryPrice = close

    float stopLoss = na

    if slMode == "Previous Candle"
        stopLoss := low[1]
    else if slMode == "ATR"
        stopLoss := entryPrice - atrValue * slAtrMult
    else if slMode == "Major Swing Level"
        stopLoss := not na(lastMajorLow) ? lastMajorLow : low[1]
    else if slMode == "Breakout Candle"
        stopLoss := low
    else if slMode == "Previous Candle + ATR Buffer"
        stopLoss := low[1] - atrValue * slBufferAtrMult

    stopLoss := math.min(stopLoss, entryPrice - syminfo.mintick)

    target1 = entryPrice + fibBaseRange * fibTarget1
    target2 = entryPrice + fibBaseRange * fibTarget2
    target3 = entryPrice + fibBaseRange * fibTarget3

    riskAmount = entryPrice - stopLoss
    rr1 = riskAmount > 0 ? (target1 - entryPrice) / riskAmount : na
    rr2 = riskAmount > 0 ? (target2 - entryPrice) / riskAmount : na
    rr3 = riskAmount > 0 ? (target3 - entryPrice) / riskAmount : na

    lastSignalText := "Bullish Breakout"
    lastSLMode := slMode
    lastEntry := entryPrice
    lastSL := stopLoss
    lastTP1 := target1
    lastTP2 := target2
    lastTP3 := target3
    lastRR1 := rr1
    lastRR2 := rr2
    lastRR3 := rr3

    signalLabel := label.new(
         x=bar_index,
         y=low,
         text="🚀 MAJOR BREAKOUT\nVolume Confirmed\nSL: " + slMode,
         style=label.style_label_up,
         color=color.new(bullColor, 0),
         textcolor=color.white,
         size=f_labelSize(labelSizeInput)
    )

    breakLine := line.new(
         x1=bar_index,
         y1=lastMajorHigh,
         x2=bar_index + levelLineBars,
         y2=lastMajorHigh,
         color=bullColor,
         width=3,
         style=f_lineStyle(lineStyleInput)
    )

    if showRiskReward
        riskBox := box.new(
             left=bar_index,
             top=entryPrice,
             right=bar_index + boxBars,
             bottom=stopLoss,
             bgcolor=color.new(bearColor, riskTransp),
             border_color=color.new(bearColor, 10),
             border_width=boxBorderWidth,
             border_style=f_lineStyle(lineStyleInput),
             text=showBoxText ? "RISK\nSL Zone" : "",
             text_color=color.new(color.white, 15),
             text_size=size.tiny,
             text_halign=text.align_center,
             text_valign=text.align_center
        )

        if rewardBoxMode == "Single Reward Box"
            rewardBox1 := box.new(
                 left=bar_index,
                 top=target3,
                 right=bar_index + boxBars,
                 bottom=entryPrice,
                 bgcolor=color.new(bullColor, rewardTransp),
                 border_color=color.new(bullColor, 10),
                 border_width=boxBorderWidth,
                 border_style=f_lineStyle(lineStyleInput),
                 text=showBoxText ? "REWARD\nFib Zone" : "",
                 text_color=color.new(color.white, 15),
                 text_size=size.tiny,
                 text_halign=text.align_center,
                 text_valign=text.align_center
            )
        else
            rewardBox1 := box.new(
                 left=bar_index,
                 top=target1,
                 right=bar_index + boxBars,
                 bottom=entryPrice,
                 bgcolor=color.new(bullColor, math.min(rewardTransp + 4, 95)),
                 border_color=color.new(bullColor, 25),
                 border_width=1,
                 border_style=f_lineStyle(lineStyleInput),
                 text=showBoxText ? "TP1 Zone" : "",
                 text_color=color.new(color.white, 20),
                 text_size=size.tiny,
                 text_halign=text.align_center,
                 text_valign=text.align_center
            )

            rewardBox2 := box.new(
                 left=bar_index,
                 top=target2,
                 right=bar_index + boxBars,
                 bottom=target1,
                 bgcolor=color.new(bullColor, rewardTransp),
                 border_color=color.new(bullColor, 15),
                 border_width=1,
                 border_style=f_lineStyle(lineStyleInput),
                 text=showBoxText ? "TP2 Zone" : "",
                 text_color=color.new(color.white, 15),
                 text_size=size.tiny,
                 text_halign=text.align_center,
                 text_valign=text.align_center
            )

            rewardBox3 := box.new(
                 left=bar_index,
                 top=target3,
                 right=bar_index + boxBars,
                 bottom=target2,
                 bgcolor=color.new(bullColor, math.max(rewardTransp - 4, 70)),
                 border_color=color.new(bullColor, 5),
                 border_width=boxBorderWidth,
                 border_style=f_lineStyle(lineStyleInput),
                 text=showBoxText ? "TP3 Zone" : "",
                 text_color=color.new(color.white, 10),
                 text_size=size.tiny,
                 text_halign=text.align_center,
                 text_valign=text.align_center
            )

        entryLine := line.new(bar_index, entryPrice, bar_index + boxBars, entryPrice, color=neutralColor, width=2)
        slLine    := line.new(bar_index, stopLoss, bar_index + boxBars, stopLoss, color=bearColor, width=2)
        tp1Line   := line.new(bar_index, target1, bar_index + boxBars, target1, color=bullColor, width=1, style=line.style_dashed)
        tp2Line   := line.new(bar_index, target2, bar_index + boxBars, target2, color=bullColor, width=1, style=line.style_dashed)
        tp3Line   := line.new(bar_index, target3, bar_index + boxBars, target3, color=bullColor, width=2)

        entryLabel := label.new(bar_index + boxBars, entryPrice, "Entry: " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=neutralColor, textcolor=color.black)
        slLabel    := label.new(bar_index + boxBars, stopLoss, "SL [" + slMode + "]: " + str.tostring(stopLoss, format.mintick), style=label.style_label_left, color=bearColor, textcolor=color.white)
        tp1Label   := label.new(bar_index + boxBars, target1, "Fib TP1: " + str.tostring(target1, format.mintick) + " | RR " + str.tostring(rr1, "#.##"), style=label.style_label_left, color=bullColor, textcolor=color.white)
        tp2Label   := label.new(bar_index + boxBars, target2, "Fib TP2: " + str.tostring(target2, format.mintick) + " | RR " + str.tostring(rr2, "#.##"), style=label.style_label_left, color=bullColor, textcolor=color.white)
        tp3Label   := label.new(bar_index + boxBars, target3, "Fib TP3: " + str.tostring(target3, format.mintick) + " | RR " + str.tostring(rr3, "#.##"), style=label.style_label_left, color=bullColor, textcolor=color.white)

// =====================================================
// BEARISH BREAKDOWN SETUP
// =====================================================
if bearSignal
    brokenLowLevel := lastMajorLow

    entryPrice = close

    float stopLoss = na

    if slMode == "Previous Candle"
        stopLoss := high[1]
    else if slMode == "ATR"
        stopLoss := entryPrice + atrValue * slAtrMult
    else if slMode == "Major Swing Level"
        stopLoss := not na(lastMajorHigh) ? lastMajorHigh : high[1]
    else if slMode == "Breakout Candle"
        stopLoss := high
    else if slMode == "Previous Candle + ATR Buffer"
        stopLoss := high[1] + atrValue * slBufferAtrMult

    stopLoss := math.max(stopLoss, entryPrice + syminfo.mintick)

    target1 = entryPrice - fibBaseRange * fibTarget1
    target2 = entryPrice - fibBaseRange * fibTarget2
    target3 = entryPrice - fibBaseRange * fibTarget3

    riskAmount = stopLoss - entryPrice
    rr1 = riskAmount > 0 ? (entryPrice - target1) / riskAmount : na
    rr2 = riskAmount > 0 ? (entryPrice - target2) / riskAmount : na
    rr3 = riskAmount > 0 ? (entryPrice - target3) / riskAmount : na

    lastSignalText := "Bearish Breakdown"
    lastSLMode := slMode
    lastEntry := entryPrice
    lastSL := stopLoss
    lastTP1 := target1
    lastTP2 := target2
    lastTP3 := target3
    lastRR1 := rr1
    lastRR2 := rr2
    lastRR3 := rr3

    signalLabel := label.new(
         x=bar_index,
         y=high,
         text="🔻 MAJOR BREAKDOWN\nVolume Confirmed\nSL: " + slMode,
         style=label.style_label_down,
         color=color.new(bearColor, 0),
         textcolor=color.white,
         size=f_labelSize(labelSizeInput)
    )

    breakLine := line.new(
         x1=bar_index,
         y1=lastMajorLow,
         x2=bar_index + levelLineBars,
         y2=lastMajorLow,
         color=bearColor,
         width=3,
         style=f_lineStyle(lineStyleInput)
    )

    if showRiskReward
        riskBox := box.new(
             left=bar_index,
             top=stopLoss,
             right=bar_index + boxBars,
             bottom=entryPrice,
             bgcolor=color.new(bearColor, riskTransp),
             border_color=color.new(bearColor, 10),
             border_width=boxBorderWidth,
             border_style=f_lineStyle(lineStyleInput),
             text=showBoxText ? "RISK\nSL Zone" : "",
             text_color=color.new(color.white, 15),
             text_size=size.tiny,
             text_halign=text.align_center,
             text_valign=text.align_center
        )

        if rewardBoxMode == "Single Reward Box"
            rewardBox1 := box.new(
                 left=bar_index,
                 top=entryPrice,
                 right=bar_index + boxBars,
                 bottom=target3,
                 bgcolor=color.new(bullColor, rewardTransp),
                 border_color=color.new(bullColor, 10),
                 border_width=boxBorderWidth,
                 border_style=f_lineStyle(lineStyleInput),
                 text=showBoxText ? "REWARD\nFib Zone" : "",
                 text_color=color.new(color.white, 15),
                 text_size=size.tiny,
                 text_halign=text.align_center,
                 text_valign=text.align_center
            )
        else
            rewardBox1 := box.new(
                 left=bar_index,
                 top=entryPrice,
                 right=bar_index + boxBars,
                 bottom=target1,
                 bgcolor=color.new(bullColor, math.min(rewardTransp + 4, 95)),
                 border_color=color.new(bullColor, 25),
                 border_width=1,
                 border_style=f_lineStyle(lineStyleInput),
                 text=showBoxText ? "TP1 Zone" : "",
                 text_color=color.new(color.white, 20),
                 text_size=size.tiny,
                 text_halign=text.align_center,
                 text_valign=text.align_center
            )

            rewardBox2 := box.new(
                 left=bar_index,
                 top=target1,
                 right=bar_index + boxBars,
                 bottom=target2,
                 bgcolor=color.new(bullColor, rewardTransp),
                 border_color=color.new(bullColor, 15),
                 border_width=1,
                 border_style=f_lineStyle(lineStyleInput),
                 text=showBoxText ? "TP2 Zone" : "",
                 text_color=color.new(color.white, 15),
                 text_size=size.tiny,
                 text_halign=text.align_center,
                 text_valign=text.align_center
            )

            rewardBox3 := box.new(
                 left=bar_index,
                 top=target2,
                 right=bar_index + boxBars,
                 bottom=target3,
                 bgcolor=color.new(bullColor, math.max(rewardTransp - 4, 70)),
                 border_color=color.new(bullColor, 5),
                 border_width=boxBorderWidth,
                 border_style=f_lineStyle(lineStyleInput),
                 text=showBoxText ? "TP3 Zone" : "",
                 text_color=color.new(color.white, 10),
                 text_size=size.tiny,
                 text_halign=text.align_center,
                 text_valign=text.align_center
            )

        entryLine := line.new(bar_index, entryPrice, bar_index + boxBars, entryPrice, color=neutralColor, width=2)
        slLine    := line.new(bar_index, stopLoss, bar_index + boxBars, stopLoss, color=bearColor, width=2)
        tp1Line   := line.new(bar_index, target1, bar_index + boxBars, target1, color=bullColor, width=1, style=line.style_dashed)
        tp2Line   := line.new(bar_index, target2, bar_index + boxBars, target2, color=bullColor, width=1, style=line.style_dashed)
        tp3Line   := line.new(bar_index, target3, bar_index + boxBars, target3, color=bullColor, width=2)

        entryLabel := label.new(bar_index + boxBars, entryPrice, "Entry: " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=neutralColor, textcolor=color.black)
        slLabel    := label.new(bar_index + boxBars, stopLoss, "SL [" + slMode + "]: " + str.tostring(stopLoss, format.mintick), style=label.style_label_left, color=bearColor, textcolor=color.white)
        tp1Label   := label.new(bar_index + boxBars, target1, "TP1: " + str.tostring(target1, format.mintick) + " | RR " + str.tostring(rr1, "#.##"), style=label.style_label_left, color=bullColor, textcolor=color.white)
        tp2Label   := label.new(bar_index + boxBars, target2, "TP2: " + str.tostring(target2, format.mintick) + " | RR " + str.tostring(rr2, "#.##"), style=label.style_label_left, color=bullColor, textcolor=color.white)
        tp3Label   := label.new(bar_index + boxBars, target3, "TP3: " + str.tostring(target3, format.mintick) + " | RR " + str.tostring(rr3, "#.##"), style=label.style_label_left, color=bullColor, textcolor=color.white)

// =====================================================
// DASHBOARD TABLE
// =====================================================
var table dash = table.new(f_tablePos(dashboardPosition), 2, 8, border_width=1, border_color=color.new(neutralColor, 70))

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Swing Breakout PRO", text_color=color.white, bgcolor=color.new(neutralColor, 70))
    table.cell(dash, 1, 0, visualTheme, text_color=color.white, bgcolor=color.new(neutralColor, 70))

    table.cell(dash, 0, 1, "Last Signal", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 1, lastSignalText, text_color=color.white, bgcolor=lastSignalText == "Bullish Breakout" ? color.new(bullColor, 30) : lastSignalText == "Bearish Breakdown" ? color.new(bearColor, 30) : color.new(color.gray, 50))

    table.cell(dash, 0, 2, "SL Mode", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 2, lastSLMode, text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 3, "Entry", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 3, na(lastEntry) ? "N/A" : str.tostring(lastEntry, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 4, "Stop Loss", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 4, na(lastSL) ? "N/A" : str.tostring(lastSL, format.mintick), text_color=color.white, bgcolor=color.new(bearColor, 65))

    table.cell(dash, 0, 5, "TP1 / RR", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 5, na(lastTP1) ? "N/A" : str.tostring(lastTP1, format.mintick) + " / " + str.tostring(lastRR1, "#.##"), text_color=color.white, bgcolor=color.new(bullColor, 70))

    table.cell(dash, 0, 6, "TP2 / RR", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 6, na(lastTP2) ? "N/A" : str.tostring(lastTP2, format.mintick) + " / " + str.tostring(lastRR2, "#.##"), text_color=color.white, bgcolor=color.new(bullColor, 65))

    table.cell(dash, 0, 7, "TP3 / RR", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 7, na(lastTP3) ? "N/A" : str.tostring(lastTP3, format.mintick) + " / " + str.tostring(lastRR3, "#.##"), text_color=color.white, bgcolor=color.new(bullColor, 55))

// =====================================================
// ALERT CONDITIONS
// =====================================================
alertcondition(bullSignal, title="Major Swing Breakout", message="Major Swing Breakout with Volume Confluence on {{ticker}}")
alertcondition(bearSignal, title="Major Swing Breakdown", message="Major Swing Breakdown with Volume Confluence on {{ticker}}")
````
