# CandelaCharts - Breaker Blocks

- url: https://www.tradingview.com/script/4REEvCCx-CandelaCharts-Breaker-Blocks/
- type: indicator
- pine_id: PUB;a3974378c3674afe8de28bd3ce163ea9
- version: 2.0

## Description

📝 [b]Overview[/b]

Breaker Blocks are a powerful concept popularized by ICT (Inner Circle Trader) and widely used in Smart Money Concepts (SMC) trading. A Breaker Block is essentially a "failed" order block. It forms when the market sweeps a prior high or low to grab liquidity, but then sharply reverses and breaks the pivot that initiated the sweep. The original order block that caused the liquidity sweep then becomes a high-probability mitigation zone—known as a Breaker Block. 

Our [b]CandelaCharts - Breaker Blocks[/b] indicator automatically identifies these complex market structures, drawing the original order block and extending the active Breaker Block zone to help you anticipate high-probability reversals and continuation setups.

📦 [b]Features[/b]

[list]
[*] [b]Automated Detection[/b]: Instantly identifies both Bullish and Bearish Breaker Blocks by analyzing pivot sweeps and structural breaks.
[*] [b]Visual Clarity[/b]: Highlights the original Order Block (gray by default) and extends the mitigated Breaker Block zone (colored) for easy visual reference.
[*] [b]Mean Line[/b]: Automatically draws a dotted mean (50%) line inside the breaker block, a key sensitivity level for price reactions.
[*] [b]Overlap Management[/b]: Optionally removes overlapping breaker blocks to keep your chart clean and focused on the most relevant zones.
[*] [b]Dynamic Clean-up[/b]: Automatically removes mitigated blocks once price breaks and closes completely through them.
[*] [b]Dynamic Ranking & Shading[/b]: Calculates a robust 0-100 score based on Volume, Block Size, Sweep Depth, and Displacement. Ranks range from [i]Prime[/i] (highest) to [i]Weak[/i] (lowest), and the zone's visual opacity dynamically scales to highlight stronger setups.
[/list]

⚙️ [b]Settings[/b]

[list]
[*] [b]Bias[/b]: Filters the detection to show "Neutral" (both directions), "Bullish" only, or "Bearish" only.
[*] [b]Max Blocks[/b]: Limits the maximum number of active breaker blocks displayed simultaneously on the chart.
[*] [b]Pivot Lookback[/b]: Adjusts the lookback period for detecting Pivot Highs and Lows. Increase this value to detect major, higher-timeframe structural breakers, or decrease it for minor, short-term breakers.
[*] [b]Bullish / Bearish Colors[/b]: Fully customize the colors for both the historical Order Block zone and the active Breaker Block zone.
[*] [b]Remove Overlaps[/b]: When enabled, the script will automatically filter out and remove overlapping breaker zones, leaving only the most distinct blocks.
[*] [b]Show Rank[/b]: Toggles the display of the rank text appended directly to the block name (e.g., "Breaker Block (Premium)").
[/list]

⚡️ [b]Showcase[/b]

[i]Bullish Breakers[/i]
https://www.tradingview.com/x/gw6E9Bre/

[i]Bearish Breakers[/i]
https://www.tradingview.com/x/XI8EApZl/

[i]Ranked Breakers[/i]
https://www.tradingview.com/x/F0KE6td0/

🚨 [b]Alerts[/b]

This indicator includes built-in dynamic alerts using TradingView's `alert()` function. You can easily set up an alert on this indicator by selecting "Any alert() function call" in the Create Alert menu. 
[list]
[*] [b]Bullish Breaker Alert[/b]: Fires when a new Bullish Breaker Block is confirmed on bar close. The alert message includes the rank of the block, allowing external filtering for high-probability setups.
[*] [b]Bearish Breaker Alert[/b]: Fires when a new Bearish Breaker Block is confirmed on bar close. The alert message includes the rank of the block.
[/list]

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator(title = "CandelaCharts - Breaker Blocks", shorttitle = "CandelaCharts - Breaker Blocks", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)











// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

colors_teal                         = color.teal
colors_red                          = color.red
colors_white                        = color.white
colors_black                        = color.black
colors_gray                         = color.gray

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

general_font                        = input.string("Monospace", "Text                 ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                        = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General", tooltip = "Customize global text size and style")
general_brand_show                  = input.bool(false, "Hide Brand", group = "General")

bb_bias                             = input.string("Neutral", "Bias              ", options=["Neutral", "Bullish", "Bearish"], group = "Settings")
bb_show_max                         = input.int(3, "Max Blocks       ", inline = "1.0", group = "Settings")
bb_len                              = input.int(5, "Pivot Lookback ", inline = "2.0", group = "Settings")
bb_show_text                        = input.bool(true, "Show Text ", inline = "3.0", group = "Settings")
bb_text_size                        = input.string("Auto", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "3.0", group = "Settings")
bb_show_rank                        = input.bool(false, "Show Rank", inline = "4.0", group = "Settings")
bb_rank_bull_css                    = input.color(color.new(colors_teal, 30), "", inline = "4.0", group = "Settings", tooltip = "Bullish Rank Color")
bb_rank_bear_css                    = input.color(color.new(colors_red, 30), "", inline = "4.0", group = "Settings", tooltip = "Bearish Rank Color")
bb_bull_css                         = input.color(color.new(colors_gray, 80), "Bullish              ", inline = "5.0", group = "Settings")
bb_bull_inv_css                     = input.color(color.new(colors_teal, 60), "", inline = "5.0", group = "Settings")
bb_bear_css                         = input.color(color.new(colors_gray, 80), "Bearish             ", inline = "6.0", group = "Settings")
bb_bear_inv_css                     = input.color(color.new(colors_red, 60), "", inline = "6.0", group = "Settings")
bb_overlap_remove                   = input.bool(false, "Remove Overlaps", group = "Settings")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   UDT   |
// # ========================================================================= #

//#region

type UDT_Pivot
    int   idx
    float p
    bool  broken

type UDT_Breaker
    int   idx
    float top
    float bottom
    bool  is_bull
    bool  mitigated
    box   bx
    box   bx_inv
    box   bx_text
    box   bx_rank
    line  div_ln
    line  mid_ln
    float score
    string rank_name

type UDT_Store
    array<UDT_Breaker> bull_breakers
    array<UDT_Breaker> bear_breakers

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Functions  |
// # ========================================================================= #

//#region

method text_size(string size) =>
    switch size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto

method font_style(string font) =>
    switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace

method notransp(color css) => 
    color.rgb(color.r(css), color.g(css), color.b(css))

overlaps(float top1, float bottom1, float top2, float bottom2) =>
    hi1 = math.max(top1, bottom1)
    lo1 = math.min(top1, bottom1)
    hi2 = math.max(top2, bottom2)
    lo2 = math.min(top2, bottom2)
    math.max(lo1, lo2) <= math.min(hi1, hi2)

method get_rank_name(float score) =>
    score >= 80 ? "Institutional" :
      score >= 60 ? "Superior" :
      score >= 40 ? "Proven" :
      score >= 20 ? "Fair" :
      "Weak"

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Store   |
// # ========================================================================= #

//#region

var UDT_Store store = UDT_Store.new(
     array.new<UDT_Breaker>(),
     array.new<UDT_Breaker>()
 )

method remove_breaker(UDT_Breaker brk) =>
    brk.bx.delete()
    brk.bx_inv.delete()
    if not na(brk.bx_text)
        brk.bx_text.delete()
    if not na(brk.bx_rank)
        brk.bx_rank.delete()
    if not na(brk.div_ln)
        brk.div_ln.delete()
    if not na(brk.mid_ln)
        brk.mid_ln.delete()

method clean_old_breakers(array<UDT_Breaker> arr, int max_size) =>
    while arr.size() > max_size
        brk = arr.pop()
        brk.remove_breaker()

method check_mitigation(UDT_Store s) =>
    if s.bull_breakers.size() > 0
        for i = s.bull_breakers.size() - 1 to 0
            brk = s.bull_breakers.get(i)
            if close < brk.bottom
                brk.remove_breaker()
                s.bull_breakers.remove(i)
                
    if s.bear_breakers.size() > 0
        for i = s.bear_breakers.size() - 1 to 0
            brk = s.bear_breakers.get(i)
            if close > brk.top
                brk.remove_breaker()
                s.bear_breakers.remove(i)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Variables   |
// # ========================================================================= #

//#region

var ph_arr = array.new<UDT_Pivot>()
var pl_arr = array.new<UDT_Pivot>()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Constants   |
// # ========================================================================= #

//#region

int MAX_LOOKBACK = 500

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Core Logic   |
// # ========================================================================= #

//#region

// Ranking Calculations
float spread = high - low
float vol_pct = ta.percentrank(volume, 200)
float spread_pct = ta.percentrank(spread, 200)
float atr = ta.atr(100)

max_bars_back(spread_pct, 1000)
max_bars_back(vol_pct, 1000)
max_bars_back(atr, 1000)

// 1. Detect Pivots
ph = ta.pivothigh(high, bb_len, bb_len)
pl = ta.pivotlow(low, bb_len, bb_len)

if not na(ph)
    ph_arr.unshift(UDT_Pivot.new(bar_index[bb_len], ph, false))
    if ph_arr.size() > 10
        ph_arr.pop()

if not na(pl)
    pl_arr.unshift(UDT_Pivot.new(bar_index[bb_len], pl, false))
    if pl_arr.size() > 10
        pl_arr.pop()

// 2. Process Breaker Logic
store.check_mitigation()

// Bullish Breakers
if (bb_bias == "Neutral" or bb_bias == "Bullish") and ph_arr.size() > 0 and pl_arr.size() > 0
    for i = 0 to ph_arr.size() - 1
        H = ph_arr.get(i)
        bars_h = bar_index - H.idx
        if not H.broken and close > H.p and bars_h > 0 and bars_h < MAX_LOOKBACK
            H.broken := true
            
            // Find LL
            float ll_val = low
            int ll_idx = bar_index
            for j = 0 to bars_h
                if low[j] < ll_val
                    ll_val := low[j]
                    ll_idx := bar_index[j]
                    
            // Find L before H
            UDT_Pivot L = na
            for j = 0 to pl_arr.size() - 1
                if pl_arr.get(j).idx < H.idx
                    L := pl_arr.get(j)
                    break
                    
            // Check Sweep
            if not na(L) and ll_val < L.p
                // Find order block (highest up-candle)
                float ob_top = na
                float ob_btm = na
                int   ob_idx = na
                
                int max_lookback_ob = int(math.min(bars_h + 20, bar_index))
                for j = bars_h to max_lookback_ob
                    if close[j] > open[j]
                        ob_top := high[j]
                        ob_btm := low[j]
                        ob_idx := bar_index[j]
                        break

                if not na(ob_top)
                    // Calculate Rank
                    float ob_score = spread_pct[bar_index - ob_idx]
                    float vol_score = vol_pct[bar_index - ob_idx]
                    float sweep_depth = L.p - ll_val
                    float sweep_score = math.min(100, (sweep_depth / math.max(atr[bar_index - ll_idx], syminfo.mintick)) * 50)
                    float disp_score = spread_pct
                    float total_score = (ob_score + vol_score + sweep_score + disp_score) / 4
                    string rank_name = get_rank_name(total_score)
                    
                    solid_css = bb_bull_css.notransp()
                    solid_inv_css = bb_bull_inv_css.notransp()

                    
                    bx = box.new(ob_idx, ob_top, bar_index, ob_btm, border_color=solid_css, border_style=line.style_solid, bgcolor=bb_bull_css)
                    bx_inv = box.new(bar_index, ob_top, bar_index + 100, ob_btm, border_color=na, bgcolor=bb_bull_inv_css, extend=extend.right)
                    
                    box bx_text = na
                    if bb_show_text
                        bx_text := box.new(bar_index, ob_top, bar_index + 100, ob_btm, border_color=na, bgcolor=color.new(color.white, 100), text="Breaker Block", text_size=text_size(bb_text_size), text_color=solid_inv_css, text_halign=text.align_center, text_valign=text.align_center, text_font_family=font_style(general_font), text_formatting=text.format_bold)
                    
                    line div_ln = na
                    box bx_rank = na
                    if bb_show_rank
                        int txt_right = bb_show_text ? bar_index + 100 : bar_index
                        if bb_show_text
                            div_ln := line.new(txt_right, ob_top, txt_right, ob_btm, color=color.new(color.white, 50), width=1)
                        bx_rank := box.new(txt_right, ob_top, txt_right + 100, ob_btm, border_color=na, bgcolor=color.new(bb_rank_bull_css, color.t(bb_bull_css)), extend=extend.right, text=str.upper(rank_name) + " (" + str.tostring(math.round(total_score)) + "%)", text_size=text_size(bb_text_size), text_color=bb_rank_bull_css.notransp(), text_halign=text.align_center, text_valign=text.align_center, text_font_family=font_style(general_font), text_formatting=text.format_bold)
                    
                    line m_ln = line.new(ob_idx, math.avg(ob_top, ob_btm), bar_index, math.avg(ob_top, ob_btm), color=solid_css, style=line.style_dotted)
                    
                    brk = UDT_Breaker.new(ob_idx, ob_top, ob_btm, true, false, bx, bx_inv, bx_text, bx_rank, div_ln, m_ln, total_score, rank_name)
                    
                    if bb_overlap_remove and store.bull_breakers.size() > 0
                        for idx = store.bull_breakers.size() - 1 to 0
                            existing_brk = store.bull_breakers.get(idx)
                            if overlaps(existing_brk.top, existing_brk.bottom, ob_top, ob_btm)
                                existing_brk.remove_breaker()
                                store.bull_breakers.remove(idx)
                                
                    store.bull_breakers.unshift(brk)
                    alert("Bullish Breaker Block Detected - Rank: " + rank_name + " - Price: " + str.tostring(close), alert.freq_once_per_bar_close)
            
        // Outside the break condition but inside loop, we must always clean up extra breakers
        clean_old_breakers(store.bull_breakers, bb_show_max)

// Bearish Breakers
if (bb_bias == "Neutral" or bb_bias == "Bearish") and pl_arr.size() > 0 and ph_arr.size() > 0
    for i = 0 to pl_arr.size() - 1
        L = pl_arr.get(i)
        bars_l = bar_index - L.idx
        if not L.broken and close < L.p and bars_l > 0 and bars_l < MAX_LOOKBACK
            L.broken := true
            
            // Find HH
            float hh_val = high
            int hh_idx = bar_index
            for j = 0 to bars_l
                if high[j] > hh_val
                    hh_val := high[j]
                    hh_idx := bar_index[j]
                    
            // Find H before L
            UDT_Pivot H = na
            for j = 0 to ph_arr.size() - 1
                if ph_arr.get(j).idx < L.idx
                    H := ph_arr.get(j)
                    break
                    
            // Check Sweep
            if not na(H) and hh_val > H.p
                // Find order block (lowest down-candle)
                float ob_top = na
                float ob_btm = na
                int   ob_idx = na
                
                int max_lookback_ob = int(math.min(bars_l + 20, bar_index))
                for j = bars_l to max_lookback_ob
                    if close[j] < open[j]
                        ob_top := high[j]
                        ob_btm := low[j]
                        ob_idx := bar_index[j]
                        break
                            
                if not na(ob_btm)
                    // Calculate Rank
                    float ob_score = spread_pct[bar_index - ob_idx]
                    float vol_score = vol_pct[bar_index - ob_idx]
                    float sweep_depth = hh_val - H.p
                    float sweep_score = math.min(100, (sweep_depth / math.max(atr[bar_index - hh_idx], syminfo.mintick)) * 50)
                    float disp_score = spread_pct
                    float total_score = (ob_score + vol_score + sweep_score + disp_score) / 4
                    string rank_name = get_rank_name(total_score)
                    
                    solid_css = bb_bear_css.notransp()
                    solid_inv_css = bb_bear_inv_css.notransp()

                    
                    bx = box.new(ob_idx, ob_top, bar_index, ob_btm, border_color=solid_css, border_style=line.style_solid, bgcolor=bb_bear_css)
                    bx_inv = box.new(bar_index, ob_top, bar_index + 100, ob_btm, border_color=na, bgcolor=bb_bear_inv_css, extend=extend.right)
                    
                    box bx_text = na
                    if bb_show_text
                        bx_text := box.new(bar_index, ob_top, bar_index + 100, ob_btm, border_color=na, bgcolor=color.new(color.white, 100), text="Breaker Block", text_size=text_size(bb_text_size), text_color=solid_inv_css, text_halign=text.align_center, text_valign=text.align_center, text_font_family=font_style(general_font), text_formatting=text.format_bold)
                    
                    line div_ln = na
                    box bx_rank = na
                    if bb_show_rank
                        int txt_right = bb_show_text ? bar_index + 100 : bar_index
                        if bb_show_text
                            div_ln := line.new(txt_right, ob_top, txt_right, ob_btm, color=color.new(color.white, 50), width=1)
                        bx_rank := box.new(txt_right, ob_top, txt_right + 100, ob_btm, border_color=na, bgcolor=color.new(bb_rank_bear_css, color.t(bb_bear_css)), extend=extend.right, text=str.upper(rank_name) + " (" + str.tostring(math.round(total_score)) + "%)", text_size=text_size(bb_text_size), text_color=bb_rank_bear_css.notransp(), text_halign=text.align_center, text_valign=text.align_center, text_font_family=font_style(general_font), text_formatting=text.format_bold)
                    
                    line m_ln = line.new(ob_idx, math.avg(ob_top, ob_btm), bar_index, math.avg(ob_top, ob_btm), color=solid_css, style=line.style_dotted)
                    
                    brk = UDT_Breaker.new(ob_idx, ob_top, ob_btm, false, false, bx, bx_inv, bx_text, bx_rank, div_ln, m_ln, total_score, rank_name)
                    
                    if bb_overlap_remove and store.bear_breakers.size() > 0
                        for idx = store.bear_breakers.size() - 1 to 0
                            existing_brk = store.bear_breakers.get(idx)
                            if overlaps(existing_brk.top, existing_brk.bottom, ob_top, ob_btm)
                                existing_brk.remove_breaker()
                                store.bear_breakers.remove(idx)
                                
                    store.bear_breakers.unshift(brk)
                    alert("Bearish Breaker Block Detected - Rank: " + rank_name + " - Price: " + str.tostring(close), alert.freq_once_per_bar_close)
            
        clean_old_breakers(store.bear_breakers, bb_show_max)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Brand   |
// # ========================================================================= #

//#region

if barstate.isfirst and general_brand_show == false
    var table brand = table.new(position.bottom_right, 1, 1, bgcolor = chart.bg_color)
    table.cell(brand, 0, 0,  "© CandelaCharts", text_color = colors_gray, text_halign = text.align_center, text_size = text_size(general_text), text_font_family = font_style(general_font))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````
