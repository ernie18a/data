# SMT-Fill [Oracle]

- url: https://www.tradingview.com/script/oPaPzqEG-SMT-Fill-Oracle/
- type: indicator
- pine_id: PUB;4a803da501f3414bbcd1a486af2f95f8
- version: 1.0

## Description

[b]WHAT THIS INDICATOR DOES[/b]

https://www.tradingview.com/x/GOC44l01/

SMT-Fill is a correlation-based fair value gap analysis tool that detects when correlated assets disagree on how they interact with their own imbalances. It identifies FVGs that form simultaneously across multiple correlated assets, then tracks whether each asset trades back into its respective gap — and flags when one asset fills its gap while the other does not.

A standard FVG tells you there is an imbalance. An SMT-Fill tells you there is an imbalance [b]where correlated assets are disagreeing on whether it gets respected[/b] — a crack in correlation at the imbalance level, which increases the probability of a reaction.

https://www.tradingview.com/x/pqDrAUIx/

This is an analysis and narrative tool. It does not generate buy or sell signals.

[b]THE CONCEPTS — WHAT EACH ONE IS AND HOW IT IS CALCULATED[/b]

[b]Fair Value Gaps (FVGs)[/b]

https://www.tradingview.com/x/mrcvTX3t/

A fair value gap is a 3-bar price imbalance where the candle bodies moved so aggressively that a gap was left behind. The indicator detects these using standard FVG logic:

[list]
[] [b]Bullish FVG[/b] — Bar 1's low is above bar 3's high. The gap between these two levels represents an area where price moved up without being fully traded, leaving an imbalance that price may return to fill.
[] [b]Bearish FVG[/b] — Bar 3's low is above bar 1's high. The gap represents a downward imbalance.
[/list]

The indicator does not just detect FVGs on your chart — it simultaneously checks whether the same FVG pattern exists on each of the other assets in your triad at the exact same time, using request.security calls. For each asset where a concurrent FVG exists, it stores that asset's own gap boundaries (high, low, and midpoint) independently.

This means the indicator is tracking up to four versions of the same gap: your chart asset's FVG boundaries and each correlated asset's FVG boundaries, all formed on the same 3-bar window but at each asset's own price levels.

[b]SMT-Fill Divergence Detection[/b]

https://www.tradingview.com/x/eWlViRXi/

This is the core concept. After an FVG forms across multiple assets, the indicator tracks whether price on each asset trades back into its respective gap. An SMT-Fill divergence occurs when one asset trades into its gap while a correlated asset does [b]not[/b] trade into its corresponding gap — the assets disagree on whether the imbalance gets filled.

The indicator monitors three levels within each gap:

[list]
[] [b]High[/b] — The top boundary of the FVG. Has price touched back into the gap at all?

[] [b]Midpoint (50%)[/b] — The equilibrium of the FVG. Has price traded through the halfway point?

[*] [b]Low[/b] — The bottom boundary of the FVG. Has price completely filled the gap?
[/list]

For each level, the indicator maintains a "traded" flag for every asset. On every bar, it checks whether each asset's price has reached that level in its own FVG. A divergence is detected when your chart asset's traded flag differs from a correlated asset's traded flag at any level — meaning one has interacted with the gap at that level while the other has not.

This produces three variants of SMT-Fill, each representing a different degree of divergence:

[list]
[] [b]Variant 1 — Touch divergence.[/b] One asset trades back into the gap (touching the high of the FVG), while the correlated asset fails to trade back into its gap at all.

https://www.tradingview.com/x/gg7S71Pv/

[] [b]Variant 2 — Midpoint divergence.[/b] One asset trades below 50% of its gap, while the correlated asset fails to reach the 50% level of its gap.

https://www.tradingview.com/x/LpsYVn7i/

[*] [b]Variant 3 — Full fill divergence.[/b] One asset completely fills its gap (price reaches the low/high boundary), while the correlated asset fails to completely fill its corresponding gap.
[/list]

https://www.tradingview.com/x/g1PBlBhq/

The indicator prioritises the most significant divergence level when drawing the SMT-Fill line. For bullish gaps, it checks the high level first (has any asset touched the gap while another hasn't), then midpoint, then low. For bearish gaps, it checks low first, then midpoint, then high.

[b]Gap Lifecycle and Cleanup[/b]

Each tracked gap has a defined lifecycle:

[list]
[] [b]Creation[/b] — A 3-bar FVG is detected on your chart, and the same FVG pattern exists on at least one other asset in the triad at the same time.
[] [b]Active tracking[/b] — The indicator monitors whether each asset's price interacts with its own version of the gap at the high, midpoint, and low levels.
[] [b]Divergence display[/b] — When the traded flags disagree between assets at any level, the gap is drawn as a colored box with an optional SMT divergence line at the diverging level.
[] [b]Closure[/b] — When price closes completely through the gap (close below the low for bullish, close above the high for bearish), the gap is automatically deleted from the chart.
[/list]

Gaps where no divergence exists between assets are hidden by default — the indicator only shows FVGs where a crack in correlation has occurred within the imbalance.

[b]SMT-Fill Divergence Line[/b]

https://www.tradingview.com/x/l6Phv4uf/

When a divergence is detected, an optional horizontal line is drawn at the specific level where the disagreement occurs (high, midpoint, or low of the gap). This line marks the exact price level where one asset has interacted with the gap but the other has not — the precise point of the crack in correlation within the imbalance.

The line extends as long as any asset is still interacting with the gap, plus a configurable extension buffer.

[b]HOW THE CONCEPTS WORK TOGETHER[/b]

SMT-Fill is not simply an FVG detector with extra assets overlaid. The concepts form a specific analytical sequence:

[list=1]
[*] [b]Concurrent FVG formation establishes the setup.[/b] A fair value gap must form on your chart asset and on at least one correlated asset at the exact same time. This is the prerequisite — it means both assets experienced the same imbalance event simultaneously, establishing a shared reference point.

[*] [b]Independent fill tracking reveals disagreement.[/b] After the gap forms, each asset's price moves independently. The indicator tracks whether each asset returns to its own gap boundaries. When one fills while the other holds, it reveals that the market is not treating the imbalance the same way across correlated assets — a crack in correlation specifically within the imbalance itself.

[*] [b]The divergence level identifies the price point.[/b] The SMT-Fill line marks exactly where the disagreement is occurring — whether at the gap entry (high), equilibrium (midpoint), or full fill (low). This gives you a specific price level to work with, not just a directional bias.

[*] [b]Gap lifecycle provides context.[/b] Gaps that are fully closed are automatically removed. Only gaps with active divergences are displayed. This keeps the chart clean and focused on the information that matters — where correlated assets are currently disagreeing on imbalance interaction.
[/list]

[b]HOW TO USE IT[/b]

[b]For HTF Bias:[/b]

SMT-Fills on higher timeframes can frame lower timeframe trade ideas. For example, if you expect a bullish weekly candle and see price manipulate down into a daily FVG forming an SMT-Fill, you can assume that manipulation is likely the manipulation for the week — giving you a directional bias and allowing you to frame LTF entries accordingly.

[b]As an Entry Model:[/b]

SMT-Fill can be combined with other Quarterly Theory concepts to build confluence. For example:

[list]
[] SSMT forms, then the first presented gap is an SMT-Fill — higher probability entry
[] A PSP forms, then the first presented gap is an SMT-Fill — confirmed reversal with imbalance divergence
[*] Any ICT entry model that involves an FVG can use SMT-Fill to increase the setup probability by confirming the gap is backed by a correlation crack
[/list]

[b]Step by step:[/b]

[list=1]
[] Add the indicator to your chart. It will automatically detect your asset triad and begin scanning for concurrent FVGs.
[] When an FVG forms on your chart and on at least one correlated asset simultaneously, the indicator begins tracking fill levels on all assets.
[] Once one asset trades into its gap while another does not, a colored box appears showing the SMT-Fill gap with a label indicating which asset is diverging.
[] The SMT-Fill divergence line marks the exact level where the disagreement is occurring.
[*] Gaps are automatically removed when fully closed, keeping your chart clean.
[/list]

[b]WHY THIS IS THIS INDICATOR WORTH USING?[/b]

Without this indicator, identifying an SMT-Fill requires a trader to:

[list]
[] Watch three charts simultaneously and mentally note when FVGs form at the same time across all of them
[] Track the exact high, midpoint, and low of each gap on each asset independently
[] Monitor in real time whether each asset trades back into its own gap at each of these three levels
[] Compare the fill status across assets to determine if a divergence exists
[*] Remember which gaps have been fully closed and which are still active
[/list]

This is practically impossible to do manually in real time across three assets and multiple active gaps. The indicator automates the entire process — concurrent FVG detection, independent multi-level fill tracking across all triad members, divergence flagging, and automatic lifecycle management — into a single overlay.

The SMT-Fill concept itself — tracking whether correlated assets agree or disagree on how they interact with simultaneously-formed imbalances — is an entirely original implementation. No other TradingView indicator detects concurrent FVGs across multiple assets, independently tracks fill levels at three price points per asset, and flags the divergence when assets disagree. This cannot be replicated by combining existing public FVG indicators because they only track a single asset and have no concept of cross-asset fill comparison.

[b]AUTO TRIAD[/b]

https://www.tradingview.com/x/GL2Gxn3T/

The indicator automatically assigns the correct correlated triad based on your chart ticker:

[list]
[] [b]Index Futures:[/b] NQ / ES / YM (+ micro variants MNQ / MES / MYM)
[] [b]FX Indices:[/b] NAS100 / SPX500 / US30
[] [b]Metals (spot):[/b] XAUUSD / XAGUSD / Copper
[] [b]Metals (futures):[/b] GC / SI / HG
[] [b]Forex:[/b] EURUSD / GBPUSD / DXY
[] [b]Currency Futures:[/b] 6E / 6B / DXY
[] [b]Energy:[/b] CL / RB / HO
[] [b]Bonds:[/b] ZF / ZB / TN
[*] [b]Crypto (spot):[/b] BTCUSD / ETHUSD / XRPUSD via Kraken
[/list]

For unsupported tickers, manual configuration is available.

[b]SETTINGS OVERVIEW[/b]

[list]
[] [b]Asset Selection[/b] — Auto triad toggle, manual ticker inputs for three assets
[] [b]General Settings[/b] — Maximum gaps tracked, box extension length
[] [b]Gap Display[/b] — Bullish/bearish toggles, gap colors, border display and width
[] [b]SMT-F Line[/b] — Divergence line toggle, color, style, width
[] [b]Labels and Text[/b] — Asset label toggle, text size, text color, label position
[] [b]Filtering[/b] — Active-only mode (only show gaps while price is interacting)
[*] [b]Watermark[/b] — Position, size, custom phrase
[/list]

INDICATOR SETTINGS/FILTERS

Here is an inside look of how the SMT-Fill [Oracle] looks:

https://www.tradingview.com/x/9U8rYOle/

[b]DISCLAIMER[/b]

[i]This indicator is for educational and informational purposes only. It does not constitute financial advice. Trading involves substantial risk of loss. Always use proper risk management and conduct your own analysis.[/i]

[b]CREDITS[/b]

[i]Developed by Danielliuks (z3nius) and bucko. Conceptual framework based on ICT (Michael Huddleston) and Quarterly Theory as taught by TraderDaye.[/i]

Open Sourced For all.
Enjoy.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Danielliuks
//@version=6
indicator("SMT-Fill [Oracle]", max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, overlay = true)
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// SETTINGS - ASSET CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
use_auto_triad = input.bool(false, 'Auto Triad', tooltip='Automatically set asset triad based on current ticker', group="Asset Selection")
tck1 = input.symbol("CME_MINI:NQ1!", "Asset 1", group="Asset Selection", tooltip="First asset to compare for SMT-F divergence")
tck2 = input.symbol("CME_MINI:ES1!", "Asset 2", group="Asset Selection", tooltip="Second asset to compare for SMT-F divergence")
tck3 = input.symbol("CBOT_MINI:YM1!", "Asset 3", group="Asset Selection", tooltip="Third asset to compare for SMT-F divergence")
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// SETTINGS - GENERAL
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
max_gaps = input.int(20, "Maximum Gaps", minval=1, maxval=100, group="General Settings", tooltip="Maximum number of gaps to track simultaneously")
auto_delete_closed = true
box_extension = input.int(3, "Box Extension (bars)", minval=0, maxval=50, group="General Settings", inline="ext", tooltip="Number of bars to extend boxes into the future while assets are touching")
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// SETTINGS - GAP DISPLAY
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
show_bullish_gaps = input.bool(true, "Bullish Gaps?", group="Gap Display", inline="bull", tooltip="Show bullish fair value gaps")
bull_gap_color = input.color(color.new(#089981, 90), "", group="Gap Display", inline="bull")
show_bearish_gaps = input.bool(true, "Bearish Gaps?", group="Gap Display", inline="bear", tooltip="Show bearish fair value gaps")
bear_gap_color = input.color(color.new(#f23645, 90), "", group="Gap Display", inline="bear")
show_gap_border = input.bool(false, "Show Gap Borders?", group="Gap Display", inline="border", tooltip="Display borders around gap boxes")
gap_border_width = input.int(1, "", minval=1, maxval=5, group="Gap Display", inline="border")
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// SETTINGS - SMT DIVERGENCE LINE
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
show_smt_line = input.bool(true, "SMT-F Divergence Line?", group="SMT-F Line", inline="show_line", tooltip="Show horizontal line at the level where SMT-F divergence occurred")
smt_line_color = input.color(color.new(color.gray, 0), "", group="SMT-F Line", inline="line")
smt_line_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group="SMT-F Line", inline="line")
smt_line_width = input.int(1, "", minval=1, maxval=5, group="SMT-F Line", inline="line")
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// SETTINGS - LABEL & TEXT
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
show_asset_label = input.bool(true, "Show Asset Label?", group="Labels & Text", inline="label", tooltip="Display which asset has the SMT-F divergence")
label_text_size = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Labels & Text", inline="size")
label_text_color = input.color(color.white, "Text Color", group="Labels & Text", inline="color", tooltip="Color of the asset label text")
label_position = input.string("Right", "Label Position", options=["Left", "Center", "Right"], group="Labels & Text", inline="pos", tooltip="Horizontal alignment of the label text")
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// SETTINGS - FILTERING
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
only_show_active = input.bool(false, "Only Show Active Gaps?", group="Filtering", tooltip="Only display gaps while price is actively interacting with them")
hide_no_divergence = true
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// TYPE DEFINITION
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
type Gap
    int idx
    string side
    float l
    float l1
    float l2
    float l3
    float h
    float h1
    float h2
    float h3
    float mid
    float mid1
    float mid2
    float mid3
    bool l_traded
    bool l1_traded
    bool l2_traded
    bool l3_traded
    bool h_traded
    bool h1_traded
    bool h2_traded
    bool h3_traded
    bool mid_traded
    bool mid1_traded
    bool mid2_traded
    bool mid3_traded
    box fvg
    line cic_line_high
    line cic_line_mid
    line cic_line_low
    int last_touching_bar
var gaps = array.new<Gap>()
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
getSymbolOnly(sym) =>
    colonPos = str.pos(sym, ":")
    result = colonPos >= 0 ? str.substring(sym, colonPos + 1, str.length(sym)) : sym
    // Remove common suffixes
    result := str.replace_all(str.replace_all(str.replace_all(result, "1!", ""), "USD", ""), ".USD", "")
    result
getLineStyle(style) =>
    style == "Solid" ? line.style_solid : style == "Dashed" ? line.style_dashed : line.style_dotted
getTextSize(size) =>
    size == "Tiny" ? size.tiny : size == "Small" ? size.small : size == "Normal" ? size.normal : size.large
getTextAlign(pos) =>
    pos == "Left" ? text.align_left : pos == "Center" ? text.align_center : text.align_right
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// AUTO TRIAD LOGIC
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
get_auto_triad() =>
    current_ticker = str.upper(syminfo.ticker)
    clean_ticker = str.replace_all(str.replace_all(str.replace_all(current_ticker, "1!", ""), "USD", ""), ".USD", "")
    
    var string asset1 = "CME_MINI:NQ1!"
    var string asset2 = "CME_MINI:ES1!"
    var string asset3 = "CBOT_MINI:YM1!"
    
    if clean_ticker == "NQ" or clean_ticker == "ES" or clean_ticker == "YM"
        asset1 := "CME_MINI:NQ1!"
        asset2 := "CME_MINI:ES1!"
        asset3 := "CBOT_MINI:YM1!"
    else if clean_ticker == "RTY"
        asset1 := "CME_MINI:NQ1!"
        asset2 := "CME_MINI:ES1!"
        asset3 := "CME_MINI:RTY1!"
    else if clean_ticker == "MNQ" or clean_ticker == "MES" or clean_ticker == "MYM"
        asset1 := "CME_MINI:MNQ1!"
        asset2 := "CME_MINI:MES1!"
        asset3 := "CBOT_MINI:MYM1!"
    else if clean_ticker == "NAS100" or clean_ticker == "SPX500" or clean_ticker == "US30"
        asset1 := "FX:NAS100"
        asset2 := "FX:SPX500"
        asset3 := "FX:US30"
    else if clean_ticker == "XAU" or clean_ticker == "XAG" or clean_ticker == "XCU"
        asset1 := "FX:XAUUSD"
        asset2 := "FX:XAGUSD"
        asset3 := "CAPITALCOM:COPPER"
    else if clean_ticker == "GC" or clean_ticker == "SI" or clean_ticker == "HG"
        asset1 := "COMEX:GC1!"
        asset2 := "COMEX:SI1!"
        asset3 := "COMEX:HG1!"
    else if clean_ticker == "BTC" or clean_ticker == "ETH" or clean_ticker == "XRP"
        asset1 := "KRAKEN:BTCUSD"
        asset2 := "KRAKEN:ETHUSD"
        asset3 := "KRAKEN:XRPUSD"
    else if clean_ticker == "EUR" or clean_ticker == "GBP"
        asset1 := "FX:EURUSD"
        asset2 := "FX:GBPUSD"
        asset3 := "CAPITALCOM:DXY"
    else if clean_ticker == "DXY"
        asset1 := "FX:EURUSD"
        asset2 := "FX:GBPUSD"
        asset3 := "CAPITALCOM:DXY"
    else if clean_ticker == "6E" or clean_ticker == "6B"
        asset1 := "CME:6E1!"
        asset2 := "CME:6B1!"
        asset3 := "CAPITALCOM:DXY"
    else if clean_ticker == "CL" or clean_ticker == "RB" or clean_ticker == "HO"
        asset1 := "NYMEX:CL1!"
        asset2 := "NYMEX:RB1!"
        asset3 := "NYMEX:HO1!"
    else if clean_ticker == "ZF" or clean_ticker == "ZB" or clean_ticker == "TN"
        asset1 := "CBOT:ZF1!"
        asset2 := "CBOT:ZB1!"
        asset3 := "CBOT:TN1!"
    
    [asset1, asset2, asset3]
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// ASSET SELECTION LOGIC
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
[auto_asset1, auto_asset2, auto_asset3] = get_auto_triad()
tck1 := use_auto_triad ? auto_asset1 : tck1
tck2 := use_auto_triad ? auto_asset2 : tck2
tck3 := use_auto_triad ? auto_asset3 : tck3
tck1_str = str.tostring(tck1)
tck2_str = str.tostring(tck2)
tck3_str = str.tostring(tck3)
chart_str = getSymbolOnly(syminfo.tickerid)
if getSymbolOnly(tck1_str) == chart_str
    tck1 := tck2
else if getSymbolOnly(tck2_str) == chart_str
    tck2 := tck1
else if getSymbolOnly(tck3_str) == chart_str
    tck3 := tck1
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// GAP DETECTION - BULLISH
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
if show_bullish_gaps and low[1] > high[3]
    fvg_bull_1 = request.security(tck1, '', low[1] > high[3])
    fvg_bull_2 = request.security(tck2, '', low[1] > high[3])
    fvg_bull_3 = request.security(tck3, '', low[1] > high[3])
    
    if fvg_bull_1 or fvg_bull_2 or fvg_bull_3
        h0 = low[1]
        l0 = high[3]
        h1 = fvg_bull_1 ? request.security(tck1, '', low[1]) : na
        l1 = fvg_bull_1 ? request.security(tck1, '', high[3]) : na
        h2 = fvg_bull_2 ? request.security(tck2, '', low[1]) : na
        l2 = fvg_bull_2 ? request.security(tck2, '', high[3]) : na
        h3 = fvg_bull_3 ? request.security(tck3, '', low[1]) : na
        l3 = fvg_bull_3 ? request.security(tck3, '', high[3]) : na
        
        mid0 = l0 + (h0 - l0) / 2
        mid1 = fvg_bull_1 ? l1 + (h1 - l1) / 2 : na
        mid2 = fvg_bull_2 ? l2 + (h2 - l2) / 2 : na
        mid3 = fvg_bull_3 ? l3 + (h3 - l3) / 2 : na
        
        new_gap = Gap.new(bar_index-2, "bull", l0, l1, l2, l3, h0, h1, h2, h3, mid0, mid1, mid2, mid3, false, false, false, false, false, false, false, false, false, false, false, false, na, na, na, na, bar_index)
        array.push(gaps, new_gap)  
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// GAP DETECTION - BEARISH
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
if show_bearish_gaps and high[1] < low[3]
    fvg_bear_1 = request.security(tck1, '', high[1] < low[3])
    fvg_bear_2 = request.security(tck2, '', high[1] < low[3])
    fvg_bear_3 = request.security(tck3, '', high[1] < low[3])
    
    if fvg_bear_1 or fvg_bear_2 or fvg_bear_3
        h0 = low[3]
        l0 = high[1]
        h1 = fvg_bear_1 ? request.security(tck1, '', low[3]) : na
        l1 = fvg_bear_1 ? request.security(tck1, '', high[1]) : na
        h2 = fvg_bear_2 ? request.security(tck2, '', low[3]) : na
        l2 = fvg_bear_2 ? request.security(tck2, '', high[1]) : na
        h3 = fvg_bear_3 ? request.security(tck3, '', low[3]) : na
        l3 = fvg_bear_3 ? request.security(tck3, '', high[1]) : na
        
        mid0 = l0 + (h0 - l0) / 2
        mid1 = fvg_bear_1 ? l1 + (h1 - l1) / 2 : na
        mid2 = fvg_bear_2 ? l2 + (h2 - l2) / 2 : na
        mid3 = fvg_bear_3 ? l3 + (h3 - l3) / 2 : na
        
        new_gap = Gap.new(bar_index-2, "bear", l0, l1, l2, l3, h0, h1, h2, h3, mid0, mid1, mid2, mid3, false, false, false, false, false, false, false, false, false, false, false, false, na, na, na, na, bar_index)
        array.push(gaps, new_gap)    
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// GAP CLEANUP
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
while array.size(gaps) > max_gaps
    temp = array.shift(gaps)
    if not na(temp.fvg)
        box.delete(temp.fvg)
    if not na(temp.cic_line_high)
        line.delete(temp.cic_line_high)
    if not na(temp.cic_line_mid)
        line.delete(temp.cic_line_mid)
    if not na(temp.cic_line_low)
        line.delete(temp.cic_line_low)
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
// GAP PROCESSING & SMT DETECTION
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
i = 0
gap_count = array.size(gaps)
while i < gap_count
    temp = array.get(gaps, i)
    
    // Get current prices for all assets
    [h1, l1] = request.security(tck1, '', [high, low])
    [h2, l2] = request.security(tck2, '', [high, low])
    [h3, l3] = request.security(tck3, '', [high, low])
    
    // Update traded flags FIRST
    if temp.side == 'bull'
        temp.h_traded := temp.h_traded or low < temp.h
        temp.h1_traded := temp.h1_traded or (not na(temp.h1) and l1 < temp.h1)
        temp.h2_traded := temp.h2_traded or (not na(temp.h2) and l2 < temp.h2)
        temp.h3_traded := temp.h3_traded or (not na(temp.h3) and l3 < temp.h3)
        temp.l_traded := temp.l_traded or low < temp.l
        temp.l1_traded := temp.l1_traded or (not na(temp.l1) and l1 < temp.l1)
        temp.l2_traded := temp.l2_traded or (not na(temp.l2) and l2 < temp.l2)
        temp.l3_traded := temp.l3_traded or (not na(temp.l3) and l3 < temp.l3)
        temp.mid_traded := temp.mid_traded or low < temp.mid
        temp.mid1_traded := temp.mid1_traded or (not na(temp.mid1) and l1 < temp.mid1)
        temp.mid2_traded := temp.mid2_traded or (not na(temp.mid2) and l2 < temp.mid2)
        temp.mid3_traded := temp.mid3_traded or (not na(temp.mid3) and l3 < temp.mid3)
    
    if temp.side == 'bear'
        temp.h_traded := temp.h_traded or high > temp.h
        temp.h1_traded := temp.h1_traded or (not na(temp.h1) and h1 > temp.h1)
        temp.h2_traded := temp.h2_traded or (not na(temp.h2) and h2 > temp.h2)
        temp.h3_traded := temp.h3_traded or (not na(temp.h3) and h3 > temp.h3)
        temp.l_traded := temp.l_traded or high > temp.l
        temp.l1_traded := temp.l1_traded or (not na(temp.l1) and h1 > temp.l1)
        temp.l2_traded := temp.l2_traded or (not na(temp.l2) and h2 > temp.l2)
        temp.l3_traded := temp.l3_traded or (not na(temp.l3) and h3 > temp.l3)
        temp.mid_traded := temp.mid_traded or high > temp.mid
        temp.mid1_traded := temp.mid1_traded or (not na(temp.mid1) and h1 > temp.mid1)
        temp.mid2_traded := temp.mid2_traded or (not na(temp.mid2) and h2 > temp.mid2)
        temp.mid3_traded := temp.mid3_traded or (not na(temp.mid3) and h3 > temp.mid3)
    
    // Check if gap is fully closed
    gap_closed = false
    if auto_delete_closed
        if temp.side == 'bull'
            gap_closed := close < temp.l
        else if temp.side == 'bear'
            gap_closed := close > temp.h
    
    // Delete closed gaps
    if gap_closed
        if not na(temp.fvg)
            box.delete(temp.fvg)
        if not na(temp.cic_line_high)
            line.delete(temp.cic_line_high)
        if not na(temp.cic_line_mid)
            line.delete(temp.cic_line_mid)
        if not na(temp.cic_line_low)
            line.delete(temp.cic_line_low)
        array.remove(gaps, i)
        gap_count -= 1
        i -= 1
        i += 1
        continue
    
    // SMT Divergence Detection - ALL LEVELS (high, mid, low)
    divergence_high = ((temp.h_traded != temp.h1_traded and not na(temp.h1)) or (temp.h_traded != temp.h2_traded and not na(temp.h2)) or (temp.h_traded != temp.h3_traded and not na(temp.h3)))
    divergence_high_asset = (temp.h_traded != temp.h1_traded and not na(temp.h1)) ? tck1 : (temp.h_traded != temp.h2_traded and not na(temp.h2)) ? tck2 : (temp.h_traded != temp.h3_traded and not na(temp.h3)) ? tck3 : ""
    
    divergence_mid = ((temp.mid_traded != temp.mid1_traded and not na(temp.mid1)) or (temp.mid_traded != temp.mid2_traded and not na(temp.mid2)) or (temp.mid_traded != temp.mid3_traded and not na(temp.mid3)))
    divergence_mid_asset = (temp.mid_traded != temp.mid1_traded and not na(temp.mid1)) ? tck1 : (temp.mid_traded != temp.mid2_traded and not na(temp.mid2)) ? tck2 : (temp.mid_traded != temp.mid3_traded and not na(temp.mid3)) ? tck3 : ""
    
    divergence_low = ((temp.l_traded != temp.l1_traded and not na(temp.l1)) or (temp.l_traded != temp.l2_traded and not na(temp.l2)) or (temp.l_traded != temp.l3_traded and not na(temp.l3)))
    divergence_low_asset = (temp.l_traded != temp.l1_traded and not na(temp.l1)) ? tck1 : (temp.l_traded != temp.l2_traded and not na(temp.l2)) ? tck2 : (temp.l_traded != temp.l3_traded and not na(temp.l3)) ? tck3 : ""
    
    any_divergence = divergence_high or divergence_mid or divergence_low
    string primary_divergence = "none"
    string primary_asset = ""
    if temp.side == "bull"
        primary_divergence := divergence_high ? "high" : divergence_mid ? "mid" : divergence_low ? "low" : "none"
        primary_asset := divergence_high ? divergence_high_asset : divergence_mid ? divergence_mid_asset : divergence_low ? divergence_low_asset : ""
    else
        primary_divergence := divergence_low ? "low" : divergence_mid ? "mid" : divergence_high ? "high" : "none"
        primary_asset := divergence_low ? divergence_low_asset : divergence_mid ? divergence_mid_asset : divergence_high ? divergence_high_asset : ""
    
    // Check if any asset is touching the gap
    price_in_gap = (low <= temp.h and high >= temp.l)
    asset1_in_gap = not na(temp.h1) and not na(temp.l1) and (l1 <= temp.h1 and h1 >= temp.l1)
    asset2_in_gap = not na(temp.h2) and not na(temp.l2) and (l2 <= temp.h2 and h2 >= temp.l2)
    asset3_in_gap = not na(temp.h3) and not na(temp.l3) and (l3 <= temp.h3 and h3 >= temp.l3)
    
    any_asset_touching = price_in_gap or asset1_in_gap or asset2_in_gap or asset3_in_gap
    
    // Update last touching bar
    if any_asset_touching
        temp.last_touching_bar := bar_index
    
    // Determine if we should show this gap
    should_show = true
    if only_show_active and not any_asset_touching
        should_show := false
    if hide_no_divergence and not any_divergence
        should_show := false
    
    // Calculate extension - ONLY extend to last touching bar + extension
    right_edge = temp.last_touching_bar + box_extension
    
    // Draw or update gaps
    if any_divergence and should_show
        gap_col = temp.side == "bull" ? bull_gap_color : bear_gap_color
        border_col = show_gap_border ? (temp.side == "bull" ? color.new(bull_gap_color, 0) : color.new(bear_gap_color, 0)) : gap_col
        
        if not na(temp.fvg)
            box.set_right(temp.fvg, right_edge)
        else
            label_text = show_asset_label ? getSymbolOnly(str.tostring(primary_asset)) : ""
            temp.fvg := box.new(temp.idx-1, temp.h, right_edge, temp.l,
                                 border_color = border_col,
                                 bgcolor = gap_col,
                                 text = label_text,
                                 text_color = label_text_color,
                                 text_size = getTextSize(label_text_size),
                                 text_halign = getTextAlign(label_position),
                                 border_width = gap_border_width)
        
        if show_smt_line
            if primary_divergence != "none"
                float level = primary_divergence == "high" ? temp.h : primary_divergence == "mid" ? temp.mid : temp.l
                line cic_line = primary_divergence == "high" ? temp.cic_line_high : primary_divergence == "mid" ? temp.cic_line_mid : temp.cic_line_low
                if not na(cic_line)
                    line.set_x2(cic_line, right_edge)
                else
                    new_line = line.new(temp.idx-1, level, right_edge, level,
                                        color = smt_line_color,
                                        style = getLineStyle(smt_line_style),
                                        width = smt_line_width)
                    if primary_divergence == "high"
                        temp.cic_line_high := new_line
                    else if primary_divergence == "mid"
                        temp.cic_line_mid := new_line
                    else
                        temp.cic_line_low := new_line
            if primary_divergence != "high" and not na(temp.cic_line_high)
                line.delete(temp.cic_line_high)
                temp.cic_line_high := na
            if primary_divergence != "mid" and not na(temp.cic_line_mid)
                line.delete(temp.cic_line_mid)
                temp.cic_line_mid := na
            if primary_divergence != "low" and not na(temp.cic_line_low)
                line.delete(temp.cic_line_low)
                temp.cic_line_low := na
    else
        // No divergence or shouldn't show - delete the box and lines
        if not na(temp.fvg)
            box.delete(temp.fvg)
            temp.fvg := na
        if not na(temp.cic_line_high)
            line.delete(temp.cic_line_high)
            temp.cic_line_high := na
        if not na(temp.cic_line_mid)
            line.delete(temp.cic_line_mid)
            temp.cic_line_mid := na
        if not na(temp.cic_line_low)
            line.delete(temp.cic_line_low)
            temp.cic_line_low := na
    
    i += 1
//#region[FUNCTIONS]
boxLoc(_loc) =>
    loc = switch _loc
        "Top-Left"      => position.top_left
        "Top-Center"    => position.top_center
        "Top-Right"     => position.top_right
        "Middle-Left"   => position.middle_left
        "Middle-Center" => position.middle_center
        "Middle-Right"  => position.middle_right
        "Bottom-Left"   => position.bottom_left
        "Bottom-Center" => position.bottom_center
        "Bottom-Right"  => position.bottom_right
    loc
_size(string _size, bool _l=false) =>
    size = switch _size
        "Tiny"   => not(_l) ? size.tiny   : size.small
        "Small"  => not(_l) ? size.small  : size.normal
        "Normal" => not(_l) ? size.normal : size.large
        "Large"  => not(_l) ? size.large  : size.huge
        "Huge"   => not(_l) ? size.huge   : size.huge
    size
//#endregion
show_watermark = true
color_watermark = input.color(color.gray, "Text Color", group = "Watermark", inline = "watermark")
use_custom_phrase = input.bool(true, "Custom Phrase?", group = "Watermark", inline = "phrase")
custom_phrase = input.text_area("", "", group = "Watermark", active = use_custom_phrase)
_y2 = input.string("Top", title="", inline='s2.2', group="Watermark", options=["Top","Middle","Bottom"])
_x2 = input.string("Center", title="", inline='s2.2', group="Watermark", options=["Left","Center","Right"])
_size2 = input.string("Small", title="", inline='s2.2', group="Watermark", options=["Tiny","Small","Normal","Large","Huge"])
//#region[INPUTS]
// QUOTE
_showQuote =     show_watermark // input.bool(true,                      title="Show?",        inline='s1',   group="Quote")
_color1    =     color_watermark //input.color(color.new(color.white, 10),                 title='',             inline='s1',   group="Quote")
_bgcolor1  =     color.new(color.white, 100) // input.color(color.new(color.white, 100),                 title='',             inline='s1',   group="Quote")
_showBrdr1 =      true // input.bool(true,                     title="Hide Border?", inline='s1',   group="Quote")
_y1        =    "Middle" // input.string("Bottom",                     title="",             inline='s1.2', group="Quote", options=["Top","Middle","Bottom"])
_x1        =   "Left" // input.string("Right",                  title="",             inline='s1.2', group="Quote", options=["Left","Center","Right"])
_size1     =    _size2 // input.string("Normal",                  title="",             inline='s1.2', group="Quote", options=["Tiny","Small","Normal","Large","Huge"])
_quoteTXT  = "" // input.text_area("Oracle Insights\nToolkit", title="Quote Text:",  group="Quote")
// SYMBOL INFO
_showInfo  =      show_watermark// input.bool(true,         title="Show?",        inline='s2.1',      group="Symbol Info")
_color2    =     color_watermark // input.color(color.new(color.white, 10),    title='',             inline='s2.1',      group="Symbol Info")
_bgcolor2  =     color.new(color.white, 100) // input.color(color.new(color.white, 100),    title='',             inline='s2.1',      group="Symbol Info")
_showBrdr2 =     true // input.bool(true,        title="Hide Border?", inline='s2.1',      group="Symbol Info")
// _y2        =    input.string("Top",        title="",             inline='s2.2',      group="Symbol Info", options=["Top","Middle","Bottom"])
// _x2        =    input.string("Right",      title="",             inline='s2.2',      group="Symbol Info", options=["Left","Center","Right"])
// _size2     =    input.string("Normal",      title="",             inline='s2.2',      group="Symbol Info", options=["Tiny","Small","Normal","Large","Huge"])
_showItext =      use_custom_phrase // input.bool(true,         title="Text?",        inline='s2.3',      group="Symbol Info")
_showIsym  =      true // input.bool(true,         title="Symbol?",      inline='s2.3',      group="Symbol Info")
_showItf   =      true // input.bool(true,         title="Timeframe?",   inline='s2.3',      group="Symbol Info")
_showIdate =      false // input.bool(false,        title="Date?",        inline='s2.3',      group="Symbol Info")
_infoTXT   = "SMT-Fill 🌀 [Oracle]"                     // input.text_area('Oracle Insights Toolkit', title="Info Text:",   group="Symbol Info")
//#endregion
//#region[LOGIC]
// TABLE LOCATION
quoteLOC = boxLoc(_y1+"-"+_x1)
infoLOC  = boxLoc(_y2+"-"+_x2)
// SYMBOL INFO
date     = str.tostring(dayofmonth(time_close)) + "/" + str.tostring(month(time_close)) + "/" + str.tostring(year(time_close))
num_tf   = if timeframe.isminutes
    if str.tonumber(timeframe.period) % 60 == 0
        str.tostring(str.tonumber(timeframe.period)/60)
    else
        timeframe.period
else
    timeframe.period
text_tf  = if timeframe.isminutes
    if str.tonumber(timeframe.period) % 60 == 0
        "H" +" TIMEFRAME"
    else
        "m" +" TIMEFRAME"
else
    na +" TIMEFRAME"
tf = num_tf + text_tf
//#endregion
//#region[PLOT]
// QUOTE
if _showQuote
    _quote = table.new(quoteLOC,1,1,frame_color=_color1,frame_width=_showBrdr1?0:1)
    table.cell(_quote, 0, 0, _quoteTXT,text_color=_color1, text_size=_size(_size1),bgcolor=_bgcolor1)
// SYMBOL INFO
if _showInfo
    _info = table.new(infoLOC,1,4,frame_color=_color2,frame_width=_showBrdr2?0:1)
    if _showItext
        table.cell(_info, 0, 2, _infoTXT,       text_color=#052D94, text_halign="center", text_size=_size(_size2),       bgcolor=_bgcolor2)
    if _showIsym
        table.cell(_info, 0, 0, syminfo.ticker, text_color=_color2, text_halign="center", text_size=_size(_size2, _l = true), bgcolor=_bgcolor2)
    if _showItf
        table.cell(_info, 0, 1, getSymbolOnly(tck1) + "/" + getSymbolOnly(tck2) + "/" + getSymbolOnly(tck3) + "\n\n" + tf,             text_color=_color2, text_halign="center", text_size=_size(_size2),       bgcolor=_bgcolor2)
    if use_custom_phrase
        table.cell(_info, 0, 3, custom_phrase,           text_color=_color2, text_halign="center", text_size=_size(_size2),       bgcolor=_bgcolor2)
//#endregion
````
