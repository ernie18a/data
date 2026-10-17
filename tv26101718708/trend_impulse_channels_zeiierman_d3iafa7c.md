# Trend Impulse Channels (Zeiierman)

- url: https://www.tradingview.com/script/d3IaFa7c-Trend-Impulse-Channels-Zeiierman/
- type: indicator
- pine_id: PUB;a301e8735141418c86feb872d423f8ed
- version: 1.0

## Description

█ [b]Overview[/b]
[b]Trend Impulse Channels (Zeiierman)[/b] is a precision-engineered trend-following system that visualizes discrete trend progression using volatility-scaled step logic. It replaces traditional slope-based tracking with clearly defined “trend steps,” capturing directional momentum only when price action decisively confirms a shift through an ATR-based trigger.

This tool is ideal for traders who prefer structured, stair-step progression over fluid curves, and value the clarity of momentum-based bands that reveal breakout conviction, pullback retests, and consolidation zones. The channel width adapts automatically to market volatility, while the step logic filters out noise and false flips.
[image]https://www.tradingview.com/x/y8Vzxkqm/ [/image]

⚪ [b]The Structural Assumption[/b]
[b]This indicator is built on a core market structure observation:[/b]
[quote]After each strong trend impulse, the market typically enters a “cooling-off” phase as profit-taking occurs and counter-trend participants enter. This often results in a shallow pullback or stall, creating a slight negative slope in an uptrend (or a positive slope in a downtrend).[/quote]
These “cooling-off” phases don’t reverse the trend — they signal temporary pressure before the next leg continues. By tracking trend steps discretely and filtering for this behavior, Trend Impulse Channels helps traders align with the rhythm of impulse → pause → impulse.
[image]https://www.tradingview.com/x/YPlP1DQP/[/image]

█ [b]How It Works[/b]
[quote]⚪ [b]Step-Based Trend Engine[/b]
At the heart of this tool is a dynamic step engine that progresses only when price crosses a predefined ATR-scaled trigger level:
[list]
[*][b]Trigger Threshold (× ATR)[/b] – Defines how far price must break beyond the current trend state to register a new trend step.
[*][b]Step Size (Volatility-Guided)[/b] – Each trend continuation moves the trend line in discrete units, scaling with ATR and trend persistence.
[*][b]Trend Direction State[/b] – Maintains a +1/-1 internal bias to support directional filters and step tracking.
[/list]
⚪ [b]Volatility-Adaptive Channel[/b]
Each step is wrapped inside a dynamic envelope scaled to current volatility:
[list]
[*][b]Upper and Lower Bands[/b] – Derived from ATR and band multipliers to expand/contract as volatility changes.
[/list]
⚪ [b]Retest Signal System[/b]
Optional signal markers show when price re-tests the upper or lower band:
[list]
[*][b]Upper Retest[/b] → Pullback into resistance during a bearish trend.
[*][b]Lower Retest[/b] → Pullback into support during a bullish trend.
[/list]
⚪ [b]Trend Step Signals[/b]
Circular markers can be shown to mark each time the trend steps forward, making it easy to identify structurally significant moments of continuation within a larger trend.[/quote]
█ [b]How to Use[/b]

⚪ [b]Trend Alignment[/b]
Use the Trend Line and Step Markers to visually confirm the direction of momentum. If multiple trend steps occur in sequence without reversal, this typically signals strong conviction and trend persistence.
[image]https://www.tradingview.com/x/90ORDtOZ/[/image]

⚪ [b]Retest-Based Entries[/b]
Wait for pullbacks into the channel and monitor for triangle retest signals. When used in confluence with trend direction, these offer high-quality continuation setups.
[image]https://www.tradingview.com/x/YDY597Qw/[/image]

⚪ [b]Breakouts[/b]
Look for breakouts beyond the upper or lower band after a longer period of pause. For higher likelihood of success, look for breakouts in the direction of the trend.
[image]https://www.tradingview.com/x/Bo4WNSUt/[/image]

█ [b]Settings[/b]
[list]
[*][b]Trigger Threshold (× ATR)[/b] - Defines how far price must move to register a new trend step. Controls sensitivity to trend flips.
[*][b]Max Step Size (× ATR)[/b] - Caps how far each trend step can extend. Prevents runaway step expansion in high volatility.
[*][b]Band Multiplier (× ATR)[/b] - Expands the upper and lower channels. Controls how much breathing room the bands allow.
[*][b]Trend Hold (bars)[/b] - Minimum number of bars the trend must remain active before allowing a flip. Helps reduce noise.
[*][b]Filter by Trend[/b] - Restrict retest signals to those aligned with the current trend direction.
[/list]

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/

// © Zeiierman {
//@version=6
indicator("Trend Impulse Channels (Zeiierman)", overlay=true)
//~~}

// ~~ Tooltips {
var string t1 = "Trigger Threshold: Controls when a new trend step is triggered. It's a multiplier of the ATR — higher values require a stronger price move to flip the trend direction."
var string t2 = "Max Step Size: Defines the maximum allowed size for each trend step, based on ATR. Use a negative number to scale down large step jumps in volatile conditions."
var string t3 = "Band Multiplier: Expands or contracts the volatility bands around the trend line. A higher value creates wider channels to account for more price fluctuation."
var string t4 = "Trend Hold: After a trend flip, the trend will hold for this many bars before another flip can occur. Useful for avoiding rapid flip-flopping in choppy markets."
var string t5 = "Retest Signals: Enables triangle markers on the chart when price re-tests the upper or lower channel boundary. Helpful for spotting potential continuation or bounce zones."
var string t6 = "Trend Filter: Only show retest signals if they align with the current trend direction (e.g., only show upper retests in a downtrend)."
var string t7 = "Trend Step Signals: Shows circular markers each time a new step is taken in the trend direction. These mark every structural trend advancement."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
flipMult   = input.float(2.86,step=0.01, title="Trigger Threshold", group="", inline="", tooltip=t1)
maxStepAtr = input.float(-0.034,step=0.001, title="Max Step Size", group="", inline="", tooltip=t2)
bandMult   = input.float(2.02, step=0.01,title="Band Multiplier", group="", inline="", tooltip=t3)
holdBars   = input.int(0, minval=0, title="Trend Hold", group="", inline="", tooltip=t4)

colorUp    = input.color(color.lime, title="", group="", inline="c", tooltip="")
colorDown  = input.color(color.red, title="", group="", inline="c", tooltip="")
showFill   = input.bool(true, title="Channel Fill", group="", inline="c", tooltip="")

ChannelRetestSignal = input.bool(true, title="Retest Signals", group="Retest Signals", inline="c22", tooltip=t5)
TrendFilter  = input.bool(true, title="Filter by Trend", group="Retest Signals", inline="c222", tooltip=t6)
colorUp2     = input.color(color.lime, title="", group="Retest Signals", inline="c2", tooltip="")
colorDown2   = input.color(color.red, title="", group="Retest Signals", inline="c2", tooltip="")

TrendStepSignal = input.bool(false, title="Trend Step Signals", group="Trend Step Signals", inline="c33", tooltip=t7)
colorUp3    = input.color(color.lime, title="", group="Trend Step Signals", inline="c3", tooltip="")
colorDown3  = input.color(color.red, title="", group="Trend Step Signals", inline="c3", tooltip="")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Atr Scaling {
atr = ta.atr(200)
stepBase = atr * 2.52
maxStep  = atr * maxStepAtr
trigger  = atr * flipMult
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Var {
var float trend     = na
var int dir         = 0
var int barsInTrend = 0
var float hold      = na
var int extension   = 0
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Logic {
startLong  = close > nz(trend) + trigger
startShort = close < nz(trend) - trigger
flip       = (startLong or startShort) and barsInTrend >= 0
stepSize   = math.min(stepBase + 0.0093 * barsInTrend * atr, maxStep)

if na(trend)
    trend := close
    dir := 0
    barsInTrend := 0
    hold := trigger
    extension := 0
else
    if flip and extension <= 0
        trend := close
        dir := startLong ? 1 : -1
        barsInTrend := 1
        hold := trigger
        extension := holdBars
    else
        trend := trend + (dir == 1 ? stepSize : dir == -1 ? -stepSize : 0)
        barsInTrend += 1
        extension := math.max(extension - 1, 0)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Channel {
trendDirection = dir == 1 ? 1 : dir == -1 ? -1 : 0
upper = trend + atr * bandMult
lower = trend - atr * bandMult
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Plots {
trendColor = dir == 1 ? colorUp : dir == -1 ? colorDown : color.gray
trendStep  = (dir != 0) and (trend != trend[1]) and ((trend > trend[1] and dir == 1) or (trend < trend[1] and dir == -1))

plotMid    = plot(trend, "Trend Line", color=trendColor, linewidth=2)
plotUpper  = plot(showFill ? upper : na, "Upper Band", color=na)
plotLower  = plot(showFill ? lower : na, "Lower Band", color=na)
fill(plotUpper, plotMid, upper, trend,showFill ? color.new(trendColor, 60) : na,na)
fill(plotLower, plotMid, lower, trend,showFill ? color.new(trendColor, 60) : na,na)

Crossunder = ta.crossunder(low,lower)
Crossover  = ta.crossover(high,upper)

if TrendFilter 
    Crossunder := ta.crossunder(low,lower) and trendDirection == 1
    Crossover  := ta.crossover(high,upper) and trendDirection == -1

plotshape(Crossunder and ChannelRetestSignal?low:na, title="Lower Retest", color=colorUp2, style=shape.triangleup, size=size.tiny, location=location.belowbar)
plotshape(Crossover and ChannelRetestSignal?high:na, title="Upper Retest", color=colorDown2, style=shape.triangledown, size=size.tiny, location=location.abovebar)

plotshape(trendStep and dir == 1 and TrendStepSignal?high:na, title="Bullish Step", location=location.absolute, style=shape.circle, color=colorUp3, size=size.tiny)
plotshape(trendStep and dir == -1 and TrendStepSignal?low:na, title="Bearish Step", location=location.absolute, style=shape.circle, color=colorDown3, size=size.tiny)
plotshape(trendStep and dir == 1 and TrendStepSignal?high:na, title="Bullish Step", location=location.absolute, style=shape.circle, color=color.new(colorUp3,50), size=size.small)
plotshape(trendStep and dir == -1 and TrendStepSignal?low:na, title="Bearish Step", location=location.absolute, style=shape.circle, color=color.new(colorDown3,50), size=size.small)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
