# Weinstein Stage Cycle Tracker [MarkitTick]

- url: https://www.tradingview.com/script/FyDa5AFy-Weinstein-Stage-Cycle-Tracker-MarkitTick/
- type: indicator
- pine_id: PUB;9325e18f84694b92a167e8a8fb7227e2
- version: 1.0

## Description

💡 Weinstein Stage Cycle Tracker reads a chart the way Stan Weinstein described the life of a stock in his 1988 book on bull and bear markets. Every market goes through four stages over a full cycle: a base-building phase, an advancing mark-up phase, a topping phase and a declining phase. The tracker puts each bar into one of these four stages using a single stage moving average, how that average is sloping, where price sits against it, and whether price has broken out of its recent trading range. The result shows as a colored moving average, a stage background, colored candles and a compact dashboard, so the trader can see which part of the cycle the market is in and how long it has been there.

The aim is to make stage analysis readable and consistent. Instead of judging a flat or rising average by eye, which changes from one person to the next and from one day to the next, the tracker uses clear, adjustable definitions. It is an analytical tool: it describes the market's current phase and sends an event alert when the phase changes. It does not give entries, stops or targets.

[b]✨ Originality and Utility[/b]
Stage analysis is usually applied by looking at a chart and a moving average and deciding which stage fits. This tracker turns that reading into a state machine: a set of four stages with written rules for moving from one stage to another. It does not recolor each bar on its own. Once a stage is established, it holds until one of the defined transition conditions is met. This is what separates it from a simple "price above or below the average" coloring tool, which flips every time price crosses the line and cannot tell a base from a top.

[list]
[*]Memory of the cycle: a stage is judged partly by what came before it. A flattening average after an advance is read as a top (Stage 3). A flattening average after a decline is read as a base (Stage 1). The same flat average means different things depending on the stage it follows, which is the core idea of the cycle.
[*]Range breakouts decide the big moves: moving into the advancing or declining stage needs price to leave its recent trading range, not just cross the average.
[*]A dead band around zero slope: small slope readings count as flat, which stops the stage from flickering whenever the average wobbles.
[*]Optional confirmation filters for the alerts: higher-timeframe agreement, trend strength and breakout volume can be required before a Stage 2 or Stage 4 alert fires (breakout volume applies to Stage 2 only).
[*]A dashboard that shows the current stage, the previous stage, when the current stage started and how many bars it has lasted.
[/list]

[b]● Why these components work together[/b]
Every component answers one question that stage analysis asks:
[list=1]
[*]The stage moving average and its slope ask whether the underlying trend is rising, falling or flat.
[*]The position of price against the average asks which side of the trend price is on.
[*]The trading range asks whether price has actually escaped the sideways base or top it was in.
[*]The optional volume, trend-strength and higher-timeframe checks ask whether a new advancing or declining stage has support beyond price alone.
[/list]
None of these is added for decoration. Each maps directly onto one part of how the stages are described: during a base, price wanders back and forth across a flattening average; during the mark-up, price is above a rising average and makes new highs, with volume expanding on the breakout; during the top, price stalls and crosses back and forth through the average; during the decline, price falls below a declining average.

[b]🔬 Methodology and Concepts[/b]

[b]• Source and optional smoothing[/b]
The stage is read from the selected source, the close by default. If Adaptive Smoothing is set to anything other than None, the source is first smoothed with the chosen average (SMA, EMA, WMA, HMA or RMA) over the smoothing length. Everything that follows, including the stage moving average and the breakout test, uses this smoothed series. With None, the raw source is used unchanged.

[b]• The stage moving average[/b]
The stage moving average is a simple moving average of the source over the MA Length, 30 bars by default. A simple moving average gives equal weight to every value in its window and moves forward as each new bar replaces the oldest one.

[b]• Slope as a percentage[/b]
The slope is the percentage change of the stage average compared with its own value a set number of bars earlier (Slope Lookback, 4 by default). A value above the Flat Slope % threshold (0.5% by default) counts as rising. A value below the negative of that threshold counts as falling. Anything in between counts as flat. Measuring the slope as a percentage keeps the threshold meaningful on any price level, from low-priced symbols to high-priced indices.

[b]• The trading range[/b]
The range is the highest high and the lowest low of the bars before the current one, over the Range Lookback (30 bars by default). The current bar is left out so a breakout is always measured against a range that has already formed.
[list]
[*]Upside breakout: the source closes above the range high, it is above the stage average, and the average is not falling.
[*]Downside breakdown: the source closes below the range low, it is below the stage average, and the average is not rising.
[/list]

[b]• How the first stage is assigned[/b]
At the start of the chart no stage is known. The first stage is assigned only when the picture is clear: a rising average with price above it starts Stage 2, and a falling average with price at or below it starts Stage 4. Until one of these happens, no stage is shown.

[b]• Transition rules[/b]
[list]
[*]From Stage 1 (basing): a downside breakdown moves to Stage 4, an upside breakout moves to Stage 2, otherwise the base continues.
[*]From Stage 2 (advancing): a downside breakdown moves to Stage 4. If the average stops rising after having risen at some point during this advance, the stage moves to Stage 3. If the average stops rising while price is not above it, and the average never rose during this stage, the advance is treated as a failed breakout and returns to Stage 1. Otherwise the advance continues.
[*]From Stage 3 (topping): a downside breakdown moves to Stage 4, an upside breakout returns to Stage 2, otherwise the top continues.
[*]From Stage 4 (declining): an upside breakout moves to Stage 2. If the average stops falling after having fallen at some point during this decline, the stage moves to Stage 1. If the average stops falling while price is not below it, and the average never fell during this stage, the stage moves to Stage 3. Otherwise the decline continues.
[/list]
The "had risen during this stage" and "had fallen during this stage" checks are what give the tracker its memory of the cycle. A flat average is only read as a top if it follows a real advance, and only read as a base if it follows a real decline.

[b]• Alert filters[/b]
All filters are off by default. HTF Confirmation, Trend Strength and Breakout Volume affect the alerts only; the stage itself, its colors and the dashboard's stage row are never filtered by them. Adaptive Smoothing is different: it changes the series the stage is read from. None of the filters is part of Weinstein's method.
[list]
[*]HTF Confirmation: a simpler rule than the chart's stage logic is applied on a higher timeframe and read from the last completed higher-timeframe bar. The book has no higher-timeframe confirmation rule; the closest idea in it is staying in harmony with the long-term trend. A rising average with price above it counts as bullish, a falling average with price at or below it counts as bearish, and anything else is neutral. A Stage 2 alert then needs a bullish higher timeframe, and a Stage 4 alert needs a bearish one.
[*]Trend Strength Filter: uses ADX, from J. Welles Wilder's Directional Movement system, which measures how strong a trend is without saying which direction it points. The ADX of the previous bar must be at or above the threshold for a Stage 2 or Stage 4 alert.
[*]Breakout Volume: the breakout bar's volume must be at least the chosen multiple of the average volume of the bars just before it. Only bars that carry volume enter that average. On a symbol that reports no volume at all, the check is skipped and the dashboard says so.
[/list]

[b]🎨 Visual Guide[/b]
[list]
[*]Stage MA: a line two pixels wide that takes the color of the current stage. Gray is Stage 1 (basing), teal is Stage 2 (advancing), orange is Stage 3 (topping) and red is Stage 4 (declining). Before any stage is established, the line is drawn in the Stage 1 gray.
[*]Stage Background: a light tint behind the price bars in the color of the current stage. Its strength is set by Background Transparency, 75 by default. No tint is drawn before the first stage is established.
[*]Candle Coloring: each candle, including its body, wick and border, is painted in its stage color, so the whole price history reads as colored blocks of basing, advancing, topping and declining. Before the first stage is established, candles keep their normal chart colors.
[/list]

[b]• Dashboard[/b]
The header shows the short name WSCT, the symbol and the chart timeframe in trader notation such as 4H, 1D or 1W. The rows are:
[list]
[*]Stage: the current stage and its name, shown in teal for Stage 2, red for Stage 4, and in the text color for Stages 1 and 3.
[*]Previous: the stage before the current one.
[*]Since: the date the current stage began, in the exchange's time zone.
[*]Bars in Stage: how many bars the current stage has lasted.
[*]Stage MA: the current value of the stage average.
[*]MA Slope: the slope percentage, teal when rising, red when falling.
[*]Distance to MA: how far the source is above or below the average, as a percentage, teal above and red below.
[*]Range High and Range Low: the edges of the trading range used for breakouts.
[*]Volume: the current bar's volume, shortened with K, M or B.
[*]Vol vs Avg: current volume as a multiple of its average over the Volume Avg Length. Only bars that carry volume enter that average; with none, the row shows a dash.
[/list]
Since and Bars in Stage show a dash during the very first stage on the chart, because the true start of that stage lies before the data the tracker could read. The Stage row's tooltip explains the warm-up before the first stage appears. Where the symbol's volume is tick volume, a count of trades rather than units traded, the tooltips of the Volume, Vol vs Avg and Breakout Volume rows say so.

Rows that appear only when their filter is on:
[list]
[*]HTF Bias: Bullish, Bearish or Neutral, with the higher timeframe, or "Skipped · below chart TF" if the chosen timeframe is lower than the chart's.
[*]Trend Strength: the previous bar's ADX as a ten-block bar with its value, colored by its share of 100: teal from 66, amber from 33 to 65, red below 33.
[*]Smoothing: the smoothing method and its length.
[*]Breakout Volume: Pass or Fail with the current ratio, or "Skipped · no volume" on a warning-colored row.
[/list]

[b]📖 How to Use[/b]
[list=1]
[*]Start with the stage color. Teal candles and background mean the tracker reads an advancing phase, red a declining phase, gray a base and orange a top.
[*]Check the Since and Bars in Stage rows. A young Stage 2 right after a long base is a different situation from a Stage 2 that has been running for a very long time.
[*]Watch the MA Slope row during Stage 2 and Stage 4. A slope moving toward the flat zone is often the first sign that the tracker may soon move to Stage 3 or Stage 1.
[*]Use Range High and Range Low to see how close price is to a breakout or a breakdown that would change the stage.
[*]Treat Stage 1 and Stage 3 as sideways phases. In stage analysis, buying in a base is described as too early: money can sit idle for a long time, and impatient buyers often sell just before the real move begins. A base can last many months or even years.
[*]Turn on the filters if you want the alerts to fire only when a new Stage 2 or Stage 4 has extra support: a matching higher timeframe, a trend-strength reading at or above the threshold, or, for Stage 2, expanding breakout volume.
[/list]

[b]• Timeframes[/b]
The settings panel's own guidance for the MA Length is 30 weeks for investors, 10 weeks for traders, and 30 days on a daily chart for traders. The default of 30 therefore fits a weekly chart for the investor view and a daily chart for the trader view. The default higher timeframe for confirmation is monthly.

[b]• Alerts[/b]
Four events fire when the stage changes on a closed bar: Stage 1 Basing, Stage 2 Advancing, Stage 3 Topping and Stage 4 Declining. They are available both as standard alert conditions and through a single alert that sends a JSON message. The JSON message carries the action word, the symbol, the timeframe, a direction (bullish for Stage 2, bearish for Stage 4, neutral for Stages 1 and 3), the stage name, the stage and previous stage numbers, the price, the stage average, the slope percentage and the time. The action words default to stage1, stage2, stage3 and stage4 and can be changed in the Alerts group. These alerts report what happened. They are events, not orders.

[b]• Repainting and live-bar behavior[/b]
Stage changes are only alerted on a closed bar. On the bar that is still forming, the stage, the candle and background colors and the dashboard are calculated from the live price and can change until that bar closes, so a stage shown on the live bar is provisional. The higher-timeframe confirmation reads the last completed higher-timeframe bar and never uses a higher-timeframe bar that has not closed yet. Because the stage is built step by step from the first bar the chart loads, the stages at the far left of the chart depend on where the loaded history begins, and a stage is only assigned once the first clear rising or falling condition is met.

[b]⚙️ Inputs and Settings[/b]

[b]• Core Settings[/b]
[list]
[*]Source: the price series the stage is read from. Close by default.
[*]MA Length: the length of the stage average, 30 by default. A longer length gives slower, longer-lasting stages. A shorter one reacts faster but changes stage more often.
[*]Slope Lookback: how many bars back the average is compared with to measure its slope, 4 by default.
[*]Flat Slope %: the size of the flat zone around zero slope, 0.5% by default. A wider zone keeps more bars classed as flat, which suits slow markets. A narrower zone makes the tracker react to smaller changes in direction.
[*]Range Lookback: how many earlier bars form the trading range used for breakouts, 30 by default.
[*]Volume Avg Length: the average used by the Vol vs Avg dashboard row, 20 by default. Only bars that carry volume are averaged.
[/list]

[b]• Filters[/b]
[list]
[*]HTF Confirmation and HTF Timeframe: off by default, with monthly as the default timeframe. The timeframe must not be lower than the chart's timeframe.
[*]Trend Strength Filter, ADX Threshold and ADX Length: off by default, with a threshold of 20 and a length of 14.
[*]Adaptive Smoothing and Smoothing Length: None by default, with a length of 5.
[*]Breakout Volume, Volume Multiple and Volume Lookback: off by default, with a multiple of 2.0 and a lookback of 4 bars. The settings panel's guidance notes that Weinstein asks for at least twice the average volume, measured over 4 weeks on a weekly chart.
[/list]

[b]• Visuals, Dashboard, Alerts and Colors[/b]
[list]
[*]Show Stage MA, Candle Coloring, Stage Background and Background Transparency control the chart drawings.
[*]Show Dashboard and Position control the panel, top right by default.
[*]Stage 1 to Stage 4 Action set the action word sent in each alert's JSON message.
[*]Every color is adjustable: the four stage colors, the three trend-strength bar colors, and the dashboard header, background, text and warning-row colors.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]• Stage analysis as a market cycle[/b]
Stan Weinstein's stage analysis describes the full life of a stock from a bull phase to a bear phase in four observed stages. The base forms while interest is low and volume is light. The mark-up begins with a breakout, a rising average and expanding volume. The top forms when price stops responding to good news and crosses back and forth through its averages. The decline begins when price falls below its prior range and below averages that then turn down. The tracker keeps this sequence and puts it into rules. It uses one stage average, as the book does, and measures the trading range over a fixed lookback where the book reads it by eye.

[b]• The moving average as a smoothing filter[/b]
A simple moving average is the plain average of the last n values, with each value weighted equally. It smooths out bar-to-bar noise to show the direction of the trend, at the cost of lag: the longer the length, the longer a major price change takes to show in the average. That trade-off between smoothness and responsiveness is the reason the MA Length and the optional smoothing matter so much to how early or late a stage change appears.

[b]• Slope, rate of change and the flat zone[/b]
Comparing the average with its value several bars earlier measures its rate of change over that span. It is the discrete version of a derivative. Readings close to zero are noisy, so the tracker adds a dead band: a symmetric flat zone around zero inside which the slope counts as neither rising nor falling. In signal processing this kind of band is called a dead zone. On its own it does not stop flicker at its edges; what keeps a flat base from being chopped into false advances and declines is the stage memory and the range breakout required to change stage.

[b]• A finite state machine with memory[/b]
The four stages and the rules between them form a finite state machine: the next state depends on both the current inputs and the current state. This is why the same combination of a flat average and price near it can mean a base after a decline and a top after an advance. A memoryless classifier, one that looks only at the current bar, cannot make that distinction.

[b]• Breakout of a trading range[/b]
Measuring the highest high and lowest low of the preceding bars defines the boundaries of recent price action. A close beyond those boundaries is the objective counterpart of the breakout from a base that marks the start of Stage 2, and of the breakdown below a top that marks the start of Stage 4.

[b]• Trend strength with ADX[/b]
The Average Directional Index was introduced by J. Welles Wilder, Jr. in 1978. It is built from positive and negative directional movement, normalized by the true range and smoothed with Wilder's method. It measures the strength of a trend but not its direction. Per TradingView, readings above 25 indicate a strong trend and readings below 20 a weak or absent one. As a filter, it asks that a new advancing or declining stage appear in a market that is actually trending.

[b]• The smoothing options[/b]
[list]
[*]SMA: equal weight on every value in the window.
[*]EMA: a weighting that fades gradually with age, so the newest values count most and it reacts faster than an SMA of the same length.
[*]WMA: weights that step down in arithmetic progression, highest on the newest value.
[*]HMA: a combination of weighted moving averages designed by Alan Hull to reduce lag while staying smooth.
[*]RMA: Wilder's smoothing, an exponential weighting with a factor of one divided by the length.
[/list]
Each option changes how much noise reaches the stage average and how much lag it adds. None is a neutral choice.

[b]• Volume as confirmation[/b]
In the stage framework, volume jumps on the Stage 2 breakout, rises on rallies and falls on dips. Comparing the breakout bar's volume with the average of the bars just before it is a simple relative measure of that expansion. Leaving out bars with no volume keeps the average honest on feeds where many bars report nothing.

[b]• What is not from the book[/b]
Weinstein judged a flat moving average and a trading range by eye, so this indicator uses numbers you set instead: Slope Lookback, Flat Slope % and Range Lookback. A breakout or breakdown is judged on the bar's close, not on an intrabar touch. A breakout that fails before the MA turns up returns to Stage 1, which follows the book's note that a false breakout falls back into the trading range; a failed breakdown returns to Stage 3, which is this indicator's own mirror of that rule. At the start of the chart, a stage is assigned only when the MA is clearly rising with price above it (Stage 2) or clearly falling with price at or below it (Stage 4).

[b]• Limitations[/b]
[list]
[*]Every moving average lags, so stage changes are confirmed after the turn has begun, not at its exact point.
[*]Sideways phases can last a long time and can produce false breakouts in both directions.
[*]The thresholds that define flat slope and the trading range are choices, not properties of the market. Different settings will classify the same chart differently.
[*]The stage describes the current phase. It does not predict how long that phase will last or how far it will run.
[/list]

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Weinstein Stage Cycle Tracker [MarkitTick]", overlay = true, behind_chart = false)

// ── INPUTS ──────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core Settings"
i_src        = input.source(close, "Source", group = GRP_CORE, tooltip = "Price series the stage is read from · Weinstein uses the close")
i_maLen      = input.int(30, "MA Length", group = GRP_CORE, minval = 2, tooltip = "Length of the stage moving average · Weinstein uses 30 weeks for investors, 10 weeks for traders, and 30 days on a daily chart for traders")
i_slopeLen   = input.int(4, "Slope Lookback", group = GRP_CORE, minval = 1, tooltip = "Bars back used to measure the moving average slope · not from Weinstein's book, which judges the slope by eye")
i_flatPct    = input.float(0.5, "Flat Slope %", group = GRP_CORE, minval = 0, step = 0.1, tooltip = "Slope inside ± this percentage counts as flat · not from Weinstein's book, which judges a flat MA by eye")
i_rangeLen   = input.int(30, "Range Lookback", group = GRP_CORE, minval = 2, tooltip = "Bars before the current one whose highest high and lowest low mark the trading range · a close above it with the MA no longer declining starts Stage 2, a close below it with the MA no longer rising starts Stage 4 · not from Weinstein's book, which reads the range by eye")
i_volLen     = input.int(20, "Volume Avg Length", group = GRP_CORE, minval = 1, tooltip = "Bars in the average that current volume is compared with · only bars carrying volume are averaged")

var string GRP_FILT = "🕯️ Filters"
i_useHtf     = input.bool(false, "HTF Confirmation", group = GRP_FILT, tooltip = "Stage 2 alert needs a bullish higher timeframe · Stage 4 alert needs a bearish one")
i_htfTf      = input.timeframe("1M", "HTF Timeframe", group = GRP_FILT, tooltip = "Not lower than the chart timeframe · a lower one is skipped and shown as skipped")
i_useAdx     = input.bool(false, "Trend Strength Filter", group = GRP_FILT, tooltip = "Stage 2 and Stage 4 alerts need ADX of the previous bar at or above the threshold")
i_adxThresh  = input.float(20.0, "ADX Threshold", group = GRP_FILT, minval = 0, maxval = 100, step = 0.5, tooltip = "Minimum ADX for a Stage 2 or Stage 4 alert")
i_adxLen     = input.int(14, "ADX Length", group = GRP_FILT, minval = 1, tooltip = "Length of the ADX used by the trend strength filter")
i_smooth     = input.string("None", "Adaptive Smoothing", options = ["None", "SMA", "EMA", "WMA", "HMA", "RMA"], group = GRP_FILT, tooltip = "Smooths the source before the stage is read · None keeps it raw")
i_smoothLen  = input.int(5, "Smoothing Length", group = GRP_FILT, minval = 1, tooltip = "Length of the adaptive smoothing")
i_useVol     = input.bool(false, "Breakout Volume", group = GRP_FILT, tooltip = "Stage 2 alert needs the breakout bar's volume at or above the multiple of the average of the bars before it · skipped on a symbol with no volume")
i_volMult    = input.float(2.0, "Volume Multiple", group = GRP_FILT, minval = 1, step = 0.1, tooltip = "Minimum breakout volume as a multiple of the average · Weinstein asks for at least 2x")
i_volLb      = input.int(4, "Volume Lookback", group = GRP_FILT, minval = 1, tooltip = "Bars before the breakout bar in the volume average · only bars carrying volume are averaged · Weinstein uses 4 weeks on a weekly chart")

var string GRP_VIS = "🎨 Visuals"
i_showMa     = input.bool(true, "Show Stage MA", group = GRP_VIS)
i_showCandles = input.bool(true, "Candle Coloring", group = GRP_VIS, tooltip = "Colors each candle with the color of its stage")
i_showBg     = input.bool(true, "Stage Background", group = GRP_VIS)
i_bgTransp   = input.int(75, "Background Transparency", group = GRP_VIS, minval = 0, maxval = 100)

var string GRP_DASH = "📊 Dashboard"
i_showDash   = input.bool(true, "Show Dashboard", group = GRP_DASH)
i_dashPos    = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)

var string GRP_WH = "🔔 Alerts"
i_actS1      = input.string("stage1", "Stage 1 Action", group = GRP_WH)
i_actS2      = input.string("stage2", "Stage 2 Action", group = GRP_WH)
i_actS3      = input.string("stage3", "Stage 3 Action", group = GRP_WH)
i_actS4      = input.string("stage4", "Stage 4 Action", group = GRP_WH)

var string GRP_COL = "🌈 Colors"
C_BASE       = input.color(#787b86, "Stage 1 Basing", group = GRP_COL)
C_SUP        = input.color(#26a69a, "Stage 2 Advancing", group = GRP_COL)
C_TOP        = input.color(#ff9800, "Stage 3 Topping", group = GRP_COL)
C_RES        = input.color(#ef5350, "Stage 4 Declining", group = GRP_COL)
C_BAR_HI     = input.color(#26a69a, "Bar High", group = GRP_COL)
C_BAR_MID    = input.color(#f9a825, "Bar Mid", group = GRP_COL)
C_BAR_LO     = input.color(#ef5350, "Bar Low", group = GRP_COL)
C_DASH_HDR   = input.color(color.new(#3a2a6d, 55), "Dashboard Header", group = GRP_COL)
C_DASH_BG    = input.color(color.new(#0a0f1a, 10), "Dashboard Background", group = GRP_COL)
C_DASH_TXT   = input.color(#ffffff, "Dashboard Text", group = GRP_COL)
C_WARN       = input.color(color.new(#f9a825, 80), "Warning Row", group = GRP_COL)

// ── CORE LOGIC ──────────────────────────────────────────────────
f_smooth(float src, string m, int len) =>
    float s = ta.sma(src, len)
    float e = ta.ema(src, len)
    float w = ta.wma(src, len)
    float h = ta.hma(src, len)
    float r = ta.rma(src, len)
    m == "SMA" ? s : m == "EMA" ? e : m == "WMA" ? w : m == "HMA" ? h : m == "RMA" ? r : src

f_stageName(int s) =>
    na(s) ? "—" : s == 1 ? "Stage 1 · Basing" : s == 2 ? "Stage 2 · Advancing" : s == 3 ? "Stage 3 · Topping" : "Stage 4 · Declining"

float coreSrc  = f_smooth(i_src, i_smooth, i_smoothLen)
float coreMa   = ta.sma(coreSrc, i_maLen)
float maBase   = coreMa[i_slopeLen]
float maSlope  = na(maBase) or maBase == 0 ? float(na) : (coreMa - maBase) / maBase * 100
float maDist   = na(coreMa) or coreMa == 0 ? float(na) : (coreSrc - coreMa) / coreMa * 100
bool  rising   = not na(maSlope) and maSlope > i_flatPct
bool  falling  = not na(maSlope) and maSlope < -i_flatPct
bool  above    = not na(coreMa) and coreSrc > coreMa
bool  below    = not na(coreMa) and coreSrc < coreMa
bool  notRising  = not na(maSlope) and maSlope <= i_flatPct
bool  notFalling = not na(maSlope) and maSlope >= -i_flatPct
float rangeHi  = ta.highest(high, i_rangeLen)[1]
float rangeLo  = ta.lowest(low, i_rangeLen)[1]
bool  breakUp  = not na(rangeHi) and coreSrc > rangeHi and above and notFalling
bool  breakDn  = not na(rangeLo) and coreSrc < rangeLo and below and notRising

var int lastRiseBar = int(na)
var int lastFallBar = int(na)
if rising
    lastRiseBar := bar_index
if falling
    lastFallBar := bar_index

var int stage          = int(na)
var int lastStage      = int(na)
var int stageStartTime = int(na)
var int stageStartBar  = int(na)

int  prevStage = stage
bool maRose    = not na(lastRiseBar) and not na(stageStartBar) and lastRiseBar >= stageStartBar
bool maFell    = not na(lastFallBar) and not na(stageStartBar) and lastFallBar >= stageStartBar
int  newStage  = na(maSlope) ? int(na) : na(prevStage) ? (rising and above ? 2 : falling and not above ? 4 : int(na)) : prevStage == 1 ? (breakDn ? 4 : breakUp ? 2 : 1) : prevStage == 2 ? (breakDn ? 4 : notRising and maRose ? 3 : notRising and not above ? 1 : 2) : prevStage == 3 ? (breakDn ? 4 : breakUp ? 2 : 3) : (breakUp ? 2 : notFalling and maFell ? 1 : notFalling and not below ? 3 : 4)
if not na(newStage) and (na(prevStage) or newStage != prevStage)
    lastStage      := prevStage
    stageStartTime := time
    stageStartBar  := bar_index
stage := newStage

bool stageChanged = not na(stage) and not na(stage[1]) and stage != stage[1]

float avgSum   = math.sum(nz(volume), i_volLen)
float avgCnt   = math.sum(nz(volume) > 0 ? 1 : 0, i_volLen)
float avgVol   = avgCnt > 0 ? avgSum / avgCnt : float(na)
float volRatio = na(avgVol) or avgVol <= 0 or na(volume) ? float(na) : volume / avgVol
float volSum   = math.sum(nz(volume), i_volLb)
float volCnt   = math.sum(nz(volume) > 0 ? 1 : 0, i_volLb)
float volBase  = volCnt > 0 ? volSum / volCnt : float(na)
float volPrev  = volBase[1]
var bool anyVol = false
anyVol := anyVol or nz(volume) > 0
bool  volSkipped  = not anyVol
float brkVolRatio = na(volPrev) or volPrev <= 0 ? float(na) : nz(volume) / volPrev
bool  volOk       = not i_useVol or volSkipped or (not na(brkVolRatio) and brkVolRatio >= i_volMult)

string htfTicker  = chart.is_standard ? syminfo.tickerid : ticker.standard(syminfo.tickerid)
bool   htfValid   = timeframe.in_seconds(i_htfTf) >= timeframe.in_seconds()
bool   htfActive  = i_useHtf and htfValid
int    htfBiasSrc = na(maSlope) ? int(na) : rising and above ? 1 : falling and not above ? -1 : 0
int    htfBias    = request.security(htfTicker, htfValid ? i_htfTf : timeframe.period, htfBiasSrc[1], lookahead = barmerge.lookahead_on)
bool   htfOkBull  = not htfActive or (not na(htfBias) and htfBias == 1)
bool   htfOkBear  = not htfActive or (not na(htfBias) and htfBias == -1)

[diPlus, diMinus, adx] = ta.dmi(i_adxLen, i_adxLen)
float adxPrev    = adx[1]
bool  strengthOk = not i_useAdx or (not na(adxPrev) and adxPrev >= i_adxThresh)

bool evtS1 = stageChanged and stage == 1
bool evtS2 = stageChanged and stage == 2 and htfOkBull and strengthOk and volOk
bool evtS3 = stageChanged and stage == 3
bool evtS4 = stageChanged and stage == 4 and htfOkBear and strengthOk

// ── ALERTS ──────────────────────────────────────────────────────
f_payload(string act, string dir) =>
    string _inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","event":"{4}","stage":"{5}","prev_stage":"{6}","price":"{7}","ma":"{8}","ma_slope_pct":"{9}","time":"{10}"',
         act, syminfo.tickerid, timeframe.period, dir, f_stageName(stage), str.tostring(stage), str.tostring(lastStage),
         str.tostring(close, format.mintick), str.tostring(coreMa, format.mintick), str.tostring(maSlope, "#.##"), str.tostring(time))
    "{" + _inner + "}"

if evtS1 and barstate.isconfirmed
    alert(f_payload(i_actS1, "neutral"), alert.freq_once_per_bar_close)
if evtS2 and barstate.isconfirmed
    alert(f_payload(i_actS2, "bullish"), alert.freq_once_per_bar_close)
if evtS3 and barstate.isconfirmed
    alert(f_payload(i_actS3, "neutral"), alert.freq_once_per_bar_close)
if evtS4 and barstate.isconfirmed
    alert(f_payload(i_actS4, "bearish"), alert.freq_once_per_bar_close)

alertcondition(evtS1 and barstate.isconfirmed, "Stage 1 · Basing", "MarkitTick — {{ticker}} entered Stage 1 · Basing")
alertcondition(evtS2 and barstate.isconfirmed, "Stage 2 · Advancing", "MarkitTick — {{ticker}} entered Stage 2 · Advancing")
alertcondition(evtS3 and barstate.isconfirmed, "Stage 3 · Topping", "MarkitTick — {{ticker}} entered Stage 3 · Topping")
alertcondition(evtS4 and barstate.isconfirmed, "Stage 4 · Declining", "MarkitTick — {{ticker}} entered Stage 4 · Declining")

// ── VISUALS ─────────────────────────────────────────────────────
color stageCol = na(stage) ? C_BASE : stage == 1 ? C_BASE : stage == 2 ? C_SUP : stage == 3 ? C_TOP : C_RES

plot(i_showMa ? coreMa : na, "Stage MA", color = stageCol, linewidth = 2)
bgcolor(i_showBg and not na(stage) ? color.new(stageCol, i_bgTransp) : na, title = "Stage Background")

color candleCol = i_showCandles and not na(stage) ? stageCol : na
plotcandle(open, high, low, close, title = "Stage Candles", color = candleCol, wickcolor = candleCol, bordercolor = candleCol)

// ── DASHBOARD ───────────────────────────────────────────────────
f_pos(string p) =>
    p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right

f_tf(string tf) =>
    int    n       = str.length(tf)
    string u       = str.substring(tf, n - 1, n)
    bool   hasUnit = u == "T" or u == "S" or u == "D" or u == "W" or u == "M"
    string q       = hasUnit ? str.substring(tf, 0, n - 1) : tf
    string qty     = q == "" ? "1" : q
    float  mins    = hasUnit ? float(na) : str.tonumber(qty)
    hasUnit ? (u == "S" ? qty + "s" : qty + u) : mins % 60 == 0 ? str.tostring(mins / 60, "#") + "H" : str.tostring(mins, "#") + "m"

f_num(float v) =>
    string res = "—"
    if not na(v)
        float  a   = math.abs(v)
        string sgn = v < 0 ? "-" : ""
        float  r2  = math.round(a, 2)
        float  k   = math.round(a / 1e3, 1)
        float  m   = math.round(a / 1e6, 1)
        float  b   = math.round(a / 1e9, 1)
        res := r2 < 1000 ? sgn + str.tostring(r2, "#.##") : k < 1000 ? sgn + str.tostring(k, "#.#") + "K" : m < 1000 ? sgn + str.tostring(m, "#.#") + "M" : sgn + str.tostring(b, "#.#") + "B"
    res

f_pct(float v) =>
    na(v) ? "—" : (v > 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

f_barColor(float pct) =>
    pct >= 0.66 ? C_BAR_HI : pct >= 0.33 ? C_BAR_MID : C_BAR_LO

f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

f_row(table t, int r, string lbl, string val, color vc, string tip = "") =>
    color bg = r % 2 == 1 ? C_DASH_BG : color.new(C_DASH_BG, 40)
    table.cell(t, 0, r, "  " + lbl, text_color = color.new(C_DASH_TXT, 25), text_halign = text.align_left, text_size = size.small, bgcolor = bg, tooltip = tip)
    table.cell(t, 1, r, val + "  ", text_color = vc, text_halign = text.align_right, text_size = size.small, bgcolor = bg, tooltip = tip)

var table dash = table.new(f_pos(i_dashPos), 2, 16, bgcolor = C_DASH_BG, frame_color = color.new(#3a2a6d, 40), frame_width = 1, border_color = color.new(#2a3040, 40), border_width = 1)

if barstate.islast and i_showDash
    color stateCol = na(stage) ? C_DASH_TXT : stage == 2 ? C_SUP : stage == 4 ? C_RES : C_DASH_TXT
    bool  knownStart = not na(lastStage)
    string tickTip   = syminfo.volumetype == "tick" ? "Volume on this symbol is tick volume · a count of trades, not units traded" : ""
    string warmTip   = "No stage is shown until Smoothing Length (when smoothing is on), MA Length and Slope Lookback bars have loaded, and then until the MA first rises with price above it or falls with price at or below it · a breakout or breakdown also needs Range Lookback bars"
    table.cell(dash, 0, 0, "WSCT", text_color = C_DASH_TXT, text_halign = text.align_left, text_size = size.small, bgcolor = C_DASH_HDR)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + f_tf(timeframe.period), text_color = C_DASH_TXT, text_halign = text.align_right, text_size = size.small, bgcolor = C_DASH_HDR)
    int r = 1
    f_row(dash, r, "Stage", f_stageName(stage), stateCol, warmTip)
    r += 1
    f_row(dash, r, "Previous", f_stageName(lastStage), C_DASH_TXT)
    r += 1
    f_row(dash, r, "Since", knownStart ? str.format_time(stageStartTime, "yyyy-MM-dd", syminfo.timezone) : "—", C_DASH_TXT)
    r += 1
    f_row(dash, r, "Bars in Stage", knownStart ? str.tostring(bar_index - stageStartBar + 1) : "—", C_DASH_TXT)
    r += 1
    f_row(dash, r, "Stage MA", na(coreMa) ? "—" : str.tostring(coreMa, format.mintick), C_DASH_TXT)
    r += 1
    f_row(dash, r, "MA Slope", f_pct(maSlope), rising ? C_SUP : falling ? C_RES : C_DASH_TXT)
    r += 1
    f_row(dash, r, "Distance to MA", f_pct(maDist), na(maDist) ? C_DASH_TXT : maDist > 0 ? C_SUP : maDist < 0 ? C_RES : C_DASH_TXT)
    r += 1
    f_row(dash, r, "Range High", na(rangeHi) ? "—" : str.tostring(rangeHi, format.mintick), C_DASH_TXT)
    r += 1
    f_row(dash, r, "Range Low", na(rangeLo) ? "—" : str.tostring(rangeLo, format.mintick), C_DASH_TXT)
    r += 1
    f_row(dash, r, "Volume", f_num(volume), C_DASH_TXT, tickTip)
    r += 1
    f_row(dash, r, "Vol vs Avg", na(volRatio) ? "—" : str.tostring(volRatio, "#.##") + "x", C_DASH_TXT, tickTip)
    r += 1
    if i_useHtf
        string htfTxt = not htfValid ? "Skipped · below chart TF" : na(htfBias) ? "—" : (htfBias == 1 ? "Bullish" : htfBias == -1 ? "Bearish" : "Neutral") + " · " + f_tf(i_htfTf)
        color  htfCol = not htfValid or na(htfBias) ? C_DASH_TXT : htfBias == 1 ? C_SUP : htfBias == -1 ? C_RES : C_DASH_TXT
        f_row(dash, r, "HTF Bias", htfTxt, htfCol)
        r += 1
    if i_useAdx
        f_row(dash, r, "Trend Strength", na(adxPrev) ? "—" : f_bar(adxPrev, 100), na(adxPrev) ? C_DASH_TXT : f_barColor(adxPrev / 100))
        r += 1
    if i_smooth != "None"
        f_row(dash, r, "Smoothing", i_smooth + " " + str.tostring(i_smoothLen), C_DASH_TXT)
        r += 1
    if i_useVol
        string volTxt = volSkipped ? "Skipped · no volume" : na(brkVolRatio) ? "—" : (brkVolRatio >= i_volMult ? "Pass · " : "Fail · ") + str.tostring(brkVolRatio, "#.##") + "x"
        color  volCol = volSkipped or na(brkVolRatio) ? C_DASH_TXT : brkVolRatio >= i_volMult ? C_SUP : C_RES
        color  volBg  = volSkipped ? C_WARN : r % 2 == 1 ? C_DASH_BG : color.new(C_DASH_BG, 40)
        table.cell(dash, 0, r, "  Breakout Volume", text_color = color.new(C_DASH_TXT, 25), text_halign = text.align_left, text_size = size.small, bgcolor = volBg, tooltip = tickTip)
        table.cell(dash, 1, r, volTxt + "  ", text_color = volCol, text_halign = text.align_right, text_size = size.small, bgcolor = volBg, tooltip = tickTip)
        r += 1
````
