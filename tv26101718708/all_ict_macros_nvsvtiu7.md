# ALL ICT Macros

- url: https://www.tradingview.com/script/NvSVTIu7-ALL-ICT-Macros/
- type: indicator
- pine_id: PUB;c53a3db998a344f4b8f929d92d50b7e8
- version: 1.0

## Description

Automatically highlights the ICT Macro window (XX:45 to XX:15) for every hour of the trading day. Useful for identifying liquidity runs, reversals, and algorithmic delivery zones during macro periods. Works across all sessions and timeframes.

## Source Code

````pine
//@version=6
indicator("Macros", overlay=true, max_boxes_count=500, max_labels_count=500)

// ================= TIMEZONE =================
groupTZ = "Timezone"
tzInput = input.string("EST", "Timezone", options=["EST", "CST", "MST", "PST", "GMT", "UTC"], group=groupTZ)
use12hr = input.bool(true, "Standard Time (12hr)", group=groupTZ)

tzString = switch tzInput
    "EST" => "America/New_York"
    "CST" => "America/Chicago"
    "MST" => "America/Denver"
    "PST" => "America/Los_Angeles"
    "GMT" => "Europe/London"
    "UTC" => "UTC"
    => "America/New_York"

// ================= COLOR CONTROL =================
groupColor = "Color Control"
useMasterColor = input.bool(false, "Use Master Color For All", group=groupColor)
masterColor = input.color(color.new(color.gray, 80), "Master Fill Color", group=groupColor)

w1Color  = input.color(color.new(color.gray, 80), "2:45 - 3:15 Color", group=groupColor)
w2Color  = input.color(color.new(color.gray, 80), "3:45 - 4:15 Color", group=groupColor)
w3Color  = input.color(color.new(color.gray, 80), "4:45 - 5:15 Color", group=groupColor)
w4Color  = input.color(color.new(color.gray, 80), "5:45 - 6:15 Color", group=groupColor)
w5Color  = input.color(color.new(color.gray, 80), "6:45 - 7:15 Color", group=groupColor)
w6Color  = input.color(color.new(color.gray, 80), "7:45 - 8:15 Color", group=groupColor)
w7Color  = input.color(color.new(color.gray, 80), "8:45 - 9:15 Color", group=groupColor)
w8Color  = input.color(color.new(color.gray, 80), "9:45 - 10:15 Color", group=groupColor)
w9Color  = input.color(color.new(color.gray, 80), "10:45 - 11:15 Color", group=groupColor)
w12Color = input.color(color.new(color.gray, 80), "11:45 - 12:15 Color", group=groupColor)
w10Color = input.color(color.new(color.gray, 80), "12:45 - 13:15 Color", group=groupColor)
w11Color = input.color(color.new(color.gray, 80), "13:45 - 14:15 Color", group=groupColor)
w13Color = input.color(color.new(color.gray, 80), "14:45 - 15:15 Color", group=groupColor)
w14Color = input.color(color.new(color.gray, 80), "18:45 - 19:15 Color", group=groupColor)
w15Color = input.color(color.new(color.gray, 80), "19:45 - 20:15 Color", group=groupColor)
w16Color = input.color(color.new(color.gray, 80), "20:45 - 21:15 Color", group=groupColor)
w17Color = input.color(color.new(color.gray, 80), "21:45 - 22:15 Color", group=groupColor)
w18Color = input.color(color.new(color.gray, 80), "22:45 - 23:15 Color", group=groupColor)
w19Color = input.color(color.new(color.gray, 80), "23:45 - 0:15 Color",  group=groupColor)
w20Color = input.color(color.new(color.gray, 80), "0:45 - 1:15 Color",   group=groupColor)
w21Color = input.color(color.new(color.gray, 80), "1:45 - 2:15 Color",   group=groupColor)

// ================= TOGGLES =================
groupToggle = "Window Toggles"
w1_on  = input.bool(true, "Enable 2:45 - 3:15", group=groupToggle)
w2_on  = input.bool(true, "Enable 3:45 - 4:15", group=groupToggle)
w3_on  = input.bool(true, "Enable 4:45 - 5:15", group=groupToggle)
w4_on  = input.bool(true, "Enable 5:45 - 6:15", group=groupToggle)
w5_on  = input.bool(true, "Enable 6:45 - 7:15", group=groupToggle)
w6_on  = input.bool(true, "Enable 7:45 - 8:15", group=groupToggle)
w7_on  = input.bool(true, "Enable 8:45 - 9:15", group=groupToggle)
w8_on  = input.bool(true, "Enable 9:45 - 10:15", group=groupToggle)
w9_on  = input.bool(true, "Enable 10:45 - 11:15", group=groupToggle)
w12_on = input.bool(true, "Enable 11:45 - 12:15", group=groupToggle)
w10_on = input.bool(true, "Enable 12:45 - 13:15", group=groupToggle)
w11_on = input.bool(true, "Enable 13:45 - 14:15", group=groupToggle)
w13_on = input.bool(true, "Enable 14:45 - 15:15", group=groupToggle)
w14_on = input.bool(true, "Enable 18:45 - 19:15", group=groupToggle)
w15_on = input.bool(true, "Enable 19:45 - 20:15", group=groupToggle)
w16_on = input.bool(true, "Enable 20:45 - 21:15", group=groupToggle)
w17_on = input.bool(true, "Enable 21:45 - 22:15", group=groupToggle)
w18_on = input.bool(true, "Enable 22:45 - 23:15", group=groupToggle)
w19_on = input.bool(true, "Enable 23:45 - 0:15",  group=groupToggle)
w20_on = input.bool(true, "Enable 0:45 - 1:15",   group=groupToggle)
w21_on = input.bool(true, "Enable 1:45 - 2:15",   group=groupToggle)

// ================= BORDER SETTINGS =================
groupBorder = "Border Settings"
borderWidth = input.int(1, "Border Width", minval=1, maxval=10, group=groupBorder)
borderColor = input.color(color.black, "Border Color", group=groupBorder)
borderStyleInput = input.string("Dotted", "Border Style", options=["Solid","Dashed","Dotted"], group=groupBorder)

borderStyle = line.style_solid
if borderStyleInput == "Dashed"
    borderStyle := line.style_dashed
else if borderStyleInput == "Dotted"
    borderStyle := line.style_dotted

// ================= TEXT SETTINGS =================
groupText = "Text Settings"
textColor = input.color(color.black, "Text Color", group=groupText)
textSizeInput = input.string("Small", "Text Size", options=["Tiny","Small","Normal","Large"], group=groupText)

textSize = size.small
if textSizeInput == "Tiny"
    textSize := size.tiny
else if textSizeInput == "Normal"
    textSize := size.normal
else if textSizeInput == "Large"
    textSize := size.large

// ================= TIME FORMAT =================
to12hr(h, m) =>
    hNum = str.tonumber(h)
    suffix = hNum >= 12 ? "pm" : "am"
    h12 = hNum == 0 ? 12 : hNum > 12 ? hNum - 12 : hNum
    str.tostring(h12) + ":" + m + suffix

formatTime(sess) =>
    sh = str.substring(sess, 0, 2)
    sm = str.substring(sess, 2, 4)
    eh = str.substring(sess, 5, 7)
    em = str.substring(sess, 7, 9)
    if use12hr
        to12hr(sh, sm) + " - " + to12hr(eh, em)
    else
        str.tostring(str.tonumber(sh)) + ":" + sm + " - " + str.tostring(str.tonumber(eh)) + ":" + em

// ================= DRAW FUNCTION =================
drawWindow(enabled, sess, customColor) =>
    if enabled
        inSess = not na(time(timeframe.period, sess, tzString))
        fillColor = useMasterColor ? masterColor : customColor

        var float hi = na
        var float lo = na
        var int leftBar = na
        var int rightBar = na
        var box b = na

        if inSess and not inSess[1]
            hi := high
            lo := low
            leftBar := bar_index
            b := box.new(bar_index, high, bar_index, low, bgcolor=fillColor)
            box.set_border_color(b, borderColor)
            box.set_border_width(b, borderWidth)
            box.set_border_style(b, borderStyle)

        if inSess
            hi := math.max(hi, high)
            lo := math.min(lo, low)
            rightBar := bar_index
            box.set_top(b, hi)
            box.set_bottom(b, lo)
            box.set_right(b, rightBar)

        if not inSess and inSess[1]
            midBar = math.floor((leftBar + rightBar) / 2)
            offset = syminfo.mintick * 40
            label.new(midBar, lo - offset, formatTime(sess), style=label.style_none, textcolor=textColor, size=textSize)

// ================= WINDOWS =================
drawWindow(w1_on,  "0245-0315", w1Color)
drawWindow(w2_on,  "0345-0415", w2Color)
drawWindow(w3_on,  "0445-0515", w3Color)
drawWindow(w4_on,  "0545-0615", w4Color)
drawWindow(w5_on,  "0645-0715", w5Color)
drawWindow(w6_on,  "0745-0815", w6Color)
drawWindow(w7_on,  "0845-0915", w7Color)
drawWindow(w8_on,  "0945-1015", w8Color)
drawWindow(w9_on,  "1045-1115", w9Color)
drawWindow(w12_on, "1145-1215", w12Color)
drawWindow(w10_on, "1245-1315", w10Color)
drawWindow(w11_on, "1345-1415", w11Color)
drawWindow(w13_on, "1445-1515", w13Color)
drawWindow(w14_on, "1845-1915", w14Color)
drawWindow(w15_on, "1945-2015", w15Color)
drawWindow(w16_on, "2045-2115", w16Color)
drawWindow(w17_on, "2145-2215", w17Color)
drawWindow(w18_on, "2245-2315", w18Color)
drawWindow(w19_on, "2345-0015", w19Color)
drawWindow(w20_on, "0045-0115", w20Color)
drawWindow(w21_on, "0145-0215", w21Color)
````
