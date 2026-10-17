# BFG Current Bar / Time Icon Marker

- url: https://www.tradingview.com/script/6oRN7eyI-BFG-Current-Bar-Time-Icon-Marker/
- type: indicator
- pine_id: PUB;7f7e1cf74f50412f862c9a88660d4a7c
- version: 1.0

## Description

Just a test. Nothing to see here. A practical in user interfaces and placement of info on a chart.

## Source Code

````pine
/// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © barefootgreenback

//@version=6
indicator("BFG Current Bar / Time Icon Marker", shorttitle="IconMark", overlay=true, max_labels_count=10)

//════════════════════════════════════════════════════════════════════
// INPUTS
//════════════════════════════════════════════════════════════════════
string groupMarker = "Marker"

string TT_MarkerSymbol = "Choose a preset marker from the categorized library. Select Custom to use the Custom Symbol / Emoji input."
string TT_CustomEmoji  = "Only used when Marker Symbol is set to \"Custom\". Click this box and press Windows key + . to open the Windows emoji picker, or paste any Unicode symbol/emoji."

bool showMarker = input.bool(true, "Show Marker", group=groupMarker)

string markerPlacementMode = input.string(
     "Current Bar",
     "Placement Mode",
     options=["Current Bar", "User Time"],
     group=groupMarker
)

// Default: June 13, 2026, 09:30 New York time.
// Pine requires input.time() defval to be a const int.
int markerTime = input.time(
     1781357400000,
     "Marker Time",
     group=groupMarker
)

string markerSymbolChoice = input.string(
     "Direction - ▲ Up Triangle",
     "Marker Symbol",
     options=[
         "Direction - ▲ Up Triangle",
         "Direction - ▼ Down Triangle",
         "Direction - △ Hollow Up Triangle",
         "Direction - ▽ Hollow Down Triangle",
         "Direction - ↑ Up Arrow",
         "Direction - ↓ Down Arrow",
         "Direction - ↗ Up-Right Arrow",
         "Direction - ↘ Down-Right Arrow",
         "Direction - ⇧ Strong Up",
         "Direction - ⇩ Strong Down",
         "Direction - ⟰ Double Up",
         "Direction - ⟱ Double Down",

         "Shape - ● Circle",
         "Shape - ○ Hollow Circle",
         "Shape - ◉ Bullseye Circle",
         "Shape - ◆ Diamond",
         "Shape - ◇ Hollow Diamond",
         "Shape - ■ Square",
         "Shape - □ Hollow Square",
         "Shape - ▣ Boxed Square",
         "Shape - ★ Star",
         "Shape - ☆ Hollow Star",
         "Shape - ✦ Spark Star",
         "Shape - ✧ Hollow Spark Star",

         "Status - ⚠ Warning",
         "Status - ✓ Check",
         "Status - ✔ Heavy Check",
         "Status - ✖ X",
         "Status - ✕ Thin X",
         "Status - ✚ Cross",
         "Status - ! Alert",
         "Status - ? Question",
         "Status - ⏱ Timer",
         "Status - ⌛ Hourglass",

         "Trading - LONG",
         "Trading - SHORT",
         "Trading - BUY",
         "Trading - SELL",
         "Trading - TP",
         "Trading - SL",
         "Trading - REV",
         "Trading - ORB",
         "Trading - SEQ",
         "Trading - MOM",
         "Trading - RSI",
         "Trading - STOCH",

         "Emoji - 🔥 Fire",
         "Emoji - ⚡ Lightning",
         "Emoji - 🎯 Target",
         "Emoji - 🚀 Rocket",
         "Emoji - 👀 Watching",
         "Emoji - 📍 Pin",
         "Emoji - 📌 Pushpin",
         "Emoji - ⏳ Waiting",
         "Emoji - ⏰ Alarm",
         "Emoji - 🧭 Compass",
         "Emoji - 💥 Explosion",
         "Emoji - 🧨 Dynamite",

         "Market - 🐂 Bull",
         "Market - 🐻 Bear",
         "Market - 🟢 Green Circle",
         "Market - 🔴 Red Circle",
         "Market - 🟡 Yellow Circle",
         "Market - 🔵 Blue Circle",
         "Market - 🟣 Purple Circle",
         "Market - 🟠 Orange Circle",
         "Market - ⚫ Black Circle",
         "Market - ⚪ White Circle",

         "BFG - 3",
         "BFG - 6",
         "BFG - 9",
         "BFG - 12",
         "BFG - 18",
         "BFG - Beat",
         "BFG - Exhaustion",
         "BFG - Sequence",
         "BFG - Reversal",
         "BFG - Continuation",

         "Custom"
     ],
     tooltip=TT_MarkerSymbol,
     group=groupMarker
)

string customMarkerText = input.string(
     "🔥",
     "Custom Symbol / Emoji",
     tooltip=TT_CustomEmoji,
     group=groupMarker
)

string markerPosition = input.string(
     "Above Bar",
     "Marker Position",
     options=["Above Bar", "Below Bar"],
     group=groupMarker
)

int markerSizeInput = input.int(3, "Marker Size", minval=1, maxval=5, group=groupMarker)

color markerColor = input.color(color.rgb(0, 255, 255), "Marker Color", group=groupMarker)

int markerXOffset = input.int(0, "Horizontal Offset Bars", minval=-100, maxval=100, group=groupMarker)

//════════════════════════════════════════════════════════════════════
// SYMBOL MAP
//════════════════════════════════════════════════════════════════════
string markerText = switch markerSymbolChoice
    "Direction - ▲ Up Triangle"          => "▲"
    "Direction - ▼ Down Triangle"        => "▼"
    "Direction - △ Hollow Up Triangle"   => "△"
    "Direction - ▽ Hollow Down Triangle" => "▽"
    "Direction - ↑ Up Arrow"             => "↑"
    "Direction - ↓ Down Arrow"           => "↓"
    "Direction - ↗ Up-Right Arrow"       => "↗"
    "Direction - ↘ Down-Right Arrow"     => "↘"
    "Direction - ⇧ Strong Up"            => "⇧"
    "Direction - ⇩ Strong Down"          => "⇩"
    "Direction - ⟰ Double Up"            => "⟰"
    "Direction - ⟱ Double Down"          => "⟱"

    "Shape - ● Circle"                   => "●"
    "Shape - ○ Hollow Circle"            => "○"
    "Shape - ◉ Bullseye Circle"          => "◉"
    "Shape - ◆ Diamond"                  => "◆"
    "Shape - ◇ Hollow Diamond"           => "◇"
    "Shape - ■ Square"                   => "■"
    "Shape - □ Hollow Square"            => "□"
    "Shape - ▣ Boxed Square"             => "▣"
    "Shape - ★ Star"                     => "★"
    "Shape - ☆ Hollow Star"              => "☆"
    "Shape - ✦ Spark Star"               => "✦"
    "Shape - ✧ Hollow Spark Star"        => "✧"

    "Status - ⚠ Warning"                 => "⚠"
    "Status - ✓ Check"                   => "✓"
    "Status - ✔ Heavy Check"             => "✔"
    "Status - ✖ X"                       => "✖"
    "Status - ✕ Thin X"                  => "✕"
    "Status - ✚ Cross"                   => "✚"
    "Status - ! Alert"                   => "!"
    "Status - ? Question"                => "?"
    "Status - ⏱ Timer"                   => "⏱"
    "Status - ⌛ Hourglass"              => "⌛"

    "Trading - LONG"                     => "LONG"
    "Trading - SHORT"                    => "SHORT"
    "Trading - BUY"                      => "BUY"
    "Trading - SELL"                     => "SELL"
    "Trading - TP"                       => "TP"
    "Trading - SL"                       => "SL"
    "Trading - REV"                      => "REV"
    "Trading - ORB"                      => "ORB"
    "Trading - SEQ"                      => "SEQ"
    "Trading - MOM"                      => "MOM"
    "Trading - RSI"                      => "RSI"
    "Trading - STOCH"                    => "STOCH"

    "Emoji - 🔥 Fire"                    => "🔥"
    "Emoji - ⚡ Lightning"               => "⚡"
    "Emoji - 🎯 Target"                  => "🎯"
    "Emoji - 🚀 Rocket"                  => "🚀"
    "Emoji - 👀 Watching"                => "👀"
    "Emoji - 📍 Pin"                     => "📍"
    "Emoji - 📌 Pushpin"                 => "📌"
    "Emoji - ⏳ Waiting"                 => "⏳"
    "Emoji - ⏰ Alarm"                   => "⏰"
    "Emoji - 🧭 Compass"                 => "🧭"
    "Emoji - 💥 Explosion"               => "💥"
    "Emoji - 🧨 Dynamite"                => "🧨"

    "Market - 🐂 Bull"                   => "🐂"
    "Market - 🐻 Bear"                   => "🐻"
    "Market - 🟢 Green Circle"           => "🟢"
    "Market - 🔴 Red Circle"             => "🔴"
    "Market - 🟡 Yellow Circle"          => "🟡"
    "Market - 🔵 Blue Circle"            => "🔵"
    "Market - 🟣 Purple Circle"          => "🟣"
    "Market - 🟠 Orange Circle"          => "🟠"
    "Market - ⚫ Black Circle"            => "⚫"
    "Market - ⚪ White Circle"            => "⚪"

    "BFG - 3"                            => "3"
    "BFG - 6"                            => "6"
    "BFG - 9"                            => "9"
    "BFG - 12"                           => "12"
    "BFG - 18"                           => "18"
    "BFG - Beat"                         => "BEAT"
    "BFG - Exhaustion"                   => "EXH"
    "BFG - Sequence"                     => "SEQ"
    "BFG - Reversal"                     => "REV"
    "BFG - Continuation"                 => "CONT"

    "Custom"                             => customMarkerText
    => "▲"

//════════════════════════════════════════════════════════════════════
// SIZE MAP
//════════════════════════════════════════════════════════════════════
markerSize = switch markerSizeInput
    1 => size.tiny
    2 => size.small
    3 => size.normal
    4 => size.large
    5 => size.huge

//════════════════════════════════════════════════════════════════════
// POSITION LOGIC
//════════════════════════════════════════════════════════════════════
bool markerAbove = markerPosition == "Above Bar"

float markerY = markerAbove ? high : low

markerYLoc = markerAbove ? yloc.abovebar : yloc.belowbar

//════════════════════════════════════════════════════════════════════
// TIME PLACEMENT LOGIC
//════════════════════════════════════════════════════════════════════
bool useCurrentBar = markerPlacementMode == "Current Bar"
bool useUserTime   = markerPlacementMode == "User Time"

// The marker prints on the candle whose time window contains the selected time.
bool markerTimeBar = not na(time_close) and time <= markerTime and time_close > markerTime

bool drawMarker = showMarker and ((useCurrentBar and barstate.islast) or (useUserTime and markerTimeBar))

//════════════════════════════════════════════════════════════════════
// MARKER DRAWING
//════════════════════════════════════════════════════════════════════
var label markerLabel = na

if drawMarker
    if na(markerLabel)
        markerLabel := label.new(
             bar_index + markerXOffset,
             markerY,
             markerText,
             xloc=xloc.bar_index,
             yloc=markerYLoc,
             style=label.style_none,
             textcolor=markerColor,
             color=color.new(color.rgb(0, 0, 0), 100),
             size=markerSize
         )
    else
        label.set_x(markerLabel, bar_index + markerXOffset)
        label.set_y(markerLabel, markerY)
        label.set_yloc(markerLabel, markerYLoc)
        label.set_text(markerLabel, markerText)
        label.set_textcolor(markerLabel, markerColor)
        label.set_color(markerLabel, color.new(color.rgb(0, 0, 0), 100))
        label.set_style(markerLabel, label.style_none)
        label.set_size(markerLabel, markerSize)

if barstate.islast and not showMarker
    if not na(markerLabel)
        label.delete(markerLabel)
        markerLabel := na
````
