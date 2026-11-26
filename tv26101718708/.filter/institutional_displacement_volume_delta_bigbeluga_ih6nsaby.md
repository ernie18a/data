# Institutional Displacement & Volume Delta [Bigbeluga]

- url: https://www.tradingview.com/script/IH6NsaBY-Institutional-Displacement-Volume-Delta-Bigbeluga/
- type: indicator
- pine_id: PUB;b1d2c3be07404ba59e376719c6611fcd
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]  
[b]Institutional Displacement & Volume Delta [BigBeluga][/b] is an advanced price action tool designed to identify high-conviction market moves, often referred to as "Displacement." It filters out market noise by highlighting candles that exhibit both significant price expansion and institutional-level volume.

By utilizing lower timeframe (LTF) data, the indicator deconstructs each displacement candle to reveal the internal "Buy vs. Sell" volume balance, allowing traders to see the true intent behind aggressive market shifts.

[b]🔵 CONCEPT[/b]  
[list]
[*] Institutional Displacement — Identifies "Power Candles" that have a large body relative to their wicks, signaling a one-sided move by major market participants.
[*] Volume Spike Filtering — Only qualifies a move as a "Shift" if the volume significantly exceeds a user-defined moving average.
[*] Intrabar Volume Deconstruction — Uses a secondary, lower timeframe (e.g., 1m) to calculate exactly how much of a candle's total volume was dedicated to buying versus selling.
[*] Internal Volume Blocks — Visually splits the body of displacement candles into color-coded sections (Buy Block and Sell Block) based on the internal delta ratio.
[*] Market State Muting — Optionally mutes the color of "choppy" or low-volume bars to keep the focus purely on high-probability institutional activity.
[/list]

[b]🔵 HOW IT WORKS (IN-DEPTH)[/b]

[b]1️⃣ Qualification of Displacement[/b]  
[list]
[*] The script first evaluates the "Body-to-Range" ratio. A candle must be mostly "body" (minimal wicks) to prove that the price didn't face significant rejection.
[*] It then checks the Volume Multiplier. The volume must be [b]X[/b] times higher than the 20-period average to confirm institutional "heavy lifting."
[*] If both conditions are met, the bar is labeled a "Bullish Shift" or "Bearish Shift."
[image]https://www.tradingview.com/x/k9LpVKbW/[/image]
[/list]

[b]2️⃣ Lower Timeframe (LTF) Volume Analysis[/b]  
[list]
[*] Standard candles only show total volume. This indicator uses [b]request.security_lower_tf[/b] to peak inside the bar.
[*] It sums up every 1-minute (or user-defined) sub-candle to categorize volume as "Buy" or "Sell" based on the sub-candle's closing direction.
[*] This calculation provides the [b]Delta[/b]—the net difference between aggressive buyers and sellers.
[image]https://www.tradingview.com/x/j4STEnkH/[/image]
[/list]

[b]3️⃣ Visual Representation[/b]  
[list]
[*] The main candle body is hollowed out, and a "Volume Block" is inserted inside. 
[*] The split point of the inner block represents the ratio of Buy vs. Sell volume. If a Bullish Displacement bar has a large Red inner block at the top, it may signal that sellers were heavily defending that area despite the bullish close.
[*] Floating labels provide immediate access to the exact Volume and Delta figures.
[image]https://www.tradingview.com/x/lHZ2J6WY/[/image]
[/list]

[b]🔵 KEY FEATURES[/b]  
[list]
[*] Precise Shift Identification: Combines price expansion (Displacement) with volume spikes.
[*] Internal Delta Blocks: Unique visual deconstruction of candle volume ratios.
[*] Institutional Dashboard: Displays real-time data for the most recent shift, including total volume, delta, and a session shift counter.
[*] Muted Chop Mode: Grey-scales non-significant candles to highlight the "Path of Least Resistance."
[image]https://www.tradingview.com/x/mQ3FTaOs/[/image]
[*] Error Handling: Built-in notification if the user selects an LTF timeframe that is mathematically incompatible with the current chart.
[image]https://www.tradingview.com/x/3Wv86xmd/[/image]
[/list]

[b]🔵 DASHBOARD METRICS[/b]  
[list]
[*] Last Shift: Indicates the direction (Bullish/Bearish) of the most recent displacement.
[*] Shift Vol: The total volume transacted during the most recent high-conviction move.
[*] Shift Δ: The net delta of the last shift, showing the dominant aggressive party.
[*] Shift Count: A running tally of Bullish vs. Bearish shifts since the chart was loaded.
[image]https://www.tradingview.com/x/3ecrWo6x/[/image]
[/list]

[b]🔵 HOW TO USE[/b]  
[list]
[*] Identifying Ignition: A Displacement bar appearing at a support or resistance level often marks the start of a new trend (Trend Ignition).
[*] Spotting Traps: Look for "Bullish Shifts" where the [b]Sell Block[/b] makes up a large portion of the candle body. This indicates heavy absorption by sellers and may lead to a failed breakout.
[*] Confluence with Delta: Use the Dashboard's "Shift Δ" to confirm that the displacement move is backed by strong net buying/selling rather than just high-volume churn.
[*] Exit Timing: If price enters a consolidation zone and the "Shift Count" starts alternating rapidly between Bullish and Bearish, it indicates institutional indecision.
[/list]

[b]🔵 CONCLUSION[/b]  
[b]Institutional Displacement & Volume Delta [BigBeluga][/b] provides a specialized lens into market momentum. By focusing on displacement and the internal mechanics of volume, it helps traders align themselves with the "smart money" and avoid the low-probability volatility of retail-driven noise.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator('Institutional Displacement & Volume Delta [Bigbeluga]', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
grp_disp = 'Displacement Settings'
volLen = input.int(20, title = 'Volume SMA Length', group = grp_disp, tooltip = 'Length for the volume moving average.')
volMult = input.float(2, title = 'Volume Spike Multiplier', step = 0.1, group = grp_disp, tooltip = '1.5 means volume must be 50% above average to qualify as a Shift.')
bodyPct = input.float(50.0, title = 'Minimum Body %', step = 5.0, group = grp_disp, tooltip = 'The candle body must make up at least this % of the entire high-to-low range.')

grp_intra = 'Intrabar Volume Settings'
ltf = input.timeframe('1', title = 'Lower Timeframe for Vol', group = grp_intra, tooltip = 'The timeframe used to calculate buy/sell volume inside the candle. Default is 1m.')

grp_vis = 'Visual Settings'
col_bull = input.color(#0077e6, title = 'Bullish Shift Color', group = grp_vis)
col_bear = input.color(#e91414, title = 'Bearish Shift Color', group = grp_vis)
col_in_B = input.color(#0077e6, title = 'Inner Buy Block Color', group = grp_vis)
col_in_S = input.color(#e91414, title = 'Inner Sell Block Color', group = grp_vis)
col_mute = input.color(color.new(#575757, 0), title = 'Muted Chop Color', group = grp_vis)
showMute = input.bool(true, title = 'Mute Non-Shift Candles', group = grp_vis, tooltip = 'Turn off to keep standard candle colors for non-shift bars.')

grp_dash = 'Dashboard Settings'
showDash = input.bool(true, title = 'Show Dashboard', group = grp_dash)
dashPos  = input.string("Bottom Right", title="Dashboard Position", options=["Top Right", "Bottom Right", "Bottom Left"], group = grp_dash)
// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
// 1. Timeframe Error Handling Logic
isValidTF = timeframe.in_seconds(ltf) < timeframe.in_seconds(timeframe.period)

up_vol_tf = close > open ? volume : 0
dn_vol_tf = close < open ? volume : 0

// Initialize empty arrays so the script doesn't crash if isValidTF is false
float[] up_vol_arr = array.new_float(0)
float[] dn_vol_arr = array.new_float(0)

// Only request lower TF data if the input timeframe is mathematically lower than the chart
if isValidTF
    up_vol_arr := request.security_lower_tf(syminfo.tickerid, ltf, up_vol_tf)
    dn_vol_arr := request.security_lower_tf(syminfo.tickerid, ltf, dn_vol_tf)

buyVol = array.size(up_vol_arr) > 0 ? array.sum(up_vol_arr) : 0
sellVol = array.size(dn_vol_arr) > 0 ? array.sum(dn_vol_arr) : 0
totalIntraVol = buyVol + sellVol

deltaVol = buyVol - sellVol
deltaStr = (deltaVol >= 0 ? "+" : "") + str.tostring(deltaVol, format.volume)

avgVol = ta.sma(volume, volLen)
highVol = volume > avgVol * volMult

candleRange = high - low
candleBody = math.abs(close - open)
bodyRatio = candleRange == 0 ? 0 : candleBody / candleRange

isDisplacement = bodyRatio >= bodyPct / 100

bullShift = close > open and highVol and isDisplacement
bearShift = close < open and highVol and isDisplacement
isShift = bullShift or bearShift

buyRatio = totalIntraVol > 0 ? buyVol / totalIntraVol : 0.5
bodyTop = math.max(open, close)
bodyBot = math.min(open, close)
splitPrice = bodyBot + candleBody * buyRatio 

// --- DASHBOARD DATA TRACKING ---
var string lastDir = "WAITING"
var float  lastVol = 0
var float  lastDelta = 0
var color  lastCol = color.gray
var int    bullCount = 0
var int    bearCount = 0

if bullShift
    lastDir := "BULLISH"
    lastVol := volume
    lastDelta := deltaVol
    lastCol := col_bull
    bullCount += 1
else if bearShift
    lastDir := "BEARISH"
    lastVol := volume
    lastDelta := deltaVol
    lastCol := col_bear
    bearCount += 1
// }

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
var color borderCol = na
var color bodyCol = na

if bullShift
    borderCol := col_bull
    bodyCol := color.new(col_bull, 100) 
else if bearShift
    borderCol := col_bear
    bodyCol := color.new(col_bear, 100) 
else
    borderCol := showMute ? col_mute : na
    bodyCol := showMute ? col_mute : na

plotcandle(open, high, low, close, title = 'Main Candles', color = bodyCol, wickcolor = borderCol, bordercolor = borderCol)

plotcandle(isShift ? bodyBot : na, isShift ? splitPrice : na, isShift ? bodyBot : na, isShift ? splitPrice : na, title = 'Buy Vol Block', color = col_in_B, bordercolor = col_in_B, wickcolor = na)

plotcandle(isShift ? splitPrice : na, isShift ? bodyTop : na, isShift ? splitPrice : na, isShift ? bodyTop : na, title = 'Sell Vol Block', color = col_in_S, bordercolor = col_in_S, wickcolor = na)

atrOffset = ta.atr(14) * 0.6
bearY = high
bullY = low

plotshape(bearShift ? bearY : na, title = 'Bearish Outer', style = shape.circle, location = location.absolute, color = color.new(col_bear, 80), size = size.small)
plotshape(bearShift ? bearY : na, title = 'Bearish Inner', style = shape.circle, location = location.absolute, color = col_bear, size = size.tiny)

plotshape(bullShift ? bullY : na, title = 'Bullish Outer', style = shape.circle, location = location.absolute, color = color.new(col_bull, 80), size = size.small)
plotshape(bullShift ? bullY : na, title = 'Bullish Inner', style = shape.circle, location = location.absolute, color = col_bull, size = size.tiny)

if bearShift
    line.new(x1 = bar_index, y1 = high, x2 = bar_index + 5, y2 = high, color = color.new(col_bear, 30), style = line.style_dashed, width = 1)
    
    bearLblText = str.tostring(-volume, format.volume) + "\nΔ " + deltaStr
    bearTipText = "Bearish Shift\nExact Total Volume: " + str.tostring(volume) + "\nExact Delta: " + str.tostring(deltaVol)
    label.new(x = bar_index + 5, y = high, text = bearLblText, color = color.new(col_bear, 80), textcolor = col_bear, style = label.style_label_center, size = size.auto, tooltip = bearTipText)

if bullShift
    line.new(x1 = bar_index, y1 = low, x2 = bar_index + 5, y2 = low, color = color.new(col_bull, 30), style = line.style_dashed, width = 1)
    
    bullLblText = "+" + str.tostring(volume, format.volume) + "\nΔ " + deltaStr
    bullTipText = "Bullish Shift\nExact Total Volume: " + str.tostring(volume) + "\nExact Delta: " + str.tostring(deltaVol)
    label.new(x = bar_index + 5, y = low, text = bullLblText, color = color.new(col_bull, 80), textcolor = col_bull, style = label.style_label_center, size = size.auto, tooltip = bullTipText)

if isShift
    sellTipText = "Exact Sell Volume: " + str.tostring(sellVol)
    label.new(x = bar_index, y = math.avg(splitPrice, bodyTop), text = 'S: ' + str.tostring(sellVol, format.volume), color = color.new(color.white, 100), textcolor = color.white, style = label.style_none, size = size.auto, tooltip = sellTipText)

    buyTipText = "Exact Buy Volume: " + str.tostring(buyVol)
    label.new(x = bar_index, y = math.avg(bodyBot, splitPrice), text = 'B: ' + str.tostring(buyVol, format.volume), color = color.new(color.white, 100), textcolor = color.white, style = label.style_none, size = size.auto, tooltip = buyTipText)
// }

// ＤＡＳＨＢＯＡＲＤ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
// Error Handler
var errTable = table.new(position.top_center, 1, 1)
if barstate.islast
    if not isValidTF
        errMessage = "⚠️ ERROR: Intrabar TF (" + ltf + ") must be lower than Chart TF (" + timeframe.period + ")"
        table.cell(errTable, 0, 0, errMessage, bgcolor = color.new(#FF9800, 10), text_color = color.white, text_size = size.normal)
    else
        table.clear(errTable, 0, 0)

// Stats Dashboard
var string pos = dashPos == "Top Right" ? position.top_right : dashPos == "Bottom Left" ? position.bottom_left : position.bottom_right
var dashTable = table.new(pos, 2, 5, border_color = color.new(#575757, 80), border_width = 1, frame_color = color.new(#575757, 60), frame_width = 1, bgcolor = color.new(#131722, 15))

if barstate.islast and showDash and isValidTF
    // Header
    
    table.merge_cells(dashTable, 0, 0, 1, 0)
    table.cell(dashTable, 0, 0, "INSTITUTIONAL DATA", text_color = color.white, text_size = size.normal, text_halign = text.align_center)

    // Row 1: Last Shift Direction
    table.cell(dashTable, 0, 1, "Last Shift", text_color = color.new(color.white, 30), text_size = size.normal, text_halign = text.align_left)
    table.cell(dashTable, 1, 1, lastDir, text_color = lastCol, text_size = size.normal, text_halign = text.align_right)
    
    // Row 2: Last Shift Volume
    table.cell(dashTable, 0, 2, "Shift Vol", text_color = color.new(color.white, 30), text_size = size.normal, text_halign = text.align_left)
    table.cell(dashTable, 1, 2, str.tostring(lastVol, format.volume), text_color = color.white, text_size = size.normal, text_halign = text.align_right)

    // Row 3: Last Shift Delta
    deltaStrDash = (lastDelta >= 0 ? "+" : "") + str.tostring(lastDelta, format.volume)
    table.cell(dashTable, 0, 3, "Shift Δ", text_color = color.new(color.white, 30), text_size = size.normal, text_halign = text.align_left)
    table.cell(dashTable, 1, 3, deltaStrDash, text_color = lastDelta > 0 ? col_bull : col_bear, text_size = size.normal, text_halign = text.align_right)

    // Row 4: Shift Counter (Session/Loaded Bars)
    countText = str.tostring(bullCount) + " Bull | " + str.tostring(bearCount) + " Bear"
    table.cell(dashTable, 0, 4, "Shift Count", text_color = color.new(color.white, 30), text_size = size.normal, text_halign = text.align_left)
    table.cell(dashTable, 1, 4, countText, text_color = color.white, text_size = size.normal, text_halign = text.align_right)
// }
````
