# The Silver Lining

- url: https://www.tradingview.com/script/8aX4iShh-The-Silver-Lining/
- type: indicator
- pine_id: PUB;2d9a3aa1c37144c3a7697c48adb40afe
- version: 1.0

## Description

A silver chart tells half of a story. It shows what silver did, but not whether capital inside the precious-metals complex was reaching for silver's torque or retreating into gold's safety while silver happened to rise. The same rally can be a vote of confidence or a drift against the current, and the price chart prints both in the same white candles.

Gold and silver usually move together, though they rarely carry the same meaning. Silver shares gold's role as reserve and monetary insurance but adds industrial demand, a thinner market and a higher beta, so it amplifies the prevailing mood of the complex. A silver gain against gold means the metals trade is accepting more cyclical risk, while a gold gain against silver means the tape is choosing caution.

The Silver Lining reads that preference directly. It measures the Gold/Silver Ratio against its own baseline, converts the distance into a centered edge, and names the result as one of six regimes. Its working premise is short: posture precedes price. It began as one trader's answer to a narrow question, which is when silver's volatility buys the most of gold's stability. The sections below explain the calculation, the pane's three layers and an hourly reading of spot silver (the chart above), then return to that question.

[b]A Ratio Turned Into a Verdict
[/b]
The indicator divides spot gold by spot silver, using OANDA's XAUUSD and XAGUSD feeds by default, because spot prices trade nearly around the clock and carry no futures roll. It compares that ratio to a 34-bar baseline, which is volume-weighted by default and falls back to an EMA whenever a feed reports no volume. The edge is the percentage distance between the ratio and its baseline, signed so that positive values mean silver is gaining and negative values mean gold is gaining.

The edge is read categorically before it is read numerically. A neutral band around zero holds the pane in Equilibrium until the edge declares itself. Beyond the band, the edge reads Silver Lead or Gold Lead, and it reaches Extreme Silver or Extreme Gold when it crosses the extreme threshold, or when it crosses a strong threshold while the ratio also sits in its historical extreme. The default thresholds of 0.05, 0.25 and 0.75 percent are tuned for the hourly clock, where the edge typically swings within a few percent; daily and weekly readers should widen them, since every threshold is an input.

A second measurement keeps the edge honest. The ratio's 20th, 50th and 80th percentiles over the latest 89 bars locate it within its recent history. Below the 20th percentile, silver dominance is historically expressed; above the 80th, gold dominance is. A ratio at one of those extremes with the edge still inside the neutral band makes the pane read Conflict, because location and momentum have stopped telling the same story.

[b]Weather, Tape and Cockpit
[/b]
The background is regime weather. Teal belongs to silver leadership, amber to gold preference and purple to conflict, and the intensity of each field follows the strength of the claim. The background carries condition, and the edge line carries timing.

The zero line doubles as a regime rail, a strip of tape that can be read without studying the line above it. Diamonds mark the bars where the edge crosses zero, and purple diamonds mark exhaustion, when a regime remains in force while its velocity has turned against it. Checkpoint circles appear every 13 bars that a regime survives, so persistence can be counted at a glance.

The table compresses the reading into plain language: the regime, the edge, the percentile zone, the velocity, the regime's age in bars, a one-line read, the number of live feeds, and the active settings. A feed count below two means one metal failed to load, and every other row should then be demoted. Every underlying value also appears in the Data Window.

[b]Reading Silver Through the Ratio
[/b]
The chart above shows spot silver (XAGUSD) on the hourly clock across the first nine days of October, with the Silver Lining in the upper pane. Silver opened the month under a teal field, printed its 62.09 high on 2 October, and pressed back toward 62 on 5 October. The background turned amber late on 5 October. Silver's next push on 6 October stalled at a lower high with the edge pinned near zero, and the slide that followed carried price to the 58.50 low of 8 October as the edge sank past −2 percent.

Teal returned late on 8 October, after the low rather than at it, and carried silver's recovery toward 61 on 9 October. By the final bar the table read Extreme Silver at an edge of 0.758 percent, one bar old, with velocity Gold reclaiming and a read of Silver lead, tiring. The zone row read Gold half, meaning the ratio still sat above the middle of its recent range. Together those rows describe a silver recovery from a gold-heavy position, extreme by a hair and already losing speed.

A skeptic will object that the ratio divides by silver, so a silver rally lowers it almost by arithmetic. Gold preference took hold late on 5 October while silver still traded near its highs, and the 6 October lower high arrived with no silver edge behind it. Preference moved first, and price followed; silver does not trend cleanly, but it pulses, and the pane shows which way the pulse is leaning.

[b]Where It Fits in a Trading Process
[/b]
The Silver Lining is a posture filter, not a signal engine, and it leaves entries and exits to the trader's own structure and confirmation tools. The reading order is simple: the table names the regime, the background shows whether it is fresh or established, the rail shows continuity and fatigue, and only then does the price chart enter. The guiding rule is to trade the ratio, not the narrative.

The daily chart sets structural posture, the hourly chart is the spine of execution, and the 15-minute chart is its breath, which detects early flow without overriding the slower clocks. The regimes carry no directional bias; gold preference does not forbid a silver long, and silver leadership does not forbid a short. Each regime simply says which side of a trade swims with the current.

The skeptic's objection disappears entirely on a chart the ratio never touches. The indicator reads its two spot feeds whatever symbol sits beneath it, so it can be loaded unchanged onto a mining stock. Primary silver producers such as First Majestic, Pan American Silver, Hecla and Coeur, or the silver-miner ETFs SIL and SILJ, are natural first tests. Senior gold producers such as Newmont and Agnico Eagle, or royalty companies such as Franco-Nevada and Wheaton Precious Metals, make the useful contrast.

On those charts the miner's price never enters the calculation, so any agreement between the regimes and the stock's swings is evidence rather than arithmetic. A high-beta silver miner tends to need silver leadership before its breakouts hold, while a gold royalty name can thrive under gold preference. The exceptions teach the most, since a silver miner rising under gold preference may be under quiet accumulation. On a regular-hours stock the ratio keeps its own clock, so the pane can step at the open to reflect a regime change that occurred overnight.

[b]A Price Before It Is a Signal
[/b]
The ratio is an exchange rate. A reading of 80 means one ounce of gold costs 80 ounces of silver, and every regime describes the direction in which that price is moving. The zone row says where the price stands within its recent history. Near the 20th percentile, an ounce of gold costs fewer ounces of silver than it has across most of the window, which is arithmetic rather than a forecast.

The instrument was designed around a practice its author follows: earning in silver's volatility and keeping in gold's stability. Silver regimes describe the stretches in which silver's torque does the earning, and a compressed ratio describes the moments in which silver's earnings command the most gold. The practice keys its exits to posture rather than to price peaks, so an extended silver regime that has begun to tire, with the ratio pressed into its lower zone, marks the point at which silver's advantage is most fully priced.

The pane cannot say what anyone should do at that point, and it does not try. It reports where the exchange rate stands and which way the preference is leaning, and the decision belongs to the reader. Nothing in this description or in the script is financial advice, and past behavior of the ratio does not predict future prices.

That reframing changes what the earlier sections described. The weather, the tape and the cockpit looked like a regime indicator, and they are one; they are also a price list for converting one temperament of metal into the other. Every teal stretch shows silver earning, every compressed ratio shows gold discounted in the currency silver pays, and the trader alone decides which side of the exchange to take.

## Source Code

````pine
// Open Source | Designed by Adrian Dyer for "The Leading Indicator"

//@version=6
indicator("The Silver Lining", shorttitle = "GSR", overlay = false, max_lines_count = 500, dynamic_requests = true)

string author = "The Leading Indicator"

// === DATA ===
grpD = "Data"
goldSymbol = input.string("OANDA:XAUUSD", "Gold Symbol", group = grpD)
silverSymbol = input.string("OANDA:XAGUSD", "Silver Symbol", group = grpD)
sourceTfInput = input.timeframe("", "Source Timeframe (blank = chart)", group = grpD)
length = input.int(34, "Baseline Length", minval = 1, group = grpD)
maType = input.string("VWMA", "Baseline Type", options = ["EMA", "VWMA"], group = grpD)
bandLength = input.int(89, "Percentile Length", minval = 20, group = grpD)

// === REGIME ENGINE ===
grpE = "Regime Engine"
neutralBand = input.float(0.05, "Neutral Band (%)", minval = 0.0, step = 0.01, group = grpE)
strongEdge = input.float(0.25, "Strong Edge (%)", minval = 0.01, step = 0.01, group = grpE)
extremeEdge = input.float(0.75, "Extreme Edge (%)", minval = 0.01, step = 0.01, group = grpE)
velocityLength = input.int(5, "Velocity Length", minval = 1, group = grpE)
checkpointEvery = input.int(13, "Checkpoint Interval", minval = 2, group = grpE)

// === DISPLAY ===
grpV = "Display"
showScore = input.bool(true, "Show Silver/Gold Edge", group = grpV)
showFill = input.bool(true, "Show Edge Fill", group = grpV)
showZones = input.bool(true, "Show Background Regime", group = grpV)
showPercentileGuides = input.bool(true, "Show Percentile Guide Levels", group = grpV)
weakZoneTransp = input.int(60, "Weak Zone Transparency", minval = 0, maxval = 100, group = grpV)
strongZoneTransp = input.int(75, "Strong Zone Transparency", minval = 0, maxval = 100, group = grpV)
extremeZoneTransp = input.int(85, "Extreme Zone Transparency", minval = 0, maxval = 100, group = grpV)
fillTransp = input.int(55, "Fill Transparency", minval = 0, maxval = 100, group = grpV)

// === ZERO-LINE MARKERS ===
grpM = "Zero-Line Markers"
showRegimeRail = input.bool(true, "Show zero-line regime rail", group = grpM)
showFlipDiamonds = input.bool(true, "Show regime flip diamonds", group = grpM)
showExhaustionMarks = input.bool(true, "Show exhaustion diamonds", group = grpM)
showCheckpointCircles = input.bool(true, "Show checkpoint circles", group = grpM)
markerTransp = input.int(80, "Marker Transparency", minval = 0, maxval = 100, group = grpM)

// === TABLE ===
grpT = "Table"
showTable = input.bool(true, "Show Table", group = grpT)
tablePosInput = input.string("Top Right", "Table Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpT)
tableSizeInput = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpT)
showSettingsRow = input.bool(true, "Show Settings Row", group = grpT)
tableBgInput = input.color(color.new(#2A2E39, 18), "Background", group = grpT)
tableLabelInput = input.color(#FAF3B2, "Label Color", group = grpT)
tableTextInput = input.color(#E6E6E6, "Body Text", group = grpT)
tableBorderInput = input.color(color.new(#FAF3B2, 70), "Border Color", group = grpT)

// === COLORS ===
grpC = "Colors"
silverColor = input.color(#7ADFEA, "Silver Regime", group = grpC)
goldColor = input.color(#FBBF24, "Gold Regime", group = grpC)
equilibriumColor = input.color(#FAF3B2, "Equilibrium", group = grpC)
conflictColor = input.color(#7E3FA1, "Conflict", group = grpC)
scoreColor = input.color(#E6E6E6, "Edge Line", group = grpC)
baselineColor = input.color(color.new(#E6E6E6, 35), "Zero Line", group = grpC)

// === HELPERS ===
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Top Center" ? position.top_center : s == "Top Right" ? position.top_right : s == "Middle Left" ? position.middle_left : s == "Middle Center" ? position.middle_center : s == "Middle Right" ? position.middle_right : s == "Bottom Center" ? position.bottom_center : s == "Bottom Right" ? position.bottom_right : position.bottom_left
f_size(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal
f_fmt(float x) => na(x) ? "--" : str.tostring(x, "#.###")
f_cell(table t, int c, int r, string txt, color tc, color bg) => table.cell(t, c, r, txt, text_color = tc, bgcolor = bg, text_size = f_size(tableSizeInput))
f_stateName(int state, bool conflict) => conflict ? "Conflict" : state == 2 ? "Extreme Silver" : state == 1 ? "Silver Lead" : state == -2 ? "Extreme Gold" : state == -1 ? "Gold Lead" : "Equilibrium"
f_strengthName(int state, bool conflict) => conflict ? "Mixed" : math.abs(state) == 2 ? "Extreme" : math.abs(state) == 1 ? "Firm" : "Weak"
f_stateColor(int state, bool conflict) => conflict ? conflictColor : state > 0 ? silverColor : state < 0 ? goldColor : equilibriumColor

// === DATA FEEDS ===
string sourceTf = sourceTfInput == "" ? timeframe.period : sourceTfInput
float gold = request.security(goldSymbol, sourceTf, close)
float silver = request.security(silverSymbol, sourceTf, close)
float goldMA = request.security(goldSymbol, sourceTf, maType == "EMA" ? ta.ema(close, length) : nz(ta.vwma(close, length), ta.ema(close, length)))
float silverMA = request.security(silverSymbol, sourceTf, maType == "EMA" ? ta.ema(close, length) : nz(ta.vwma(close, length), ta.ema(close, length)))
int liveFeeds = (na(gold) ? 0 : 1) + (na(silver) ? 0 : 1)

float gsr = silver != 0.0 ? gold / silver : na
float gsrMA = silverMA != 0.0 ? goldMA / silverMA : na
float score = gsrMA != 0.0 ? (1.0 - gsr / gsrMA) * 100.0 : na
float scoreVelocity = ta.ema(score - nz(score[1], score), velocityLength)
float p20Raw = ta.percentile_nearest_rank(gsr, bandLength, 20)
float p50Raw = ta.percentile_nearest_rank(gsr, bandLength, 50)
float p80Raw = ta.percentile_nearest_rank(gsr, bandLength, 80)
float p20 = ta.ema(p20Raw, 5)
float p50 = ta.ema(p50Raw, 5)
float p80 = ta.ema(p80Raw, 5)

bool silverPercentile = gsr <= p20
bool goldPercentile = gsr >= p80
bool conflictState = math.abs(score) <= neutralBand and (silverPercentile or goldPercentile)
int regimeCode = conflictState ? 0 : score >= extremeEdge or (score >= strongEdge and silverPercentile) ? 2 : score >= neutralBand ? 1 : score <= -extremeEdge or (score <= -strongEdge and goldPercentile) ? -2 : score <= -neutralBand ? -1 : 0
bool stateChanged = na(regimeCode[1]) ? true : regimeCode != regimeCode[1] or conflictState != conflictState[1]
var int stateAge = 0
stateAge := stateChanged ? 1 : stateAge + 1
bool checkpoint = stateAge > 0 and stateAge % checkpointEvery == 0
bool scoreCross = ta.cross(score, 0.0)
bool exhaustion = (regimeCode > 0 and scoreVelocity < 0.0 and (math.abs(score) >= strongEdge or silverPercentile)) or (regimeCode < 0 and scoreVelocity > 0.0 and (math.abs(score) >= strongEdge or goldPercentile))

string zoneRead = gsr <= p20 ? "Silver p20" : gsr >= p80 ? "Gold p80" : gsr < p50 ? "Silver half" : gsr > p50 ? "Gold half" : "Median"
string velocityRead = scoreVelocity > 0.0 ? "Silver accelerating" : scoreVelocity < 0.0 ? "Gold reclaiming" : "Flat"
string readText = conflictState ? "Ratio extreme, baseline undecided" : regimeCode > 0 ? (exhaustion ? "Silver lead, tiring" : "Silver gaining on gold") : regimeCode < 0 ? (exhaustion ? "Gold lead, tiring" : "Gold preference dominant") : "No clean metal preference"
color stateColor = f_stateColor(regimeCode, conflictState)

// === PLOTS ===
zeroPlot = plot(0.0, title = "Zero", color = baselineColor, linewidth = 1)
scorePlot = plot(showScore ? score : na, title = "Silver / Gold Edge", color = scoreColor, linewidth = 2)
fill(scorePlot, zeroPlot, color = showFill and score > 0.0 ? color.new(silverColor, fillTransp) : na, title = "Silver Edge Fill")
fill(scorePlot, zeroPlot, color = showFill and score < 0.0 ? color.new(goldColor, fillTransp) : na, title = "Gold Edge Fill")
hline(0.0, "Baseline", color = color.new(color.gray, 35), linestyle = hline.style_dotted)
hline(strongEdge, "Strong Silver Edge", color = color.new(silverColor, 40), linestyle = hline.style_dashed)
hline(-strongEdge, "Strong Gold Edge", color = color.new(goldColor, 40), linestyle = hline.style_dashed)
hline(extremeEdge, "Extreme Silver Edge", color = color.new(silverColor, 20), linestyle = hline.style_dotted)
hline(-extremeEdge, "Extreme Gold Edge", color = color.new(goldColor, 20), linestyle = hline.style_dotted)
plot(showPercentileGuides and silverPercentile ? score : na, title = "Silver Percentile Zone", style = plot.style_circles, linewidth = 2, color = color.new(silverColor, 20))
plot(showPercentileGuides and goldPercentile ? score : na, title = "Gold Percentile Zone", style = plot.style_circles, linewidth = 2, color = color.new(goldColor, 20))
plot(gsr, title = "Gold/Silver Ratio", color = color.new(goldColor, 100), display = display.data_window)
plot(gsrMA, title = "GSR Baseline", color = color.new(scoreColor, 100), display = display.data_window)
plot(p20, title = "20th Percentile", color = color.new(silverColor, 100), display = display.data_window)
plot(p50, title = "50th Percentile", color = color.new(equilibriumColor, 100), display = display.data_window)
plot(p80, title = "80th Percentile", color = color.new(goldColor, 100), display = display.data_window)
plot(regimeCode, title = "Silver Lining State Code", color = color.new(stateColor, 100), display = display.data_window)
plot(stateAge, title = "Silver Lining State Age", color = color.new(stateColor, 100), display = display.data_window)

color bgColor = na
if showZones
    int zoneTransp = math.abs(regimeCode) == 2 ? extremeZoneTransp : math.abs(regimeCode) == 1 ? strongZoneTransp : weakZoneTransp
    bgColor := conflictState ? color.new(conflictColor, strongZoneTransp) : regimeCode > 0 ? color.new(silverColor, zoneTransp) : regimeCode < 0 ? color.new(goldColor, zoneTransp) : na
bgcolor(bgColor, title = "Silver Lining Background Regime")

plotshape(showRegimeRail ? 0.0 : na, title = "Zero-Line Regime Rail", style = shape.square, location = location.absolute, color = color.new(stateColor, markerTransp), size = size.tiny)
plotshape(showFlipDiamonds and scoreCross ? 0.0 : na, title = "Regime Flip", style = shape.diamond, location = location.absolute, color = color.new(stateColor, math.max(markerTransp - 18, 0)), size = size.tiny)
plotshape(showExhaustionMarks and exhaustion ? 0.0 : na, title = "Exhaustion", style = shape.diamond, location = location.absolute, color = color.new(conflictColor, math.max(markerTransp - 12, 0)), size = size.tiny)
plot(showCheckpointCircles and checkpoint ? 0.0 : na, title = "State Checkpoint", style = plot.style_circles, linewidth = 3, color = color.new(stateColor, math.max(markerTransp - 20, 0)))

// === TABLE ===
var table dash = table.new(f_pos(tablePosInput), 2, 8, bgcolor = tableBgInput, frame_color = tableBorderInput, border_color = tableBorderInput, border_width = 1)
if showTable and barstate.islast
    table.clear(dash, 0, 0, 1, 7)
    f_cell(dash, 0, 0, "Regime", tableLabelInput, tableBgInput)
    f_cell(dash, 1, 0, f_stateName(regimeCode, conflictState), regimeCode == 0 and not conflictState ? color.black : color.white, color.new(stateColor, conflictState ? 55 : 35))
    f_cell(dash, 0, 1, "Edge", tableLabelInput, tableBgInput)
    f_cell(dash, 1, 1, f_fmt(score) + "%", tableTextInput, tableBgInput)
    f_cell(dash, 0, 2, "Zone", tableLabelInput, tableBgInput)
    f_cell(dash, 1, 2, zoneRead, tableTextInput, tableBgInput)
    f_cell(dash, 0, 3, "Velocity", tableLabelInput, tableBgInput)
    f_cell(dash, 1, 3, velocityRead, scoreVelocity >= 0.0 ? silverColor : goldColor, tableBgInput)
    f_cell(dash, 0, 4, "Age", tableLabelInput, tableBgInput)
    f_cell(dash, 1, 4, str.tostring(stateAge) + " bars", tableTextInput, tableBgInput)
    f_cell(dash, 0, 5, "Read", tableLabelInput, tableBgInput)
    f_cell(dash, 1, 5, readText, tableTextInput, tableBgInput)
    f_cell(dash, 0, 6, "Feeds", tableLabelInput, tableBgInput)
    f_cell(dash, 1, 6, str.tostring(liveFeeds) + "/2", liveFeeds == 2 ? tableTextInput : color.orange, tableBgInput)
    f_cell(dash, 0, 7, "Settings", tableLabelInput, tableBgInput)
    f_cell(dash, 1, 7, showSettingsRow ? "TF " + sourceTf + " · " + maType + " " + str.tostring(length) : "", tableTextInput, tableBgInput)
else if not showTable and barstate.islast
    table.clear(dash, 0, 0, 1, 7)
````
