# Multiple SMAs/EMAs

- url: https://www.tradingview.com/script/vOaUJhF4-Multiple-SMAs-EMAs/
- type: indicator
- pine_id: PUB;dbe7677299f143a4ba9db9df0806e28c
- version: 1.0

## Description

Multi.MA displays up to 9 configurable moving averages, with automatic HighTimeFrame/LowTimeFrame logic that adapts the visible MAs based on the chart timeframe.

## Source Code

````pine
//@version=6
indicator("Multiple SMAs/EMAs", shorttitle="Multiple MA", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Couleurs fixes par défaut
// Réglables ensuite dans Style
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color VIOLET          = #800080
color DARK_BLUE       = #00008B
color LIGHT_TURQUOISE = #40E0D0
color YELLOW          = #FFD700
color RED             = #FF0000

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fonctions MA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
maValue(_src, _len, _type) =>
    float ema1 = ta.ema(_src, _len)
    float ema2 = ta.ema(ema1, _len)
    float ema3 = ta.ema(ema2, _len)

    switch _type
        "SMA"  => ta.sma(_src, _len)
        "EMA"  => ta.ema(_src, _len)
        "WMA"  => ta.wma(_src, _len)
        "VWMA" => ta.vwma(_src, _len)
        "RMA"  => ta.rma(_src, _len)
        "HMA"  => ta.hma(_src, _len)
        "DEMA" => 2.0 * ema1 - ema2
        "TEMA" => 3.0 * (ema1 - ema2) + ema3
        "ALMA" => ta.alma(_src, _len, 0.85, 6)
        => ta.sma(_src, _len)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fonctions Timeframe
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tfToResolution(_tf) =>
    switch _tf
        "M."  => "M"
        "W."  => "W"
        "D."  => "D"
        "H12" => "720"
        "H8"  => "480"
        "H6"  => "360"
        "H5"  => "300"
        "H4"  => "240"
        "H3"  => "180"
        "H2"  => "120"
        "H1"  => "60"
        "M45" => "45"
        "M30" => "30"
        "M15" => "15"
        "M5"  => "5"
        "M3"  => "3"
        "M1"  => "1"
        => timeframe.period

tfToSeconds(_tf) =>
    switch _tf
        "M."  => 30 * 24 * 60 * 60
        "W."  => 7 * 24 * 60 * 60
        "D."  => 24 * 60 * 60
        "H12" => 12 * 60 * 60
        "H8"  => 8 * 60 * 60
        "H6"  => 6 * 60 * 60
        "H5"  => 5 * 60 * 60
        "H4"  => 4 * 60 * 60
        "H3"  => 3 * 60 * 60
        "H2"  => 2 * 60 * 60
        "H1"  => 60 * 60
        "M45" => 45 * 60
        "M30" => 30 * 60
        "M15" => 15 * 60
        "M5"  => 5 * 60
        "M3"  => 3 * 60
        "M1"  => 60
        => 5 * 60 * 60

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs compacts MA 1-4
// Réglages uniquement : TF / Type / Len
// Pas d'activation ici
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gMA1 = "MA 1-4"

tf1   = input.string("Chart", "MA1 TF", options=["Chart", "M.", "W.", "D.", "H12", "H8", "H6", "H5", "H4", "H3", "H2", "H1", "M45", "M30", "M15", "M5", "M3", "M1"], group=gMA1, inline="ma1", display=display.none)
type1 = input.string("SMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=gMA1, inline="ma1", display=display.none)
len1  = input.int(200, "Len", minval=1, group=gMA1, inline="ma1", display=display.none)

tf2   = input.string("Chart", "MA2 TF", options=["Chart", "M.", "W.", "D.", "H12", "H8", "H6", "H5", "H4", "H3", "H2", "H1", "M45", "M30", "M15", "M5", "M3", "M1"], group=gMA1, inline="ma2", display=display.none)
type2 = input.string("SMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=gMA1, inline="ma2", display=display.none)
len2  = input.int(100, "Len", minval=1, group=gMA1, inline="ma2", display=display.none)

tf3   = input.string("Chart", "MA3 TF", options=["Chart", "M.", "W.", "D.", "H12", "H8", "H6", "H5", "H4", "H3", "H2", "H1", "M45", "M30", "M15", "M5", "M3", "M1"], group=gMA1, inline="ma3", display=display.none)
type3 = input.string("SMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=gMA1, inline="ma3", display=display.none)
len3  = input.int(50, "Len", minval=1, group=gMA1, inline="ma3", display=display.none)

tf4   = input.string("Chart", "MA4 TF", options=["Chart", "M.", "W.", "D.", "H12", "H8", "H6", "H5", "H4", "H3", "H2", "H1", "M45", "M30", "M15", "M5", "M3", "M1"], group=gMA1, inline="ma4", display=display.none)
type4 = input.string("SMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=gMA1, inline="ma4", display=display.none)
len4  = input.int(20, "Len", minval=1, group=gMA1, inline="ma4", display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs compacts MA 5-9
// Réglages uniquement : TF / Type / Len
// Pas d'activation ici
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gMA2 = "MA 5-9"

tf5   = input.string("Chart", "MA5 TF", options=["Chart", "M.", "W.", "D.", "H12", "H8", "H6", "H5", "H4", "H3", "H2", "H1", "M45", "M30", "M15", "M5", "M3", "M1"], group=gMA2, inline="ma5", display=display.none)
type5 = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=gMA2, inline="ma5", display=display.none)
len5  = input.int(200, "Len", minval=1, group=gMA2, inline="ma5", display=display.none)

tf6   = input.string("Chart", "MA6 TF", options=["Chart", "M.", "W.", "D.", "H12", "H8", "H6", "H5", "H4", "H3", "H2", "H1", "M45", "M30", "M15", "M5", "M3", "M1"], group=gMA2, inline="ma6", display=display.none)
type6 = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=gMA2, inline="ma6", display=display.none)
len6  = input.int(100, "Len", minval=1, group=gMA2, inline="ma6", display=display.none)

tf7   = input.string("Chart", "MA7 TF", options=["Chart", "M.", "W.", "D.", "H12", "H8", "H6", "H5", "H4", "H3", "H2", "H1", "M45", "M30", "M15", "M5", "M3", "M1"], group=gMA2, inline="ma7", display=display.none)
type7 = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=gMA2, inline="ma7", display=display.none)
len7  = input.int(50, "Len", minval=1, group=gMA2, inline="ma7", display=display.none)

tf8   = input.string("Chart", "MA8 TF", options=["Chart", "M.", "W.", "D.", "H12", "H8", "H6", "H5", "H4", "H3", "H2", "H1", "M45", "M30", "M15", "M5", "M3", "M1"], group=gMA2, inline="ma8", display=display.none)
type8 = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=gMA2, inline="ma8", display=display.none)
len8  = input.int(21, "Len", minval=1, group=gMA2, inline="ma8", display=display.none)

tf9   = input.string("Chart", "MA9 TF", options=["Chart", "M.", "W.", "D.", "H12", "H8", "H6", "H5", "H4", "H3", "H2", "H1", "M45", "M30", "M15", "M5", "M3", "M1"], group=gMA2, inline="ma9", display=display.none)
type9 = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=gMA2, inline="ma9", display=display.none)
len9  = input.int(9, "Len", minval=1, group=gMA2, inline="ma9", display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA TIMEFRAME
// Activation uniquement ici
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gAuto = "MA TIMEFRAME"

maTimeframe = input.bool(true, "MA TIMEFRAME", group=gAuto, display=display.none)

autoSwitchTf = input.string(
     "H5",
     "Timeframe",
     options=["M1", "M3", "M5", "M15", "M30", "M45", "H1", "H2", "H3", "H4", "H5", "H6", "H8", "H12", "D.", "W.", "M."],
     group=gAuto,
     display=display.none,
     active=maTimeframe
 )

// Colonne gauche = HTF | Colonne droite = LTF
autoHtf1 = input.bool(true,  "HTF MA1", group=gAuto, inline="auto1", display=display.none, active=maTimeframe)
autoLtf1 = input.bool(false, "LTF MA1", group=gAuto, inline="auto1", display=display.none, active=maTimeframe)

autoHtf2 = input.bool(false, "HTF MA2", group=gAuto, inline="auto2", display=display.none, active=maTimeframe)
autoLtf2 = input.bool(false, "LTF MA2", group=gAuto, inline="auto2", display=display.none, active=maTimeframe)

autoHtf3 = input.bool(true,  "HTF MA3", group=gAuto, inline="auto3", display=display.none, active=maTimeframe)
autoLtf3 = input.bool(false, "LTF MA3", group=gAuto, inline="auto3", display=display.none, active=maTimeframe)

autoHtf4 = input.bool(false, "HTF MA4", group=gAuto, inline="auto4", display=display.none, active=maTimeframe)
autoLtf4 = input.bool(false, "LTF MA4", group=gAuto, inline="auto4", display=display.none, active=maTimeframe)

autoHtf5 = input.bool(false, "HTF MA5", group=gAuto, inline="auto5", display=display.none, active=maTimeframe)
autoLtf5 = input.bool(false, "LTF MA5", group=gAuto, inline="auto5", display=display.none, active=maTimeframe)

autoHtf6 = input.bool(false, "HTF MA6", group=gAuto, inline="auto6", display=display.none, active=maTimeframe)
autoLtf6 = input.bool(false, "LTF MA6", group=gAuto, inline="auto6", display=display.none, active=maTimeframe)

autoHtf7 = input.bool(false, "HTF MA7", group=gAuto, inline="auto7", display=display.none, active=maTimeframe)
autoLtf7 = input.bool(true,  "LTF MA7", group=gAuto, inline="auto7", display=display.none, active=maTimeframe)

autoHtf8 = input.bool(false, "HTF MA8", group=gAuto, inline="auto8", display=display.none, active=maTimeframe)
autoLtf8 = input.bool(true,  "LTF MA8", group=gAuto, inline="auto8", display=display.none, active=maTimeframe)

autoHtf9 = input.bool(false, "HTF MA9", group=gAuto, inline="auto9", display=display.none, active=maTimeframe)
autoLtf9 = input.bool(false, "LTF MA9", group=gAuto, inline="auto9", display=display.none, active=maTimeframe)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Source — tout en bas des Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
src = input.source(close, "Source", group="Source", display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Calcul MTF
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
calcMTF(_tf, _len, _type) =>
    request.security(
         syminfo.tickerid,
         tfToResolution(_tf),
         maValue(src, _len, _type),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Détection HTF / LTF selon timeframe sélectionné
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
chartSeconds = nz(timeframe.in_seconds(timeframe.period), tfToSeconds(autoSwitchTf))
switchSeconds = tfToSeconds(autoSwitchTf)

isLtf = chartSeconds < switchSeconds
isHtf = not isLtf

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Activation effective
// Si MA TIMEFRAME est décoché, toutes les MA sont masquées.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showEff1 = maTimeframe ? (isHtf ? autoHtf1 : autoLtf1) : false
showEff2 = maTimeframe ? (isHtf ? autoHtf2 : autoLtf2) : false
showEff3 = maTimeframe ? (isHtf ? autoHtf3 : autoLtf3) : false
showEff4 = maTimeframe ? (isHtf ? autoHtf4 : autoLtf4) : false
showEff5 = maTimeframe ? (isHtf ? autoHtf5 : autoLtf5) : false
showEff6 = maTimeframe ? (isHtf ? autoHtf6 : autoLtf6) : false
showEff7 = maTimeframe ? (isHtf ? autoHtf7 : autoLtf7) : false
showEff8 = maTimeframe ? (isHtf ? autoHtf8 : autoLtf8) : false
showEff9 = maTimeframe ? (isHtf ? autoHtf9 : autoLtf9) : false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Calculs MA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma1 = calcMTF(tf1, len1, type1)
ma2 = calcMTF(tf2, len2, type2)
ma3 = calcMTF(tf3, len3, type3)
ma4 = calcMTF(tf4, len4, type4)
ma5 = calcMTF(tf5, len5, type5)
ma6 = calcMTF(tf6, len6, type6)
ma7 = calcMTF(tf7, len7, type7)
ma8 = calcMTF(tf8, len8, type8)
ma9 = calcMTF(tf9, len9, type9)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
// Style modifiable : couleur + épaisseur
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showEff1 ? ma1 : na, "MA1", color=VIOLET, linewidth=2)
plot(showEff2 ? ma2 : na, "MA2", color=DARK_BLUE, linewidth=1)
plot(showEff3 ? ma3 : na, "MA3", color=LIGHT_TURQUOISE, linewidth=1)
plot(showEff4 ? ma4 : na, "MA4", color=YELLOW, linewidth=1)

plot(showEff5 ? ma5 : na, "MA5", color=VIOLET, linewidth=2)
plot(showEff6 ? ma6 : na, "MA6", color=DARK_BLUE, linewidth=1)
plot(showEff7 ? ma7 : na, "MA7", color=LIGHT_TURQUOISE, linewidth=2)
plot(showEff8 ? ma8 : na, "MA8", color=YELLOW, linewidth=1)
plot(showEff9 ? ma9 : na, "MA9", color=RED, linewidth=1)
````
