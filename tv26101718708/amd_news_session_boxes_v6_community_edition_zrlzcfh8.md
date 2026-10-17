# AMD + News Session Boxes v6 (Community Edition)

- url: https://www.tradingview.com/script/ZRLZCFH8-AMD-News-Session-Boxes-v6-Community-Edition/
- type: indicator
- pine_id: PUB;070d56bb121f4e3fa3fcac64d07a41d0
- version: 1.0

## Description

TradingView Community Description (ICT AMD Blueprint Strategy)
The Story of the Daily Power of Three (PO3)

In Inner Circle Trader (ICT) concepts, institutional order flow delivers price through a precise daily algorithm known as the Power of Three (PO3): Accumulation, Manipulation, and Distribution. Smart Money constructs these cycles to engineer liquidity, trigger retail stop losses, and expand price toward structural targets.

This script perfectly prints this institutional signature directly onto your intraday workspace, complete with an integrated algorithmic anchor line—the VWAP.

The Algorithmic Breakdown
1. 🟣 The Accumulation Phase (18:00 - 02:30 NY Time)

	• Narrative: The algorithm enters a consolidation state during the post-market and early Asian sessions. Here, Smart Money purposefully holds the price within a tight range to accumulate sell positions (if bearish) or buy positions (if bullish). Retail traders view this as a clear support/resistance bracket.

2. 🟢 The Manipulation Phase (02:30 - 09:30 NY Time)

	• Narrative: Spanning the London open through the NY pre-market, the algorithm executes the Judas Swing. It creates a convincing false breakout opposite to the true intended daily trend. This intentional expansion hunts retail sell-stops/buy-stops and triggers breakout algorithms, generating the counterpart liquidity Smart Money requires.

3. 🔵 The High-Impact News Window (08:15 - 08:45 NY Time)

	• Narrative: This isolated 30-minute block highlights where the algorithm utilizes high-impact news releases (CPI, NFP, FOMC) as a catalyst to accelerate the final stage of manipulation or rapidly transition into the real distribution trend.

4. 🟠 The Distribution Phase (09:30 - 17:00 NY Time)
	
	• Narrative: The New York open provides the massive volume expansion where institutional algorithms dump their accumulated positions into the hands of trapped retail breakout traders, sending price flying toward key daily draws on liquidity.

For clean box formatting and ideal algorithmic clarity, run this script exclusively on sub-daily setups like the 1-minute, 3-minute, 5-minute, or 15-minute execution frames.

## Source Code

````pine
//@version=6
indicator("AMD + News Session Boxes v6 (Community Edition)", overlay=true)

// --- Helper function to map string selection to line style ---
get_line_style(string style_str) =>
    switch style_str
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// --- Helper function to map text size string to size constant ---
get_text_size(string size_str) =>
    switch size_str
        "Small" => size.small
        "Large" => size.large
        => size.normal

// ==========================================
// --- GLOBAL CONFIGURATION -----------------
// ==========================================
string global_tz = input.string("America/New_York", title="Global Timezone", tooltip="Default is America/New_York. Change this to track local exchange hours (e.g., UTC, GMT+2, Europe/London)")

// ==========================================
// --- INPUTS: CONFIGURATION GROUPS ---------
// ==========================================

// --- Session 1: Accumulation (18:00 - 02:30) ---
grp1         = "Box 1: Accumulation (18:00 - 02:30)"
color_bg1    = input.color(color.new(color.purple, 92), title="Background Color", group=grp1)
color_brd1   = input.color(color.purple, title="Border Color", group=grp1)
brd_width1   = input.int(0, title="Border Width (px)", minval=0, maxval=5, group=grp1)
brd_style1   = input.string("Solid", title="Border Style", options=["Solid", "Dashed", "Dotted"], group=grp1)
txt_color1   = input.color(color.purple, title="Font Color", group=grp1)
txt_size1    = input.string("Normal", title="Font Size", options=["Small", "Normal", "Large"], group=grp1)
txt_pos1     = input.string("Top", title="Text Position", options=["Top", "Bottom"], group=grp1)

// --- Session 2: Manipulation (02:30 - 09:30) ---
grp2         = "Box 2: Manipulation (02:30 - 09:30)"
color_bg2    = input.color(color.new(color.green, 92), title="Background Color", group=grp2)
color_brd2   = input.color(color.green, title="Border Color", group=grp2)
brd_width2   = input.int(0, title="Border Width (px)", minval=0, maxval=5, group=grp2)
brd_style2   = input.string("Solid", title="Border Style", options=["Solid", "Dashed", "Dotted"], group=grp2)
txt_color2   = input.color(color.green, title="Font Color", group=grp2)
txt_size2    = input.string("Normal", title="Font Size", options=["Small", "Normal", "Large"], group=grp2)
txt_pos2     = input.string("Top", title="Text Position", options=["Top", "Bottom"], group=grp2)

// --- News Box: (08:15 - 08:45) ---
grp_news     = "Box: News (08:15 - 08:45)"
color_bgN    = input.color(color.new(color.blue, 50), title="Background Color", group=grp_news)
color_brdN   = input.color(color.blue, title="Border Color", group=grp_news)
brd_widthN   = input.int(0, title="Border Width (px)", minval=0, maxval=5, group=grp_news)
brd_styleN   = input.string("Solid", title="Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_news)
txt_colorN   = input.color(color.white, title="Font Color", group=grp_news)
txt_sizeN    = input.string("Small", title="Font Size", options=["Small", "Normal", "Large"], group=grp_news)
txt_posN     = input.string("Top", title="Text Position", options=["Top", "Bottom"], group=grp_news)

// --- Session 3: Distribution (09:30 - 17:00) ---
grp3         = "Box 3: Distribution (09:30 - 17:00)"
color_bg3    = input.color(color.new(color.orange, 92), title="Background Color", group=grp3)
color_brd3   = input.color(color.orange, title="Border Color", group=grp3)
brd_width3   = input.int(0, title="Border Width (px)", minval=0, maxval=5, group=grp3)
brd_style3   = input.string("Solid", title="Border Style", options=["Solid", "Dashed", "Dotted"], group=grp3)
txt_color3   = input.color(color.orange, title="Font Color", group=grp3)
txt_size3    = input.string("Normal", title="Font Size", options=["Small", "Normal", "Large"], group=grp3)
txt_pos3     = input.string("Top", title="Text Position", options=["Top", "Bottom"], group=grp3)


// ==========================================
// --- SESSION EVALUATION RUNTIME -----------
// ==========================================

in_session1 = not na(time(timeframe.period, "1800-0230:23456", global_tz))
in_session2 = not na(time(timeframe.period, "0230-0930:23456", global_tz))
in_sessionN = not na(time(timeframe.period, "0815-0845:23456", global_tz))
in_session3 = not na(time(timeframe.period, "0930-1700:23456", global_tz))


// ==========================================
// --- DRAWING LOGIC ENGINE -----------------
// ==========================================

// --- Box 1: Accumulation ---
var box box1 = na
var float hi1 = na
var float lo1 = na
sess1_start = in_session1 and not in_session1[1]

if in_session1
    if sess1_start
        hi1 := high
        lo1 := low
        box1 := box.new(left=bar_index, top=hi1, right=bar_index, bottom=lo1, 
                        bgcolor=color_bg1, border_color=color_brd1, 
                        border_width=brd_width1, border_style=get_line_style(brd_style1),
                        text="Accumulation", text_color=txt_color1, text_size=get_text_size(txt_size1),
                        text_valign=str.lower(txt_pos1), text_halign="left")
    else
        hi1 := math.max(high, hi1)
        lo1 := math.min(low, lo1)
        box.set_top(box1, hi1)
        box.set_bottom(box1, lo1)
        box.set_right(box1, bar_index)

// --- Box 2: Manipulation ---
var box box2 = na
var float hi2 = na
var float lo2 = na
sess2_start = in_session2 and not in_session2[1]

if in_session2
    if sess2_start
        hi2 := high
        lo2 := low
        box2 := box.new(left=bar_index, top=hi2, right=bar_index, bottom=lo2, 
                        bgcolor=color_bg2, border_color=color_brd2, 
                        border_width=brd_width2, border_style=get_line_style(brd_style2),
                        text="Manipulation", text_color=txt_color2, text_size=get_text_size(txt_size2),
                        text_valign=str.lower(txt_pos2), text_halign="left")
    else
        hi2 := math.max(high, hi2)
        lo2 := math.min(low, lo2)
        box.set_top(box2, hi2)
        box.set_bottom(box2, lo2)
        box.set_right(box2, bar_index)

// --- Box: News ---
var box boxN = na
var float hiN = na
var float loN = na
sessN_start = in_sessionN and not in_sessionN[1]

if in_sessionN
    if sessN_start
        hiN := high
        loN := low
        boxN := box.new(left=bar_index, top=hiN, right=bar_index, bottom=loN, 
                        bgcolor=color_bgN, border_color=color_brdN, 
                        border_width=brd_widthN, border_style=get_line_style(brd_styleN),
                        text="News", text_color=txt_colorN, text_size=get_text_size(txt_sizeN),
                        text_valign=str.lower(txt_posN), text_halign="left")
    else
        hiN := math.max(high, hiN)
        loN := math.min(low, loN)
        box.set_top(boxN, hiN)
        box.set_bottom(boxN, loN)
        box.set_right(boxN, bar_index)

// --- Box 3: Distribution ---
var box box3 = na
var float hi3 = na
var float lo3 = na
sess3_start = in_session3 and not in_session3[1]

if in_session3
    if sess3_start
        hi3 := high
        lo3 := low
        box3 := box.new(left=bar_index, top=hi3, right=bar_index, bottom=lo3, 
                        bgcolor=color_bg3, border_color=color_brd3, 
                        border_width=brd_width3, border_style=get_line_style(brd_style3),
                        text="Distribution", text_color=txt_color3, text_size=get_text_size(txt_size3),
                        text_valign=str.lower(txt_pos3), text_halign="left")
    else
        hi3 := math.max(high, hi3)
        lo3 := math.min(low, lo3)
        box.set_top(box3, hi3)
        box.set_bottom(box3, lo3)
        box.set_right(box3, bar_index)
````
