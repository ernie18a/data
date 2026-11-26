# Haunted '90s Halloween 3D [Neblok]

- url: https://www.tradingview.com/script/VCdF0WMP-Haunted-90s-Halloween-3D-Neblok/
- type: indicator
- pine_id: PUB;9da36cb3afa641c8b52d85473e9054c3
- version: 1.0

## Description

Haunted '90s Halloween 3D [Neblok]

A free Halloween chart overlay with a 1990s neon look. It adds a 3D jack-o'-lantern, a witch flying across a full moon, neon candles, and swing-high/low tags.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IT DOES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎃 3D Jack-o'-Lantern (bottom right)
A shaded 3D pumpkin with a carved face, glowing candlelight, and a neon purple rim light. On live charts, the candle glow flickers with each price tick.

🧙 Witch on a Broomstick (top right)
A witch flies left across a glowing full moon, with bats and twinkling stars around her. The art is pinned to the corners of your screen, so it stays in place when you zoom or scroll.

📼 Happy Halloween Banner (top center)
A large retro banner. The line under it shows TREAT ▲ when price is above the prior day's close and TRICK ▼ when it is below, with the percent change.

🕯️ Neon Candles
Recolors candles neon orange (up) and neon purple (down).

👻 BOO! / EEK! Swing Tags
BOO! marks confirmed swing highs. EEK! marks confirmed swing lows.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Add the indicator to any chart. It works on any symbol and timeframe.
2. Open Settings. Everything is grouped by section and can be turned on or off.
3. If the art looks stretched or squished, adjust "Chart Aspect" (see below).
4. To get alerts, create an alert on this indicator and choose "Any alert() function call."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎃 3D Art
- Jack-o'-Lantern / Witch / Moon + Stars / Ground Shadow: show or hide each piece.
- Candle Flicker + Twinkling Stars: animates the glow and stars on live ticks. When the market is closed, the art stays still.
- Detail (High / Fast): High draws the full-resolution art. Fast draws a lighter version. Use Fast if your chart feels slow.
- Pixel Size: makes all the art bigger or smaller.
- Chart Aspect (pane width ÷ height): stops the art from stretching. About 2.0 fits most widescreen layouts. Raise it if the art looks too wide. Lower it if it looks squeezed.
- Jack-o'-Lantern Scale / Witch Scale: resize each piece separately.

🧪 Neon Palette
Change the main colors: pumpkin, lit side, shade, rim light, candle glow, flicker, witch skin, hat/cape, hot pink, moon, stars, bristles, and ground shadow. All colors are solid neon with no gradients.

📼 Banner
- Show Banner: turn the banner on or off.
- Banner Text: type your own message.
- Banner Text Size: Large or Huge.
- Trick-or-Treat Line: shows the percent change from the prior daily close. It uses the confirmed prior close, so the value does not repaint.

🕯️ Neon Candles
- Recolor Candles Neon: turn the recoloring on or off.
- Up Candle / Down Candle: pick your colors.

👻 BOO! / EEK! Pivots
- Pivot Strength: how many bars on each side a high or low must beat to be tagged. The default is 10. Higher values mark only major swings. Lower values mark more minor ones.
- Max Tags on Chart: oldest tags are removed after this limit.
- Tag Size: Normal, Large, or Huge.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPORTANT NOTES ON THE TAGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- A swing is confirmed only after "Pivot Strength" bars have closed after it. With the default of 10, a tag appears 10 bars after the actual high or low and is placed back on that bar.
- Once a tag is placed it does not repaint. However, it is always delayed, so it shows where a swing happened, not where one is about to happen.
- Tags are best used to see market structure (higher highs, lower lows) or to mark levels for support and resistance. They are not entry or exit signals.
- Alerts fire once per bar close when a new BOO! or EEK! is confirmed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TIPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- A dark chart background makes the neon colors stand out most.
- If the witch covers recent candles, add right-side margin to the chart or lower Witch Scale.
- Turn off the art and banner if you only want the neon candles and swing tags.

Happy Halloween from NeBlok Edge 🎃

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This script is for educational and entertainment purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, or other financial instrument.

Swing tags confirm only after the fact and are not trade signals. Past price behavior does not guarantee future results. Trading futures, options, stocks, and crypto involves substantial risk of loss and is not suitable for everyone. Never trade money you cannot afford to lose.

You are solely responsible for your own trading decisions. Do your own research, and consult a licensed financial professional before making any investment decisions. The author and NeBlok Edge accept no liability for any losses from using this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  Haunted '90s Halloween 3D [Neblok]
//  Free script by James — NeBlok Edge
//  Toon-shaded 3D jack-o'-lantern (bottom right) + witch on a broomstick flying
//  LEFT across a glowing full moon (top right). Art is pre-rendered from 3D
//  shapes with lighting from the upper left, then quantized to flat neon bands
//  (no gradients), and drawn as a fine-grain table so it stays pinned to the
//  screen corners at any zoom.
//  Extras: neon candles, BOO!/EEK! swing-pivot tags, Trick-or-Treat banner.
// ═══════════════════════════════════════════════════════════════════════════
indicator("Haunted '90s Halloween 3D [Neblok]", shorttitle = "Halloween '90s [Neblok]", overlay = true, max_labels_count = 500)

// ─── Inputs: Art ────────────────────────────────────────────────────────────
string G_ART = "🎃 3D Art"
bool   showJack   = input.bool(true,  "Jack-o'-Lantern (bottom right)", group = G_ART)
bool   showWitch  = input.bool(true,  "Witch on Broomstick (top right)", group = G_ART)
bool   showMoon   = input.bool(true,  "Full Moon + Stars behind Witch", group = G_ART)
bool   showGround = input.bool(true,  "Ground Shadow under Pumpkin", group = G_ART)
bool   doFlicker  = input.bool(true,  "Candle Flicker + Twinkling Stars (live ticks)", group = G_ART)
string quality    = input.string("High", "Detail", options = ["High", "Fast"], group = G_ART,
      tooltip = "High draws every pixel. Fast draws every 2nd pixel at double size (4x fewer cells) if your chart feels sluggish.")
float  pxSize     = input.float(0.38, "Pixel Size (% of chart height)", minval = 0.05, maxval = 3.0, step = 0.01, group = G_ART)
float  aspect     = input.float(2.0,  "Chart Aspect (pane width ÷ height)", minval = 0.5, maxval = 5.0, step = 0.05, group = G_ART,
      tooltip = "Keeps the art from stretching. Most widescreen layouts are ~2.0. Raise it if the art looks too wide, lower it if it looks squeezed.")
float  jackScale  = input.float(1.0,  "Jack-o'-Lantern Scale", minval = 0.3, maxval = 4.0, step = 0.05, group = G_ART)
float  witchScale = input.float(1.0,  "Witch Scale",           minval = 0.3, maxval = 4.0, step = 0.05, group = G_ART)

// ─── Inputs: Neon Palette (flat colors only) ────────────────────────────────
string G_COL = "🧪 Neon Palette"
color cPumpkin   = input.color(#FF6600, "Pumpkin",      group = G_COL, inline = "p")
color cPumpLight = input.color(#FF9A3C, "Lit Side",     group = G_COL, inline = "p")
color cPumpShade = input.color(#A33A00, "Shade",        group = G_COL, inline = "p")
color cRim       = input.color(#BF00FF, "Rim Light",    group = G_COL, inline = "r")
color cGlow      = input.color(#FFFF00, "Candle Glow",  group = G_COL, inline = "r")
color cGlowAlt   = input.color(#FF9900, "Flicker",      group = G_COL, inline = "r")
color cSkin      = input.color(#39FF14, "Witch Skin",   group = G_COL, inline = "w")
color cPurple    = input.color(#BF00FF, "Hat / Cape",   group = G_COL, inline = "w")
color cPink      = input.color(#FF10F0, "Hot Pink",     group = G_COL, inline = "w")
color cMoon      = input.color(#F5FF3B, "Moon",         group = G_COL, inline = "m")
color cCyan      = input.color(#00FFFF, "Stars",        group = G_COL, inline = "m")
color cBristle   = input.color(#FFD500, "Bristles",     group = G_COL, inline = "m")
color cShadow    = input.color(#3A0060, "Ground Shadow", group = G_COL)

// ─── Inputs: Banner ─────────────────────────────────────────────────────────
string G_BAN = "📼 Banner"
bool   showBanner = input.bool(true, "Show Banner (top center)", group = G_BAN)
string bannerText = input.string("★ HAPPY HALLOWEEN ★", "Banner Text", group = G_BAN)
string bannerSize = input.string("Huge", "Banner Text Size", options = ["Large", "Huge"], group = G_BAN)
bool   showTT     = input.bool(true, "Trick-or-Treat Line (daily % change)", group = G_BAN)

// ─── Inputs: Candles ────────────────────────────────────────────────────────
string G_CAN = "🕯️ Neon Candles"
bool  neonCandles = input.bool(true, "Recolor Candles Neon", group = G_CAN)
color cBull       = input.color(#FF6600, "Up Candle",   group = G_CAN, inline = "c")
color cBear       = input.color(#BF00FF, "Down Candle", group = G_CAN, inline = "c")

// ─── Inputs: BOO!/EEK! Pivots ───────────────────────────────────────────────
string G_BOO = "👻 BOO! / EEK! Pivots"
bool   showBoo  = input.bool(true, "Tag Swing Highs (BOO!) and Lows (EEK!)", group = G_BOO)
int    pivLen   = input.int(10, "Pivot Strength (bars each side)", minval = 2, maxval = 50, group = G_BOO)
int    maxBoo   = input.int(30, "Max Tags on Chart", minval = 1, maxval = 200, group = G_BOO)
string booSize  = input.string("Large", "Tag Size", options = ["Normal", "Large", "Huge"], group = G_BOO)

// ─── Helpers ────────────────────────────────────────────────────────────────
sizeOf(string s) =>
    switch s
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.large

// Sprite character -> flat neon color. Toon bands give the 3D shading.
pxColor(string ch, bool alt) =>
    switch ch
        // pumpkin: deep / shade / base / lit / specular
        "a" => #4A1400
        "b" => cPumpShade
        "O" => cPumpkin
        "c" => cPumpLight
        "d" => #FFD9A8
        "r" => cRim
        // carved face: cut wall / glow / hot core
        "w" => #E03000
        "Y" => alt ? cGlowAlt : cGlow
        "y" => alt ? cGlow : #FFF6B0
        // greens: stem + witch skin
        "g" => #0E6B00
        "G" => cSkin
        "h" => #B6FF9E
        "S" => showGround ? cShadow : color(na)
        // moon: shade / mid / base / lit / halo / ink outline
        "m" => showMoon ? #7E8000 : color(na)
        "n" => showMoon ? #BFC400 : color(na)
        "M" => showMoon ? cMoon : color(na)
        "N" => showMoon ? #FFFFC2 : color(na)
        "H" => showMoon ? #8F9400 : color(na)
        "k" => showMoon ? #000000 : color(na)
        "C" => showMoon ? (alt ? cPink : cCyan) : color(na)
        // witch: purples, dress, pinks, broom
        "p" => #4A006E
        "P" => cPurple
        "Q" => #E07BFF
        "K" => #14001F
        "Z" => cPink
        "z" => #9E0094
        "B" => cBristle
        "e" => #FFFF00
        "j" => #6E2A00
        "J" => #B35A1F
        "l" => #E08A4A
        => color(na)

// Paint a sprite into a table (every `step`-th pixel); remember flicker pixels
drawSprite(table t, array<string> rows, float sc, int step, string flickChars, array<int> fx, array<int> fy, array<string> fc) =>
    int   w  = str.length(rows.get(0))
    float ph = pxSize * sc * step
    float pw = ph / aspect
    int   ty = 0
    for y = 0 to rows.size() - 1 by step
        string r  = rows.get(y)
        int    tx = 0
        for x = 0 to w - 1 by step
            string ch = str.substring(r, x, x + 1)
            table.cell(t, tx, ty, "", width = pw, height = ph, bgcolor = pxColor(ch, false))
            if ch != "." and str.contains(flickChars, ch)
                fx.push(tx)
                fy.push(ty)
                fc.push(ch)
            tx += 1
        ty += 1
    ty

// Swap flicker pixels between their two neon states
flickerSprite(table t, bool alt, array<int> fx, array<int> fy, array<string> fc) =>
    if fx.size() > 0
        for i = 0 to fx.size() - 1
            table.cell_set_bgcolor(t, fx.get(i), fy.get(i), pxColor(fc.get(i), alt))
    fx.size()

// ─── Art (pre-rendered 3D, quantized to flat neon) ──────────────────────────
var array<string> JACK = array.from(
      "....................................................",
      "....................................................",
      "..............................gg....................",
      "............................gggg....................",
      "...........................gggg.....................",
      "...........................ggg......................",
      "..........................Ggg.......................",
      "..........................Ggg.......................",
      ".........................GGgg.......................",
      ".........................GGgg.......................",
      "...............cOOOO.ccchGGgOOO.cOOOO...............",
      "........cccOOcccccOOcccchGGgOOOOcccOOOOOcOOO........",
      "......ccccccccccccccdddcccccOOOOccccOOOOccOOO.......",
      ".....ccddcccdddccccdddddccccOOOOrcccOOOOrcOOOOr.....",
      "....ccdddccddddccccddddcccccOOOOOcccOOOOOrcOOOrr....",
      "....cddddcdddddcccdwdddcccccOOOOwcccOOOOOOOOOOOrr...",
      "...ccdddccddddccccwwYdccccccOOOwYYccOOOOOOOOOOOrr...",
      "...ccdddccddddccccwYYdccccccOOOwYYccOOOOOObOOOObrr..",
      "..cccddcccdddccccwYyyYcccccOOOwYYyYcOOOOOObOOOOObr..",
      "..ccccccccccccccwwYyyYcccccOOOwYyyyYOOOOOObOOOOObr..",
      ".OccccccccccccccwYyyyyYcccOOOwYYyyyYOOOOOObbOOObbrr.",
      ".OcccccccccccccwYYYYYYYcccOOOwYYYYYYYOOOOObbOOObbrr.",
      ".OccccccccccccwwYYYYYYYYcOOOwYYYYYYYYYOOOObbOOObbbr.",
      ".OccccccccccccwYYYYYYYYYOOOOwYYYYYYYYYOOOObbOOObbbr.",
      ".OcccccccccccccOOOcccccOOOwOOOOOObOOOOOOObbbOOObbbr.",
      ".OOcccccccccccOOOOccccOOOwyOOOOOObOOOOOOObbbOOObbbr.",
      ".OOOcccOOcccOOOOOOcccOOOwyyyOOOOObOOOOOOObbbOObbbbr.",
      ".OOOOOOOOOOOOOOOOOOOOOOwwYYYYOOObbOOOOOObbbbOObbbar.",
      ".OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOObbOOOOOwbbbbOObbbar.",
      ".OOOOOOOOOOOOYOOOOOOOOOOOOOOOOObbbOOOOwbbbbaObbbbrr.",
      ".OOOOOOOOOOOOYYOOOOwOOOOOOOOOObbwwOOwwYbbbbaObbbarr.",
      "..OOOOOOOOOOOOYYYYYYYOwwYyyyYybwYYYYYYYbbbaObbbbar..",
      "..OOOOOOOOOOOOYYYYYYYywyyyyyyyywYYYYYYbbbbabbbbaar..",
      "..bOOOOOOOOOOOYYYYYYYYyyyyyyyyyYYYYYYYbbbaabbbbarr..",
      "...OOOOOOOOOOOOYYYYYYYYYYYYYYYYYYYYYYbbbaaabbbaar...",
      "...bbOOOOOOOOOOOYYYYYYYYYYYYYYYYYYYYbbbaaabbbaarr...",
      "....bbbbbbbbbbbbbbbOOYYYYYYYYYYaabbbbbaaarbbaarr....",
      ".....bbbbbbbbbbbbbbbbbYYYYYYYYaaabbbbaaarbbaaar.....",
      "......bbbbbbbbbbbbabbbbbbbbbaaaarbbaaaaaraaaaa......",
      ".......aaaaaaaaaaaaabbbbbbaaaaaaaaaaaaaaaaaaa.......",
      "..........aS.SaaaaaaaaaaaaaaaaaaaaaaaaSSSS..........",
      "....SSSSSSSSSSSSSSSSSSSaaaaaaSSSSSSSSSSSSSSSSSSSSS..",
      "....SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS...",
      "....................SSSSSSSSSSSSSS..................")

// Witch faces and flies LEFT: hooked nose + broom handle point left, cape and bristles trail right
var array<string> WITCH = array.from(
      "................................................................................",
      ".............................................ppppppkHHHHHHH.....................",
      "....C.....................................pppppppkkMMMMMMHHHHH...............C..",
      "....CC.............C.....................ppppppkkMMMMMMMMMMMHHHH...........CCCC.",
      "..CCCCC............CC...................PpppppkMMMMMMMMMMMMMMMnHH...........CC..",
      "...CCC............CCC..................PPppppkNNNNMMMMMMMMMMMMMnHHH..........C..",
      "....C..............C..................PPPpppkNNNNNNMMMMMMMMMMMMnnnHH............",
      "....................................HkPPPpppkNNNNNNNMMMMMMMMMMMMnnnHH...........",
      "....................................kPPPPpppkNNNNNNNMMMMMMMMMMMMnnnnHH..........",
      "...................................HkPPPPppkNNNNNNNNMMMMMMMMMMMMMnnnnH..........",
      "..................................HkQPPPPppkNNNNNNNNMMMMMMMMMMMMMnnnnmH.........",
      ".................................HHkQPPPPppkNNNNNNNNMMMMMMNNNMMMMnnnnmHH........",
      ".................................HMkZZBBZZZkNnnnNNNNMMMMMNNNNNMMMnnnnnmH........",
      "................................kkkQZZBBZZZkkkkkNNNMMMMMMNNnnnnMMnnnnnmHH.......",
      "...ZZZ.......ZZ..............PPPPPPPPPPPPPPPPPPPkNNMMMMMMNnnnnnMMnnnnnmmH.......",
      "..ZZZZZZZZZ.ZZZZZ............pppppppppppppppppppkNMMMMMMMNnnnnnMMnnnnnmmHH......",
      "...ZZZZZZZZZZZZ................kpkpppppppppZZZkkNMMMMMMMMMNnnnMMMnnnnnmmmH......",
      "....Z.ZZZZZZ.ZZ................HkMkkGeGGgggZZZZZkkkMMMMMMMMMMMMMnnnnnnmmmH......",
      ".......Z..Z....................HMkkGGeGGgggZZZZZZZZkkMMMMMMMMMMMnnnnnnmmmHH.....",
      "...............................kkGGGGGGGgggZZZZZZZZZZkkkMMMMMMMnnnnnnnmmmHH.....",
      "..............................kGGGGGGGGGgggZZZZZZZZZZZZZkMMMMMMnnnnnnmmmmmH.....",
      ".............................GGGGGGGGGGGgggzzzzzzzzzzkkkMMMMMMnnnNNnnmmmmmH.....",
      "............................GGGGkkkGGGGGggzzzzzzzzzzzzkMMMMMMMnnNnnnnmmmmmH.....",
      "..............................kkMMkGGGGGgkkzzzzzzzzzzzzkMMMMMnnnnnnnmmmmmmH.....",
      "..............................HHMkGGGGGkkQQQQQzzzzQQQkkkMMMMnnnnnnnnmmmmmmH.....",
      "..............................HHkGGGkkkkkPQQQQQzzzQQQQQQkkknnnnnnnnmmmmmmHH.....",
      "...............................HMkkkMMkPPKKQQQQQzQQQQQQQQQQkkknnnnmmmmmmmHH.....",
      "...............................HnMMMMkPKKKKKPPPPPPPPPQQQQQQQQQkknnmmmmmmmH......",
      "...............................HnMMMkPKKKKKKPPPPPPPPPPPPPQQQQQQQkkkmmmmmmH......",
      "...............................HHnMMkPKKKKKKPPPPPPPPPPPPPPPPQQQQQQQkkmmmmH......",
      "................................HnnMkPKKKKKKPPPPPPPPPPPPPPPPPPPQQQQQQkkmHH......",
      "................................HHnkPKKKKKKKKPPPPPPPPPPPPPPPPPPPPPQQQQQkk.......",
      ".................................HkPKKKKKKKKKPPPPPPPPPPPPPPPPPPPPPPPPPQQQ.......",
      ".................................kPKKKKKKKKKKPPPPPPPpppppppppppppPPPPPPPPPP.....",
      ".................................PKKKKKKKKKKKPPPPPppppppppppppPPPpppPPPPPPBeB...",
      "................................PKPkPKKKKKKKPkPPPppppppppPPPPkkkkkBBeeeeeeeBBB..",
      "..............llllll..........GGKP.HkPKKKKKKPkkPPPppppPPPkkkkmkkeeeeeeeBBBBBBB..",
      "..............JJJJJJJllllllllGGGG...kPKKKKKPknnkPPppPPkkkkkkkkeeeBBBBBBBBBBBBB..",
      "................jjjjjjjJJJJJJJGGGllllKKKKKKPkkkkkkPPkkmmkZZZZeBBBBBBBBBBBBBBBB..",
      "..........................jjjjjjjJJJJKKKKKKPllllllkkkkkkkZZZZBBBBBBBBBBBBBBBBBB.",
      ".....................................PKKKKKKJJJJJJJJlllllZZZZBBBBBBBBBBBBBBBBBB.",
      ".....................................PKKKKPkkkkkjjjjjJJJJZZZZBBBBBBBBBBBBBBBBBB.",
      ".......................................ZKKPkHHmmkkkkkkkkkZZZZBBBBBBBBBBBBBBBBBB.",
      ".......................................ZZZ...HHHHHHHHHHHHkZZZBBBBBBBBBBBBBBBBBB.",
      "......................................PKZZ........HHHHHH..ZZZBBBBBBBBBBBBBBBBBB.",
      "......................................PKP....................BBBBBBBBBBBBBBBBB..",
      "......................................ZKP.......................BBBBBBBBBBBBBB..",
      ".....................................ZZZZ.........................BBBBBBBBBBBB..",
      ".....C...............................PKZ.................................BBBBB..",
      "....CC.............................PPKKP........................................",
      "...CCCC...........................PKKKKP.....................................C..",
      "....CC....................C.....PPKKKKP.....................................CCCC",
      ".....C...................CC.....PKKKP.......................................CCC.",
      ".........................CCC.................................................C..",
      "..........................C.....................................................",
      "................................................................................")

int STEP    = quality == "High" ? 1 : 2
int JACK_W  = str.length(JACK.get(0))
int WITCH_W = str.length(WITCH.get(0))
int jCols   = int(math.ceil(JACK_W / STEP))
int jRows   = int(math.ceil(JACK.size() / STEP))
int wCols   = int(math.ceil(WITCH_W / STEP))
int wRows   = int(math.ceil(WITCH.size() / STEP))

var table tJack  = table.new(position.bottom_right, jCols, jRows, frame_width = 0, border_width = 0)
var table tWitch = table.new(position.top_right,    wCols, wRows, frame_width = 0, border_width = 0)
var table tBan   = table.new(position.top_center, 1, 2, bgcolor = #0A0014, frame_color = cPurple, frame_width = 4, border_color = cPumpkin, border_width = 2)

var array<int>    jfx = array.new<int>()
var array<int>    jfy = array.new<int>()
var array<string> jfc = array.new<string>()
var array<int>    wfx = array.new<int>()
var array<int>    wfy = array.new<int>()
var array<string> wfc = array.new<string>()
var bool built = false

// ─── Trick-or-Treat: % change vs prior daily close (non-repainting) ─────────
float dPrev  = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)
float dayChg = na(dPrev) or dPrev == 0 ? na : (close - dPrev) / dPrev * 100

// ─── Draw on the last bar ───────────────────────────────────────────────────
if barstate.islast
    if not built
        if showJack
            drawSprite(tJack, JACK, jackScale, STEP, "Yy", jfx, jfy, jfc)
        if showWitch
            drawSprite(tWitch, WITCH, witchScale, STEP, "C", wfx, wfy, wfc)
        built := true

    if doFlicker
        bool alt = math.floor(timenow / 450) % 2 == 1
        flickerSprite(tJack,  alt,     jfx, jfy, jfc)
        flickerSprite(tWitch, not alt, wfx, wfy, wfc)

    if showBanner
        table.cell(tBan, 0, 0, bannerText, text_color = cPumpkin, text_size = sizeOf(bannerSize),
                   text_font_family = font.family_monospace, text_formatting = text.format_bold, bgcolor = #0A0014)
        if showTT and not na(dayChg)
            bool   treat = dayChg >= 0
            string tt    = (treat ? "TREAT ▲ +" : "TRICK ▼ ") + str.tostring(dayChg, "0.00") + "%"
            table.cell(tBan, 0, 1, tt, text_color = #000000, text_size = size.large,
                       text_font_family = font.family_monospace, text_formatting = text.format_bold,
                       bgcolor = treat ? cSkin : cPink)

// ─── Neon candles ───────────────────────────────────────────────────────────
color candleCol = neonCandles ? (close >= open ? cBull : cBear) : na
plotcandle(open, high, low, close, "Neon Candles", color = candleCol, wickcolor = candleCol, bordercolor = candleCol)

// ─── BOO! / EEK! swing tags ─────────────────────────────────────────────────
var array<label> tags = array.new<label>()
float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low,  pivLen, pivLen)

if showBoo and not na(ph)
    tags.push(label.new(bar_index - pivLen, ph, "BOO!", style = label.style_label_down, color = cPurple,
                         textcolor = #FFFFFF, size = sizeOf(booSize), text_font_family = font.family_monospace,
                         text_formatting = text.format_bold))
if showBoo and not na(pl)
    tags.push(label.new(bar_index - pivLen, pl, "EEK!", style = label.style_label_up, color = cSkin,
                         textcolor = #000000, size = sizeOf(booSize), text_font_family = font.family_monospace,
                         text_formatting = text.format_bold))
while tags.size() > maxBoo
    tags.shift().delete()

// ─── Alerts ─────────────────────────────────────────────────────────────────
if showBoo and not na(ph)
    alert("BOO! Swing high confirmed at " + str.tostring(ph, format.mintick) + " on " + syminfo.ticker, alert.freq_once_per_bar_close)
if showBoo and not na(pl)
    alert("EEK! Swing low confirmed at " + str.tostring(pl, format.mintick) + " on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
