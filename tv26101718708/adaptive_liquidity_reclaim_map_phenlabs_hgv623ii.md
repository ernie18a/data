# Adaptive Liquidity Reclaim Map [PhenLabs]

- url: https://www.tradingview.com/script/hGv623ii-Adaptive-Liquidity-Reclaim-Map-PhenLabs/
- type: indicator
- pine_id: PUB;c67639ff272b4fbca6f9ae72d2b23cf6
- version: 1.0

## Description

📊 Adaptive Liquidity Reclaim Map [PhenLabs]

Version: PineScript™ v6

📌 Description
Adaptive Liquidity Reclaim Map (ALRM) turns a common but noisy market event into a publication-ready visual decision: price sweeps a confirmed liquidity zone, decisively reclaims it, and aligns with higher-timeframe direction. The V2 layout is designed to make the active battlefield obvious at a glance—two slim zones, one focal reclaim, and one clean payoff block.

ALRM keeps only the newest buy-side and sell-side zones on the chart. When a reclaim qualifies, it prints a high-contrast score callout, tints the signal candle, and projects transparent risk/reward blocks from the actual sweep-bar invalidation to the runner objective.

🚀 Points of Innovation
[list]
[*]Slim active liquidity zones: the latest confirmed swing pools become semi-transparent ATR-sized zones instead of bare horizontal lines.
[*]Screenshot-first focal signal: a diamond marker and oversized BULL/BEAR RECLAIM callout concentrate attention on the qualified event.
[*]Transparent quality score: a 0-100 confluence measure combines impulse quality, reclaim close location, HTF alignment, and volatility suitability. It is not a probability or AI prediction.
[*]Payoff blocks, not just targets: translucent risk and reward rectangles show the geometry of the current setup from entry to runner.
[*]One event per pool: each confirmed swing can create only one signal, keeping the chart clean during repeated retests.
[/list]

🔧 Core Components
[list]
[*]Active Liquidity Zones: pivot highs create the newest buy-side zone and pivot lows create the newest sell-side zone. Each zone has a subtle fill, colored border, and optional dashed center.
[*]Adaptive Reclaim Filter: candle body is normalized by ATR and compared with a threshold that responds to current volatility.
[*]Confluence Quality Score: impulse, close location, HTF context, and volatility regime are normalized and clamped to a 0-100 quality display.
[*]Risk/Reward Block: the sweep extreme defines risk, while 1R and runner objectives create the latest payoff map.
[/list]

🔥 Key Features
[list]
[*]Neon emerald bullish and magenta bearish visuals remain clear on dark TradingView charts.
[*]Large BULL/BEAR RECLAIM callout includes Quality score and runner framing for an immediate screenshot narrative.
[*]Optional signal-candle tint makes the event visible even when zoomed out.
[*]Amber primary objective, subtle runner line, and thin entry line sit inside transparent risk/reward blocks.
[*]Branded 2-column dashboard shows mode, HTF bias, volatility regime, active pools, last event, and quality.
[*]Separate bullish and bearish alerts are available for notification workflows.
[/list]

🎨 Visualization
[list]
[*]Magenta zone: newest buy-side liquidity around a confirmed swing high, where upside sweep attempts are evaluated.
[*]Emerald zone: newest sell-side liquidity around a confirmed swing low, where downside sweep attempts are evaluated.
[*]Diamond marker plus large label: a qualified reclaim; the label states direction, confluence quality, and runner R target.
[*]Red risk block and emerald reward block: the latest payoff geometry from signal-bar entry through the runner objective.
[*]Amber dotted line: primary target. Fainter amber dotted line: runner. Thin neutral line: entry.
[*]Top-right ALRM V2 dashboard: compact context for publication screenshots and live decision support.
[/list]

📖 Usage Guidelines
[list]
[*][b]Pivot Left Bars[/b] — Default: 4 — Range: 2-20 — Controls how much left-side structure is required for a zone. Increase for more significant pools.
[*][b]Pivot Right Bars[/b] — Default: 4 — Range: 2-20 — Sets confirmation delay and selectivity. Higher values reduce zone turnover.
[*][b]ATR Length[/b] — Default: 14 — Range: 5-100 — Volatility unit used for impulse, quality, and zone sizing.
[*][b]Volatility Lookback[/b] — Default: 50 — Range: 10-200 — ATR baseline used to identify the current volatility regime.
[*][b]Base Impulse (ATR)[/b] — Default: 0.35 — Range: 0.10-2.00 — Minimum normalized candle body before adaptive scaling. Raise it for fewer, more forceful reclaims.
[*][b]Liquidity Zone Width (ATR)[/b] — Default: 0.10 — Range: 0.02-1.00 — Half-width of the active zone. Keep it near 0.10 for a slim, screenshot-friendly band.
[*][b]Require HTF Alignment[/b] — Default: On — Range: On/Off — Requires the reclaim to agree with higher-timeframe EMA direction.
[*][b]Higher Timeframe[/b] — Default: 240 — Range: Any TradingView timeframe — Context timeframe for directional filtering; typically select one above the chart timeframe.
[*][b]Primary Target (R)[/b] — Default: 1.0 — Range: 0.50-5.00 — Bright amber first objective measured from entry to sweep-bar extreme.
[*][b]Runner Target (R)[/b] — Default: 2.0 — Range: 0.75-8.00 — Full reward-block objective shown in the signal callout.
[*][b]Projection Length[/b] — Default: 30 — Range: 5-200 — Number of bars the active risk/reward block extends.
[*][b]Show Score Callouts[/b] — Default: On — Range: On/Off — Shows the large directional quality label; ALRM retains only the latest callout per direction.
[*][b]Tint Signal Candle[/b] — Default: On — Range: On/Off — Adds a high-contrast directional tint only to qualified signal candles.
[/list]

✅ Best Use Cases
[list]
[*]Dark-chart screenshot posts where the setup needs to be understood without a long explanation.
[*]Intraday index, futures, FX, and crypto charts where stop runs and reclaims are common.
[*]Liquidity-focused discretionary workflows that want a consistent visual invalidation and payoff reference.
[*]Multi-timeframe execution plans using a higher-timeframe direction filter with lower-timeframe entries.
[/list]

⚠️ Limitations
[list]
[*]Pivot confirmation delays a new zone by the selected right-bar setting; ALRM does not predict unconfirmed swings.
[*]The quality score is a normalized confluence display, not a forecast, probability, machine-learning output, or trade recommendation.
[*]Risk/reward blocks use the signal-bar sweep extreme and cannot account for spread, slippage, gaps, event risk, or future liquidity changes.
[*]Higher-timeframe alignment can filter valid countertrend reversals; disable it only with a separate reversal plan.
[/list]

💡 What Makes This Unique
[list]
[*]ALRM fuses a confirmed liquidity sweep, adaptive impulse logic, and HTF context into a single screenshot-first visual system.
[*]It replaces stale-line clutter with two current zones, capped callouts, and one active payoff map.
[*]The same sweep-bar event powers detection, quality framing, invalidation, and targets, so the visual story remains internally consistent.
[/list]

🔬 How It Works
[list]
[*]ALRM confirms the newest swing high and swing low, then renders each as a slim ATR-sized active liquidity zone.
[*]When price trades beyond a zone center and closes back through it, ALRM measures reclaim impulse relative to current ATR.
[*]The threshold adjusts with volatility, while the optional higher-timeframe EMA gate checks directional context without lookahead.
[*]A qualifying reclaim receives a clamped confluence score, a directional callout, and one projected risk/reward block with primary and runner objectives.
[/list]

[quote]💡 Note:
Use ALRM with market structure, session context, and a defined execution plan. Confirm alerts on bar close, account for instrument-specific costs, and test settings on the market and timeframe you trade. This tool is an analytical aid only and is not financial advice.[/quote]

## Source Code

````pine
//@version=6
indicator("Adaptive Liquidity Reclaim Map [PhenLabs]", shorttitle="ALRM", overlay=true, max_lines_count=30, max_boxes_count=10, max_labels_count=6)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string grpDetection = "1. Liquidity Detection"
leftBars = input.int(4, "Pivot Left Bars", minval=2, maxval=20, group=grpDetection, tooltip="Bars required to the left of a confirmed liquidity pivot.")
rightBars = input.int(4, "Pivot Right Bars", minval=2, maxval=20, group=grpDetection, tooltip="Bars required to the right of a confirmed liquidity pivot. Higher values are more selective.")
atrLen = input.int(14, "ATR Length", minval=5, maxval=100, group=grpDetection, tooltip="Volatility baseline used to normalize reclaim strength and size liquidity zones.")
volLookback = input.int(50, "Volatility Lookback", minval=10, maxval=200, group=grpDetection, tooltip="Lookback used to adapt the impulse threshold to the current volatility regime.")
baseImpulse = input.float(0.35, "Base Impulse (ATR)", minval=0.10, maxval=2.00, step=0.05, group=grpDetection, tooltip="Minimum candle body as a fraction of ATR before adaptive scaling.")
zoneWidthAtr = input.float(0.10, "Liquidity Zone Width (ATR)", minval=0.02, maxval=1.00, step=0.01, group=grpDetection, tooltip="Half-width of each active liquidity zone as a fraction of ATR. 0.10 keeps zones slim on a screenshot.")

string grpContext = "2. Higher-Timeframe Context"
useHtfGate = input.bool(true, "Require HTF Alignment", group=grpContext, tooltip="Signals only fire when the reclaim agrees with the selected higher-timeframe EMA bias.")
htfTimeframe = input.timeframe("240", "Higher Timeframe", group=grpContext, tooltip="Context timeframe. Select one above the chart timeframe for a meaningful bias filter.")
htfEmaLen = input.int(50, "HTF EMA Length", minval=10, maxval=300, group=grpContext, tooltip="EMA length used inside the higher-timeframe bias calculation.")

string grpTargets = "3. Payoff Map"
rrPrimary = input.float(1.0, "Primary Target (R)", minval=0.50, maxval=5.00, step=0.25, group=grpTargets, tooltip="First objective measured from entry to the sweep-bar extreme.")
rrRunner = input.float(2.0, "Runner Target (R)", minval=0.75, maxval=8.00, step=0.25, group=grpTargets, tooltip="Second objective measured from entry to the sweep-bar extreme.")
projectionBars = input.int(30, "Projection Length", minval=5, maxval=200, group=grpTargets, tooltip="Number of bars used to draw the current risk/reward block.")

string grpVisuals = "4. Screenshot Visuals"
showLiquidityZones = input.bool(true, "Show Active Liquidity Zones", group=grpVisuals)
showZoneCenter = input.bool(true, "Show Zone Center Line", group=grpVisuals)
showSignals = input.bool(true, "Show Signal Markers", group=grpVisuals)
showCallouts = input.bool(true, "Show Score Callouts", group=grpVisuals)
showPayoffMap = input.bool(true, "Show Risk/Reward Blocks", group=grpVisuals)
showSignalTint = input.bool(true, "Tint Signal Candle", group=grpVisuals)
bullColor = input.color(color.rgb(0, 245, 160), "Bullish Emerald", group=grpVisuals)
bearColor = input.color(color.rgb(255, 45, 149), "Bearish Magenta", group=grpVisuals)
primaryColor = input.color(color.rgb(255, 190, 65), "Primary Target Amber", group=grpVisuals)
neutralColor = input.color(color.rgb(156, 163, 175), "Neutral Text", group=grpVisuals)
charcoalColor = input.color(color.rgb(19, 20, 27), "Charcoal Background", group=grpVisuals)

// ─────────────────────────────────────────────────────────────────────────────
// Volatility and adaptive quality inputs. All values are guarded before use.
// ─────────────────────────────────────────────────────────────────────────────
float atrValue = ta.atr(atrLen)
float atrBaseline = ta.sma(atrValue, volLookback)
float volatilityRatio = not na(atrValue) and not na(atrBaseline) and atrBaseline > 0 ? atrValue / atrBaseline : 1.0
float adaptiveImpulse = baseImpulse * math.max(0.65, math.min(1.50, volatilityRatio))
float bodyAtr = not na(atrValue) and atrValue > 0 ? math.abs(close - open) / atrValue : na
float zoneHalfWidth = not na(atrValue) and atrValue > 0 ? atrValue * zoneWidthAtr : na
float candleHeight = high - low
float bullCloseLocation = candleHeight > 0 ? (close - low) / candleHeight : 0.50
float bearCloseLocation = candleHeight > 0 ? (high - close) / candleHeight : 0.50
float impulseQuality = not na(bodyAtr) and adaptiveImpulse > 0 ? math.min(1.0, bodyAtr / (adaptiveImpulse * 1.50)) : 0.0
float volatilityQuality = math.max(0.0, 1.0 - math.min(1.0, math.abs(volatilityRatio - 1.0) / 0.75))

// ─────────────────────────────────────────────────────────────────────────────
// Detection: only the latest confirmed pivot becomes the active liquidity zone.
// ─────────────────────────────────────────────────────────────────────────────
float pivotHigh = ta.pivothigh(high, leftBars, rightBars)
float pivotLow = ta.pivotlow(low, leftBars, rightBars)

var float lastSwingHigh = na
var float lastSwingLow = na
var bool bullUsed = false
var bool bearUsed = false
var box buySideZone = na
var box sellSideZone = na
var line buySideCenter = na
var line sellSideCenter = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    bearUsed := false
    if not na(buySideZone)
        box.delete(buySideZone)
    if not na(buySideCenter)
        line.delete(buySideCenter)
    if showLiquidityZones and not na(zoneHalfWidth)
        buySideZone := box.new(left=bar_index - rightBars, top=lastSwingHigh + zoneHalfWidth, right=bar_index, bottom=lastSwingHigh - zoneHalfWidth, xloc=xloc.bar_index, extend=extend.right, border_color=color.new(bearColor, 15), border_width=1, bgcolor=color.new(bearColor, 88))
        if showZoneCenter
            buySideCenter := line.new(x1=bar_index - rightBars, y1=lastSwingHigh, x2=bar_index, y2=lastSwingHigh, xloc=xloc.bar_index, extend=extend.right, color=color.new(bearColor, 30), style=line.style_dashed, width=1)

if not na(pivotLow)
    lastSwingLow := pivotLow
    bullUsed := false
    if not na(sellSideZone)
        box.delete(sellSideZone)
    if not na(sellSideCenter)
        line.delete(sellSideCenter)
    if showLiquidityZones and not na(zoneHalfWidth)
        sellSideZone := box.new(left=bar_index - rightBars, top=lastSwingLow + zoneHalfWidth, right=bar_index, bottom=lastSwingLow - zoneHalfWidth, xloc=xloc.bar_index, extend=extend.right, border_color=color.new(bullColor, 15), border_width=1, bgcolor=color.new(bullColor, 88))
        if showZoneCenter
            sellSideCenter := line.new(x1=bar_index - rightBars, y1=lastSwingLow, x2=bar_index, y2=lastSwingLow, xloc=xloc.bar_index, extend=extend.right, color=color.new(bullColor, 30), style=line.style_dashed, width=1)

// ─────────────────────────────────────────────────────────────────────────────
// Confirmation gate: adaptive impulse plus no-lookahead HTF directional context.
// ─────────────────────────────────────────────────────────────────────────────
bool htfBull = request.security(syminfo.tickerid, htfTimeframe, close > ta.ema(close, htfEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
bool htfBear = request.security(syminfo.tickerid, htfTimeframe, close < ta.ema(close, htfEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
bool bullContext = not useHtfGate or htfBull
bool bearContext = not useHtfGate or htfBear
float bullHtfQuality = htfBull ? 1.0 : useHtfGate ? 0.0 : 0.50
float bearHtfQuality = htfBear ? 1.0 : useHtfGate ? 0.0 : 0.50

bool bullSweep = not na(lastSwingLow) and low < lastSwingLow and close > lastSwingLow
bool bearSweep = not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh
bool bullImpulse = not na(bodyAtr) and close > open and bodyAtr >= adaptiveImpulse
bool bearImpulse = not na(bodyAtr) and close < open and bodyAtr >= adaptiveImpulse
float bullRisk = close - low
float bearRisk = high - close

// Setup quality is confluence, not a probability or an AI prediction.
float bullScore = math.max(0.0, math.min(100.0, impulseQuality * 35.0 + bullCloseLocation * 30.0 + bullHtfQuality * 20.0 + volatilityQuality * 15.0))
float bearScore = math.max(0.0, math.min(100.0, impulseQuality * 35.0 + bearCloseLocation * 30.0 + bearHtfQuality * 20.0 + volatilityQuality * 15.0))

// Signal logic is preserved: a fresh sweep-reclaim must satisfy impulse, HTF,
// and minimum-risk gates, with only one signal permitted per confirmed pool.
bool bullSignal = bullSweep and bullImpulse and bullContext and not bullUsed and bullRisk > syminfo.mintick
bool bearSignal = bearSweep and bearImpulse and bearContext and not bearUsed and bearRisk > syminfo.mintick

// ─────────────────────────────────────────────────────────────────────────────
// Latest signal callouts and payoff blocks. Older drawings are removed so the
// chart stays publication-ready rather than becoming a historical object stack.
// ─────────────────────────────────────────────────────────────────────────────
var label bullCallout = na
var label bearCallout = na
var box riskBlock = na
var box rewardBlock = na
var line entryLine = na
var line primaryTargetLine = na
var line runnerTargetLine = na
var string lastSignalText = "WAITING"
var float lastSignalScore = na
var color lastSignalColor = neutralColor

if bullSignal
    bullUsed := true
    lastSignalText := "BULL RECLAIM"
    lastSignalScore := bullScore
    lastSignalColor := bullColor
    if not na(bullCallout)
        label.delete(bullCallout)
    if not na(riskBlock)
        box.delete(riskBlock)
    if not na(rewardBlock)
        box.delete(rewardBlock)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(primaryTargetLine)
        line.delete(primaryTargetLine)
    if not na(runnerTargetLine)
        line.delete(runnerTargetLine)
    float bullStop = low
    float bullTargetOne = close + bullRisk * rrPrimary
    float bullTargetTwo = close + bullRisk * rrRunner
    if showCallouts
        bullCallout := label.new(x=bar_index, y=na, text="BULL RECLAIM\nSETUP " + str.tostring(bullScore, "#") + "/100\n" + str.tostring(rrRunner, "#.0#") + "R RUNNER", xloc=xloc.bar_index, yloc=yloc.belowbar, color=bullColor, textcolor=charcoalColor, style=label.style_label_up, size=size.large)
    if showPayoffMap
        riskBlock := box.new(left=bar_index, top=close, right=bar_index + projectionBars, bottom=bullStop, xloc=xloc.bar_index, border_color=color.new(bearColor, 35), border_width=1, bgcolor=color.new(bearColor, 86))
        rewardBlock := box.new(left=bar_index, top=bullTargetTwo, right=bar_index + projectionBars, bottom=close, xloc=xloc.bar_index, border_color=color.new(bullColor, 35), border_width=1, bgcolor=color.new(bullColor, 86))
        entryLine := line.new(x1=bar_index, y1=close, x2=bar_index + projectionBars, y2=close, xloc=xloc.bar_index, extend=extend.none, color=color.new(neutralColor, 25), style=line.style_solid, width=1)
        primaryTargetLine := line.new(x1=bar_index, y1=bullTargetOne, x2=bar_index + projectionBars, y2=bullTargetOne, xloc=xloc.bar_index, extend=extend.none, color=primaryColor, style=line.style_dotted, width=2)
        runnerTargetLine := line.new(x1=bar_index, y1=bullTargetTwo, x2=bar_index + projectionBars, y2=bullTargetTwo, xloc=xloc.bar_index, extend=extend.none, color=color.new(primaryColor, 55), style=line.style_dotted, width=1)

if bearSignal
    bearUsed := true
    lastSignalText := "BEAR RECLAIM"
    lastSignalScore := bearScore
    lastSignalColor := bearColor
    if not na(bearCallout)
        label.delete(bearCallout)
    if not na(riskBlock)
        box.delete(riskBlock)
    if not na(rewardBlock)
        box.delete(rewardBlock)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(primaryTargetLine)
        line.delete(primaryTargetLine)
    if not na(runnerTargetLine)
        line.delete(runnerTargetLine)
    float bearStop = high
    float bearTargetOne = close - bearRisk * rrPrimary
    float bearTargetTwo = close - bearRisk * rrRunner
    if showCallouts
        bearCallout := label.new(x=bar_index, y=na, text="BEAR RECLAIM\nSETUP " + str.tostring(bearScore, "#") + "/100\n" + str.tostring(rrRunner, "#.0#") + "R RUNNER", xloc=xloc.bar_index, yloc=yloc.abovebar, color=bearColor, textcolor=color.white, style=label.style_label_down, size=size.large)
    if showPayoffMap
        riskBlock := box.new(left=bar_index, top=bearStop, right=bar_index + projectionBars, bottom=close, xloc=xloc.bar_index, border_color=color.new(bearColor, 35), border_width=1, bgcolor=color.new(bearColor, 86))
        rewardBlock := box.new(left=bar_index, top=close, right=bar_index + projectionBars, bottom=bearTargetTwo, xloc=xloc.bar_index, border_color=color.new(bullColor, 35), border_width=1, bgcolor=color.new(bullColor, 86))
        entryLine := line.new(x1=bar_index, y1=close, x2=bar_index + projectionBars, y2=close, xloc=xloc.bar_index, extend=extend.none, color=color.new(neutralColor, 25), style=line.style_solid, width=1)
        primaryTargetLine := line.new(x1=bar_index, y1=bearTargetOne, x2=bar_index + projectionBars, y2=bearTargetOne, xloc=xloc.bar_index, extend=extend.none, color=primaryColor, style=line.style_dotted, width=2)
        runnerTargetLine := line.new(x1=bar_index, y1=bearTargetTwo, x2=bar_index + projectionBars, y2=bearTargetTwo, xloc=xloc.bar_index, extend=extend.none, color=color.new(primaryColor, 55), style=line.style_dotted, width=1)

plotshape(bullSignal and showSignals, title="Bullish Liquidity Reclaim", style=shape.diamond, location=location.belowbar, color=bullColor, text="", size=size.small)
plotshape(bearSignal and showSignals, title="Bearish Liquidity Reclaim", style=shape.diamond, location=location.abovebar, color=bearColor, text="", size=size.small)
color signalTint = showSignalTint and bullSignal ? bullColor : showSignalTint and bearSignal ? bearColor : na
barcolor(signalTint, title="ALRM Signal Tint")

// ─────────────────────────────────────────────────────────────────────────────
// Compact branded dashboard
// ─────────────────────────────────────────────────────────────────────────────
var table dashboard = table.new(position.top_right, 2, 8, bgcolor=color.new(charcoalColor, 8), frame_color=color.new(neutralColor, 75), frame_width=1, border_color=color.new(neutralColor, 88), border_width=1)

if barstate.islast
    string htfState = htfBull ? "BULLISH" : htfBear ? "BEARISH" : "NEUTRAL"
    color htfColor = htfBull ? bullColor : htfBear ? bearColor : neutralColor
    string volatilityState = volatilityRatio > 1.15 ? "ELEVATED" : volatilityRatio < 0.85 ? "COMPRESSED" : "NORMAL"
    color volatilityColor = volatilityRatio > 1.15 ? bearColor : volatilityRatio < 0.85 ? bullColor : neutralColor
    string buySideText = na(lastSwingHigh) ? "WAITING" : str.tostring(lastSwingHigh, format.mintick)
    string sellSideText = na(lastSwingLow) ? "WAITING" : str.tostring(lastSwingLow, format.mintick)
    string qualityText = na(lastSignalScore) ? "-- / 100" : str.tostring(lastSignalScore, "#") + " / 100"
    color qualityColor = na(lastSignalScore) ? neutralColor : lastSignalScore >= 75 ? bullColor : lastSignalScore >= 55 ? primaryColor : bearColor
    table.cell(dashboard, 0, 0, "ALRM  •  V2", text_color=color.white, bgcolor=color.new(charcoalColor, 0), text_halign=text.align_left)
    table.cell(dashboard, 1, 0, "RECLAIM MAP", text_color=primaryColor, bgcolor=color.new(charcoalColor, 0), text_halign=text.align_right)
    table.cell(dashboard, 0, 1, "MODE", text_color=neutralColor, bgcolor=color.new(charcoalColor, 35), text_halign=text.align_left)
    table.cell(dashboard, 1, 1, useHtfGate ? "HTF FILTERED" : "OPEN FILTER", text_color=useHtfGate ? primaryColor : neutralColor, bgcolor=color.new(charcoalColor, 35), text_halign=text.align_right)
    table.cell(dashboard, 0, 2, "HTF BIAS", text_color=neutralColor, text_halign=text.align_left)
    table.cell(dashboard, 1, 2, htfState, text_color=htfColor, text_halign=text.align_right)
    table.cell(dashboard, 0, 3, "VOL REGIME", text_color=neutralColor, text_halign=text.align_left)
    table.cell(dashboard, 1, 3, volatilityState, text_color=volatilityColor, text_halign=text.align_right)
    table.cell(dashboard, 0, 4, "BUY POOL", text_color=neutralColor, text_halign=text.align_left)
    table.cell(dashboard, 1, 4, buySideText, text_color=bearColor, text_halign=text.align_right)
    table.cell(dashboard, 0, 5, "SELL POOL", text_color=neutralColor, text_halign=text.align_left)
    table.cell(dashboard, 1, 5, sellSideText, text_color=bullColor, text_halign=text.align_right)
    table.cell(dashboard, 0, 6, "LAST EVENT", text_color=neutralColor, bgcolor=color.new(charcoalColor, 35), text_halign=text.align_left)
    table.cell(dashboard, 1, 6, lastSignalText, text_color=lastSignalColor, bgcolor=color.new(charcoalColor, 35), text_halign=text.align_right)
    table.cell(dashboard, 0, 7, "QUALITY", text_color=neutralColor, bgcolor=color.new(charcoalColor, 15), text_halign=text.align_left)
    table.cell(dashboard, 1, 7, qualityText, text_color=qualityColor, bgcolor=color.new(charcoalColor, 15), text_halign=text.align_right)

alertcondition(bullSignal, title="ALRM Bullish Liquidity Reclaim", message="ALRM bullish liquidity reclaim on {{ticker}} at {{close}}.")
alertcondition(bearSignal, title="ALRM Bearish Liquidity Reclaim", message="ALRM bearish liquidity reclaim on {{ticker}} at {{close}}.")
````
