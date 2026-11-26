# ADX/DI Histogram [MTF Advanced]

- url: https://www.tradingview.com/script/DjnFZRWN-ADX-DI-Histogram-MTF-Advanced/
- type: indicator
- pine_id: PUB;535e1a3d65e04b86a61272b9f9b0923a
- version: 2.0

## Description

[image]https://www.tradingview.com/x/2c4Vg8Rk/[/image]


[b]Institutional Trend Clarity — Without Indicator Overload[/b]

Most traders use ADX to measure strength…
But strength alone doesn’t tell you when a move is actually tradable.

This indicator transforms classic ADX/DI into a multi-timeframe alignment engine, giving you a clean, real-time view of:

• Trend direction
• Trend strength
• Participation across timeframes
• Market structure quality

All in one minimal, high-clarity dashboard.

[b]WHAT MAKES THIS DIFFERENT[/b]

This is not just another ADX.

It answers a deeper question:

Is the trend actually supported across timeframes—or is it fragile?

By combining:
• ADX (strength)
• DI bias (direction)
• Multi-timeframe stacking
• Participation modeling (PWR)

You get a true structure-based trend read, not just a number.

[b]CORE FEATURES[/b]

[b]MTF ALIGNMENT DASHBOARD[/b]
Instantly see alignment across three timeframes:
• Direction (▲ / ▼)
• ADX strength
• Participation (● ◑ ○)

No chart clutter. No guesswork.

SMART MARKET STATE CLASSIFICATION

Instead of vague signals, the indicator classifies the environment into clear states:

[b]FULL BULL / FULL BEAR[/b]
Strong, aligned trend across all timeframes
Best conditions for continuation trades

[b]BUILDING BULL / BUILDING BEAR[/b]
Trend is developing from lower to higher timeframes
Early-stage momentum (often best risk/reward)

[b]WEAK BULL / WEAK BEAR[/b]
Direction agrees, but lacks participation
Lower conviction / prone to failure

[b]MIXED[/b]
Conflicting structure or broken alignment
Chop / avoid conditions

[b]PARTICIPATION (PWR) SYSTEM[/b]

Each timeframe is graded visually:

● Strong participation (ADX above threshold)
◑ Building participation
○ Weak / inactive

This allows you to instantly see whether momentum is:
• Expanding
• Stalling
• Failing

[b]ADX/DI HISTOGRAM (ENHANCED)[/b]

• Clean directional bias histogram
• Strength-weighted coloring
• Optional ADX overlay
• Built for clarity, not noise

[b]SMART ALERTS (NON-SPAM)[/b]

Built-in alert system triggers only on state changes:

• FULL BULL / BEAR confirmed
• BUILDING trend emerging
• WEAK conditions detected
• MIXED environments

Includes:
• Strict Mode (alerts only on FULL alignment)
• Clean, readable alert labels

[b]HOW TO USE[/b]

Trend Traders
Focus on FULL BULL / BEAR
Use BUILDING as early entry opportunities

Intraday / Scalpers
Exploit BUILDING phases
Avoid WEAK and MIXED environments

Risk Management
Use PWR dots to confirm participation before committing size

[b]WHY IT MATTERS[/b]

Most indicators tell you something is happening.

This tells you if the move is actually worth trading.

[b]DESIGNED FOR[/b]

• Futures traders
• Intraday and swing traders
• Multi-timeframe analysts
• Traders who want clarity without clutter

[b]FINAL THOUGHT[/b][image]https://www.tradingview.com/x/2c4Vg8Rk/[/image]

This tool won’t predict the market.

But it will help you stop trading weak environments
and focus only on structurally sound moves.

## Source Code

````pine
//@version=6
indicator("ADX/DI Histogram [MTF Advanced]", overlay=false, scale=scale.left)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

len = input.int(14, "Length", minval=1,
     tooltip="ADX/DI calculation length.")

threshold = input.int(25, "ADX Threshold", minval=1,
     tooltip="ADX level required for strong trend participation.")

showADX = input.bool(false, "Show ADX Line",
     tooltip="Displays the raw ADX line.")

showDILine = input.bool(false, "Show DI Bias Line",
     tooltip="Reserved for DI bias display options.")

showBg = input.bool(false, "Show Background Bias",
     tooltip="Highlights bullish or bearish bias when ADX is above the trend threshold.")

showZones = input.bool(true, "Show Strength Zones",
     tooltip="Displays the ADX strength guides at 35 and 50. The primary trend threshold remains visible.")

showReadout = input.bool(true, "Show Current Chart Readout",
     tooltip="Displays current chart ADX, trend direction, and strength.")

showMTF = input.bool(true, "Show MTF Stack",
     tooltip="Displays multi-timeframe ADX/DI alignment dashboard.")

strictAlerts = input.bool(false, "Strict Alerts — Full Alignment Only",
     tooltip="When enabled, alerts only trigger for FULL BULL or FULL BEAR state changes.")

tf1 = input.timeframe("240", "MTF 1",
     tooltip="Higher timeframe used in the MTF dashboard.")

tf2 = input.timeframe("60", "MTF 2",
     tooltip="Middle timeframe used in the MTF dashboard.")

tf3 = input.timeframe("15", "MTF 3",
     tooltip="Lower timeframe used in the MTF dashboard.")

colorTheme = input.string(
     "Graphite",
     "Color Theme",
     options=["Graphite", "Classic Navy"],
     group="Appearance",
     tooltip="Controls the histogram, background bias, readout, and MTF dashboard colors. Graphite uses the refined neutral-dark palette, while Classic Navy restores the original published appearance.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Color Theme
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isGraphite = colorTheme == "Graphite"

BULL_COLOR    = isGraphite ? #26C6B8 : #00c89b
BEAR_COLOR    = isGraphite ? #A83A68 : #f23645
NEUTRAL_COLOR = isGraphite ? #667582 : #636b79
CAUTION_COLOR = #ffb100

HEADER_COLOR = isGraphite ? #B9B9BD : #38bdf8
PANEL_BG     = isGraphite ? #222225 : #131722
ROW_BG       = isGraphite ? #2D2D30 : #1e222d
HEADER_BG    = isGraphite ? #17181C : #2a2e39

BORDER_COLOR = isGraphite
     ? color.new(#38383C, 52)
     : color.new(#363a45, 50)

MUTED_TEXT = isGraphite ? #929296 : #b2b5be

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADX / DI Function
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

adxDI(_len) =>
    trueRange = math.max(
         math.max(high - low, math.abs(high - nz(close[1]))),
         math.abs(low - nz(close[1])))

    dmPlus = high - nz(high[1]) > nz(low[1]) - low
         ? math.max(high - nz(high[1]), 0)
         : 0

    dmMinus = nz(low[1]) - low > high - nz(high[1])
         ? math.max(nz(low[1]) - low, 0)
         : 0

    smTR      = ta.rma(trueRange, _len)
    smDMPlus  = ta.rma(dmPlus, _len)
    smDMMinus = ta.rma(dmMinus, _len)

    diPlus  = smDMPlus / smTR * 100
    diMinus = smDMMinus / smTR * 100

    dx = math.abs(diPlus - diMinus) /
         math.max(diPlus + diMinus, 0.000001) * 100

    adx = ta.sma(dx, _len)

    [adx, diPlus, diMinus]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Logic and Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[adx, diPlus, diMinus] = adxDI(len)

diBias      = threshold + (diPlus - diMinus)
bullBias    = diPlus > diMinus
bearBias    = diMinus > diPlus
neutralBias = math.abs(diPlus - diMinus) < 3

weakTrend     = adx < 20
buildingTrend = adx >= 20 and adx < threshold
moderateTrend = adx >= threshold and adx < 35
strongTrend   = adx >= 35 and adx < 50

bullColor = weakTrend
     ? color.new(BULL_COLOR, 65)
     : buildingTrend
     ? color.new(BULL_COLOR, 45)
     : moderateTrend
     ? color.new(BULL_COLOR, 35)
     : strongTrend
     ? color.new(BULL_COLOR, 10)
     : color.new(BULL_COLOR, 0)

bearColor = weakTrend
     ? color.new(BEAR_COLOR, 65)
     : buildingTrend
     ? color.new(BEAR_COLOR, 45)
     : moderateTrend
     ? color.new(BEAR_COLOR, 35)
     : strongTrend
     ? color.new(BEAR_COLOR, 10)
     : color.new(BEAR_COLOR, 0)

histColor = bullBias ? bullColor : bearColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots and Backgrounds
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bgcolor(
     showBg and bullBias and adx >= threshold
     ? color.new(BULL_COLOR, 92)
     : na)

bgcolor(
     showBg and bearBias and adx >= threshold
     ? color.new(BEAR_COLOR, 92)
     : na)

hline(
     threshold,
     "Trend Threshold",
     color=color.new(color.white, 65),
     linestyle=hline.style_dashed)

hline(
     35,
     "Strong Trend",
     color=showZones ? color.new(color.white, 82) : na,
     linestyle=hline.style_dotted)

hline(
     50,
     "Extreme Trend",
     color=showZones ? color.new(color.white, 88) : na,
     linestyle=hline.style_dotted)

plot(
     diBias,
     title="DI Bias Histogram",
     style=plot.style_histogram,
     histbase=threshold,
     linewidth=4,
     color=histColor,
     display=display.all - display.price_scale)

plot(
     showADX ? adx : na,
     title="ADX",
     color=color.new(color.gray, 70),
     linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Readout and MTF Calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendText = neutralBias ? "Neutral" : bullBias ? "Bull" : "Bear"

trendColor = neutralBias
     ? color.new(NEUTRAL_COLOR, 20)
     : bullBias
     ? BULL_COLOR
     : BEAR_COLOR

strengthText = weakTrend
     ? "Weak"
     : buildingTrend
     ? "Building"
     : moderateTrend
     ? "Moderate"
     : strongTrend
     ? "Strong"
     : "Extreme"

strengthColor = weakTrend
     ? NEUTRAL_COLOR
     : buildingTrend
     ? color.yellow
     : moderateTrend
     ? BULL_COLOR
     : strongTrend
     ? color.lime
     : color.green

[adx1, plus1, minus1] =
     request.security(syminfo.tickerid, tf1, adxDI(len))

[adx2, plus2, minus2] =
     request.security(syminfo.tickerid, tf2, adxDI(len))

[adx3, plus3, minus3] =
     request.security(syminfo.tickerid, tf3, adxDI(len))

bull1 = plus1 > minus1
bull2 = plus2 > minus2
bull3 = plus3 > minus3

bear1 = minus1 > plus1
bear2 = minus2 > plus2
bear3 = minus3 > plus3

allBull = bull1 and bull2 and bull3
allBear = bear1 and bear2 and bear3

pwr1 = adx1 >= threshold ? 2 : adx1 >= 20 ? 1 : 0
pwr2 = adx2 >= threshold ? 2 : adx2 >= 20 ? 1 : 0
pwr3 = adx3 >= threshold ? 2 : adx3 >= 20 ? 1 : 0

strongCount =
     (pwr1 == 2 ? 1 : 0) +
     (pwr2 == 2 ? 1 : 0) +
     (pwr3 == 2 ? 1 : 0)

fullBull = allBull and strongCount == 3
fullBear = allBear and strongCount == 3

buildingBull =
     allBull and
     pwr3 >= pwr2 and
     pwr2 >= pwr1 and
     strongCount >= 1 and
     not fullBull

buildingBear =
     allBear and
     pwr3 >= pwr2 and
     pwr2 >= pwr1 and
     strongCount >= 1 and
     not fullBear

weakBull = allBull and strongCount <= 1 and not buildingBull
weakBear = allBear and strongCount <= 1 and not buildingBear

mixedState =
     not fullBull and
     not fullBear and
     not buildingBull and
     not buildingBear and
     not weakBull and
     not weakBear

stackText = fullBull
     ? "FULL BULL"
     : fullBear
     ? "FULL BEAR"
     : buildingBull
     ? "BUILDING BULL"
     : buildingBear
     ? "BUILDING BEAR"
     : weakBull
     ? "WEAK BULL"
     : weakBear
     ? "WEAK BEAR"
     : "MIXED"

stackColor = fullBull or buildingBull or weakBull
     ? BULL_COLOR
     : fullBear or buildingBear or weakBear
     ? BEAR_COLOR
     : MUTED_TEXT

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alert Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

stateId = fullBull
     ? 1
     : buildingBull
     ? 2
     : weakBull
     ? 3
     : fullBear
     ? -1
     : buildingBear
     ? -2
     : weakBear
     ? -3
     : 0

stateChanged = barstate.isconfirmed and stateId != stateId[1]

fullBullAlert     = stateChanged and fullBull
buildingBullAlert = stateChanged and buildingBull and not strictAlerts
weakBullAlert     = stateChanged and weakBull and not strictAlerts
fullBearAlert     = stateChanged and fullBear
buildingBearAlert = stateChanged and buildingBear and not strictAlerts
weakBearAlert     = stateChanged and weakBear and not strictAlerts
mixedAlert        = stateChanged and mixedState and not strictAlerts

bullStateAlert =
     stateChanged and
     (fullBull or
     (not strictAlerts and (buildingBull or weakBull)))

bearStateAlert =
     stateChanged and
     (fullBear or
     (not strictAlerts and (buildingBear or weakBear)))

anyStateAlert =
     stateChanged and
     (not strictAlerts or fullBull or fullBear)

alertcondition(
     fullBullAlert,
     "MTF FULL BULL (Trend Confirmed)",
     "ADX/DI MTF: FULL BULL trend confirmed on {{ticker}} {{interval}}")

alertcondition(
     buildingBullAlert,
     "MTF BUILDING BULL (Early Trend)",
     "ADX/DI MTF: BUILDING BULL early trend on {{ticker}} {{interval}}")

alertcondition(
     weakBullAlert,
     "MTF WEAK BULL (Low Conviction)",
     "ADX/DI MTF: WEAK BULL low-conviction trend on {{ticker}} {{interval}}")

alertcondition(
     fullBearAlert,
     "MTF FULL BEAR (Trend Confirmed)",
     "ADX/DI MTF: FULL BEAR trend confirmed on {{ticker}} {{interval}}")

alertcondition(
     buildingBearAlert,
     "MTF BUILDING BEAR (Early Trend)",
     "ADX/DI MTF: BUILDING BEAR early trend on {{ticker}} {{interval}}")

alertcondition(
     weakBearAlert,
     "MTF WEAK BEAR (Low Conviction)",
     "ADX/DI MTF: WEAK BEAR low-conviction trend on {{ticker}} {{interval}}")

alertcondition(
     mixedAlert,
     "MTF MIXED (No Alignment)",
     "ADX/DI MTF: MIXED no clear alignment on {{ticker}} {{interval}}")

alertcondition(
     bullStateAlert,
     "Any MTF Bull State",
     "ADX/DI MTF: Bull state started on {{ticker}} {{interval}}")

alertcondition(
     bearStateAlert,
     "Any MTF Bear State",
     "ADX/DI MTF: Bear state started on {{ticker}} {{interval}}")

alertcondition(
     anyStateAlert,
     "Any MTF State Change",
     "ADX/DI MTF: State changed on {{ticker}} {{interval}}")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Table Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tfDir(_bull, _bear) =>
    _bull ? "▲" : _bear ? "▼" : "—"

tfDirColor(_bull, _bear) =>
    _bull ? BULL_COLOR : _bear ? BEAR_COLOR : CAUTION_COLOR

tfDot(_adx) =>
    _adx >= threshold ? "●" : _adx >= 20 ? "◑" : "○"

tfDotColor(_adx) =>
    _adx >= threshold
         ? BULL_COLOR
         : _adx >= 20
         ? CAUTION_COLOR
         : NEUTRAL_COLOR

tfLabel(_tf) =>
    n = str.tonumber(_tf)

    not na(n)
         ? (int(n) >= 60 and int(n) % 60 == 0
         ? str.tostring(int(n / 60)) + "H"
         : str.tostring(int(n)))
         : _tf == "D"
         ? "1D"
         : _tf == "W"
         ? "1W"
         : _tf == "M"
         ? "1MO"
         : str.upper(_tf)

chartTfLabel = tfLabel(timeframe.period)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboards
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mainBg    = PANEL_BG
glassBg   = ROW_BG
headerBg  = HEADER_BG
borderCol = BORDER_COLOR
mutedText = MUTED_TEXT

// Current Readout

var table readout = table.new(position.top_left, 10, 1)

if barstate.islast and showReadout
    table.cell(readout, 0, 0, "TF:",
         text_color=mutedText,
         text_size=size.normal)

    table.cell(readout, 1, 0, chartTfLabel,
         text_color=color.white,
         text_size=size.normal)

    table.cell(readout, 2, 0, "  ·  ",
         text_color=color.new(color.white, 70),
         text_size=size.normal)

    table.cell(readout, 3, 0, "ADX:",
         text_color=mutedText,
         text_size=size.normal)

    table.cell(readout, 4, 0, str.tostring(adx, "#.0"),
         text_color=color.white,
         text_size=size.normal)

    table.cell(readout, 5, 0, "  ·  ",
         text_color=color.new(color.white, 70),
         text_size=size.normal)

    table.cell(readout, 6, 0, "Trend:",
         text_color=mutedText,
         text_size=size.normal)

    table.cell(readout, 7, 0, trendText,
         text_color=trendColor,
         text_size=size.normal)

    table.cell(readout, 8, 0, "  Strength:",
         text_color=mutedText,
         text_size=size.normal)

    table.cell(readout, 9, 0, strengthText,
         text_color=strengthColor,
         text_size=size.normal)

// MTF Dashboard

var table mtfPanel = table.new(
     position.top_right,
     4,
     6,
     border_width=1,
     frame_color=borderCol,
     border_color=borderCol)

renderRow(row, tf, val, bull, bear) =>
    bg = row % 2 == 0 ? glassBg : mainBg

    table.cell(mtfPanel, 0, row, "  " + tfLabel(tf) + "  ",
         text_color=HEADER_COLOR,
         bgcolor=bg,
         text_size=size.normal)

    table.cell(mtfPanel, 1, row, "  " + str.tostring(val, "#.0") + "  ",
         text_color=color.white,
         bgcolor=bg,
         text_size=size.normal)

    table.cell(mtfPanel, 2, row, "  " + tfDir(bull, bear) + "  ",
         text_color=tfDirColor(bull, bear),
         bgcolor=bg,
         text_size=size.large)

    table.cell(mtfPanel, 3, row, "  " + tfDot(val) + "  ",
         text_color=tfDotColor(val),
         bgcolor=bg,
         text_size=size.normal)

if barstate.islast and showMTF
    table.cell(mtfPanel, 0, 0, "MTF ALIGNMENT",
         text_color=color.white,
         bgcolor=headerBg,
         text_size=size.normal)

    table.merge_cells(mtfPanel, 0, 0, 3, 0)

    table.cell(mtfPanel, 0, 1, "TF",
         text_color=mutedText,
         bgcolor=mainBg,
         text_size=size.small)

    table.cell(mtfPanel, 1, 1, "ADX",
         text_color=mutedText,
         bgcolor=mainBg,
         text_size=size.small)

    table.cell(mtfPanel, 2, 1, "DIR",
         text_color=mutedText,
         bgcolor=mainBg,
         text_size=size.small)

    table.cell(mtfPanel, 3, 1, "PWR",
         text_color=mutedText,
         bgcolor=mainBg,
         text_size=size.small)

    renderRow(2, tf1, adx1, bull1, bear1)
    renderRow(3, tf2, adx2, bull2, bear2)
    renderRow(4, tf3, adx3, bull3, bear3)

    table.cell(mtfPanel, 0, 5, " MTF STATE ",
         text_color=mutedText,
         bgcolor=headerBg,
         text_size=size.small)

    table.cell(mtfPanel, 1, 5, " " + stackText + " ",
         text_color=stackColor,
         bgcolor=headerBg,
         text_size=size.normal,
         text_halign=text.align_left)

    table.merge_cells(mtfPanel, 1, 5, 3, 5)
````
