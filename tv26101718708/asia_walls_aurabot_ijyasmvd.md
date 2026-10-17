# Asia Walls [Aurabot]

- url: https://www.tradingview.com/script/IjYaSmvD-Asia-Walls-Aurabot/
- type: indicator
- pine_id: PUB;689ef836537f4202a1a53a6586536b45
- version: 2.0

## Description

Asia Walls turns the Asian session into a floor and a ceiling for the New York session.

WHAT IT SHOWS
- Ceiling: the Asian session high (18:00 to 03:00 New York time)
- Floor: the Asian session low
- Zones: shaded bands above the ceiling and below the floor, sized by ATR (14) so they scale with volatility
- Midpoint: optional line halfway between the walls
- Focus window: a highlighted time window you choose (default 9:40 to 10:30 New York)
- Status badge: shows if price is above the ceiling, below the floor, or inside the Asian range

HOW IT WORKS
The script tracks the high and low of the Asian session bar by bar. When the session closes, it locks them in as the walls and carries them into the day until your cut-off time (default 16:00). Nothing is drawn from future bars, so the walls never move once they appear.

HOW TO USE IT
Inside the walls, price is still in the overnight range. Above the ceiling or below the floor, price has left it. Some traders look for a failed push and a move back inside, others look for acceptance and continuation. The script does not pick for you. It shows where price is so you can apply your own read.

ALERTS
- Price over the ceiling
- Price under the floor

SETTINGS
Session times, how long the walls stay on the chart, zone depth, midpoint, focus window, status badge, wall width and zone fade.

THEMES
One dropdown changes the whole look: Aurabot (default), Neon Cyber, Midnight Aura, Sunset Blaze, Ocean Depth, Ghost Protocol, Classic, Neon Violet, Plasma, Blade Runner, Toxic, Ghost Wire, Midnight Blue, Ember Gold, Stealth Dark, Clean Light (for white charts), or Custom with your own colors.

NOTES
This is a map, not a signal. It does not tell you to buy or sell. Built for intraday charts (1 to 15 minutes). All times are New York time. How price reacted to these levels in the past does not guarantee how it will react in the future.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AuraSznfx
// Aurabot Asia Walls
// Draws the Asian session range (18:00 to 03:00 New York) as a floor and a ceiling for the day, shades the zones
// beyond them, and highlights a New York time window you choose. A map, not a signal.
//@version=6
indicator("Aurabot Asia Walls", "Asia Walls", overlay = true, max_labels_count = 200)

tz = "America/New_York"
gA = "Asian session"
aStart = input.int(1800, "Starts (HHMM, New York)", group = gA)
aEnd   = input.int(300, "Ends (HHMM, New York)", group = gA)
showAsia = input.bool(true, "Shade the Asian session", group = gA)
gW = "Walls"
wallEnd = input.int(1600, "Draw walls until (HHMM, New York)", group = gW)
zoneATR = input.float(1.5, "Zone depth beyond each wall (x ATR)", minval = 0, step = 0.25, group = gW)
showMid = input.bool(true, "Show the midpoint", group = gW)
showTags = input.bool(true, "Tag the walls (ASIA HIGH / ASIA LOW)", group = gW)
gT = "Focus window"
fStart = input.int(940, "Window starts (HHMM, New York)", group = gT)
fEnd   = input.int(1030, "Window ends (HHMM, New York)", group = gT)
showBadge = input.bool(true, "Status badge", group = gT)
gC = "◈ Theme"
themeChoice = input.string("Aurabot", "◈ Color Theme", group = gC, options = ["Aurabot", "Neon Cyber", "Midnight Aura", "Sunset Blaze", "Ocean Depth", "Ghost Protocol", "Classic", "Neon Violet", "Plasma", "Blade Runner", "Toxic", "Ghost Wire", "Midnight Blue", "Ember Gold", "Stealth Dark", "Clean Light", "Custom"], tooltip = "Sets the whole colour palette at once.")
cuHigh    = input.color(#FF427E, "↳ Custom Ceiling", group = gC)
cuLow     = input.color(#00D9FF, "↳ Custom Floor", group = gC)
cuAccent  = input.color(#FACC15, "↳ Custom Focus Window", group = gC)
cuNeutral = input.color(#8A8AA0, "↳ Custom Neutral", group = gC)
lineW     = input.int(3, "◈ Wall Width", minval = 1, maxval = 4, group = gC)
zoneFade  = input.int(86, "◈ Zone Fade", minval = 50, maxval = 98, group = gC)

cCeil = switch themeChoice
    "Aurabot"         => #FF427E
    "Neon Cyber"      => #FF1744
    "Midnight Aura"   => #F472B6
    "Sunset Blaze"    => #EF4444
    "Ocean Depth"     => #F97316
    "Ghost Protocol"  => #52525B
    "Classic"         => #F23645
    "Neon Violet"     => #FF4081
    "Plasma"          => #FF006E
    "Blade Runner"    => #448AFF
    "Toxic"           => #D500F9
    "Ghost Wire"      => #FF8A80
    "Midnight Blue"   => #FF6B6B
    "Ember Gold"      => #FF6E40
    "Stealth Dark"    => #EF9A9A
    "Clean Light"     => #C62828
    => cuHigh

cFloor = switch themeChoice
    "Aurabot"         => #00D9FF
    "Neon Cyber"      => #00E676
    "Midnight Aura"   => #6366F1
    "Sunset Blaze"    => #FBBF24
    "Ocean Depth"     => #22D3EE
    "Ghost Protocol"  => #A1A1AA
    "Classic"         => #089981
    "Neon Violet"     => #B388FF
    "Plasma"          => #00FFF5
    "Blade Runner"    => #FFAB40
    "Toxic"           => #76FF03
    "Ghost Wire"      => #84FFFF
    "Midnight Blue"   => #00B0FF
    "Ember Gold"      => #FFD740
    "Stealth Dark"    => #A5D6A7
    "Clean Light"     => #2E7D32
    => cuLow

cWin = switch themeChoice
    "Aurabot"         => #FACC15
    "Neon Cyber"      => #FFEA00
    "Midnight Aura"   => #A78BFA
    "Sunset Blaze"    => #FB923C
    "Ocean Depth"     => #38BDF8
    "Ghost Protocol"  => #D4D4D8
    "Classic"         => #FF9800
    "Neon Violet"     => #E040FB
    "Plasma"          => #FFD60A
    "Blade Runner"    => #FF6E40
    "Toxic"           => #C6FF00
    "Ghost Wire"      => #EEFF41
    "Midnight Blue"   => #FFD166
    "Ember Gold"      => #FFAB00
    "Stealth Dark"    => #FFE082
    "Clean Light"     => #EF6C00
    => cuAccent

cNeutral = switch themeChoice
    "Aurabot"         => #8A8AA0
    "Neon Cyber"      => #78909C
    "Midnight Aura"   => #64748B
    "Sunset Blaze"    => #9A8478
    "Ocean Depth"     => #64748B
    "Ghost Protocol"  => #71717A
    "Classic"         => #787B86
    "Neon Violet"     => #8D8FA6
    "Plasma"          => #5C6B73
    "Blade Runner"    => #607D8B
    "Toxic"           => #7A8B6F
    "Ghost Wire"      => #78909C
    "Midnight Blue"   => #546E7A
    "Ember Gold"      => #8D6E63
    "Stealth Dark"    => #6D7B6E
    "Clean Light"     => #90A4AE
    => cuNeutral
cText = themeChoice == "Clean Light" ? #263238 : #EDE9FE

f_min(int hhmm) => math.floor(hhmm / 100) * 60 + hhmm % 100
hm = hour(time, tz) * 60 + minute(time, tz)
int s0 = f_min(aStart)
int e0 = f_min(aEnd)
bool inAsia = s0 > e0 ? (hm >= s0 or hm < e0) : (hm >= s0 and hm < e0)
bool startAsia = inAsia and not inAsia[1]

var float ceilV = na
var float floorV = na
var float runH = na
var float runL = na
if startAsia
    runH := high
    runL := low
else if inAsia
    runH := math.max(nz(runH, high), high)
    runL := math.min(nz(runL, low), low)
if not inAsia and inAsia[1]
    ceilV := runH
    floorV := runL

bool showWalls = not inAsia and hm < f_min(wallEnd) and hm >= e0 and not na(ceilV)
float atr = ta.atr(14)
float d = zoneATR * nz(atr)
pC  = plot(showWalls ? ceilV : na, "Ceiling", cCeil, lineW, plot.style_linebr)
pC2 = plot(showWalls ? ceilV + d : na, "Ceiling zone edge", color.new(cCeil, 100), 1, plot.style_linebr, display = display.none)
pF  = plot(showWalls ? floorV : na, "Floor", cFloor, lineW, plot.style_linebr)
pF2 = plot(showWalls ? floorV - d : na, "Floor zone edge", color.new(cFloor, 100), 1, plot.style_linebr, display = display.none)
plot(showWalls and showMid ? (ceilV + floorV) / 2 : na, "Midpoint", color.new(cNeutral, 30), 1, plot.style_linebr)
fill(pC, pC2, color.new(cCeil, zoneFade), "Above the ceiling")
fill(pF, pF2, color.new(cFloor, zoneFade), "Below the floor")

// wall tags at the right end of each day
var label tagH = na
var label tagL = na
if showTags and showWalls and not showWalls[1]
    tagH := label.new(bar_index, ceilV, "ASIA HIGH", style = label.style_label_left, color = color.new(#000000, 100), textcolor = cCeil, size = size.small)
    tagL := label.new(bar_index, floorV, "ASIA LOW", style = label.style_label_left, color = color.new(#000000, 100), textcolor = cFloor, size = size.small)
if showTags and showWalls and not na(tagH)
    label.set_x(tagH, bar_index)
    label.set_x(tagL, bar_index)

bool inWin = hm >= f_min(fStart) and hm < f_min(fEnd)
bgcolor(showAsia and inAsia ? color.new(cNeutral, 90) : na, title = "Asian session")
bgcolor(inWin ? color.new(cWin, 88) : na, title = "Focus window")

hudPos = input.string("Bottom right", "◈ Panel position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = "◈ Panel", tooltip = "Where this script's info panel sits, so it never covers price or other panels.")
f_hudPos(string p) =>
    switch p
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Top right"     => position.top_right
        "Middle left"   => position.middle_left
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        => position.bottom_right
var table tb = table.new(f_hudPos(hudPos), 1, 2, bgcolor = themeChoice == "Clean Light" ? color.new(#FFFFFF, 10) : color.new(#050508, 15), border_width = 1, border_color = color.new(cWin, 60))
if showBadge and barstate.islast
    string where = na(ceilV) or inAsia ? "Asian session in progress" : close > ceilV ? "Above the ceiling" : close < floorV ? "Below the floor" : "Inside the Asian range"
    color wc = na(ceilV) or inAsia ? cText : close > ceilV ? cCeil : close < floorV ? cFloor : color.new(cText, 40)
    table.cell(tb, 0, 0, "ASIA WALLS", text_color = cWin, text_size = size.normal)
    table.cell(tb, 0, 1, where + (inWin ? " (focus window)" : ""), text_color = wc, text_size = size.small)

alertcondition(showWalls and ta.crossunder(low, floorV), "Price under the floor", "ASIA WALLS: price traded under the Asian low")
alertcondition(showWalls and ta.crossover(high, ceilV), "Price over the ceiling", "ASIA WALLS: price traded over the Asian high")
````
