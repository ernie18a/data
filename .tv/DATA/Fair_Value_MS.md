<!-- tradingview-pine-id: PUB;0b067f9bc137451498b38c9b0e18ae20 -->
<!-- tradingviewscripts-format: 1 -->
# Fair Value MS

Source: https://www.tradingview.com/script/AUsPh7VF-Fair-Value-MS/

## Description

This indicator introduces rigid rules to familiar concepts to better capture and visualize Market Structure and Areas of Support and Resistance in a way that is both rule-based and reactive to market movements. 

Typical "Market Structure" or "Zig-Zag" methods determine swing points based on fixed thresholds (length or percentage). While this does provide rigid structure, the results may be lagging or confusing due to the timing, since it is fixed to static parameters.

I believe the concept of Fair Value Gaps can solve this problem. 

As you will notice, there are no length settings in this indicator.

 > FVG Market Structure

Fair Value Gaps are a well known concept used to indicate directional intent, forming when price moves aggressively in one direction, leaving behind an imbalance between buyers and sellers. While the term FVG was popularized by ICT, the underlying concept predates them, known historically as imbalances, inefficiencies, or liquidity voids in institutional trading.

Note: For simplicity, in this indicator they'll be called FVGs.

By reading into this, we are able to clearly and rigidly define market structure simply by "looking" at the chart, using objective price events rather than subjective interpretation, or lengths.

[image]https://www.tradingview.com/x/pjgPs2SW/[/image]

By using FVGs to determine structure direction, the length, and speed of identification lies entirely on the market. If an FVG Down occurs immediately after a New Higher High forms, it is reasonable to assume there was a seller at that point, so the script would indicate a New Swing High.

The script is NOT stuck, waiting for a % retrace, or # bars to pass to identify it as such.

Sometimes the market is in a steady trend in a single direction and no FVGs form; therefore, no structure forms. -> Why would we try to impose structure on a clear trend?

Ultimately, the FVG Structure Method uses real reactions from the market to determine Market structure, and is not fixed to specific parameters.

As with other market structure indicators, "Market Structure Breaks" are still identifiable when price moves outside the most recent swing points. 

These are helpful to indicate larger direction. In the following section you will see how these help us determine when we should start the search for an "Area of Interest (AOI)".

 > Areas of Interest (AOIs)

[image]https://www.tradingview.com/x/OhIVxWNL/[/image]

"Area of Interest (AOI)" is a generalized term, and could refer to many types of zones you might recognize under different names. While the AOIs in this indicator are specialized in their own way, I have chosen to simply use the term "Area of Interest" because it’s more important to understand how they behave and why they exist than to focus on what they’re called.

The goal of an AOI is to point out reasonable areas where buyers or sellers may be staging, as is typical with support and resistance.

In order to reasonably identify these areas, we look for cause and effect relationships. When considering these relationships, it's easier to understand the placement of the points to define each zone.

(Buyer Examples)

Cause: Strong Buyers step in at Swing Low
Effect: Fair Value Gap Forms

Cause: Sustained Buying Pressure
Effect: Market Structure Breaks

In this example, The zone is drawn from the Swing Low, to the Bottom of the FVG closest to the swing point.

In theory, the participation at the swing point was strong and aggressive enough to create the FVG imbalance. Which then found acceptance and continued into a Market Structure Break. So with these AOIs, we are trying to locate the aggressive Buyers or Sellers which were positioned BEFORE the FVG. 

These Zones are intended to act as areas to look for reactions from market participants, to judge where price may be going. When revisiting these zones, we look for a reaction or a break, to further provide us information to if the buyers or sellers are still there.

[image]https://www.tradingview.com/x/WKNIgdpG/[/image]

As seen in the screenshot above, The information we gain is not from the creation of these zones, but from the behavior we witness when these zones are revisited.

Technical Note: In this indicator, Market Structure Breaks are only considered when price closes outside the recent swing points. Wicks are not considered as confirmation, therefore are not used to detect structural breaks.

[image]https://www.tradingview.com/x/ceJuQaCT/[/image]

Inside each AOI you can optionally display a readout of the volume which accumulated during the time starting at the swing point and going until the closing bar of the FVG.

Note: We are counting volume until the closing bar of the FVG since the FVG is a 3 bar formation, and aggressive volume is required throughout to create the imbalance.

[image]https://www.tradingview.com/x/1v05jmfy/[/image]

There are multiple FVGs that typically occur in a single direction, but we do not look to every single one to be indicative of structure, only the first FVG in the opposite direction of the previous direction (which is determined by previous FVGs)

[image]https://www.tradingview.com/x/lHHHMU2X/[/image]

You will probably notice, the AOIs do not form from the closest swing or FVG to the break, this is because we are targeting larger directional changes to draw these AOIs from.

Since they do not always happen perfectly every time, the AOI formation waits for an FVG to occur AND a Market structure break to happen. One without the other will result in no Zone displaying.

> Reflection Lines

While they may seem slightly redundant, Reflection Lines serve as reminders of previous support and resistance pivots. They are drawn at the same Pivots where and AOI is formed, and extend beyond the mitigation of the AOI. 

[image]https://www.tradingview.com/x/JRzKWQQZ/[/image]

These lines are often points of price to look for "Support Flips", a re-test pattern where price trades through previous support (or resistance) then returns to it and rejects, continuing into a larger move or trend.

Their namesake is based on the behavior of price, "reflecting" at these levels.

The Reflection lines are simple and change color based on price's location. 
If price is above, we would typically look to a reflection line in with support in mind.

As a basic filter, these lines use an average price to determine their color, this way they will not change their color as frequently in choppy situations.

> Session Start/End Lines

For analysis purposes and trade review, it is helpful to analyze with context.
For that reason, I have implemented start and end session lines into the indicator, these are helpful when reviewing historical charts to not provide additional context.

[image]https://www.tradingview.com/x/DP5sVKqF/[/image]

By default, they are set to the NYSE Session, but can be changed to fit any needs.

These lines are not advanced, and simply draw a line as the chart passes the start and end of the sessions. It's very likely that you may need to adjust the session for your specific needs.

Note: The Timezone can be adjusted within the code if needed. By Default, the indicator uses "America/New_York" Timezone.

> Conclusion

If you’ve ever felt like your structure tools were confusing or lagging, drawing zones too late, or zones that simply don't make sense, this should feel like a breath of fresh air. 

By removing arbitrary length settings and instead using FVGs to define structure and as a basis for AOIs, you're getting a more accurate look at what price is doing and where it's reacting from. 

This indicator is rule-based, reactive, and aims to keep things logical without fluff or false confidence.

Enjoy!

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © SamRecio

//@version=6
indicator("Fair Value MS", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 5000)

///_____________________________________________________________________________________________________________________
///User Inputs
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

timezone = "America/New_York" //Can be specified in GMT notation ("GMT-5") or as an IANA time zone database name found here >>> https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

fvgTog = input.string("Structural", title = "Show FVGs", options  = ["All","Structural","None"], group = "Fair Value Gaps", tooltip = "Note: 'All' Will cause less Historical AOIs to display.")
upCol = input.color(#3daa45, title = "  Up Color  ", inline = "upCol", group = "Fair Value Gaps")
downCol = input.color(#ff033e, title = "Down Color", inline = "downCol", group = "Fair Value Gaps")
upFillCol = input.color(color.rgb(0,0,0,100), title = "Fill", inline = "upCol", group = "Fair Value Gaps")
downFillCol = input.color(color.rgb(0,0,0,100), title = "Fill", inline = "downCol", group = "Fair Value Gaps")

aoiNum = input.int(3, minval = 0, title = "Extend AOIs", group = "Areas of Interest", tooltip = "Max number of Live AOIs Extended to the Current Bar.\n\nExample: 3 = 3 Above Price & 3 Below Price")
bullColor = input.color(#3daa4533, title = "Bull  Color", inline= "bullcolor", group = "Areas of Interest") 
bearColor = input.color(#ff033e33, title = "Bear Color", inline= "bearcolor",  group = "Areas of Interest")
bullFillColor = input.color(#3daa4533, title = "Fill", inline= "bullcolor", group = "Areas of Interest") 
bearFillColor = input.color(#ff033e33, title = "Fill", inline= "bearcolor",  group = "Areas of Interest")
textTog = input.bool(false, title = "AOI Volume", group = "Areas of Interest", inline = "txt")
textColor = textTog?input.color(color.new(color.white,40), title = "", group = "Areas of Interest", inline = "txt"):color.rgb(0,0,0,100)
textSize = str.lower(input.string("Auto", title = "Size", options = ["Tiny","Small","Normal","Large","Huge","Auto"], group = "Areas of Interest", inline = "txt"))

refTog = input.bool(true, title = "Display Reflection Lines", group = "Reflection Lines")
refDownCol = input.color(#ff3c00, title = "Resistance Color", group = "Reflection Lines")
refUpCol = input.color(#004d92, title = "Support Color", group = "Reflection Lines")
refCount = input.int(3, title = "Reflection Count", group = "Reflection Lines")

msTog = input.bool(true, title = "", inline = "ms", group = "Market Structure")
msStyle = input.string("___", title = "Structure", options = ["___","- - -",". . ."], inline = "ms", group = "Market Structure")
msColor = color.new(chart.fg_color,40)                                                                                  //input.color(color.gray, title = "", inline = "ms", group = "Market Structure")
mssBullTog = input.bool(true, title = "", inline = "bull", group = "Market Structure")
mssBullStyle = input.string("- - -", title = "  Bullish   ", options = ["___","- - -",". . ."], inline = "bull", group = "Market Structure")
mssBullColor = input.color(#3daa45, title = "", group = "Market Structure", inline = "bull")
mssBearTog = input.bool(true, title = "", inline = "bear", group = "Market Structure")
mssBearStyle = input.string("- - -", title = "  Bearish   ", options = ["___","- - -",". . ."], inline = "bear", group = "Market Structure")
mssBearColor = input.color(#ff033e, title = "", group = "Market Structure", inline = "bear")

sesh_in = input.session("0930-1600", title = "Session", group = "Session")
s_tog = input.bool(true, title = "Start", inline = "start", group = "Session")
s_style = input.string("- - -", title = "", options = ["___","- - -",". . ."], inline = "start", group = "Session")
sc = input.color(color.new(color.gray,50), title = "", inline = "start", group = "Session")
e_tog = input.bool(true, title = " End ", inline = "end", group = "Session")
e_style = input.string("- - -", title = "", options = ["___","- - -",". . ."], inline = "end", group = "Session")
ec = input.color(color.new(#ff033e,50), title = "", inline = "end", group = "Session")


///_____________________________________________________________________________________________________________________
///Functions
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

rope_smoother(float _src, float _threshold) =>
    var float _rope = _src
    _move = _src - _rope //Movement from Rope
    _rope += math.max(math.abs(_move) - nz(_threshold), 0) * math.sign(_move) //Directional Movement beyond the Threshold
    _rope

get_vol_to_bar(_from_bar,_to_bar) =>
    float cum_vol = 0
    for i = (bar_index-_to_bar) to (bar_index-_from_bar)
        cum_vol += volume[i]
    cum_vol

linestyle(_input) =>
    _input == "___"?line.style_solid:
     _input == "- - -"?line.style_dashed:
     _input == ". . ."?line.style_dotted:
     na

///_____________________________________________________________________________________________________________________
///UDTs
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

type pb
    float price
    int bar

type aoi
    box bx
    float top

type tb
    pb top
    pb bot

///_____________________________________________________________________________________________________________________
///Variables
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

var int dir = 0
var int mss_dir = 0

var bool bull_aoi_check = false
var bool bear_aoi_check = false

var pb hst = pb.new(na,na)
var pb lst = pb.new(na,na)

var pb piv_hi = pb.new(na,na)
var pb piv_lo = pb.new(na,na)

var tb ph_aoi = tb.new(pb.new(high,na),pb.new(high,na))
var tb pl_aoi = tb.new(pb.new(low,na),pb.new(low,na))

var bull_aois = array.new<aoi>()
var bear_aois = array.new<aoi>()

var bool piv_lo_claimed = false
var bool piv_hi_claimed = false

fvg_up = (low > high[2]) and (close[1] > high[2]) 
fvg_down = (high < low[2]) and (close[1] < low[2])

c_top = math.max(open,close)
c_bot = math.min(open,close)

///_____________________________________________________________________________________________________________________
///FVG Structure
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

if fvgTog == "All"
    if fvg_down
        box.new(bar_index[2],low[2],bar_index,high, border_color = downCol, bgcolor = downFillCol)
    if fvg_up
        box.new(bar_index[2],high[2],bar_index,low, border_color = upCol, bgcolor = upFillCol)

if dir == 0
    if fvg_up
        dir := 1
        hst := pb.new(high,bar_index)
        lst := pb.new(low,bar_index)
    if fvg_down
        dir := -1
        hst := pb.new(high,bar_index)
        lst := pb.new(low,bar_index)

if dir == 1
    if high >= hst.price
        hst := pb.new(high,bar_index)
        lst := pb.new(low,bar_index)
    if low <= lst.price
        lst := pb.new(low,bar_index)
    if fvg_down
        dir := -1
        piv_hi := hst
        piv_hi_claimed := false
        if (hst.price > (piv_hi[1]).price)
            if (piv_hi.price >= ph_aoi.top.price and bear_aoi_check) or (not bear_aoi_check)
                ph_aoi := tb.new(pb.new(piv_hi.price,piv_hi.bar),pb.new(low[2],bar_index))
                bear_aoi_check := true
        hst := pb.new(high,bar_index)
        lst := lst
        if msTog
            line.new(piv_hi.bar,piv_hi.price,piv_lo.bar,piv_lo.price, color = msColor, style = linestyle(msStyle))
        if fvgTog == "Structural"
            box.new(bar_index[2],low[2],bar_index,high, border_color = downCol, bgcolor = downFillCol)

if dir == -1
    if low <= lst.price
        hst := pb.new(high,bar_index)
        lst := pb.new(low,bar_index)
    if high >= hst.price
        hst := pb.new(high,bar_index)
    if fvg_up
        dir := 1
        piv_lo := lst
        piv_lo_claimed := false
        if (lst.price < (piv_lo[1]).price)
            if (piv_lo.price <= pl_aoi.bot.price and bull_aoi_check) or (not bull_aoi_check)
                pl_aoi := tb.new(pb.new(high[2],bar_index),pb.new(piv_lo.price,piv_lo.bar))
                bull_aoi_check := true
        hst := hst
        lst := pb.new(low,bar_index)
        if msTog
            line.new(piv_hi.bar,piv_hi.price,piv_lo.bar,piv_lo.price, color = msColor, style = linestyle(msStyle))
        if fvgTog == "Structural"
            box.new(bar_index[2],high[2],bar_index,low, border_color = upCol, bgcolor = upFillCol)

///_____________________________________________________________________________________________________________________
///Areas of Interest (AOIs)
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

var r_vals = array.new<pb>(na)

//Market Structure Breaks
break_up = close > piv_hi.price
break_down = close < piv_lo.price

if mss_dir <= 0 and break_up
    mss_dir := 1
if bull_aoi_check and mss_dir == 1 and pl_aoi.bot.price <= lst.price and break_up
    cumvol = get_vol_to_bar(pl_aoi.bot.bar,pl_aoi.top.bar)
    bull_aois.push(aoi.new(box.new(pl_aoi.bot.bar,pl_aoi.top.price,bar_index,pl_aoi.bot.price, border_color = bullColor, bgcolor = bullFillColor, text_color = textColor, text = str.tostring(cumvol, format.volume), text_size = textSize),pl_aoi.top.price))
    r_vals.push(pl_aoi.bot)
    if mssBullTog
        line.new(piv_hi.bar,piv_hi.price,bar_index,piv_hi.price, color = mssBullColor, style = linestyle(mssBullStyle))
    bull_aoi_check := false


if mss_dir >= 0 and break_down
    mss_dir := -1
if bear_aoi_check and mss_dir == -1 and ph_aoi.top.price >= hst.price and break_down
    cumvol = get_vol_to_bar(ph_aoi.top.bar,ph_aoi.bot.bar)
    bear_aois.push(aoi.new(box.new(ph_aoi.top.bar,ph_aoi.top.price,bar_index,ph_aoi.bot.price, border_color = bearColor, bgcolor = bearFillColor, text_color = textColor, text = str.tostring(cumvol, format.volume), text_size = textSize),ph_aoi.top.price))
    r_vals.push(ph_aoi.top)
    if mssBearTog
        line.new(piv_lo.bar,piv_lo.price,bar_index,piv_lo.price, color = mssBearColor, style = linestyle(mssBearStyle))
    bear_aoi_check := false

//Managing Extended Display
if (bull_aois.size() > 0)
    for [i,area] in bull_aois
        if i < (bull_aois.size()-aoiNum)
            area.bx.set_top(na)
        else
            area.bx.set_top(area.top)
            area.bx.set_right(bar_index)
            area.bx.set_text_halign(text.align_right)

if (bear_aois.size() > 0)     
    for [i,area] in bear_aois
        if i < (bear_aois.size()-aoiNum)
            area.bx.set_top(na)
        else
            area.bx.set_top(area.top)
            area.bx.set_right(bar_index)
            area.bx.set_text_halign(text.align_right)

//Managing Mitigation
if (bull_aois.size() > 0)
    last_aoi = bull_aois.last()
    for i = bull_aois.size()-1 to 0
        area = bull_aois.get(i)
        top = area.top
        bot = area.bx.get_bottom()
        not_touching = (bot > last_aoi.top or top < last_aoi.bx.get_bottom())
        overlap = (i != bull_aois.size()-1) and not not_touching
        if overlap
            area.bx.set_right(last_aoi.bx.get_left())
            area.bx.set_text_halign(text.align_center)
            bull_aois.remove(i)
        else if c_bot < bot
            area.bx.set_text_halign(text.align_center)
            bull_aois.remove(i)

if bear_aois.size() > 0
    last_aoi = bear_aois.last()
    for i = bear_aois.size()-1 to 0
        area = bear_aois.get(i)
        top = area.top
        bot = area.bx.get_bottom()
        not_touching = (bot > last_aoi.top or top < last_aoi.bx.get_bottom())
        overlap = (i != bear_aois.size()-1) and not not_touching
        if overlap 
            area.bx.set_right(last_aoi.bx.get_left())
            area.bx.set_text_halign(text.align_center)
            bear_aois.remove(i)
        else if c_top > top
            area.bx.set_text_halign(text.align_center)
            bear_aois.remove(i)

///_____________________________________________________________________________________________________________________
///Reflection Lines
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

var int t_dir = 0

if r_vals.size() > refCount
    r_vals.shift()

mean = rope_smoother(close,ta.atr(14))

if refTog
    var r_lns = array.new_line(na)

    for [i,ln] in r_lns
        ln.delete()
        r_lns.remove(i)

    for [i,val] in r_vals
        col = mean < val.price ? refDownCol : mean > val.price ? refUpCol : color.gray
        r_lns.push(line.new(val.bar,val.price,bar_index+1,val.price, color = col, width = 2))

///_____________________________________________________________________________________________________________________
///Session Lines
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

trade_sesh = na(time(timeframe.period, sesh_in, timezone))

//Start/End Day
if not trade_sesh and trade_sesh[1] and s_tog
    line.new(bar_index,low-0.01, bar_index,high+0.01, extend = extend.both, color = sc, style = linestyle(s_style))
    
if trade_sesh and not trade_sesh[1] and e_tog
    line.new(bar_index,low-0.01, bar_index,high+0.01, extend = extend.both, color = ec, style = linestyle(e_style))
````
