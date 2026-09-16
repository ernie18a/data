<!-- tradingview-pine-id: PUB;a6ea53c2eedd4618a14ca6b34b405553 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# HTF Balanced Price Range (BPR)

Source: https://www.tradingview.com/script/9Ylk05RI-HTF-BPR-Balanced-Price-Range/

## Description

Introduction
Within Inner Circle Trader (ICT) concepts, the Balanced Price Range (BPR) is especially important, as it helps to navigate institutional order flow. It pinpoints price zones where opposing market inefficiencies intersect, leaving pools of resting liquidity and unexecuted orders. This indicator automates the identification of these overlapping structures across any asset class while using data from higher (or current) timeframe. 

How is this script different from other similar tools:
- Unique way of presenting BPR zones with focus on clarity and simplicity
- Highly configurable and customizable
- Automatic timeframe selection which always uses next higher timeframe (can be manually overridden)
- It marks BPRs on either higher or current timeframe providing more flexibility
- Uses side box markers which can help to navigate busy charts (can be turned off)
- Option to wait for higher timeframe close before removing BPR from the chart which should eliminate any repainting during mitigation
- Markers are highlighted when price touches BPRs, giving clear indication the price interacts with this BPR

What is BPR
A Balanced Price Range - frequently referred to as a double Fair Value Gap occurs when a bullish FVG and a bearish FVG directly overlap. Because both buyers and sellers created imbalances across the exact same price window, these overlapping zones become high-probability reaction areas. In algorithmic price delivery, BPRs serve as primary rebalancing targets where the market seeks liquidity before expanding or reversing.

What is FVG
FVG or Fair Value Gap is a three-candle formation where the middle candle moves so aggressively creating displacement that it leaves a gap between the wick of the prior candle and the wick of the following candle. 

Trading BPR
BPR entries remain one of the most underrated setup models in ICT trading:
- The Setup: Locate overlapping bullish and bearish FVGs, ideally on the 1-hour to 4-hour timeframes.
- Execution: Wait for price to revisit this overlap following a confirmed Market Structure Shift (MSS). The reaction inside this confluence is usually immediate and sharp.
- The Edge: While average retail traders trade single FVGs in isolation, entering at the intersection captures the compound liquidity of both imbalances.

The Underlying Mechanics
- Single Inefficiencies: A standard Fair Value Gap represents one-sided delivery—a rapid displacement where either buyers or sellers were largely absent.
- Dual Inefficiencies: A BPR represents a corridor that price aggressively skipped twice — once going up without sellers, and second time going down without buyers.
- Algorithmic Repricing: When price returns to a BPR, the delivery algorithm is repricing an area of double inefficiency. Because both buy-side and sell-side resting orders line up inside this narrow range, retests typically trigger decisive expansion away from the zone.
	
SETTINGS:
- Show HTF BPRs - enable displaying of BPR zones on higher (or current)  timeframe
- Looback - how many previous bars are used to find BPRs	
- Auto Higher timeframe (one step up) - when enabled, the script works using data from the next higher timeframe above the chart's timeframe
- Manual HTF - when the previous option is not enabled, you can select manualy any higher timeframe (or chart TF)
- Wait for HTF Close (no repainting) - BPR is removed from the chart after higher timeframe close (this may take some time on higher timeframes)
- Max BPR Length - max distance between two opposing FVGs which are part of the same BPR
- Stop drawing BPR after X Candles - BPR is removed from the chart after this many bars 
- Fill & Border - BPR decorations settings
- Side Marker & Border - apart from displaying factual BPRs as they are created, the script can also display box side markers
- Marker Position - define where the markers should be displayed (and their width)
- Mitigated BPR Boxes - select what happens when BPR is fully mitigated (the price closes through it). When "Remove" is selected, the corresponding Marker is removed as well. "Highlight" and "Display" options don't apply to the Markers.

-----------------
Disclaimer

The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dub4art

//@version=6
indicator('HTF Balanced Price Range (BPR)', 'HTFBPRT', overlay = true, max_boxes_count = 500, max_lines_count =  500)

var g_HTFBPR = "HTF BPR - Balanced Price Range"
show_HTFBPR        = input.bool(true, title = 'Show HTF BPRs      ', inline = 'bpra', group = g_HTFBPR)
bar_count       = input.int(1000, title = 'Lookback', maxval=4000, inline = 'bpra', group = g_HTFBPR, tooltip = "How many bars are used for finding valid BPRs. Max = 4000")
autoHTF         = input.bool(true, 'Auto Higher Timeframe (one step up)', group=g_HTFBPR, tooltip="When enabled, automatically uses the next higher timeframe above the chart's timeframe (e.g. 1m->5m, 5m->15m, 15m->1H, 1H->4H, sub-1m->1m). Disable to use the manual timeframe below.")
tf              = input.timeframe("", "Manual HTF", group=g_HTFBPR, tooltip="Manual timeframe to calculate BPRs on (used only when Auto Higher Timeframe is disabled)")
wait4HTC        = input(true, title="Wait for HTF Close (no repainting)", group=g_HTFBPR, tooltip = "BPR is removed from memory after HTF close. This may take some time on longer timeframes.")
lookback        = input.int(100, 'Max BPR Length', maxval = 400, group=g_HTFBPR, tooltip = "BPR Length = Max distance between two FVGs being part of the same BPR. Max = 100")
closeBPR        = input.int(500, 'Stop Drawing BPR after X Candles', group=g_HTFBPR) //use time (ms) for length limits in MTF, so this input is approximate "candles of current TF"
bullBPRCol      = input.color(color.new(color.aqua,100), 'Fill', inline = 'htfbpr1', group=g_HTFBPR)
bearBPRCol      = input.color(color.rgb(255,30,170, 100), '', inline = 'htfbpr1', group=g_HTFBPR)
bull_border      = input.color(color.new(color.aqua,50), 'Border', inline = 'htfbpr1', group=g_HTFBPR)
bear_border      = input.color(color.rgb(255,30,170, 50), '', inline = 'htfbpr1', group=g_HTFBPR)
htfbpr_style     = input.string(defval=line.style_dashed, options=[line.style_dashed, line.style_dotted, line.style_solid], title = "", inline='htfbpr1', group = g_HTFBPR)
bpr_width        = input.int(2, '', inline = 'htfbpr1', group=g_HTFBPR)
show_marker      = input.bool(true, title = 'Side Marker      ', inline = 'htfbpr2', group = g_HTFBPR, tooltip = "Shows marker box on the side at the level of active BPR level. Applies only to active BPRs (not mitigated)")
bullBPRMCol      = input.color(color.new(color.aqua,80), 'Fill', inline = 'htfbpr2', group=g_HTFBPR)
bearBPRMCol      = input.color(color.rgb(255,30,170, 80), '', inline = 'htfbpr2', group=g_HTFBPR)
bull_M_border   = input.color(color.new(color.aqua,100), 'Border', inline = 'htfbpr2', group=g_HTFBPR)
bear_M_border   = input.color(color.rgb(255,30,170, 100), '', inline = 'htfbpr2', group=g_HTFBPR)
x1              = input.int(8, 'Marker Position', inline = 'htfbpr3', group = g_HTFBPR, tooltip = "Coordinates of HTF BPR Marker Boxes. Each value represents bar offset from current bar.")
x2              = input.int(9, '', inline = 'htfbpr3', group = g_HTFBPR)
x3              = input.int(10, '', inline = 'htfbpr3', group = g_HTFBPR)
filledBpr       = input.string('Remove', 'Mitigated BPR Boxes', ['Remove', 'Highlight', 'Display'], inline = 'htfbpr4', group=g_HTFBPR)
bCol            = input.color(color.silver, '', inline = 'htfbpr4', group=g_HTFBPR)

htfbpr_switch = last_bar_index - bar_index <= bar_count

type bpr
    bool a = false    
    bool bull = true  
    int start_time    
    float top         
    float bottom      
    box bx            
    box marker
    line ln1
    line ln2

f_security(_symbol, _res, _src, _repaint) => 
    request.security(_symbol, _res, _src[_repaint ? barstate.isrealtime ? 1 : 0 : 0])[_repaint ? barstate.isrealtime ? 0 : 1 : 0]

resolve_auto_tf() =>
    string result = tf
    if timeframe.isseconds
        result := "1"
    else if timeframe.isminutes
        curMin = timeframe.multiplier
        if curMin < 5
            result := "5"
        else if curMin < 15
            result := "15"
        else if curMin < 60
            result := "60"
        else if curMin < 240
            result := "240"
        else
            result := "1D"
    else if timeframe.isdaily
        result := "1W"
    else if timeframe.isweekly
        result := "1M"
    else
        result := tf
    result

tf_label(string tfId) =>
    string result = tfId
    if tfId == "1"
        result := "1"
    else if tfId == "5"
        result := "5"
    else if tfId == "15"
        result := "15"
    else if tfId == "60"
        result := "1H"
    else if tfId == "240"
        result := "4H"
    else if tfId == "1D" or tfId == "D"
        result := "D"
    else if tfId == "1W" or tfId == "W"
        result := "W"
    else if tfId == "1M" or tfId == "M"
        result := "M"
    else
        result := tfId
    result

scan_bpr_levels(lb) =>
    bullishFVG = low > high[2] and close[1] > high[2] 
    bearishFVG = high < low[2] and close[1] < low[2]
    
    var float htf_bull_top = na
    var float htf_bull_bot = na
    var int   htf_bull_start = 0
    var int   htf_bull_create_time = 0
    
    var float htf_bear_top = na
    var float htf_bear_bot = na
    var int   htf_bear_start = 0
    var int   htf_bear_create_time = 0

    if bullishFVG
        p1 = high[2]
        p2 = low
        
        for i = 2 to lb-1
            if bearishFVG[i] and p1 < low[i+2] and p2 > high[i]
                p3 = low[i+2]
                p4 = high[i]
                
                htf_bull_top := math.max(p1, p4)
                htf_bull_bot := math.min(p2, p3)
                htf_bull_start := time[i+2]
                htf_bull_create_time := time
                break

    if bearishFVG
        p1 = low[2]
        p2 = high
        
        for i = 2 to lb-1
            if bullishFVG[i] and p1 > high[i+2] and p2 < low[i]
                p3 = high[i+2]
                p4 = low[i]
                
                htf_bear_top := math.min(p1, p4)
                htf_bear_bot := math.max(p2, p3)
                htf_bear_start := time[i+2]
                htf_bear_create_time := time
                break

    [htf_bull_top, htf_bull_bot, htf_bull_start, htf_bull_create_time, htf_bear_top, htf_bear_bot, htf_bear_start, htf_bear_create_time]

method manageBPR(array<bpr> this, int limit_ms, float htf_close)=>
    bull_zone_claimed = false
    bear_zone_claimed = false

    if this.size() > 0
        for i = this.size() - 1 to 0
            bh = this.get(i)

            if (time - bh.start_time) > limit_ms
                box.delete(bh.bx)
                if show_marker
                    box.delete(bh.marker)
                    line.delete(bh.ln1)
                    line.delete(bh.ln2)
                this.remove(i)
                continue

            inBPRBull = close >= bh.top and close <= bh.bottom
            inBPRBear = close <= bh.top and close >= bh.bottom
            if bh.a
                if show_marker
                    box.set_left(bh.marker,  bh.bull ? bar_index + x1 : bar_index + x2)
                    box.set_right(bh.marker, bh.bull ? bar_index + x2 : bar_index + x3)
                    box.set_text_halign(bh.marker, text.align_center)
                    line.set_x1(bh.ln1, bh.bull ? bar_index + x1 : bar_index + x2)
                    line.set_x2(bh.ln1, bh.bull ? bar_index + x2 : bar_index + x3)
                    line.set_x1(bh.ln2, bh.bull ? bar_index + x1 : bar_index + x2)
                    line.set_x2(bh.ln2, bh.bull ? bar_index + x2 : bar_index + x3)
                    if bh.bull
                        if inBPRBull and not bull_zone_claimed
                            box.set_bgcolor(bh.marker, color.new(bullBPRMCol, 60))
                            bull_zone_claimed := true
                        else
                            box.set_bgcolor(bh.marker, bullBPRMCol)
                    else
                        if inBPRBear and not bear_zone_claimed
                            box.set_bgcolor(bh.marker, color.new(bearBPRMCol, 60))
                            bear_zone_claimed := true
                        else
                            box.set_bgcolor(bh.marker, bearBPRMCol)

            if bh.a and bh.bull and htf_close < bh.top and barstate.isconfirmed
                bh.a := false
                if show_marker
                    box.delete(bh.marker)
                    line.delete(bh.ln1)
                    line.delete(bh.ln2)
                if filledBpr == 'Remove'
                    box.delete(bh.bx)
                    this.remove(i) 
                    continue
                else if filledBpr == 'Highlight'
                    bh.bx.set_border_style(line.style_solid)
                    bh.bx.set_border_width(1)
                    bh.bx.set_border_color(bCol)
                continue 

            if bh.a and not bh.bull and htf_close > bh.top and barstate.isconfirmed
                bh.a := false
                if show_marker
                    box.delete(bh.marker)
                    line.delete(bh.ln1)
                    line.delete(bh.ln2)
                if filledBpr == 'Remove'
                    box.delete(bh.bx)
                    this.remove(i)
                    continue
                else if filledBpr == 'Highlight'
                    bh.bx.set_border_style(line.style_solid)
                    bh.bx.set_border_width(1)
                    bh.bx.set_border_color(bCol)

var bprArr = array.new<bpr>()

effective_tf = autoHTF ? resolve_auto_tf() : tf
[htf_bull_top, htf_bull_bot, htf_bull_start, htf_bull_idx, htf_bear_top, htf_bear_bot, htf_bear_start, htf_bear_idx] = request.security(syminfo.tickerid, effective_tf, scan_bpr_levels(lookback))
htf_close = f_security(syminfo.tickerid, effective_tf, close, wait4HTC)
tf_text = tf_label(effective_tf)

if htf_bull_idx != htf_bull_idx[1] and htf_bull_idx != 0
    if bprArr.size() > 0
        for j = bprArr.size() - 1 to 0
            existing = bprArr.get(j)
            if existing.bull and existing.start_time == htf_bull_start
                box.delete(existing.bx)
                if not na(existing.marker)
                    box.delete(existing.marker)
                if not na(existing.ln1)
                    line.delete(existing.ln1)
                if not na(existing.ln2)
                    line.delete(existing.ln2)
                bprArr.remove(j)
    bprNew = bpr.new(
         a = true, 
         bull = true, 
         start_time = htf_bull_start, 
         top = htf_bull_top, 
         bottom = htf_bull_bot,
         bx = box.new(htf_bull_start, htf_bull_top, time, htf_bull_bot, border_color = bull_border, border_width = bpr_width, border_style = htfbpr_style, bgcolor = bullBPRCol, xloc = xloc.bar_time),
         marker = show_marker ? box.new(bar_index + x1, htf_bull_top, bar_index + x2, htf_bull_bot, border_color = bull_M_border, border_width = 1, bgcolor = bullBPRMCol, text = tf_text, text_size = size.small, text_color = color.new(bull_border,0), text_halign = text.align_right, xloc = xloc.bar_index) : na,
         ln1 = show_marker ? line.new(bar_index + x1, htf_bull_top, bar_index + x2, htf_bull_top, color = color.new(bull_M_border,10), style = line.style_solid, width = 2) : na,
         ln2 = show_marker ? line.new(bar_index + x1, htf_bull_bot, bar_index + x2, htf_bull_bot, color = color.new(bull_M_border,10), style = line.style_solid, width = 2) : na
         )
    bprArr.push(bprNew)

if htf_bear_idx != htf_bear_idx[1] and htf_bear_idx != 0
    if bprArr.size() > 0
        for j = bprArr.size() - 1 to 0
            existing = bprArr.get(j)
            if not existing.bull and existing.start_time == htf_bear_start
                box.delete(existing.bx)
                if not na(existing.marker)
                    box.delete(existing.marker)
                if not na(existing.ln1)
                    line.delete(existing.ln1)
                if not na(existing.ln2)
                    line.delete(existing.ln2)
                bprArr.remove(j)
    bprNew = bpr.new(
         a = true, 
         bull = false, 
         start_time = htf_bear_start, 
         top = htf_bear_top, 
         bottom = htf_bear_bot,
         bx = box.new(htf_bear_start, htf_bear_top, time, htf_bear_bot, border_color = bear_border, border_width = bpr_width, border_style = htfbpr_style, bgcolor = bearBPRCol, xloc = xloc.bar_time),
         marker = show_marker ? box.new(bar_index + x2, htf_bear_top, bar_index + x3, htf_bear_bot, border_color = bear_M_border, border_width = 1, bgcolor = bearBPRMCol, text = tf_text, text_size = size.small,  text_color = color.new(bear_border,0), text_halign = text.align_right, xloc = xloc.bar_index) : na,
         ln1 = show_marker ? line.new(bar_index + x2, htf_bear_top, bar_index + x3, htf_bear_top, color = color.new(bear_M_border,10), style = line.style_solid, width = 2) : na,
         ln2 = show_marker ? line.new(bar_index + x2, htf_bear_bot, bar_index + x3, htf_bear_bot, color = color.new(bear_M_border,10), style = line.style_solid, width = 2) : na
         )
    bprArr.push(bprNew)

limit_in_ms = closeBPR * timeframe.in_seconds(timeframe.period) * 1000

if show_HTFBPR and htfbpr_switch
    bprArr.manageBPR(limit_in_ms, htf_close)
````
