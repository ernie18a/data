# Volatility Squeeze Scanner MTF [StrixEDGE]

- url: https://www.tradingview.com/script/xydyGUMS-Volatility-Squeeze-Scanner-MTF-StrixEDGE/
- type: indicator
- pine_id: PUB;809a8a0eb8734b17892b1ef41e0985d7
- version: 1.0

## Description

Overview

A multi-timeframe volatility squeeze detector that identifies when Bollinger Bands contract inside Keltner Channels across four configurable timeframes simultaneously. The indicator combines squeeze state detection with a LazyBear-method momentum oscillator and a real-time consensus engine, giving traders a structured view of cross-timeframe compression without switching charts.

Volatility squeezes represent periods of contracting price action — energy building before a directional move. Detecting them on a single timeframe is common. Detecting them across multiple timeframes at once isolates the higher-probability setups where compression is structural, not noise.
How It Works

Squeeze Detection
A squeeze fires when the Bollinger Bands (SMA ± standard deviation) fully contract inside the Keltner Channel (SMA ± ATR). This means the upper Bollinger Band is below the upper Keltner Channel AND the lower Bollinger Band is above the lower Keltner Channel. When both conditions hold, volatility has compressed below its average range — the market is coiling.

Bull BIAS https://www.tradingview.com/x/HuUmrBSh/

Bear BIAS https://www.tradingview.com/x/4zV4piGJ/

Momentum Oscillator (LazyBear Method)
The momentum histogram is calculated as the linear regression of the difference between price and the average of the Donchian Channel midline and SMA. This produces a zero-centered oscillator that reveals both the direction and acceleration of momentum inside the squeeze.

The histogram uses a four-tone color scheme:
- Bright green — bullish momentum, accelerating
- Dark green — bullish momentum, decelerating
- Bright red — bearish momentum, accelerating
- Dark red — bearish momentum, decelerating

Squeeze-State Dots
Dots on the zero line change color based on the current chart timeframe's squeeze state:
- Orange dot — squeeze is active (BB inside KC)
- Teal dot — no squeeze (BB outside KC)

The transition from orange to teal marks the moment the squeeze fires — volatility is expanding and the move is underway.

Multi-Timeframe Consensus
The indicator runs the squeeze calculation independently on four user-defined timeframes via `request.security()`. A consensus table displays each timeframe's squeeze state, momentum direction, momentum acceleration, and squeeze duration in real time.

Consensus is reached when the number of timeframes simultaneously in squeeze meets or exceeds the user-defined threshold (default: 3 out of 4). The background subtly highlights when consensus is active, with a brighter flash on the bar where consensus is first reached.

How to Read It

Entry context:
Wait for the consensus row to show 3/4 or 4/4 CONSENSUS — this confirms compression is happening across the timeframe stack, not just locally. The higher the consensus count, the more significant the potential expansion.

Directional bias:
The MOM and DIR columns across timeframes reveal whether momentum is aligned. When most timeframes show BULL + ▲, the bias favors long. When most show BEAR + ▼, the bias favors short. Mixed readings suggest no clear directional edge — patience is warranted.

Timing the release:
Watch the zero-line dots on the current chart timeframe. When the dot transitions from orange (squeeze active) to teal (squeeze released), the coil is unwinding. The histogram's color and direction at that moment indicate the likely direction of the expansion.

Duration as context:
The DUR column shows how many bars each timeframe has been in squeeze. Longer durations generally correspond to larger eventual moves. A fresh squeeze (DUR = 1–3) may still be forming. An extended squeeze (DUR = 15+) is deeply compressed and more likely to produce a significant breakout.

Inputs

Bollinger Bands
- Length — lookback period for the SMA and standard deviation (default: 20)
- Multiplier — standard deviation multiplier for band width (default: 2.0)

https://www.tradingview.com/x/VjlJIvkh/

Keltner Channel
- Length — lookback period for the SMA and ATR (default: 20)
- Multiplier — ATR multiplier for channel width (default: 1.5)

https://www.tradingview.com/x/0veOVe8k/

Timeframes
- Four independently configurable timeframes (default: 5m, 15m, 1H, 4H)
- Choose timeframes that create meaningful structure for your trading style

https://www.tradingview.com/x/0wkvy2Bm/

Consensus
- Minimum TF Consensus — how many timeframes must be in squeeze simultaneously to trigger consensus (2, 3, or 4; default: 3)

https://www.tradingview.com/x/EC8eR4Gg/

Momentum
- Momentum Source — price source for all calculations (Close, Open, High, Low, HL2, HLC3, OHLC4)

https://www.tradingview.com/x/LbNIjsGE/

Alerts

5 alert conditions are available:

- Squeeze Consensus Reached — fires when the minimum TF consensus threshold is first met
- Squeeze Consensus Broken — fires when consensus drops below the threshold
- Consensus + Bullish Bias — consensus active with 3+ timeframes showing positive momentum
- Consensus + Bearish Bias — consensus active with 3+ timeframes showing negative momentum
- Full 4/4 Squeeze — all four timeframes in simultaneous squeeze

https://www.tradingview.com/x/5tBa33Nc/

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Volatility Squeeze Scanner MTF [StrixEDGE]", shorttitle = "Volatility Squeeze Scanner MTF [StrixEDGE]", overlay = false, precision = 4)

// ─── INPUTS ─────────────────────────────────────────────────────────────────

i_bbLen  = input.int(20, "Length", minval = 1, group = "Bollinger Bands")
i_bbMult = input.float(2.0, "Multiplier", minval = 0.1, step = 0.1, group = "Bollinger Bands")

i_kcLen  = input.int(20, "Length", minval = 1, group = "Keltner Channel")
i_kcMult = input.float(1.5, "Multiplier", minval = 0.1, step = 0.1, group = "Keltner Channel")

i_tf1 = input.timeframe("5", "Timeframe 1", group = "Timeframes")
i_tf2 = input.timeframe("15", "Timeframe 2", group = "Timeframes")
i_tf3 = input.timeframe("60", "Timeframe 3", group = "Timeframes")
i_tf4 = input.timeframe("240", "Timeframe 4", group = "Timeframes")

i_minCons = input.int(3, "Minimum TF Consensus", minval = 2, maxval = 4, tooltip = "How many TFs must be in squeeze simultaneously to trigger consensus", group = "Consensus")

i_momSrc = input.string("Close", "Momentum Source", options = ["Open", "High", "Low", "Close", "HL2", "HLC3", "OHLC4"], group = "Momentum")

i_showTbl  = input.bool(true, "Show Consensus Table", group = "Display")
i_tblPos   = input.string("Top Right", "Table Position", options = ["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = "Display")
i_tblSize  = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal", "Large"], group = "Display")

// ─── CONSTANTS ──────────────────────────────────────────────────────────────

C_BG     = color.new(#0d1117, 0)
C_HDR    = color.new(#161b22, 0)
C_BORDER = color.new(#30363d, 0)
C_TEXT   = color.new(#e6edf3, 0)
C_DIM    = color.new(#8b949e, 0)
C_BULL   = color.new(#00E676, 0)
C_BEAR   = color.new(#FF1744, 0)
C_SQZ    = color.new(#FF6D00, 0)
C_NOSQZ  = color.new(#26A69A, 0)
C_BRAND  = color.new(#7C4DFF, 0)

// ─── FUNCTIONS ──────────────────────────────────────────────────────────────

getSrc() =>
    switch i_momSrc
        "Open"  => open
        "High"  => high
        "Low"   => low
        "HL2"   => hl2
        "HLC3"  => hlc3
        "OHLC4" => ohlc4
        => close

calcSqueeze() =>
    src = getSrc()
    bbMid = ta.sma(src, i_bbLen)
    bbDev = i_bbMult * ta.stdev(src, i_bbLen)
    bbUp  = bbMid + bbDev
    bbLo  = bbMid - bbDev
    kcMid = ta.sma(src, i_kcLen)
    kcRng = i_kcMult * ta.atr(i_kcLen)
    kcUp  = kcMid + kcRng
    kcLo  = kcMid - kcRng
    sqz   = bbLo > kcLo and bbUp < kcUp
    dcMid = math.avg(ta.highest(high, i_kcLen), ta.lowest(low, i_kcLen))
    delta = src - math.avg(dcMid, ta.sma(src, i_kcLen))
    mom   = ta.linreg(delta, i_kcLen, 0)
    var int dur = 0
    dur := sqz ? dur + 1 : 0
    [sqz, mom, dur]

getPos() =>
    switch i_tblPos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

getTblSize() =>
    switch i_tblSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

getSubSize() =>
    switch i_tblSize
        "Tiny"   => size.tiny
        "Small"  => size.tiny
        "Normal" => size.small
        "Large"  => size.normal
        => size.tiny

fmtTf(string tf) =>
    secs = timeframe.in_seconds(tf)
    mins = secs / 60
    string result = ""
    if mins < 60
        result := str.tostring(math.round(mins)) + "m"
    else if mins < 1440
        result := str.tostring(math.round(mins / 60)) + "H"
    else if mins < 10080
        result := str.tostring(math.round(mins / 1440)) + "D"
    else if mins < 43200
        result := str.tostring(math.round(mins / 10080)) + "W"
    else
        result := str.tostring(math.round(mins / 43200)) + "M"
    result

// ─── MTF DATA ───────────────────────────────────────────────────────────────

[sqz1, mom1, dur1] = request.security(syminfo.tickerid, i_tf1, calcSqueeze(), lookahead = barmerge.lookahead_off)
[sqz2, mom2, dur2] = request.security(syminfo.tickerid, i_tf2, calcSqueeze(), lookahead = barmerge.lookahead_off)
[sqz3, mom3, dur3] = request.security(syminfo.tickerid, i_tf3, calcSqueeze(), lookahead = barmerge.lookahead_off)
[sqz4, mom4, dur4] = request.security(syminfo.tickerid, i_tf4, calcSqueeze(), lookahead = barmerge.lookahead_off)

[sqzC, momC, durC] = calcSqueeze()

dir1 = mom1 > nz(mom1[1])
dir2 = mom2 > nz(mom2[1])
dir3 = mom3 > nz(mom3[1])
dir4 = mom4 > nz(mom4[1])

// ─── CONSENSUS ──────────────────────────────────────────────────────────────

sqzCount     = (sqz1 ? 1 : 0) + (sqz2 ? 1 : 0) + (sqz3 ? 1 : 0) + (sqz4 ? 1 : 0)
isConsensus  = sqzCount >= i_minCons

int consInt          = isConsensus ? 1 : 0
bool consensusNew    = consInt == 1 and nz(consInt[1], 0) == 0
bool consensusEnd    = consInt == 0 and nz(consInt[1], 0) == 1

bullCount = (mom1 > 0 ? 1 : 0) + (mom2 > 0 ? 1 : 0) + (mom3 > 0 ? 1 : 0) + (mom4 > 0 ? 1 : 0)
bearCount = 4 - bullCount

// ─── HISTOGRAM ──────────────────────────────────────────────────────────────

bool momPositive = momC >= 0
bool momAccel    = momC > nz(momC[1])
bool momDecel    = momC < nz(momC[1])

color momCol = na
if momPositive and momAccel
    momCol := color.new(#00E676, 0)
else if momPositive
    momCol := color.new(#00897B, 0)
else if momDecel
    momCol := color.new(#FF1744, 0)
else
    momCol := color.new(#B71C1C, 0)

plot(momC, "Momentum", style = plot.style_histogram, color = momCol, linewidth = 4)
hline(0, "Zero", color = color.new(#363A45, 0), linestyle = hline.style_dotted)

color sqzDotCol = sqzC ? color.new(#FF6D00, 0) : color.new(#26A69A, 0)
plot(0, "Squeeze State", style = plot.style_circles, color = sqzDotCol, linewidth = 3)

bgcolor(isConsensus ? color.new(#FF6D00, 92) : na, title = "Consensus Active")
bgcolor(consensusNew ? color.new(#FFAB00, 80) : na, title = "Consensus Entry Flash")

// ─── TABLE ──────────────────────────────────────────────────────────────────

var table tbl = table.new(getPos(), 5, 7, bgcolor = C_BG, border_color = C_BORDER, border_width = 1, frame_color = C_BORDER, frame_width = 2)

if i_showTbl and barstate.islast
    // Row 0 - title
    table.cell(tbl, 0, 0, "SQUEEZE SCANNER", text_color = C_BRAND, bgcolor = C_HDR, text_size = getTblSize(), text_halign = text.align_left)
    table.cell(tbl, 1, 0, "", bgcolor = C_HDR)
    table.cell(tbl, 2, 0, "", bgcolor = C_HDR)
    table.cell(tbl, 3, 0, "", bgcolor = C_HDR)
    table.cell(tbl, 4, 0, "[StrixEDGE]", text_color = C_DIM, bgcolor = C_HDR, text_size = getSubSize(), text_halign = text.align_right)
    table.merge_cells(tbl, 0, 0, 3, 0)

    // Row 1 - headers
    table.cell(tbl, 0, 1, "TF", text_color = C_DIM, bgcolor = C_HDR, text_size = getSubSize())
    table.cell(tbl, 1, 1, "SQZ", text_color = C_DIM, bgcolor = C_HDR, text_size = getSubSize())
    table.cell(tbl, 2, 1, "MOM", text_color = C_DIM, bgcolor = C_HDR, text_size = getSubSize())
    table.cell(tbl, 3, 1, "DIR", text_color = C_DIM, bgcolor = C_HDR, text_size = getSubSize())
    table.cell(tbl, 4, 1, "DUR", text_color = C_DIM, bgcolor = C_HDR, text_size = getSubSize())

    // Row 2 - TF1
    string sqzIco1 = sqz1 ? "●" : "○"
    color  sqzClr1 = sqz1 ? C_SQZ : C_NOSQZ
    string momTxt1 = mom1 > 0 ? "BULL" : "BEAR"
    color  momClr1 = mom1 > 0 ? C_BULL : C_BEAR
    string dirTxt1 = dir1 ? "▲" : "▼"
    string durTxt1 = sqz1 ? str.tostring(dur1) : "—"
    color  durClr1 = sqz1 ? C_SQZ : C_DIM
    table.cell(tbl, 0, 2, fmtTf(i_tf1), text_color = C_TEXT, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 1, 2, sqzIco1, text_color = sqzClr1, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 2, 2, momTxt1, text_color = momClr1, bgcolor = C_BG, text_size = getSubSize())
    table.cell(tbl, 3, 2, dirTxt1, text_color = momClr1, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 4, 2, durTxt1, text_color = durClr1, bgcolor = C_BG, text_size = getTblSize())

    // Row 3 - TF2
    string sqzIco2 = sqz2 ? "●" : "○"
    color  sqzClr2 = sqz2 ? C_SQZ : C_NOSQZ
    string momTxt2 = mom2 > 0 ? "BULL" : "BEAR"
    color  momClr2 = mom2 > 0 ? C_BULL : C_BEAR
    string dirTxt2 = dir2 ? "▲" : "▼"
    string durTxt2 = sqz2 ? str.tostring(dur2) : "—"
    color  durClr2 = sqz2 ? C_SQZ : C_DIM
    table.cell(tbl, 0, 3, fmtTf(i_tf2), text_color = C_TEXT, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 1, 3, sqzIco2, text_color = sqzClr2, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 2, 3, momTxt2, text_color = momClr2, bgcolor = C_BG, text_size = getSubSize())
    table.cell(tbl, 3, 3, dirTxt2, text_color = momClr2, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 4, 3, durTxt2, text_color = durClr2, bgcolor = C_BG, text_size = getTblSize())

    // Row 4 - TF3
    string sqzIco3 = sqz3 ? "●" : "○"
    color  sqzClr3 = sqz3 ? C_SQZ : C_NOSQZ
    string momTxt3 = mom3 > 0 ? "BULL" : "BEAR"
    color  momClr3 = mom3 > 0 ? C_BULL : C_BEAR
    string dirTxt3 = dir3 ? "▲" : "▼"
    string durTxt3 = sqz3 ? str.tostring(dur3) : "—"
    color  durClr3 = sqz3 ? C_SQZ : C_DIM
    table.cell(tbl, 0, 4, fmtTf(i_tf3), text_color = C_TEXT, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 1, 4, sqzIco3, text_color = sqzClr3, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 2, 4, momTxt3, text_color = momClr3, bgcolor = C_BG, text_size = getSubSize())
    table.cell(tbl, 3, 4, dirTxt3, text_color = momClr3, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 4, 4, durTxt3, text_color = durClr3, bgcolor = C_BG, text_size = getTblSize())

    // Row 5 - TF4
    string sqzIco4 = sqz4 ? "●" : "○"
    color  sqzClr4 = sqz4 ? C_SQZ : C_NOSQZ
    string momTxt4 = mom4 > 0 ? "BULL" : "BEAR"
    color  momClr4 = mom4 > 0 ? C_BULL : C_BEAR
    string dirTxt4 = dir4 ? "▲" : "▼"
    string durTxt4 = sqz4 ? str.tostring(dur4) : "—"
    color  durClr4 = sqz4 ? C_SQZ : C_DIM
    table.cell(tbl, 0, 5, fmtTf(i_tf4), text_color = C_TEXT, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 1, 5, sqzIco4, text_color = sqzClr4, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 2, 5, momTxt4, text_color = momClr4, bgcolor = C_BG, text_size = getSubSize())
    table.cell(tbl, 3, 5, dirTxt4, text_color = momClr4, bgcolor = C_BG, text_size = getTblSize())
    table.cell(tbl, 4, 5, durTxt4, text_color = durClr4, bgcolor = C_BG, text_size = getTblSize())

    // Row 6 - consensus
    string consText = str.tostring(sqzCount) + "/4 " + (isConsensus ? "CONSENSUS" : "NO CONSENSUS")
    color  consBg   = isConsensus ? color.new(#FF6D00, 80) : C_HDR
    color  consCol  = isConsensus ? C_SQZ : C_DIM

    string biasText = "MIXED"
    color  biasCol  = C_DIM
    if bullCount >= 3
        biasText := "BULL BIAS"
        biasCol  := C_BULL
    else if bullCount <= 1
        biasText := "BEAR BIAS"
        biasCol  := C_BEAR

    table.cell(tbl, 0, 6, consText, text_color = consCol, bgcolor = consBg, text_size = getSubSize(), text_halign = text.align_left)
    table.cell(tbl, 1, 6, "", bgcolor = consBg)
    table.cell(tbl, 2, 6, "", bgcolor = consBg)
    table.cell(tbl, 3, 6, biasText, text_color = biasCol, bgcolor = consBg, text_size = getSubSize(), text_halign = text.align_right)
    table.cell(tbl, 4, 6, "", bgcolor = consBg)
    table.merge_cells(tbl, 0, 6, 2, 6)
    table.merge_cells(tbl, 3, 6, 4, 6)

if not i_showTbl
    table.clear(tbl, 0, 0, 4, 6)

// ─── ALERTS ─────────────────────────────────────────────────────────────────

alertcondition(consensusNew, title = "Squeeze Consensus Reached", message = "StrixEDGE Squeeze Scanner | {{ticker}} {{interval}} | Multi-TF squeeze consensus reached")
alertcondition(consensusEnd, title = "Squeeze Consensus Broken", message = "StrixEDGE Squeeze Scanner | {{ticker}} {{interval}} | Multi-TF squeeze consensus lost")
alertcondition(isConsensus and bullCount >= 3, title = "Consensus + Bullish Bias", message = "StrixEDGE | {{ticker}} {{interval}} | Squeeze consensus with bullish momentum bias")
alertcondition(isConsensus and bullCount <= 1, title = "Consensus + Bearish Bias", message = "StrixEDGE | {{ticker}} {{interval}} | Squeeze consensus with bearish momentum bias")
alertcondition(sqzCount == 4, title = "Full 4/4 Squeeze", message = "StrixEDGE | {{ticker}} {{interval}} | All 4 timeframes in simultaneous squeeze")

// ═══════════════════════════════════════════════════════════════════════════════
````
