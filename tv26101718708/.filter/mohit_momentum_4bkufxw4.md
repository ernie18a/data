# mohit Momentum

- url: https://www.tradingview.com/script/4BKUfXW4-mohit-Momentum/
- type: indicator
- pine_id: PUB;dfc93be0534c49528ff3fcbcfc62736a
- version: 2.0

## Description

mohit Momentum is a highly versatile technical analysis tool designed to track market momentum across multiple timeframes simultaneously, helping traders stay on the right side of the primary trend.
[b]Core Architecture & Logic[/b]
The indicator calculates a custom momentum curve using the exponential relationship between fast, slow, and signal EMA lengths. It evaluates current market conditions across three specific layers:
1.Current Timeframe Trend: Tracks whether the momentum line is positioned above or below its signal line, signaling short-term bullish or bearish pressure.
2.Zero-Line Absolute Trend: Determines if the overall absolute trend is structural by monitoring whether momentum is trading in positive territory (above zero) or negative territory (below zero).
3.Higher Timeframe (HTF) Filter: Fetches trend data from a larger, customizable background timeframe (e.g., Weekly chart) to act as a macro trend shield, protecting you from trading against dominant market forces.
[b]Dynamic Information Table[/b]
The script automatically plots a real-time summary dashboard directly on your chart, displaying:
[b]Current TF:[/b] Dynamically shows a state classification (e.g., ▲ Strong Bull, ▲ Weak Bull, ▼ Strong Bear, or ▼ Weak Bear) based on the combined interaction of the MACD crossovers and the absolute zero line.
[b]HTF Row:[/b] Displays a clear status indicator (▲ Bullish, ▼ Bearish, or — Neutral) reflecting structural momentum on the high-level timeframe.
[b]Signal:[/b] Automatically generates consensus summaries—flagging highly confident setups as Confirmed Bull or Confirmed Bear when structural timeframes align, or warning you with a Conflicting state when the market is out of sync.
[b]Visual Elements & Smart Features[/b]
T[b]rend-Synced Backgrounds:[/b] Paints the entire chart area with customizable opacity colors (Green/Red) when highly confirmed trend setups trigger.
[b]Execution Cross Markers: [/b]Plots distinct shape markers (Triangles and Circles) on the chart tracking structural HTF-confirmed crossovers and absolute zero-line breaks.
[b]Fully Modular Alert System: [/b]Pre-loaded with complete alert configurations tracking structural crosses, macro alignment, and zero-boundary breakouts so you never miss a verified directional shift.

## Source Code

````pine
//@version=6
indicator("mohit Momentum", shorttitle="mohitMom", overlay=false)

// ═══════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════
grp1 = "Core Settings"
fastLen = input.int(9, "Fast EMA Length", minval=1, group=grp1)
slowLen = input.int(20, "Slow EMA Length", minval=1, group=grp1)
signalLen = input.int(9, "Signal EMA Length", minval=1, group=grp1)
srcInput = input.source(close, "Source", group=grp1)

grp2 = "Higher Timeframe (HTF) Confirmation"
htfEnable = input.bool(true, "Enable HTF Filter", group=grp2)
htfTF = input.timeframe("W", "Higher Timeframe", group=grp2)
htfOpacity = input.int(85, "Background Opacity %", minval=50, maxval=95, group=grp2)
bullBgColor = input.color(color.green, "Bullish Background Color", group=grp2)
bearBgColor = input.color(color.red, "Bearish Background Color", group=grp2)

grp3 = "Table"
showTable = input.bool(true, "Show Info Table", group=grp3)
tablePos = input.string("Bottom Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp3)
tableBoxColor = input.color(color.black, "Table Box Color", group=grp3)
tableBoxTransp = input.int(80, "Table Box Transparency", minval=0, maxval=100, group=grp3)
tableTextColor = input.color(color.silver, "Table Label Text Color", group=grp3)
tableHeaderTextColor = input.color(color.white, "Table Header Text Color", group=grp3)

grp4 = "Momentum Line Colors"
bullMomColor = input.color(color.green, "Momentum Color (Bull Crossover)", group=grp4)
bearMomColor = input.color(color.red, "Momentum Color (Bear Crossover)", group=grp4)
signalLineColor = input.color(color.red, "Signal Line Color", group=grp4)

// ═══════════════════════════════════════════════════════
// CORE CALCULATIONS (current timeframe)
// ═══════════════════════════════════════════════════════
fastEMA = ta.ema(srcInput, fastLen)
slowEMA = ta.ema(srcInput, slowLen)
macdLine = fastEMA - slowEMA
signalLine = ta.ema(macdLine, signalLen)

// ═══════════════════════════════════════════════════════
// HTF CALCULATIONS (single security call via tuple)
// ═══════════════════════════════════════════════════════
[htfFast, htfSlow, htfMacd, htfSignal] = request.security(syminfo.tickerid, htfTF, [ta.ema(close, fastLen), ta.ema(close, slowLen), ta.ema(close, fastLen) - ta.ema(close, slowLen), ta.ema(ta.ema(close, fastLen) - ta.ema(close, slowLen), signalLen)], lookahead=barmerge.lookahead_off)

htfBullish = htfMacd > htfSignal and htfMacd > 0
htfBearish = htfMacd < htfSignal and htfMacd < 0

// ═══════════════════════════════════════════════════════
// SIGNAL CONDITIONS
// ═══════════════════════════════════════════════════════
curBullish = macdLine > signalLine
curBearish = macdLine < signalLine
aboveZero = macdLine > 0
belowZero = macdLine < 0

bullCross = ta.crossover(macdLine, signalLine)
bearCross = ta.crossunder(macdLine, signalLine)
zeroCrossUp = ta.crossover(macdLine, 0)
zeroCrossDown = ta.crossunder(macdLine, 0)

htfConfirmedBull = bullCross and (htfEnable ? htfBullish : true)
htfConfirmedBear = bearCross and (htfEnable ? htfBearish : true)

fullyBullish = curBullish and aboveZero and (htfEnable ? htfBullish : true)
fullyBearish = curBearish and belowZero and (htfEnable ? htfBearish : true)

// ═══════════════════════════════════════════════════════
// BACKGROUND COLOR
// ═══════════════════════════════════════════════════════
bgColor = fullyBullish ? color.new(bullBgColor, htfOpacity) : fullyBearish ? color.new(bearBgColor, htfOpacity) : na
bgcolor(bgColor, title="Momentum Background")

// ═══════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════
var color momColor = curBullish ? bullMomColor : bearMomColor
if bullCross
    momColor := bullMomColor
if bearCross
    momColor := bearMomColor
plot(macdLine, title="Momentum", color=color.new(momColor, 0), linewidth=2)
plot(signalLine, title="Signal", color=color.new(signalLineColor, 0), linewidth=2)
hline(0, "Zero Line", color=color.new(color.blue, 50), linestyle=hline.style_dotted, linewidth=1)

// HTF-confirmed cross markers
plotshape(htfConfirmedBull, title="Bull Cross", location=location.bottom, style=shape.triangleup, size=size.small, color=color.green)
plotshape(htfConfirmedBear, title="Bear Cross", location=location.top, style=shape.triangledown, size=size.small, color=color.red)

// Zero line cross markers
plotshape(zeroCrossUp, title="Zero Cross Up", location=location.bottom, style=shape.circle, size=size.tiny, color=color.aqua)
plotshape(zeroCrossDown, title="Zero Cross Down", location=location.top, style=shape.circle, size=size.tiny, color=color.orange)

// ═══════════════════════════════════════════════════════
// INFO TABLE
// ═══════════════════════════════════════════════════════
if showTable and barstate.islast
    tPos = switch tablePos
        "Top Right"   => position.top_right
        "Top Left"    => position.top_left
        "Bottom Left" => position.bottom_left
        => position.bottom_right

    t = table.new(tPos, 2, 4, bgcolor = color.new(tableBoxColor, tableBoxTransp), border_color = color.gray, border_width = 1, frame_color = color.gray, frame_width = 1)

    // Header row
    table.cell(t, 0, 0, "mohit Momentum", text_color=tableHeaderTextColor, text_size=size.small, bgcolor=color.new(color.gray, 60), text_halign=text.align_center)
    table.cell(t, 1, 0, "Status", text_color=tableHeaderTextColor, text_size=size.small, bgcolor=color.new(color.gray, 60), text_halign=text.align_center)

    // Current TF row
    curLabel = curBullish ? (aboveZero ? "▲ Strong Bull" : "▲ Weak Bull") : (belowZero ? "▼ Strong Bear" : "▼ Weak Bear")
    curColor = curBullish ? color.green : color.red
    table.cell(t, 0, 1, "Current TF", text_color=tableTextColor, text_size=size.small)
    table.cell(t, 1, 1, curLabel, text_color=curColor, text_size=size.small)

    // HTF row
    htfLabel = htfBullish ? "▲ Bullish" : htfBearish ? "▼ Bearish" : "— Neutral"
    htfColor = htfBullish ? color.green : htfBearish ? color.red : color.gray
    htfTitle = htfEnable ? "HTF (" + htfTF + ")" : "HTF (off)"
    table.cell(t, 0, 2, htfTitle, text_color=tableTextColor, text_size=size.small)
    table.cell(t, 1, 2, htfLabel, text_color=htfColor, text_size=size.small)

    // Signal state row
    sigLabel = fullyBullish ? "✅Confirmed Bull" : fullyBearish ? "🚫Confirmed Bear" : "⚠️Conflicting"
    sigColor = fullyBullish ? color.green : fullyBearish ? color.red : color.orange
    table.cell(t, 0, 3, "Signal", text_color=tableTextColor, text_size=size.small)
    table.cell(t, 1, 3, sigLabel, text_color=sigColor, text_size=size.small)

// ═══════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════
alertcondition(htfConfirmedBull, "Bull Cross + HTF Confirmed", "mohit Momentum: Bullish cross confirmed by Higher Timeframe!")
alertcondition(htfConfirmedBear, "Bear Cross + HTF Confirmed", "mohit Momentum: Bearish cross confirmed by Higher Timeframe!")
alertcondition(bullCross, "Bull Cross", "mohit Momentum: Green crossed above Red")
alertcondition(bearCross, "Bear Cross", "mohit Momentum: Green crossed below Red")
alertcondition(zeroCrossUp, "Zero Line Cross Up", "mohit Momentum: Momentum crossed above zero line")
alertcondition(zeroCrossDown, "Zero Line Cross Down", "mohit Momentum: Momentum crossed below zero line")
````
