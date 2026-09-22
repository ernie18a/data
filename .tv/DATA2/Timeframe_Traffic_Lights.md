<!-- tradingview-pine-id: PUB;65a873daa44548b18af829f5ca831028 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Timeframe Traffic Lights

Source: https://www.tradingview.com/script/A5ckSO4X-Timeframe-Traffic-Lights/

## Description

TIMEFRAME TRAFFIC LIGHTS
See the trend on five timeframes at a glance, in one small box on your chart.

OVERVIEW
Timeframe Traffic Lights shows a row of coloured dots, one for each timeframe you choose. Green means that timeframe is trending up, red means down, and grey means there is no clear trend. When the dots agree, the trend is strong across the board. When they disagree, the market is mixed.

It draws nothing else on your chart, so it stays out of the way of your candles and your other indicators. It works on any chart timeframe, because each light looks at its own timeframe separately. It is a visual tool only. It does not give buy or sell signals and it does not place trades.

HOW EACH LIGHT DECIDES ITS COLOUR
Each light uses two average-price lines (moving averages): a fast one that follows the last 20 candles and a slow one that follows the last 50. On each timeframe the script checks how price and those two lines are lined up:

[*] Green: price is above the fast line, and the fast line is above the slow line. The trend is up.
[*] Red: price is below the fast line, and the fast line is below the slow line. The trend is down.
[*] Grey: anything in between. There is no clear trend.

This is deliberately simple and easy to understand. You can change the 20 and 50 in the settings.

THE DEFAULT TIMEFRAMES
15m, 30m, 1h, 4h and 1D. You can change any of the five in the settings.

WHAT YOU SEE IN THE BOX
Row 1: timeframe names
The short name of each timeframe (15m, 30m, 1h, 4h, 1D).

Row 2: the dots
One dot per timeframe in green, red or grey.

Strength shading
A bright, solid dot means the trend is strong. A faded dot means the trend is there but weak or young. Grey dots are never faded, since there is no trend to measure. Strength is worked out by comparing the gap between the two average lines with the typical size of a candle on that timeframe (the average candle range over the last 14 candles). Using candle size keeps it fair across timeframes, so the same setting works on the 15m and on the daily. Fading only changes how a dot looks. A faded green dot still counts as green.

Recently-flipped marker (✦)
A small ✦ appears under any light that changed colour within the last 3 candles of its own timeframe. On the daily that means the last 3 days, and on the 15m it means the last 45 minutes. The ✦ takes the colour the light changed to. It sits in its own row that shows a blank space when nothing has flipped, so the box doesn't jump in height.

Candle countdown
The time left until each timeframe's current candle closes, shown as hours and minutes like 03:05. It uses a fixed format so the box doesn't change width as the numbers change. For timeframes of a day or more it shows days and hours, like 2d05h. The text is soft grey normally, and turns amber when less than 10% of that candle is left. That's the moment a dot is most likely to change.

Overall reading
One line under the dots that sums up all five:
- ▲ 4 of 5 UP (green)
- ▼ 3 of 5 DOWN (red)
- MIXED (grey)
A direction is only called when enough lights agree (3 out of 5 by default). Anything short of that reads as MIXED, and so does a tie between green and red.

Colour key (optional)
A row at the bottom explaining the colours: Up, Down, Mix and ✦ New. It's off by default to keep the box small.

ALERTS
You get an alert at the moment all five lights turn green ("all timeframes UP") or all five turn red ("all timeframes DOWN"). It fires once when they line up, not on every candle while they stay lined up.

To set it up: click Create Alert, choose Timeframe Traffic Lights as the condition, then select "Any alert() function call".

SETTINGS
Timeframes

[*] Timeframe 1 to 5: which timeframes get a light

Trend

[*] Fast average length (default 20)
[*] Slow average length (default 50)
[*] Lights needed to call a direction (default 3 out of 5). Set it to 4 or 5 for a stricter overall reading, or 1 to react to any single light that beats the other side

Extras (each can be switched on or off)

[*] Fade the dot when the trend is weak
[*] Trend counts as strong at this gap (default 1.0). A lower number makes more dots bright, and a higher number makes fewer
[*] Mark lights that just changed colour (✦), and how many candles count as "just changed" (default 3)
[*] Show candle countdown
[*] Update lights only when a candle closes
[*] Show colour key
[*] Alert when all 5 lights agree

Look

[*] Box position: top left, top right, bottom left or bottom right (default bottom right)
[*] Text size: Tiny, Small, Normal or Large (default Small)

UPDATE ONLY WHEN A CANDLE CLOSES
By default the lights are live, so a dot can flip while that timeframe's candle is still forming. With "Update lights only when a candle closes" turned on, each light shows the reading from that timeframe's last finished candle. The dots stop flipping mid-candle, which means fewer false flips. The trade-off is that they react later, by up to one candle of that timeframe. The ✦ markers and the all-lights alert follow the same delay.

HOW TO READ IT

[*] All dots the same colour: every timeframe agrees, so the trend is strong across the board
[*] Mixed colours: the timeframes disagree. A short-term move may be going against the bigger picture
[*] Bright dots: the trend is well established
[*] Faded dots: the trend is weak or has only just started
[*] A fresh ✦ on a fast timeframe while the slow ones haven't moved: an early hint that something may be turning, and worth watching
[*] An amber countdown: that candle is about to close, so a dot may change soon
[*] Big timeframes (4h, 1D) usually move slowly, so a change there tends to matter more than a change on the 15m

HOW TO USE
1. Add the indicator and open its settings.
2. Choose the five timeframes you care about.
3. Set the box position and text size. Tiny works best on a phone.
4. If the box is too tall, turn off the ✦ marker or the countdown.
5. Create an alert if you want to be told when all five lights agree.

Tips

[*] Turn on "Update lights only when a candle closes" if you find the dots flip too often
[*] Turn on the colour key for a few days while you learn the symbols, then switch it off
[*] On a phone, use the Tiny text size and keep the extras you actually look at

GOOD TO KNOW

[*] Moving averages follow price, so the lights describe what has been happening, not what will happen. A green light does not mean price will keep rising
[*] In live mode, a dot (and the all-lights alert) can change while a candle is still forming, and can change back before it closes. Use the candle-close option if that bothers you
[*] Each timeframe needs about 50 candles of history loaded for its slow line to settle. On very short histories the first readings may look odd
[*] The strength setting is a starting point. The default of 1.0 is a guess that suits many markets, so adjust it until the bright and faded dots look right for your symbol
[*] The daily candle countdown follows your data feed's own day. For most Bitcoin feeds that is midnight UTC, not midnight in your local time
[*] On a market that is closed, the countdown may look odd or show --:--
[*] The number of lights is fixed at five. You can change which timeframes they use, but not how many there are
[*] The countdown updates whenever new price data arrives, so on a quiet chart it can lag by a few seconds

DISCLAIMER
This script is a visualisation tool for educational and informational purposes only. It is not financial advice and does not guarantee any results. Trading carries risk, so always manage your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © asg1994

//@version=6
indicator("Timeframe Traffic Lights", overlay = true)

// ── Settings ──────────────────────────────────────────
tf1           = input.timeframe("15",  "Timeframe 1")
tf2           = input.timeframe("30",  "Timeframe 2")
tf3           = input.timeframe("60",  "Timeframe 3")
tf4           = input.timeframe("240", "Timeframe 4")
tf5           = input.timeframe("D",   "Timeframe 5")
fastLen       = input.int(20, "Fast average length (candles)", minval = 2)
slowLen       = input.int(50, "Slow average length (candles)", minval = 3)
minAgree      = input.int(3, "Lights needed to call a direction (out of 5)", minval = 1, maxval = 5)
showStrength  = input.bool(true, "Fade the dot when the trend is weak")
strongGap     = input.float(1.0, "Trend counts as strong at this gap (in typical candle sizes)", minval = 0.1, step = 0.1)
showFlip      = input.bool(true, "Mark lights that just changed colour")
flipWithin    = input.int(3, "'Just changed' means within the last (candles)", minval = 1, maxval = 20)
showCount     = input.bool(true, "Show candle countdown (time until each candle closes)")
confirmedOnly = input.bool(false, "Update lights only when a candle closes")
showKey       = input.bool(false, "Show colour key")
alertOn       = input.bool(true, "Alert when all 5 lights agree")
posIn         = input.string("Bottom right", "Box position", options = ["Top left", "Top right", "Bottom left", "Bottom right"])
sizeIn        = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"])

numTf   = 5
tblPos  = posIn == "Top left" ? position.top_left : posIn == "Top right" ? position.top_right : posIn == "Bottom left" ? position.bottom_left : position.bottom_right
tblSize = sizeIn == "Tiny" ? size.tiny : sizeIn == "Small" ? size.small : sizeIn == "Normal" ? size.normal : size.large
lookMode = confirmedOnly ? barmerge.lookahead_on : barmerge.lookahead_off

// ── Working out the trend on one timeframe ────────────
// Sends back three things:
//   1) the trend: 1 = up (green), -1 = down (red), 0 = mixed (grey)
//   2) the strength: gap between the two average lines, in typical candle sizes
//   3) the age: how many candles ago the trend last changed
// If "candle closes" mode is on, all three come from the previous (finished) candle.
f_pack() =>
    float fast = ta.ema(close, fastLen)
    float slow = ta.ema(close, slowLen)
    float atr  = ta.atr(14)
    int   st   = close > fast and fast > slow ? 1 : close < fast and fast < slow ? -1 : 0
    float gap  = atr > 0 ? math.abs(fast - slow) / atr : 0.0
    int   age  = nz(ta.barssince(st != st[1]), 999)
    [confirmedOnly ? st[1] : st, confirmedOnly ? gap[1] : gap, confirmedOnly ? age[1] : age]

// Ask each timeframe for its own reading
[s1, g1, a1] = request.security(syminfo.tickerid, tf1, f_pack(), lookahead = lookMode)
[s2, g2, a2] = request.security(syminfo.tickerid, tf2, f_pack(), lookahead = lookMode)
[s3, g3, a3] = request.security(syminfo.tickerid, tf3, f_pack(), lookahead = lookMode)
[s4, g4, a4] = request.security(syminfo.tickerid, tf4, f_pack(), lookahead = lookMode)
[s5, g5, a5] = request.security(syminfo.tickerid, tf5, f_pack(), lookahead = lookMode)

// NEW: ask each timeframe when its current candle will close
int c1 = request.security(syminfo.tickerid, tf1, time_close, lookahead = barmerge.lookahead_on)
int c2 = request.security(syminfo.tickerid, tf2, time_close, lookahead = barmerge.lookahead_on)
int c3 = request.security(syminfo.tickerid, tf3, time_close, lookahead = barmerge.lookahead_on)
int c4 = request.security(syminfo.tickerid, tf4, time_close, lookahead = barmerge.lookahead_on)
int c5 = request.security(syminfo.tickerid, tf5, time_close, lookahead = barmerge.lookahead_on)

// ── Counting the lights ───────────────────────────────
int ups   = (s1 == 1 ? 1 : 0) + (s2 == 1 ? 1 : 0) + (s3 == 1 ? 1 : 0) + (s4 == 1 ? 1 : 0) + (s5 == 1 ? 1 : 0)
int downs = (s1 == -1 ? 1 : 0) + (s2 == -1 ? 1 : 0) + (s3 == -1 ? 1 : 0) + (s4 == -1 ? 1 : 0) + (s5 == -1 ? 1 : 0)

bool allUp   = ups == numTf
bool allDown = downs == numTf

// ── Alerts (only at the moment all lights line up) ────
if alertOn and allUp and not allUp[1]
    alert(syminfo.ticker + ": all timeframes UP", alert.freq_once_per_bar)
if alertOn and allDown and not allDown[1]
    alert(syminfo.ticker + ": all timeframes DOWN", alert.freq_once_per_bar)

// ── Helpers ───────────────────────────────────────────
// Turns a timeframe into a short name, e.g. "60" becomes "1h" and "D" becomes "1D"
f_tfLabel(string tf) =>
    int s = timeframe.in_seconds(tf)
    s < 60      ? str.tostring(s) + "s" :
     s < 3600    ? str.tostring(int(s / 60)) + "m" :
     s < 86400   ? str.tostring(int(s / 3600)) + "h" :
     s < 604800  ? str.tostring(int(s / 86400)) + "D" :
     s < 2592000 ? str.tostring(int(s / 604800)) + "W" :
     str.tostring(int(s / 2592000)) + "M"

// The plain colour for a trend (green / red / grey)
f_baseColor(int s) =>
    s == 1 ? #00e676 : s == -1 ? #ff5252 : #9e9e9e

// The dot colour, faded when the trend is weak (grey dots are never faded)
f_dotColor(int s, float gap) =>
    color c = f_baseColor(s)
    showStrength and s != 0 and gap < strongGap ? color.new(c, 65) : c

// NEW: turns milliseconds into a fixed-width countdown: "03:05" (hours:minutes), or "2d05h" if a day or more
f_countdown(int ms) =>
    int totalMin = int(math.max(0, ms) / 60000)
    totalMin >= 1440 ? str.tostring(int(totalMin / 1440)) + "d" + str.tostring(int((totalMin % 1440) / 60), "00") + "h" : str.tostring(int(totalMin / 60), "00") + ":" + str.tostring(totalMin % 60, "00")

// ── The lights box ────────────────────────────────────
// Row 0 = timeframe names | row 1 = dots | then (each optional): just-flipped marker, candle countdown
// then the overall reading, then the colour key (optional)
int flipRow    = 2
int countRow   = showFlip ? 3 : 2
int overallRow = 2 + (showFlip ? 1 : 0) + (showCount ? 1 : 0)
int keyRow     = overallRow + 1
int totalRows  = keyRow + (showKey ? 1 : 0)

var table lights = table.new(tblPos, numTf, totalRows, border_width = 1)

if barstate.isfirst
    // Make the overall row span all five columns
    table.cell(lights, 0, overallRow, "")
    table.merge_cells(lights, 0, overallRow, numTf - 1, overallRow)

if barstate.islast
    array<int>    states = array.from(s1, s2, s3, s4, s5)
    array<float>  gaps   = array.from(g1, g2, g3, g4, g5)
    array<int>    ages   = array.from(a1, a2, a3, a4, a5)
    array<int>    closes = array.from(c1, c2, c3, c4, c5)
    array<string> tfs    = array.from(tf1, tf2, tf3, tf4, tf5)
    array<string> names  = array.from(f_tfLabel(tf1), f_tfLabel(tf2), f_tfLabel(tf3), f_tfLabel(tf4), f_tfLabel(tf5))

    for i = 0 to numTf - 1
        table.cell(lights, i, 0, names.get(i), text_color = color.white, text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(color.black, 20))
        table.cell(lights, i, 1, "●", text_color = f_dotColor(states.get(i), gaps.get(i)), text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(color.black, 20))

        // A ✦ under any light that changed colour within the last few candles
        if showFlip
            bool fresh = ages.get(i) < flipWithin
            table.cell(lights, i, flipRow, fresh ? "✦" : " ", text_color = f_baseColor(states.get(i)), text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(color.black, 20))

        // NEW: countdown to the close of each timeframe's candle.
        // Grey normally, amber when less than 10% of the candle is left.
        if showCount
            int    closeAt  = closes.get(i)
            int    remainMs = na(closeAt) ? 0 : closeAt - timenow
            int    candleMs = timeframe.in_seconds(tfs.get(i)) * 1000
            bool   soon     = not na(closeAt) and remainMs < candleMs * 0.10
            string cdText   = na(closeAt) ? "--:--" : f_countdown(remainMs)
            table.cell(lights, i, countRow, cdText, text_color = soon ? #ffb300 : #b0b0b0, text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(color.black, 20))

    // A direction is only called when enough lights agree (set by "Lights needed").
    // Anything short of that reads as mixed.
    bool   callUp    = ups >= minAgree and ups > downs
    bool   callDown  = downs >= minAgree and downs > ups
    string readText  = callUp ? "▲ " + str.tostring(ups) + " of " + str.tostring(numTf) + " UP" : callDown ? "▼ " + str.tostring(downs) + " of " + str.tostring(numTf) + " DOWN" : "MIXED"
    color  readColor = callUp ? #00e676 : callDown ? #ff5252 : #9e9e9e

    table.cell(lights, 0, overallRow, readText, text_color = readColor, text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(readColor, 80))

    // Optional colour key
    if showKey
        table.cell(lights, 0, keyRow, "Key",    text_color = color.white, text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(color.black, 20))
        table.cell(lights, 1, keyRow, "● Up",   text_color = #00e676,     text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(color.black, 20))
        table.cell(lights, 2, keyRow, "● Down", text_color = #ff5252,     text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(color.black, 20))
        table.cell(lights, 3, keyRow, "● Mix",  text_color = #9e9e9e,     text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(color.black, 20))
        table.cell(lights, 4, keyRow, showFlip ? "✦ New" : "", text_color = color.white, text_size = tblSize, text_halign = text.align_center, bgcolor = color.new(color.black, 20))
````
