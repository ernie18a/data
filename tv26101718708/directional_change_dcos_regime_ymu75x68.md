# Directional Change DC/OS + Regime 

- url: https://www.tradingview.com/script/yMU75X68-Directional-Change-DC-OS-Regime/
- type: indicator
- pine_id: PUB;370e68ae9454419191bc2abee2e9ab1d
- version: 1.0

## Description

DC/OS Filter — Directional Change & Overshoot Observer
DC/OS Filter is a market-structure observation tool. It does not forecast price. It does not predict turns. It simply marks what has already happened in terms of Directional Change (DC) and Overshoot (OS) events, measures them, and — optionally — filters those observations through a regime context.

Everything you see on the chart is a record of a completed move. Nothing on the chart is a promise about the future.

What it observes
The indicator runs up to five independent agents, each with its own sensitivity threshold (0.5% / 1% / 2% / 5% / 10% by default). Each agent tracks price using the Directional Change / Overshoot event framework:

DC (Directional Change) — a reversal of at least δ% from the last extreme. This is a confirmed change of direction, measured after the fact.

OS (Overshoot) — a continuation beyond the last DC extreme, in the same direction. Also confirmed after the fact.

Every DC and OS is a historical event, plotted at the moment it completed — never before.

For each agent, the tool accumulates statistics on those events: event counts, average DC duration, average OS duration, average OS length, and the level at which the next DC would occur given the current extreme.

What the dashed "prediction" lines actually mean
The dashed horizontal lines labeled "pred DC" and "pred OS" are not forecasts.

They are arithmetic projections of the current observation state:

pred DC = the price at which a DC event would be confirmed if price were to reach it. It is derived purely from the current extreme and the agent's threshold.

pred OS = the price at which the next OS would be recorded, based on the historical average OS length of that agent.

The vertical placement of these lines on the time axis is derived from the agent's own historical average cycle time — how long, on average, past DC+OS cycles have taken to complete. It is a backward-looking average, not a forward-looking estimate.

If the market never reaches those levels, nothing happens. The lines are simply a reference grid showing where events would trigger, given today's structure.

The regime filter
The optional filter classifies the current environment into one of: Trend Up, Trend Down, Range, Chop, or Neutral, using:

EMA 50 / EMA 200 for directional bias

ADX for trend strength

A body-ratio chop detector

Optional RTH session gate (0930–1600)

Optional volume-spike requirement

Its purpose is to contextualize the DC/OS events — to say, "given the current regime, this observation is consistent with a trend continuation, or with a range boundary." It does not add information about the future. It only describes the present.

How to read it
Colors and labels — Every DC and OS is drawn with its own line, marker, and text label. Hover any label for full details: price, time, threshold, direction, event counts.

Dashboard — Per-agent statistics (mode, event count, last DC, next DC level, distance to next DC, average cycle length) are shown in a compact table. A SUGGESTION row summarizes the current observational state — again, a description, not a signal.

Prediction lines — Show where an event would be confirmed and roughly when, based on history. Treat them as reference levels, not targets.

Signal marks — When enabled, LONG/SHORT triangles mark moments where a completed DC or OS aligns with the current regime filter. These are confirmations of what the structure already did, not entries into what it will do.

What this indicator is not
Not a forecasting tool. It does not predict price, direction, or timing.

Not a signal generator in the traditional sense. The LONG/SHORT markers annotate completed structure, not anticipated structure.

Not a strategy. There are no entries, exits, or position sizing rules baked in.

Not a replacement for risk management. Observations are not advice.

Why this framing matters
Most indicators on TradingView are marketed as predictors. This one deliberately is not. Directional Change theory is fundamentally a descriptive framework — it defines events rigorously so they can be counted, measured, and compared. The value of the tool is in the discipline of that measurement:

It removes ambiguity about "when did the trend change?" — because a DC is a precisely defined event.

It lets you compare the same market across multiple sensitivities at once, so you can see the structure at different scales simultaneously.

It gives you a stable, statistics-based reference grid for the levels at which structure would change — so you can plan around them instead of guessing.

You are not being told what will happen. You are being shown what has happened, measured consistently, and laid out cleanly so you can make your own decision.

Settings overview
Agents 1–5 — Enable/disable, threshold %, colors. All five run independently.

Performance — Max bars to draw, chart drawings on/off, text on lines on/off.

Regime filter — Action mode (Off / Trend only / Range only), RTH, volume spike, EMA/ADX lengths, signal agent selection, bar-close confirmation.

Style — Dashboard position and size, line label size.

Notes and limitations
The tool is designed for 15-minute stock charts but works on any liquid instrument and timeframe.

Historical drawings are pruned beyond Max Bars to Draw to stay within TradingView object limits.

Prediction lines are recomputed on each DC event; they are state-driven, not time-driven, and will move as structure evolves.

Tooltips render at TradingView's standard size; only line label size is configurable. 

NOT A FINANCIAL ADVICE ... ONLY FOR EDUCATIONAL PURPOSES

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gogaz

//@version=6
indicator(title="Directional Change DC/OS + Regime", shorttitle="Directional Change + Filter", overlay=true, max_lines_count=500, max_labels_count=500)

type Agent
    float p_h
    float p_l
    int mode
    float lastDCPrice
    int lastDCTime
    float lastOSPrice
    int lastOSTime
    line currentOSLine
    int totalEvents
    int numOS
    int numDC
    float sumOSLength
    float lastOSLength
    float sumTimeOS
    int countTimeOS
    float lastTimeOS
    float sumTimeDC
    int countTimeDC
    float lastTimeDC
    float lastEventPrice
    int lastEventBarIndex
    string lastEventType
    bool isFirstEvent
    bool osSegmentStarted
    int lastDCBar
    int lastOSBarIndex
    line predDCLine
    line predOSLine
    float avgTimeDC
    float avgTimeOS
    int barsSinceLastClean
    bool justDC
    bool justOS
    label dcLabel
    label osLabel
    label predDCLabel
    label predOSLabel

detectEvents(highPrice, lowPrice, mode, highPoint, lowPoint, delta) =>
    int newMode = mode
    bool isDC = false
    bool isOS = false
    float eventPrice = na
    int eventTime = time
    string eventType = na
    float newHighPoint = highPoint
    float newLowPoint = lowPoint
    if mode == 1
        if lowPrice <= highPoint * (1 - delta)
            isDC := true
            eventPrice := lowPrice
            eventType := "Down DC"
            newMode := -1
            newLowPoint := lowPrice
        else if highPrice > highPoint
            isOS := true
            eventPrice := highPrice
            eventType := "Up OS"
            newHighPoint := highPrice
    else
        if highPrice >= lowPoint * (1 + delta)
            isDC := true
            eventPrice := highPrice
            eventType := "Up DC"
            newMode := 1
            newHighPoint := highPrice
        else if lowPrice < lowPoint
            isOS := true
            eventPrice := lowPrice
            eventType := "Down OS"
            newLowPoint := lowPrice
    [newMode, isDC, isOS, eventPrice, eventTime, eventType, newHighPoint, newLowPoint]

sizeFromString(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

formatTime(int t) =>
    na(t) ? "—" : str.format_time(t, "yyyy-MM-dd HH:mm", syminfo.timezone)

updateAgent(agent, delta, dcColor, osColor, drawLimit, showText, lblSize) =>
    agent.justDC := false
    agent.justOS := false
    agent.barsSinceLastClean += 1
    if agent.barsSinceLastClean >= 100
        if agent.lastDCBar > 0 and (bar_index - agent.lastDCBar) > drawLimit
            if not na(agent.currentOSLine)
                line.delete(agent.currentOSLine)
                agent.currentOSLine := na
            if not na(agent.osLabel)
                label.delete(agent.osLabel)
                agent.osLabel := na
        agent.barsSinceLastClean := 0

    [newMode, isDC, isOS, eventPrice, eventTime, eventType, new_p_h, new_p_l] = detectEvents(high, low, agent.mode, agent.p_h, agent.p_l, delta)

    if isDC or isOS
        if isDC
            agent.justDC := true
            int cycleBars = bar_index - agent.lastDCBar
            bool validCycle = not agent.isFirstEvent and cycleBars > 0 and cycleBars < 10000
            if validCycle
                agent.lastTimeDC := cycleBars
                agent.sumTimeDC += cycleBars
                agent.countTimeDC += 1
                agent.avgTimeDC := agent.sumTimeDC / agent.countTimeDC
            else
                agent.lastTimeDC := na

            if agent.osSegmentStarted and not na(agent.lastOSPrice) and not na(agent.lastDCPrice) and agent.lastDCPrice != 0
                length = agent.mode == 1 ? (agent.lastOSPrice / agent.lastDCPrice - 1.0) * 100.0 : (agent.lastDCPrice / agent.lastOSPrice - 1.0) * 100.0
                agent.sumOSLength += length
                agent.lastOSLength := length

            if not na(agent.lastOSBarIndex) and agent.lastOSBarIndex > agent.lastDCBar
                osBars = agent.lastOSBarIndex - agent.lastDCBar
                if osBars > 0 and osBars < 10000
                    agent.lastTimeOS := osBars
                    agent.sumTimeOS += osBars
                    agent.countTimeOS += 1
                    agent.avgTimeOS := agent.sumTimeOS / agent.countTimeOS
            else
                agent.lastTimeOS := na

            agent.numDC += 1
            agent.osSegmentStarted := false
            agent.totalEvents += 1
            agent.lastDCBar := bar_index
            agent.lastOSBarIndex := na
            agent.lastEventType := "DC"
        else
            agent.justOS := true
            agent.lastOSBarIndex := bar_index
            if not agent.osSegmentStarted
                agent.numOS += 1
                agent.osSegmentStarted := true
                agent.totalEvents += 1
            agent.lastEventType := "OS"

        agent.lastEventPrice := eventPrice
        agent.lastEventBarIndex := bar_index
        if agent.isFirstEvent
            agent.isFirstEvent := false

        lineColor = agent.mode == 1 ? dcColor : osColor
        labelStyle = agent.mode == 1 ? label.style_label_down : label.style_label_up
        canDraw = drawLimit > 0

        if isDC
            if canDraw
                if not na(agent.lastOSPrice)
                    line.new(agent.lastDCTime, agent.lastDCPrice, agent.lastOSTime, agent.lastOSPrice, style=line.style_dashed, color=lineColor, xloc=xloc.bar_time)
                    line.new(agent.lastOSTime, agent.lastOSPrice, eventTime, eventPrice, style=line.style_solid, color=lineColor, xloc=xloc.bar_time)
                else
                    line.new(agent.lastDCTime, agent.lastDCPrice, eventTime, eventPrice, style=line.style_solid, color=lineColor, xloc=xloc.bar_time)

                if not na(agent.currentOSLine)
                    line.delete(agent.currentOSLine)
                    agent.currentOSLine := na
                if not na(agent.osLabel)
                    label.delete(agent.osLabel)
                    agent.osLabel := na

                // --- DC event label (reused) with tooltip ---
                dcText = eventType + (showText ? "\n" + str.tostring(eventPrice, format.mintick) + "  Δ" + str.tostring(delta * 100, "#.##") + "%" : "")
                dcTip = "DC EVENT\n" +
                         "Type:      " + eventType + "\n" +
                         "Price:     " + str.tostring(eventPrice, format.mintick) + "\n" +
                         "Time:      " + formatTime(eventTime) + "\n" +
                         "Threshold: " + str.tostring(delta * 100, "#.##") + "%\n" +
                         "New mode:  " + (newMode == 1 ? "UP" : "DOWN") + "\n" +
                         "Total DC:  " + str.tostring(agent.numDC)
                if na(agent.dcLabel)
                    agent.dcLabel := label.new(eventTime, eventPrice, dcText, color=lineColor, textcolor=color.white, style=labelStyle, xloc=xloc.bar_time, size=lblSize, tooltip=dcTip)
                else
                    label.set_xy(agent.dcLabel, eventTime, eventPrice)
                    label.set_text(agent.dcLabel, dcText)
                    label.set_color(agent.dcLabel, lineColor)
                    label.set_style(agent.dcLabel, labelStyle)
                    label.set_size(agent.dcLabel, lblSize)
                    label.set_tooltip(agent.dcLabel, dcTip)

            agent.lastDCPrice := eventPrice
            agent.lastDCTime := eventTime
            agent.lastOSPrice := na
            agent.lastOSTime := na
            agent.mode := newMode

            if canDraw
                nextDCPx = agent.mode == 1 ? agent.lastDCPrice * (1 - delta) : agent.lastDCPrice * (1 + delta)
                avgOS = agent.numOS > 0 ? agent.sumOSLength / agent.numOS : 0.0
                nextOSPx = agent.mode == 1 ? agent.lastDCPrice * (1.0 + avgOS / 100.0) : agent.lastDCPrice / (1.0 + avgOS / 100.0)
                color_dc = agent.mode == 1 ? osColor : dcColor
                color_os = agent.mode == 1 ? dcColor : osColor

                if agent.countTimeDC > 0
                    avgWait = math.min(nz(agent.avgTimeDC, 0) + nz(agent.avgTimeOS, 0), 500)
                    predBar = bar_index + int(math.round(avgWait))
                    if na(agent.predDCLine)
                        agent.predDCLine := line.new(predBar - 15, nextDCPx, predBar + 15, nextDCPx, color=color_dc, width=1)
                    else
                        line.set_xy1(agent.predDCLine, predBar - 15, nextDCPx)
                        line.set_xy2(agent.predDCLine, predBar + 15, nextDCPx)
                        line.set_color(agent.predDCLine, color_dc)

                    // --- Predicted DC label (reused) with tooltip ---
                    predDCText = showText ? "pred DC\n" + str.tostring(nextDCPx, format.mintick) : "pred DC"
                    predDCTip = "PREDICTED DC\n" + "Price:      " + str.tostring(nextDCPx, format.mintick) + "\n" +"Earliest:   ~" + str.tostring(int(math.round(avgWait))) + " bars ahead\n" +"Avg DC:     " + str.tostring(agent.avgTimeDC, "#.#") + " bars\n" + "Avg OS:     " + str.tostring(agent.avgTimeOS, "#.#") + " bars\n" + "Mode:       " + (agent.mode == 1 ? "UP" : "DOWN") + "\n" +"Threshold:  " + str.tostring(delta * 100, "#.##") + "%"
                    if na(agent.predDCLabel)
                        agent.predDCLabel := label.new(predBar, nextDCPx, predDCText, color=color_dc, textcolor=color.white, style=label.style_label_left, size=lblSize, tooltip=predDCTip)
                    else
                        label.set_xy(agent.predDCLabel, predBar, nextDCPx)
                        label.set_text(agent.predDCLabel, predDCText)
                        label.set_color(agent.predDCLabel, color_dc)
                        label.set_size(agent.predDCLabel, lblSize)
                        label.set_tooltip(agent.predDCLabel, predDCTip)

                if agent.countTimeOS > 0
                    osWait = math.min(nz(agent.avgTimeOS, 0), 500)
                    predOSBar = bar_index + int(math.round(osWait))
                    if na(agent.predOSLine)
                        agent.predOSLine := line.new(predOSBar - 15, nextOSPx, predOSBar + 15, nextOSPx, color=color_os, width=1)
                    else
                        line.set_xy1(agent.predOSLine, predOSBar - 15, nextOSPx)
                        line.set_xy2(agent.predOSLine, predOSBar + 15, nextOSPx)
                        line.set_color(agent.predOSLine, color_os)

                    // --- Predicted OS label (reused) with tooltip ---
                    predOSText = showText ? "pred OS\n" + str.tostring(nextOSPx, format.mintick) : "pred OS"
                    predOSTip = "PREDICTED OS\n" + "Price:      " + str.tostring(nextOSPx, format.mintick) + "\n"    +"Earliest:   ~" + str.tostring(int(math.round(osWait))) + " bars ahead\n" +  "Avg OS:     " + str.tostring(agent.avgTimeOS, "#.#") + " bars\n" +  "Avg OS len: " + str.tostring(agent.numOS > 0 ? agent.sumOSLength / agent.numOS : 0.0, "#.##") + "%\n" +  "Mode:       " + (agent.mode == 1 ? "UP" : "DOWN")
                    if na(agent.predOSLabel)
                        agent.predOSLabel := label.new(predOSBar, nextOSPx, predOSText, color=color_os, textcolor=color.white, style=label.style_label_left, size=lblSize, tooltip=predOSTip)
                    else
                        label.set_xy(agent.predOSLabel, predOSBar, nextOSPx)
                        label.set_text(agent.predOSLabel, predOSText)
                        label.set_color(agent.predOSLabel, color_os)
                        label.set_size(agent.predOSLabel, lblSize)
                        label.set_tooltip(agent.predOSLabel, predOSTip)

        else if isOS
            agent.lastOSPrice := eventPrice
            agent.lastOSTime := eventTime
            if canDraw
                if na(agent.currentOSLine)
                    agent.currentOSLine := line.new(agent.lastDCTime, agent.lastDCPrice, eventTime, eventPrice, style=line.style_dashed, color=lineColor, xloc=xloc.bar_time)
                else
                    line.set_x2(agent.currentOSLine, eventTime)
                    line.set_y2(agent.currentOSLine, eventPrice)

                // --- OS segment label (reused) with tooltip ---
                midTime = int(math.avg(agent.lastDCTime, eventTime))
                midPrice = math.avg(agent.lastDCPrice, eventPrice)
                osText = "OS " + (agent.mode == 1 ? "Up" : "Down") + (showText ? "\n" + str.tostring(midPrice, format.mintick) : "")
                osLenPct = not na(agent.lastOSLength) ? agent.lastOSLength : (agent.lastDCPrice != 0 ? math.abs((eventPrice / agent.lastDCPrice - 1.0) * 100.0) : na)
                osTip = "OS SEGMENT\n" + "Direction: " + (agent.mode == 1 ? "Up" : "Down") + "\n" +  "From DC:   " + str.tostring(agent.lastDCPrice, format.mintick) + "\n"   +"To OS:     " + str.tostring(eventPrice, format.mintick) + "\n" +"Length:    " + (na(osLenPct) ? "—" : str.tostring(osLenPct, "#.##") + "%") + "\n" + "Start:     " + formatTime(agent.lastDCTime) + "\n" +  "End:       " + formatTime(eventTime) + "\n" +"OS count:  " + str.tostring(agent.numOS)
                if na(agent.osLabel)
                    agent.osLabel := label.new(midTime, midPrice, osText, color=lineColor, textcolor=color.white, style=label.style_label_left, xloc=xloc.bar_time, size=lblSize, tooltip=osTip)
                else
                    label.set_xy(agent.osLabel, midTime, midPrice)
                    label.set_text(agent.osLabel, osText)
                    label.set_color(agent.osLabel, lineColor)
                    label.set_size(agent.osLabel, lblSize)
                    label.set_tooltip(agent.osLabel, osTip)

        agent.p_h := new_p_h
        agent.p_l := new_p_l

seedAgent(Agent a) =>
    a.p_h := close
    a.p_l := close
    a.mode := 1
    a.lastDCPrice := close
    a.lastDCTime := time
    a.lastOSPrice := na
    a.lastOSTime := na
    a.currentOSLine := na
    a.isFirstEvent := true
    a.totalEvents := 0
    a.numOS := 0
    a.numDC := 0
    a.sumOSLength := 0.0
    a.lastOSLength := na
    a.sumTimeOS := 0.0
    a.countTimeOS := 0
    a.lastTimeOS := na
    a.sumTimeDC := 0.0
    a.countTimeDC := 0
    a.lastTimeDC := na
    a.lastEventPrice := close
    a.lastEventBarIndex := bar_index
    a.lastEventType := na
    a.osSegmentStarted := false
    a.lastDCBar := bar_index
    a.lastOSBarIndex := na
    a.predDCLine := na
    a.predOSLine := na
    a.avgTimeDC := na
    a.avgTimeOS := na
    a.barsSinceLastClean := 0
    a.justDC := false
    a.justOS := false
    a.dcLabel := na
    a.osLabel := na
    a.predDCLabel := na
    a.predOSLabel := na

color agent1Color = #00FFFF
color agent2Color = #FFA500
color agent3Color = #32CD32
color agent4Color = #FF00FF
color agent5Color = #808080

gPerf = "Performance"
drawLimit = input.int(200, "Max Bars to Draw", minval=50, maxval=1000, group=gPerf)
enableDrawings = input.bool(true, "Enable Chart Drawings", group=gPerf)
showLineText = input.bool(true, "Show text on lines", group=gPerf)

gA1 = "Agent 1"
enableAgent1 = input.bool(true, "Enable Agent 1", group=gA1)
delta1 = input.float(0.5, "Threshold 1 (%)", minval=0.0, group=gA1) / 100.0
dcColor1 = input.color(agent1Color, "DC Color Agent 1", group=gA1)
osColor1 = input.color(agent1Color, "OS Color Agent 1", group=gA1)

gA2 = "Agent 2"
enableAgent2 = input.bool(false, "Enable Agent 2", group=gA2)
delta2 = input.float(1.0, "Threshold 2 (%)", minval=0.0, group=gA2) / 100.0
dcColor2 = input.color(agent2Color, "DC Color Agent 2", group=gA2)
osColor2 = input.color(agent2Color, "OS Color Agent 2", group=gA2)

gA3 = "Agent 3"
enableAgent3 = input.bool(false, "Enable Agent 3", group=gA3)
delta3 = input.float(2.0, "Threshold 3 (%)", minval=0.0, group=gA3) / 100.0
dcColor3 = input.color(agent3Color, "DC Color Agent 3", group=gA3)
osColor3 = input.color(agent3Color, "OS Color Agent 3", group=gA3)

gA4 = "Agent 4"
enableAgent4 = input.bool(false, "Enable Agent 4", group=gA4)
delta4 = input.float(5.0, "Threshold 4 (%)", minval=0.0, group=gA4) / 100.0
dcColor4 = input.color(agent4Color, "DC Color Agent 4", group=gA4)
osColor4 = input.color(agent4Color, "OS Color Agent 4", group=gA4)

gA5 = "Agent 5"
enableAgent5 = input.bool(false, "Enable Agent 5", group=gA5)
delta5 = input.float(10.0, "Threshold 5 (%)", minval=0.0, group=gA5) / 100.0
dcColor5 = input.color(agent5Color, "DC Color Agent 5", group=gA5)
osColor5 = input.color(agent5Color, "OS Color Agent 5", group=gA5)

gFilt = "Regime filter (15m stocks)"
filterMode = input.string("Trend only", "Action filter", options=["Off (map only)", "Trend only", "Range only"], group=gFilt)
useRth = input.bool(true, "Regular hours only (0930-1600)", group=gFilt)
needVol = input.bool(true, "Require volume spike", group=gFilt)
emaFastLen = input.int(50, "Fast EMA", minval=2, group=gFilt)
emaSlowLen = input.int(200, "Slow EMA", minval=5, group=gFilt)
adxLen = input.int(14, "ADX length", minval=2, group=gFilt)
adxTrendMin = input.float(20.0, "ADX trend min", minval=1.0, group=gFilt)
adxRangeMax = input.float(16.0, "ADX range max", minval=1.0, group=gFilt)
volLen = input.int(20, "Volume SMA", minval=2, group=gFilt)
volMult = input.float(1.30, "Volume spike mult", minval=1.0, step=0.05, group=gFilt)
signalAgent = input.int(1, "Signal agent (1-5)", minval=1, maxval=5, group=gFilt)
confirmedOnly = input.bool(true, "Signals on bar close only", group=gFilt)
showSignals = input.bool(true, "Show filtered LONG/SHORT marks", group=gFilt)

gStyle = "Style"
dash_loc = input.string("Bottom Left", "Dashboard Location", options=["Top Right", "Top Center", "Top Left", "Bottom Left", "Bottom Center", "Bottom Right", "Middle Left", "Middle Center", "Middle Right"], group=gStyle)
text_size = input.string("Small", "Dashboard Size", options=["Tiny", "Small", "Normal", "Large"], group=gStyle)
labelSize = input.string("Tiny", "Line Label Size", options=["Tiny", "Small", "Normal", "Large"], group=gStyle)



var agent1 = Agent.new()
var agent2 = Agent.new()
var agent3 = Agent.new()
var agent4 = Agent.new()
var agent5 = Agent.new()
if na(agent1.p_h)
    seedAgent(agent1)
if na(agent2.p_h)
    seedAgent(agent2)
if na(agent3.p_h)
    seedAgent(agent3)
if na(agent4.p_h)
    seedAgent(agent4)
if na(agent5.p_h)
    seedAgent(agent5)

lblSz = sizeFromString(labelSize)

lim = enableDrawings ? drawLimit : 0
if enableAgent1
    updateAgent(agent1, delta1, dcColor1, osColor1, lim, showLineText, lblSz)
if enableAgent2
    updateAgent(agent2, delta2, dcColor2, osColor2, lim, showLineText, lblSz)
if enableAgent3
    updateAgent(agent3, delta3, dcColor3, osColor3, lim, showLineText, lblSz)
if enableAgent4
    updateAgent(agent4, delta4, dcColor4, osColor4, lim, showLineText, lblSz)
if enableAgent5
    updateAgent(agent5, delta5, dcColor5, osColor5, lim, showLineText, lblSz)

inSession = not useRth or not na(time(timeframe.period, "0930-1600"))
emaF = ta.ema(close, emaFastLen)
emaS = ta.ema(close, emaSlowLen)
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
volSma = ta.sma(volume, volLen)
volOk = not needVol or (not na(volume) and not na(volSma) and volume > volSma * volMult)
trendUp = emaF > emaS and adx >= adxTrendMin
trendDn = emaF < emaS and adx >= adxTrendMin
inRange = adx <= adxRangeMax
bodyRatio = math.abs(close - open) / math.max(high - low, syminfo.mintick)
inChop = not trendUp and not trendDn and ta.sma(bodyRatio, 20) < 0.35
regimeName = trendUp ? "Trend Up" : trendDn ? "Trend Down" : inChop ? "Chop" : inRange ? "Range" : "Neutral"

sig = signalAgent == 1 ? agent1 : signalAgent == 2 ? agent2 : signalAgent == 3 ? agent3 : signalAgent == 4 ? agent4 : agent5
sigOn = signalAgent == 1 ? enableAgent1 : signalAgent == 2 ? enableAgent2 : signalAgent == 3 ? enableAgent3 : signalAgent == 4 ? enableAgent4 : enableAgent5

barOk = not confirmedOnly or barstate.isconfirmed
baseGate = sigOn and inSession and volOk and barOk and not inChop

osWithUp = sig.justOS and sig.mode == 1
osWithDn = sig.justOS and sig.mode == -1
dcToUp = sig.justDC and sig.mode == 1
dcToDn = sig.justDC and sig.mode == -1

trendLong = baseGate and filterMode == "Trend only" and trendUp and (osWithUp or dcToUp)
trendShort = baseGate and filterMode == "Trend only" and trendDn and (osWithDn or dcToDn)
rangeLong = baseGate and filterMode == "Range only" and inRange and dcToUp
rangeShort = baseGate and filterMode == "Range only" and inRange and dcToDn
mapLong = baseGate and filterMode == "Off (map only)" and (osWithUp or dcToUp)
mapShort = baseGate and filterMode == "Off (map only)" and (osWithDn or dcToDn)

longSig = trendLong or rangeLong or mapLong
shortSig = trendShort or rangeShort or mapShort

plot(emaF, "EMA Fast", color.new(color.teal, 0), 1)
plot(emaS, "EMA Slow", color.new(color.orange, 0), 2)
plotshape(showSignals and longSig, "Filtered LONG", shape.triangleup, location.belowbar, color.teal, size=size.small)
plotshape(showSignals and shortSig, "Filtered SHORT", shape.triangledown, location.abovebar, color.red, size=size.small)

if showSignals and longSig
    label.new(bar_index, low, "LONG\n" + filterMode, style=label.style_label_up, color=color.teal, textcolor=color.white, size=size.tiny)
if showSignals and shortSig
    label.new(bar_index, high, "SHORT\n" + filterMode, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)

statsTable_position = dash_loc == "Top Left" ? position.top_left : dash_loc == "Bottom Left" ? position.bottom_left : dash_loc == "Bottom Center" ? position.bottom_center : dash_loc == "Bottom Right" ? position.bottom_right : dash_loc == "Top Right" ? position.top_right : dash_loc == "Top Center" ? position.top_center : dash_loc == "Middle Left" ? position.middle_left : dash_loc == "Middle Center" ? position.middle_center : position.middle_right
table_text_size = text_size == "Tiny" ? size.tiny : text_size == "Small" ? size.small : text_size == "Normal" ? size.normal : size.large
var table statsTable = table.new(statsTable_position, 6, 18, bgcolor=color.new(color.black, 90), border_width=2, frame_color=color.gray, frame_width=1)

formatValue(value) => na(value) ? "—" : str.tostring(math.round(value * 100.0) / 100.0)
formatPrice(value) => na(value) ? "—" : str.tostring(math.round(value * 1000.0) / 1000.0)
getDistColor(dist, thresholdPct) => na(dist) ? color.gray : dist < thresholdPct ? color.red : dist < thresholdPct * 2.0 ? color.orange : color.white
nextDcPx(Agent a, float dlt, bool on) => on ? (a.mode == 1 ? a.p_h * (1.0 - dlt) : a.p_l * (1.0 + dlt)) : na

sug = not inSession ? "WAIT  RTH" : inChop ? "WAIT  Chop" : not volOk ? "WAIT  Volume" : longSig ? "LOOK LONG" : shortSig ? "LOOK SHORT" : filterMode == "Trend only" and trendUp ? "WAIT  Trend up, no event" : filterMode == "Trend only" and trendDn ? "WAIT  Trend down, no event" : filterMode == "Range only" and inRange ? "WAIT  Range, no DC" : "WAIT"

sugCol = str.startswith(sug, "LOOK LONG") ? color.lime : str.startswith(sug, "LOOK SHORT") ? color.red : color.orange

if barstate.islast
    nextDC1 = nextDcPx(agent1, delta1, enableAgent1)
    nextDC2 = nextDcPx(agent2, delta2, enableAgent2)
    nextDC3 = nextDcPx(agent3, delta3, enableAgent3)
    nextDC4 = nextDcPx(agent4, delta4, enableAgent4)
    nextDC5 = nextDcPx(agent5, delta5, enableAgent5)
    distDC1 = enableAgent1 and not na(nextDC1) ? math.abs((nextDC1 / close - 1.0) * 100.0) : na
    distDC2 = enableAgent2 and not na(nextDC2) ? math.abs((nextDC2 / close - 1.0) * 100.0) : na
    distDC3 = enableAgent3 and not na(nextDC3) ? math.abs((nextDC3 / close - 1.0) * 100.0) : na
    distDC4 = enableAgent4 and not na(nextDC4) ? math.abs((nextDC4 / close - 1.0) * 100.0) : na
    distDC5 = enableAgent5 and not na(nextDC5) ? math.abs((nextDC5 / close - 1.0) * 100.0) : na

    row = 0
    table.cell(statsTable, 0, row, "DC/OS + FILTER", text_color=color.white, text_size=size.small)
    table.cell(statsTable, 1, row, regimeName, text_color=trendUp ? color.lime : trendDn ? color.red : color.orange, text_size=size.small)
    table.merge_cells(statsTable, 1, row, 5, row)
    row += 1
    table.cell(statsTable, 0, row, "Statistic", text_color=color.white, text_size=table_text_size)
    table.cell(statsTable, 1, row, "A1", text_color=enableAgent1 ? agent1Color : color.gray, text_size=table_text_size)
    table.cell(statsTable, 2, row, "A2", text_color=enableAgent2 ? agent2Color : color.gray, text_size=table_text_size)
    table.cell(statsTable, 3, row, "A3", text_color=enableAgent3 ? agent3Color : color.gray, text_size=table_text_size)
    table.cell(statsTable, 4, row, "A4", text_color=enableAgent4 ? agent4Color : color.gray, text_size=table_text_size)
    table.cell(statsTable, 5, row, "A5", text_color=enableAgent5 ? agent5Color : color.gray, text_size=table_text_size)
    row += 1
    table.cell(statsTable, 0, row, "Mode", text_color=color.white, text_size=table_text_size)
    table.cell(statsTable, 1, row, enableAgent1 ? (agent1.mode == 1 ? "UP" : "DOWN") : "—", text_color=enableAgent1 ? (agent1.mode == 1 ? color.lime : color.red) : color.gray)
    table.cell(statsTable, 2, row, enableAgent2 ? (agent2.mode == 1 ? "UP" : "DOWN") : "—", text_color=enableAgent2 ? (agent2.mode == 1 ? color.lime : color.red) : color.gray)
    table.cell(statsTable, 3, row, enableAgent3 ? (agent3.mode == 1 ? "UP" : "DOWN") : "—", text_color=enableAgent3 ? (agent3.mode == 1 ? color.lime : color.red) : color.gray)
    table.cell(statsTable, 4, row, enableAgent4 ? (agent4.mode == 1 ? "UP" : "DOWN") : "—", text_color=enableAgent4 ? (agent4.mode == 1 ? color.lime : color.red) : color.gray)
    table.cell(statsTable, 5, row, enableAgent5 ? (agent5.mode == 1 ? "UP" : "DOWN") : "—", text_color=enableAgent5 ? (agent5.mode == 1 ? color.lime : color.red) : color.gray)
    row += 1
    table.cell(statsTable, 0, row, "Events", text_color=color.white, text_size=table_text_size)
    table.cell(statsTable, 1, row, enableAgent1 ? formatValue(agent1.totalEvents) : "—", text_color=enableAgent1 ? agent1Color : color.gray)
    table.cell(statsTable, 2, row, enableAgent2 ? formatValue(agent2.totalEvents) : "—", text_color=enableAgent2 ? agent2Color : color.gray)
    table.cell(statsTable, 3, row, enableAgent3 ? formatValue(agent3.totalEvents) : "—", text_color=enableAgent3 ? agent3Color : color.gray)
    table.cell(statsTable, 4, row, enableAgent4 ? formatValue(agent4.totalEvents) : "—", text_color=enableAgent4 ? agent4Color : color.gray)
    table.cell(statsTable, 5, row, enableAgent5 ? formatValue(agent5.totalEvents) : "—", text_color=enableAgent5 ? agent5Color : color.gray)
    row += 1
    table.cell(statsTable, 0, row, "Last DC", text_color=color.white, text_size=table_text_size)
    table.cell(statsTable, 1, row, enableAgent1 ? formatPrice(agent1.lastDCPrice) : "—", text_color=enableAgent1 ? agent1Color : color.gray)
    table.cell(statsTable, 2, row, enableAgent2 ? formatPrice(agent2.lastDCPrice) : "—", text_color=enableAgent2 ? agent2Color : color.gray)
    table.cell(statsTable, 3, row, enableAgent3 ? formatPrice(agent3.lastDCPrice) : "—", text_color=enableAgent3 ? agent3Color : color.gray)
    table.cell(statsTable, 4, row, enableAgent4 ? formatPrice(agent4.lastDCPrice) : "—", text_color=enableAgent4 ? agent4Color : color.gray)
    table.cell(statsTable, 5, row, enableAgent5 ? formatPrice(agent5.lastDCPrice) : "—", text_color=enableAgent5 ? agent5Color : color.gray)
    row += 1
    table.cell(statsTable, 0, row, "Next DC", text_color=color.white, text_size=table_text_size)
    table.cell(statsTable, 1, row, enableAgent1 ? formatPrice(nextDC1) : "—", text_color=enableAgent1 ? color.orange : color.gray)
    table.cell(statsTable, 2, row, enableAgent2 ? formatPrice(nextDC2) : "—", text_color=enableAgent2 ? color.orange : color.gray)
    table.cell(statsTable, 3, row, enableAgent3 ? formatPrice(nextDC3) : "—", text_color=enableAgent3 ? color.orange : color.gray)
    table.cell(statsTable, 4, row, enableAgent4 ? formatPrice(nextDC4) : "—", text_color=enableAgent4 ? color.orange : color.gray)
    table.cell(statsTable, 5, row, enableAgent5 ? formatPrice(nextDC5) : "—", text_color=enableAgent5 ? color.orange : color.gray)
    row += 1
    table.cell(statsTable, 0, row, "Dist DC %", text_color=color.white, text_size=table_text_size)
    table.cell(statsTable, 1, row, enableAgent1 and not na(distDC1) ? formatValue(distDC1) + "%" : "—", text_color=enableAgent1 ? getDistColor(distDC1, delta1 * 100.0) : color.gray)
    table.cell(statsTable, 2, row, enableAgent2 and not na(distDC2) ? formatValue(distDC2) + "%" : "—", text_color=enableAgent2 ? getDistColor(distDC2, delta2 * 100.0) : color.gray)
    table.cell(statsTable, 3, row, enableAgent3 and not na(distDC3) ? formatValue(distDC3) + "%" : "—", text_color=enableAgent3 ? getDistColor(distDC3, delta3 * 100.0) : color.gray)
    table.cell(statsTable, 4, row, enableAgent4 and not na(distDC4) ? formatValue(distDC4) + "%" : "—", text_color=enableAgent4 ? getDistColor(distDC4, delta4 * 100.0) : color.gray)
    table.cell(statsTable, 5, row, enableAgent5 and not na(distDC5) ? formatValue(distDC5) + "%" : "—", text_color=enableAgent5 ? getDistColor(distDC5, delta5 * 100.0) : color.gray)
    row += 1
    table.cell(statsTable, 0, row, "Avg DC bars", text_color=color.white, text_size=table_text_size)
    table.cell(statsTable, 1, row, enableAgent1 ? formatValue(agent1.avgTimeDC) : "—", text_color=enableAgent1 ? agent1Color : color.gray)
    table.cell(statsTable, 2, row, enableAgent2 ? formatValue(agent2.avgTimeDC) : "—", text_color=enableAgent2 ? agent2Color : color.gray)
    table.cell(statsTable, 3, row, enableAgent3 ? formatValue(agent3.avgTimeDC) : "—", text_color=enableAgent3 ? agent3Color : color.gray)
    table.cell(statsTable, 4, row, enableAgent4 ? formatValue(agent4.avgTimeDC) : "—", text_color=enableAgent4 ? agent4Color : color.gray)
    table.cell(statsTable, 5, row, enableAgent5 ? formatValue(agent5.avgTimeDC) : "—", text_color=enableAgent5 ? agent5Color : color.gray)
    row += 1
    table.cell(statsTable, 0, row, "SUGGESTION", text_color=color.white, bgcolor=sugCol, text_size=table_text_size)
    table.cell(statsTable, 1, row, sug, text_color=color.white, bgcolor=sugCol, text_size=table_text_size)
    table.merge_cells(statsTable, 1, row, 5, row)

alertcondition(longSig, "DC/OS Filtered LONG", "Filtered LONG")
alertcondition(shortSig, "DC/OS Filtered SHORT", "Filtered SHORT")
if longSig
    alert("DC/OS LONG " + syminfo.ticker + " " + str.tostring(close), alert.freq_once_per_bar_close)
if shortSig
    alert("DC/OS SHORT " + syminfo.ticker + " " + str.tostring(close), alert.freq_once_per_bar_close)
````
