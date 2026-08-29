<!-- tradingview-pine-id: PUB;c1afbad74e454904b0943f1bb287362d -->
<!-- tradingviewscripts-format: 1 -->
# Multitimeframe Fair Value Gap – FVG (Zeiierman)

Source: https://www.tradingview.com/script/5jS51RsP-Multitimeframe-Fair-Value-Gap-FVG-Zeiierman/

## Description

█ Overview
The Multitimeframe Fair Value Gap – FVG (Zeiierman) indicator provides a dynamic and customizable visualization of institutional imbalances (Fair Value Gaps) across multiple timeframes. Built for traders who seek to analyze price inefficiencies, this tool helps highlight potential entry points, unmitigated gaps, and directional bias using smart volume logic and adaptive visual elements.

[image]https://www.tradingview.com/x/cA5xZ8D2/[/image]

A Fair Value Gap (FVG) forms when there's a three-candle sequence in which a market imbalance leaves a "gap" between the wicks of candle 1 and candle 3. These areas are often considered footprints of institutional activity, and this indicator gives you the tools to track them with surgical precision across any timeframe you choose—regardless of the one you're viewing.

This indicator also includes a trend filter powered by a low-pass Butterworth filter, enabling traders to distinguish between countertrend vs. trend-aligned FVGs for more intelligent decision-making. On top of that, it features a dynamic FVG table for live tracking and bull/bear volume power visualization inside each gap, adding powerful clarity to market intent.

[image]https://www.tradingview.com/x/DZqSmVrI/[/image]

█ How It Works
The indicator analyzes the open, high, low, close, and volume of candles from a user-selected timeframe. It identifies Fair Value Gaps based on wick logic and only confirms those that meet customizable strength criteria. Once detected, the indicator visualizes each FVG with dynamically extending boxes, optional buy/sell volume bars, and a real-time mitigation check.
⚪ Multitimeframe Logic
Users can analyze FVGs from a higher or lower timeframe regardless of their current chart.
This is achieved using request.security() to fetch OHLCV data from the chosen timeframe.

⚪ Wick Sensitivity & Impulse Filter
The script measures the wick size of potential FVG candles and compares them to a running average. Only FVGs with wick sizes above a certain sensitivity threshold (user-controlled) are plotted. This ensures only meaningful price dislocations (e.g., strong impulsive moves) are shown, reducing noise.

⚪ Midpoint Mitigation Logic
FVGs are marked as "mitigated" when the price revisits the gap area. Traders can choose whether full gap closure or just a midpoint touch is required. This allows faster reactivity in real-time trading environments.

⚪ Bull & Bear Power – Volume-Weighted Visualization
Every Fair Value Gap box includes sub-bars representing the estimated buy and sell effort that created the gap. These are calculated using the candle's close in relation to its high/low range and volume:

[*]Buy Volume % ≈ effort from low to close
[*]Sell Volume % ≈ effort from high to close

Each sub-bar inside the FVG:

[*]Is color-coded (UpCol for bullish, DnCol for bearish)
[*]Is drawn proportionally to the strength of buyers or sellers
[*]Visually displays who was in control during the imbalance

⚪ FVG Table – Dynamic On-Chart Overview
The indicator includes an optional on-chart table that displays all currently active (unmitigated) FVGs in a side panel format:

[*]Automatic updates as gaps are formed and mitigated
[*]Color-coded rows to show bullish vs. bearish FVGs
[*]Timestamps to know precisely when the gap formed
[*]User-controlled position via Table Left and Table Right

This is a gap watchlist overlay, giving traders a concise view of current inefficiencies without manually scanning the chart.

⚪ FVG Trend Filter (Butterworth Smoother)
Using a two-pole Butterworth low-pass filter, the indicator computes a trendline based on average FVG values, offering a smooth but responsive directional signal.

[*]Passband Ripple (dB): Controls sensitivity and overshoot tolerance
[*]Cutoff Frequency (0–0.5): Sets how quickly the trendline reacts

The trendline helps categorize each FVG:

[*]Trend up → favor bullish FVGs
[*]Trend down → favor bearish FVGs

It adds an extra dimension to FVG entries, helping distinguish between trend-aligned and countertrend signals.

█ How to Use
⚪ Identify Institutional Gaps
Use this tool to identify areas where institutions may have left imbalances behind quickly. 
These areas often become:

[*]Strong support/resistance zones
[*]Areas where price might react sharply
[*]Targets for liquidity sweeps or retracements

[image]https://www.tradingview.com/x/Q6Hk7Sin/[/image]

⚪ React to Trend or Countertrend
The built-in trendline helps categorize each FVG:

[*]Trend up → Bullish FVGs have higher validity
[*]Trend down → Bearish FVGs have higher validity

[image]https://www.tradingview.com/x/m5OIuSwb/[/image]

⚪ Volume Context via Bull/Bear Power
Each Fair Value Gap is more than just a price imbalance — it’s a story of effort and intent. The Bull/Bear Power feature visualizes the buy and sell pressure behind each FVG, helping you understand how the gap was formed and who was in control.

[*]A bullish FVG with a strong buy effort suggests continuation potential — buyers dominated the move.
[*]A bullish FVG with a dominant sell effort could signal a trap or reversal — sellers may have overwhelmed the breakout.
[*]These insights allow you to confirm imbalance strength, spot traps early, and add confidence to entries based on dominant volume profiles.

Instead of viewing gaps as static zones, this feature turns each into a live volume map — a visual breakdown of who moved the market and whether that move had conviction.

[image]https://www.tradingview.com/x/Rgkfphec/[/image]

⚪ Plan with the FVG Table
The FVG Table acts as your on-chart control center for tracking active imbalances. When enabled, it provides a clear summary of all unmitigated Fair Value Gaps, helping you stay organized and focused during fast-moving sessions.

[*]Track live and historical gaps: See exactly when and where each FVG formed.
[*]Monitor older, still-valid zones: Gaps off-screen but not mitigated remain in play — perfect for anticipating future reactions.
[*]Gauge market bias at a glance: The balance of bullish vs. bearish FVGs helps you understand overall directional pressure.
[*]Plan entries confidently: Use the table to reference all zones for risk management, confluence stacking, or layered execution strategies.

Instead of manually scanning your chart, the FVG Table offers a clean, at-a-glance overview of the market’s inefficiencies — giving you the structure needed to act with precision.

[image]https://www.tradingview.com/x/YBiNvYQD/[/image]

█ Settings

[*]FVG Timeframe
Select any timeframe to source FVGs independent of your current chart.
[*]Sensitivity
Filter FVGs by how impulsive the move is — it helps you eliminate weak gaps.
[*]Mitigated on Mid
Control whether gaps are removed at midpoint touch or full fill.
[*]Table Settings
Control the table position and width. Cleanly view all active FVGs.
[*]FVG Style
Customize gap box colors, length, and bullish/bearish overlays.
[*]Trend Filter
Enable or disable the smoothed FVG-based trendline with customizable smoothing controls.

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {

//@version=6
indicator('Multitimeframe Fair Value Gap – FVG (Zeiierman)',shorttitle = "MTF FVG (Zeiierman)", overlay = true, max_bars_back = 5000, max_boxes_count = 500)
//~~}

//~~ Tooltips {
var string t1 = "Select the timeframe for calculating Fair Value Gaps (FVGs).\n\nThis setting controls which candle data 
 is used to identify FVGs. For example, selecting '15' uses the 15-minute chart even if you’re viewing a different timeframe.
 \n\nA higher timeframe (e.g., 1H, 4H) can show more significant institutional gaps, while a lower timeframe (e.g., 5min) 
 can detect intraday inefficiencies."
var string t2 = "Adjusts the minimum required candle body size (relative to average) to validate a Fair Value Gap.
 \n\n**How it works:**\nA wick is considered significant only if it is greater than or equal to the average body size 
 multiplied by this sensitivity.\n\n- Increase to only show strong, impulsive moves (fewer but more powerful FVGs).
 \n- Decrease to detect more FVGs, including minor ones (may include noise)."
var string t3 = "Enable this to consider a Fair Value Gap 'mitigated' when price reaches the midpoint of the gap.
 \n\n**Without this**, mitigation requires full price fill from top to bottom of the gap.\n**With this**, 
 a touch of the midpoint is enough to consider the imbalance resolved.\n\nMidpoint logic allows earlier detection of 
 mitigation for traders seeking speed over precision."
var string t4 = "Toggle the visibility of the Fair Value Gap summary table on the chart.\n\nThis table shows each FVG’s 
 placement and context. Turning it off hides the visual output (but the logic still runs)."
var string t5 = "Adjust the horizontal distance from the current bar to where the FVG info table begins.\n\n**Increase** 
 to move the table further to the left (away from price).\n**Decrease** to pull the table closer to price action.\nUseful 
 for positioning the overlay in non-intrusive areas."
var string t6 = "Set how far the FVG data table extends to the right of each row.\n\n**Larger values** give more space 
 per FVG block, useful for long labels or wide screens.\n**Smaller values** create a more compact layout, saving screen real estate."
var string t7 = "Control how far each Fair Value Gap box extends into the future.\n\nThis determines the horizontal 
 length (in bars) of the visual box representing the FVG.\n\n- A higher value keeps unfilled gaps visible longer 
 (good for swing traders).\n- A lower value limits clutter on active charts (better for scalpers)."
var string t8 = "Set the background color used to display **buy-side Fair Value Gaps** (bullish direction).\n\nA more 
 transparent color makes it subtle, while a more opaque shade makes it prominent."
var string t9 = "Set the background color used to display **sell-side Fair Value Gaps** (bearish direction).\n\nUse 
 this to visually distinguish bearish gaps from bullish ones."
var string t10 = "Set the base color used for all FVG boxes and borders.\n\nThis neutral tone is used before the price 
 fills the gap, or for the general FVG zone display.\nCombine with bullish/bearish highlights for a multi-layered visual effect."
var string t11 = "Toggle the display of a trendline based on the average direction of valid Fair Value Gaps.
 \n\n**Enabled:** You'll see a dynamic line that updates based on confirmed FVGs, giving directional context.
 \n**Disabled:** No trendline is shown, only individual FVGs are plotted."
var string t12 = "Sets the ripple level (in decibels) for the low-pass trend filter that processes FVG trend direction.
 \n\nHigher values allow more fluctuations (more sensitive).\nLower values produce smoother, slower trend transitions.
 \n\nRecommended: Start with 10dB and adjust based on market noise."
var string t13 = "Sets the cutoff frequency for the trend filter (range: 0 to 0.5).\n\n**Lower values** filter out 
 more noise (slower trend reaction).\n**Higher values** allow faster reaction to price changes.\n\nSet based on how 
 reactive you want the FVG trendline to be."
var string t14 = "Set the color of the **bullish trendline** when the FVG trend is rising.
 \n\nUse a vibrant green or lime for clear uptrend confirmation."
var string t15 = "Set the color of the **bearish trendline** when the FVG trend is falling.
 \n\nUse a strong red to clearly highlight downtrends based on FVGs."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
tf          = input.timeframe('', title = 'Timeframe', group="FVG Timeframe",inline = 'tf')
BodySens    = input.float(1.0, title = 'Sensativity', step = .1, minval = 0,group="FVG Timeframe",inline='tf', tooltip=t1+t2)
mit         = input.bool(true,"Mitigated on mid", group="FVG Mitigation", tooltip=t3)
showActive  = input.bool(false, title = 'Show FVG table', group="FVG Table", tooltip=t4)
TableLeft   = input.int(5, title = 'Table Left', minval = 0, maxval = 30, group="FVG Table",inline = 'Tab') * 10
TableRight  = input.int(10, title = 'Right', minval = 10, maxval = 50, group="FVG Table",inline = 'Tab', tooltip=t5+t6) * 10
extendLength= input.int(10,"Extend Boxes", group="FVG Style", tooltip=t7)
UpCol       = input.color(color.new(#00ffbb, 50), title = '', group="FVG Style", inline = 'FVG')
DnCol       = input.color(color.new(#ff1100, 50), title = '', group="FVG Style",inline = 'FVG')
Col         = input.color(color.new(color.gray, 85), title = '', group="FVG Style", inline = 'FVG', tooltip=t8+t9+t10)
showTrend   = input.bool(true, title = 'Show FVG Trend', group="Trend", tooltip=t11)
rp          = input.float(10.0, "Passband Ripple (dB)", group="Trend",minval=0.1, step=0.1, tooltip=t12)
fc          = input.float(0.1, "Cutoff Frequency (0 to 0.5)",group="Trend",minval=0.001, maxval=0.5, step=0.01, tooltip=t13)
TUpCol      = input.color(color.lime, title = '', group="Trend",inline = 'Trend')
TDnCol      = input.color(color.red, title = '', group="Trend",inline = 'Trend', tooltip=t14+t15)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Arrays {
type Data
    array<box> fvg
    array<box> bv
    array<box> sv
    array<line>mid

var bv = Data.new(array.new<box>(),array.new<box>(),array.new<box>(),array.new<line>())
var sv = Data.new(array.new<box>(),array.new<box>(),array.new<box>(),array.new<line>())

var save  = array.new<float>(0)
var FVGs  = array.new<box>()
var TLine = array.new<float>(1, 0.0)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Functions {
getMTF() => [close, high, low, high[2], low[2], volume]

getCandle() =>
    wick = math.max(close, open) - math.min(close, open)
    array.push(save, wick)
    avgFVG = array.avg(save)
    [wick, avgFVG]

getBarTime(t, barsOffset) =>
    t + (barsOffset * timeframe.in_seconds(timeframe.period) * 1000)

BarsBack(val, hl) =>
    back = time
    for i = 0 to 4999 by 1
        if val == hl[i]
            back := time[i]
            break
    back

VolumePower(v,c,l,h,ca)=> ca ? math.round(math.round(v * (c - l) / (h - l)) / v * 100) :
 math.round(math.round(v * (h - c) / (h - l)) / v * 100)

method Cleaner(Data d, cond) =>
    if d.fvg.size()>0
        for [i,e] in d.fvg
            top = e.get_top()
            bot = e.get_bottom()
            mid = math.avg(top,bot)
            Cond = mit ? (cond ? low<=mid : high>=mid) : (cond ? low <= bot : high >= top)
            if Cond
                e.delete()
                d.mid.get(i).delete()
                d.bv.get(i).delete()
                d.sv.get(i).delete()
                d.fvg.remove(i)
                d.mid.remove(i)
                d.bv.remove(i)
                d.sv.remove(i)

UpdateFVG(Box) =>
    if Box.size() > 0
        for e in Box
            date = str.format_time(e.get_left(),"yyyy-MM-dd HH:mm",syminfo.timezone)
            b = box.new(bar_index + TableLeft, e.get_top(), bar_index + TableRight, e.get_bottom(), 
             bgcolor = close<e.get_bottom()?DnCol:UpCol, border_color = color(na),text=date,text_color=chart.fg_color)
            FVGs.push(b)

FVG(l,l2,h,h2,c1,LBack,L2Back,HBack,H2Back,wick,avgFVG,buyVol,sellVol) =>
    BullFVG = l > h2 and c1 > h2 
    BearFVG = h < l2 and c1 < l2

    if BullFVG and not BullFVG[1] and wick >= avgFVG * BodySens
        prev = array.get(TLine, 0)
        array.unshift(TLine, math.avg(ohlc4, prev))

        future = getBarTime(HBack,extendLength)
        b = box.new(H2Back, l, future, h2, bgcolor = Col, border_color = Col, extend = extend.none,xloc = xloc.bar_time)
        bv.fvg.unshift(b)

        mid = math.avg(l,h2)
        m = line.new(H2Back,mid,future,mid,xloc=xloc.bar_time,color=color.white,style=line.style_dashed)
        bv.mid.unshift(m)

        dist = (future-H2Back)
        bb = box.new(H2Back,mid,int(H2Back+dist*(buyVol/100)),l,bgcolor = UpCol, border_color = UpCol, extend = extend.none,xloc = xloc.bar_time)
        sb = box.new(H2Back,h2,int(H2Back+dist*(sellVol/100)),mid,bgcolor = DnCol, border_color = DnCol, extend = extend.none,xloc = xloc.bar_time)
        bv.bv.unshift(bb)
        bv.sv.unshift(sb)

    if BearFVG and not BearFVG[1] and wick >= avgFVG * BodySens
        prev = array.get(TLine, 0)
        array.unshift(TLine, math.avg(ohlc4, prev))

        future = getBarTime(LBack,extendLength)
        b = box.new(L2Back, l2, future, h, bgcolor = Col, border_color = Col, extend = extend.none,xloc = xloc.bar_time)
        sv.fvg.unshift(b)

        mid = math.avg(l2,h)
        m = line.new(L2Back,mid,future,mid,xloc=xloc.bar_time,color=color.white,style=line.style_dashed)
        sv.mid.unshift(m)

        dist = (future-L2Back)
        bb = box.new(L2Back,mid,int(L2Back+dist*(buyVol/100)),l2,bgcolor = UpCol, border_color = UpCol, extend = extend.none,xloc = xloc.bar_time)
        sb = box.new(L2Back,h,int(L2Back+dist*(sellVol/100)),mid,bgcolor = DnCol, border_color = DnCol, extend = extend.none,xloc = xloc.bar_time)
        sv.bv.unshift(bb)
        sv.sv.unshift(sb)

    else
        prev = array.get(TLine, 0)
        array.unshift(TLine, prev)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Main {
[c1, h, l, h2, l2, v] = request.security(syminfo.tickerid, tf, getMTF(), lookahead = barmerge.lookahead_on)
[wick, avgFVG] = request.security(syminfo.tickerid, tf, getCandle(), lookahead = barmerge.lookahead_on)
HBack = BarsBack(h, high)
LBack = BarsBack(l, low)
H2Back = BarsBack(h2, high)
L2Back = BarsBack(l2, low)

buyVol  = VolumePower(v, c1, l, h,true)
sellVol = VolumePower(v, c1, l, h,false)

FVG(l,l2,h,h2,c1,LBack,L2Back,HBack,H2Back,wick,avgFVG,buyVol,sellVol)
bv.Cleaner(true)
sv.Cleaner(false)

if showActive
    b = box.new(bar_index + TableLeft, ta.max(high), bar_index + TableRight, ta.min(low), bgcolor = color.new(color.gray, 100), border_color = color.gray, extend = extend.none)
    box.delete(b[1])

    //Delete Old
    for e in FVGs
        e.delete()

    //Insert new
    FVGs.clear()
    UpdateFVG(bv.fvg)
    UpdateFVG(sv.fvg)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Trend {
var TCol = color.gray
Trend = array.get(TLine, 0)
TCol := Trend > Trend[1] ? TUpCol : Trend < Trend[1] ? TDnCol : TCol[1]
src  = math.avg(h,l,Trend)
epsilon = math.sqrt(math.pow(10, rp/10) - 1)
d       = math.sqrt(1 + epsilon*epsilon)
c    = 1 / math.tan(math.pi * fc)
norm = 1 / (1 + d*c + c*c)
b0   = norm
b1   = 2 * norm
b2   = norm
a1   = 2 * norm * (1 - c*c)
a2   = norm * (1 - d*c + c*c)
trend = 0.0
trend := (bar_index < 2) ? src : (b0*src + b1*src[1] + b2*src[2] - a1*nz(trend[1]) - a2*nz(trend[2]))
Trend_ = plot(showTrend?trend:na, color=TCol, title="FVG Trend Filter")
visualclose  = ta.ema(Trend,10)
visualclose_ = plot(visualclose, color=color.new(color.blue,100), title="visualtrend", editable = false)
fill(Trend_, visualclose_, trend, visualclose,color.new(TCol, 70),na, title="Fill")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
