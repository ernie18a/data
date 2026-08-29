<!-- tradingview-pine-id: PUB;40659905e9e749178e25a9bcbb8f9573 -->
<!-- tradingviewscripts-format: 1 -->
# Market Network Confirmation [NeuralMarkets]

Source: https://www.tradingview.com/script/Uu3bj8iQ-Market-Network-Confirmation-NeuralMarkets/

## Description

Market Network Confirmation [NeuralMarkets]

Price tells you where the market moved. The network tells you whether the market moved together.

A strong index move can look convincing on the surface and still be structurally weak underneath.

[*]Sometimes SPY rallies while only a handful of sectors participate.
[*]Sometimes the index is flat while participation quietly broadens.
[*]Sometimes the market looks healthy, but the sector network is already fragmenting.

This indicator was built to measure that difference.

What this indicator is designed to answer

Not:

"Is SPY up or down?"

But:

"Is the current move actually supported by the market underneath it?"

Market Network Confirmation analyzes the internal structure of the S&P 500 through its major sector ETFs and combines breadth with graph-based network analytics.

The result is a structural read on whether the current move is broad, narrow, deteriorating, recovering, or fragmented.

The Market as a Network

The indicator models the major SPDR sector ETFs as nodes in a financial network:

XLK - Technology
XLF - Financials
XLY - Consumer Discretionary
XLC - Communication Services
XLI - Industrials
XLV - Health Care
XLP - Consumer Staples
XLE - Energy
XLU - Utilities
XLB - Materials
XLRE - Real Estate

Rolling relationships between sector returns form the edges of the network.

The indicator then evaluates the structure using multiple graph-theory measures instead of relying on a single breadth statistic.

Market States

Broad Confirmation

The index move is supported by broad sector participation and a healthy underlying network.

This is the cleanest confirmation state.

Narrow Advance

SPY is moving higher, but participation is limited or leadership is overly concentrated.

The move may still continue, but the internal structure is less convincing.

Internal Divergence

SPY continues to advance while network health deteriorates underneath.

Price strength and internal structure are moving in opposite directions.

Recovery Broadening

SPY remains weak, but internal network conditions are improving.

Participation may be strengthening before the index itself fully recovers.

Distribution

Selling is broadly confirmed while network health remains weak.

The decline is not isolated to a small part of the market.

Fragmentation

The sector network breaks into weakly connected groups.

In this environment, the market behaves less like one coherent system and more like a collection of disconnected sectors.

Healthy Rotation

No major structural warning is present, but the market is rotating rather than moving with strong broad confirmation.

Network Health

The indicator creates a composite Network Health score from several graph measures:

• Mean network connectivity
• Strong-edge density
• Clustering coefficient
• Minimum Spanning Tree compactness
• Network entropy
• Decentralization
• Connected components

The score is normalized from 0 to 100.

A high Network Health score means the sector network is structurally coherent and broadly connected.

A low score means relationships are weaker, more fragmented, or overly concentrated.

Important:

High Network Health is not automatically bullish.

A market can be strongly connected while rising or while falling.

Network Health measures structural coherence, not direction.

Participation

Participation measures how many sectors are moving in the same direction as SPY.

For example:

SPY rising + 9 of 11 sectors rising

indicates broad bullish participation.

SPY rising + only 4 of 11 sectors rising

indicates a narrow advance.

Participation tells you how many sectors agree.

Network Health tells you how structurally connected the market is.

Those are not the same thing.

Move Confirmation

Move Confirmation combines:

• Network Health
• Sector Participation
• Distribution of influence across the network

This creates a 0-100 measure of how strongly the internal market structure supports the current index move.

The dashboard classifies confirmation as:

• High
• Moderate
• Low

This is not a probability of future returns.

It is a measure of structural agreement behind the current move.

Internal Trend

The indicator also tracks whether network health is:

• Improving
• Stable
• Deteriorating

This becomes useful when price and internal structure start moving in opposite directions.

For example:

SPY making new highs while Network Health declines

is very different from:

SPY making new highs while Network Health strengthens.

Sector Network

The Sector Network panel shows which sectors are:

• Supporting the current SPY direction
• Diverging from it

This gives a fast view of whether the move is broad or being carried by only a few sectors.

Network Diagnostics

For users who want to inspect the underlying graph structure, the indicator exposes the individual network metrics.

Connectivity
Average strength of relationships across the sector network.

Strong Edge Density
Percentage of strong relationships currently present in the network.

Clustering
Measures whether sectors are forming tightly connected groups.

MST Compactness
Uses a Minimum Spanning Tree to measure how efficiently the full sector network can be connected.

Entropy
Measures how broadly network influence is distributed.

Decentralization
Shows whether the network is broadly distributed rather than dominated by a small number of nodes.

Connectedness
Measures how close the system is to behaving as one connected network.

Fragmentation
Measures how disconnected the market has become.

Why use network analysis?

Traditional breadth tools usually count:

• Advancers vs decliners
• Positive vs negative sectors
• Stocks above moving averages
• New highs vs new lows

Those are useful.

But they do not measure how relationships between market components are changing.

Two markets can both have 8 bullish sectors.

One may be tightly connected and behaving as a coherent market.

The other may contain several disconnected clusters with very weak relationships.

Graph analysis can distinguish between those structures.

Practical Use

Market Network Confirmation can be used as a second layer of analysis when evaluating:

• Breakouts
• Trend continuation
• Rally quality
• Selloff confirmation
• Market breadth
• Sector rotation
• Internal divergence
• Recovery attempts

Research tool only. Not a standalone buy/sell signal.

---

## Source Code

````pine
//@version=6
indicator("Market Network Confirmation [NeuralMarkets]", shorttitle="NM Network Confirmation", overlay=true, max_bars_back=3000)

import NeuralMarkets/NeuralMarketsNetworkToolkit/1 as graph

groupModel = "Network Model"
corrLen = input.int(50, "Network Relationship Window", minval=20, maxval=250, group=groupModel)
edgeThreshold = input.float(0.55, "Strong Network Edge", minval=0.20, maxval=0.90, step=0.05, group=groupModel)
moveLen = input.int(3, "Market Move Window", minval=1, maxval=20, group=groupModel)
divergenceLen = input.int(10, "Internal Divergence Window", minval=3, maxval=50, group=groupModel)
divergenceThreshold = input.float(7.5, "Network Divergence Threshold", minval=2.0, maxval=25.0, step=0.5, group=groupModel)

groupDisplay = "Display"
showDashboard = input.bool(true, "Market Structure Card", group=groupDisplay)
showSectors = input.bool(true, "Sector Participation", group=groupDisplay)
showDiagnostics = input.bool(true, "Network Diagnostics", group=groupDisplay)
showBackground = input.bool(false, "Tint Chart by State", group=groupDisplay)

panelBg = color.new(color.rgb(18, 22, 28), 8)
panelBgAlt = color.new(color.rgb(25, 30, 38), 5)
headerBg = color.rgb(13, 17, 23)
borderColor = color.new(color.rgb(95, 105, 120), 65)
bullColor = color.rgb(54, 211, 153)
bearColor = color.rgb(248, 113, 113)
warningColor = color.rgb(251, 191, 36)
neutralColor = color.rgb(148, 163, 184)
cyanColor = color.rgb(56, 189, 248)
whiteText = color.rgb(241, 245, 249)
mutedText = color.rgb(148, 163, 184)

spy = request.security("AMEX:SPY", timeframe.period, close)
xlk = request.security("AMEX:XLK", timeframe.period, close)
xlf = request.security("AMEX:XLF", timeframe.period, close)
xly = request.security("AMEX:XLY", timeframe.period, close)
xlc = request.security("AMEX:XLC", timeframe.period, close)
xli = request.security("AMEX:XLI", timeframe.period, close)
xlv = request.security("AMEX:XLV", timeframe.period, close)
xlp = request.security("AMEX:XLP", timeframe.period, close)
xle = request.security("AMEX:XLE", timeframe.period, close)
xlu = request.security("AMEX:XLU", timeframe.period, close)
xlb = request.security("AMEX:XLB", timeframe.period, close)
xlre = request.security("AMEX:XLRE", timeframe.period, close)

rXlk = math.log(xlk / xlk[1])
rXlf = math.log(xlf / xlf[1])
rXly = math.log(xly / xly[1])
rXlc = math.log(xlc / xlc[1])
rXli = math.log(xli / xli[1])
rXlv = math.log(xlv / xlv[1])
rXlp = math.log(xlp / xlp[1])
rXle = math.log(xle / xle[1])
rXlu = math.log(xlu / xlu[1])
rXlb = math.log(xlb / xlb[1])
rXlre = math.log(xlre / xlre[1])

array<float> returns = array.from(rXlk, rXlf, rXly, rXlc, rXli, rXlv, rXlp, rXle, rXlu, rXlb, rXlre)

int nodeCount = 11
var array<float> network = graph.newMatrix(nodeCount, 0.0)

for i = 0 to nodeCount - 1
    graph.setCell(network, i, i, nodeCount, 1.0)

for i = 0 to nodeCount - 2
    for j = i + 1 to nodeCount - 1
        float ri = array.get(returns, i)
        float rj = array.get(returns, j)
        float relationship = ta.correlation(ri, rj, corrLen)
        graph.setUndirectedEdge(network, i, j, nodeCount, nz(relationship))

connectivity = graph.meanAbsoluteConnectivity(network, nodeCount)
networkDensity = graph.density(network, nodeCount, edgeThreshold)
fragmentation = graph.fragmentation(network, nodeCount, edgeThreshold)
clustering = graph.averageClusteringCoefficient(network, nodeCount, edgeThreshold)
compactness = graph.mstCompactness(network, nodeCount)
networkEntropy = graph.strengthEntropy(network, nodeCount)
centralization = graph.centralization(network, nodeCount)
components = graph.connectedComponentsCount(network, nodeCount, edgeThreshold)

componentScore = 1.0 - math.max(0.0, math.min(1.0, (components - 1.0) / (nodeCount - 1.0)))
distributionScore = 1.0 - centralization

networkHealthRaw = 0.22 * connectivity + 0.14 * networkDensity + 0.14 * clustering + 0.18 * compactness + 0.10 * networkEntropy + 0.12 * distributionScore + 0.10 * componentScore
networkHealth = math.max(0.0, math.min(100.0, networkHealthRaw * 100.0))

spyMove = spy[moveLen] != 0 ? spy / spy[moveLen] - 1.0 : 0.0
mXlk = xlk[moveLen] != 0 ? xlk / xlk[moveLen] - 1.0 : 0.0
mXlf = xlf[moveLen] != 0 ? xlf / xlf[moveLen] - 1.0 : 0.0
mXly = xly[moveLen] != 0 ? xly / xly[moveLen] - 1.0 : 0.0
mXlc = xlc[moveLen] != 0 ? xlc / xlc[moveLen] - 1.0 : 0.0
mXli = xli[moveLen] != 0 ? xli / xli[moveLen] - 1.0 : 0.0
mXlv = xlv[moveLen] != 0 ? xlv / xlv[moveLen] - 1.0 : 0.0
mXlp = xlp[moveLen] != 0 ? xlp / xlp[moveLen] - 1.0 : 0.0
mXle = xle[moveLen] != 0 ? xle / xle[moveLen] - 1.0 : 0.0
mXlu = xlu[moveLen] != 0 ? xlu / xlu[moveLen] - 1.0 : 0.0
mXlb = xlb[moveLen] != 0 ? xlb / xlb[moveLen] - 1.0 : 0.0
mXlre = xlre[moveLen] != 0 ? xlre / xlre[moveLen] - 1.0 : 0.0

array<float> sectorMoves = array.from(mXlk, mXlf, mXly, mXlc, mXli, mXlv, mXlp, mXle, mXlu, mXlb, mXlre)

int alignedSectors = 0
int bullishSectors = 0
int bearishSectors = 0

for i = 0 to nodeCount - 1
    float sectorMove = array.get(sectorMoves, i)
    if sectorMove > 0
        bullishSectors += 1
    if sectorMove < 0
        bearishSectors += 1
    if spyMove > 0 and sectorMove > 0
        alignedSectors += 1
    if spyMove < 0 and sectorMove < 0
        alignedSectors += 1

participation = alignedSectors * 1.0 / nodeCount
participationPct = participation * 100.0

confirmationRaw = 0.50 * (networkHealth / 100.0) + 0.35 * participation + 0.15 * distributionScore
confirmationScore = math.max(0.0, math.min(100.0, confirmationRaw * 100.0))

spyTrendMove = spy[divergenceLen] != 0 ? spy / spy[divergenceLen] - 1.0 : 0.0
healthChange = networkHealth - networkHealth[divergenceLen]

internalDivergence = spyTrendMove > 0 and healthChange <= -divergenceThreshold
internalRecovery = spyTrendMove < 0 and healthChange >= divergenceThreshold

string marketState = "HEALTHY ROTATION"

if internalDivergence
    marketState := "INTERNAL DIVERGENCE"
else if internalRecovery
    marketState := "RECOVERY BROADENING"
else if networkHealth < 35 or components >= 4
    marketState := "FRAGMENTATION"
else if spyMove > 0 and participation >= 0.70 and networkHealth >= 60 and centralization <= 0.45
    marketState := "BROAD CONFIRMATION"
else if spyMove < 0 and participation >= 0.70 and networkHealth >= 60
    marketState := "BROAD SELLING CONFIRMATION"
else if spyMove > 0 and (participation < 0.50 or centralization >= 0.55)
    marketState := "NARROW ADVANCE"
else if spyMove < 0 and participation >= 0.55 and networkHealth < 50
    marketState := "DISTRIBUTION"
else
    marketState := "HEALTHY ROTATION"

string marketDirection = spyMove > 0 ? "BULLISH" : spyMove < 0 ? "BEARISH" : "FLAT"

color stateColor = neutralColor
if marketState == "BROAD CONFIRMATION"
    stateColor := bullColor
if marketState == "RECOVERY BROADENING"
    stateColor := bullColor
if marketState == "BROAD SELLING CONFIRMATION"
    stateColor := bearColor
if marketState == "DISTRIBUTION"
    stateColor := bearColor
if marketState == "NARROW ADVANCE"
    stateColor := warningColor
if marketState == "INTERNAL DIVERGENCE"
    stateColor := warningColor
if marketState == "FRAGMENTATION"
    stateColor := bearColor

string confirmationLabel = confirmationScore >= 70 ? "HIGH" : confirmationScore < 45 ? "LOW" : "MODERATE"

signedPct(float value) =>
    string txt = str.tostring(value * 100.0, "#.00")
    value > 0 ? "+" + txt + "%" : txt + "%"

metricBar(float value) =>
    float v = math.max(0.0, math.min(100.0, value))
    int filled = int(math.round(v / 10.0))
    string txt = ""
    for i = 1 to 10
        txt += i <= filled ? "■" : "·"
    txt

metricColor(float value) =>
    value >= 70 ? bullColor : value >= 45 ? warningColor : bearColor

stateRead(string state) =>
    string result = "MONITOR"
    if state == "BROAD CONFIRMATION"
        result := "MOVE SUPPORTED"
    else if state == "BROAD SELLING CONFIRMATION"
        result := "SELLING CONFIRMED"
    else if state == "RECOVERY BROADENING"
        result := "INTERNALS IMPROVING"
    else if state == "INTERNAL DIVERGENCE"
        result := "CAUTION"
    else if state == "NARROW ADVANCE"
        result := "SELECTIVE"
    else if state == "DISTRIBUTION"
        result := "DEFENSIVE"
    else if state == "FRAGMENTATION"
        result := "LOW CONVICTION"
    result

sectorName(int idx) =>
    string result = "XLK"
    if idx == 1
        result := "XLF"
    if idx == 2
        result := "XLY"
    if idx == 3
        result := "XLC"
    if idx == 4
        result := "XLI"
    if idx == 5
        result := "XLV"
    if idx == 6
        result := "XLP"
    if idx == 7
        result := "XLE"
    if idx == 8
        result := "XLU"
    if idx == 9
        result := "XLB"
    if idx == 10
        result := "XLRE"
    result

sectorFullName(int idx) =>
    string result = "Technology"
    if idx == 1
        result := "Financials"
    if idx == 2
        result := "Consumer Disc."
    if idx == 3
        result := "Communication"
    if idx == 4
        result := "Industrials"
    if idx == 5
        result := "Health Care"
    if idx == 6
        result := "Consumer Staples"
    if idx == 7
        result := "Energy"
    if idx == 8
        result := "Utilities"
    if idx == 9
        result := "Materials"
    if idx == 10
        result := "Real Estate"
    result

color chartTint = na
if marketState == "BROAD CONFIRMATION" or marketState == "RECOVERY BROADENING"
    chartTint := color.new(bullColor, 96)
else if marketState == "INTERNAL DIVERGENCE" or marketState == "NARROW ADVANCE"
    chartTint := color.new(warningColor, 96)
else if marketState == "DISTRIBUTION" or marketState == "FRAGMENTATION" or marketState == "BROAD SELLING CONFIRMATION"
    chartTint := color.new(bearColor, 96)

bgcolor(showBackground ? chartTint : na)

var table dashboard = table.new(position.top_right, 3, 8, bgcolor=panelBg, frame_color=borderColor, frame_width=1, border_color=borderColor, border_width=1)

string healthChangeText = healthChange > 0 ? "+" + str.tostring(healthChange, "#.0") : str.tostring(healthChange, "#.0")
string networkTrend = healthChange > 2 ? "IMPROVING" : healthChange < -2 ? "DETERIORATING" : "STABLE"
color networkTrendColor = healthChange > 2 ? bullColor : healthChange < -2 ? bearColor : neutralColor
color directionColor = spyMove > 0 ? bullColor : spyMove < 0 ? bearColor : neutralColor
string stateIcon = marketState == "BROAD CONFIRMATION" ? "●" : marketState == "RECOVERY BROADENING" ? "▲" : marketState == "INTERNAL DIVERGENCE" ? "⚠" : marketState == "NARROW ADVANCE" ? "◆" : marketState == "DISTRIBUTION" ? "▼" : "●"

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "NEURALMARKETS", text_color=mutedText, bgcolor=headerBg, text_size=size.tiny)
    table.cell(dashboard, 1, 0, "MARKET NETWORK", text_color=whiteText, bgcolor=headerBg, text_size=size.small)
    table.cell(dashboard, 2, 0, "CONFIRMATION", text_color=cyanColor, bgcolor=headerBg, text_size=size.tiny)

    table.cell(dashboard, 0, 1, "MARKET STATE", text_color=mutedText, bgcolor=panelBgAlt)
    table.cell(dashboard, 1, 1, marketState, text_color=stateColor, bgcolor=panelBgAlt, text_size=size.small)
    table.cell(dashboard, 2, 1, stateRead(marketState), text_color=stateColor, bgcolor=panelBgAlt)

    table.cell(dashboard, 0, 2, "MARKET", text_color=mutedText, bgcolor=panelBg)
    table.cell(dashboard, 1, 2, marketDirection + "  " + signedPct(spyMove), text_color=directionColor, bgcolor=panelBg)
    table.cell(dashboard, 2, 2, str.tostring(bullishSectors) + "↑  " + str.tostring(bearishSectors) + "↓", text_color=whiteText, bgcolor=panelBg)

    table.cell(dashboard, 0, 3, "NETWORK HEALTH", text_color=mutedText, bgcolor=panelBgAlt)
    table.cell(dashboard, 1, 3, metricBar(networkHealth), text_color=metricColor(networkHealth), bgcolor=panelBgAlt)
    table.cell(dashboard, 2, 3, str.tostring(networkHealth, "#") + " / 100", text_color=metricColor(networkHealth), bgcolor=panelBgAlt)

    table.cell(dashboard, 0, 4, "PARTICIPATION", text_color=mutedText, bgcolor=panelBg)
    table.cell(dashboard, 1, 4, metricBar(participationPct), text_color=metricColor(participationPct), bgcolor=panelBg)
    table.cell(dashboard, 2, 4, str.tostring(alignedSectors) + " / 11", text_color=whiteText, bgcolor=panelBg)

    table.cell(dashboard, 0, 5, "CONFIRMATION", text_color=mutedText, bgcolor=panelBgAlt)
    table.cell(dashboard, 1, 5, metricBar(confirmationScore), text_color=metricColor(confirmationScore), bgcolor=panelBgAlt)
    table.cell(dashboard, 2, 5, str.tostring(confirmationScore, "#") + "  " + confirmationLabel, text_color=metricColor(confirmationScore), bgcolor=panelBgAlt)

    table.cell(dashboard, 0, 6, "INTERNAL TREND", text_color=mutedText, bgcolor=panelBg)
    table.cell(dashboard, 1, 6, networkTrend, text_color=networkTrendColor, bgcolor=panelBg)
    table.cell(dashboard, 2, 6, healthChangeText, text_color=networkTrendColor, bgcolor=panelBg)

    table.cell(dashboard, 0, 7, "DECISION READ", text_color=mutedText, bgcolor=headerBg)
    table.cell(dashboard, 1, 7, stateRead(marketState), text_color=stateColor, bgcolor=headerBg, text_size=size.small)
    table.cell(dashboard, 2, 7, stateIcon, text_color=stateColor, bgcolor=headerBg, text_size=size.large)

var table sectorTable = table.new(position.bottom_left, 4, 12, bgcolor=panelBg, frame_color=borderColor, frame_width=1, border_color=borderColor, border_width=1)

if barstate.islast and showSectors
    table.cell(sectorTable, 0, 0, "SECTOR NETWORK", text_color=whiteText, bgcolor=headerBg, text_size=size.small)
    table.cell(sectorTable, 1, 0, "ETF", text_color=mutedText, bgcolor=headerBg)
    table.cell(sectorTable, 2, 0, "MOVE", text_color=mutedText, bgcolor=headerBg)
    table.cell(sectorTable, 3, 0, "CONFIRMATION", text_color=mutedText, bgcolor=headerBg)

    for i = 0 to nodeCount - 1
        float sectorMove = array.get(sectorMoves, i)
        bool aligned = spyMove > 0 ? sectorMove > 0 : spyMove < 0 ? sectorMove < 0 : false
        color rowBg = i % 2 == 0 ? panelBg : panelBgAlt
        color moveColor = sectorMove > 0 ? bullColor : sectorMove < 0 ? bearColor : neutralColor
        string status = aligned ? "● SUPPORTING" : "○ DIVERGING"
        color statusColor = aligned ? bullColor : warningColor
        table.cell(sectorTable, 0, i + 1, sectorFullName(i), text_color=whiteText, bgcolor=rowBg)
        table.cell(sectorTable, 1, i + 1, sectorName(i), text_color=cyanColor, bgcolor=rowBg)
        table.cell(sectorTable, 2, i + 1, signedPct(sectorMove), text_color=moveColor, bgcolor=rowBg)
        table.cell(sectorTable, 3, i + 1, status, text_color=statusColor, bgcolor=rowBg)

var table diagnosticTable = table.new(position.bottom_right, 3, 9, bgcolor=panelBg, frame_color=borderColor, frame_width=1, border_color=borderColor, border_width=1)

if barstate.islast and showDiagnostics
    table.cell(diagnosticTable, 0, 0, "NETWORK DIAGNOSTICS", text_color=whiteText, bgcolor=headerBg, text_size=size.small)
    table.cell(diagnosticTable, 1, 0, "STRUCTURE", text_color=mutedText, bgcolor=headerBg)
    table.cell(diagnosticTable, 2, 0, "VALUE", text_color=mutedText, bgcolor=headerBg)

    array<string> names = array.from("Connectivity", "Strong Edge Density", "Clustering", "MST Compactness", "Entropy", "Decentralization", "Connectedness", "Fragmentation")
    array<float> values = array.from(connectivity * 100.0, networkDensity * 100.0, clustering * 100.0, compactness * 100.0, networkEntropy * 100.0, distributionScore * 100.0, componentScore * 100.0, fragmentation * 100.0)

    for i = 0 to 7
        float v = array.get(values, i)
        float quality = i == 7 ? 100.0 - v : v
        color rowBg = i % 2 == 0 ? panelBg : panelBgAlt
        color c = metricColor(quality)
        table.cell(diagnosticTable, 0, i + 1, array.get(names, i), text_color=mutedText, bgcolor=rowBg)
        table.cell(diagnosticTable, 1, i + 1, metricBar(quality), text_color=c, bgcolor=rowBg)
        table.cell(diagnosticTable, 2, i + 1, str.tostring(v, "#") + "%", text_color=whiteText, bgcolor=rowBg)

stateChanged = marketState != marketState[1]

alertcondition(stateChanged, "Market Network State Changed", "Market Network Confirmation detected a change in internal market structure.")
alertcondition(internalDivergence and not internalDivergence[1], "Internal Divergence", "SPY is advancing while underlying sector network health is deteriorating.")
alertcondition(internalRecovery and not internalRecovery[1], "Recovery Broadening", "SPY remains weak while underlying sector network health is improving.")
alertcondition(marketState == "BROAD CONFIRMATION" and marketState[1] != "BROAD CONFIRMATION", "Broad Confirmation", "SPY advance is receiving broad sector and network confirmation.")
````
