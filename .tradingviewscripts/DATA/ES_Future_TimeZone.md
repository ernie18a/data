<!-- tradingview-pine-id: PUB;cffff4f19c6e41deb395a1ff8282b3c3 -->
<!-- tradingviewscripts-format: 1 -->
# ES Future TimeZone

Source: https://www.tradingview.com/script/3rm3V6fh/

## Description

Description
Take the guesswork out of multi-session index trading. The ES Global Sessions Highlighter is a precision charting tool designed specifically for S&P 500 (ES) and index futures traders to instantly map out the world’s major financial windows on their charts.

Whether you trade the explosive morning opening bell, look for London-to-NY handoff setups, or trade the overnight sessions, this indicator gives you immediate structural context. Stop manually calculating time zones and let your chart tell you who is currently driving the tape.

Key Features:

[*]Asia Session: Highlights the overnight consolidation and range-bound liquidity phase.

[*]London Session: Tracks early European momentum, cross-border flows, and pre-US positioning.

[*]US Regular Trading Hours (RTH): Pinpoints the core New York cash session (9:30 AM – 4:00 PM ET) where peak volume and institutional participation concentrate.

[*]US Post-Market / Settlement: Isolates the late-day auction and wind-down window (4:00 PM – 5:00 PM ET) to help you manage closing imbalances.

[*]Fully Customizable: Tailor colors, opacity, and session boundaries to match your preferred trading desk aesthetic and time zone

---

## Source Code

````pine
//@version=6
indicator("ES Future TimeZone", overlay=true, scale=scale.none)

//param
showAsia   = input.bool(true,  "showAsia", group="PS")
showLondon = input.bool(true,  "showLondon", group="PS")
showUS     = input.bool(true,  "showUS(RTH)", group="PS")
showUSPost = input.bool(true,  "showUSPost", group="PS")

colorAsia   = input.color(color.new(color.blue, 92),    "colorAsia", group="CS")
colorLondon = input.color(color.new(color.orange, 92),  "colorLondon", group="CS")
colorUS     = input.color(color.new(color.green, 92),   "colorUS", group="CS")
colorUSPost = input.color(color.new(color.purple, 92),  "colorUSPost", group="CS")

isDST() =>
    var bool dst = false
    if bar_index == 0 or ta.change(time("D")) != 0

        y = year(time, "America/New_York")
        m = month(time, "America/New_York")
        d = dayofmonth(time, "America/New_York")
        
        int marchDstStart = 14 - (7 + dayofweek(timestamp("America/New_York", y, 3, 1, 0, 0))) % 7
        int novDstEnd = 7 - (7 + dayofweek(timestamp("America/New_York", y, 11, 1, 0, 0))) % 7
        
        if m > 3 and m < 11
            dst := true
        else if m == 3
            dst := d > marchDstStart or (d == marchDstStart and hour(time, "America/New_York") >= 2)
        else if m == 11
            dst := d < novDstEnd or (d == novDstEnd and hour(time, "America/New_York") < 2)
        else
            dst := false
    dst

dstActive = isDST()

//TimeZone
inAsia   = not na(time(timeframe.period, "1800-0200:23456", "America/New_York")) and showAsia
inLondon = not na(time(timeframe.period, "0200-0930:23456", "America/New_York")) and showLondon
inUS     = not na(time(timeframe.period, "0930-1600:23456", "America/New_York")) and showUS
inUSPost = not na(time(timeframe.period, "1600-1700:23456", "America/New_York")) and showUSPost

//bg color
bgcolor(inAsia   ? colorAsia   : na, title="Asiabg")
bgcolor(inLondon ? colorLondon : na, title="Londonbg")
bgcolor(inUS     ? colorUS     : na, title="USbg")
bgcolor(inUSPost ? colorUSPost : na, title="USPostbg")

//desc text
isNewSession(inSess) => inSess and not inSess[1]

if isNewSession(inAsia)
    label.new(bar_index, high, text="(Asia)", color=color.blue, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar)

if isNewSession(inLondon)
    label.new(bar_index, high, text="(London)", color=color.orange, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar)

if isNewSession(inUS)
    label.new(bar_index, high, text="(US RTH)", color=color.green, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar)

if isNewSession(inUSPost)
    label.new(bar_index, high, text="(US Post)", color=color.purple, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar)
````
