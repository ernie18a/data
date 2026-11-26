# Chartling

- url: https://www.tradingview.com/script/Is9AoRJM-Chartling/
- type: indicator
- pine_id: PUB;83ec3311d1634f109b15fa3801263a08
- version: 1.0

## Description

[b]CHARTLING[/b]

[i]A tiny market-aware companion that lives on your chart.[/i]

Every day, a new Chartling can hatch on your chart with its own permanent identity: appearance, rarity, name, personality, traits and quirks. As the market moves, it reads those conditions, reacts to them, and gets on with its own little life. It might study the chart, grab a coffee, read, exercise, nap, or watch the market through a telescope.

[b]Chartling experiences the market with you.[/b]

[b]DAILY HATCH[/b]
At a configurable hatch time and timezone, each day brings a new deterministic Chartling that grows through a small lifecycle:

[b]EGG → HATCH → YOUNG → ADULT[/b]

The HUD shows its current age, and its look develops as it grows.

[b]THE CATALOGUE[/b]
Chartling contains a deterministic catalogue of [b]999,999,999[/b] creatures, IDs [b]#000000001[/b] to [b]#999999999[/b].

Every valid ID permanently maps to one canonical Chartling: a unique three-part name, rarity, palette, head, tail, markings, core, personality, dominant traits and two quirks.

Enter the same ID again and you get the same canonical Chartling.

[b]The ID is its permanent genetic address.[/b]

[b]RARITY[/b]
Six deterministic tiers, shown in the HUD in each tier's color:

[list]
[*][b]COMMON[/b] — 599,999,999
[*][b]UNCOMMON[/b] — 250,000,000
[*][b]RARE[/b] — 100,000,000
[*][b]VERY RARE[/b] — 40,000,000
[*][b]MYSTICAL[/b] — 9,000,000
[*][b]LEGENDARY[/b] — 1,000,000
[/list]

Higher tiers unlock rarer cosmetic gene pools, up to the Golden palette and Halo core at Legendary.

[b]PERSONALITY & QUIRKS[/b]
Traits like curiosity, laziness, confidence and drama combine into archetypes such as QUANT, GREMLIN, LOAF, HOTSHOT and SCOUT.

Each Chartling also carries two permanent quirks — COFFEE, NAPPER, WATCHER, FIT and more — that influence its behavior, so a coffee-lover and a napper can live noticeably different days.

[b]MARKET SENSE[/b]
Chartling reads the market through a [b]Flow + Wave[/b] system and wears that information:

[list]
[*][b]Flow becomes belly color[/b] — reflecting direction and strength around a smoothed market reference.
[*][b]Wave becomes a small flag[/b] — green when price is above the Wave, red when below, and no flag when price overlaps it.
[/list]

A configurable Trend Timeframe can drive the Wave.

When it is higher than the chart timeframe, Chartling uses confirmed higher-timeframe data. When it is equal to or lower, Chartling uses the chart timeframe.

Repeated Flow changes, sustained trends and choppy stretches feed a small market memory that shifts its mood over time.

[b]TRADING WISDOM[/b]
On by default: [b]500 trading-psychology reflections[/b] covering risk, patience, discipline, FOMO, drawdowns and more.

A reflection is selected deterministically from each Chartling's ID.

Turn Trading Wisdom off for the more whimsical [b]Chartling Lore[/b].

Either way, the creature's canonical identity stays the same.

[b]COLLECTING[/b]
Add IDs to your [b]Keeper List[/b] to remember favorites.

Use [b]Show Chartling #[/b] to summon any catalogue ID. A summoned Chartling keeps the current day's age and lifecycle while displaying that ID's permanent identity.

A private [b]Trainer Code[/b] personalizes your daily hatch sequence. Using the same Trainer Code with the same market, hatch settings and day reproduces the same hatch.

[b]HUD & LAYOUT[/b]
A five-line identity card shows:

[list]
[*]Name / rarity
[*]ID / age
[*]Personality / traits / quirks
[*]DNA / collection status
[*]Trading Wisdom or Chartling Lore
[/list]

The HUD adapts to light and dark chart themes, while the Chartling's name, ID and DNA retain its rarity color.

Chartling and the HUD can be positioned independently across eight chart locations.

[b]Static Chartling[/b] pauses animation and Market Sense for a quieter collectible view.

[b]HOW TO USE[/b]

[list]
[*]Add Chartling and set your hatch time and timezone.
[*]Optionally enter a Trainer Code for a repeatable daily hatch sequence.
[*]Let it hatch and watch personality and market conditions shape its behavior.
[*]Keep the ones you like and revisit any ID with Show Chartling #.
[/list]

Chartling is an informational, educational and entertainment-oriented market companion. Flow, Wave, volatility, volume and range drive its visuals and behavior; Trading Wisdom offers general reflection.

Market interpretation, trade selection and risk decisions remain with you.

[b]Every chart has a story. Every day has a new Chartling.[/b]
[i]Chartling experiences the market with you.[/i]

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright © 2026 Ben Deharde.
//
// Chartling v1.0.0
// Original concept, character system, canonical catalogue and Pine implementation by Ben Deharde.
// Chartling is a market-aware chart companion. It is not a trading signal, recommendation or strategy.
//
// Canonical DNA contract — CL-DNA-1
// One valid 9-digit Chartling ID maps to one permanent canonical DNA/personality.
// Compatible releases should preserve that mapping. Market reactions and lifecycle state may vary independently.
//
// Canonical naming contract — CL-NAME-1
// Every valid 9-digit Chartling ID maps one-to-one to one permanent three-part canonical name.
// Compatible releases should preserve that mapping.
//
// Canonical lore contract — CL-LORE-1
// Every valid Chartling ID maps deterministically to one permanent sentence in each supported lore style.
// Lore is descriptive flavor, is not part of Chartling's unique identity and does not provide trading signals.
// Chartling Lore contains 1,000,000 deterministic combinations; Trading Wisdom contains 500 curated sentences.
//
// Maintainer note:
// Preserve attribution when adapting or republishing this source.
//
// MPL-2.0 licenses the source code. It does not grant trademark rights in contributor names, marks or logos.

//@version=6
indicator("Chartling", "Chartling", overlay = true)

string groupChartling = "Chartling"
string groupSense = "Market Sense"

int pixelSize = input.int(1, "Size", minval = 1, maxval = 5, group = groupChartling)
bool showHUD = input.bool(true, "Info HUD", group = groupChartling)
bool tradingWisdom = input.bool(true, "Trading Wisdom", tooltip = "On: one of 500 curated trading psychology reflections. Off: original Chartling lore. Both styles are deterministic for each Chartling ID.", group = groupChartling)
string chartlingPositionInput = input.string("Bottom Left", "Chartling Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip = "Places Chartling on one of the eight outer chart positions.", group = groupChartling)
string hudPositionInput = input.string("Bottom Center", "HUD Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip = "Places the HUD independently. If the same position as Chartling is selected, the HUD automatically uses a safe fallback position.", group = groupChartling)

f_tablePosition(string p) =>
    p == "Top Left" ? position.top_left : p == "Top Center" ? position.top_center : p == "Top Right" ? position.top_right : p == "Middle Left" ? position.middle_left : p == "Middle Right" ? position.middle_right : p == "Bottom Left" ? position.bottom_left : p == "Bottom Right" ? position.bottom_right : position.bottom_center

string resolvedHudPositionInput = hudPositionInput == chartlingPositionInput ? (chartlingPositionInput == "Bottom Center" ? "Bottom Right" : "Bottom Center") : hudPositionInput
string chartlingTablePosition = f_tablePosition(chartlingPositionInput)
string hudTablePosition = f_tablePosition(resolvedHudPositionInput)
bool staticChartling = input.bool(false, "Static Chartling", tooltip = "Freezes Chartling as a static picture and disables Market Sense, animation, reactions and behavior calculations. Only the daily hatch/lifecycle stage and HUD can change.", group = groupChartling)
string trainerCode = input.string("", "Trainer Code", tooltip = "Choose a personal, memorable code. It becomes part of your daily hatch seed. Using the same code on another device reproduces your hatches. It is not displayed on the chart.", group = groupChartling, confirm = true)
string keeperList = input.text_area("", "Keeper List", tooltip = "Your collection. One Chartling number per line, for example #483921746. Adding a number here does not change today's hatch.", group = groupChartling)
string showChartling = input.string("", "Show Chartling #", tooltip = "Leave empty for today's hatch. Enter any Chartling number from 1 to 999999999 to show that canonical Chartling. The summoned Chartling keeps the normal age and lifecycle from your current hatch time. Clear the field to return to today's hatch.", group = groupChartling)
int hatchHour = input.int(8, "Hatch Hour", minval = 0, maxval = 23, tooltip = "Hour when your new daily Chartling appears.", group = groupChartling, inline = "hatch")
int hatchMinute = input.int(0, "Minute", minval = 0, maxval = 59, tooltip = "Minute when your new daily Chartling appears.", group = groupChartling, inline = "hatch")
string hatchTimezone = input.string("Europe/Berlin", "Hatch Timezone", tooltip = "IANA time zone used for your hatch clock, for example Europe/Berlin, America/New_York, Asia/Tokyo or Etc/UTC.", group = groupChartling)

bool showGround = true
int brainTickSeconds = 3
float liveliness = 1.0
float quirkiness = 1.0
bool allowLongNaps = true
bool enableFood = true
float foodVolume = 1.45
float foodRange = 1.15
bool enableShock = true
float shockATR = 1.75
float shockVolume = 2.00
bool showFlowBelly = true
bool showWaveFlag = true
string trendTF = input.timeframe("5", "Trend Timeframe", tooltip = "Higher selections use confirmed higher-timeframe Wave data. Equal or lower selections use the chart timeframe.", group = groupSense)
int preLen = input.int(17, "Wave Pre", minval = 1, group = groupSense, inline = "pre")
string preType = input.string("EMA", "", options = ["SMA", "EMA", "HMA"], group = groupSense, inline = "pre")
int postLen = input.int(150, "Wave Post", minval = 1, group = groupSense, inline = "post")
string postType = input.string("HMA", "", options = ["SMA", "EMA", "HMA"], group = groupSense, inline = "post")
int flowLen = input.int(200, "Flow", minval = 1, group = groupSense, inline = "flow")
string flowType = input.string("EMA", "", options = ["EMA", "SMA", "WMA", "HMA", "RMA"], group = groupSense, inline = "flow")

f_clamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))
f_clampi(int v, int lo, int hi) => math.max(lo, math.min(hi, v))
f_rand(float seed) => math.abs(math.sin(seed * 12.9898 + 78.233))
f_dnaRand(float seed) =>
    float x = math.sin(seed * 12.9898 + 78.233) * 43758.5453
    x - math.floor(x)
f_repeatPenalty(int candidate, int last1, int last2, int last3) => candidate == last1 ? 0.18 : candidate == last2 ? 0.45 : candidate == last3 ? 0.72 : 1.0

f_symbolSeed(string s) =>
    string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789:_!@#$%&*+-./ "
    int n = str.length(s)
    float h = 216613626.0
    if n > 0
        int maxI = math.min(n - 1, 63)
        for i = 0 to maxI
            string ch = str.substring(s, i, i + 1)
            int p = str.pos(alphabet, ch)
            float v = na(p) or p < 0 ? 97.0 : float(p + 1)
            h := h * 131.0 + v * 17.0 + float(i + 1) * 29.0
            h := h - math.floor(h / 2147483647.0) * 2147483647.0
    h

f_validHatchId(int id) => id >= 1 and id <= 999999999

f_idText(int id) =>
    string s = str.tostring(id)
    int n = str.length(s)
    string z = n == 1 ? "00000000" : n == 2 ? "0000000" : n == 3 ? "000000" : n == 4 ? "00000" : n == 5 ? "0000" : n == 6 ? "000" : n == 7 ? "00" : n == 8 ? "0" : ""
    z + s

f_parseHatchId(string raw) =>
    string cleaned = str.trim(raw)
    int n0 = str.length(cleaned)
    if n0 > 0 and str.substring(cleaned, 0, 1) == "#"
        cleaned := str.substring(cleaned, 1, n0)
    int n = str.length(cleaned)
    bool digitsOnly = n > 0
    if digitsOnly
        for i = 0 to n - 1
            string ch = str.substring(cleaned, i, i + 1)
            if str.pos("0123456789", ch) < 0
                digitsOnly := false
    float parsed = digitsOnly ? str.tonumber(cleaned) : na
    int id = not na(parsed) ? int(parsed) : 0
    f_validHatchId(id) ? id : 0

f_parseKeeperList(string codes) =>
    array<int> ids = array.new_int()
    string cleaned = str.replace_all(str.replace_all(codes, ",", "\n"), ";", "\n")
    array<string> lines = str.split(cleaned, "\n")
    int count = array.size(lines)
    if count > 0
        for i = 0 to count - 1
            int id = f_parseHatchId(array.get(lines, i))
            if f_validHatchId(id)
                array.push(ids, id)
    ids

f_keeperContains(array<int> ids, int targetId) =>
    bool found = false
    int count = array.size(ids)
    if count > 0 and f_validHatchId(targetId)
        for i = 0 to count - 1
            if array.get(ids, i) == targetId
                found := true
    found

var array<int> keeperIds = f_parseKeeperList(keeperList)

f_birthPalette(int p) =>
    switch p
        0 => [color.rgb(122, 108, 229), color.rgb(163, 149, 249), color.rgb(74, 63, 157), color.rgb(51, 44, 110), color.rgb(191, 180, 255), color.rgb(226, 215, 255), color.rgb(79, 225, 255)]
        1 => [color.rgb(47, 155, 156), color.rgb(91, 201, 195), color.rgb(30, 104, 111), color.rgb(20, 72, 79), color.rgb(143, 232, 218), color.rgb(215, 246, 237), color.rgb(255, 201, 87)]
        2 => [color.rgb(215, 99, 103), color.rgb(244, 145, 135), color.rgb(145, 58, 72), color.rgb(94, 39, 53), color.rgb(255, 187, 174), color.rgb(255, 226, 206), color.rgb(91, 221, 255)]
        3 => [color.rgb(109, 153, 74), color.rgb(158, 194, 105), color.rgb(70, 104, 50), color.rgb(46, 72, 37), color.rgb(196, 218, 134), color.rgb(236, 235, 194), color.rgb(255, 176, 74)]
        4 => [color.rgb(67, 127, 210), color.rgb(111, 171, 238), color.rgb(43, 82, 145), color.rgb(30, 56, 102), color.rgb(164, 203, 255), color.rgb(224, 239, 255), color.rgb(103, 255, 211)]
        5 => [color.rgb(185, 93, 160), color.rgb(221, 139, 197), color.rgb(123, 60, 108), color.rgb(83, 40, 75), color.rgb(242, 178, 222), color.rgb(253, 224, 244), color.rgb(104, 232, 255)]
        6 => [color.rgb(206, 145, 55), color.rgb(238, 184, 91), color.rgb(137, 92, 34), color.rgb(91, 61, 26), color.rgb(255, 213, 133), color.rgb(255, 239, 207), color.rgb(102, 222, 204)]
        7 => [color.rgb(77, 176, 139), color.rgb(123, 216, 176), color.rgb(48, 116, 92), color.rgb(31, 79, 63), color.rgb(167, 237, 202), color.rgb(223, 250, 235), color.rgb(255, 196, 83)]
        8 => [color.rgb(78, 83, 181), color.rgb(125, 132, 226), color.rgb(48, 53, 123), color.rgb(34, 37, 86), color.rgb(163, 169, 247), color.rgb(224, 226, 255), color.rgb(76, 236, 255)]
        9 => [color.rgb(176, 91, 57), color.rgb(217, 132, 91), color.rgb(116, 57, 39), color.rgb(77, 39, 30), color.rgb(241, 167, 124), color.rgb(252, 222, 194), color.rgb(91, 214, 237)]
        10 => [color.rgb(148, 113, 192), color.rgb(189, 155, 228), color.rgb(96, 72, 133), color.rgb(65, 49, 92), color.rgb(217, 189, 248), color.rgb(241, 228, 255), color.rgb(255, 205, 79)]
        11 => [color.rgb(89, 116, 136), color.rgb(136, 164, 182), color.rgb(58, 76, 91), color.rgb(40, 53, 65), color.rgb(175, 196, 209), color.rgb(229, 239, 244), color.rgb(95, 224, 255)]
        12 => [color.rgb(204, 118, 151), color.rgb(239, 165, 190), color.rgb(139, 73, 101), color.rgb(92, 47, 69), color.rgb(255, 197, 214), color.rgb(255, 228, 236), color.rgb(105, 244, 211)]
        13 => [color.rgb(112, 163, 191), color.rgb(165, 207, 228), color.rgb(67, 105, 132), color.rgb(43, 70, 91), color.rgb(196, 229, 244), color.rgb(239, 249, 255), color.rgb(117, 233, 255)]
        14 => [color.rgb(37, 42, 78), color.rgb(82, 91, 145), color.rgb(23, 27, 52), color.rgb(13, 16, 33), color.rgb(109, 126, 207), color.rgb(189, 204, 247), color.rgb(73, 234, 255)]
        15 => [color.rgb(55, 190, 111), color.rgb(109, 241, 155), color.rgb(28, 117, 68), color.rgb(17, 75, 44), color.rgb(174, 255, 86), color.rgb(226, 255, 191), color.rgb(255, 74, 194)]
        16 => [color.rgb(51, 53, 60), color.rgb(103, 107, 119), color.rgb(29, 31, 36), color.rgb(14, 15, 19), color.rgb(145, 149, 163), color.rgb(218, 221, 230), color.rgb(255, 77, 88)]
        17 => [color.rgb(181, 217, 226), color.rgb(224, 245, 249), color.rgb(112, 157, 171), color.rgb(73, 111, 125), color.rgb(239, 251, 255), color.rgb(255, 255, 255), color.rgb(118, 222, 255)]
        18 => [color.rgb(75, 151, 156), color.rgb(111, 213, 190), color.rgb(72, 75, 142), color.rgb(40, 43, 94), color.rgb(214, 111, 210), color.rgb(241, 201, 250), color.rgb(113, 255, 185)]
        19 => [color.rgb(181, 83, 48), color.rgb(236, 133, 67), color.rgb(111, 45, 35), color.rgb(68, 27, 27), color.rgb(255, 188, 76), color.rgb(255, 231, 167), color.rgb(255, 224, 73)]
        20 => [color.rgb(55, 42, 86), color.rgb(105, 79, 144), color.rgb(29, 22, 52), color.rgb(14, 11, 29), color.rgb(174, 148, 212), color.rgb(228, 217, 244), color.rgb(255, 137, 69)]
        21 => [color.rgb(221, 209, 199), color.rgb(248, 239, 231), color.rgb(158, 143, 136), color.rgb(105, 94, 91), color.rgb(255, 211, 221), color.rgb(255, 248, 244), color.rgb(91, 233, 226)]
        22 => [color.rgb(214, 163, 45), color.rgb(251, 211, 90), color.rgb(145, 99, 27), color.rgb(91, 58, 17), color.rgb(255, 232, 141), color.rgb(255, 247, 207), color.rgb(247, 252, 255)]
        => [color.rgb(30, 23, 44), color.rgb(74, 54, 103), color.rgb(16, 12, 25), color.rgb(6, 5, 11), color.rgb(177, 61, 210), color.rgb(224, 164, 245), color.rgb(74, 229, 255)]

f_paletteName(int p) =>
    switch p
        0 => "VIOLET"
        1 => "LAGOON"
        2 => "CORAL"
        3 => "MOSS"
        4 => "AZURE"
        5 => "ORCHID"
        6 => "AMBER"
        7 => "MINT"
        8 => "INDIGO"
        9 => "EMBER"
        10 => "LILAC"
        11 => "SLATE"
        12 => "ROSE"
        13 => "ARCTIC"
        14 => "MIDNIGHT"
        15 => "NEON"
        16 => "OBSIDIAN"
        17 => "FROST"
        18 => "AURORA"
        19 => "SOLAR"
        20 => "ECLIPSE"
        21 => "PEARL"
        22 => "GOLDEN"
        => "VOID"

f_loreManner10(int i) =>
    switch i
        0 => "Quietly"
        1 => "Carefully"
        2 => "Patiently"
        3 => "Curiously"
        4 => "Secretly"
        5 => "Proudly"
        6 => "Sleepily"
        7 => "Boldly"
        8 => "Happily"
        => "Solemnly"

f_loreVerb10(int i) =>
    switch i
        0 => "watches"
        1 => "counts"
        2 => "collects"
        3 => "studies"
        4 => "guards"
        5 => "follows"
        6 => "chases"
        7 => "measures"
        8 => "remembers"
        => "names"

f_loreAction100(int i) =>
    int a = int(math.floor(float(i) / 10.0))
    int b = i % 10
    f_loreManner10(a) + " " + f_loreVerb10(b)

f_loreShade10(int i) =>
    switch i
        0 => "distant"
        1 => "tiny"
        2 => "quiet"
        3 => "strange"
        4 => "hidden"
        5 => "crooked"
        6 => "restless"
        7 => "forgotten"
        8 => "wandering"
        => "faint"

f_loreThing10(int i) =>
    switch i
        0 => "lights"
        1 => "stars"
        2 => "patterns"
        3 => "shadows"
        4 => "signals"
        5 => "echoes"
        6 => "rhythms"
        7 => "clouds"
        8 => "sparks"
        => "footsteps"

f_loreObject100(int i) =>
    int a = int(math.floor(float(i) / 10.0))
    int b = i % 10
    f_loreShade10(a) + " " + f_loreThing10(b)

f_loreScene10(int i) =>
    switch i
        0 => "at dawn"
        1 => "near midnight"
        2 => "before breakfast"
        3 => "after sunset"
        4 => "during the quiet hour"
        5 => "under dim light"
        6 => "by the open window"
        7 => "beyond the old gate"
        8 => "between two thoughts"
        => "before the next storm"

f_loreTail10(int i) =>
    switch i
        0 => "."
        1 => " again."
        2 => " for a moment."
        3 => " without warning."
        4 => " when bored."
        5 => " when curious."
        6 => " on purpose."
        7 => " for no clear reason."
        8 => " until distracted."
        => " then moves on."

f_loreEnding100(int i) =>
    int a = int(math.floor(float(i) / 10.0))
    int b = i % 10
    f_loreScene10(a) + f_loreTail10(b)

f_loreSentence(int id) =>
    int loreIndex = id % 1000000
    int actionIndex = int(math.floor(float(loreIndex) / 10000.0))
    int objectIndex = int(math.floor(float(loreIndex % 10000) / 100.0))
    int endingIndex = loreIndex % 100
    f_loreAction100(actionIndex) + " " + f_loreObject100(objectIndex) + " " + f_loreEnding100(endingIndex)

string WISDOM_START_PACK = "Protect capital before chasing opportunity|Set risk before the trade begins|Keep each loss small enough to absorb|Let risk stay boring and predictable|Size the position from risk, not excitement|Trade small enough to think clearly|Match size to the planned invalidation|Keep size stable when confidence rises|Place the stop where the idea is invalid|Accept the stop before entering|Do not widen risk to avoid being wrong|Let invalidation end the trade|Wait for the setup instead of inventing one|Let price come to your plan|Treat patience as an active trading decision|Stay selective when nothing qualifies|Let a missed move remain missed|Do not chase price after the entry is gone|Separate a fast move from a valid setup|Watch runaway price without needing to join|Do not make the next trade repay the last one|Pause when a loss starts feeling personal|Let frustration cool before trading again|Treat the next setup as independent|Let setup quality control trade frequency|Do not lower standards to stay active|Stop when the plan is complete|Treat every extra trade as fresh risk|Follow the rule written while calm|Judge execution before judging the outcome|Keep the process stable under pressure|Choose repeatable behavior over clever improvisation|Think in probabilities rather than certainties|Let one trade remain one data point|Accept uncertainty before taking risk|Judge an edge across a meaningful sample|Separate trade quality from trade outcome|Review winners as critically as losers|Do not reward a mistake because it made money|Do not condemn a good decision because it lost|Let evidence matter more than ego|Stay willing to change your market view|Keep conviction inside predefined risk|Do not attach self-worth to being right|Write the trade reason before hindsight changes it|Track decisions as carefully as P&L|Review repeated behavior, not isolated stories|Use the journal to expose recurring mistakes|Plan the response before the market creates urgency|Define invalidation before entering|Know what conditions tell you to stand aside|Begin the session with scenarios, not demands|Enter because criteria are met|Exit because the plan says the idea is done|Keep execution aligned with the setup timeframe|Reduce open decisions before the trade begins|Trade the market condition you actually have|Recognize when the environment has changed|Match expectations to volatility and structure|Let poor conditions justify standing aside|Reduce pressure before trying to recover a drawdown|Review the process before changing everything|Keep risk controlled when confidence is low|Let recovery come from normal execution|Keep the same standards during a winning streak|Let confidence rise slower than profits|Review winners with the same honesty as losses|Do not let recent success expand risk automatically|Notice the emotion before acting on it|Treat strong feelings as information about yourself|Pause when urgency narrows your attention|Keep P&L from controlling the next decision|Accept that good trades will sometimes be missed|Do not turn regret into a late entry|Let the original opportunity end when it is gone|Study the missed trade after the session|Treat boredom as a feeling, not a signal|Let quiet markets stay quiet|Do not invent setups to fill screen time|Use slow periods to observe instead of trade|Respect how quickly volatility can change risk|Slow down when price moves faster than your process|Plan in advance for major news|Treat large candles as movement, not certainty|Set goals around actions you can control|Do not force trades to meet a daily target|Measure process quality alongside P&L|Let one session remain a small part of the record|Keep enough rules stable to learn from results|Repeat the same preparation through changing moods|Build a process you can follow on a bad day|Change methods slower than you collect evidence|Define the edge clearly enough to test|Use statistics to challenge memory|Judge expectancy, not just win rate|Separate strategy performance from execution errors|Protect mental capital as well as financial capital|Build a trading routine you can sustain|Let one session stay smaller than your identity|Give skill enough time to compound"
string WISDOM_END_PACK = "survival creates the next opportunity|one trade should never threaten the account|accepted downside supports clearer decisions|capital preserved today keeps choices open|discipline starts with a defined loss|larger size magnifies every mistake|comfort with the stop matters more than conviction|consistency makes results easier to judge|emotions grow quickly when size is too large|good sizing keeps one outcome unimportant|a planned loss is part of the process|hope should not replace the original rule|small losses preserve clarity|respecting the boundary builds self-trust|good trades can still reach their stop|the market does not reward constant action|another opportunity will come|urgency is not evidence|waiting protects entry quality|doing nothing can be correct execution|missing a trade is not losing money|late entries need fresh reasons|speed does not improve risk|regret is cheaper than a forced trade|another setup is worth waiting for|the market owes no recovery|normal decisions rebuild discipline|anger is not a valid entry condition|recovery should not require larger risk|stepping away can protect the session|activity is not the same as productivity|boredom is a poor reason to participate|more trades can hide weaker decisions|selectivity protects both capital and focus|no setup is useful information|rules matter most when emotion resists them|a good loss can still be good execution|a lucky win can still contain a mistake|consistency turns an edge into behavior|discipline removes unnecessary decisions|good setups can still lose|short runs contain plenty of luck|certainty is not available in advance|variance does not automatically invalidate the process|probability thinking reduces the need to be right|results need context|luck can hide poor execution|losses can occur inside a sound process|the decision matters before the outcome is known|honest review prevents outcome bias|price does not care about your opinion|humility keeps new information visible|flexibility is cheaper than stubbornness|certainty can hide risk|being wrong quickly can be a strength|memory is less reliable than evidence|rule adherence deserves measurement|patterns become visible across many trades|honest notes improve future decisions|review should produce learning, not excuses|preparation reduces emotional improvisation|clear rules make patience easier|surprises are easier to manage with a plan|the losing scenario deserves advance thought|good preparation includes when not to trade|excitement should not replace evidence|normal noise should not rewrite the plan|simple rules are easier to repeat|clean execution creates useful data|good entries still require good exits|not every method fits every regime|chop and trend reward different behavior|more movement does not always mean more edge|context gives a setup meaning|adaptation should be planned rather than impulsive|larger bets rarely solve variance|drawdowns reveal weaknesses that wins can hide|evidence should guide strategy changes|smaller size can create room to think|recovery does not need to happen today|good outcomes can hide weak decisions|favorable conditions are not permanent|the next trade is not safer because the last one won|discipline can disappear inside success|luck and skill can look alike in small samples|fear and excitement both distort risk|awareness creates room for choice|appropriate size makes emotions easier to manage|the goal is deliberate action, not zero emotion|a short pause can restore perspective|hindsight makes entries look easier than they were|a miss is not a financial loss|selective trading requires accepting some misses|a late trade needs a new setup|the next valid opportunity matters more|stimulation is not the same as opportunity|low activity can mean the filter is working|boredom often lowers standards quietly|doing nothing can protect capital|your edge does not owe you entertainment|fast markets punish improvisation|slippage belongs in real risk|volatility is not automatically opportunity|old size assumptions may no longer fit|preparation matters more as speed increases|the market does not know your income goal|good decisions can occur on losing days|profit can coexist with poor execution|progress includes reducing avoidable mistakes|long-term results are built from ordinary sessions|stable execution makes statistics useful|routine protects attention|repeatability matters more than occasional brilliance|constant changes turn feedback into noise|consistency is a skill before it is a result|small samples can mislead|average win and average loss both matter|historical results still require live discipline|data should reduce uncertainty, not pretend to erase it|an edge only matters if you can execute it|rest supports decision quality|burnout can ruin good execution|long-term improvement is usually quiet|the market will still be here tomorrow|survival gives learning time to work"
var array<string> WISDOM_STARTS = str.split(WISDOM_START_PACK, "|")
var array<string> WISDOM_ENDS = str.split(WISDOM_END_PACK, "|")

f_tradingWisdom(int id) =>
    int wisdomIndex = int(((int(id) - 1) * 271 + 137) % 500)
    int themeIndex = int(math.floor(float(wisdomIndex) / 20.0))
    int localIndex = wisdomIndex % 20
    int startIndex = themeIndex * 4 + int(math.floor(float(localIndex) / 5.0))
    int endIndex = themeIndex * 5 + localIndex % 5
    array.get(WISDOM_STARTS, startIndex) + "; " + array.get(WISDOM_ENDS, endIndex) + "."

f_nameOnset(int i) =>
    switch i
        0 => "Ar"
        1 => "Be"
        2 => "Ca"
        3 => "Da"
        4 => "El"
        5 => "Fi"
        6 => "Ga"
        7 => "Ha"
        8 => "Io"
        => "Ju"

f_nameMiddle(int i) =>
    switch i
        0 => "ri"
        1 => "la"
        2 => "ve"
        3 => "no"
        4 => "mi"
        5 => "sa"
        6 => "te"
        7 => "ko"
        8 => "yu"
        => "di"

f_nameEnding(int i) =>
    switch i
        0 => "na"
        1 => "or"
        2 => "el"
        3 => "is"
        4 => "an"
        5 => "um"
        6 => "et"
        7 => "ix"
        8 => "ar"
        => "os"

f_namePart(int block, int style) =>
    int a = int(math.floor(float(block) / 100.0))
    int b = int(math.floor(float(block % 100) / 10.0))
    int c = block % 10
    int aa = (a + style * 3) % 10
    int bb = (b + style * 5) % 10
    int cc = (c + style * 7) % 10
    f_nameOnset(aa) + f_nameMiddle(bb) + f_nameEnding(cc)

f_chartlingName(int id) =>
    int firstBlock = int(math.floor(float(id) / 1000000.0))
    int secondBlock = int(math.floor(float(id % 1000000) / 1000.0))
    int thirdBlock = id % 1000
    f_namePart(firstBlock, 0) + " " + f_namePart(secondBlock, 1) + " " + f_namePart(thirdBlock, 2)

f_ageText(float minutes) =>
    int totalMinutes = math.max(0, int(math.floor(minutes)))
    int days = int(math.floor(float(totalMinutes) / 1440.0))
    int hours = int(math.floor(float(totalMinutes % 1440) / 60.0))
    int mins = totalMinutes % 60
    days > 0 ? str.tostring(days) + "D " + str.tostring(hours) + "H" : hours > 0 ? str.tostring(hours) + "H " + str.tostring(mins) + "M" : str.tostring(mins) + "M"

int hatchClock = barstate.islast ? timenow : time_close
int hatchLocalYear = year(hatchClock, hatchTimezone)
int hatchLocalMonth = month(hatchClock, hatchTimezone)
int hatchLocalDay = dayofmonth(hatchClock, hatchTimezone)
int hatchLocalMidnight = timestamp(hatchTimezone, hatchLocalYear, hatchLocalMonth, hatchLocalDay, 0, 0)
int todayHatchTime = timestamp(hatchTimezone, hatchLocalYear, hatchLocalMonth, hatchLocalDay, hatchHour, hatchMinute)
int previousDayProbe = hatchLocalMidnight - 43200000
int previousYear = year(previousDayProbe, hatchTimezone)
int previousMonth = month(previousDayProbe, hatchTimezone)
int previousDay = dayofmonth(previousDayProbe, hatchTimezone)
int previousHatchTime = timestamp(hatchTimezone, previousYear, previousMonth, previousDay, hatchHour, hatchMinute)
int hatchCycleStart = hatchClock >= todayHatchTime ? todayHatchTime : previousHatchTime
int hatchCycleYear = year(hatchCycleStart, hatchTimezone)
int hatchCycleMonth = month(hatchCycleStart, hatchTimezone)
int hatchCycleDay = dayofmonth(hatchCycleStart, hatchTimezone)
int hatchDayKey = hatchCycleYear * 10000 + hatchCycleMonth * 100 + hatchCycleDay
string trainerKey = str.upper(str.trim(trainerCode))
bool trainerReady = str.length(trainerKey) > 0
string standardTickerId = ticker.standard(syminfo.tickerid)
float trainerSeed = f_symbolSeed(trainerReady ? trainerKey : "CHARTLING")
var float symbolBaseSeed = f_symbolSeed(standardTickerId)
float hatchRollSeed = trainerSeed * 1.11317 + symbolBaseSeed * 2.17303 + float(hatchDayKey) * 0.73129 + 19.1701
int dailyHatchId = 1 + int(math.floor(f_dnaRand(hatchRollSeed) * 999999999.0))
string showChartlingTrimmed = str.trim(showChartling)
bool manualInputProvided = str.length(showChartlingTrimmed) > 0
int requestedHatchId = f_parseHatchId(showChartlingTrimmed)
bool manualInputInvalid = manualInputProvided and not f_validHatchId(requestedHatchId)
bool manualView = manualInputProvided and not manualInputInvalid
int hatchId = manualView ? requestedHatchId : dailyHatchId
string hatchIdText = f_idText(hatchId)
string chartlingName = f_chartlingName(hatchId)
varip int keeperCheckHatchId = na
varip bool keeperCheckResult = false
if na(keeperCheckHatchId) or keeperCheckHatchId != hatchId
    keeperCheckHatchId := hatchId
    keeperCheckResult := f_keeperContains(keeperIds, hatchId)
bool isKeeper = keeperCheckResult
float birthSeed = float(hatchId) * 0.61803398875
// Exact catalogue rarity allocation across #000000001-#999999999.
// The affine permutation keeps rarity positions scattered while preserving the exact tier counts.
int rarityRank = int(((int(hatchId) - 1) * 48271 + 314159265) % 999999999)
int rarityTier = rarityRank < 599999999 ? 0 : rarityRank < 849999999 ? 1 : rarityRank < 949999999 ? 2 : rarityRank < 989999999 ? 3 : rarityRank < 998999999 ? 4 : 5
string rarityName = rarityTier == 0 ? "COMMON" : rarityTier == 1 ? "UNCOMMON" : rarityTier == 2 ? "RARE" : rarityTier == 3 ? "VERY RARE" : rarityTier == 4 ? "MYSTICAL" : "LEGENDARY"
color rarityColor = rarityTier == 0 ? chart.fg_color : rarityTier == 1 ? color.rgb(76, 214, 124) : rarityTier == 2 ? color.rgb(76, 145, 255) : rarityTier == 3 ? color.rgb(190, 91, 255) : rarityTier == 4 ? color.rgb(242, 75, 75) : color.rgb(255, 156, 61)
float paletteRoll = f_dnaRand(birthSeed + 3.17)
int paletteIndex = rarityTier == 0 ? int(math.floor(paletteRoll * 8.0)) : rarityTier == 1 ? 8 + int(math.floor(paletteRoll * 6.0)) : rarityTier == 2 ? 14 + int(math.floor(paletteRoll * 4.0)) : rarityTier == 3 ? 18 + int(math.floor(paletteRoll * 3.0)) : rarityTier == 4 ? (paletteRoll < 0.5 ? 21 : 23) : 22
string paletteName = f_paletteName(paletteIndex)
int headOptions = rarityTier == 0 ? 3 : rarityTier == 1 ? 4 : 5
int tailOptions = rarityTier == 0 ? 3 : rarityTier == 1 ? 4 : 5
int markingOptions = rarityTier == 0 ? 2 : rarityTier == 1 ? 3 : rarityTier == 2 ? 4 : 5
int coreOptions = rarityTier == 0 ? 1 : rarityTier == 1 ? 2 : 3
int headGene = math.min(headOptions - 1, int(math.floor(f_dnaRand(birthSeed + 17.41) * float(headOptions))))
int tailGene = math.min(tailOptions - 1, int(math.floor(f_dnaRand(birthSeed + 29.83) * float(tailOptions))))
int markingGene = math.min(markingOptions - 1, int(math.floor(f_dnaRand(birthSeed + 41.27) * float(markingOptions))))
int coreGene = rarityTier == 5 ? 2 : math.min(coreOptions - 1, int(math.floor(f_dnaRand(birthSeed + 57.63) * float(coreOptions))))
string headStyle = headGene == 0 ? "Horns" : headGene == 1 ? "Ears" : headGene == 2 ? "None" : headGene == 3 ? "Nubs" : "Fins"
string tailStyle = tailGene == 0 ? "Classic" : tailGene == 1 ? "Lightning" : tailGene == 2 ? "None" : tailGene == 3 ? "Stub" : "Curl"
string extraMarking = markingGene == 0 ? "None" : markingGene == 1 ? "Stripe" : markingGene == 2 ? "Spots" : markingGene == 3 ? "Mask" : "Crest"
string coreStyle = coreGene == 0 ? "Single" : coreGene == 1 ? "Twin" : "Halo"
[birthBody, birthLight, birthShadow, birthDeep, birthMark, birthHorn, birthCore] = f_birthPalette(paletteIndex)

string loreSentence = tradingWisdom ? f_tradingWisdom(hatchId) : f_loreSentence(hatchId)

f_marketMA(string method, float src, int len) =>
    switch method
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "HMA" => ta.hma(src, len)
        => ta.ema(src, len)

f_wave(string prT, int prL, string poT, int poL) =>
    float preO = f_marketMA(prT, open, prL)
    float preH = f_marketMA(prT, high, prL)
    float preL = f_marketMA(prT, low, prL)
    float preC = f_marketMA(prT, close, prL)
    float sO = na(preO) ? open : preO
    float sH = na(preH) ? high : preH
    float sL = na(preL) ? low : preL
    float sC = na(preC) ? close : preC
    float haC = (sO + sH + sL + sC) / 4.0
    float haO = na
    haO := na(haO[1]) ? (sO + sC) / 2.0 : (nz(haO[1]) + nz(haC[1])) / 2.0
    float haH = math.max(sH, math.max(haO, haC))
    float haL = math.min(sL, math.min(haO, haC))
    [f_marketMA(poT, haH, poL), f_marketMA(poT, haL, poL)]

f_waveHist(string prT, int prL, string poT, int poL) =>
    [h, l] = f_wave(prT, prL, poT, poL)
    [h[1], l[1]]

int W = 96
int H = 48
int SCREEN_W = staticChartling ? 38 : W
int SCREEN_H = staticChartling ? 38 : H
int SAFE_LEFT_X = 14
int HOME_MIN_X = 18
int HOME_MAX_X = 61
int HOME_START_X = 28
int FLAG_X = 84
int FLAG_TOP_Y = 29
int CLEAR_TOP = 3
int CLEAR_BOTTOM = H - 1

color C_VOID = color.new(color.black, 100)
color C_BODY = birthBody
color C_BODY_L = birthLight
color C_BODY_D = birthShadow
color C_BODY_DD = birthDeep
color C_MARK = birthMark
color C_HORN = birthHorn
color C_HORN_D = color.new(birthHorn, 25)
color C_EYE = color.rgb(245, 250, 255)
color C_OUTLINE = color.rgb(22, 21, 31)
color C_PUPIL = C_OUTLINE
color C_CORE = birthCore
color C_CORE_HOT = color.rgb(255, 214, 77)
color C_BULL = color.rgb(50, 220, 120)
color C_BEAR = color.rgb(235, 70, 90)
color C_EGG = color.rgb(226, 220, 243)
color C_EGG_D = color.rgb(169, 160, 195)
color C_STAR = color.rgb(235, 240, 255)
color C_SLEEP = color.rgb(156, 190, 255)
color C_GROUND = color.new(color.rgb(48, 51, 66), 30)
color C_GROUND2 = color.new(color.rgb(80, 84, 105), 35)
color C_SHADOW = color.new(color.black, 35)
color C_GLASS = color.rgb(28, 30, 39)
color C_GLASS_L = color.rgb(88, 119, 155)
color C_CUP = color.rgb(230, 232, 239)
color C_COFFEE = color.rgb(165, 106, 54)
color C_LAPTOP = color.rgb(70, 77, 99)
color C_SCREEN = color.rgb(52, 180, 200)
color C_PAPER = color.rgb(221, 217, 200)
color C_PAPER_D = color.rgb(151, 148, 138)
color C_SIGN = color.rgb(198, 164, 105)
color C_SIGN_D = color.rgb(126, 98, 60)
color C_PHONE = color.rgb(53, 58, 75)
color C_PHONE_SCREEN = color.rgb(103, 210, 235)
color C_BOOK = color.rgb(180, 90, 100)
color C_BOOK_PAGE = color.rgb(235, 222, 195)
color C_POP = color.rgb(242, 214, 90)
color C_POP_BOX = color.rgb(220, 75, 75)
color C_RAIN = color.rgb(105, 165, 225)
color C_CLOUD = color.rgb(125, 135, 155)
color C_TEXT = chart.fg_color
color C_HUD_BG = color.new(chart.bg_color, 18)
color C_HUD_OFF = color.new(chart.bg_color, 100)

var table screen = table.new(chartlingTablePosition, SCREEN_W, SCREEN_H, bgcolor = C_VOID, frame_color = C_VOID, frame_width = 0, border_width = 0)
var table hud = table.new(hudTablePosition, 1, 5, bgcolor = C_HUD_BG, frame_color = C_VOID, frame_width = 0)

if barstate.isfirst
    for y = 0 to SCREEN_H - 1
        for x = 0 to SCREEN_W - 1
            table.cell(screen, x, y, "■", text_size = pixelSize, text_color = color.new(color.white, 100), bgcolor = C_VOID)
    for y = 0 to 4
        table.cell(hud, 0, y, "", text_size = size.tiny, text_color = C_TEXT, bgcolor = C_HUD_BG)

f_px(table t, int x, int y, color c) =>
    if x >= 0 and x < SCREEN_W and y >= 0 and y < SCREEN_H
        table.cell_set_bgcolor(t, x, y, c)

f_rect(table t, int x, int y, int w, int h, color c) =>
    for yy = 0 to h - 1
        for xx = 0 to w - 1
            f_px(t, x + xx, y + yy, c)

f_clearScene(table t) =>
    for y = CLEAR_TOP to CLEAR_BOTTOM
        for x = 0 to W - 1
            table.cell_set_bgcolor(t, x, y, C_VOID)

f_ground(table t) =>
    if showGround
        for x = SAFE_LEFT_X to W - 2
            f_px(t, x, 42, x % 7 == 0 ? C_GROUND2 : C_GROUND)
        for x = SAFE_LEFT_X + 3 to W - 4
            f_px(t, x, 43, C_SHADOW)
        f_px(t, SAFE_LEFT_X + 4, 41, C_GROUND2)
        f_px(t, SAFE_LEFT_X + 5, 40, C_GROUND2)
        f_px(t, 35, 41, C_GROUND2)
        f_px(t, 54, 40, C_GROUND2)
        f_px(t, 72, 41, C_GROUND2)
        f_px(t, 91, 40, C_GROUND2)

f_notice(table t, int x, int y, color c) =>
    f_rect(t, x, y, 2, 4, c)
    f_rect(t, x, y + 6, 2, 2, c)

f_sleepZ(table t, int x, int y) =>
    f_rect(t, x, y, 3, 1, C_SLEEP)
    f_px(t, x + 2, y + 1, C_SLEEP)
    f_px(t, x + 1, y + 2, C_SLEEP)
    f_rect(t, x, y + 3, 3, 1, C_SLEEP)

f_heart(table t, int x, int y) =>
    f_px(t, x + 1, y, C_BEAR)
    f_px(t, x + 3, y, C_BEAR)
    f_rect(t, x, y + 1, 5, 2, C_BEAR)
    f_rect(t, x + 1, y + 3, 3, 1, C_BEAR)
    f_px(t, x + 2, y + 4, C_BEAR)

f_thought(table t, int x, int y) =>
    f_px(t, x, y + 5, C_EYE)
    f_px(t, x + 2, y + 3, C_EYE)
    f_rect(t, x + 4, y, 6, 4, C_EYE)
    f_rect(t, x + 5, y + 1, 4, 2, C_VOID)

f_question(table t, int x, int y, color c) =>
    f_rect(t, x, y, 4, 1, c)
    f_px(t, x + 3, y + 1, c)
    f_px(t, x + 2, y + 2, c)
    f_px(t, x + 2, y + 3, c)
    f_px(t, x + 2, y + 5, c)

f_lightbulb(table t, int x, int y) =>
    f_rect(t, x + 1, y, 3, 1, C_CORE_HOT)
    f_rect(t, x, y + 1, 5, 3, C_CORE_HOT)
    f_rect(t, x + 1, y + 4, 3, 2, C_SIGN_D)
    f_rect(t, x + 1, y + 6, 3, 1, C_OUTLINE)

f_music(table t, int x, int y) =>
    f_rect(t, x + 2, y, 1, 5, C_CORE)
    f_rect(t, x + 2, y, 4, 1, C_CORE)
    f_rect(t, x + 5, y, 1, 4, C_CORE)
    f_rect(t, x, y + 4, 3, 2, C_CORE)
    f_rect(t, x + 3, y + 3, 3, 2, C_CORE)

f_confetti(table t, int x, int y, int phase) =>
    f_px(t, x, y, phase % 2 == 0 ? C_BULL : C_CORE_HOT)
    f_px(t, x + 5, y + 2, C_BEAR)
    f_px(t, x + 9, y - 1, C_CORE)
    f_px(t, x + 13, y + 3, C_BULL)
    f_px(t, x + 17, y, C_CORE_HOT)
    f_px(t, x + 21, y + 4, C_BEAR)

f_angrySteam(table t, int x, int y, int phase) =>
    int off = phase % 2
    f_px(t, x, y + off, C_BEAR)
    f_px(t, x + 1, y - 1 + off, C_BEAR)
    f_px(t, x + 4, y + off, C_BEAR)
    f_px(t, x + 5, y - 1 + off, C_BEAR)

f_dizzyStars(table t, int x, int y, int phase) =>
    if phase % 2 == 0
        f_px(t, x, y, C_CORE_HOT)
        f_px(t, x + 7, y - 2, C_STAR)
        f_px(t, x + 13, y + 1, C_CORE)
    else
        f_px(t, x + 2, y - 1, C_STAR)
        f_px(t, x + 9, y + 1, C_CORE_HOT)
        f_px(t, x + 14, y - 2, C_CORE)

f_rainCloud(table t, int x, int y, int phase) =>
    f_rect(t, x + 2, y, 8, 2, C_CLOUD)
    f_rect(t, x, y + 2, 12, 3, C_CLOUD)
    int drop = phase % 2
    f_px(t, x + 2, y + 6 + drop, C_RAIN)
    f_px(t, x + 6, y + 7 - drop, C_RAIN)
    f_px(t, x + 10, y + 6 + drop, C_RAIN)

f_meditation(table t, int x, int y, int phase) =>
    color a = phase % 2 == 0 ? color.new(C_CORE, 35) : color.new(C_CORE_HOT, 45)
    f_px(t, x - 7, y, a)
    f_px(t, x + 7, y, a)
    f_px(t, x - 5, y - 5, a)
    f_px(t, x + 5, y - 5, a)
    f_px(t, x - 2, y - 8, a)
    f_px(t, x + 2, y - 8, a)
    f_px(t, x, y - 10, a)

f_coffee(table t, int x, int y, int frame) =>
    int lift = frame == 1 or frame == 2 ? -4 : 0
    f_rect(t, x, y + lift, 4, 3, C_CUP)
    f_rect(t, x + 1, y + 1 + lift, 2, 1, C_COFFEE)
    f_px(t, x + 4, y + 1 + lift, C_CUP)
    if frame == 0 or frame == 3
        f_px(t, x + 1, y - 2, color.new(C_STAR, 40))

f_laptop(table t, int x, int y, int frame) =>
    f_rect(t, x, y, 9, 6, C_LAPTOP)
    f_rect(t, x + 1, y + 1, 7, 4, C_OUTLINE)
    f_rect(t, x + 2, y + 2, 5, 1, C_SCREEN)
    f_rect(t, frame % 2 == 0 ? x + 2 : x + 4, y + 4, 3, 1, frame % 2 == 0 ? C_BULL : C_BEAR)
    f_rect(t, x - 1, y + 6, 11, 1, C_LAPTOP)

f_newspaper(table t, int x, int y, int frame) =>
    int shift = frame % 2
    f_rect(t, x + shift, y, 9, 7, C_PAPER)
    f_rect(t, x + 1 + shift, y + 1, 3, 2, C_PAPER_D)
    f_rect(t, x + 5 + shift, y + 1, 3, 1, C_PAPER_D)
    f_rect(t, x + 1 + shift, y + 4, 7, 1, C_PAPER_D)
    f_rect(t, x + 1 + shift, y + 6, 5, 1, C_PAPER_D)

f_popcorn(table t, int x, int y) =>
    f_rect(t, x, y + 2, 6, 6, C_POP_BOX)
    f_rect(t, x + 1, y + 2, 1, 6, C_STAR)
    f_rect(t, x + 4, y + 2, 1, 6, C_STAR)
    f_px(t, x + 1, y + 1, C_POP)
    f_px(t, x + 3, y, C_POP)
    f_px(t, x + 5, y + 1, C_POP)
    f_px(t, x + 2, y + 1, C_STAR)

f_phone(table t, int x, int y, int frame) =>
    f_rect(t, x, y, 4, 7, C_PHONE)
    f_rect(t, x + 1, y + 1, 2, 4, frame % 2 == 0 ? C_PHONE_SCREEN : C_CORE)
    f_px(t, x + 2, y + 6, C_STAR)

f_book(table t, int x, int y) =>
    f_rect(t, x, y, 5, 6, C_BOOK)
    f_rect(t, x + 5, y, 5, 6, C_BOOK)
    f_rect(t, x + 1, y + 1, 4, 4, C_BOOK_PAGE)
    f_rect(t, x + 5, y + 1, 4, 4, C_BOOK_PAGE)
    f_rect(t, x + 4, y, 2, 6, C_OUTLINE)

f_telescope(table t, int x, int y) =>
    f_rect(t, x, y, 8, 2, C_LAPTOP)
    f_rect(t, x + 7, y - 1, 3, 4, C_CORE)
    f_rect(t, x + 3, y + 2, 1, 5, C_SIGN_D)
    f_rect(t, x + 6, y + 2, 1, 5, C_SIGN_D)

f_dumbbell(table t, int x, int y, int frame) =>
    int lift = frame % 2 == 0 ? 0 : -2
    f_rect(t, x, y + lift, 10, 1, C_OUTLINE)
    f_rect(t, x, y - 1 + lift, 2, 3, C_BODY_DD)
    f_rect(t, x + 8, y - 1 + lift, 2, 3, C_BODY_DD)

f_magnifier(table t, int x, int y) =>
    f_rect(t, x + 1, y, 4, 1, C_EYE)
    f_px(t, x, y + 1, C_EYE)
    f_px(t, x + 5, y + 1, C_EYE)
    f_px(t, x, y + 2, C_EYE)
    f_px(t, x + 5, y + 2, C_EYE)
    f_rect(t, x + 1, y + 3, 4, 1, C_EYE)
    f_px(t, x + 5, y + 4, C_SIGN_D)
    f_px(t, x + 6, y + 5, C_SIGN_D)
    f_px(t, x + 7, y + 6, C_SIGN_D)

f_snack(table t, int x, int y) =>
    f_rect(t, x, y, 5, 7, C_CORE_HOT)
    f_rect(t, x + 1, y + 2, 3, 2, C_BODY_DD)
    f_px(t, x + 2, y + 1, C_BEAR)

f_plantedFlag(table t, int x, int topY, color c, int frame) =>
    int groundY = 42
    int poleH = groundY - topY + 1
    f_rect(t, x, topY, 1, poleH, C_SIGN_D)
    f_rect(t, x - 1, groundY, 3, 1, C_GROUND2)
    if frame % 2 == 0
        f_rect(t, x + 1, topY, 6, 3, c)
        f_px(t, x + 6, topY + 3, c)
    else
        f_rect(t, x + 1, topY, 5, 3, c)
        f_rect(t, x + 5, topY + 1, 2, 3, c)

f_flagWork(table t, int phase, int frame) =>
    if phase == 1
        f_px(t, FLAG_X - 3, 38, C_STAR)
        f_px(t, FLAG_X - 5, 36, C_CORE)
    if phase == 2
        f_rect(t, FLAG_X - 3, 41, 7, 2, C_SIGN_D)
        f_px(t, FLAG_X - 5, 40 - frame % 2, C_GROUND2)
        f_px(t, FLAG_X + 4, 40 + frame % 2, C_GROUND2)
        f_px(t, FLAG_X - 1, 39, C_STAR)
    if phase == 3
        f_px(t, FLAG_X - 3, 34, C_CORE_HOT)
        f_px(t, FLAG_X + 8, 35, C_STAR)

f_focusRays(table t, int x, int y, color c, int frame) =>
    if frame % 2 == 0
        f_px(t, x - 3, y, c)
        f_px(t, x + 3, y, c)
        f_px(t, x, y - 3, c)
    else
        f_px(t, x - 2, y - 2, c)
        f_px(t, x + 2, y - 2, c)

f_headHatch(table t, int ox, int oy) =>
    if headStyle == "Horns"
        f_rect(t, ox + 3, oy, 3, 3, C_HORN)
        f_rect(t, ox + 12, oy, 3, 3, C_HORN)
    else if headStyle == "Ears"
        f_rect(t, ox + 1, oy + 1, 5, 3, C_HORN)
        f_rect(t, ox + 12, oy + 1, 5, 3, C_HORN)
    else if headStyle == "Nubs"
        f_rect(t, ox + 4, oy + 1, 2, 2, C_HORN)
        f_rect(t, ox + 12, oy + 1, 2, 2, C_HORN)
    else if headStyle == "Fins"
        f_px(t, ox + 2, oy + 2, C_HORN)
        f_rect(t, ox + 3, oy + 1, 2, 2, C_HORN)
        f_px(t, ox + 15, oy + 2, C_HORN)
        f_rect(t, ox + 13, oy + 1, 2, 2, C_HORN)

f_headYoung(table t, int ox, int oy) =>
    if headStyle == "Horns"
        f_rect(t, ox + 3, oy, 3, 4, C_HORN)
        f_px(t, ox + 3, oy + 3, C_HORN_D)
        f_rect(t, ox + 16, oy, 3, 4, C_HORN)
        f_px(t, ox + 18, oy + 3, C_HORN_D)
    else if headStyle == "Ears"
        f_rect(t, ox + 1, oy + 2, 6, 4, C_HORN)
        f_rect(t, ox + 15, oy + 2, 6, 4, C_HORN)
    else if headStyle == "Nubs"
        f_rect(t, ox + 5, oy + 1, 3, 2, C_HORN)
        f_rect(t, ox + 16, oy + 1, 3, 2, C_HORN)
    else if headStyle == "Fins"
        f_rect(t, ox, oy + 3, 4, 2, C_HORN)
        f_rect(t, ox + 2, oy + 1, 3, 2, C_HORN)
        f_rect(t, ox + 20, oy + 3, 4, 2, C_HORN)
        f_rect(t, ox + 19, oy + 1, 3, 2, C_HORN)

f_headAdult(table t, int ox, int oy) =>
    if headStyle == "Horns"
        f_rect(t, ox + 4, oy, 4, 5, C_HORN)
        f_rect(t, ox + 5, oy + 4, 2, 2, C_HORN_D)
        f_rect(t, ox + 20, oy, 4, 5, C_HORN)
        f_rect(t, ox + 21, oy + 4, 2, 2, C_HORN_D)
    else if headStyle == "Ears"
        f_rect(t, ox + 1, oy + 2, 7, 5, C_HORN)
        f_rect(t, ox + 20, oy + 2, 7, 5, C_HORN)
        f_rect(t, ox + 2, oy + 3, 5, 3, C_HORN_D)
        f_rect(t, ox + 21, oy + 3, 5, 3, C_HORN_D)
    else if headStyle == "Nubs"
        f_rect(t, ox + 6, oy + 2, 3, 3, C_HORN)
        f_rect(t, ox + 20, oy + 2, 3, 3, C_HORN)
        f_px(t, ox + 7, oy + 1, C_HORN_D)
        f_px(t, ox + 21, oy + 1, C_HORN_D)
    else if headStyle == "Fins"
        f_rect(t, ox - 1, oy + 4, 5, 2, C_HORN)
        f_rect(t, ox + 1, oy + 2, 4, 2, C_HORN)
        f_px(t, ox + 3, oy + 1, C_HORN_D)
        f_rect(t, ox + 25, oy + 4, 5, 2, C_HORN)
        f_rect(t, ox + 24, oy + 2, 4, 2, C_HORN)
        f_px(t, ox + 25, oy + 1, C_HORN_D)

f_tailHatch(table t, int ox, int oy) =>
    if tailStyle == "Classic"
        f_px(t, ox + 14, oy + 13, C_BODY_D)
        f_px(t, ox + 16, oy + 12, C_BODY_D)
        f_px(t, ox + 18, oy + 12, C_BODY_D)
        f_px(t, ox + 19, oy + 13, C_BODY_DD)
        f_px(t, ox + 18, oy + 14, C_BODY_DD)
    else if tailStyle == "Lightning"
        f_px(t, ox + 14, oy + 13, C_BODY_D)
        f_px(t, ox + 16, oy + 11, C_BODY_D)
        f_px(t, ox + 18, oy + 12, C_BODY_D)
        f_px(t, ox + 17, oy + 14, C_BODY_DD)
        f_px(t, ox + 20, oy + 13, C_BODY_DD)
    else if tailStyle == "Stub"
        f_rect(t, ox + 14, oy + 13, 4, 3, C_BODY_D)
        f_px(t, ox + 18, oy + 14, C_BODY_DD)
    else if tailStyle == "Curl"
        f_px(t, ox + 14, oy + 13, C_BODY_D)
        f_px(t, ox + 16, oy + 12, C_BODY_D)
        f_px(t, ox + 18, oy + 12, C_BODY_D)
        f_px(t, ox + 20, oy + 13, C_BODY_DD)
        f_px(t, ox + 20, oy + 15, C_BODY_DD)
        f_px(t, ox + 18, oy + 16, C_BODY_DD)

f_tailYoung(table t, int ox, int oy) =>
    if tailStyle == "Classic"
        f_px(t, ox - 5, oy + 17, C_BODY_DD)
        f_px(t, ox - 4, oy + 16, C_BODY_D)
        f_px(t, ox - 3, oy + 15, C_BODY_D)
        f_px(t, ox - 2, oy + 14, C_BODY)
        f_px(t, ox - 1, oy + 14, C_BODY)
    else if tailStyle == "Lightning"
        f_px(t, ox - 1, oy + 14, C_BODY)
        f_px(t, ox - 3, oy + 15, C_BODY_D)
        f_px(t, ox - 5, oy + 14, C_BODY_D)
        f_px(t, ox - 4, oy + 17, C_BODY_DD)
        f_px(t, ox - 7, oy + 16, C_BODY_DD)
        f_px(t, ox - 6, oy + 19, C_BODY_DD)
    else if tailStyle == "Stub"
        f_rect(t, ox - 4, oy + 15, 4, 4, C_BODY_D)
        f_rect(t, ox - 5, oy + 16, 2, 2, C_BODY_DD)
    else if tailStyle == "Curl"
        f_px(t, ox - 1, oy + 14, C_BODY)
        f_px(t, ox - 3, oy + 15, C_BODY_D)
        f_px(t, ox - 5, oy + 16, C_BODY_D)
        f_px(t, ox - 7, oy + 18, C_BODY_DD)
        f_px(t, ox - 8, oy + 20, C_BODY_DD)
        f_px(t, ox - 7, oy + 22, C_BODY_DD)
        f_px(t, ox - 5, oy + 22, C_BODY_DD)
        f_px(t, ox - 4, oy + 20, C_BODY_D)

f_tailAdult(table t, int ox, int oy) =>
    if tailStyle == "Classic"
        f_px(t, ox - 6, oy + 19, C_BODY_DD)
        f_px(t, ox - 5, oy + 18, C_BODY_DD)
        f_px(t, ox - 4, oy + 17, C_BODY_D)
        f_px(t, ox - 3, oy + 16, C_BODY_D)
        f_px(t, ox - 2, oy + 15, C_BODY)
        f_px(t, ox - 1, oy + 15, C_BODY)
    else if tailStyle == "Lightning"
        f_px(t, ox - 1, oy + 15, C_BODY)
        f_px(t, ox - 3, oy + 16, C_BODY_D)
        f_px(t, ox - 5, oy + 15, C_BODY_D)
        f_px(t, ox - 4, oy + 18, C_BODY_D)
        f_px(t, ox - 7, oy + 18, C_BODY_DD)
        f_px(t, ox - 6, oy + 21, C_BODY_DD)
        f_px(t, ox - 8, oy + 20, C_BODY_DD)
    else if tailStyle == "Stub"
        f_rect(t, ox - 5, oy + 16, 5, 4, C_BODY_D)
        f_rect(t, ox - 6, oy + 17, 2, 2, C_BODY_DD)
        f_px(t, ox - 6, oy + 19, C_BODY_DD)
    else if tailStyle == "Curl"
        f_px(t, ox - 1, oy + 15, C_BODY)
        f_px(t, ox - 3, oy + 16, C_BODY_D)
        f_px(t, ox - 5, oy + 17, C_BODY_D)
        f_px(t, ox - 7, oy + 19, C_BODY_DD)
        f_px(t, ox - 8, oy + 20, C_BODY_DD)
        f_px(t, ox - 8, oy + 23, C_BODY_DD)
        f_px(t, ox - 7, oy + 25, C_BODY_DD)
        f_px(t, ox - 5, oy + 25, C_BODY_DD)
        f_px(t, ox - 3, oy + 23, C_BODY_D)
        f_px(t, ox - 4, oy + 21, C_BODY_D)

f_extraHatch(table t, int ox, int oy) =>
    if extraMarking == "Stripe"
        f_rect(t, ox + 5, oy + 4, 8, 1, C_MARK)
    else if extraMarking == "Spots"
        f_px(t, ox + 5, oy + 4, C_MARK)
        f_px(t, ox + 12, oy + 5, C_MARK)
        f_px(t, ox + 8, oy + 10, C_MARK)
    else if extraMarking == "Mask"
        f_rect(t, ox + 4, oy + 6, 10, 3, C_MARK)
    else if extraMarking == "Crest"
        f_rect(t, ox + 8, oy + 3, 2, 5, C_MARK)

f_extraYoung(table t, int ox, int oy) =>
    if extraMarking == "Stripe"
        f_rect(t, ox + 6, oy + 5, 12, 1, C_MARK)
    else if extraMarking == "Spots"
        f_rect(t, ox + 5, oy + 5, 2, 2, C_MARK)
        f_rect(t, ox + 17, oy + 6, 2, 2, C_MARK)
        f_px(t, ox + 11, oy + 14, C_MARK)
    else if extraMarking == "Mask"
        f_rect(t, ox + 5, oy + 8, 15, 4, C_MARK)
    else if extraMarking == "Crest"
        f_rect(t, ox + 11, oy + 4, 3, 7, C_MARK)

f_extraAdult(table t, int ox, int oy) =>
    if extraMarking == "Stripe"
        f_rect(t, ox + 6, oy + 6, 17, 1, C_MARK)
    else if extraMarking == "Spots"
        f_rect(t, ox + 5, oy + 6, 3, 2, C_MARK)
        f_rect(t, ox + 20, oy + 7, 3, 2, C_MARK)
        f_rect(t, ox + 11, oy + 16, 2, 2, C_MARK)
        f_px(t, ox + 20, oy + 15, C_MARK)
    else if extraMarking == "Mask"
        f_rect(t, ox + 6, oy + 9, 18, 5, C_MARK)
    else if extraMarking == "Crest"
        f_rect(t, ox + 13, oy + 5, 4, 9, C_MARK)

f_coreHatch(table t, int ox, int oy, color core) =>
    if coreStyle == "Single"
        f_rect(t, ox + 8, oy, 2, 2, core)
    else if coreStyle == "Twin"
        f_px(t, ox + 7, oy + 1, core)
        f_px(t, ox + 10, oy + 1, core)
    else
        f_rect(t, ox + 7, oy, 4, 1, core)
        f_px(t, ox + 7, oy + 1, core)
        f_px(t, ox + 10, oy + 1, core)

f_coreYoung(table t, int ox, int oy, color core) =>
    if coreStyle == "Single"
        f_rect(t, ox + 10, oy, 3, 2, core)
    else if coreStyle == "Twin"
        f_rect(t, ox + 8, oy + 1, 2, 2, core)
        f_rect(t, ox + 13, oy + 1, 2, 2, core)
    else
        f_rect(t, ox + 9, oy - 1, 5, 1, core)
        f_px(t, ox + 9, oy, core)
        f_px(t, ox + 13, oy, core)

f_coreAdult(table t, int ox, int oy, color core) =>
    if coreStyle == "Single"
        f_rect(t, ox + 13, oy, 3, 3, core)
    else if coreStyle == "Twin"
        f_rect(t, ox + 11, oy + 1, 2, 2, core)
        f_rect(t, ox + 17, oy + 1, 2, 2, core)
    else
        f_rect(t, ox + 12, oy - 1, 5, 1, core)
        f_px(t, ox + 11, oy, core)
        f_px(t, ox + 17, oy, core)
        f_px(t, ox + 14, oy + 1, core)

int FACE_NORMAL = 0
int FACE_SLEEPY = 1
int FACE_SURPRISED = 2
int FACE_YAWN = 3
int FACE_ANGRY = 4
int FACE_LAUGH = 5
int FACE_DIZZY = 6

f_hatch(table t, int ox, int oy, bool blinkNow, bool step, color core, color belly, bool glasses, bool scratch, int look, int faceMode) =>
    f_headHatch(t, ox, oy)
    f_tailHatch(t, ox, oy)
    f_coreHatch(t, ox, oy, core)
    f_rect(t, ox + 2, oy + 2, 14, 10, C_OUTLINE)
    f_rect(t, ox + 3, oy + 3, 12, 8, C_BODY)
    f_rect(t, ox + 5, oy + 3, 8, 1, C_BODY_L)
    f_extraHatch(t, ox, oy)
    bool sleepyFace = faceMode == FACE_SLEEPY
    bool laughFace = faceMode == FACE_LAUGH
    bool dizzyFace = faceMode == FACE_DIZZY
    bool angryFace = faceMode == FACE_ANGRY
    if glasses
        f_rect(t, ox + 4, oy + 6, 10, 3, C_GLASS)
        f_rect(t, ox + 5, oy + 7, 3, 1, C_GLASS_L)
        f_rect(t, ox + 10, oy + 7, 3, 1, C_GLASS_L)
    else if dizzyFace
        f_px(t, ox + 5, oy + 6, C_EYE)
        f_px(t, ox + 7, oy + 8, C_EYE)
        f_px(t, ox + 7, oy + 6, C_EYE)
        f_px(t, ox + 5, oy + 8, C_EYE)
        f_px(t, ox + 10, oy + 6, C_EYE)
        f_px(t, ox + 12, oy + 8, C_EYE)
        f_px(t, ox + 12, oy + 6, C_EYE)
        f_px(t, ox + 10, oy + 8, C_EYE)
    else if blinkNow or sleepyFace or laughFace
        f_rect(t, ox + 5, oy + 7, 3, 1, C_PUPIL)
        f_rect(t, ox + 10, oy + 7, 3, 1, C_PUPIL)
    else
        f_rect(t, ox + 5, oy + 6, 3, 3, C_EYE)
        f_rect(t, ox + 10, oy + 6, 3, 3, C_EYE)
        int lx = look < 0 ? 5 : look > 0 ? 7 : 6
        int rx = look < 0 ? 10 : look > 0 ? 12 : 11
        f_px(t, ox + lx, oy + 7, C_PUPIL)
        f_px(t, ox + rx, oy + 7, C_PUPIL)
    if faceMode == FACE_SURPRISED
        f_rect(t, ox + 8, oy + 9, 3, 2, C_OUTLINE)
    else if faceMode == FACE_YAWN
        f_rect(t, ox + 8, oy + 9, 3, 2, C_CORE_HOT)
    else if laughFace
        f_rect(t, ox + 7, oy + 9, 5, 2, C_OUTLINE)
        f_rect(t, ox + 8, oy + 9, 3, 1, C_BEAR)
    else if angryFace
        f_rect(t, ox + 7, oy + 9, 4, 1, C_OUTLINE)
        f_px(t, ox + 5, oy + 5, C_BODY_DD)
        f_px(t, ox + 12, oy + 5, C_BODY_DD)
    else
        f_px(t, ox + 9, oy + 9, C_OUTLINE)
    f_rect(t, ox + 5, oy + 12, 9, 5, C_BODY)
    f_rect(t, ox + 8, oy + 14, 3, 2, belly)
    if step
        f_rect(t, ox + 5, oy + 17, 3, 2, C_BODY_D)
        f_rect(t, ox + 12, oy + 16, 3, 2, C_BODY_D)
    else
        f_rect(t, ox + 5, oy + 17, 3, 2, C_BODY_D)
        f_rect(t, ox + 12, oy + 17, 3, 2, C_BODY_D)
    if scratch
        f_rect(t, ox + 15, oy + 6, 2, 5, C_BODY_L)

f_young(table t, int ox, int oy, bool blinkNow, bool step, color core, color belly, bool glasses, bool scratch, int look, bool poweredNow, int faceMode) =>
    f_tailYoung(t, ox, oy)
    f_headYoung(t, ox, oy)
    f_coreYoung(t, ox, oy, core)
    if poweredNow
        f_px(t, ox + 11, oy - 1, color.new(core, 20))
    f_rect(t, ox + 2, oy + 3, 20, 13, C_OUTLINE)
    f_rect(t, ox + 3, oy + 4, 18, 11, C_BODY)
    f_rect(t, ox + 6, oy + 4, 12, 2, C_BODY_L)
    f_extraYoung(t, ox, oy)
    f_rect(t, ox + 4, oy + 11, 3, 2, C_BODY_D)
    f_rect(t, ox + 17, oy + 11, 3, 2, C_BODY_D)
    bool sleepyFace = faceMode == FACE_SLEEPY
    bool laughFace = faceMode == FACE_LAUGH
    bool dizzyFace = faceMode == FACE_DIZZY
    bool angryFace = faceMode == FACE_ANGRY
    if glasses
        f_rect(t, ox + 5, oy + 7, 15, 4, C_GLASS)
        f_rect(t, ox + 6, oy + 8, 4, 2, C_GLASS_L)
        f_rect(t, ox + 15, oy + 8, 4, 2, C_GLASS_L)
    else if dizzyFace
        f_px(t, ox + 6, oy + 8, C_EYE)
        f_px(t, ox + 9, oy + 11, C_EYE)
        f_px(t, ox + 9, oy + 8, C_EYE)
        f_px(t, ox + 6, oy + 11, C_EYE)
        f_px(t, ox + 15, oy + 8, C_EYE)
        f_px(t, ox + 18, oy + 11, C_EYE)
        f_px(t, ox + 18, oy + 8, C_EYE)
        f_px(t, ox + 15, oy + 11, C_EYE)
    else if blinkNow or sleepyFace or laughFace
        f_rect(t, ox + 6, oy + 10, 4, 1, C_PUPIL)
        f_rect(t, ox + 15, oy + 10, 4, 1, C_PUPIL)
    else
        f_rect(t, ox + 6, oy + 8, 4, 4, C_EYE)
        f_rect(t, ox + 15, oy + 8, 4, 4, C_EYE)
        int lx = look < 0 ? 6 : look > 0 ? 8 : 7
        int rx = look < 0 ? 15 : look > 0 ? 17 : 16
        f_rect(t, ox + lx, oy + 9, 2, 2, C_PUPIL)
        f_rect(t, ox + rx, oy + 9, 2, 2, C_PUPIL)
    if faceMode == FACE_SURPRISED
        f_rect(t, ox + 10, oy + 12, 4, 3, C_OUTLINE)
    else if faceMode == FACE_YAWN
        f_rect(t, ox + 10, oy + 12, 4, 2, C_CORE_HOT)
    else if laughFace
        f_rect(t, ox + 9, oy + 12, 6, 3, C_OUTLINE)
        f_rect(t, ox + 10, oy + 13, 4, 1, C_BEAR)
    else if angryFace
        f_rect(t, ox + 10, oy + 13, 4, 1, C_OUTLINE)
        f_rect(t, ox + 6, oy + 7, 4, 1, C_BODY_DD)
        f_rect(t, ox + 15, oy + 7, 4, 1, C_BODY_DD)
    else
        f_rect(t, ox + 11, oy + 13, 2, 1, C_OUTLINE)
    f_rect(t, ox + 6, oy + 16, 13, 8, C_BODY)
    f_rect(t, ox + 10, oy + 19, 5, 3, belly)
    f_rect(t, ox + 3, oy + 17, 4, 3, C_BODY)
    f_rect(t, ox + 18, oy + 17, 4, 3, C_BODY)
    if step
        f_rect(t, ox + 6, oy + 24, 5, 2, C_BODY_D)
        f_rect(t, ox + 16, oy + 23, 5, 2, C_BODY_D)
    else
        f_rect(t, ox + 6, oy + 24, 5, 2, C_BODY_D)
        f_rect(t, ox + 16, oy + 24, 5, 2, C_BODY_D)
    if scratch
        f_rect(t, ox + 20, oy + 8, 3, 7, C_BODY_L)

f_adult(table t, int ox, int oy, bool blinkNow, bool step, color core, color belly, bool glasses, bool scratch, int look, bool poweredNow, bool crown, int faceMode) =>
    f_tailAdult(t, ox, oy)
    f_headAdult(t, ox, oy)
    f_coreAdult(t, ox, oy, core)
    if poweredNow
        f_px(t, ox + 14, oy - 2, color.new(core, 15))
        f_px(t, ox + 12, oy - 1, color.new(core, 30))
        f_px(t, ox + 16, oy - 1, color.new(core, 30))
    if crown
        f_px(t, ox + 10, oy - 4, C_CORE_HOT)
        f_px(t, ox + 14, oy - 6, C_CORE_HOT)
        f_px(t, ox + 18, oy - 4, C_CORE_HOT)
        f_rect(t, ox + 10, oy - 3, 9, 2, C_CORE_HOT)
    f_rect(t, ox + 1, oy + 4, 27, 14, C_OUTLINE)
    f_rect(t, ox + 2, oy + 5, 25, 12, C_BODY)
    f_rect(t, ox + 6, oy + 5, 17, 2, C_BODY_L)
    f_extraAdult(t, ox, oy)
    f_rect(t, ox + 3, oy + 13, 4, 3, C_BODY_D)
    f_rect(t, ox + 22, oy + 13, 4, 3, C_BODY_D)
    bool sleepyFace = faceMode == FACE_SLEEPY
    bool laughFace = faceMode == FACE_LAUGH
    bool dizzyFace = faceMode == FACE_DIZZY
    bool angryFace = faceMode == FACE_ANGRY
    if glasses
        f_rect(t, ox + 6, oy + 9, 8, 5, C_GLASS)
        f_rect(t, ox + 16, oy + 9, 8, 5, C_GLASS)
        f_rect(t, ox + 14, oy + 10, 2, 2, C_GLASS)
        f_rect(t, ox + 7, oy + 10, 4, 2, C_GLASS_L)
        f_rect(t, ox + 17, oy + 10, 4, 2, C_GLASS_L)
    else if dizzyFace
        f_px(t, ox + 7, oy + 9, C_EYE)
        f_px(t, ox + 11, oy + 13, C_EYE)
        f_px(t, ox + 11, oy + 9, C_EYE)
        f_px(t, ox + 7, oy + 13, C_EYE)
        f_px(t, ox + 18, oy + 9, C_EYE)
        f_px(t, ox + 22, oy + 13, C_EYE)
        f_px(t, ox + 22, oy + 9, C_EYE)
        f_px(t, ox + 18, oy + 13, C_EYE)
    else if blinkNow or sleepyFace or laughFace
        f_rect(t, ox + 7, oy + 12, 5, 1, C_PUPIL)
        f_rect(t, ox + 18, oy + 12, 5, 1, C_PUPIL)
    else
        f_rect(t, ox + 7, oy + 9, 5, 4, C_EYE)
        f_rect(t, ox + 18, oy + 9, 5, 4, C_EYE)
        int lx = look < 0 ? 7 : look > 0 ? 9 : 8
        int rx = look < 0 ? 18 : look > 0 ? 20 : 19
        f_rect(t, ox + lx, oy + 10, 2, 2, C_PUPIL)
        f_rect(t, ox + rx, oy + 10, 2, 2, C_PUPIL)
        f_px(t, ox + lx, oy + 10, C_EYE)
        f_px(t, ox + rx, oy + 10, C_EYE)
    if angryFace
        f_rect(t, ox + 7, oy + 8, 5, 1, C_BODY_DD)
        f_rect(t, ox + 18, oy + 8, 5, 1, C_BODY_DD)
    if faceMode == FACE_SURPRISED
        f_rect(t, ox + 12, oy + 14, 5, 4, C_OUTLINE)
    else if faceMode == FACE_YAWN
        f_rect(t, ox + 12, oy + 14, 5, 3, C_OUTLINE)
        f_rect(t, ox + 13, oy + 15, 3, 1, C_CORE_HOT)
    else if laughFace
        f_rect(t, ox + 11, oy + 14, 7, 4, C_OUTLINE)
        f_rect(t, ox + 13, oy + 16, 3, 1, C_BEAR)
    else if angryFace
        f_rect(t, ox + 12, oy + 15, 5, 1, C_OUTLINE)
    else
        f_rect(t, ox + 13, oy + 15, 3, 1, C_OUTLINE)
    f_rect(t, ox + 10, oy + 18, 10, 2, C_BODY)
    f_rect(t, ox + 7, oy + 20, 16, 10, C_BODY)
    f_rect(t, ox + 12, oy + 24, 6, 4, belly)
    f_rect(t, ox + 3, oy + 21, 5, 4, C_BODY)
    f_rect(t, ox + 22, oy + 21, 5, 4, C_BODY)
    if scratch
        f_rect(t, ox + 24, oy + 11, 3, 9, C_BODY_L)
    if step
        f_rect(t, ox + 7, oy + 30, 6, 3, C_BODY_D)
        f_rect(t, ox + 19, oy + 29, 6, 3, C_BODY_D)
    else
        f_rect(t, ox + 7, oy + 30, 6, 3, C_BODY_D)
        f_rect(t, ox + 19, oy + 30, 6, 3, C_BODY_D)

f_egg(table t, int ox, int oy, int crack) =>
    f_rect(t, ox + 5, oy, 5, 2, C_EGG)
    f_rect(t, ox + 3, oy + 2, 9, 2, C_EGG)
    f_rect(t, ox + 1, oy + 4, 13, 7, C_EGG)
    f_rect(t, ox, oy + 6, 2, 5, C_EGG_D)
    f_rect(t, ox + 13, oy + 6, 2, 5, C_EGG_D)
    f_rect(t, ox + 3, oy + 11, 9, 2, C_EGG_D)
    f_rect(t, ox + 5, oy + 13, 5, 2, C_EGG_D)
    if crack >= 1
        f_px(t, ox + 8, oy + 3, C_OUTLINE)
        f_px(t, ox + 7, oy + 4, C_OUTLINE)
        f_px(t, ox + 8, oy + 5, C_OUTLINE)
    if crack >= 2
        f_px(t, ox + 7, oy + 6, C_OUTLINE)
        f_px(t, ox + 8, oy + 7, C_OUTLINE)
        f_px(t, ox + 7, oy + 8, C_OUTLINE)
        f_px(t, ox + 6, oy + 9, C_OUTLINE)

f_food(table t, int x, int y, bool bullish, int bite) =>
    color c = bullish ? C_BULL : C_BEAR
    if bite == 0
        f_px(t, x + 2, y - 1, C_STAR)
    if bite <= 1
        f_rect(t, x, y, 5, 1, c)
    if bite <= 2
        f_rect(t, x, y + 1, 5, 2, c)
    if bite <= 3
        f_rect(t, x + 1, y + 3, 3, 2, c)

int lifeClock = barstate.islast ? timenow : time_close
varip int activeHatchCycleStart = na
bool newDay = na(activeHatchCycleStart) or hatchCycleStart != activeHatchCycleStart
if newDay
    activeHatchCycleStart := hatchCycleStart
int lifeElapsedMS = math.max(0, lifeClock - hatchCycleStart)
float ageMinutes = float(lifeElapsedMS) / 60000.0
float ageHours = float(lifeElapsedMS) / 3600000.0
string ageText = f_ageText(ageMinutes)
int dailyStage = ageMinutes < 15.0 ? 0 : ageMinutes < 45.0 ? 1 : ageMinutes < 225.0 ? 2 : 3
int stage = dailyStage
int renderStage = stage
int level = stage == 0 ? 0 : math.min(24, 1 + int(math.floor(ageHours)))

int ACT_IDLE = 0
int ACT_LOOK_L = 1
int ACT_LOOK_R = 2
int ACT_SLEEP = 3
int ACT_SCRATCH = 4
int ACT_YAWN = 5
int ACT_DANCE = 6
int ACT_GLASSES = 7
int ACT_COFFEE = 8
int ACT_LAPTOP = 9
int ACT_NEWSPAPER = 10
int ACT_CROWN = 11
int ACT_WAVE = 12
int ACT_CHEER = 13
int ACT_SHRUG = 14
int ACT_THINK = 15
int ACT_LAUGH = 16
int ACT_ANGRY = 17
int ACT_DIZZY = 18
int ACT_HEART = 19
int ACT_POPCORN = 20
int ACT_PHONE = 21
int ACT_BOOK = 22
int ACT_TELESCOPE = 23
int ACT_WORKOUT = 24
int ACT_MEDITATE = 25
int ACT_MUSIC = 26
int ACT_CONFETTI = 27
int ACT_RAIN = 28
int ACT_MAGNIFY = 29
int ACT_SNACK = 30
int ACT_LIGHTBULB = 31
int ACT_STARE = 32
int ACT_JUMP = 33
int ACT_SIT = 34
int ACT_HIDE = 35
int ACT_PEEK = 36
int ACT_SPIN = 37
int ACT_FLEX = 38
int ACT_CLAP = 39
int ACT_SNEEZE = 40
int ACT_HICCUP = 41
int ACT_DOZE = 42
int ACT_POINT = 43
int ACT_VICTORY = 44
int ACT_CHARTWATCH = 45

int INT_NONE = 0
int INT_WANDER = 1
int INT_COFFEE = 2
int INT_READ = 3
int INT_LAPTOP = 4
int INT_SLEEP = 5
int INT_MEDITATE = 6
int INT_SNACK = 7
int INT_FLAG = 8
int INT_WATCH = 9
int INT_PLAY = 10
int INT_PHONE = 11
int INT_TELESCOPE = 12
int INT_WORKOUT = 13
int INT_GROOM = 14
int INT_THINK = 15
int INT_SULK = 16
int INT_SMUG = 17
int INT_BELLY = 18
int INT_BUG = 19
int INT_PUSHUP = 20
int INT_HIDE = 21

int MOVE_STAY = 0
int MOVE_WALK = 1
int MOVE_MOON = 2
int MOVE_PACE = 3
int MOVE_DASH = 4

f_resumable(int i) => i == INT_COFFEE or i == INT_READ or i == INT_LAPTOP or i == INT_SLEEP or i == INT_MEDITATE or i == INT_PHONE or i == INT_TELESCOPE or i == INT_THINK

int ZONE_SLEEP = 8
int ZONE_SNACK = 22
int ZONE_CENTER = 34
int ZONE_COFFEE = 43
int ZONE_DESK = 48
int ZONE_WATCH = 57
int ZONE_FLAG = 58

f_topTraits(float a, float b, float c, float d, float e, float f, float g, float h) =>
    int first = 0
    int second = 1
    float firstV = a
    float secondV = b
    if secondV > firstV
        int tmpI = first
        first := second
        second := tmpI
        float tmpV = firstV
        firstV := secondV
        secondV := tmpV
    array<float> vals = array.from(a, b, c, d, e, f, g, h)
    for i = 2 to 7
        float v = array.get(vals, i)
        if v > firstV
            second := first
            secondV := firstV
            first := i
            firstV := v
        else if v > secondV
            second := i
            secondV := v
    [first, second]

f_traitName(int t) => t == 0 ? "CURIOUS" : t == 1 ? "CHILL" : t == 2 ? "BOLD" : t == 3 ? "CAUTIOUS" : t == 4 ? "PLAYFUL" : t == 5 ? "ANALYTICAL" : t == 6 ? "FOODIE" : "DRAMATIC"

float personaSeed = birthSeed + 991.17
float traitCuriosity = 0.18 + f_dnaRand(personaSeed + 11.31) * 0.82
float traitLaziness = 0.12 + f_dnaRand(personaSeed + 23.17) * 0.78
float traitConfidence = 0.15 + f_dnaRand(personaSeed + 37.91) * 0.85
float traitNervous = 0.10 + f_dnaRand(personaSeed + 51.73) * 0.80
float traitPlayful = 0.15 + f_dnaRand(personaSeed + 71.29) * 0.85
float traitNerdy = 0.12 + f_dnaRand(personaSeed + 89.47) * 0.88
float traitAppetite = 0.15 + f_dnaRand(personaSeed + 101.83) * 0.85
float traitDrama = 0.10 + f_dnaRand(personaSeed + 131.57) * 0.90
string personalityName = traitNerdy > 0.74 and traitCuriosity > 0.62 ? "QUANT" : traitPlayful > 0.76 ? "GREMLIN" : traitLaziness > 0.72 ? "LOAF" : traitNervous > 0.72 ? "WORRIER" : traitConfidence > 0.76 ? "HOTSHOT" : traitCuriosity > 0.72 ? "SCOUT" : "ODDBALL"
[topTraitA, topTraitB] = f_topTraits(traitCuriosity, traitLaziness, traitConfidence, traitNervous, traitPlayful, traitNerdy, traitAppetite, traitDrama)
string traitAName = f_traitName(topTraitA)
string traitBName = f_traitName(topTraitB)

int QUIRK_COFFEE = 0
int QUIRK_FLAG = 1
int QUIRK_FITNESS = 2
int QUIRK_NAPPER = 3
int QUIRK_WATCHER = 4
int QUIRK_SNACKER = 5
int QUIRK_SHOWBOAT = 6
int QUIRK_SKEPTIC = 7
int quirkA = int(math.floor(f_dnaRand(personaSeed + 211.77) * 8.0))
int quirkB0 = int(math.floor(f_dnaRand(personaSeed + 287.41) * 8.0))
int quirkB = quirkB0 == quirkA ? (quirkB0 + 3) % 8 : quirkB0
string quirkAName = quirkA == QUIRK_COFFEE ? "COFFEE" : quirkA == QUIRK_FLAG ? "FLAG" : quirkA == QUIRK_FITNESS ? "FIT" : quirkA == QUIRK_NAPPER ? "NAPPER" : quirkA == QUIRK_WATCHER ? "WATCHER" : quirkA == QUIRK_SNACKER ? "SNACK" : quirkA == QUIRK_SHOWBOAT ? "SHOWBOAT" : "SKEPTIC"
string quirkBName = quirkB == QUIRK_COFFEE ? "COFFEE" : quirkB == QUIRK_FLAG ? "FLAG" : quirkB == QUIRK_FITNESS ? "FIT" : quirkB == QUIRK_NAPPER ? "NAPPER" : quirkB == QUIRK_WATCHER ? "WATCHER" : quirkB == QUIRK_SNACKER ? "SNACK" : quirkB == QUIRK_SHOWBOAT ? "SHOWBOAT" : "SKEPTIC"
bool quirkCoffee = quirkA == QUIRK_COFFEE or quirkB == QUIRK_COFFEE
bool quirkFlag = quirkA == QUIRK_FLAG or quirkB == QUIRK_FLAG
bool quirkFitness = quirkA == QUIRK_FITNESS or quirkB == QUIRK_FITNESS
bool quirkNapper = quirkA == QUIRK_NAPPER or quirkB == QUIRK_NAPPER
bool quirkWatcher = quirkA == QUIRK_WATCHER or quirkB == QUIRK_WATCHER
bool quirkSnacker = quirkA == QUIRK_SNACKER or quirkB == QUIRK_SNACKER
bool quirkShowboat = quirkA == QUIRK_SHOWBOAT or quirkB == QUIRK_SHOWBOAT
bool quirkSkeptic = quirkA == QUIRK_SKEPTIC or quirkB == QUIRK_SKEPTIC

int favoriteSleepX = f_clampi(ZONE_SLEEP + int(math.round((traitLaziness - 0.5) * 8.0)), HOME_MIN_X, HOME_MAX_X)
int favoriteReadX = f_clampi(24 + int(math.round(traitNerdy * 18.0)), HOME_MIN_X, HOME_MAX_X)
int favoriteIdleX = f_clampi(16 + int(math.round(traitCuriosity * 34.0)), HOME_MIN_X, HOME_MAX_X)

varip float moodBoredom = 30.0
varip float moodStress = 18.0
varip float moodFatigue = 24.0
varip float moodHunger = 20.0
varip float moodCuriosity = 35.0
varip float moodFocus = 32.0
varip float moodConfidence = 48.0
varip int lastMoodBucket = -1

varip int currentIntent = INT_NONE
varip int intentPhase = 0
varip int intentPhaseStart = 0
varip int intentPhaseDuration = 0
varip int intentActionDuration = 0
varip int intentLongDuration = 0
varip int intentVariant = 0
varip int intentFromX = HOME_START_X
varip int intentToX = HOME_START_X
varip int moveMode = MOVE_STAY
varip int roamAnchorX = HOME_START_X
varip bool movementLocked = false
varip int lastBrainBucket = -1
varip int nextDecisionAfter = 0
varip int lastIntent1 = INT_NONE
varip int lastIntent2 = INT_NONE
varip int lastIntent3 = INT_NONE

varip bool resumePending = false
varip int resumeIntent = INT_NONE
varip int resumeX = HOME_START_X
varip int resumeRemaining = 0

varip bool pendingFlagRitual = false
varip bool pendingBellyNotice = false
varip int pendingMarketReaction = 0
varip int seenWaveBias = 99
varip int seenFlowBias = 99
varip int marketFlowFlips = 0
varip int marketTrendBars = 0
varip int marketChopBars = 0
varip int lastConfirmedFlowBias = 0
varip int lastMarketMemoryBar = -1
varip int lastMarketReactionBar = -100000

if staticChartling
    bool staticIdentityChanged = bar_index == 0 or renderStage != nz(renderStage[1], renderStage) or hatchId != nz(hatchId[1], hatchId)
    bool staticInitialCommit = barstate.islastconfirmedhistory or (barstate.islast and barstate.ishistory)
    bool staticRealtimeCommit = barstate.isrealtime and barstate.isconfirmed and staticIdentityChanged
    bool staticCommitDraw = staticInitialCommit or staticRealtimeCommit
    bool staticHudCommit = staticInitialCommit or barstate.isrealtime

    if staticCommitDraw
        for yy = 0 to SCREEN_H - 1
            for xx = 0 to SCREEN_W - 1
                table.cell_set_bgcolor(screen, xx, yy, C_VOID)

        f_rect(screen, 3, SCREEN_H - 1, SCREEN_W - 6, 1, C_GROUND)

        float hatchProgress = f_clamp(ageMinutes / 15.0, 0.0, 1.0)
        int crack = hatchProgress < 0.35 ? 0 : hatchProgress < 0.70 ? 1 : 2

        if renderStage == 0
            f_egg(screen, 11, 22, crack)
        else if renderStage == 1
            f_hatch(screen, 10, 17, false, false, C_CORE, C_BODY, false, false, 0, FACE_NORMAL)
        else if renderStage == 2
            f_young(screen, 8, 11, false, false, C_CORE, C_BODY, false, false, 0, false, FACE_NORMAL)
        else
            f_adult(screen, 8, 4, false, false, C_CORE, C_BODY, false, false, 0, false, false, FACE_NORMAL)

    if staticHudCommit
        if showHUD
            string rarityDisplay = rarityName == "LEGENDARY" ? "✦ LEGENDARY ✦" : rarityName == "MYSTICAL" ? "✦ MYSTICAL ✦" : rarityName == "VERY RARE" ? "✦ VERY RARE ✦" : rarityName
            string dnaCompact = paletteName
            dnaCompact += headStyle != "None" ? "/" + str.upper(headStyle) : ""
            dnaCompact += tailStyle != "None" ? "/" + str.upper(tailStyle) : ""
            dnaCompact += extraMarking != "None" ? "/" + str.upper(extraMarking) : ""
            dnaCompact += "/" + str.upper(coreStyle)
            string collectionText = manualInputInvalid ? "ENTER #000000001-#999999999 • SHOWING TODAY" : not trainerReady and not manualView ? "SET TRAINER CODE" : isKeeper ? "★ IN KEEPER LIST ★" : ""

            table.cell_set_text(hud, 0, 0, chartlingName + " • " + rarityDisplay)
            table.cell_set_text(hud, 0, 1, "#" + hatchIdText + " • AGE " + ageText)
            table.cell_set_text(hud, 0, 2, personalityName + " • " + traitAName + "/" + traitBName + " • " + quirkAName + "/" + quirkBName)
            table.cell_set_text(hud, 0, 3, dnaCompact + (str.length(collectionText) > 0 ? " • " + collectionText : ""))
            table.cell_set_text(hud, 0, 4, loreSentence)
            table.cell_set_text_color(hud, 0, 0, rarityColor)
            table.cell_set_text_color(hud, 0, 1, rarityColor)
            table.cell_set_text_color(hud, 0, 2, C_TEXT)
            table.cell_set_text_color(hud, 0, 3, rarityColor)
            table.cell_set_text_color(hud, 0, 4, C_TEXT)

            for yy = 0 to 4
                table.cell_set_bgcolor(hud, 0, yy, C_HUD_BG)
        else
            for yy = 0 to 4
                table.cell_set_text(hud, 0, yy, "")
                table.cell_set_bgcolor(hud, 0, yy, C_HUD_OFF)

else
    float chartTimeframeSeconds = timeframe.in_seconds()
    float senseTimeframeSeconds = timeframe.in_seconds(trendTF)
    bool useHigherSense = not na(chartTimeframeSeconds) and not na(senseTimeframeSeconds) and senseTimeframeSeconds > chartTimeframeSeconds
    string waveRequestTF = useHigherSense ? trendTF : timeframe.period
    [waveHighLocal, waveLowLocal] = f_wave(preType, preLen, postType, postLen)
    // f_waveHist offsets the expression by one bar, so lookahead_on uses confirmed higher-timeframe data.
    [waveHighHTF, waveLowHTF] = request.security(syminfo.tickerid, waveRequestTF, f_waveHist(preType, preLen, postType, postLen), lookahead = barmerge.lookahead_on)
    float waveHigh = useHigherSense ? waveHighHTF : waveHighLocal
    float waveLow = useHigherSense ? waveLowHTF : waveLowLocal

    float flowBase = (2.0 * (open[1] + close[1])) - high - low - open
    flowBase := flowBase < low ? (flowBase + low) / 2.0 : flowBase
    flowBase := flowBase > high ? (flowBase + high) / 2.0 : flowBase
    float flowEMA = ta.ema(flowBase, flowLen)
    float flowSMA = ta.sma(flowBase, flowLen)
    float flowWMA = ta.wma(flowBase, flowLen)
    float flowHMA = ta.hma(flowBase, flowLen)
    float flowRMA = ta.rma(flowBase, flowLen)
    float flowLine = flowType == "EMA" ? flowEMA : flowType == "WMA" ? flowWMA : flowType == "HMA" ? flowHMA : flowType == "RMA" ? flowRMA : flowSMA
    float flowDelta = close - flowLine
    int flowState = na(flowLine) ? 0 : close >= flowLine ? (flowDelta > flowDelta[1] ? 2 : 1) : (flowDelta < flowDelta[1] ? -2 : -1)
    color marketFlowColor = flowState == 2 ? color.rgb(0, 128, 192) : flowState == 1 ? color.rgb(102, 204, 255) : flowState == -2 ? color.rgb(192, 64, 64) : flowState == -1 ? color.rgb(255, 204, 128) : color.rgb(122, 108, 229)
    bool isFlowUp = flowState > 0
    bool isFlowDown = flowState < 0

    bool aboveWave = not na(waveHigh) and low > waveHigh and high > waveHigh
    bool belowWave = not na(waveLow) and high < waveLow and low < waveLow
    bool engineReady = not na(waveHigh) and not na(waveLow) and not na(flowLine)
    int waveBias = aboveWave ? 1 : belowWave ? -1 : 0
    bool flowWaveAgrees = waveBias != 0 and ((waveBias == 1 and isFlowUp) or (waveBias == -1 and isFlowDown))
    bool flowWaveConflict = waveBias != 0 and not flowWaveAgrees

    float reactionATR = ta.atr(14)
    float reactionATRMean = ta.sma(reactionATR, 50)
    float atrRel = na(reactionATRMean) or reactionATRMean == 0.0 ? 1.0 : reactionATR / reactionATRMean
    float volumeMean = ta.sma(volume, 50)
    float volumeRel = na(volume) or na(volumeMean) or volumeMean == 0.0 ? 1.0 : volume / volumeMean
    float rangeRel = na(reactionATR) or reactionATR == 0.0 ? 1.0 : (high - low) / reactionATR
    float trendRel = na(reactionATR) or reactionATR == 0.0 or na(flowLine) ? 0.0 : math.abs(close - flowLine) / reactionATR

    color marketBellyColor = not showFlowBelly or not engineReady ? C_BODY : marketFlowColor
    bool waveFlagOn = showWaveFlag and engineReady and waveBias != 0
    color waveFlagColor = waveBias == 1 ? C_BULL : C_BEAR

    int animClock = barstate.isrealtime ? timenow : time_close
    int animFrame = int(animClock / 450) % 4
    bool walkFrame = animFrame % 2 == 0
    bool blinkNow = int(animClock / 180) % 37 == 0
    int lookCycle = int(animClock / 1200) % 3
    int idleLook = lookCycle == 0 ? -1 : lookCycle == 1 ? 0 : 1
    int brainWindowMS = brainTickSeconds * 1000
    int brainBucket = int(animClock / brainWindowMS)
    int moodBucket = int(animClock / 3000)
    int microBucket = int(animClock / 4000)

    float energyRaw = 20.0 + atrRel * 24.0 + math.min(volumeRel, 3.0) * 18.0 + math.min(trendRel, 2.0) * 16.0
    int energy = int(math.round(f_clamp(energyRaw, 0.0, 100.0)))
    bool marketSleepy = stage > 0 and atrRel < 0.72 and volumeRel < 0.78
    bool powered = energy >= 82 and not marketSleepy
    color normalCore = energy >= 78 ? C_CORE_HOT : C_CORE

    if newDay
        moodBoredom := 24.0 + traitPlayful * 16.0
        moodStress := 12.0 + traitNervous * 22.0
        moodFatigue := 18.0 + traitLaziness * 18.0
        moodHunger := 14.0 + traitAppetite * 18.0
        moodCuriosity := 24.0 + traitCuriosity * 30.0
        moodFocus := 20.0 + traitNerdy * 24.0
        moodConfidence := 35.0 + traitConfidence * 35.0
        lastMoodBucket := -1
        currentIntent := INT_NONE
        intentPhase := 0
        intentPhaseStart := animClock
        intentPhaseDuration := 0
        intentActionDuration := 0
        intentLongDuration := 0
        intentVariant := 0
        intentFromX := HOME_START_X
        intentToX := HOME_START_X
        moveMode := MOVE_STAY
        roamAnchorX := HOME_START_X
        movementLocked := false
        lastBrainBucket := -1
        nextDecisionAfter := 0
        lastIntent1 := INT_NONE
        lastIntent2 := INT_NONE
        lastIntent3 := INT_NONE
        resumePending := false
        resumeIntent := INT_NONE
        resumeX := HOME_START_X
        resumeRemaining := 0
        pendingFlagRitual := false
        pendingBellyNotice := false
        pendingMarketReaction := 0
        seenWaveBias := 99
        seenFlowBias := 99
        marketFlowFlips := 0
        marketTrendBars := 0
        marketChopBars := 0
        lastConfirmedFlowBias := 0
        lastMarketMemoryBar := -1
        lastMarketReactionBar := -100000

    int flowBiasNow = flowState > 0 ? 1 : -1

    if engineReady and stage > 0
        if seenWaveBias == 99
            seenWaveBias := waveBias
        else if waveBias != seenWaveBias
            seenWaveBias := waveBias
            pendingFlagRitual := true
            moodCuriosity := f_clamp(moodCuriosity + 24.0, 0.0, 100.0)
            moodFocus := f_clamp(moodFocus + 18.0, 0.0, 100.0)
        if seenFlowBias == 99
            seenFlowBias := flowBiasNow
        else if flowBiasNow != seenFlowBias
            seenFlowBias := flowBiasNow
            pendingBellyNotice := true
            moodCuriosity := f_clamp(moodCuriosity + 16.0, 0.0, 100.0)

    if stage > 0 and moodBucket != lastMoodBucket
        lastMoodBucket := moodBucket
        float heat = f_clamp((atrRel - 0.70) / 1.40, 0.0, 1.0)
        float quiet = f_clamp((0.95 - volumeRel) / 0.65, 0.0, 1.0)
        moodBoredom := f_clamp(moodBoredom + 1.2 + quiet * (2.2 + traitPlayful * 2.0) - heat * 1.5, 0.0, 100.0)
        moodStress := f_clamp(moodStress + heat * (2.5 + traitNervous * 5.5) + (flowWaveConflict ? 2.0 : -1.0 - traitConfidence), 0.0, 100.0)
        moodFatigue := f_clamp(moodFatigue + 0.9 + quiet * 1.4 + traitLaziness * 0.9 - heat * 0.8, 0.0, 100.0)
        moodHunger := f_clamp(moodHunger + 0.9 + traitAppetite * 1.6, 0.0, 100.0)
        moodCuriosity := f_clamp(moodCuriosity + 0.8 + traitCuriosity * 1.2 + (math.abs(flowState) == 2 ? 1.0 : 0.0), 0.0, 100.0)
        moodFocus := f_clamp(moodFocus + (waveBias != 0 ? 4.0 : math.abs(flowState) == 2 ? 2.0 : -1.1) + traitNerdy * 0.8, 0.0, 100.0)
        moodConfidence := f_clamp(moodConfidence + (flowWaveAgrees ? 2.0 : flowWaveConflict ? -2.5 : 0.2) + traitConfidence * 0.4 - traitNervous * 0.3, 0.0, 100.0)
        if currentIntent == INT_SLEEP and intentPhase >= 2
            moodFatigue := f_clamp(moodFatigue - 8.0, 0.0, 100.0)
            moodStress := f_clamp(moodStress - 2.0, 0.0, 100.0)
        if currentIntent == INT_COFFEE and intentPhase == 1
            moodFatigue := f_clamp(moodFatigue - 4.0, 0.0, 100.0)
            moodFocus := f_clamp(moodFocus + 2.0, 0.0, 100.0)
        if currentIntent == INT_SNACK and intentPhase == 1
            moodHunger := f_clamp(moodHunger - 10.0, 0.0, 100.0)
        if currentIntent == INT_MEDITATE and intentPhase == 1
            moodStress := f_clamp(moodStress - 7.0, 0.0, 100.0)
        if currentIntent == INT_PLAY and intentPhase == 1
            moodBoredom := f_clamp(moodBoredom - 7.0, 0.0, 100.0)
        if currentIntent == INT_FLAG and intentPhase >= 1
            moodCuriosity := f_clamp(moodCuriosity - 4.0, 0.0, 100.0)
        if currentIntent == INT_WATCH and intentPhase >= 1
            moodFocus := f_clamp(moodFocus - 2.0, 0.0, 100.0)

    if barstate.isconfirmed and engineReady and stage > 0 and bar_index != lastMarketMemoryBar
        lastMarketMemoryBar := bar_index
        int confirmedFlowBias = flowState > 0 ? 1 : -1
        if lastConfirmedFlowBias != 0 and confirmedFlowBias != lastConfirmedFlowBias
            marketFlowFlips += 1
        else
            marketFlowFlips := math.max(0, marketFlowFlips - 1)
        lastConfirmedFlowBias := confirmedFlowBias
        bool alignedTrendMemory = waveBias != 0 and flowWaveAgrees and math.abs(flowState) == 2
        bool chopMemory = waveBias == 0 or flowWaveConflict
        marketTrendBars := alignedTrendMemory ? marketTrendBars + 1 : 0
        marketChopBars := chopMemory ? marketChopBars + 1 : 0
        bool memoryReady = bar_index - lastMarketReactionBar >= 6
        if memoryReady and marketFlowFlips >= 3
            pendingMarketReaction := -1
            moodStress := f_clamp(moodStress + 8.0 + traitNervous * 6.0, 0.0, 100.0)
            moodConfidence := f_clamp(moodConfidence - 5.0 - traitDrama * 3.0, 0.0, 100.0)
            marketFlowFlips := 0
            lastMarketReactionBar := bar_index
        else if memoryReady and marketTrendBars >= 8
            pendingMarketReaction := 1
            moodConfidence := f_clamp(moodConfidence + 7.0 + traitConfidence * 4.0, 0.0, 100.0)
            moodFocus := f_clamp(moodFocus + 6.0, 0.0, 100.0)
            marketTrendBars := 0
            lastMarketReactionBar := bar_index
        else if memoryReady and marketChopBars >= 10
            pendingMarketReaction := 2
            moodBoredom := f_clamp(moodBoredom + 8.0, 0.0, 100.0)
            moodCuriosity := f_clamp(moodCuriosity + 5.0 + traitCuriosity * 3.0, 0.0, 100.0)
            marketChopBars := 0
            lastMarketReactionBar := bar_index

    bool finishIntent = false
    int intentElapsed = currentIntent == INT_NONE ? 0 : math.max(0, animClock - intentPhaseStart)

    if currentIntent != INT_NONE and not movementLocked
        if intentPhase == 0 and intentElapsed >= intentPhaseDuration
            roamAnchorX := intentToX
            intentFromX := intentToX
            intentPhase := 1
            intentPhaseStart := animClock
            intentPhaseDuration := currentIntent == INT_SLEEP ? 3000 : currentIntent == INT_FLAG ? 2600 : currentIntent == INT_PUSHUP ? 3500 : intentActionDuration
        else if intentPhase == 1 and intentElapsed >= intentPhaseDuration
            if currentIntent == INT_SLEEP
                intentPhase := 2
                intentPhaseStart := animClock
                intentPhaseDuration := intentLongDuration
            else if currentIntent == INT_FLAG
                intentPhase := 2
                intentPhaseStart := animClock
                intentPhaseDuration := 3200
            else if currentIntent == INT_READ or currentIntent == INT_COFFEE or currentIntent == INT_LAPTOP
                intentPhase := 2
                intentPhaseStart := animClock
                intentPhaseDuration := currentIntent == INT_READ ? 4500 : 3200
            else if currentIntent == INT_PUSHUP
                intentPhase := 2
                intentPhaseStart := animClock
                intentPhaseDuration := 4200
            else
                finishIntent := true
        else if intentPhase == 2 and intentElapsed >= intentPhaseDuration
            if currentIntent == INT_SLEEP
                intentPhase := 3
                intentPhaseStart := animClock
                intentPhaseDuration := 4200
            else if currentIntent == INT_FLAG
                intentPhase := 3
                intentPhaseStart := animClock
                intentPhaseDuration := 2200
            else
                finishIntent := true
        else if intentPhase == 3 and intentElapsed >= intentPhaseDuration
            finishIntent := true

    if finishIntent
        lastIntent3 := lastIntent2
        lastIntent2 := lastIntent1
        lastIntent1 := currentIntent
        currentIntent := INT_NONE
        intentPhase := 0
        intentPhaseStart := animClock
        intentPhaseDuration := 0
        moveMode := MOVE_STAY
        nextDecisionAfter := animClock + 1000 + int(f_rand(personaSeed * 0.031 + float(brainBucket) * 4.113) * (2800.0 + traitLaziness * 2200.0))

    bool urgentIntentWaiting = pendingFlagRitual or pendingBellyNotice or pendingMarketReaction != 0 or resumePending
    bool canChooseIntent = stage > 0 and not movementLocked and currentIntent == INT_NONE and (urgentIntentWaiting or (brainBucket != lastBrainBucket and animClock >= nextDecisionAfter))

    if canChooseIntent
        lastBrainBucket := brainBucket
        float decisionSeed = personaSeed * 0.017 + float(brainBucket) * 2.731 + float(level) * 0.417
        int chosenIntent = INT_WANDER
        int chosenVariant = int(math.floor(f_rand(decisionSeed + 7.3) * 6.0))
        int chosenTarget = roamAnchorX
        int chosenMoveMode = MOVE_WALK
        int chosenActionDuration = 7000
        int chosenLongDuration = 0

        if pendingFlagRitual
            chosenIntent := INT_FLAG
            chosenTarget := ZONE_FLAG
            chosenActionDuration := 2600
            pendingFlagRitual := false
        else if pendingBellyNotice
            chosenIntent := INT_BELLY
            chosenTarget := roamAnchorX
            chosenActionDuration := 5200
            pendingBellyNotice := false
        else if pendingMarketReaction != 0
            chosenIntent := pendingMarketReaction == 1 ? INT_SMUG : pendingMarketReaction == -1 ? INT_SULK : INT_THINK
            chosenTarget := roamAnchorX
            chosenActionDuration := pendingMarketReaction == 1 ? 9000 : pendingMarketReaction == -1 ? 10000 : 6500
            chosenVariant := pendingMarketReaction == 1 and (traitConfidence > 0.62 or quirkShowboat) ? 1 : pendingMarketReaction == -1 and traitDrama > 0.60 ? 1 : chosenVariant
            pendingMarketReaction := 0
        else if resumePending
            chosenIntent := resumeIntent
            chosenTarget := resumeX
            chosenActionDuration := math.max(3500, resumeRemaining)
            resumePending := false
        else
            float nWander = f_rand(decisionSeed + 10.1) * 20.0 * quirkiness
            float nCoffee = f_rand(decisionSeed + 20.2) * 18.0
            float nRead = f_rand(decisionSeed + 30.3) * 18.0
            float nLaptop = f_rand(decisionSeed + 40.4) * 18.0
            float nSleep = f_rand(decisionSeed + 50.5) * 14.0
            float nMeditate = f_rand(decisionSeed + 60.6) * 16.0
            float nSnack = f_rand(decisionSeed + 70.7) * 16.0
            float nFlag = f_rand(decisionSeed + 80.8) * 18.0
            float nWatch = f_rand(decisionSeed + 90.9) * 17.0
            float nPlay = f_rand(decisionSeed + 101.1) * 22.0 * quirkiness
            float nPhone = f_rand(decisionSeed + 111.2) * 16.0
            float nScope = f_rand(decisionSeed + 121.3) * 17.0
            float nWorkout = f_rand(decisionSeed + 131.4) * 17.0
            float nGroom = f_rand(decisionSeed + 141.5) * 17.0 * quirkiness
            float nThink = f_rand(decisionSeed + 151.6) * 17.0
            float nBug = f_rand(decisionSeed + 161.7) * 18.0 * quirkiness
            float nPush = f_rand(decisionSeed + 171.8) * 15.0 * quirkiness
            float nHide = f_rand(decisionSeed + 181.9) * 14.0

            float uWander = (moodCuriosity * 0.42 + moodBoredom * 0.34 + traitCuriosity * 28.0 + nWander) * f_repeatPenalty(INT_WANDER, lastIntent1, lastIntent2, lastIntent3)
            float uCoffee = (moodFatigue * 0.58 + moodFocus * 0.12 + traitNerdy * 17.0 + nCoffee + (quirkCoffee ? 24.0 : 0.0)) * f_repeatPenalty(INT_COFFEE, lastIntent1, lastIntent2, lastIntent3)
            float uRead = (moodBoredom * 0.26 + traitNerdy * 38.0 + traitLaziness * 12.0 + nRead) * f_repeatPenalty(INT_READ, lastIntent1, lastIntent2, lastIntent3)
            float uLaptop = (moodFocus * 0.48 + traitNerdy * 38.0 + moodCuriosity * 0.12 + nLaptop) * f_repeatPenalty(INT_LAPTOP, lastIntent1, lastIntent2, lastIntent3)
            float uSleep = (moodFatigue * 0.88 + traitLaziness * 28.0 - moodStress * 0.10 + nSleep + (quirkNapper ? 22.0 : 0.0)) * f_repeatPenalty(INT_SLEEP, lastIntent1, lastIntent2, lastIntent3)
            float uMeditate = (moodStress * 0.72 + traitLaziness * 9.0 + (1.0 - traitDrama) * 10.0 + nMeditate) * f_repeatPenalty(INT_MEDITATE, lastIntent1, lastIntent2, lastIntent3)
            float uSnack = (moodHunger * 0.86 + traitAppetite * 34.0 + nSnack + (quirkSnacker ? 24.0 : 0.0)) * f_repeatPenalty(INT_SNACK, lastIntent1, lastIntent2, lastIntent3)
            float uFlag = (moodCuriosity * 0.46 + traitCuriosity * 25.0 + traitNerdy * 14.0 + nFlag + (quirkFlag ? 25.0 : 0.0) + (quirkSkeptic ? 12.0 : 0.0)) * (waveBias != 0 ? 1.0 : 0.35) * f_repeatPenalty(INT_FLAG, lastIntent1, lastIntent2, lastIntent3)
            float uWatch = (moodFocus * 0.54 + traitNerdy * 25.0 + traitConfidence * 12.0 + math.min(trendRel, 2.0) * 9.0 + nWatch + (waveBias != 0 ? 10.0 : 0.0) + (flowWaveConflict ? 12.0 : 0.0) + (quirkWatcher ? 24.0 : 0.0) + (quirkSkeptic ? 10.0 : 0.0)) * f_repeatPenalty(INT_WATCH, lastIntent1, lastIntent2, lastIntent3)
            float uPlay = (moodBoredom * 0.60 + traitPlayful * 42.0 - moodFatigue * 0.24 + nPlay + (quirkShowboat ? 22.0 : 0.0)) * f_repeatPenalty(INT_PLAY, lastIntent1, lastIntent2, lastIntent3)
            float uPhone = (moodBoredom * 0.38 + traitLaziness * 13.0 + nPhone) * f_repeatPenalty(INT_PHONE, lastIntent1, lastIntent2, lastIntent3)
            float uScope = (moodCuriosity * 0.48 + traitNerdy * 22.0 + traitCuriosity * 15.0 + nScope) * f_repeatPenalty(INT_TELESCOPE, lastIntent1, lastIntent2, lastIntent3)
            float uWorkout = ((100.0 - moodFatigue) * 0.26 + (1.0 - traitLaziness) * 32.0 + traitConfidence * 18.0 + nWorkout + (quirkFitness ? 26.0 : 0.0)) * f_repeatPenalty(INT_WORKOUT, lastIntent1, lastIntent2, lastIntent3)
            float uGroom = (traitNervous * 18.0 + traitConfidence * 8.0 + nGroom + 22.0) * f_repeatPenalty(INT_GROOM, lastIntent1, lastIntent2, lastIntent3)
            float uThink = (moodCuriosity * 0.28 + moodStress * 0.18 + traitCuriosity * 22.0 + traitNerdy * 18.0 + nThink + (quirkSkeptic ? 20.0 : 0.0)) * f_repeatPenalty(INT_THINK, lastIntent1, lastIntent2, lastIntent3)
            float uBug = (moodCuriosity * 0.52 + traitCuriosity * 34.0 + traitPlayful * 18.0 + nBug) * f_repeatPenalty(INT_BUG, lastIntent1, lastIntent2, lastIntent3)
            float uPush = ((100.0 - moodFatigue) * 0.18 + traitPlayful * 18.0 + (1.0 - traitLaziness) * 18.0 + nPush) * f_repeatPenalty(INT_PUSHUP, lastIntent1, lastIntent2, lastIntent3)
            float uHide = (moodStress * 0.58 + traitNervous * 30.0 + traitDrama * 12.0 + nHide) * f_repeatPenalty(INT_HIDE, lastIntent1, lastIntent2, lastIntent3)

            float bestScore = uWander
            chosenIntent := INT_WANDER
            if uCoffee > bestScore
                bestScore := uCoffee
                chosenIntent := INT_COFFEE
            if uRead > bestScore
                bestScore := uRead
                chosenIntent := INT_READ
            if uLaptop > bestScore
                bestScore := uLaptop
                chosenIntent := INT_LAPTOP
            if uSleep > bestScore
                bestScore := uSleep
                chosenIntent := INT_SLEEP
            if uMeditate > bestScore
                bestScore := uMeditate
                chosenIntent := INT_MEDITATE
            if uSnack > bestScore
                bestScore := uSnack
                chosenIntent := INT_SNACK
            if uFlag > bestScore
                bestScore := uFlag
                chosenIntent := INT_FLAG
            if uWatch > bestScore
                bestScore := uWatch
                chosenIntent := INT_WATCH
            if uPlay > bestScore
                bestScore := uPlay
                chosenIntent := INT_PLAY
            if uPhone > bestScore
                bestScore := uPhone
                chosenIntent := INT_PHONE
            if uScope > bestScore
                bestScore := uScope
                chosenIntent := INT_TELESCOPE
            if uWorkout > bestScore
                bestScore := uWorkout
                chosenIntent := INT_WORKOUT
            if uGroom > bestScore
                bestScore := uGroom
                chosenIntent := INT_GROOM
            if uThink > bestScore
                bestScore := uThink
                chosenIntent := INT_THINK
            if uBug > bestScore
                bestScore := uBug
                chosenIntent := INT_BUG
            if uPush > bestScore
                bestScore := uPush
                chosenIntent := INT_PUSHUP
            if uHide > bestScore
                bestScore := uHide
                chosenIntent := INT_HIDE

            float targetRoll = f_rand(decisionSeed + 212.7)
            if chosenIntent == INT_WANDER
                chosenTarget := f_clampi(HOME_MIN_X + int(math.floor(targetRoll * float(HOME_MAX_X - HOME_MIN_X + 1))), HOME_MIN_X, HOME_MAX_X)
                if math.abs(chosenTarget - roamAnchorX) < 12
                    chosenTarget := roamAnchorX < favoriteIdleX ? math.min(HOME_MAX_X, roamAnchorX + 18) : math.max(HOME_MIN_X, roamAnchorX - 18)
                chosenMoveMode := chosenVariant == 0 and traitPlayful > 0.45 ? MOVE_MOON : chosenVariant == 1 and traitNervous > 0.55 ? MOVE_PACE : MOVE_WALK
                chosenActionDuration := 3000 + int(f_rand(decisionSeed + 213.9) * 5000.0)
            else if chosenIntent == INT_COFFEE
                chosenTarget := ZONE_COFFEE
                chosenActionDuration := int((12000.0 + f_rand(decisionSeed + 220.2) * 12000.0) / liveliness)
            else if chosenIntent == INT_READ
                chosenTarget := favoriteReadX
                chosenActionDuration := int((18000.0 + traitNerdy * 18000.0 + f_rand(decisionSeed + 230.3) * 14000.0) / liveliness)
            else if chosenIntent == INT_LAPTOP
                chosenTarget := ZONE_DESK
                chosenActionDuration := int((16000.0 + traitNerdy * 15000.0 + f_rand(decisionSeed + 240.4) * 12000.0) / liveliness)
            else if chosenIntent == INT_SLEEP
                chosenTarget := favoriteSleepX
                chosenActionDuration := 3000
                chosenLongDuration := int(((allowLongNaps ? 26000.0 : 15000.0) + traitLaziness * (allowLongNaps ? 42000.0 : 18000.0) + f_rand(decisionSeed + 250.5) * 18000.0) / liveliness)
            else if chosenIntent == INT_MEDITATE
                chosenTarget := ZONE_CENTER
                chosenActionDuration := int((14000.0 + f_rand(decisionSeed + 260.6) * 16000.0) / liveliness)
            else if chosenIntent == INT_SNACK
                chosenTarget := ZONE_SNACK
                chosenActionDuration := int((8000.0 + traitAppetite * 9000.0 + f_rand(decisionSeed + 270.7) * 7000.0) / liveliness)
            else if chosenIntent == INT_FLAG
                chosenTarget := ZONE_FLAG
                chosenActionDuration := 2600
            else if chosenIntent == INT_WATCH
                chosenTarget := ZONE_WATCH
                chosenActionDuration := int((9000.0 + traitNerdy * 12000.0 + f_rand(decisionSeed + 290.9) * 9000.0) / liveliness)
            else if chosenIntent == INT_PLAY
                chosenTarget := roamAnchorX
                chosenActionDuration := int((6000.0 + f_rand(decisionSeed + 301.1) * 9000.0) / liveliness)
            else if chosenIntent == INT_PHONE
                chosenTarget := roamAnchorX
                chosenActionDuration := int((9000.0 + f_rand(decisionSeed + 311.2) * 13000.0) / liveliness)
            else if chosenIntent == INT_TELESCOPE
                chosenTarget := ZONE_WATCH
                chosenActionDuration := int((10000.0 + f_rand(decisionSeed + 321.3) * 15000.0) / liveliness)
            else if chosenIntent == INT_WORKOUT
                chosenTarget := ZONE_CENTER
                chosenActionDuration := int((8000.0 + f_rand(decisionSeed + 331.4) * 10000.0) / liveliness)
            else if chosenIntent == INT_GROOM
                chosenTarget := roamAnchorX
                chosenActionDuration := 2500 + int(f_rand(decisionSeed + 341.5) * 5500.0)
            else if chosenIntent == INT_THINK
                chosenTarget := roamAnchorX
                chosenActionDuration := 6000 + int(f_rand(decisionSeed + 351.6) * 8000.0)
            else if chosenIntent == INT_BUG
                chosenTarget := f_clampi(HOME_MIN_X + int(math.floor(targetRoll * float(HOME_MAX_X - HOME_MIN_X + 1))), HOME_MIN_X, HOME_MAX_X)
                chosenMoveMode := MOVE_DASH
                chosenActionDuration := 6500 + int(f_rand(decisionSeed + 361.7) * 6500.0)
            else if chosenIntent == INT_PUSHUP
                chosenTarget := ZONE_CENTER
                chosenActionDuration := 3500
            else if chosenIntent == INT_HIDE
                chosenTarget := favoriteSleepX
                chosenActionDuration := 8000 + int(f_rand(decisionSeed + 381.9) * 9000.0)

        currentIntent := chosenIntent
        intentVariant := chosenVariant
        intentFromX := roamAnchorX
        intentToX := f_clampi(chosenTarget, HOME_MIN_X, HOME_MAX_X)
        moveMode := chosenMoveMode
        intentActionDuration := math.max(1800, chosenActionDuration)
        intentLongDuration := chosenLongDuration
        int travelDistance = math.abs(intentToX - intentFromX)
        int travelMS = int((900.0 + float(travelDistance) * (moveMode == MOVE_DASH ? 42.0 : moveMode == MOVE_MOON ? 76.0 : 62.0)) / liveliness)
        if travelDistance <= 2
            intentPhase := 1
            intentPhaseStart := animClock
            intentPhaseDuration := currentIntent == INT_SLEEP ? 3000 : currentIntent == INT_FLAG ? 2600 : currentIntent == INT_PUSHUP ? 3500 : intentActionDuration
            moveMode := MOVE_STAY
        else
            intentPhase := 0
            intentPhaseStart := animClock
            intentPhaseDuration := math.max(900, travelMS)

    int liveIntentElapsed = currentIntent == INT_NONE ? 0 : math.max(0, animClock - intentPhaseStart)
    float homeWalkProgress = currentIntent != INT_NONE and intentPhase == 0 and intentPhaseDuration > 0 ? f_clamp(float(liveIntentElapsed) / float(intentPhaseDuration), 0.0, 1.0) : 1.0
    float homeWalkSmooth = homeWalkProgress * homeWalkProgress * (3.0 - 2.0 * homeWalkProgress)
    bool homeWalkingAction = currentIntent != INT_NONE and intentPhase == 0 and math.abs(intentToX - intentFromX) > 2
    int naturalHomeX = homeWalkingAction ? intentFromX + int(math.round(float(intentToX - intentFromX) * homeWalkSmooth)) : roamAnchorX
    moveMode := homeWalkingAction ? moveMode : MOVE_STAY

    int idleAction = ACT_IDLE
    if currentIntent == INT_WANDER
        idleAction := intentPhase == 0 ? (intentToX < intentFromX ? ACT_LOOK_L : ACT_LOOK_R) : intentVariant % 3 == 0 ? ACT_SCRATCH : intentVariant % 3 == 1 ? ACT_STARE : ACT_PEEK
    else if currentIntent == INT_COFFEE
        idleAction := intentPhase == 0 ? (intentToX < intentFromX ? ACT_LOOK_L : ACT_LOOK_R) : intentPhase == 1 ? ACT_COFFEE : ACT_LIGHTBULB
    else if currentIntent == INT_READ
        idleAction := intentPhase == 0 ? (intentToX < intentFromX ? ACT_LOOK_L : ACT_LOOK_R) : intentPhase == 1 ? ACT_NEWSPAPER : ACT_CHARTWATCH
    else if currentIntent == INT_LAPTOP
        idleAction := intentPhase == 0 ? (intentToX < intentFromX ? ACT_LOOK_L : ACT_LOOK_R) : intentPhase == 1 ? ACT_LAPTOP : ACT_LIGHTBULB
    else if currentIntent == INT_SLEEP
        idleAction := intentPhase == 0 ? (intentToX < intentFromX ? ACT_LOOK_L : ACT_LOOK_R) : intentPhase == 1 ? ACT_YAWN : intentPhase == 2 ? ACT_SLEEP : ACT_FLEX
    else if currentIntent == INT_MEDITATE
        idleAction := intentPhase == 0 ? (intentToX < intentFromX ? ACT_LOOK_L : ACT_LOOK_R) : ACT_MEDITATE
    else if currentIntent == INT_SNACK
        idleAction := intentPhase == 0 ? (intentToX < intentFromX ? ACT_LOOK_L : ACT_LOOK_R) : ACT_SNACK
    else if currentIntent == INT_FLAG
        idleAction := intentPhase == 0 ? ACT_CHARTWATCH : intentPhase == 1 ? ACT_STARE : intentPhase == 2 ? ACT_POINT : waveBias == 0 ? ACT_SHRUG : ACT_CHEER
    else if currentIntent == INT_WATCH
        idleAction := intentPhase == 0 ? ACT_CHARTWATCH : liveIntentElapsed > 11000 and flowWaveConflict ? ACT_POINT : ACT_CHARTWATCH
    else if currentIntent == INT_PLAY
        idleAction := intentVariant == 0 ? ACT_DANCE : intentVariant == 1 ? ACT_CLAP : intentVariant == 2 ? ACT_JUMP : intentVariant == 3 ? ACT_SPIN : intentVariant == 4 ? ACT_MUSIC : ACT_WAVE
    else if currentIntent == INT_PHONE
        idleAction := ACT_PHONE
    else if currentIntent == INT_TELESCOPE
        idleAction := intentPhase == 0 ? ACT_CHARTWATCH : ACT_TELESCOPE
    else if currentIntent == INT_WORKOUT
        idleAction := intentPhase == 0 ? ACT_LOOK_R : intentVariant % 2 == 0 ? ACT_WORKOUT : ACT_FLEX
    else if currentIntent == INT_GROOM
        idleAction := intentVariant == 0 ? ACT_SCRATCH : intentVariant == 1 ? ACT_SNEEZE : intentVariant == 2 ? ACT_HICCUP : intentVariant == 3 ? ACT_PEEK : ACT_GLASSES
    else if currentIntent == INT_THINK
        idleAction := intentVariant % 3 == 0 ? ACT_THINK : intentVariant % 3 == 1 ? ACT_LIGHTBULB : ACT_SHRUG
    else if currentIntent == INT_SULK
        idleAction := intentVariant % 3 == 0 ? ACT_RAIN : intentVariant % 3 == 1 ? ACT_ANGRY : ACT_HIDE
    else if currentIntent == INT_SMUG
        idleAction := intentVariant % 3 == 0 ? ACT_CROWN : intentVariant % 3 == 1 ? ACT_VICTORY : ACT_CONFETTI
    else if currentIntent == INT_BELLY
        idleAction := intentVariant % 2 == 0 ? ACT_STARE : ACT_SHRUG
    else if currentIntent == INT_BUG
        idleAction := intentPhase == 0 ? ACT_LOOK_R : intentVariant % 2 == 0 ? ACT_MAGNIFY : ACT_JUMP
    else if currentIntent == INT_PUSHUP
        idleAction := intentPhase == 0 ? ACT_LOOK_R : intentPhase == 1 ? ACT_WORKOUT : ACT_SHRUG
    else if currentIntent == INT_HIDE
        idleAction := intentPhase == 0 ? ACT_LOOK_L : intentVariant % 2 == 0 ? ACT_HIDE : ACT_PEEK

    if currentIntent == INT_NONE and stage > 0 and not movementLocked
        float micro = f_rand(personaSeed * 0.023 + float(microBucket) * 1.771)
        idleAction := micro < 0.08 + traitNervous * 0.08 ? ACT_SCRATCH : micro < 0.14 + traitLaziness * 0.08 ? ACT_SIT : micro < 0.20 + traitPlayful * 0.08 ? ACT_WAVE : micro < 0.25 + traitConfidence * 0.05 ? ACT_FLEX : micro < 0.31 + traitCuriosity * 0.07 ? ACT_PEEK : ACT_IDLE

    varip int eventMode = 0
    varip int eventStart = 0
    varip int lastFoodBar = -1
    varip int lastShockBar = -1
    varip bool foodBull = true
    varip int eventHomeX = HOME_START_X

    if newDay
        eventMode := 0
        eventStart := 0
        lastFoodBar := -1
        lastShockBar := -1
        foodBull := true
        eventHomeX := HOME_START_X

    int eventElapsed = eventMode > 0 ? math.max(0, animClock - eventStart) : 0
    if eventMode == 1 and eventElapsed > 5600
        eventMode := 0
        movementLocked := false
    if eventMode == 2 and eventElapsed > 1700
        eventMode := 0
        movementLocked := false

    bool foodTrigger = enableFood and stage > 0 and barstate.isrealtime and eventMode == 0 and bar_index != lastFoodBar and (volumeRel >= foodVolume or rangeRel >= foodRange)
    bool shockTrigger = enableShock and stage > 0 and barstate.isrealtime and eventMode == 0 and bar_index != lastShockBar and (atrRel >= shockATR or volumeRel >= shockVolume)

    if eventMode == 0
        if shockTrigger
            if f_resumable(currentIntent) and intentPhase > 0
                resumePending := true
                resumeIntent := currentIntent
                resumeX := roamAnchorX
                resumeRemaining := math.max(3000, intentPhaseDuration - math.max(0, animClock - intentPhaseStart))
            currentIntent := INT_NONE
            intentPhase := 0
            idleAction := ACT_IDLE
            eventMode := 2
            eventStart := animClock
            lastShockBar := bar_index
            eventHomeX := naturalHomeX
            roamAnchorX := naturalHomeX
            moveMode := MOVE_STAY
            movementLocked := true
            moodStress := f_clamp(moodStress + 20.0 * traitNervous + 8.0 * traitDrama, 0.0, 100.0)
        else if foodTrigger and moodHunger > 38.0
            if f_resumable(currentIntent) and intentPhase > 0
                resumePending := true
                resumeIntent := currentIntent
                resumeX := roamAnchorX
                resumeRemaining := math.max(3000, intentPhaseDuration - math.max(0, animClock - intentPhaseStart))
            currentIntent := INT_NONE
            intentPhase := 0
            idleAction := ACT_IDLE
            eventMode := 1
            eventStart := animClock
            lastFoodBar := bar_index
            foodBull := close >= open
            eventHomeX := naturalHomeX
            roamAnchorX := naturalHomeX
            moveMode := MOVE_STAY
            movementLocked := true
            moodHunger := f_clamp(moodHunger - 18.0, 0.0, 100.0)

    bool foodNotice = eventMode == 1 and eventElapsed < 600
    bool foodWalk = eventMode == 1 and eventElapsed >= 600 and eventElapsed < 2100
    bool foodEat = eventMode == 1 and eventElapsed >= 2100 and eventElapsed < 3100
    bool foodHappy = eventMode == 1 and eventElapsed >= 3100 and eventElapsed < 4000
    bool foodReturn = eventMode == 1 and eventElapsed >= 4000
    bool shocking = eventMode == 2

    int petX = naturalHomeX
    int foodX = SAFE_LEFT_X + 4

    if foodWalk
        float p = f_clamp(float(eventElapsed - 600) / 1500.0, 0.0, 1.0)
        petX := eventHomeX + int(math.round(float(foodX - eventHomeX) * p))
    if foodEat or foodHappy
        petX := foodX
    if foodReturn
        float p = f_clamp(float(eventElapsed - 4000) / 1600.0, 0.0, 1.0)
        petX := foodX + int(math.round(float(eventHomeX - foodX) * p))
    if shocking
        petX := eventHomeX

    int petY = renderStage == 1 ? 28 : renderStage == 2 ? 22 : 15
    if renderStage == 0
        petY := 27
    if shocking
        petY -= animFrame % 2 == 0 ? 3 : 0
    if foodHappy
        petY -= animFrame % 2 == 0 ? 2 : 0
    if idleAction == ACT_DANCE or idleAction == ACT_CHEER or idleAction == ACT_JUMP or idleAction == ACT_VICTORY
        petY -= animFrame % 2 == 0 ? 2 : 0
    if idleAction == ACT_SIT or idleAction == ACT_DOZE
        petY += 2
    if idleAction == ACT_HIDE
        petY += 6
    if idleAction == ACT_HICCUP and animFrame == 1
        petY -= 1
    if idleAction == ACT_SNEEZE and animFrame == 1
        petY += 1
    if currentIntent == INT_NONE and eventMode == 0 and animFrame == 2
        petY += 1

    bool actSleep = idleAction == ACT_SLEEP or idleAction == ACT_DOZE
    bool actScratch = idleAction == ACT_SCRATCH
    bool actYawn = idleAction == ACT_YAWN
    bool actDance = idleAction == ACT_DANCE or idleAction == ACT_SPIN
    bool actGlasses = idleAction == ACT_GLASSES
    bool actCoffee = idleAction == ACT_COFFEE
    bool actLaptop = idleAction == ACT_LAPTOP
    bool actNewspaper = idleAction == ACT_NEWSPAPER
    bool actMoonwalk = moveMode == MOVE_MOON
    bool actCrown = idleAction == ACT_CROWN
    bool actWave = idleAction == ACT_WAVE
    bool actCheer = idleAction == ACT_CHEER or idleAction == ACT_VICTORY
    bool actShrug = idleAction == ACT_SHRUG
    bool actThink = idleAction == ACT_THINK
    bool actLaugh = idleAction == ACT_LAUGH
    bool actAngry = idleAction == ACT_ANGRY
    bool actDizzy = idleAction == ACT_DIZZY or idleAction == ACT_SPIN
    bool actHeart = idleAction == ACT_HEART
    bool actPopcorn = idleAction == ACT_POPCORN
    bool actPhone = idleAction == ACT_PHONE
    bool actBook = idleAction == ACT_BOOK
    bool actTelescope = idleAction == ACT_TELESCOPE or idleAction == ACT_CHARTWATCH
    bool actWorkout = idleAction == ACT_WORKOUT or idleAction == ACT_FLEX
    bool actMeditate = idleAction == ACT_MEDITATE
    bool actMusic = idleAction == ACT_MUSIC
    bool actConfetti = idleAction == ACT_CONFETTI or idleAction == ACT_VICTORY
    bool actRain = idleAction == ACT_RAIN
    bool actMagnify = idleAction == ACT_MAGNIFY
    bool actSnack = idleAction == ACT_SNACK
    bool actLightbulb = idleAction == ACT_LIGHTBULB
    bool actStare = idleAction == ACT_STARE or idleAction == ACT_CHARTWATCH
    bool actHide = idleAction == ACT_HIDE
    bool actPeek = idleAction == ACT_PEEK
    bool actClap = idleAction == ACT_CLAP
    bool actSneeze = idleAction == ACT_SNEEZE
    bool actHiccup = idleAction == ACT_HICCUP
    bool actPoint = idleAction == ACT_POINT
    bool actPanicRun = moveMode == MOVE_DASH

    bool glasses = actGlasses
    bool coffee = actCoffee
    bool laptop = actLaptop
    bool newspaper = actNewspaper
    bool crown = actCrown
    bool book = actBook
    bool phone = actPhone
    bool popcorn = actPopcorn
    bool telescope = actTelescope
    bool scratch = actScratch

    int faceMode = FACE_NORMAL
    if shocking or foodNotice or actSneeze or actHiccup
        faceMode := FACE_SURPRISED
    else if actSleep
        faceMode := FACE_SLEEPY
    else if actYawn
        faceMode := FACE_YAWN
    else if actAngry
        faceMode := FACE_ANGRY
    else if actLaugh or actCheer or actClap
        faceMode := FACE_LAUGH
    else if actDizzy
        faceMode := FACE_DIZZY

    int ATT_NONE = 0
    int ATT_CHART = 1
    int ATT_FLAG = 2
    int ATT_BELLY = 3
    int ATT_OBJECT_L = 4
    int ATT_OBJECT_R = 5
    int attentionTarget = currentIntent == INT_WATCH or currentIntent == INT_TELESCOPE ? ATT_CHART : currentIntent == INT_FLAG ? ATT_FLAG : currentIntent == INT_BELLY ? ATT_BELLY : currentIntent == INT_COFFEE or currentIntent == INT_SNACK ? ATT_OBJECT_L : currentIntent == INT_READ or currentIntent == INT_LAPTOP or currentIntent == INT_PHONE ? ATT_OBJECT_R : ATT_NONE

    int look = idleLook
    look := idleAction == ACT_LOOK_L ? -1 : look
    look := idleAction == ACT_LOOK_R ? 1 : look
    look := actStare ? 0 : look
    look := actPoint ? (animFrame % 2 == 0 ? 1 : -1) : look
    look := homeWalkingAction and moveMode != MOVE_MOON ? (intentToX < intentFromX ? -1 : 1) : look
    look := actMoonwalk ? (intentToX < intentFromX ? 1 : -1) : look
    look := foodNotice or foodWalk or foodEat ? (foodX < eventHomeX ? -1 : 1) : look
    look := foodReturn ? (eventHomeX > foodX ? 1 : -1) : look
    look := attentionTarget == ATT_CHART ? -1 : attentionTarget == ATT_FLAG ? (FLAG_X >= petX ? 1 : -1) : attentionTarget == ATT_BELLY ? 0 : attentionTarget == ATT_OBJECT_L ? -1 : attentionTarget == ATT_OBJECT_R ? 1 : look

    bool walking = (((homeWalkingAction and homeWalkProgress < 1.0) and not movementLocked) or foodWalk or foodReturn)
    bool renderPowered = powered
    color activeCore = normalCore
    float hatchProgress = f_clamp(ageMinutes / 15.0, 0.0, 1.0)
    int crack = hatchProgress < 0.35 ? 0 : hatchProgress < 0.70 ? 1 : 2

    if barstate.islast
        f_clearScene(screen)
        f_ground(screen)

        if eventMode == 1 and eventElapsed < 3200
            int bite = eventElapsed < 2350 ? 0 : eventElapsed < 2600 ? 1 : eventElapsed < 2850 ? 2 : 3
            f_food(screen, SAFE_LEFT_X, 35, foodBull, bite)

        if waveFlagOn and renderStage > 0
            f_plantedFlag(screen, FLAG_X, FLAG_TOP_Y, waveFlagColor, animFrame)
            if currentIntent == INT_FLAG and intentPhase >= 1
                f_flagWork(screen, intentPhase, animFrame)

        if renderStage == 0
            f_egg(screen, HOME_START_X, 26, crack)
        else if renderStage == 1
            f_hatch(screen, petX + 5, petY + 5, blinkNow, walking ? walkFrame : false, activeCore, marketBellyColor, glasses, scratch, look, faceMode)
        else if renderStage == 2
            f_young(screen, petX + 2, petY + 2, blinkNow, walking ? walkFrame : false, activeCore, marketBellyColor, glasses, scratch, look, renderPowered, faceMode)
        else
            f_adult(screen, petX, petY, blinkNow, walking ? walkFrame : false, activeCore, marketBellyColor, glasses, scratch, look, renderPowered, crown, faceMode)

        if renderStage > 0
            if coffee
                f_coffee(screen, petX - 1, 39, animFrame)
            if laptop
                f_laptop(screen, petX + 8, 38, animFrame)
            if newspaper
                f_newspaper(screen, petX + 8, 35, animFrame)
            if popcorn
                f_popcorn(screen, petX - 2, 35)
            if phone
                f_phone(screen, petX + 25, 29, animFrame)
            if book
                f_book(screen, petX + 6, 36)
            if telescope
                f_telescope(screen, petX + 20, 31)
            if actWorkout
                f_dumbbell(screen, petX + 7, 37, animFrame)
            if actMagnify
                f_magnifier(screen, petX + 22, 31)
            if actSnack
                f_snack(screen, petX - 1, 35)

        if faceMode == FACE_SLEEPY and renderStage > 0 and eventMode == 0
            f_sleepZ(screen, math.min(W - 5, petX + 27), petY + 1)
            if renderStage >= 2 and animFrame >= 2
                f_sleepZ(screen, math.min(W - 6, petX + 31), petY - 5)

        if actWave and renderStage > 0
            int waveY = petY + (animFrame % 2 == 0 ? 5 : 3)
            f_rect(screen, petX + 27, waveY, 2, 7, C_BODY_L)
            f_px(screen, petX + 30, waveY - 1, C_STAR)

        if actCheer and renderStage > 0
            f_rect(screen, petX - 1, petY + 5, 2, 8, C_BODY_L)
            f_rect(screen, petX + 28, petY + 5, 2, 8, C_BODY_L)
            f_px(screen, petX - 2, petY + 3, C_CORE_HOT)
            f_px(screen, petX + 31, petY + 2, C_CORE_HOT)

        if actShrug and renderStage > 0
            f_rect(screen, petX - 3, petY + 21, 6, 2, C_BODY)
            f_rect(screen, petX + 26, petY + 21, 6, 2, C_BODY)
            f_question(screen, math.min(W - 6, petX + 29), petY + 3, C_CORE)

        if actThink and renderStage > 0
            f_thought(screen, math.min(W - 12, petX + 28), math.max(6, petY - 2))

        if actAngry and renderStage > 0
            f_angrySteam(screen, petX + 4, petY - 2, animFrame)
            f_angrySteam(screen, petX + 20, petY - 2, animFrame)

        if actDizzy and renderStage > 0
            f_dizzyStars(screen, petX + 3, petY - 3, animFrame)

        if actHeart and renderStage > 0
            f_heart(screen, math.min(W - 7, petX + 26), math.max(6, petY + 1))

        if actMeditate and renderStage > 0
            f_meditation(screen, petX + 14, petY + 21, animFrame)

        if actMusic and renderStage > 0
            f_music(screen, math.min(W - 7, petX + 27), math.max(6, petY + 1))
            if animFrame % 2 == 0
                f_px(screen, petX - 2, petY + 4, C_CORE)

        if actConfetti and renderStage > 0
            f_confetti(screen, math.max(1, petX - 4), math.max(6, petY - 3), animFrame)

        if actRain and renderStage > 0
            f_rainCloud(screen, petX + 8, math.max(6, petY - 7), animFrame)

        if actLightbulb and renderStage > 0
            f_lightbulb(screen, math.min(W - 7, petX + 27), math.max(6, petY))

        if actStare and renderStage > 0
            f_px(screen, petX - 2, petY + 10, C_STAR)
            f_px(screen, petX + 29, petY + 10, C_STAR)

        if actDance and renderStage > 0
            f_px(screen, petX + 1, petY - 2, C_STAR)
            f_px(screen, petX + 9, petY - 5, C_CORE_HOT)
            f_px(screen, petX + 23, petY - 3, C_STAR)
            f_px(screen, petX + 28, petY + 3, C_CORE)

        if actMoonwalk and homeWalkProgress < 1.0 and not movementLocked
            f_px(screen, petX + 4, 43, color.new(C_STAR, 25))
            f_px(screen, petX + 8, 42, color.new(C_STAR, 45))

        if actHide and renderStage > 0
            f_rect(screen, petX - 1, 37, 31, 6, C_SIGN_D)
            f_rect(screen, petX + 1, 38, 27, 4, C_SIGN)

        if actPeek and renderStage > 0
            f_rect(screen, petX + 24, petY + 11, 5, 3, C_EYE)
            f_px(screen, petX + 27, petY + 12, C_PUPIL)

        if actClap and renderStage > 0
            int clapOff = animFrame % 2 == 0 ? 0 : 2
            f_rect(screen, petX + 11 - clapOff, petY + 21, 3, 3, C_BODY_L)
            f_rect(screen, petX + 16 + clapOff, petY + 21, 3, 3, C_BODY_L)
            if clapOff == 0
                f_px(screen, petX + 15, petY + 20, C_STAR)

        if actSneeze and renderStage > 0 and animFrame == 1
            f_px(screen, petX + 29, petY + 13, C_STAR)
            f_px(screen, petX + 31, petY + 12, C_STAR)
            f_px(screen, petX + 33, petY + 14, C_STAR)

        if actHiccup and renderStage > 0 and animFrame == 1
            f_notice(screen, math.min(W - 4, petX + 29), petY + 5, C_CORE_HOT)

        if actPoint and renderStage > 0
            bool pointRight = animFrame % 2 == 0
            int armX = pointRight ? petX + 27 : petX - 5
            f_rect(screen, armX, petY + 20, 7, 2, C_BODY_L)
            f_px(screen, pointRight ? armX + 7 : armX - 1, petY + 20, C_STAR)

        if actPanicRun and homeWalkProgress < 1.0 and not movementLocked
            f_px(screen, petX + 2, 43, color.new(C_STAR, 20))
            f_px(screen, petX + 7, 42, color.new(C_STAR, 35))
            f_px(screen, petX + 12, 43, color.new(C_STAR, 50))

        if currentIntent == INT_BELLY and intentPhase >= 1 and renderStage > 0
            f_question(screen, math.min(W - 6, petX + 24), petY + 19, marketBellyColor)
            if animFrame % 2 == 0
                f_px(screen, petX + 14, petY + 27, C_STAR)

        if currentIntent == INT_WATCH and intentPhase >= 1 and renderStage > 0
            color watchColor = waveBias == 1 ? C_BULL : waveBias == -1 ? C_BEAR : marketBellyColor
            f_focusRays(screen, petX + 14, petY - 1, watchColor, animFrame)
            if flowWaveConflict and liveIntentElapsed > 10000 and animFrame % 2 == 0
                f_px(screen, petX + 20, 42, C_STAR)
                f_px(screen, petX + 22, 43, C_SHADOW)

        if currentIntent == INT_PUSHUP and intentPhase == 2 and renderStage > 0
            f_question(screen, math.min(W - 6, petX + 28), petY + 4, C_CORE_HOT)

        if foodHappy
            f_px(screen, petX + 1, petY - 2, C_STAR)
            f_px(screen, petX + 9, petY - 5, C_CORE_HOT)
            f_px(screen, petX + 23, petY - 3, C_STAR)

        if shocking
            f_notice(screen, math.min(W - 4, petX + 28), 20, C_BEAR)
            f_px(screen, petX + 1, petY - 2, C_STAR)
            f_px(screen, petX + 24, petY - 3, C_STAR)

        if foodNotice
            f_notice(screen, math.max(1, petX - 5), 22, C_CORE_HOT)

        if engineReady and math.abs(flowState) == 2 and renderStage > 0 and animFrame == 0
            color strongColor = marketFlowColor
            f_px(screen, petX + 2, petY - 1, color.new(strongColor, 20))
            f_px(screen, math.min(W - 2, petX + 27), petY + 3, color.new(strongColor, 20))

        if renderPowered and renderStage > 0
            if animFrame == 0
                f_px(screen, petX - 2, petY + 8, color.new(activeCore, 20))
                f_px(screen, math.min(W - 2, petX + 29), petY + 11, color.new(activeCore, 20))
            if animFrame == 2
                f_px(screen, petX + 2, petY - 1, color.new(activeCore, 30))
                f_px(screen, math.min(W - 2, petX + 26), petY + 2, color.new(activeCore, 30))

        if showHUD
            string rarityDisplay = rarityName == "LEGENDARY" ? "✦ LEGENDARY ✦" : rarityName == "MYSTICAL" ? "✦ MYSTICAL ✦" : rarityName == "VERY RARE" ? "✦ VERY RARE ✦" : rarityName
            string dnaCompact = paletteName
            dnaCompact += headStyle != "None" ? "/" + str.upper(headStyle) : ""
            dnaCompact += tailStyle != "None" ? "/" + str.upper(tailStyle) : ""
            dnaCompact += extraMarking != "None" ? "/" + str.upper(extraMarking) : ""
            dnaCompact += "/" + str.upper(coreStyle)
            string collectionText = manualInputInvalid ? "ENTER #000000001-#999999999 • SHOWING TODAY" : not trainerReady and not manualView ? "SET TRAINER CODE" : isKeeper ? "★ IN KEEPER LIST ★" : ""
            table.cell_set_text(hud, 0, 0, chartlingName + " • " + rarityDisplay)
            table.cell_set_text(hud, 0, 1, "#" + hatchIdText + " • AGE " + ageText)
            table.cell_set_text(hud, 0, 2, personalityName + " • " + traitAName + "/" + traitBName + " • " + quirkAName + "/" + quirkBName)
            table.cell_set_text(hud, 0, 3, dnaCompact + (str.length(collectionText) > 0 ? " • " + collectionText : ""))
            table.cell_set_text(hud, 0, 4, loreSentence)
            table.cell_set_text_color(hud, 0, 0, rarityColor)
            table.cell_set_text_color(hud, 0, 1, rarityColor)
            table.cell_set_text_color(hud, 0, 2, C_TEXT)
            table.cell_set_text_color(hud, 0, 3, rarityColor)
            table.cell_set_text_color(hud, 0, 4, C_TEXT)
            for yy = 0 to 4
                table.cell_set_bgcolor(hud, 0, yy, C_HUD_BG)
        else
            for yy = 0 to 4
                table.cell_set_text(hud, 0, yy, "")
                table.cell_set_bgcolor(hud, 0, yy, C_HUD_OFF)

plot(na)
````
