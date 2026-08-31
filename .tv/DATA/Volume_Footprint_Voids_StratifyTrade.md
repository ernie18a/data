<!-- tradingview-pine-id: PUB;a29523ff015b4c85ae24d49c38ee29f1 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Footprint Voids [StratifyTrade]

Source: https://www.tradingview.com/script/ZMxB93wD-Volume-Footprint-Voids-BigBeluga/

## Description

Volume Footprint Voids is a unique tool that uses lower timeframe calculation to plot different styles of single candle POC.

This indicator is very powerful for scalping and finding very precise entry and exits, spotting potential trapped traders, and more.

Unlike many other volume profiles, this aims to plot single candle profiles as well as their own footprints.

🔶 FEATURES

The script includes the following settings:

[*]Windows: Plotting style and calculations
[*]Coloring modes
[*]Display modes
[*]lower-timeframe calculations

🔶 CALCULATION

[image]https://www.tradingview.com/x/csUK74Rm/[/image]

In the image above we can see how the script calculates each level position that will serve as a calculation process to see how much volume/closes there are within the levels.

[image]https://www.tradingview.com/x/IjDn41KG/[/image]

In the image above, we can have a more clear example of how we count each candle close.
We use the prior screenshot as an example, after setting each level we will use the lower-timeframe input to measure the amount of closes within the ranges.

Depending on the lot size, the box will be larger or smaller, usually the POC will always have the highest box size.

NOTE: Size is the starting point, always from the low of the candle.
To find more voids, select a closer LTF to the current one you're using.
To find fewer voids, select a timeframe away from your current one.
Due to Pine Script limitations, we are only able to plot a certain amount of footprints, and we can't plot the whole history chart.

[image]https://www.tradingview.com/x/fpE3nJbw/[/image]

POC will be the largest block displayed, indicating the time point of control
Gray areas are closes above the average
Black are Void or imbalance that price will fill in the future, like FVG

[image]https://www.tradingview.com/x/q1MRRjQZ/[/image]

The image above shows an incorrect size input that will lead to bad calculations, while on the other side, a correct size input that will lead to a clear vision and better calculation.

🔶 WINDOWS

[image]https://www.tradingview.com/x/ucUBvibi/[/image]

The "▲▼" Mode will display delta buyers and delta sellers coloring with voids as black.
It also offers a gradient mode for a beautier visualization

[image]https://www.tradingview.com/x/EDLDLvkK/[/image]

The "Total Volume" mode will display the net volume within the lot size (closes within the levels).
This is useful to spot possible highest net volume within the same highest lot size.

[image]https://www.tradingview.com/x/Kryqd41K/[/image]

The "POC + Gaps" will show both POC and Gaps as the highest block while all the rest will be considered as the smaller block.
This is useful to see where the highest lot were and if there are higher or lower imbalances within the candle

[image]https://www.tradingview.com/x/yyWFbBEb/[/image]
The last option "Gaps" will simply display the gaps as the highest block, while the POC as the lowest block.
This is useful to have a better view of the gaps areas

🔶 EXAMPLE

[image]https://www.tradingview.com/x/e58Pbz38/[/image]

This is one of the most basic examples of how this script can be used. POC at the bottom creating a strong support area as price holds and creates higher voids gap that price fills while rising.

🔶 SETTINGS

Users have full control over the script, from colors to choosing the lower-timeframe inputs to disabling the lot size.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © StratifyTrade
//@version=5


indicator(
       "Volume Footprint Voids [StratifyTrade]"
     , "StratifyTrade - Volume Footprint Voids [1.0]"
     , overlay = true
     , max_labels_count = 500
     , max_lines_count = 500
         )


const string tlM = 
     "[POC] Display point of control of the most closes\n
     [▲▼] Display Delta volume coloring\n
     [▲▼ Gradient] Display Delta gradient volume\n
     [Total Volume] Display net volume color\n
     [POC + Gaps] Display POC and void gaps\n
     [Gaps] Display void gaps only"

const string tlL = 
     "The Lot inputs is the ammount of point the script will assign to each candle, 
     this mean that on each candle, the script will assign 0.25 lot size to fit the 
     entire candle untill it fully fit, start with 0.01 and ride your way untill it 
     fit the best size. This is the starting Lot size"

const string tlT = 
     "POC/Delta LTF Volume calculation\TIP: To spot volume voids use a close LTF to the 
     main one, for less void, use a smaller LTF"

const string tlX =
     "Display Lots size text"


mode = input.string(
       "POC"
     , "Window    "
     , ["POC", "▲▼", "▲▼ Gradient", "Total Volume", "POC + Gaps", "Gaps"]
     , tlM
     , "mode"
     , "Coloring"
                  )

vNH   = input.color   (#f59c1c, "POC       ", inline = "net", group = "Coloring")
vNM   = input.color   (#9f9f9f, "          ", inline = "net", group = "Coloring")
vN0   = input.color   (#5c5c5c, "          ", inline = "net", group = "Coloring")

vGUH  = input.color   (#4cc786, "▲▼        ", inline = "grd", group = "Coloring")
vGDN  = input.color   (#cd1d28, "          ", inline = "grd", group = "Coloring")
vGDH  = input.color   (#5c5c5c, "          ", inline = "grd", group = "Coloring")

tVM  = input.color    (#f4f4f4, "Total     ", inline = "tvo", group = "Coloring")
tVL  = input.color    (#a8a8aa, "          ", inline = "tvo", group = "Coloring")
tVG  = input.color    (#46454b, "          ", inline = "tvo", group = "Coloring")

gPG  = input.color    (#cd1c28, "Gaps      ", inline = "gap", group = "Coloring")
gLV  = input.color    (#9f9f9f, "          ", inline = "gap", group = "Coloring")
gL0  = input.color    (#5c5c5e, "          ", inline = "gap", group = "Coloring")

Lot  = input.float    (0.25     , "Size      "                , group = "SETTINGS", tooltip = tlL, minval  = 0.01        , step = 0.01)
LTF  = input.timeframe("5"      , "LTF       "                , group = "SETTINGS", tooltip = tlT                                     )  
plN  = input.string   ("ON"     , "Lots      "                , group = "SETTINGS", tooltip = tlX,             options = ["ON", "OFF"])

color css = na
int     i = 0


type bin
    float[] lvls
    float[] vols
    int  [] lots

type voids
    float   top
    float   btm
    int     loc
    color   css
    bool    bull

type bar
    float   o = open
    float   h = high
    float   l = low
    float   c = close
    float   v = volume


bar               b  = bar  .new       ()
bin              ZZ  = bin  .new       (
                       array.new<float>()
                     , array.new<float>()
                     , array.new< int >()
                                       )
var voids[]    void  = array.new<voids>()


[cL, oP, hI, lO, vO] = request.security_lower_tf(
       ""
     , LTF
     , 
     [
           b.c
         , b.o
         , b.h
         , b.l
         , b.v
         
     ]
                                                 )


method pos(bin zz, float Lot, int i) =>
    if i == 0
        zz.lvls.unshift(               b.l             )
        zz.lots.unshift(                0              )
        zz.vols.unshift(                0              )

    else
        zz.lvls.unshift(b.l + (b.l * ((Lot * i)) / 100))
        zz.lots.unshift(                0              )
        zz.vols.unshift(                0              )

    zz.lvls.get(0)


method puts(bin zz, float c, float o, int x, float v) =>
    switch
        c > o => zz.lots.set(x, zz.lots.get(x) + 1), zz.vols.set(x, zz.vols.get(x) + v)
        c < o => zz.lots.set(x, zz.lots.get(x) + 1), zz.vols.set(x, zz.vols.get(x) - v)


method dLb(float y, color css, string txt, string size) =>
    label.new(
           x                = bar_index
         , y                = y
         , style            = label.style_label_center
         , color            = #ffffff00
         , textcolor        = css
         , text             = txt
         , size             = size
         , xloc             = xloc.bar_index
         , text_font_family = font.family_monospace
             )


while b.h > ZZ.pos(Lot, i)
    i   += 1


if ZZ.lvls.size() > 1
    for x = 0 to ZZ.lvls.size() - 1
        for [id, c] in cL
            o    = oP     .get( id )
            h    = hI     .get( id )
            l    = lO     .get( id )
            v    = vO     .get( id )
            lots = ZZ.lots.get( x  )
            lvls = ZZ.lvls.get( x  )
            switch
                x                             == 0 =>
                    if                     h > ZZ.lvls.get ( x + 1 )
                        ZZ                         .puts(c, o, x, v)
                        
                x != 0 and x != ZZ.lvls.size() - 1 =>
                    if c < ZZ.lvls.get(x - 1) and c > ZZ.lvls.get(x)
                        ZZ                         .puts(c, o, x, v)  

                x             == ZZ.lvls.size() - 1 =>
                    if                        l < ZZ.lvls.get(x - 1)
                        ZZ                         .puts(c, o, x, v)       


if ZZ.lvls.size() > 1
    for x = 0 to ZZ.lvls.size() - 1 
        if ZZ.lvls.get(x) <= b.h
            lots = ZZ.lots.get(x)
            lvls = ZZ.lvls.get(x)
            vols = ZZ.vols.get(x)

            switch mode
                "POC"          => css := lots <= ZZ.lots.avg() ? vN0  : lots != 0 and lots != ZZ.lots.max() and lots >= ZZ.lots.avg() ? vNM  : lots == ZZ.lots.max() ? vNH  : vN0
                "▲▼"           => css := lots == 0             ? vGDH : vols  > 0                                                     ? vGUH : vols < 0              ? vGDN : na
                "POC + Gaps"   => css := lots == ZZ.lots.max() ? vNH  : lots == 0                                                     ? vN0  : vNM
                "Gaps"         => css := lots == ZZ.lots.max() ? gL0  : lots == 0                                                     ? gPG  : gLV
                "▲▼ Gradient"  => css :=                                                          color.from_gradient(vols, ZZ.vols.min()      , ZZ.vols.max()      , vGDN, vGUH)
                "Total Volume" => css :=                                                          color.from_gradient(vols, ZZ.vols.abs().min(), ZZ.vols.abs().max(), tVL , tVM )

            if plN == "ON"
                lvls.dLb (
                     chart.fg_color
                     , 
                         str.tostring(lots) + 
                         (
                         str.length(str.tostring(lots)) == 1 
                         ? "    " 
                         : str.length(str.tostring(lots)) == 2 
                         ? "     " 
                         : "      "
                         )

                     , size.small
                         )

            if mode != "POC + Gaps" and mode != "Gaps" and mode != "Total Volume"

                if lots <= ZZ.lots.avg()
                    lvls.dLb                         (css, "▉"     , size.small)

                if lots != 0 and lots != ZZ.lots.max() and lots >= ZZ.lots.avg()
                    lvls.dLb                         (css, "▉"      , size.small)
                    lvls.dLb                         (css, "   ▉"   , size.small)

                if lots == ZZ.lots.max()
                    lvls.dLb                         (css, "▉"      , size.small)
                    lvls.dLb                         (css, "   ▉"   , size.small)
                    lvls.dLb                         (css, "      ▉", size.small)

            if mode == "POC + Gaps"

                if lots > 0 and lots < ZZ.lots.max()
                    lvls.dLb                         (css, "▉"      , size.small)

                if lots == 0
                    lvls.dLb                         (css, "▉"      , size.small)
                    lvls.dLb                         (css, "   ▉"   , size.small)
                    lvls.dLb                         (css, "      ▉", size.small)

                if lots == ZZ.lots.max()
                    lvls.dLb                         (css, "▉"      , size.small)
                    lvls.dLb                         (css, "   ▉"   , size.small)
                    lvls.dLb                         (css, "      ▉", size.small)

            if mode == "Gaps"

                if lots != 0 and lots != ZZ.lots.max()
                    lvls.dLb                         (css, "▉"      , size.small)
                    lvls.dLb                         (css, "   ▉"   , size.small)

                if lots == 0
                    lvls.dLb                         (css, "▉"      , size.small)
                    lvls.dLb                         (css, "   ▉"   , size.small)
                    lvls.dLb                         (css, "      ▉", size.small)

                if lots == ZZ.lots.max()
                    lvls.dLb                         (css, "▉"      , size.small)

            if mode == "Total Volume"

                if vols > ZZ.vols.abs().avg() and vols != ZZ.vols.abs().max()
                    lvls.dLb                         (css, "▉"      , size.small)
                    lvls.dLb                         (css, "   ▉"   , size.small)

                if vols == ZZ.vols.abs().max()
                    lvls.dLb                         (css, "▉"      , size.small)
                    lvls.dLb                         (css, "   ▉"   , size.small)
                    lvls.dLb                         (css, "      ▉", size.small)

                if vols < ZZ.vols.abs().avg() and vols != ZZ.vols.abs().max()
                    lvls.dLb                         (css, "▉"      , size.small)
````
