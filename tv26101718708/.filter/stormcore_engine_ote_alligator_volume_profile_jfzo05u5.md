# StormCore Engine: OTE, Alligator & Volume Profile

- url: https://www.tradingview.com/script/jFzO05U5-stormcore-engine-ote-alligator-volume-profile/
- type: indicator
- pine_id: PUB;cafce8f73f304419998ebf0e60f59265
- version: 2.0

## Description

The StormCore Engine is a modular, all-in-one technical analysis tool designed to consolidate three powerful trading methodologies into a single, highly optimized script. By combining Optimal Trade Entry (OTE) zones, a modernized Williams Alligator, and a dynamic Volume Profile with node detection, this engine helps traders identify liquidity zones, trend alignments, and key volume clusters without exhausting indicator limits on the chart.

This script is built with a modular architecture, meaning every core component can be toggled on or off via a "Master Toggle" in the settings, keeping your workspace clean and reducing CPU load when specific tools are not in use.

### Core Modules

1. Optimal Trade Entry (OTE)
This module automatically plots Fibonacci retracement levels (including the 62% and 79% "sweet spot" boxes) anchored either to the visible chart area, custom date ranges, or higher timeframe swings. 
- Features fractal detection to identify potential market structure shifts.
- Customizable Fibonacci extensions for dynamic profit-taking targets.

2. Super Alligator
A modernized take on the classic Bill Williams Alligator indicator. It utilizes SMMA-based Jaw, Teeth, and Lips to gauge trend direction and momentum.
- Signal Generation: Prints explicit Buy/Sell markers only when the "mouth" is fully open and the gap between the close price and the Lips exceeds a user-defined percentage.
- Trend Filters: Includes optional SMA 200 and VWAP filters to ensure signals only fire in the direction of the macro trend or intraday fair value.

3. Volume Profile & Node Detection
Calculates the trading volume at specific price levels over a user-defined lookback period. 
- Displays the Point of Control (POC) and Value Area High/Low (VAH/VAL).
- Node Detection Algorithm: Highlights high-volume Peaks and low-volume Troughs within the profile, which often act as significant support and resistance barriers.

### Practical Application (How to Use)
A high-probability setup occurs when multiple modules align:
- Wait for the price to retrace into the OTE 70% box.
- Check if this zone coincides with a Volume Profile Peak (indicating strong historical liquidity).
- Await a confirming signal from the Super Alligator (e.g., a Buy triangle firing above the VWAP filter) to execute the trade.

All modules are calculated independently but rendered cleanly to avoid chart clutter. Adjust the settings for your specific asset and timeframe.

Developed by Andy Storm | AI-StormCore.

## Source Code

````pine
//@version=6
// @author Andy Storm | AI-StormCore
// @version v1.2
indicator("StormCore | Combo Master Suite v1.2", "SC | Engine v1.2", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// =========================================================================
// === USER DEFINED TYPES (UDT)
// =========================================================================
// --- Volume Profile Types ---
type BAR
    float open   = open
    float high   = high
    float low    = low
    float close  = close
    float volume = volume
    int   index  = bar_index

type barData
    float[] barHigh
    float[] barLow
    float[] barVolume
    bool[]  barPolarity
    int[]   barCount

type volumeData
    float[] totalVolume
    float[] bullishVolume
    float[] bearishVolume
    int[]   endProfileIndex
    bool[]  peakVolume
    bool[]  troughVolume

type volumeProfile
    box[]         boxes
    chart.point[] pocPoints
    polyline      pocPolyline
    int           pocLevel
    int           vahLevel
    int           valLevel
    int           startIndex

// --- Divergence Master Types ---
type Pivot
    int bar
    float price

type DivSignal
    int type       
    int offset     
    string txt     
    color col
    int count      

// =========================================================================
// === GLOBAL HELPER FUNCTIONS
// =========================================================================
convertTextSize(string size) =>
    switch size
        "tiny" => size.tiny
        "small" => size.small
        "medium" => size.normal
        "large" => size.large

convertLineStyle(string style) =>
    switch style
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

barIsVisible() =>
    time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time

smma(series float src, int length) =>
    var float smma_val = float(na)
    smma_val := na(smma_val[1]) ? ta.sma(src, length) : (smma_val[1] * (length - 1) + src) / length
    smma_val

renderLine(int _x1, float _y1, int _x2, float _y2, string _xloc, string _extend, color _color, string _style, int _width) =>
    var line id = line.new(_x1, _y1, _x2, _y2, _xloc, _extend, _color, _style, _width)
    line.set_xy1(id, _x1, _y1)
    line.set_xy2(id, _x2, _y2)
    line.set_color(id, _color)

renderLabel(int _x, float _y, string _text, color _color, string _style, color _textcolor, string _size, string _tooltip) =>
    var label lb = label.new(_x, _y, _text, xloc.bar_index, yloc.price, _color, _style, _textcolor, _size, text.align_left, _tooltip)
    lb.set_xy(_x, _y)
    lb.set_text(_text)
    lb.set_tooltip(_tooltip)
    lb.set_textcolor(_textcolor)

requestBarData(string _lowerTimeframe) => 
    request.security_lower_tf(syminfo.tickerid, _lowerTimeframe, BAR.new(), ignore_invalid_timeframe = true)

calculateTimeframe(int _depth) => 
    int tfInMs = timeframe.in_seconds(timeframe.period)
    int mInMS = 60
    if _depth == 2
        switch
            tfInMs <                 30  =>  '1S'
            tfInMs <          1 * mInMS  =>  '5S'
            tfInMs <=        15 * mInMS  =>   '1'
            tfInMs <=        60 * mInMS  =>   '5'
            tfInMs <=       240 * mInMS  =>  '15'
            tfInMs <=      1440 * mInMS  =>  '60'
            => 'D'
    else if _depth == 1
        switch
            tfInMs <                 15  =>  '1S'
            tfInMs <                 30  =>  '5S'
            tfInMs <          1 * mInMS  => '15S'
            tfInMs <=         5 * mInMS  =>   '1'
            tfInMs <=        15 * mInMS  =>   '5'
            tfInMs <=        60 * mInMS  =>  '15'
            tfInMs <=       240 * mInMS  =>  '60'
            tfInMs <=      1440 * mInMS  => '240'
            => 'D'
    else
        'D'

getTextSize(string _text) =>
    if _text != 'None'
        switch _text
            'Tiny'   => size.tiny
            'Small'  => size.small 
            'Normal' => size.normal
            => size.auto
    else
        size.auto

// =========================================================================
// === MASTER TOGGLES
// =========================================================================
showOTE       = input.bool(true, "Show OTE Module", group="MODULES MASTER TOGGLE")
showAlligator = input.bool(true, "Show Alligator Module 🐊", group="MODULES MASTER TOGGLE")
masterShowVP  = input.bool(true, "Show Volume Profile Module", group="MODULES MASTER TOGGLE")
showDivMaster = input.bool(true, "Show Divergence Master Module 📉", group="MODULES MASTER TOGGLE")

// =========================================================================
// === INPUTS: STORMCORE OTE
// =========================================================================
longColor  = input.color(color.rgb(33, 243, 79, 37), "Long Direction Color", group="OTE: Colors")
shortColor = input.color(#ff5252a0,  "Short Direction Color", group="OTE: Colors")

useCustomDates = input.bool(false, "Use Custom Dates", group="OTE: Custom Date Range")
startDate = input.time(timestamp("2026-01-01 00:00"), "Start Date", group="OTE: Custom Date Range")
endDate = input.time(timestamp("2026-01-31 00:00"), "End Date", group="OTE: Custom Date Range")
useHigherTimeframe = input.bool(false, "Use Higher Timeframe", group="OTE: Custom Date Range")
higherTimeframe = input.timeframe("D", "Higher Timeframe", group="OTE: Custom Date Range")

useBodies = input.bool(false, "Use Candle Bodies to anchor range", group = "OTE: Box")
showFibBox = input.bool(true, "Show Fib Box", group = "OTE: Box", inline = "2")
enableFibBox1 = input.bool(true, "Enable Fib Box 79-62", group = "OTE: Box", inline = "1")
enableFibBox2 = input.bool(true, "Enable Fib Box 21-38", group = "OTE: Box", inline = "2")
showText = input.bool(true, "Show Text", group = "OTE: Box", inline = "2")
textSizeOptions = input.string("medium", "Text Size", options=["tiny", "small", "medium", "large"], group = "OTE: Box", inline = "3")
textAlignOptions = input.string("center", "Text Alignment", options=["left", "center", "right"], group = "OTE: Box", inline = "3")

lineThickness = input.int(1, "Line Thickness", options=[1, 2, 3, 4], group = "OTE: Line Settings", inline = "4")
lineStyle = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group = "OTE: Line Settings", inline = "4")

showHighLowLines = input.bool(true, "High/Low Lines", group = "OTE: Fib Retracements", inline = "3")
showMidline = input.bool(true, "Midline", group = "OTE: Fib Retracements", inline = "3")
show29eight = input.bool(false, "Show 29.5 Line", group = "OTE: Fib Retracements", inline = "5")
show70six = input.bool(false, "Show 70.5 Line", group = "OTE: Fib Retracements", inline = "6")
show88six = input.bool(true, "Show 88 Line", group = "OTE: Fib Retracements", inline = "7")
showFibLabels = input.bool(false, "Show Labels", group="OTE: Fib Retracements", inline="8")

showfibExt1 = input.bool(true, "Ext#1", group ="OTE: Fib Extensions", inline="9")
fibExt1 = input.float(1, "", group ="OTE: Fib Extensions", inline="9")
showfibExt2 = input.bool(true, "Ext#2", group ="OTE: Fib Extensions", inline="9")
fibExt2 = input.float(1.27, "", group ="OTE: Fib Extensions", inline="9")
showfibExt3 = input.bool(true, "Ext#3", group ="OTE: Fib Extensions", inline="10")
fibExt3 = input.float(1.62, "", group ="OTE: Fib Extensions", inline="10")
showfibExt4 = input.bool(false, "Ext#4", group ="OTE: Fib Extensions", inline="10")
fibExt4 = input.float(2, "", group ="OTE: Fib Extensions", inline="10")
showfibExt5 = input.bool(false, "Ext#5", group ="OTE: Fib Extensions", inline="11")
fibExt5 = input.float(2.62, "", group ="OTE: Fib Extensions", inline="11")
showfibExt6 = input.bool(false, "Ext#6", group ="OTE: Fib Extensions", inline="11")
fibExt6 = input.float(3.62, "", group ="OTE: Fib Extensions", inline="11")
showExtLabels = input.bool(true, "Show Labels", group ="OTE: Fib Extensions", inline="11")
flipInvertExts = input.bool(false, "Flip/Invert", group ="OTE: Fib Extensions", inline="12")

showFractals = input.bool(false, "Show Fractals", group="OTE: Fractals")
numCandlesSTL = input.int(13, minval=3, maxval=100, step=2, title="Candles for Fractals", group="OTE: Fractals")

// =========================================================================
// === INPUTS: SUPER ALLIGATOR
// =========================================================================
jawLength   = input.int(13, minval=1, title="Jaw Length", group="ALLIGATOR: Settings")
teethLength = input.int(8,  minval=1, title="Teeth Length", group="ALLIGATOR: Settings")
lipsLength  = input.int(5,  minval=1, title="Lips Length", group="ALLIGATOR: Settings")
jawOffset   = input.int(8,  title="Jaw Offset", group="ALLIGATOR: Settings")
teethOffset = input.int(5,  title="Teeth Offset", group="ALLIGATOR: Settings")
lipsOffset  = input.int(3,  title="Lips Offset", group="ALLIGATOR: Settings")

gapPct     = input.float(0.1, minval=0.0, step=0.01, title="Min Gap (%)", group="ALLIGATOR: Signals")
markerDist = input.float(1.5, minval=0.1, step=0.1, title="Marker Dist (ATR)", group="ALLIGATOR: Signals")

smaLength   = input.int(200, minval=1, title="SMA Length", group="ALLIGATOR: Filters")
useVwap     = input.bool(false, title="Use VWAP Filter", group="ALLIGATOR: Filters")
useSma      = input.bool(false, title="Use SMA Filter",  group="ALLIGATOR: Filters")
showSma     = input.bool(true,  title="Show SMA",        group="ALLIGATOR: Filters")
showVwap    = input.bool(false, title="Show VWAP",       group="ALLIGATOR: Filters")
showSignals = input.bool(false, title="Show Signals",    group="ALLIGATOR: Filters")

// =========================================================================
// === INPUTS: VOLUME PROFILE
// =========================================================================
displayOpt = display.all - display.status_line

vn_volumeNodesGroup = 'VP: Volume Nodes'
vp_componentsGroup = 'VP: Components'
vp_displayGroup = 'VP: Display Settings'

vn_peaksShow = input.string('Peaks', 'Volume Peaks', options = ['Peaks', 'Clusters', 'None'], inline = 'vnP', group = vn_volumeNodesGroup, display = displayOpt)
vn_peakVolumeColor = input.color(color.new(color.blue, 70), '', inline = 'vnP', group = vn_volumeNodesGroup)
vn_peaksNumberOfNodes = input.int(9, '  Node Detection Percent %', minval = 0, maxval = 100, group = vn_volumeNodesGroup, display = displayOpt) / 100
vn_peaksShow := vn_peaksNumberOfNodes == 0 ? 'None' : vn_peaksShow

vn_troughsShow = input.string('None', 'Volume Troughs', options = ['Troughs', 'Clusters', 'None'], inline = 'vnT', group = vn_volumeNodesGroup, display = displayOpt)
vn_troughVolumeColor = input.color(color.new(color.gray, 50), '', inline = 'vnT', group = vn_volumeNodesGroup)
vn_troughsNumberOfNodes = input.int(7, '  Node Detection Percent %', minval = 0, maxval = 100, group = vn_volumeNodesGroup, display = displayOpt) / 100
vn_troughsShow := vn_troughsNumberOfNodes == 0 ? 'None' : vn_troughsShow

vn_VolumeNodeThreshold = input.int(1, 'Volume Node Threshold %', minval = 0, maxval = 100, group = vn_volumeNodesGroup, display = displayOpt) / 100

vn_highestNVolumeNodes = input.int(0, 'Highest Volume Nodes', minval = 0, maxval = 31, inline = 'vnL', group = vn_volumeNodesGroup, display = displayOpt)
vn_highestVolumeColor = input.color(color.new(color.orange, 25), '', inline = 'vnL', group = vn_volumeNodesGroup)

vn_lowestNVolumeNodes = input.int(0, 'Lowest Volume Nodes', minval = 0, maxval = 31, inline = 'vnH', group = vn_volumeNodesGroup, display = displayOpt)
vn_lowestVolumeColor = input.color(color.new(color.navy, 25), '', inline = 'vnH', group = vn_volumeNodesGroup)

vp_profileShow = input.bool(true, 'Volume Profile', inline = 'vp', group = vp_componentsGroup)
vp_profileGradientColors = input.string('Gradient Colors', '', options = ['Gradient Colors', 'Classic Colors' ], inline = 'vp', group = vp_componentsGroup)
vp_valueAreaUpColor = input.color(color.new(#2962ff, 30), '  Value Area Up / Down', inline = 'VA', group = vp_componentsGroup)
vp_valueAreaDwonColor = input.color(color.new(#fbc02d, 30), '/', inline = 'VA', group = vp_componentsGroup)
vp_profileUpVolumeColor = input.color(color.new(#5d606b, 50), '  Profile Up / Down Volume', inline = 'VP', group = vp_componentsGroup)
vp_profileDownVolumeColor = input.color(color.new(#d1d4dc, 50), '/', inline = 'VP', group = vp_componentsGroup)

vp_pocShow = input.string('None', 'Point of Control', options = ['Developing', 'Regular', 'None'], inline = 'poc', group = vp_componentsGroup, display = displayOpt)
vp_pocColor = input.color(#fbc02d, '', inline = 'poc', group = vp_componentsGroup)
vp_pocWidth = input.int(2, 'Width', inline = 'poc', group = vp_componentsGroup, display = displayOpt)

vp_vahShow = input.bool(false, 'Value Area High (VAH)', inline = 'vah', group = vp_componentsGroup)
vp_vahColor = input.color(#2962ff, '', inline = 'vah', group = vp_componentsGroup)
vp_valShow = input.bool(false, 'Value Area Low (VAL)', inline = 'val', group = vp_componentsGroup)
vp_valColor = input.color(#2962ff, '', inline = 'val', group = vp_componentsGroup)
vp_profileLevels = input.string('Small', "Profile Price Labels", options=['Tiny', 'Small', 'Normal', 'None'], group = vp_componentsGroup, display = displayOpt)

vp_profileLength = input.int(360, 'Profile Lookback Length', minval = 10, maxval = 5000, step = 10, group = vp_displayGroup, display = displayOpt)
vp_profileLength := last_bar_index < vp_profileLength ? last_bar_index : vp_profileLength - 1
vp_valueAreaThreshold = input.float(70, 'Value Area (%)', minval = 0, maxval = 100, group = vp_displayGroup, display = displayOpt) / 100

vp_profilePlracment = input.string('Right', 'Profile Placement', options = ['Right', 'Left'], group = vp_displayGroup, display = displayOpt)
profilePlacementRight = vp_profilePlracment == 'Right' 

vp_profileNumberOfRows = input.int(100, 'Profile Number of Rows' , minval = 30, maxval = 130 , step = 10, group = vp_displayGroup, display = displayOpt)
vp_profileWidth = input.float(25, 'Profile Width', minval = 0, maxval = 250, group = vp_displayGroup, display = displayOpt) / 100
vp_profileHorizontalOffset = input.int(13, 'Profile Horizontal Offset', maxval = 50, group = vp_displayGroup, display = displayOpt)

vp_valueAreaBackground = input.bool(false, 'Value Area Background', inline = 'vBG', group = vp_displayGroup)
vp_valueAreaBackgroundColor = input.color(color.new(#2962ff, 89), '', inline = 'vBG', group = vp_displayGroup)
vp_profileBackground = input.bool(false, 'Profile Range Background', inline = 'pBG', group = vp_displayGroup)
vp_profileBackgroundColor  = input.color(color.new(#2962ff, 95), '', inline = 'pBG', group = vp_displayGroup)

// =========================================================================
// === INPUTS: DIVERGENCE MASTER
// =========================================================================
grp_div_main = "DIV MASTER: Main Settings"
div_auto_mtf = input.bool(true, "StormCore Auto: MTF Dynamics", group=grp_div_main, tooltip="Автоматически меняет Pivot Period в зависимости от таймфрейма (1M=2, 1W=4, 1D=20). Отключает расчеты внутри дня для фильтрации шума.")
div_show_reg = input.bool(true, "StormCore Auto: Regular Divergences", group=grp_div_main)
div_show_hid = input.bool(true, "StormCore Auto: Hidden Divergences", group=grp_div_main)
div_prd      = input.int(5, "Pivot Period (Manual Mode)", minval=1, maxval=50, group=grp_div_main, tooltip="Используется только если выключен MTF Dynamics.")
div_src_type = input.string("Close", "Pivot Source", options=["Close", "High/Low"], group=grp_div_main)
div_min_divs = input.int(1, "Minimum Number of Divergence", minval=1, maxval=11, group=grp_div_main, tooltip="Минимальное количество индикаторов для подтверждения.")
div_max_bars = input.int(100, "Maximum Bars to Check", minval=30, maxval=300, group=grp_div_main)
div_show_last= input.bool(false, "Show Only Last Divergence", group=grp_div_main, tooltip="Очищает график от исторических линий.")

grp_div_ind = "DIV MASTER: Indicators Toggles"
div_use_macd   = input.bool(true, "MACD", group=grp_div_ind)
div_use_macdh  = input.bool(true, "MACD Histogram", group=grp_div_ind)
div_use_rsi    = input.bool(true, "RSI", group=grp_div_ind)
div_use_stoch  = input.bool(true, "Stochastic", group=grp_div_ind)
div_use_cci    = input.bool(true, "CCI", group=grp_div_ind)
div_use_mom    = input.bool(true, "Momentum", group=grp_div_ind)
div_use_obv    = input.bool(true, "OBV", group=grp_div_ind)
div_use_vwmacd = input.bool(true, "VW MACD", group=grp_div_ind)
div_use_cmf    = input.bool(true, "Chaikin Money Flow", group=grp_div_ind)
div_use_mfi    = input.bool(true, "Money Flow Index", group=grp_div_ind)
div_use_ext    = input.bool(true, "External Indicator", group=grp_div_ind)
div_ext_src    = input.source(close, "External Source", group=grp_div_ind)

grp_div_vis = "DIV MASTER: Visuals & Styles"
div_show_indis  = input.string("Don't Show", "Show Indicator Names", options=["Full", "First Letter", "Don't Show"], group=grp_div_vis)
div_show_num    = input.bool(true, "Show Divergence Number", group=grp_div_vis)
div_show_lines  = input.bool(false, "Draw Divergence Lines", group=grp_div_vis)
pos_reg_col = input.color(color.yellow, "Positive Regular", group=grp_div_vis, inline="c1")
neg_reg_col = input.color(color.navy, "Negative Regular", group=grp_div_vis, inline="c1")
pos_hid_col = input.color(color.lime, "Positive Hidden", group=grp_div_vis, inline="c2")
neg_hid_col = input.color(color.red, "Negative Hidden", group=grp_div_vis, inline="c2")
div_show_mas    = input.bool(false, "Show MAs (50 & 200)", group=grp_div_vis)
ma50_col    = input.color(color.lime, "MA 50", group=grp_div_vis, inline="ma")
ma200_col   = input.color(color.red, "MA 200", group=grp_div_vis, inline="ma")

// =========================================================================
// === GLOBAL DATA REQUESTS (MANDATORY V6 SCOPE)
// =========================================================================
// OTE HTF
[globalHighTF, globalLowTF, globalOpenTF, globalCloseTF, _] = request.security(syminfo.tickerid, higherTimeframe, [high, low, open, close, time])

// VP LTF
string global_ltf_res = calculateTimeframe(2)
BAR[] global_ltf_data = requestBarData(global_ltf_res)

// =========================================================================
// === CALCULATIONS: DIVERGENCE MASTER (METHODS)
// =========================================================================
// Methods placed here inherit global input scope for colors (pos_reg_col etc.)
method validate_slope(series float src, series float ind, int c_prd, int offset, int len, float p_price, float p_ind, bool is_low) =>
    bool is_clean = true
    float price_slope = (src[c_prd] - p_price) / len
    float ind_slope = (ind[c_prd] - p_ind) / len
    
    for j = 1 to len - 1
        int check_idx = c_prd + j
        float expected_price = src[c_prd] - (price_slope * j)
        float expected_ind = ind[c_prd] - (ind_slope * j)
        
        if is_low
            if src[check_idx] < expected_price or ind[check_idx] < expected_ind
                is_clean := false
                break
        else
            if src[check_idx] > expected_price or ind[check_idx] > expected_ind
                is_clean := false
                break
    is_clean

method check_div(series float src, series float ind, bool is_ph, bool is_pl, array<Pivot> p_highs, array<Pivot> p_lows, int c_prd, int max_b, bool check_reg, bool check_hid) =>
    bool pos_reg = false, bool neg_reg = false
    bool pos_hid = false, bool neg_hid = false
    int opr = 0, int onr = 0, int oph = 0, int onh = 0
    
    if is_pl
        for p in p_lows
            int curr_bar = bar_index - c_prd
            int len = curr_bar - p.bar
            if len > max_b
                break
            if len > 5
                int offset = bar_index - p.bar
                float p_ind = ind[offset]
                
                if check_reg and src[c_prd] < p.price and ind[c_prd] > p_ind
                    if validate_slope(src, ind, c_prd, offset, len, p.price, p_ind, true)
                        pos_reg := true, opr := offset
                        break
                if check_hid and src[c_prd] > p.price and ind[c_prd] < p_ind
                    if validate_slope(src, ind, c_prd, offset, len, p.price, p_ind, true)
                        pos_hid := true, oph := offset
                        break
                        
    if is_ph
        for p in p_highs
            int curr_bar = bar_index - c_prd
            int len = curr_bar - p.bar
            if len > max_b
                break
            if len > 5
                int offset = bar_index - p.bar
                float p_ind = ind[offset]
                
                if check_reg and src[c_prd] > p.price and ind[c_prd] < p_ind
                    if validate_slope(src, ind, c_prd, offset, len, p.price, p_ind, false)
                        neg_reg := true, onr := offset
                        break
                if check_hid and src[c_prd] < p.price and ind[c_prd] > p_ind
                    if validate_slope(src, ind, c_prd, offset, len, p.price, p_ind, false)
                        neg_hid := true, onh := offset
                        break
                        
    [pos_reg, neg_reg, pos_hid, neg_hid, opr, onr, oph, onh]

method add_signal(array<DivSignal> arr, int type, int offset, string name, color col) =>
    bool found = false
    for s in arr
        if s.type == type and s.offset == offset
            if name != ""
                s.txt += (s.txt == "" ? "" : "\n") + name
            s.count += 1
            found := true
            break
    if not found
        arr.push(DivSignal.new(type, offset, name, col, 1))

method process_indicator(array<DivSignal> sigs, bool enabled, string name, series float src, series float ind, bool is_ph, bool is_pl, array<Pivot> phs, array<Pivot> pls, int c_prd, int mx, bool c_reg, bool c_hid) =>
    if enabled
        [pr, nr, ph, nh, opr, onr, oph, onh] = check_div(src, ind, is_ph, is_pl, phs, pls, c_prd, mx, c_reg, c_hid)
        if pr
            sigs.add_signal(0, opr, name, pos_reg_col)
        if nr
            sigs.add_signal(1, onr, name, neg_reg_col)
        if ph
            sigs.add_signal(2, oph, name, pos_hid_col)
        if nh
            sigs.add_signal(3, onh, name, neg_hid_col)

// =========================================================================
// === CALCULATIONS: STORMCORE OTE
// =========================================================================
var bool prevUseCustomDates = useCustomDates
var bool prevUseBodies = useBodies
var bool prevUseHigherTimeframe = useHigherTimeframe

var float chartHigh = float(na)
var float chartLow = float(na)
var int highTime = int(na)
var int lowTime = int(na)
var bool isOTEDrawn = false

if showOTE
    if useCustomDates and (time == startDate or useCustomDates != prevUseCustomDates or useBodies != prevUseBodies or useHigherTimeframe != prevUseHigherTimeframe)
        chartHigh := float(na)
        chartLow := float(na)
        highTime := int(na)
        lowTime := int(na)

    if useCustomDates and time >= startDate and time <= endDate
        var float highValue = float(na)
        var float lowValue = float(na)
        if useHigherTimeframe
            if useBodies
                highValue := math.max(globalOpenTF, globalCloseTF)
                lowValue := math.min(globalOpenTF, globalCloseTF)
            else
                highValue := globalHighTF
                lowValue := globalLowTF
        else
            if useBodies
                highValue := math.max(open, close)
                lowValue := math.min(open, close)
            else
                highValue := high
                lowValue := low
                
        if na(chartHigh) or highValue > chartHigh
            chartHigh := highValue
            highTime := time
        if na(chartLow) or lowValue < chartLow
            chartLow := lowValue
            lowTime := time
    else if not useCustomDates and barIsVisible()
        if useBodies
            if na(chartHigh) or math.max(open, close) > chartHigh
                chartHigh := math.max(open, close)
                highTime := time
            if na(chartLow) or math.min(open, close) < chartLow
                chartLow := math.min(open, close)
                lowTime := time
        else
            if na(chartHigh) or high > chartHigh
                chartHigh := high
                highTime := time
            if na(chartLow) or low < chartLow
                chartLow := low
                lowTime := time

prevUseCustomDates := useCustomDates
prevUseBodies := useBodies
prevUseHigherTimeframe := useHigherTimeframe

int leftTime = math.min(highTime, lowTime)
bool isBull = lowTime < highTime

autoLineColor  = isBull ? longColor : shortColor
autoBoxColor   = isBull ? color.new(longColor, 85) : color.new(shortColor, 85)
autoLabelColor = isBull ? longColor : shortColor

// =========================================================================
// === CALCULATIONS: SUPER ALLIGATOR
// =========================================================================
jaw   = smma(hl2, jawLength)
teeth = smma(hl2, teethLength)
lips  = smma(hl2, lipsLength)
sma200 = ta.sma(close, smaLength)
vwap   = ta.vwap
atr    = ta.atr(14)

lipsD  = lips[lipsOffset]
jawD   = jaw[jawOffset]
teethD = teeth[teethOffset]

gapOkBull = (close - lipsD) / close * 100 >= gapPct
gapOkBear = (lipsD - close) / close * 100 >= gapPct

vwapOkBull = not useVwap or close > vwap
vwapOkBear = not useVwap or close < vwap
smaOkBull  = not useSma  or close > sma200
smaOkBear  = not useSma  or close < sma200

bullFan = lipsD > jawD
bearFan = jawD  > lipsD

buyReady  = bullFan and gapOkBull and vwapOkBull and smaOkBull
sellReady = bearFan and gapOkBear and vwapOkBear and smaOkBear

buySignal  = buyReady  and not buyReady[1]
sellSignal = sellReady and not sellReady[1]

float buyMarkerY  = buySignal  ? low  - atr * markerDist : float(na)
float sellMarkerY = sellSignal ? high + atr * markerDist : float(na)

// =========================================================================
// === CALCULATIONS: VOLUME PROFILE
// =========================================================================
BAR bar = BAR.new()
BAR[] ltfBarData = array.new<BAR>()

var barData barDataArray = barData.new(
     array.new<float>(), array.new<float>(), array.new<float>(), 
     array.new<bool>(), array.new<int>())

volumeData volumeDataArray = volumeData.new(
     array.new<float>(vp_profileNumberOfRows, 0.), array.new<float>(vp_profileNumberOfRows, 0.), 
     array.new<float>(vp_profileNumberOfRows, 0.), array.new<int>(vp_profileNumberOfRows, 0),
     array.new<bool>(vp_profileNumberOfRows, false), array.new<bool>(vp_profileNumberOfRows, false))

var volumeProfile VP = volumeProfile.new(
     array.new<box>(), array.new<chart.point>(), polyline.new(array.new<chart.point>()), int(na), int(na), int(na), int(na))

var float highestPrice = float(na)
var float lowestPrice = float(na)
string profileLevesSize = getTextSize(vp_profileLevels)

if masterShowVP
    if bar_index == last_bar_index - vp_profileLength
        VP.startIndex := bar_index
        lowestPrice := low 
        highestPrice := high
    else if bar_index > last_bar_index - vp_profileLength
        lowestPrice := math.min(low, lowestPrice)
        highestPrice := math.max(high, highestPrice)

    if vp_profileLength <= 700
        ltfBarData := global_ltf_data
    else
        ltfBarData := array.new<BAR>(1, BAR.new(open, high, low, close, volume, bar_index))

    if barstate.ishistory and (bar_index >= last_bar_index - vp_profileLength) and bar_index < last_bar_index and ltfBarData.size() > 0
        if ltfBarData.size() > 0 and not na(nz(ltfBarData.get(0).volume))
            for currentLtfBar = 0 to ltfBarData.size() - 1
                barDataArray.barHigh.push(ltfBarData.get(currentLtfBar).high)
                barDataArray.barLow.push(ltfBarData.get(currentLtfBar).low)
                barDataArray.barVolume.push(ltfBarData.get(currentLtfBar).volume)
                barDataArray.barPolarity.push(ltfBarData.get(currentLtfBar).close > ltfBarData.get(currentLtfBar).open)
            barDataArray.barCount.push(ltfBarData.size())

// =========================================================================
// === CALCULATIONS: DIVERGENCE MASTER (EXECUTION)
// =========================================================================
var ph_arr = array.new<Pivot>()
var pl_arr = array.new<Pivot>()

var active_lines  = array.new_line()
var active_labels = array.new_label()

get_name(string full, string short) =>
    div_show_indis == "Full" ? full : (div_show_indis == "First Letter" ? short : "")

int calc_prd = div_prd
bool disable_calc = false

if div_auto_mtf
    if timeframe.ismonthly
        calc_prd := 2
    else if timeframe.isweekly
        calc_prd := 4
    else if timeframe.isdaily
        calc_prd := 20
    else if timeframe.isintraday
        disable_calc := true

float eval_src_high = div_src_type == "Close" ? close : high
float eval_src_low  = div_src_type == "Close" ? close : low
float eval_src      = div_src_type == "Close" ? close : hl2

float ph = ta.pivothigh(eval_src_high, calc_prd, calc_prd)
float pl = ta.pivotlow(eval_src_low, calc_prd, calc_prd)
bool new_ph = not na(ph) and not disable_calc
bool new_pl = not na(pl) and not disable_calc

float rsi_val   = ta.rsi(close, 14)
[macd_line, sig_line, macd_hist] = ta.macd(close, 12, 26, 9)
float stoch_val = ta.sma(ta.stoch(close, high, low, 14), 3)
float cci_val   = ta.cci(close, 10)
float mom_val   = ta.mom(close, 10)
float obv_val   = ta.cum(math.sign(ta.change(close)) * volume)
float vwmacd_val= ta.vwma(close, 12) - ta.vwma(close, 26)
float cmf_val   = ta.sma(((close-low) - (high-close)) / (high - low == 0 ? 1 : high - low) * volume, 21) / ta.sma(volume, 21)
float mfi_val   = ta.mfi(close, 14)
float ext_val   = div_ext_src

DivSignal[] current_signals = array.new<DivSignal>()

if (new_pl or new_ph) and not disable_calc
    current_signals.process_indicator(div_use_macd,  get_name("MACD", "M"), eval_src, macd_line, new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_macdh, get_name("Hist", "H"), eval_src, macd_hist, new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_rsi,   get_name("RSI",  "R"), eval_src, rsi_val,   new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_stoch, get_name("Stoch","S"), eval_src, stoch_val, new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_cci,   get_name("CCI",  "C"), eval_src, cci_val,   new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_mom,   get_name("Mom",  "M"), eval_src, mom_val,   new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_obv,   get_name("OBV",  "O"), eval_src, obv_val,   new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_vwmacd,get_name("VWM",  "V"), eval_src, vwmacd_val,new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_cmf,   get_name("CMF",  "C"), eval_src, cmf_val,   new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_mfi,   get_name("MFI",  "M"), eval_src, mfi_val,   new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    current_signals.process_indicator(div_use_ext,   get_name("Ext",  "X"), eval_src, ext_val,   new_ph, new_pl, ph_arr, pl_arr, calc_prd, div_max_bars, div_show_reg, div_show_hid)
    
    if new_ph
        ph_arr.unshift(Pivot.new(bar_index[calc_prd], ph))
        if ph_arr.size() > 15
            ph_arr.pop()
            
    if new_pl
        pl_arr.unshift(Pivot.new(bar_index[calc_prd], pl))
        if pl_arr.size() > 15
            pl_arr.pop()

// =========================================================================
// === GLOBAL DRAWING SCOPE (STRICT TERNARY)
// =========================================================================

// --- ALLIGATOR PLOTS ---
plot(showAlligator ? jaw : na,   "Jaw",   offset=jawOffset,   color=#2962FF, linewidth=2)
plot(showAlligator ? teeth : na, "Teeth", offset=teethOffset, color=#E91E63, linewidth=2)
plot(showAlligator ? lips : na,  "Lips",  offset=lipsOffset,  color=#66BB6A, linewidth=2)
plot((showAlligator and showSma)  ? sma200 : na, "SMA",  color=color.new(color.orange, 0), linewidth=1)
plot((showAlligator and showVwap) ? vwap : na,   "VWAP", color=color.new(color.purple, 0), linewidth=1)

plotshape(showAlligator and showSignals ? buyMarkerY  : na, title="Buy",  style=shape.triangleup,   location=location.absolute, color=color.new(color.green, 0), size=size.tiny)
plotshape(showAlligator and showSignals ? sellMarkerY : na, title="Sell", style=shape.triangledown, location=location.absolute, color=color.new(color.red,   0), size=size.tiny)

float buyLineY1 = (showAlligator and showSignals and buySignal) ? low : float(na)
float buyLineY2 = (showAlligator and showSignals and buySignal) ? (low - atr * markerDist) : float(na)
float sellLineY1 = (showAlligator and showSignals and sellSignal) ? high : float(na)
float sellLineY2 = (showAlligator and showSignals and sellSignal) ? (high + atr * markerDist) : float(na)

line.new(bar_index, buyLineY1, bar_index, buyLineY2, style=line.style_dotted, color=showAlligator and showSignals and buySignal ? color.new(color.green, 30) : na, width=1)
line.new(bar_index, sellLineY1, bar_index, sellLineY2, style=line.style_dotted, color=showAlligator and showSignals and sellSignal ? color.new(color.red, 30) : na, width=1)

// --- OTE FRACTALS (v6 Strict Casting) ---
isUpperFractal(int n) =>
    int middle = int(math.floor(n / 2))
    float highest = high[middle]
    for i = 0 to n - 1
        if i != middle and high[i] > highest
            highest := high[i]
    highest == high[middle]

isLowerFractal(int n) =>
    int middle = int(math.floor(n / 2))
    float lowest = low[middle]
    for i = 0 to n - 1
        if i != middle and low[i] < lowest
            lowest := low[i]
    lowest == low[middle]

sth = isUpperFractal(numCandlesSTL)
stl = isLowerFractal(numCandlesSTL)
plotshape((showOTE and showFractals and sth) ? high : na, title="Upper Fractal", style=shape.triangledown, location=location.abovebar, color=autoLineColor, size=size.tiny, offset=-int(math.floor(numCandlesSTL/2)))
plotshape((showOTE and showFractals and stl) ? low : na, title="Lower Fractal", style=shape.triangleup, location=location.belowbar, color=autoLabelColor, size=size.tiny, offset=-int(math.floor(numCandlesSTL/2)))

// --- OTE ZONES & FIBS ---
fibLine(series float fibLevel, bool _showPriceLabels) =>
    float fibRatio = 1 - (fibLevel / 100)
    float fibPrice = isBull ? chartLow + ((chartHigh - chartLow) * fibRatio) : chartHigh - ((chartHigh - chartLow) * fibRatio)
    line.new(leftTime, fibPrice, time, fibPrice, xloc.bar_time, extend.none, showOTE ? autoLineColor : na, convertLineStyle(lineStyle), lineThickness)
    if _showPriceLabels and showOTE
        label.new(time, fibPrice, str.tostring(fibPrice, "#.###") + " (" + str.tostring(fibPrice, "#.###") + ")", xloc.bar_time,style=label.style_none, textcolor=autoLabelColor, size=convertTextSize(textSizeOptions), textalign=text.align_center)

fibExt(series float fibLevel, bool _showExt) =>
    float fibRatio = fibLevel / 100
    float fibPrice = isBull ? chartLow - ((chartHigh - chartLow) * fibRatio) : chartHigh + ((chartHigh - chartLow) * fibRatio)
    line.new(leftTime, fibPrice, time, fibPrice, xloc.bar_time, extend.none, showOTE ? autoLineColor : na, convertLineStyle(lineStyle), lineThickness)
    if _showExt and showOTE
        label.new(time, fibPrice, str.tostring(fibLevel / 100, "#.###") + " (" + str.tostring(fibPrice, "#.###") + ")", xloc.bar_time, style=label.style_none, textcolor=autoLabelColor, size=convertTextSize(textSizeOptions), textalign=text.align_center)

fibExtApply(float f, bool show) =>
    if show
        if flipInvertExts
            fibExt((f * 100) - 100, showExtLabels)
        else
            fibExt(-(f * 100), showExtLabels)

fibBox(series float fibLevel_1, series float fibLevel_2, string labelText) =>
    float fibRatio_1 = 1 - (fibLevel_1 / 100)
    float fibPrice_1 = isBull ? chartLow + ((chartHigh - chartLow) * fibRatio_1) : chartHigh - ((chartHigh - chartLow) * fibRatio_1)
    float fibRatio_2 = 1 - (fibLevel_2 / 100)
    float fibPrice_2 = isBull ? chartLow + ((chartHigh - chartLow) * fibRatio_2) : chartHigh - ((chartHigh - chartLow) * fibRatio_2)
    box b = box.new(leftTime, fibPrice_1, time, fibPrice_2, xloc=xloc.bar_time, border_style=convertLineStyle(lineStyle), border_color=showOTE ? color.new(color.white, 100) : na)
    if showOTE
        box.set_bgcolor(b, showFibBox ? autoBoxColor : color.new(color.white, 100))
        if showText
            box.set_text(b, labelText)
            box.set_text_color(b, autoLabelColor)
            box.set_text_size(b, convertTextSize(textSizeOptions))
            box.set_text_halign(b, textAlignOptions)

// --- DIV MASTER DRAWS ---
bool a_pos_reg = false
bool a_neg_reg = false
bool a_pos_hid = false
bool a_neg_hid = false

if showDivMaster
    if div_show_last and current_signals.size() > 0
        for ln in active_lines
            ln.delete()
        for lb in active_labels
            lb.delete()
        active_lines.clear()
        active_labels.clear()
        
    for s in current_signals
        if s.count >= div_min_divs
            if s.type == 0
                a_pos_reg := true
            if s.type == 1
                a_neg_reg := true
            if s.type == 2
                a_pos_hid := true
            if s.type == 3
                a_neg_hid := true
            
            float y1 = div_src_type == "Close" ? close[s.offset] : (s.type == 0 or s.type == 2 ? low[s.offset] : high[s.offset])
            float y2 = div_src_type == "Close" ? close[calc_prd] : (s.type == 0 or s.type == 2 ? low[calc_prd] : high[calc_prd])
            
            line ln = div_show_lines ? line.new(bar_index - s.offset, y1, bar_index - calc_prd, y2, color=s.col, width=2, style= s.type <= 1 ? line.style_solid : line.style_dashed) : na
            
            string final_txt = s.txt
            if div_show_num
                final_txt += (final_txt == "" ? "" : "\n") + str.tostring(s.count)
                
            label lb = na
            if final_txt != ""
                if s.type == 0 or s.type == 2
                    lb := label.new(bar_index - calc_prd, low[calc_prd], text=final_txt, color=s.col, style=label.style_label_up, size=size.small, textcolor=color.black)
                else
                    lb := label.new(bar_index - calc_prd, high[calc_prd], text=final_txt, color=s.col, style=label.style_label_down, size=size.small, textcolor=color.white)
                    
            if div_show_last
                if not na(ln)
                    active_lines.push(ln)
                if not na(lb)
                    active_labels.push(lb)

plot(showDivMaster and div_show_mas ? ta.sma(close, 50)  : na, title="Div MA 50",  color=ma50_col,  linewidth=2)
plot(showDivMaster and div_show_mas ? ta.sma(close, 200) : na, title="Div MA 200", color=ma200_col, linewidth=2)

// =========================================================================
// === ALERTS
// =========================================================================
alertcondition(a_pos_reg, title="SC: Positive Regular Divergence", message="SC: Positive Regular Divergence Detected")
alertcondition(a_neg_reg, title="SC: Negative Regular Divergence", message="SC: Negative Regular Divergence Detected")
alertcondition(a_pos_hid, title="SC: Positive Hidden Divergence",  message="SC: Positive Hidden Divergence Detected")
alertcondition(a_neg_hid, title="SC: Negative Hidden Divergence",  message="SC: Negative Hidden Divergence Detected")

// =========================================================================
// === LAST BAR EXECUTIONS (Boxes / Complex Drawings)
// =========================================================================
if barstate.islast
    // OTE RENDER
    if showOTE and not isOTEDrawn
        if showHighLowLines
            fibLine(100, showFibLabels)
            fibLine(0, showFibLabels)
        if showMidline
            fibLine(50.5, showFibLabels)
        if show29eight
            fibLine(29.5, showFibLabels)
        if show70six
            fibLine(70.5, showFibLabels)
        if show88six
            fibLine(88, showFibLabels)
        if enableFibBox1
            fibBox(79, 62, "OTE 70%")
        if enableFibBox2
            fibBox(21, 38, "OTE 30%")
        fibExtApply(fibExt1, showfibExt1)
        fibExtApply(fibExt2, showfibExt2)
        fibExtApply(fibExt3, showfibExt3)
        fibExtApply(fibExt4, showfibExt4)
        fibExtApply(fibExt5, showfibExt5)
        fibExtApply(fibExt6, showfibExt6)
        isOTEDrawn := true
    
    // VOLUME PROFILE RENDER
    if masterShowVP and ltfBarData.size() > 0 
        float priceStep = (highestPrice - lowestPrice) / vp_profileNumberOfRows
        while VP.boxes.size() > 0
            box.delete(VP.boxes.shift())

        if barDataArray.barCount.size() > vp_profileLength
            int barCount = barDataArray.barCount.shift()
            for barCountIndex = 0 to barCount - 1
                barDataArray.barHigh.shift()
                barDataArray.barLow.shift()
                barDataArray.barVolume.shift()
                barDataArray.barPolarity.shift()

        VP.pocPoints.clear()
        
        if not na(VP.pocPolyline)
            polyline.delete(VP.pocPolyline)

        if ltfBarData.size() > 0 and not na(nz(ltfBarData.get(0).volume))
            for currentLtfBar = 0 to ltfBarData.size() - 1
                barDataArray.barHigh.push(ltfBarData.get(currentLtfBar).high)
                barDataArray.barLow.push(ltfBarData.get(currentLtfBar).low)
                barDataArray.barVolume.push(ltfBarData.get(currentLtfBar).volume)
                barDataArray.barPolarity.push(ltfBarData.get(currentLtfBar).close > ltfBarData.get(currentLtfBar).open)
            barDataArray.barCount.push(ltfBarData.size())

        int barIndex = vp_profileLength
        int numberOfBars = 0
        int arraySize = barDataArray.barVolume.size()

        for arrayIndex = 0 to arraySize - 1
            float levelHigh = barDataArray.barHigh.get(arrayIndex)
            float levelLow = barDataArray.barLow.get(arrayIndex)
            float levelVolume = barDataArray.barVolume.get(arrayIndex)
            
            int startSlotIndex = int(math.max(math.floor((levelLow - lowestPrice) / priceStep), 0))
            int endSlotIndex = int(math.min(math.floor((levelHigh - lowestPrice) / priceStep), vp_profileNumberOfRows - 1))
            
            for priceLevelIndex = startSlotIndex to endSlotIndex
                float priceLevel = lowestPrice + priceLevelIndex * priceStep
                float volumeProportion = switch
                    levelLow >= priceLevel and levelHigh > priceLevel + priceStep => (priceLevel + priceStep - levelLow) / (levelHigh - levelLow)
                    levelHigh <= priceLevel + priceStep and levelLow < priceLevel => (levelHigh - priceLevel) / (levelHigh - levelLow)
                    levelLow >= priceLevel and levelHigh <= priceLevel + priceStep => 1
                    => priceStep / (levelHigh - levelLow)

                volumeDataArray.totalVolume.set(priceLevelIndex, volumeDataArray.totalVolume.get(priceLevelIndex) + levelVolume * volumeProportion)
                if barDataArray.barPolarity.get(arrayIndex)
                    volumeDataArray.bullishVolume.set(priceLevelIndex, volumeDataArray.bullishVolume.get(priceLevelIndex) + levelVolume * volumeProportion)

            if vp_pocShow == 'Developing'
                if arrayIndex == barDataArray.barCount.get(vp_profileLength - barIndex)
                    VP.pocPoints.push(chart.point.from_index(bar_index[barIndex], math.avg(high[barIndex], low[barIndex])))
                    VP.pocPoints.push(chart.point.from_index(bar_index[barIndex] + 1, lowestPrice + (volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.max()) + .5) * priceStep))
                    numberOfBars += barDataArray.barCount.get(vp_profileLength - barIndex)
                    barIndex  -= 1
                else if arrayIndex == (numberOfBars + barDataArray.barCount.get(vp_profileLength - barIndex)) and numberOfBars != 0
                    VP.pocPoints.push(chart.point.from_index(bar_index[barIndex] + 1, lowestPrice + (volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.max()) + .5) * priceStep))
                    numberOfBars += barDataArray.barCount.get(vp_profileLength - barIndex)
                    barIndex  -= 1
                else if barIndex == 0
                    VP.pocPoints.push(chart.point.from_index(bar_index[barIndex] + 1, lowestPrice + (volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.max()) + .5) * priceStep))
                    numberOfBars += barDataArray.barCount.get(vp_profileLength - barIndex)

        VP.pocPolyline := polyline.new(VP.pocPoints, false, false, xloc.bar_index, vp_pocColor, color(na), line.style_solid, vp_pocWidth)

        for volumeIndex = 0 to vp_profileNumberOfRows - 1
            float bearishVolume = 2 * volumeDataArray.bullishVolume.get(volumeIndex) - volumeDataArray.totalVolume.get(volumeIndex)
            volumeDataArray.bearishVolume.set(volumeIndex, volumeDataArray.bearishVolume.get(volumeIndex) + bearishVolume * (bearishVolume > 0 ? 1 : -1) )

        VP.pocLevel := volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.max())
        float totalTradedVolume = volumeDataArray.totalVolume.sum() * vp_valueAreaThreshold
        float valueAreaVolume = VP.pocLevel != -1 ? volumeDataArray.totalVolume.get(VP.pocLevel) : 0
        VP.vahLevel := VP.pocLevel
        VP.valLevel := VP.pocLevel
        
        while valueAreaVolume < totalTradedVolume
            if VP.valLevel == 0 and VP.vahLevel == vp_profileNumberOfRows - 1
                break
            float volumeAbovePOC = 0.
            if VP.vahLevel < vp_profileNumberOfRows - 1 
                volumeAbovePOC := volumeDataArray.totalVolume.get(VP.vahLevel + 1)
            float volumeBelowPOC = 0.
            if VP.valLevel > 0
                volumeBelowPOC := volumeDataArray.totalVolume.get(VP.valLevel - 1)
            
            if volumeBelowPOC == 0 and volumeAbovePOC == 0
                break
            if volumeAbovePOC >= volumeBelowPOC
                valueAreaVolume  += volumeAbovePOC
                VP.vahLevel += 1
            else
                valueAreaVolume  += volumeBelowPOC
                VP.valLevel -= 1

        float vahPrice = lowestPrice + (VP.vahLevel + 1.) * priceStep
        float pocPrice = lowestPrice + (VP.pocLevel + .5) * priceStep
        float valPrice = lowestPrice + (VP.valLevel + .0) * priceStep

        int profilePlottingLength = vp_profileLength > 360 ? 360 : vp_profileLength
        float profileWidth = profilePlottingLength * vp_profileWidth
        int profileHorizontalOffset = int(profileWidth + vp_profileHorizontalOffset)

        if vp_profileShow and profilePlacementRight and vp_pocShow == 'Developing'
            renderLine(last_bar_index, pocPrice, profileHorizontalOffset + int(last_bar_index - profileWidth + 1), pocPrice, xloc.bar_index, extend.none, vp_pocColor, line.style_solid, vp_pocWidth)

        if vp_vahShow
            renderLine(VP.startIndex, vahPrice, profilePlacementRight ? (vp_profileShow ? profileHorizontalOffset : 0) + last_bar_index : last_bar_index, vahPrice, xloc.bar_index, extend.none, vp_vahColor, line.style_solid, 1)
        
        if vp_pocShow == 'Regular'
            renderLine(VP.startIndex, pocPrice, profilePlacementRight ? vp_profileShow ? profileHorizontalOffset + int(last_bar_index - profileWidth + 1) : last_bar_index : last_bar_index, pocPrice, xloc.bar_index, extend.none, vp_pocColor, line.style_solid, vp_pocWidth)

        if vp_valShow
            renderLine(VP.startIndex, valPrice, profilePlacementRight ? (vp_profileShow ? profileHorizontalOffset : 0) + last_bar_index : last_bar_index, valPrice, xloc.bar_index, extend.none, vp_valColor, line.style_solid, 1)

        if vp_valueAreaBackground
            VP.boxes.push(box.new(VP.startIndex, valPrice, last_bar_index, vahPrice, vp_valueAreaBackgroundColor, 1, line.style_dotted, bgcolor = vp_valueAreaBackgroundColor))

        if vp_profileBackground
            VP.boxes.push(box.new(VP.startIndex, lowestPrice, last_bar_index, highestPrice, vp_profileBackgroundColor, 1, line.style_dotted, bgcolor = vp_profileBackgroundColor))

        if vp_profileLevels != 'None' and VP.pocLevel != -1 
            renderLabel(profilePlacementRight ? (vp_profileShow ? profileHorizontalOffset : 0) + last_bar_index : vp_profileShow ? VP.startIndex : last_bar_index, highestPrice, str.tostring(highestPrice, format.mintick), color.new(chart.fg_color, 89), label.style_label_down, chart.fg_color, profileLevesSize, 'Profile High')
            renderLabel(profilePlacementRight ? (vp_profileShow ? profileHorizontalOffset : 0) + last_bar_index : last_bar_index, vahPrice, str.tostring(vahPrice, format.mintick), color.new(vp_vahColor, 89), label.style_label_left, vp_vahColor, profileLevesSize, 'Value Area High')
            renderLabel(profilePlacementRight ? (vp_profileShow ? profileHorizontalOffset : 0) + last_bar_index : last_bar_index, pocPrice, str.tostring(pocPrice, format.mintick), color.new(vp_pocColor, 89), label.style_label_left, vp_pocColor, profileLevesSize, 'Point of Control')
            renderLabel(profilePlacementRight ? (vp_profileShow ? profileHorizontalOffset : 0) + last_bar_index : last_bar_index, valPrice, str.tostring(valPrice, format.mintick), color.new(vp_valColor, 89), label.style_label_left, vp_valColor, profileLevesSize, 'Value Area Low')
            renderLabel(profilePlacementRight ? (vp_profileShow ? profileHorizontalOffset : 0) + last_bar_index : vp_profileShow ? VP.startIndex : last_bar_index, lowestPrice, str.tostring(lowestPrice, format.mintick), color.new(chart.fg_color, 89), label.style_label_up, chart.fg_color, profileLevesSize, 'Profile Low')

        for volumeNodeLevel = 0 to vp_profileNumberOfRows - 1
            if vp_profileShow
                if vp_profileGradientColors == 'Gradient Colors'
                    vp_valueAreaUpColor       := color.from_gradient(volumeDataArray.totalVolume.get(volumeNodeLevel) / volumeDataArray.totalVolume.max(), 0, 1, color.new(vp_valueAreaUpColor      , 95), color.new(vp_valueAreaUpColor      , 0))  
                    vp_valueAreaDwonColor     := color.from_gradient(volumeDataArray.totalVolume.get(volumeNodeLevel) / volumeDataArray.totalVolume.max(), 0, 1, color.new(vp_valueAreaDwonColor    , 95), color.new(vp_valueAreaDwonColor    , 0))  
                    vp_profileUpVolumeColor   := color.from_gradient(volumeDataArray.totalVolume.get(volumeNodeLevel) / volumeDataArray.totalVolume.max(), 0, 1, color.new(vp_profileUpVolumeColor  , 95), color.new(vp_profileUpVolumeColor  , 0))  
                    vp_profileDownVolumeColor := color.from_gradient(volumeDataArray.totalVolume.get(volumeNodeLevel) / volumeDataArray.totalVolume.max(), 0, 1, color.new(vp_profileDownVolumeColor, 95), color.new(vp_profileDownVolumeColor, 0))  
    
                int startProfileIndex = profilePlacementRight ? profileHorizontalOffset + int(last_bar_index - volumeDataArray.bullishVolume.get(volumeNodeLevel) / volumeDataArray.totalVolume.max() * profileWidth) : VP.startIndex
                int endProfileIndex   = profilePlacementRight ? profileHorizontalOffset + last_bar_index : int(startProfileIndex + volumeDataArray.bullishVolume.get(volumeNodeLevel) / volumeDataArray.totalVolume.max() * profileWidth)

                VP.boxes.push(box.new(startProfileIndex, lowestPrice + (volumeNodeLevel + .1) * priceStep, endProfileIndex, lowestPrice + (volumeNodeLevel + .9) * priceStep, color(na), bgcolor = volumeNodeLevel >= VP.valLevel and volumeNodeLevel <= VP.vahLevel ? vp_valueAreaUpColor : vp_profileUpVolumeColor))

                startProfileIndex := profilePlacementRight ? startProfileIndex : endProfileIndex
                endProfileIndex   := profilePlacementRight ? startProfileIndex - int( (volumeDataArray.totalVolume.get(volumeNodeLevel) - volumeDataArray.bullishVolume.get(volumeNodeLevel)) / volumeDataArray.totalVolume.max() * profileWidth) : startProfileIndex + int( (volumeDataArray.totalVolume.get(volumeNodeLevel) - volumeDataArray.bullishVolume.get(volumeNodeLevel)) / volumeDataArray.totalVolume.max() * profileWidth)

                VP.boxes.push(box.new(startProfileIndex, lowestPrice + (volumeNodeLevel + .1) * priceStep, endProfileIndex, lowestPrice + (volumeNodeLevel + .9) * priceStep, color(na), bgcolor = volumeNodeLevel >= VP.valLevel and volumeNodeLevel <= VP.vahLevel ? vp_valueAreaDwonColor : vp_profileDownVolumeColor))
                volumeDataArray.endProfileIndex.set(volumeNodeLevel, endProfileIndex)

        if  vn_peaksShow != 'None' or  vn_troughsShow != 'None'
            int startVolumeNodeIndex = int(na)
            int endVolumeNodeIndex = int(na)
            bool peakUpperNth = false
            bool peakLowerNth = false

            int peaksNumberOfNodes = int(vp_profileNumberOfRows * vn_peaksNumberOfNodes)
            float[] tempPeakTotalVolume = volumeDataArray.totalVolume.copy()

            for index = 1 to peaksNumberOfNodes
                tempPeakTotalVolume.unshift(0.)
                tempPeakTotalVolume.push(0.)

            for volumeNodeLevel = 0 to vp_profileNumberOfRows - 1 + 2 * peaksNumberOfNodes 
                if vn_peaksShow != 'None' and volumeNodeLevel >= 2 * peaksNumberOfNodes 
                    for currentVolumeNode = volumeNodeLevel - 2 * peaksNumberOfNodes to volumeNodeLevel - peaksNumberOfNodes - 1
                        if tempPeakTotalVolume.get(volumeNodeLevel - peaksNumberOfNodes) <= tempPeakTotalVolume.get(currentVolumeNode)
                            peakUpperNth := false
                            break
                        else
                            peakUpperNth := true

                    for currentVolumeNode = volumeNodeLevel - peaksNumberOfNodes + 1 to volumeNodeLevel
                        if tempPeakTotalVolume.get(volumeNodeLevel - peaksNumberOfNodes) <= tempPeakTotalVolume.get(currentVolumeNode)
                            peakLowerNth := false
                            break
                        else
                            peakLowerNth := true

                    if peakUpperNth and peakLowerNth and tempPeakTotalVolume.get(volumeNodeLevel - peaksNumberOfNodes) / tempPeakTotalVolume.max() > vn_VolumeNodeThreshold
                        startVolumeNodeIndex := vp_profileShow ? profilePlacementRight ? VP.startIndex : volumeDataArray.endProfileIndex.get(volumeNodeLevel - 2 * peaksNumberOfNodes) : VP.startIndex
                        endVolumeNodeIndex   := vp_profileShow ? profilePlacementRight ? volumeDataArray.endProfileIndex.get(volumeNodeLevel - 2 * peaksNumberOfNodes) : last_bar_index : last_bar_index
                        vn_peakVolumeColor := vn_peaksShow == 'Peaks' ? vn_peakVolumeColor : color.from_gradient(tempPeakTotalVolume.get(volumeNodeLevel - peaksNumberOfNodes) / tempPeakTotalVolume.max(), 0, 1, color.new(vn_peakVolumeColor, 95), color.new(vn_peakVolumeColor, 65))  
                        VP.boxes.push(box.new(startVolumeNodeIndex, lowestPrice + (volumeNodeLevel - 2 * peaksNumberOfNodes + .1) * priceStep, endVolumeNodeIndex, lowestPrice + (volumeNodeLevel - 2 * peaksNumberOfNodes + .9) * priceStep, color(na), bgcolor = vn_peakVolumeColor))

                        if vn_peaksShow == 'Clusters'
                            for currentVolumeNode = volumeNodeLevel - 2 * peaksNumberOfNodes to volumeNodeLevel
                                if currentVolumeNode >= peaksNumberOfNodes and currentVolumeNode <= vp_profileNumberOfRows - 1 + peaksNumberOfNodes
                                    if not volumeDataArray.peakVolume.get(currentVolumeNode - peaksNumberOfNodes)
                                        startVolumeNodeIndex := vp_profileShow ? profilePlacementRight ? VP.startIndex : volumeDataArray.endProfileIndex.get(currentVolumeNode - peaksNumberOfNodes) : VP.startIndex
                                        endVolumeNodeIndex   := vp_profileShow ? profilePlacementRight ? volumeDataArray.endProfileIndex.get(currentVolumeNode - peaksNumberOfNodes) : last_bar_index : last_bar_index
                                        VP.boxes.push(box.new(startVolumeNodeIndex, lowestPrice + (currentVolumeNode - peaksNumberOfNodes + .0) * priceStep, endVolumeNodeIndex, lowestPrice + (currentVolumeNode - peaksNumberOfNodes + 1.) * priceStep, color(na), bgcolor = vn_peakVolumeColor))
                                        volumeDataArray.peakVolume.set(currentVolumeNode - peaksNumberOfNodes, true)
            tempPeakTotalVolume.clear()

            bool troughUpperNth = false
            bool troughLowerNth = false
            int troughsNumberOfNodes = int(vp_profileNumberOfRows * vn_troughsNumberOfNodes)
            float[] tempTroughTotalVolume = volumeDataArray.totalVolume.copy()

            for index = 1 to troughsNumberOfNodes
                tempTroughTotalVolume.unshift(volumeDataArray.totalVolume.max())
                tempTroughTotalVolume.push(volumeDataArray.totalVolume.max())
                
            for volumeNodeLevel = 0 to vp_profileNumberOfRows - 1 + 2 * troughsNumberOfNodes 
                if vn_troughsShow != 'None' and volumeNodeLevel >= 2 * troughsNumberOfNodes 
                    for currentVolumeNode = volumeNodeLevel - 2 * troughsNumberOfNodes to volumeNodeLevel - troughsNumberOfNodes - 1
                        if tempTroughTotalVolume.get(volumeNodeLevel - troughsNumberOfNodes) >= tempTroughTotalVolume.get(currentVolumeNode)
                            troughUpperNth := false
                            break
                        else
                            troughUpperNth := true

                    for currentVolumeNode = volumeNodeLevel - troughsNumberOfNodes + 1 to volumeNodeLevel
                        if tempTroughTotalVolume.get(volumeNodeLevel - troughsNumberOfNodes) >= tempTroughTotalVolume.get(currentVolumeNode)
                            troughLowerNth := false
                            break
                        else
                            troughLowerNth := true

                    if troughUpperNth and troughLowerNth and tempTroughTotalVolume.get(volumeNodeLevel - troughsNumberOfNodes) / tempTroughTotalVolume.max() > vn_VolumeNodeThreshold
                        startVolumeNodeIndex := vp_profileShow ? profilePlacementRight ? VP.startIndex : volumeDataArray.endProfileIndex.get(volumeNodeLevel - 2 * troughsNumberOfNodes) : VP.startIndex
                        endVolumeNodeIndex   := vp_profileShow ? profilePlacementRight ? volumeDataArray.endProfileIndex.get(volumeNodeLevel - 2 * troughsNumberOfNodes) : last_bar_index : last_bar_index
                        vn_troughVolumeColor := vn_troughsShow == 'Troughs' ? vn_troughVolumeColor : color.from_gradient(tempTroughTotalVolume.get(volumeNodeLevel - troughsNumberOfNodes) / tempTroughTotalVolume.max(), 0, 1, color.new(vn_troughVolumeColor, 95), color.new(vn_troughVolumeColor, 31))  
                        VP.boxes.push(box.new(startVolumeNodeIndex, lowestPrice + (volumeNodeLevel - 2 * troughsNumberOfNodes + .1) * priceStep, endVolumeNodeIndex, lowestPrice + (volumeNodeLevel - 2 * troughsNumberOfNodes + .9) * priceStep, color(na), bgcolor = vn_troughVolumeColor))

                        if vn_troughsShow == 'Clusters'
                            for currentVolumeNode = volumeNodeLevel - 2 * troughsNumberOfNodes to volumeNodeLevel
                                if currentVolumeNode >= troughsNumberOfNodes and currentVolumeNode <= vp_profileNumberOfRows - 1 + troughsNumberOfNodes
                                    if not volumeDataArray.troughVolume.get(currentVolumeNode - troughsNumberOfNodes)
                                        startVolumeNodeIndex := vp_profileShow ? profilePlacementRight ? VP.startIndex : volumeDataArray.endProfileIndex.get(currentVolumeNode - troughsNumberOfNodes) : VP.startIndex
                                        endVolumeNodeIndex   := vp_profileShow ? profilePlacementRight ? volumeDataArray.endProfileIndex.get(currentVolumeNode - troughsNumberOfNodes) : last_bar_index : last_bar_index
                                        VP.boxes.push(box.new(startVolumeNodeIndex, lowestPrice + (currentVolumeNode - troughsNumberOfNodes + .0) * priceStep, endVolumeNodeIndex, lowestPrice + (currentVolumeNode - troughsNumberOfNodes + 1.) * priceStep, color(na), bgcolor = vn_troughVolumeColor))
                                        volumeDataArray.troughVolume.set(currentVolumeNode - troughsNumberOfNodes, true)
            tempTroughTotalVolume.clear()

        if vn_highestNVolumeNodes > 0
            for highestNode = 0 to vn_highestNVolumeNodes - 1
                int startVolumeNodeIndex = vp_profileShow ? profilePlacementRight ? VP.startIndex : volumeDataArray.endProfileIndex.get(volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.max(highestNode))) : VP.startIndex
                int endVolumeNodeIndex   = vp_profileShow ? profilePlacementRight ? volumeDataArray.endProfileIndex.get(volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.max(highestNode))) : last_bar_index : last_bar_index
                VP.boxes.push(box.new(startVolumeNodeIndex, lowestPrice + (volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.max(highestNode)) + .1) * priceStep, endVolumeNodeIndex, lowestPrice + (volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.max(highestNode)) + .9) * priceStep, color(na), bgcolor = vn_highestVolumeColor))

        if vn_lowestNVolumeNodes > 0
            int lowestNVolumeNodeCount = 0
            int lowestNVolumeNodeIndex = 0
            float lowestNVolumeNodeValue = 0.
            while lowestNVolumeNodeCount < vn_lowestNVolumeNodes
                if lowestNVolumeNodeIndex == vp_profileNumberOfRows
                    break
                if volumeDataArray.totalVolume.min(lowestNVolumeNodeIndex) != lowestNVolumeNodeValue
                    lowestNVolumeNodeValue := volumeDataArray.totalVolume.min(lowestNVolumeNodeIndex)
                    int startVolumeNodeIndex = vp_profileShow ? profilePlacementRight ? VP.startIndex : volumeDataArray.endProfileIndex.get(volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.min(lowestNVolumeNodeIndex))) : VP.startIndex
                    int endVolumeNodeIndex   = vp_profileShow ? profilePlacementRight ? volumeDataArray.endProfileIndex.get(volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.min(lowestNVolumeNodeIndex))) : last_bar_index : last_bar_index
                    VP.boxes.push(box.new(startVolumeNodeIndex, lowestPrice + (volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.min(lowestNVolumeNodeIndex)) + .1) * priceStep, endVolumeNodeIndex, lowestPrice + (volumeDataArray.totalVolume.indexof(volumeDataArray.totalVolume.min(lowestNVolumeNodeIndex)) + .9) * priceStep, color(na), bgcolor = vn_lowestVolumeColor))
                    lowestNVolumeNodeCount += 1
                lowestNVolumeNodeIndex += 1
````
