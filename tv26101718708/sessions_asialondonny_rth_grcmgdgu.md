# Sessions (Asia,London,NY RTH)

- url: https://www.tradingview.com/script/grcMgdGu-Sessions-Asia-London-NY-RTH/
- type: indicator
- pine_id: PUB;d3eefcfade404d299f24498f120d4379
- version: 1.0

## Description

Marks the three main trading sessions on any intraday chart — Asia, London and New York Regular Trading Hours — with a background shade and a high/low range box for each session.

WHAT IT SHOWS
• Background shading for each session
• A box from each session's high to its low, growing live as the session runs
• Session name and range (high − low, in points) printed inside the box
• Optional 50% midline of each session's range

DEFAULT SESSIONS (New York time)
• Asia: 18:00 – 03:00 (from the CME Globex reopen)
• London: 03:00 – 09:30
• NY RTH: 09:30 – 16:00

All times can be changed. Sessions that cross midnight are supported.

TIMEZONE
Session times are read in the timezone you choose (default America/New_York). It adjusts for daylight saving automatically, so the boxes stay on the correct bars whatever timezone your chart uses. Also available: America/Chicago, Europe/London, Asia/Tokyo, Asia/Kolkata and UTC.

FULLY CUSTOMISABLE COLOURS
Each session has three colour settings, each with its own opacity slider:
• Background — the session shade
• Box fill — the inside of the high/low box
• Border / text — the box outline, label and midline
The defaults are light tints so price stays readable. Set any opacity to 0% to hide that part, for example to show box outlines only.

SETTINGS
• Turn each session on or off
• Turn background shading, boxes, labels and the midline on or off
• Edit session times and colours

USAGE IDEAS
• See the Asia and London highs and lows going into the NY open
• Spot range expansion or compression from one session to the next
• Frame the opening-range and liquidity-sweep setups around session extremes

NOTES
• Works on intraday timeframes only; nothing is drawn on Daily and above
• TradingView's own extended-hours background may overlap the shading. You can turn it off in Chart Settings → Symbol
• For ICT-style "kill zones", change the times to Asia 20:00–00:00 and London 02:00–05:00

This indicator is for visual and educational use only and is not financial advice.

## Source Code

````pine
//@version=6
indicator("Sessions — Asia / London / NY RTH", shorttitle="Sessions", overlay=true, max_boxes_count=500, max_lines_count=500)

// ───────── General ─────────
tz       = input.string("America/New_York", "Session timezone",
     options=["America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo", "Asia/Kolkata", "UTC"],
     tooltip="Session times are read in this zone. America/New_York auto-adjusts for US daylight saving.")
showBg   = input.bool(true,  "Shade background")
showBox  = input.bool(true,  "High / Low box")
showText = input.bool(true,  "Name + range inside box")
showMid  = input.bool(false, "50% midline")

// ───────── Asia ─────────
G_A    = "Asia"
aOn    = input.bool(true,           "Show",  inline="a0", group=G_A)
aSess  = input.session("1800-0300", "",      inline="a0", group=G_A)
aBg    = input.color(color.new(#7E57C2, 92), "Background", inline="a1", group=G_A)
aFill  = input.color(color.new(#7E57C2, 94), "Box fill",   inline="a1", group=G_A)
aLine  = input.color(color.new(#7E57C2, 40), "Border / text", inline="a1", group=G_A)

// ───────── London ─────────
G_L    = "London"
lOn    = input.bool(true,           "Show",  inline="l0", group=G_L)
lSess  = input.session("0300-0930", "",      inline="l0", group=G_L)
lBg    = input.color(color.new(#2962FF, 92), "Background", inline="l1", group=G_L)
lFill  = input.color(color.new(#2962FF, 94), "Box fill",   inline="l1", group=G_L)
lLine  = input.color(color.new(#2962FF, 40), "Border / text", inline="l1", group=G_L)

// ───────── NY RTH ─────────
G_N    = "NY RTH"
nOn    = input.bool(true,           "Show",  inline="n0", group=G_N)
nSess  = input.session("0930-1600", "",      inline="n0", group=G_N)
nBg    = input.color(color.new(#FF9800, 92), "Background", inline="n1", group=G_N)
nFill  = input.color(color.new(#FF9800, 94), "Box fill",   inline="n1", group=G_N)
nLine  = input.color(color.new(#FF9800, 40), "Border / text", inline="n1", group=G_N)

// ───────── Engine ─────────
drawSession(bool on, string sess, string name, color fillCol, color lineCol) =>
    bool inS = on and timeframe.isintraday and not na(time(timeframe.period, sess, tz))
    var box   bx = na
    var line  md = na
    var float hi = na
    var float lo = na

    if inS and not inS[1]                         // session opened
        hi := high
        lo := low
        bx := showBox ? box.new(bar_index, hi, bar_index, lo,
             border_color=lineCol, bgcolor=fillCol, border_width=1,
             text_size=size.small, text_color=lineCol,
             text_halign=text.align_left, text_valign=text.align_top) : na
        md := showMid ? line.new(bar_index, (hi + lo) / 2, bar_index, (hi + lo) / 2,
             color=lineCol, style=line.style_dashed) : na
    else if inS                                    // session running
        hi := math.max(hi, high)
        lo := math.min(lo, low)

    if inS
        if not na(bx)
            box.set_right(bx, bar_index)
            box.set_top(bx, hi)
            box.set_bottom(bx, lo)
            if showText
                box.set_text(bx, name + "  " + str.tostring(hi - lo, format.mintick))
        if not na(md)
            float m = (hi + lo) / 2
            line.set_xy1(md, line.get_x1(md), m)
            line.set_xy2(md, bar_index, m)
    inS

inAsia   = drawSession(aOn, aSess, "Asia",   aFill, aLine)
inLondon = drawSession(lOn, lSess, "London", lFill, lLine)
inNY     = drawSession(nOn, nSess, "NY RTH", nFill, nLine)

bgcolor(showBg and inAsia   ? aBg : na, title="Asia bg")
bgcolor(showBg and inLondon ? lBg : na, title="London bg")
bgcolor(showBg and inNY     ? nBg : na, title="NY RTH bg")
````
