<!-- tradingview-pine-id: PUB;1e0210f261e74416a118864b6ebb9ed3 -->
<!-- tradingviewscripts-format: 1 -->
# Market Leadership Network [NeuralMarkets]

Source: https://www.tradingview.com/script/EHCPUv7v-Market-Leadership-Network-NeuralMarkets/

## Description

Markets rarely move as one.
Some stocks quietly take control long before the index reacts.
Sometimes NVDA leads AI. Sometimes Financials quietly take over. Sometimes the entire market rotates beneath the surface while the index barely moves.
Most indicators measure price.
This indicator measures leadership.

Think of the market as a network.
Every asset influences something.
Some lead.
Some follow.
Some simply react.

Market Leadership Network transforms a group of symbols into a directed influence network and continuously asks one question:

Who is driving the market right now?

Rather than comparing relative strength, the model studies lead–lag relationships between assets and identifies where influence appears to originate.

What you'll see

Current Driver
The asset currently exhibiting the strongest outbound influence across the selected universe.
Not necessarily the strongest performer......the strongest leader.

Leadership Board

Every symbol is ranked from Leader to Follower using network influence instead of simple performance.
Leadership changes can occur even when prices remain relatively unchanged.

Leadership History

Markets don't always rotate every day.
Some leaders dominate for weeks.
Others briefly emerge before fading.
Leadership History shows how persistent each leader has been across the selected lookback window.

Influence Map

Once a leader emerges...
Which assets begin following?
The influence panel visualizes the strongest directional relationships currently detected within the network.

Why this is different
Traditional indicators ask:
"Is this stock strong?"
Market Leadership Network asks:
"Is this stock leading everyone else?"
Those are very different questions.

Built on Graph Theory

Internally, the indicator models the selected symbols as a weighted directed graph.
Lead–lag relationships become network connections.
Graph analytics are then used to estimate:
• Leadership
• Followers
• Influence concentration
• Rotation dynamics
• Leadership persistence
No prediction model.
No black-box AI.
Just quantitative network analysis applied to financial markets.

Ideal For
• Sector rotation research
• Technology leadership
• Heavyweight stock analysis
• Cross-asset studies
• Market structure research
• Quantitative experimentation

A note on interpretation

Leadership is relative, not absolute.
The rankings depend entirely on the selected group of assets.
The indicator is designed to explore market structure—not to generate automatic buy or sell signals.
Think of it as a microscope for understanding who is moving the market, rather than another indicator telling you where price should go next.
.................................................................................................................

Built with NeuralMarkets Network Toolkit
The indicator is powered entirely by the open-source NeuralMarkets Network Toolkit, a graph analytics library for Pine Script that provides reusable network algorithms, centrality measures, clustering metrics and financial graph primitives.

---

## Source Code

````pine
//@version=6
indicator("Market Leadership Network [NeuralMarkets]", shorttitle="NM Leadership", overlay=false, max_bars_back=3000)

import NeuralMarkets/NeuralMarketsNetworkToolkit/1 as graph

//====================================================================
// INPUTS
//====================================================================

groupUniverse = "Network Universe"

symbol1 = input.symbol("NASDAQ:NVDA", "Asset 1", group=groupUniverse)
symbol2 = input.symbol("NASDAQ:MSFT", "Asset 2", group=groupUniverse)
symbol3 = input.symbol("NASDAQ:AAPL", "Asset 3", group=groupUniverse)
symbol4 = input.symbol("NASDAQ:META", "Asset 4", group=groupUniverse)
symbol5 = input.symbol("NASDAQ:AMZN", "Asset 5", group=groupUniverse)
symbol6 = input.symbol("AMEX:SPY", "Asset 6", group=groupUniverse)

groupModel = "Lead-Lag Model"

lookback = input.int(80, "Relationship Window", minval=20, maxval=300, group=groupModel)
maxLag = input.int(5, "Maximum Lead Lag", minval=1, maxval=10, group=groupModel)
powerWeight = input.float(2.0, "Influence Weight Power", minval=1.0, maxval=4.0, step=0.25, group=groupModel)
rankSmooth = input.int(5, "Rank Smoothing", minval=1, maxval=50, group=groupModel)
historyLookback = input.int(100, "Leadership History", minval=20, maxval=300, group=groupModel)

groupDisplay = "Display"

showDashboard = input.bool(true, "Market Leadership Dashboard", group=groupDisplay)
showBoard = input.bool(true, "Leadership Board", group=groupDisplay)
showInfluence = input.bool(true, "Leader Influence", group=groupDisplay)
showHistory = input.bool(true, "Leader History", group=groupDisplay)
showStability = input.bool(true, "Leadership Stability Plot", group=groupDisplay)

//====================================================================
// COLORS
//====================================================================

headerBg = color.rgb(22, 26, 32)
cellBg = color.rgb(31, 35, 42)
cellBg2 = color.rgb(37, 42, 50)

leaderColor = color.rgb(65, 190, 125)
neutralColor = color.rgb(180, 185, 195)
followerColor = color.rgb(218, 150, 65)
weakColor = color.rgb(125, 130, 140)

whiteText = color.rgb(235, 238, 245)
mutedText = color.rgb(165, 170, 180)

//====================================================================
// DATA
//====================================================================

p1 = request.security(symbol1, timeframe.period, close)
p2 = request.security(symbol2, timeframe.period, close)
p3 = request.security(symbol3, timeframe.period, close)
p4 = request.security(symbol4, timeframe.period, close)
p5 = request.security(symbol5, timeframe.period, close)
p6 = request.security(symbol6, timeframe.period, close)

r1 = math.log(p1 / p1[1])
r2 = math.log(p2 / p2[1])
r3 = math.log(p3 / p3[1])
r4 = math.log(p4 / p4[1])
r5 = math.log(p5 / p5[1])
r6 = math.log(p6 / p6[1])

//====================================================================
// HELPERS
//====================================================================

leadInfluence(float source, float target, int length, int lagMaximum) =>
    float best = 0.0
    for lag = 1 to lagMaximum
        float value = ta.correlation(source[lag], target, length)
        if not na(value) and value > best
            best := value
    best

softWeight(float value) =>
    float v = math.max(value, 0.0)
    math.pow(v, powerWeight)

symbolName(int idx) =>
    string result = symbol1
    if idx == 1
        result := symbol2
    if idx == 2
        result := symbol3
    if idx == 3
        result := symbol4
    if idx == 4
        result := symbol5
    if idx == 5
        result := symbol6
    result

shortName(string value) =>
    string result = value
    int colonPos = str.pos(value, ":")
    if colonPos >= 0
        result := str.substring(value, colonPos + 1, str.length(value))
    result

scoreBar(float value) =>
    int blocks = int(math.round(math.max(0.0, math.min(100.0, value)) / 10.0))
    string result = ""
    for i = 1 to 10
        result += i <= blocks ? "█" : "░"
    result

influenceBar(float value, float maximum) =>
    float normalized = maximum > 0.000001 ? value / maximum : 0.0
    int blocks = int(math.round(math.max(0.0, math.min(1.0, normalized)) * 10.0))
    string result = ""
    for i = 1 to 10
        result += i <= blocks ? "█" : "░"
    result

//====================================================================
// DIRECTED LEAD-LAG RELATIONSHIPS
//====================================================================

i12 = leadInfluence(r1, r2, lookback, maxLag)
i13 = leadInfluence(r1, r3, lookback, maxLag)
i14 = leadInfluence(r1, r4, lookback, maxLag)
i15 = leadInfluence(r1, r5, lookback, maxLag)
i16 = leadInfluence(r1, r6, lookback, maxLag)

i21 = leadInfluence(r2, r1, lookback, maxLag)
i23 = leadInfluence(r2, r3, lookback, maxLag)
i24 = leadInfluence(r2, r4, lookback, maxLag)
i25 = leadInfluence(r2, r5, lookback, maxLag)
i26 = leadInfluence(r2, r6, lookback, maxLag)

i31 = leadInfluence(r3, r1, lookback, maxLag)
i32 = leadInfluence(r3, r2, lookback, maxLag)
i34 = leadInfluence(r3, r4, lookback, maxLag)
i35 = leadInfluence(r3, r5, lookback, maxLag)
i36 = leadInfluence(r3, r6, lookback, maxLag)

i41 = leadInfluence(r4, r1, lookback, maxLag)
i42 = leadInfluence(r4, r2, lookback, maxLag)
i43 = leadInfluence(r4, r3, lookback, maxLag)
i45 = leadInfluence(r4, r5, lookback, maxLag)
i46 = leadInfluence(r4, r6, lookback, maxLag)

i51 = leadInfluence(r5, r1, lookback, maxLag)
i52 = leadInfluence(r5, r2, lookback, maxLag)
i53 = leadInfluence(r5, r3, lookback, maxLag)
i54 = leadInfluence(r5, r4, lookback, maxLag)
i56 = leadInfluence(r5, r6, lookback, maxLag)

i61 = leadInfluence(r6, r1, lookback, maxLag)
i62 = leadInfluence(r6, r2, lookback, maxLag)
i63 = leadInfluence(r6, r3, lookback, maxLag)
i64 = leadInfluence(r6, r4, lookback, maxLag)
i65 = leadInfluence(r6, r5, lookback, maxLag)

//====================================================================
// BUILD NETWORK
//====================================================================

var array<float> network = graph.newMatrix(6, 0.0)

graph.setDirectedEdge(network, 0, 1, 6, softWeight(i12))
graph.setDirectedEdge(network, 0, 2, 6, softWeight(i13))
graph.setDirectedEdge(network, 0, 3, 6, softWeight(i14))
graph.setDirectedEdge(network, 0, 4, 6, softWeight(i15))
graph.setDirectedEdge(network, 0, 5, 6, softWeight(i16))

graph.setDirectedEdge(network, 1, 0, 6, softWeight(i21))
graph.setDirectedEdge(network, 1, 2, 6, softWeight(i23))
graph.setDirectedEdge(network, 1, 3, 6, softWeight(i24))
graph.setDirectedEdge(network, 1, 4, 6, softWeight(i25))
graph.setDirectedEdge(network, 1, 5, 6, softWeight(i26))

graph.setDirectedEdge(network, 2, 0, 6, softWeight(i31))
graph.setDirectedEdge(network, 2, 1, 6, softWeight(i32))
graph.setDirectedEdge(network, 2, 3, 6, softWeight(i34))
graph.setDirectedEdge(network, 2, 4, 6, softWeight(i35))
graph.setDirectedEdge(network, 2, 5, 6, softWeight(i36))

graph.setDirectedEdge(network, 3, 0, 6, softWeight(i41))
graph.setDirectedEdge(network, 3, 1, 6, softWeight(i42))
graph.setDirectedEdge(network, 3, 2, 6, softWeight(i43))
graph.setDirectedEdge(network, 3, 4, 6, softWeight(i45))
graph.setDirectedEdge(network, 3, 5, 6, softWeight(i46))

graph.setDirectedEdge(network, 4, 0, 6, softWeight(i51))
graph.setDirectedEdge(network, 4, 1, 6, softWeight(i52))
graph.setDirectedEdge(network, 4, 2, 6, softWeight(i53))
graph.setDirectedEdge(network, 4, 3, 6, softWeight(i54))
graph.setDirectedEdge(network, 4, 5, 6, softWeight(i56))

graph.setDirectedEdge(network, 5, 0, 6, softWeight(i61))
graph.setDirectedEdge(network, 5, 1, 6, softWeight(i62))
graph.setDirectedEdge(network, 5, 2, 6, softWeight(i63))
graph.setDirectedEdge(network, 5, 3, 6, softWeight(i64))
graph.setDirectedEdge(network, 5, 4, 6, softWeight(i65))

//====================================================================
// NODE STRENGTHS
//====================================================================

out1 = graph.outStrength(network, 6, 0)
out2 = graph.outStrength(network, 6, 1)
out3 = graph.outStrength(network, 6, 2)
out4 = graph.outStrength(network, 6, 3)
out5 = graph.outStrength(network, 6, 4)
out6 = graph.outStrength(network, 6, 5)

in1 = graph.inStrength(network, 6, 0)
in2 = graph.inStrength(network, 6, 1)
in3 = graph.inStrength(network, 6, 2)
in4 = graph.inStrength(network, 6, 3)
in5 = graph.inStrength(network, 6, 4)
in6 = graph.inStrength(network, 6, 5)

net1 = out1 - in1
net2 = out2 - in2
net3 = out3 - in3
net4 = out4 - in4
net5 = out5 - in5
net6 = out6 - in6

minNet = math.min(math.min(math.min(net1, net2), math.min(net3, net4)), math.min(net5, net6))
maxNet = math.max(math.max(math.max(net1, net2), math.max(net3, net4)), math.max(net5, net6))
netRange = maxNet - minNet

rankScore(float value) =>
    netRange > 0.000001 ? 100.0 * (value - minNet) / netRange : 50.0

score1 = ta.ema(rankScore(net1), rankSmooth)
score2 = ta.ema(rankScore(net2), rankSmooth)
score3 = ta.ema(rankScore(net3), rankSmooth)
score4 = ta.ema(rankScore(net4), rankSmooth)
score5 = ta.ema(rankScore(net5), rankSmooth)
score6 = ta.ema(rankScore(net6), rankSmooth)

scoreByIndex(int idx) =>
    float result = score1
    if idx == 1
        result := score2
    if idx == 2
        result := score3
    if idx == 3
        result := score4
    if idx == 4
        result := score5
    if idx == 5
        result := score6
    result

//====================================================================
// CURRENT LEADER
//====================================================================

leaderIndex = graph.leadingNode(network, 6)
leaderScore = scoreByIndex(leaderIndex)
leaderName = shortName(symbolName(leaderIndex))

leaderChanged = leaderIndex != leaderIndex[1]

var int leaderAge = 1

if leaderChanged
    leaderAge := 1
else
    leaderAge += 1

leaderDelta = leaderScore - leaderScore[1]

string leaderMomentum = "HOLDING"

if leaderChanged
    leaderMomentum := "NEW LEADER"
else if leaderDelta > 1.0
    leaderMomentum := "STRENGTHENING"
else if leaderDelta < -1.0
    leaderMomentum := "WEAKENING"

//====================================================================
// LEADER HISTORY
//====================================================================

var array<int> leaderHistory = array.new_int(0)

array.push(leaderHistory, leaderIndex)

if array.size(leaderHistory) > historyLookback
    array.shift(leaderHistory)

historyCount = array.size(leaderHistory)

history0 = 0
history1 = 0
history2 = 0
history3 = 0
history4 = 0
history5 = 0

if historyCount > 0
    for i = 0 to historyCount - 1
        int h = array.get(leaderHistory, i)
        if h == 0
            history0 += 1
        if h == 1
            history1 += 1
        if h == 2
            history2 += 1
        if h == 3
            history3 += 1
        if h == 4
            history4 += 1
        if h == 5
            history5 += 1

historyCountByIndex(int idx) =>
    int result = history0
    if idx == 1
        result := history1
    if idx == 2
        result := history2
    if idx == 3
        result := history3
    if idx == 4
        result := history4
    if idx == 5
        result := history5
    result

currentLeaderHistoryCount = historyCountByIndex(leaderIndex)
leaderStability = historyCount > 0 ? 100.0 * currentLeaderHistoryCount / historyCount : 0.0

uniqueLeaders = 0

if history0 > 0
    uniqueLeaders += 1
if history1 > 0
    uniqueLeaders += 1
if history2 > 0
    uniqueLeaders += 1
if history3 > 0
    uniqueLeaders += 1
if history4 > 0
    uniqueLeaders += 1
if history5 > 0
    uniqueLeaders += 1

string diversityState = "BALANCED"

if uniqueLeaders <= 2
    diversityState := "DOMINATED"
else if uniqueLeaders >= 5
    diversityState := "FREQUENTLY ROTATING"

string stabilityState = "MEDIUM"

if leaderStability >= 65
    stabilityState := "HIGH"
else if leaderStability < 35
    stabilityState := "LOW"

string rotationRisk = "MEDIUM"

if leaderAge >= 10 and leaderStability >= 55
    rotationRisk := "LOW"

if leaderAge <= 3 or leaderStability < 30
    rotationRisk := "HIGH"

//====================================================================
// LEADERSHIP CONCENTRATION
//====================================================================

leadershipConcentration = graph.leadershipConcentration(network, 6)

string concentrationState = "DISTRIBUTED"

if leadershipConcentration >= 0.55
    concentrationState := "CONCENTRATED"
else if leadershipConcentration <= 0.20
    concentrationState := "BROAD"

//====================================================================
// SORT LEADERSHIP BOARD
//====================================================================

var array<int> rankOrder = array.new_int(6, 0)

if barstate.islast
    for i = 0 to 5
        array.set(rankOrder, i, i)

    for i = 0 to 4
        for j = i + 1 to 5
            int a = array.get(rankOrder, i)
            int b = array.get(rankOrder, j)

            if scoreByIndex(b) > scoreByIndex(a)
                array.set(rankOrder, i, b)
                array.set(rankOrder, j, a)

//====================================================================
// SORT LEADER INFLUENCE TARGETS
//====================================================================

var array<int> influenceTargets = array.new_int(5, 0)
var array<float> influenceValues = array.new_float(5, 0.0)

if barstate.islast
    int slot = 0

    for target = 0 to 5
        if target != leaderIndex
            array.set(influenceTargets, slot, target)
            array.set(influenceValues, slot, graph.getCell(network, leaderIndex, target, 6))
            slot += 1

    for i = 0 to 3
        for j = i + 1 to 4
            float va = array.get(influenceValues, i)
            float vb = array.get(influenceValues, j)

            if vb > va
                int ta = array.get(influenceTargets, i)
                int tb = array.get(influenceTargets, j)

                array.set(influenceValues, i, vb)
                array.set(influenceValues, j, va)

                array.set(influenceTargets, i, tb)
                array.set(influenceTargets, j, ta)

//====================================================================
// ONLY MEANINGFUL PLOT
//====================================================================

plot(showStability ? leaderStability : na, "Leadership Stability", color=leaderColor, linewidth=2)

hline(65, "Stable", color=color.new(leaderColor, 80))
hline(35, "Unstable", color=color.new(followerColor, 80))

//====================================================================
// TOP RIGHT — HERO DASHBOARD
//====================================================================

var table dashboard = table.new(position.top_right, 2, 10, border_width=1, border_color=color.rgb(60, 65, 72))

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "NEURALMARKETS", text_color=whiteText, bgcolor=headerBg)
    table.cell(dashboard, 1, 0, "MARKET LEADERSHIP", text_color=whiteText, bgcolor=headerBg)

    table.cell(dashboard, 0, 1, "Current Driver", text_color=mutedText, bgcolor=cellBg)
    table.cell(dashboard, 1, 1, leaderName, text_color=leaderColor, bgcolor=cellBg)

    table.cell(dashboard, 0, 2, "Status", text_color=mutedText, bgcolor=cellBg2)
    table.cell(dashboard, 1, 2, leaderMomentum, text_color=whiteText, bgcolor=cellBg2)

    table.cell(dashboard, 0, 3, "Leader Score", text_color=mutedText, bgcolor=cellBg)
    table.cell(dashboard, 1, 3, str.tostring(leaderScore, "#.0"), text_color=whiteText, bgcolor=cellBg)

    table.cell(dashboard, 0, 4, "Leader Age", text_color=mutedText, bgcolor=cellBg2)
    table.cell(dashboard, 1, 4, str.tostring(leaderAge) + " bars", text_color=whiteText, bgcolor=cellBg2)

    table.cell(dashboard, 0, 5, "Stability", text_color=mutedText, bgcolor=cellBg)
    table.cell(dashboard, 1, 5, stabilityState + " · " + str.tostring(leaderStability, "#") + "%", text_color=whiteText, bgcolor=cellBg)

    table.cell(dashboard, 0, 6, "Rotation Risk", text_color=mutedText, bgcolor=cellBg2)
    table.cell(dashboard, 1, 6, rotationRisk, text_color=rotationRisk == "HIGH" ? followerColor : leaderColor, bgcolor=cellBg2)

    table.cell(dashboard, 0, 7, "Leadership", text_color=mutedText, bgcolor=cellBg)
    table.cell(dashboard, 1, 7, concentrationState, text_color=whiteText, bgcolor=cellBg)

    table.cell(dashboard, 0, 8, "History", text_color=mutedText, bgcolor=cellBg2)
    table.cell(dashboard, 1, 8, diversityState, text_color=whiteText, bgcolor=cellBg2)

    table.cell(dashboard, 0, 9, "Information Flow", text_color=mutedText, bgcolor=cellBg)
    table.cell(dashboard, 1, 9, "COMING SOON", text_color=weakColor, bgcolor=cellBg)

//====================================================================
// BOTTOM LEFT — LEADERSHIP BOARD
//====================================================================

var table board = table.new(position.bottom_left, 5, 7, border_width=1, border_color=color.rgb(60, 65, 72))

if barstate.islast and showBoard
    table.cell(board, 0, 0, "#", text_color=whiteText, bgcolor=headerBg)
    table.cell(board, 1, 0, "ASSET", text_color=whiteText, bgcolor=headerBg)
    table.cell(board, 2, 0, "LEADERSHIP", text_color=whiteText, bgcolor=headerBg)
    table.cell(board, 3, 0, "SCORE", text_color=whiteText, bgcolor=headerBg)
    table.cell(board, 4, 0, "ROLE", text_color=whiteText, bgcolor=headerBg)

    for row = 0 to 5
        int idx = array.get(rankOrder, row)
        float score = scoreByIndex(idx)

        string role = "NEUTRAL"
        color roleColor = neutralColor

        if score >= 67
            role := "LEADER"
            roleColor := leaderColor
        else if score <= 33
            role := "FOLLOWER"
            roleColor := followerColor

        color rowBg = idx == leaderIndex ? color.rgb(34, 58, 48) : cellBg

        table.cell(board, 0, row + 1, str.tostring(row + 1), text_color=whiteText, bgcolor=rowBg)
        table.cell(board, 1, row + 1, shortName(symbolName(idx)), text_color=idx == leaderIndex ? leaderColor : whiteText, bgcolor=rowBg)
        table.cell(board, 2, row + 1, scoreBar(score), text_color=roleColor, bgcolor=rowBg)
        table.cell(board, 3, row + 1, str.tostring(score, "#.0"), text_color=whiteText, bgcolor=rowBg)
        table.cell(board, 4, row + 1, role, text_color=roleColor, bgcolor=rowBg)

//====================================================================
// BOTTOM RIGHT — LEADER INFLUENCE
//====================================================================

var table influenceTable = table.new(position.bottom_right, 4, 6, border_width=1, border_color=color.rgb(60, 65, 72))

if barstate.islast and showInfluence
    float maxInfluence = array.get(influenceValues, 0)

    table.cell(influenceTable, 0, 0, leaderName, text_color=leaderColor, bgcolor=headerBg)
    table.cell(influenceTable, 1, 0, "TARGET", text_color=whiteText, bgcolor=headerBg)
    table.cell(influenceTable, 2, 0, "INFLUENCE", text_color=whiteText, bgcolor=headerBg)
    table.cell(influenceTable, 3, 0, "VALUE", text_color=whiteText, bgcolor=headerBg)

    for row = 0 to 4
        int target = array.get(influenceTargets, row)
        float value = array.get(influenceValues, row)

        table.cell(influenceTable, 0, row + 1, "→", text_color=leaderColor, bgcolor=cellBg)
        table.cell(influenceTable, 1, row + 1, shortName(symbolName(target)), text_color=whiteText, bgcolor=cellBg)
        table.cell(influenceTable, 2, row + 1, influenceBar(value, maxInfluence), text_color=leaderColor, bgcolor=cellBg)
        table.cell(influenceTable, 3, row + 1, str.tostring(value, "#.000"), text_color=mutedText, bgcolor=cellBg)

//====================================================================
// TOP LEFT — LEADER HISTORY
//====================================================================

var table historyTable = table.new(position.top_left, 4, 7, border_width=1, border_color=color.rgb(60, 65, 72))

if barstate.islast and showHistory
    table.cell(historyTable, 0, 0, "LEADER HISTORY", text_color=whiteText, bgcolor=headerBg)
    table.cell(historyTable, 1, 0, "BARS", text_color=whiteText, bgcolor=headerBg)
    table.cell(historyTable, 2, 0, "SHARE", text_color=whiteText, bgcolor=headerBg)
    table.cell(historyTable, 3, 0, "HISTORY", text_color=whiteText, bgcolor=headerBg)

    for idx = 0 to 5
        int count = historyCountByIndex(idx)
        float share = historyCount > 0 ? 100.0 * count / historyCount : 0.0
        color historyColor = idx == leaderIndex ? leaderColor : neutralColor

        table.cell(historyTable, 0, idx + 1, shortName(symbolName(idx)), text_color=historyColor, bgcolor=cellBg)
        table.cell(historyTable, 1, idx + 1, str.tostring(count), text_color=whiteText, bgcolor=cellBg)
        table.cell(historyTable, 2, idx + 1, str.tostring(share, "#") + "%", text_color=whiteText, bgcolor=cellBg)
        table.cell(historyTable, 3, idx + 1, scoreBar(share), text_color=historyColor, bgcolor=cellBg)

//====================================================================
// ALERTS
//====================================================================

alertcondition(leaderChanged, "Leadership Rotation", "Market Leadership Network detected a change in the dominant market leader.")

highRotationRisk = rotationRisk == "HIGH" and rotationRisk[1] != "HIGH"

alertcondition(highRotationRisk, "High Rotation Risk", "Market Leadership Network detected elevated leadership rotation risk.")
````
