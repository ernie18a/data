# Fibonacci Impulse Layers [josseliani]

- url: https://www.tradingview.com/script/I2FjiVKH-Fibonacci-Impulse-Layers-josseliani/
- type: indicator
- pine_id: PUB;ac5e0ea12f924063bd0ff1b8e89731d1
- version: 2.0

## Description

Fibonacci Impulse Layers shows the Fibonacci Golden Zones of three active market-structure layers directly on the chart:

→ [b]Bias[/b] — the broader structure, calculated on 4H by default.  
→ [b]Macro[/b] — the larger impulse on the current chart timeframe, using Pivot Depth 12 by default.  
→ [b]Local[/b] — the smaller and more reactive impulse, using Pivot Depth 3 by default.

Bias shows the broader direction and helps identify whether the market is moving with that trend or correcting against it. Macro shows the intermediate impulse in relation to Bias. Local shows the nearest active structure in relation to Macro.

Local correction → Macro Golden Zone  
Macro correction → Bias Golden Zone  
Golden Zone reaction → Potential return toward the relevant structural High or Low

The indicator does not calculate Fibonacci extension targets. Its purpose is to identify active 50–61.8 Golden Zones and show where price is located within the Bias, Macro, and Local impulse structure.

[b]📊 THREE STRUCTURAL LAYERS[/b]

[b]1️⃣ Bias[/b]

Bias provides the broader market context.

It is calculated on a separately selected timeframe. The default is 4H, but the user can select 1H, 1D, 1W, or another timeframe equal to or higher than the current chart timeframe.

Bias helps identify:

→ the direction of the broader active impulse;  
→ whether Macro is moving with Bias or correcting against it;  
→ the location of the broader 50–61.8 Golden Zone;  
→ the structural High or Low belonging to the active Bias impulse.

[b]2️⃣ Macro[/b]

Macro is calculated on the current chart timeframe using a larger pivot depth.

Its default Pivot Depth is 12, so it reacts more slowly than Local and represents a broader impulse.

When Macro moves against Bias, the table identifies it as a counter-Bias move. In that situation, the Bias Golden Zone may become the broader structural destination.

[b]3️⃣ Local[/b]

Local is also calculated on the current chart timeframe, but with a smaller Pivot Depth of 3 by default.

It follows the nearest active impulse and displays the closest Golden Zone.

When Local moves against Macro, that movement may represent a Local correction toward the Macro Golden Zone rather than a reversal of the broader structure.

[b]🧩 HOW THE STRUCTURE IS CALCULATED[/b]

Each layer identifies confirmed pivot Highs and Lows and maintains its own active bullish or bearish impulse.

Two Structure Break modes are available:

→ [b]Wick[/b] — the structure changes when the High or Low breaks the active structural level.  
→ [b]Close[/b] — the structure changes only after a candle closes beyond that level.

Lower Pivot Depth → smaller and more reactive structure  
Higher Pivot Depth → broader and slower structure

Each active layer contains:

• Impulse direction  
• Structural High and Low  
• Fibonacci retracement levels  
• 50–61.8 Golden Zone  
• Return reference toward the active structural extreme

[b]📐 READING THE GOLDEN ZONES[/b]

The primary retracement area is 50–61.8.

For a bullish impulse:

Impulse Low → Impulse High → Pullback from above into 50–61.8 → Potential return toward the High

For a bearish impulse:

Impulse High → Impulse Low → Pullback from below into 50–61.8 → Potential return toward the Low

The direction of entry matters.

A bullish Golden Zone becomes active when price enters it from above. A bearish Golden Zone becomes active when price enters it from below.

If price has crossed through the complete area and later returns from the wrong side, that return is not treated as a new valid retracement.

Each Golden Zone can generate only one valid retracement event per active impulse. Leaving and returning to the same zone does not create another event. A new event becomes available only after the corresponding structure updates its High, Low, or direction.

Macro and Bias can display the 23.6, 38.2, 50, 61.8, 78.6, and optional 88.6 levels.

Local uses a cleaner display focused on 38.2 and the 50–61.8 Golden Zone.

[b]🔍 ALIGNMENT AND MARKET STATE[/b]

The indicator does not assume that every Local change has already reversed the Macro or Bias structure.

[b]Alignment[/b] reports which layers currently point in the same direction:

• FULL BULLISH ALIGNMENT  
• FULL BEARISH ALIGNMENT  
• BIAS + MACRO ALIGNED / LOCAL OPPOSITE  
• MACRO + LOCAL ALIGNED / BIAS OPPOSITE  
• BIAS + LOCAL ALIGNED / MACRO OPPOSITE

[b]Market State[/b] explains what that combination represents:

• Bullish or bearish continuation  
• Local pullback within the broader trend  
• Counter-Bias Macro move  
• Local reaction against the active Macro structure

Alignment shows [b]which layers agree[/b]. Market State explains [b]what the current combination represents[/b].

Full three-layer alignment is not required to use the indicator. The table also describes corrective and counter-trend structures.

[b]📋 DECISION TABLE[/b]

The Decision Table combines the three layers into one market map.

→ [b]Bias, Macro, and Local[/b] show their current direction and Golden Zone prices.

→ [b]Alignment[/b] shows which structural layers agree.

→ [b]Market State[/b] distinguishes continuation, correction, and counter-structure movement.

→ [b]Status[/b] shows whether price is currently inside a valid Local, Macro, Bias, or combined Golden Zone.

→ [b]Local Plan[/b] shows the Local Golden Zone and the relevant Local High or Low. When Local opposes Macro, the Macro Golden Zone may appear as the next structural area.

→ [b]Macro Plan[/b] shows the Macro Golden Zone and the relevant Macro High or Low. When Macro opposes Bias, the Bias Golden Zone may appear as the broader structural area.

→ [b]Bias Plan[/b] shows the Bias Golden Zone and its active structural High or Low.

The plans describe the currently calculated structural route. They are not automatic entries, stop-loss levels, or guaranteed targets.

[b]⚙️ SETTINGS[/b]

[b]Local Pivot Depth[/b]

Controls the smaller structure on the current chart timeframe.

Lower value → faster Local reactions  
Higher value → broader Local impulses

Default: 3.

[b]Macro Pivot Depth[/b]

Controls the larger structure on the current chart timeframe.

Increase it when Macro changes too frequently. Decrease it when Macro reacts too slowly.

Default: 12.

[b]Bias Timeframe[/b]

Selects the timeframe used for the broader Bias structure.

It must be equal to or higher than the current chart timeframe.

Default: 4H.

[b]Bias Pivot Depth[/b]

Controls pivot sensitivity inside the selected Bias timeframe.

[b]Use Confirmed Bias[/b]

Enabled by default.

✓ Enabled — uses the last fully completed Bias timeframe candle.  
✕ Disabled — uses the developing Bias candle and can change before that candle closes.

The active mode appears in the table as CONFIRMED or LIVE.

[b]Structure Break[/b]

Wick provides faster structural updates.

Close requires a candle close beyond the structural level and provides stricter confirmation.

[b]Fibonacci display[/b]

Macro and Bias Fibonacci levels can be enabled or disabled individually. The optional 88.6 level is disabled by default.

The user can also control:

• Impulse diagonals  
• Structural High and Low lines  
• 50–61.8 fills  
• Local pivot dots  
• Level extension length  
• Labels  
• Colors and transparency  
• Table position and text size

[b]🔔 ALERTS[/b]

The script includes five alert conditions:

• Full Bullish Alignment  
• Full Bearish Alignment  
• Valid Local Retracement  
• Valid Macro Retracement  
• Valid Bias Retracement

Retracement alerts trigger only on the first valid entry into the relevant 50–61.8 area from the correct correction side during the current impulse.

The chart and table can react while the current candle is forming. Alerts are confirmed at the chart candle close and trigger when a new qualifying condition begins.

[b]⚠️ IMPORTANT NOTES[/b]

Pivot structures require bars on both sides of a swing before the pivot can be confirmed. A new pivot therefore appears only after the selected Pivot Depth has completed.

The active structure can update when new structural Highs, Lows, or breaks develop.

The live table may change during the current candle as price enters or leaves a Golden Zone. Historical calculations and alert events are represented using completed chart candles.

Confirmed Bias uses completed higher-timeframe information. Live Bias is more responsive but can change while the selected Bias candle remains open.

The indicator keeps only the active Local, Macro, and Bias structures. Previous Fibonacci grids are removed to keep the chart readable.

Fibonacci Impulse Layers is a market-structure analysis tool. It does not execute trades, calculate Fibonacci extensions, or guarantee that price will react at a displayed level.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © josseliani
//@version=6

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ◈ FIBONACCI IMPULSE LAYERS [josseliani]
//  Bias → Macro → Local | Structure • Fibonacci • Alignment
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

indicator("Fibonacci Impulse Layers [josseliani]", overlay=true, max_lines_count=300, max_labels_count=300)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 1. LOCAL STRUCTURE

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string LOCAL_GROUP = "1. Local Structure"



int localDepth = input.int(3, "Local Pivot Depth", minval=1, group=LOCAL_GROUP, tooltip="Defines the Local Fibonacci impulse on the current chart timeframe. Lower values detect smaller, more reactive swings. Higher values create broader Local impulses.")

bool showAllPivotDots = input.bool(true, "Show Local Pivot Dots", group=LOCAL_GROUP)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 2. MACRO STRUCTURE

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string MACRO_GROUP = "2. Macro Structure"



int macroDepth = input.int(12, "Macro Pivot Depth", minval=2, group=MACRO_GROUP, tooltip="Defines a higher-order Fibonacci impulse on the current chart timeframe. Increase the depth to capture a broader Macro swing. Decrease it for a more reactive Macro structure.")

bool showMacroStructure = input.bool(true, "Show Macro Structure", group=MACRO_GROUP)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 3. MACRO FIB

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string MACRO_FIB_GROUP = "3. Macro Fib"



bool showMacro236 = input.bool(true, "Show 23.6", group=MACRO_FIB_GROUP)

bool showMacro382 = input.bool(true, "Show 38.2", group=MACRO_FIB_GROUP)

bool showMacro50 = input.bool(true, "Show 50.0", group=MACRO_FIB_GROUP)

bool showMacro618 = input.bool(true, "Show 61.8", group=MACRO_FIB_GROUP)

bool showMacro786 = input.bool(true, "Show 78.6", group=MACRO_FIB_GROUP)

bool showMacro886 = input.bool(false, "Show 88.6", group=MACRO_FIB_GROUP)

bool showMacroFib = input.bool(true, "Show Macro Fib", group=MACRO_FIB_GROUP)



bool fillMacro50618 = input.bool(true, "Fill 50-61.8 Zone", group=MACRO_FIB_GROUP)



int macroFibWidth = input.int(2, "Macro Fib Width", minval=1, maxval=5, group=MACRO_FIB_GROUP)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 4. BIAS STRUCTURE

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string BIAS_GROUP = "4. Bias Structure"



string biasTf = input.timeframe("240", "Bias Timeframe", group=BIAS_GROUP, tooltip="Defines the timeframe used for the Bias Fibonacci impulse. It must be equal to or higher than the chart timeframe. If you use a D1 chart or higher, change the default H4 Bias to D1 or another higher timeframe.")

int biasDepth = input.int(3, "Bias Pivot Depth", minval=1, group=BIAS_GROUP, tooltip="Controls pivot sensitivity inside the selected Bias timeframe. Higher values create a broader, slower Bias impulse.")



bool useConfirmedBias = input.bool(true, "Use Confirmed Bias", group=BIAS_GROUP, tooltip="On: uses only the last closed Bias timeframe bar. Off: uses the developing Bias bar, which can change before it closes.")

bool showBiasStructure = input.bool(true, "Show Bias Structure", group=BIAS_GROUP)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 5. BIAS FIB

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string BIAS_FIB_GROUP = "5. Bias Fib"



bool showBiasFib = input.bool(true, "Show Bias Fib", group=BIAS_FIB_GROUP)



bool showBias236 = input.bool(true, "Show 23.6", group=BIAS_FIB_GROUP)

bool showBias382 = input.bool(true, "Show 38.2", group=BIAS_FIB_GROUP)

bool showBias50 = input.bool(true, "Show 50.0", group=BIAS_FIB_GROUP)

bool showBias618 = input.bool(true, "Show 61.8", group=BIAS_FIB_GROUP)

bool showBias786 = input.bool(true, "Show 78.6", group=BIAS_FIB_GROUP)

bool showBias886 = input.bool(false, "Show 88.6", group=BIAS_FIB_GROUP)



bool fillBias50618 = input.bool(true, "Fill 50-61.8 Zone", group=BIAS_FIB_GROUP)



int biasFibWidth = input.int(2, "Bias Fib Width", minval=1, maxval=5, group=BIAS_FIB_GROUP)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 6. STRUCTURE LOGIC

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string STRUCTURE_GROUP = "6. Structure Logic"



string breakMode = input.string("Wick", "Structure Break", options=["Wick", "Close"], group=STRUCTURE_GROUP, tooltip="Wick = high/low break. Close = close beyond structural level.")



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 7. DISPLAY

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string DISPLAY_GROUP = "7. Display"



int extendLocalBars = input.int(30, "Extend Local Levels Bars", minval=5, group=DISPLAY_GROUP)

int extendMacroBars = input.int(10, "Extend Macro Levels Bars", minval=5, group=DISPLAY_GROUP)

int extendBiasBars = input.int(10, "Extend Bias Levels Bars", minval=5, group=DISPLAY_GROUP)



bool showLocalDiagonal = input.bool(true, "Show Local Diagonal", group=DISPLAY_GROUP)

bool showMacroDiagonal = input.bool(true, "Show Macro Diagonal", group=DISPLAY_GROUP)

bool showBiasDiagonal = input.bool(true, "Show Bias Diagonal", group=DISPLAY_GROUP)



bool showLocalHighLow = input.bool(true, "Show Local High / Low", group=DISPLAY_GROUP)

bool showMacroHighLow = input.bool(true, "Show Macro High / Low", group=DISPLAY_GROUP)

bool showBiasHighLow = input.bool(true, "Show Bias High / Low", group=DISPLAY_GROUP)



bool showLocal382 = input.bool(true, "Show Local 38.2", group=DISPLAY_GROUP)

bool showLocalZone = input.bool(true, "Show Local 50-61.8 Zone", group=DISPLAY_GROUP)



bool showLevelLabels = input.bool(true, "Show Level Labels", group=DISPLAY_GROUP)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 8. TABLE

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string TABLE_GROUP = "8. Decision Table"



bool showDecisionTable = input.bool(true, "Show Decision Table", group=TABLE_GROUP)



string tablePositionInput = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=TABLE_GROUP)

string tableSizeInput = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal"], group=TABLE_GROUP)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 9. STYLE

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string STYLE_GROUP = "9. Style"



int pivotDotWidth = input.int(1, "Pivot Dot Size", minval=1, maxval=5, group=STYLE_GROUP)



int localLineWidth = input.int(1, "Local Line Width", minval=1, maxval=5, group=STYLE_GROUP)

int macroLineWidth = input.int(1, "Macro Impulse Width", minval=1, maxval=5, group=STYLE_GROUP)

int biasLineWidth = input.int(2, "Bias Impulse Width", minval=1, maxval=5, group=STYLE_GROUP)



int localZoneTransparency = input.int(87, "Local Zone Transparency", minval=0, maxval=100, group=STYLE_GROUP)



int macroTransparency = input.int(45, "Macro Line Transparency", minval=0, maxval=100, group=STYLE_GROUP)

int macroFillTransparency = input.int(80, "Macro Fill Transparency", minval=0, maxval=100, group=STYLE_GROUP)



int biasTransparency = input.int(65, "Bias Line Transparency", minval=0, maxval=100, group=STYLE_GROUP)

int biasFillTransparency = input.int(88, "Bias Fill Transparency", minval=0, maxval=100, group=STYLE_GROUP)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 10. LOCAL COLORS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string LOCAL_COLOR_GROUP = "10. Local Colors"



color pivotHighColor = input.color(color.red, "Pivot High Dot", group=LOCAL_COLOR_GROUP)

color pivotLowColor = input.color(color.blue, "Pivot Low Dot", group=LOCAL_COLOR_GROUP)



color localUpColor = input.color(color.lime, "Local Up Impulse", group=LOCAL_COLOR_GROUP)

color localDownColor = input.color(color.red, "Local Down Impulse", group=LOCAL_COLOR_GROUP)



color localHighColor = input.color(color.red, "Local High", group=LOCAL_COLOR_GROUP)

color localLowColor = input.color(color.blue, "Local Low", group=LOCAL_COLOR_GROUP)



color local382Color = input.color(color.yellow, "Local 38.2", group=LOCAL_COLOR_GROUP)

color local50Color = input.color(color.yellow, "Local 50", group=LOCAL_COLOR_GROUP)

color local618Color = input.color(color.orange, "Local 61.8", group=LOCAL_COLOR_GROUP)



color localZoneColor = input.color(color.orange, "Local 50-61.8 Fill", group=LOCAL_COLOR_GROUP)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 11. HTF COLORS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string HTF_COLOR_GROUP = "11. HTF Colors"



color macroBaseColor = input.color(color.gray, "Macro Color", group=HTF_COLOR_GROUP)

color biasBaseColor = input.color(color.gray, "Bias Color", group=HTF_COLOR_GROUP)



color macroColor = color.new(macroBaseColor, macroTransparency)

color macroFillColor = color.new(macroBaseColor, macroFillTransparency)



color biasColor = color.new(biasBaseColor, biasTransparency)

color biasFillColor = color.new(biasBaseColor, biasFillTransparency)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// HELPERS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_tfLabel(string tf) =>

    string result = tf



    if tf == "1"

        result := "M1"

    else if tf == "3"

        result := "M3"

    else if tf == "5"

        result := "M5"

    else if tf == "15"

        result := "M15"

    else if tf == "30"

        result := "M30"

    else if tf == "45"

        result := "M45"

    else if tf == "60"

        result := "H1"

    else if tf == "120"

        result := "H2"

    else if tf == "240"

        result := "H4"

    else if tf == "D"

        result := "D1"

    else if tf == "W"

        result := "W1"



    result



f_directionText(int tr) =>

    string result = "WAIT"



    if tr == 1

        result := "▲ UP"

    else if tr == -1

        result := "▼ DOWN"



    result



f_directionColor(int tr) =>

    color result = color.new(color.gray, 80)



    if tr == 1

        result := color.new(color.lime, 76)

    else if tr == -1

        result := color.new(color.red, 76)



    result



// Match the symbol's minimum tick precision in TABLE text.

f_price(float p) =>

    na(p) ? "-" : str.tostring(p, format.mintick)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STRUCTURE ENGINE

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_structure(int d, string mode) =>

    float ph = ta.pivothigh(high, d, d)

    float pl = ta.pivotlow(low, d, d)



    var float structuralHigh = na

    var int structuralHighTime = na



    var float structuralLow = na

    var int structuralLowTime = na



    var int trend = 0



    var float candidateLow = na

    var int candidateLowTime = na



    var float candidateHigh = na

    var int candidateHighTime = na



    if not na(ph) and na(structuralHigh)

        structuralHigh := ph

        structuralHighTime := time[d]



    if not na(pl) and na(structuralLow)

        structuralLow := pl

        structuralLowTime := time[d]



    if not na(pl)

        if na(candidateLow) or pl < candidateLow

            candidateLow := pl

            candidateLowTime := time[d]



    if not na(ph)

        if na(candidateHigh) or ph > candidateHigh

            candidateHigh := ph

            candidateHighTime := time[d]



    float bullishBreakPrice = mode == "Close" ? close : high

    float bearishBreakPrice = mode == "Close" ? close : low



    bool bullishBreak = not na(structuralHigh) and bullishBreakPrice > structuralHigh

    bool bearishBreak = not na(structuralLow) and bearishBreakPrice < structuralLow



    if bullishBreak

        if trend == 1 and not na(candidateLow) and not na(candidateLowTime) and candidateLowTime < time

            structuralLow := candidateLow

            structuralLowTime := candidateLowTime



        structuralHigh := bullishBreakPrice

        structuralHighTime := time



        trend := 1



        candidateLow := na

        candidateLowTime := na



        candidateHigh := na

        candidateHighTime := na



    else if bearishBreak

        if trend == -1 and not na(candidateHigh) and not na(candidateHighTime) and candidateHighTime < time

            structuralHigh := candidateHigh

            structuralHighTime := candidateHighTime



        structuralLow := bearishBreakPrice

        structuralLowTime := time



        trend := -1



        candidateHigh := na

        candidateHighTime := na



        candidateLow := na

        candidateLowTime := na



    [trend, structuralHigh, structuralLow, structuralHighTime, structuralLowTime]



// Returns the completed structure state from the previous Bias timeframe bar.

f_confirmedStructure(int d, string mode) =>

    [tr, hi, lo, hiTime, loTime] = f_structure(d, mode)

    [tr[1], hi[1], lo[1], hiTime[1], loTime[1]]



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// LOCAL PIVOT DOTS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float localPh = ta.pivothigh(high, localDepth, localDepth)

float localPl = ta.pivotlow(low, localDepth, localDepth)



plot(showAllPivotDots and not na(localPh) ? localPh : na, title="Pivot High Dot", color=pivotHighColor, style=plot.style_circles, linewidth=pivotDotWidth, offset=-localDepth)

plot(showAllPivotDots and not na(localPl) ? localPl : na, title="Pivot Low Dot", color=pivotLowColor, style=plot.style_circles, linewidth=pivotDotWidth, offset=-localDepth)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STRUCTURE ENGINES

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[localTrend, localHigh, localLow, localHighTime, localLowTime] = f_structure(localDepth, breakMode)



[macroTrend, macroHigh, macroLow, macroHighTime, macroLowTime] = f_structure(macroDepth, breakMode)



[biasLiveTrend, biasLiveHigh, biasLiveLow, biasLiveHighTime, biasLiveLowTime] = request.security(syminfo.tickerid, biasTf, f_structure(biasDepth, breakMode), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)



[biasConfirmedTrend, biasConfirmedHigh, biasConfirmedLow, biasConfirmedHighTime, biasConfirmedLowTime] = request.security(syminfo.tickerid, biasTf, f_confirmedStructure(biasDepth, breakMode), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)



int biasTrend = useConfirmedBias ? biasConfirmedTrend : biasLiveTrend

float biasHigh = useConfirmedBias ? biasConfirmedHigh : biasLiveHigh

float biasLow = useConfirmedBias ? biasConfirmedLow : biasLiveLow

int biasHighTime = useConfirmedBias ? biasConfirmedHighTime : biasLiveHighTime

int biasLowTime = useConfirmedBias ? biasConfirmedLowTime : biasLiveLowTime



if barstate.isfirst and timeframe.in_seconds(biasTf) < timeframe.in_seconds()

    runtime.error("Bias Timeframe must be equal to or higher than the chart timeframe. Change Bias Timeframe in Settings.")



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// VALIDITY

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool localValid = localTrend != 0 and not na(localHigh) and not na(localLow) and not na(localHighTime) and not na(localLowTime) and localHigh > localLow



bool macroValid = macroTrend != 0 and not na(macroHigh) and not na(macroLow) and not na(macroHighTime) and not na(macroLowTime) and macroHigh > macroLow



bool biasValid = biasTrend != 0 and not na(biasHigh) and not na(biasLow) and not na(biasHighTime) and not na(biasLowTime) and biasHigh > biasLow



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// FIB

// 0 = live impulse end

// 100 = impulse origin

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_fib(int tr, float hi, float lo, float ratio) =>

    float r = hi - lo

    tr == 1 ? hi - r * ratio : lo + r * ratio



float local382 = localValid ? f_fib(localTrend, localHigh, localLow, 0.382) : na

float local50 = localValid ? f_fib(localTrend, localHigh, localLow, 0.500) : na

float local618 = localValid ? f_fib(localTrend, localHigh, localLow, 0.618) : na



float macro236 = macroValid ? f_fib(macroTrend, macroHigh, macroLow, 0.236) : na

float macro382 = macroValid ? f_fib(macroTrend, macroHigh, macroLow, 0.382) : na

float macro50 = macroValid ? f_fib(macroTrend, macroHigh, macroLow, 0.500) : na

float macro618 = macroValid ? f_fib(macroTrend, macroHigh, macroLow, 0.618) : na

float macro786 = macroValid ? f_fib(macroTrend, macroHigh, macroLow, 0.786) : na

float macro886 = macroValid ? f_fib(macroTrend, macroHigh, macroLow, 0.886) : na



float bias236 = biasValid ? f_fib(biasTrend, biasHigh, biasLow, 0.236) : na

float bias382 = biasValid ? f_fib(biasTrend, biasHigh, biasLow, 0.382) : na

float bias50 = biasValid ? f_fib(biasTrend, biasHigh, biasLow, 0.500) : na

float bias618 = biasValid ? f_fib(biasTrend, biasHigh, biasLow, 0.618) : na

float bias786 = biasValid ? f_fib(biasTrend, biasHigh, biasLow, 0.786) : na

float bias886 = biasValid ? f_fib(biasTrend, biasHigh, biasLow, 0.886) : na



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 50-61.8 ZONES

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float localZoneLow = localValid ? math.min(local50, local618) : na

float localZoneHigh = localValid ? math.max(local50, local618) : na



float macroZoneLow = macroValid ? math.min(macro50, macro618) : na

float macroZoneHigh = macroValid ? math.max(macro50, macro618) : na



float biasZoneLow = biasValid ? math.min(bias50, bias618) : na

float biasZoneHigh = biasValid ? math.max(bias50, bias618) : na



// A zone is touched when any part of the candle range overlaps it.
// This makes wick-only contact visible immediately instead of waiting for Close.
bool touchesLocalZone = localValid and high >= localZoneLow and low <= localZoneHigh

bool touchesMacroZone = macroValid and high >= macroZoneLow and low <= macroZoneHigh

bool touchesBiasZone = biasValid and high >= biasZoneLow and low <= biasZoneHigh



// A retracement is valid only when price enters the 50-61.8 zone

// from the correction side of the active impulse.

bool localStructureChanged = localTrend != localTrend[1] or localHighTime != localHighTime[1] or localLowTime != localLowTime[1]

bool macroStructureChanged = macroTrend != macroTrend[1] or macroHighTime != macroHighTime[1] or macroLowTime != macroLowTime[1]

bool biasStructureChanged = biasTrend != biasTrend[1] or biasHighTime != biasHighTime[1] or biasLowTime != biasLowTime[1]



var bool localRetracementConsumed = false

var bool macroRetracementConsumed = false

var bool biasRetracementConsumed = false

if localStructureChanged
    localRetracementConsumed := false

if macroStructureChanged
    macroRetracementConsumed := false

if biasStructureChanged
    biasRetracementConsumed := false



bool localBullishEntry = localValid and not localStructureChanged and not localRetracementConsumed and localTrend == 1 and close[1] > localZoneHigh[1] and touchesLocalZone

bool localBearishEntry = localValid and not localStructureChanged and not localRetracementConsumed and localTrend == -1 and close[1] < localZoneLow[1] and touchesLocalZone

bool macroBullishEntry = macroValid and not macroStructureChanged and not macroRetracementConsumed and macroTrend == 1 and close[1] > macroZoneHigh[1] and touchesMacroZone

bool macroBearishEntry = macroValid and not macroStructureChanged and not macroRetracementConsumed and macroTrend == -1 and close[1] < macroZoneLow[1] and touchesMacroZone

bool biasBullishEntry = biasValid and not biasStructureChanged and not biasRetracementConsumed and biasTrend == 1 and close[1] > biasZoneHigh[1] and touchesBiasZone

bool biasBearishEntry = biasValid and not biasStructureChanged and not biasRetracementConsumed and biasTrend == -1 and close[1] < biasZoneLow[1] and touchesBiasZone



// Keep every zone notification visible for three candles of the open chart.
// This prevents a higher-timeframe Bias notice from occupying STATUS for hours
// on a lower-timeframe chart after price has already left the Bias zone.
const int ZONE_NOTICE_BARS = 3

bool localEntryPulse = localBullishEntry or localBearishEntry
bool macroEntryPulse = macroBullishEntry or macroBearishEntry
bool biasEntryPulse = biasBullishEntry or biasBearishEntry

var int localNoticeBar = na
var int macroNoticeBar = na
var int biasNoticeBar = na

// A qualified touch remains part of the active impulse scenario after the
// short IN ZONE notice expires. It is cleared when the impulse target is
// reached, the opposite structural boundary is broken, or structure changes.
var bool localTouchActive = false
var bool macroTouchActive = false
var bool biasTouchActive = false

var int localTouchSide = 0
var int macroTouchSide = 0
var int biasTouchSide = 0

var int localTouchBar = na
var int macroTouchBar = na
var int biasTouchBar = na

if localStructureChanged
    localNoticeBar := na
    localTouchActive := false
    localTouchSide := 0
    localTouchBar := na
if macroStructureChanged
    macroNoticeBar := na
    macroTouchActive := false
    macroTouchSide := 0
    macroTouchBar := na
if biasStructureChanged
    biasNoticeBar := na
    biasTouchActive := false
    biasTouchSide := 0
    biasTouchBar := na

if localEntryPulse
    localNoticeBar := bar_index
    localRetracementConsumed := true
    localTouchActive := true
    localTouchSide := localTrend
    localTouchBar := bar_index

if macroEntryPulse
    macroNoticeBar := bar_index
    macroRetracementConsumed := true
    macroTouchActive := true
    macroTouchSide := macroTrend
    macroTouchBar := bar_index

if biasEntryPulse
    biasNoticeBar := bar_index
    biasRetracementConsumed := true
    biasTouchActive := true
    biasTouchSide := biasTrend
    biasTouchBar := bar_index

// Resolve a stored touch only from the following chart bar. The touch candle
// can span both the zone and a structural boundary, so its intrabar order is
// unknowable and should not instantly complete the scenario.
bool localTouchResolved = localTouchActive and not na(localTouchBar) and bar_index > localTouchBar and ((localTouchSide == 1 and (high >= localHigh or low <= localLow)) or (localTouchSide == -1 and (low <= localLow or high >= localHigh)))
bool macroTouchResolved = macroTouchActive and not na(macroTouchBar) and bar_index > macroTouchBar and ((macroTouchSide == 1 and (high >= macroHigh or low <= macroLow)) or (macroTouchSide == -1 and (low <= macroLow or high >= macroHigh)))
bool biasTouchResolved = biasTouchActive and not na(biasTouchBar) and bar_index > biasTouchBar and ((biasTouchSide == 1 and (high >= biasHigh or low <= biasLow)) or (biasTouchSide == -1 and (low <= biasLow or high >= biasHigh)))

if localTouchResolved
    localNoticeBar := na
    localTouchActive := false
if macroTouchResolved
    macroNoticeBar := na
    macroTouchActive := false
if biasTouchResolved
    biasNoticeBar := na
    biasTouchActive := false

bool inLocalTradeZone = localTouchActive and (touchesLocalZone or (not na(localNoticeBar) and bar_index - localNoticeBar < ZONE_NOTICE_BARS))

bool inMacroTradeZone = macroTouchActive and (touchesMacroZone or (not na(macroNoticeBar) and bar_index - macroNoticeBar < ZONE_NOTICE_BARS))

bool inBiasTradeZone = biasTouchActive and (touchesBiasZone or (not na(biasNoticeBar) and bar_index - biasNoticeBar < ZONE_NOTICE_BARS))



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// TIME / ENDPOINTS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int chartBarMs = int(timeframe.in_seconds() * 1000.0)



int localStartTime = localTrend == 1 ? localLowTime : localHighTime

float localStartPrice = localTrend == 1 ? localLow : localHigh



int localEndTime = localTrend == 1 ? localHighTime : localLowTime

float localEndPrice = localTrend == 1 ? localHigh : localLow



int macroStartTime = macroTrend == 1 ? macroLowTime : macroHighTime

float macroStartPrice = macroTrend == 1 ? macroLow : macroHigh



int macroEndTime = macroTrend == 1 ? macroHighTime : macroLowTime

float macroEndPrice = macroTrend == 1 ? macroHigh : macroLow



int biasStartTime = biasTrend == 1 ? biasLowTime : biasHighTime

float biasStartPrice = biasTrend == 1 ? biasLow : biasHigh



int biasEndTime = biasTrend == 1 ? biasHighTime : biasLowTime

float biasEndPrice = biasTrend == 1 ? biasHigh : biasLow



int localLevelStart = localValid ? math.min(localHighTime, localLowTime) : time

int macroLevelStart = macroValid ? math.min(macroHighTime, macroLowTime) : time

int biasLevelStart = biasValid ? math.min(biasHighTime, biasLowTime) : time



int localLevelEnd = time + chartBarMs * extendLocalBars

int macroLevelEnd = time + chartBarMs * extendMacroBars

int biasLevelEnd = time + chartBarMs * extendBiasBars



color localImpulseColor = localTrend == 1 ? localUpColor : localDownColor



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// LOCAL OBJECTS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var line lImpulse = na



var line lHighLine = na

var line lLowLine = na



var line l382Line = na

var line l50Line = na

var line l618Line = na



var linefill lFill = na



var label lHighLabel = na

var label lLowLabel = na



var label l382Label = na

var label l50Label = na

var label l618Label = na



if not na(lFill)

    linefill.delete(lFill)

    lFill := na



if not na(lImpulse)

    line.delete(lImpulse)

    lImpulse := na



if not na(lHighLine)

    line.delete(lHighLine)

    lHighLine := na



if not na(lLowLine)

    line.delete(lLowLine)

    lLowLine := na



if not na(l382Line)

    line.delete(l382Line)

    l382Line := na



if not na(l50Line)

    line.delete(l50Line)

    l50Line := na



if not na(l618Line)

    line.delete(l618Line)

    l618Line := na



if not na(lHighLabel)

    label.delete(lHighLabel)

    lHighLabel := na



if not na(lLowLabel)

    label.delete(lLowLabel)

    lLowLabel := na



if not na(l382Label)

    label.delete(l382Label)

    l382Label := na



if not na(l50Label)

    label.delete(l50Label)

    l50Label := na



if not na(l618Label)

    label.delete(l618Label)

    l618Label := na



if localValid

    if showLocalDiagonal

        lImpulse := line.new(localStartTime, localStartPrice, localEndTime, localEndPrice, xloc=xloc.bar_time, extend=extend.none, color=localImpulseColor, style=line.style_solid, width=localLineWidth)



    if showLocalHighLow

        lHighLine := line.new(localLevelStart, localHigh, localLevelEnd, localHigh, xloc=xloc.bar_time, extend=extend.none, color=localHighColor, style=line.style_solid, width=localLineWidth)

        lLowLine := line.new(localLevelStart, localLow, localLevelEnd, localLow, xloc=xloc.bar_time, extend=extend.none, color=localLowColor, style=line.style_solid, width=localLineWidth)



    if showLocal382

        l382Line := line.new(localLevelStart, local382, localLevelEnd, local382, xloc=xloc.bar_time, extend=extend.none, color=local382Color, style=line.style_dotted, width=1)



    if showLocalZone

        l50Line := line.new(localLevelStart, local50, localLevelEnd, local50, xloc=xloc.bar_time, extend=extend.none, color=local50Color, style=line.style_dotted, width=1)

        l618Line := line.new(localLevelStart, local618, localLevelEnd, local618, xloc=xloc.bar_time, extend=extend.none, color=local618Color, style=line.style_dotted, width=1)



        lFill := linefill.new(l50Line, l618Line, color.new(localZoneColor, localZoneTransparency))



    if showLevelLabels

        if showLocalHighLow

            lHighLabel := label.new(localLevelEnd, localHigh, "L HIGH", xloc=xloc.bar_time, style=label.style_label_left, color=localHighColor, textcolor=color.white, size=size.tiny)

            lLowLabel := label.new(localLevelEnd, localLow, "L LOW", xloc=xloc.bar_time, style=label.style_label_left, color=localLowColor, textcolor=color.white, size=size.tiny)



        if showLocal382

            l382Label := label.new(localLevelEnd, local382, "L 38.2", xloc=xloc.bar_time, style=label.style_label_left, color=local382Color, textcolor=color.black, size=size.tiny)



        if showLocalZone

            l50Label := label.new(localLevelEnd, local50, "L 50", xloc=xloc.bar_time, style=label.style_label_left, color=local50Color, textcolor=color.black, size=size.tiny)

            l618Label := label.new(localLevelEnd, local618, "L 61.8", xloc=xloc.bar_time, style=label.style_label_left, color=local618Color, textcolor=color.black, size=size.tiny)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MACRO OBJECTS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var line mImpulse = na



var line mHighLine = na

var line mLowLine = na



var line m236Line = na

var line m382Line = na

var line m50Line = na

var line m618Line = na

var line m786Line = na

var line m886Line = na



var linefill mFill = na



var label mHighLabel = na

var label mLowLabel = na



var label m236Label = na

var label m382Label = na

var label m50Label = na

var label m618Label = na

var label m786Label = na

var label m886Label = na



if not na(mFill)

    linefill.delete(mFill)

    mFill := na



if not na(mImpulse)

    line.delete(mImpulse)

    mImpulse := na



if not na(mHighLine)

    line.delete(mHighLine)

    mHighLine := na



if not na(mLowLine)

    line.delete(mLowLine)

    mLowLine := na



if not na(m236Line)

    line.delete(m236Line)

    m236Line := na



if not na(m382Line)

    line.delete(m382Line)

    m382Line := na



if not na(m50Line)

    line.delete(m50Line)

    m50Line := na



if not na(m618Line)

    line.delete(m618Line)

    m618Line := na



if not na(m786Line)

    line.delete(m786Line)

    m786Line := na



if not na(m886Line)

    line.delete(m886Line)

    m886Line := na



if not na(mHighLabel)

    label.delete(mHighLabel)

    mHighLabel := na



if not na(mLowLabel)

    label.delete(mLowLabel)

    mLowLabel := na



if not na(m236Label)

    label.delete(m236Label)

    m236Label := na



if not na(m382Label)

    label.delete(m382Label)

    m382Label := na



if not na(m50Label)

    label.delete(m50Label)

    m50Label := na



if not na(m618Label)

    label.delete(m618Label)

    m618Label := na



if not na(m786Label)

    label.delete(m786Label)

    m786Label := na



if not na(m886Label)

    label.delete(m886Label)

    m886Label := na



if showMacroStructure and macroValid

    if showMacroDiagonal

        mImpulse := line.new(macroStartTime, macroStartPrice, macroEndTime, macroEndPrice, xloc=xloc.bar_time, extend=extend.none, color=macroColor, style=line.style_solid, width=macroLineWidth)



    if showMacroHighLow

        mHighLine := line.new(macroLevelStart, macroHigh, macroLevelEnd, macroHigh, xloc=xloc.bar_time, extend=extend.none, color=macroColor, style=line.style_solid, width=macroLineWidth)

        mLowLine := line.new(macroLevelStart, macroLow, macroLevelEnd, macroLow, xloc=xloc.bar_time, extend=extend.none, color=macroColor, style=line.style_solid, width=macroLineWidth)



    if showMacroFib and showMacro236

        m236Line := line.new(macroLevelStart, macro236, macroLevelEnd, macro236, xloc=xloc.bar_time, extend=extend.none, color=macroColor, style=line.style_dotted, width=macroFibWidth)



    if showMacroFib and showMacro382

        m382Line := line.new(macroLevelStart, macro382, macroLevelEnd, macro382, xloc=xloc.bar_time, extend=extend.none, color=macroColor, style=line.style_dotted, width=macroFibWidth)



    if showMacroFib and showMacro50

        m50Line := line.new(macroLevelStart, macro50, macroLevelEnd, macro50, xloc=xloc.bar_time, extend=extend.none, color=macroColor, style=line.style_dotted, width=macroFibWidth)



    if showMacroFib and showMacro618

        m618Line := line.new(macroLevelStart, macro618, macroLevelEnd, macro618, xloc=xloc.bar_time, extend=extend.none, color=macroColor, style=line.style_dotted, width=macroFibWidth)



    if showMacroFib and showMacro786

        m786Line := line.new(macroLevelStart, macro786, macroLevelEnd, macro786, xloc=xloc.bar_time, extend=extend.none, color=macroColor, style=line.style_dotted, width=macroFibWidth)



    if showMacroFib and showMacro886

        m886Line := line.new(macroLevelStart, macro886, macroLevelEnd, macro886, xloc=xloc.bar_time, extend=extend.none, color=macroColor, style=line.style_dotted, width=macroFibWidth)



    if showMacroFib and fillMacro50618 and showMacro50 and showMacro618 and not na(m50Line) and not na(m618Line)

        mFill := linefill.new(m50Line, m618Line, macroFillColor)



    if showLevelLabels

        if showMacroHighLow

            mHighLabel := label.new(macroLevelEnd, macroHigh, macroTrend == 1 ? "M HIGH / 0" : "M HIGH / 100", xloc=xloc.bar_time, style=label.style_label_left, color=macroColor, textcolor=color.white, size=size.tiny)

            mLowLabel := label.new(macroLevelEnd, macroLow, macroTrend == 1 ? "M LOW / 100" : "M LOW / 0", xloc=xloc.bar_time, style=label.style_label_left, color=macroColor, textcolor=color.white, size=size.tiny)



        if showMacroFib and showMacro236

            m236Label := label.new(macroLevelEnd, macro236, "M 23.6", xloc=xloc.bar_time, style=label.style_label_left, color=macroColor, textcolor=color.white, size=size.tiny)



        if showMacroFib and showMacro382

            m382Label := label.new(macroLevelEnd, macro382, "M 38.2", xloc=xloc.bar_time, style=label.style_label_left, color=macroColor, textcolor=color.white, size=size.tiny)



        if showMacroFib and showMacro50

            m50Label := label.new(macroLevelEnd, macro50, "M 50", xloc=xloc.bar_time, style=label.style_label_left, color=macroColor, textcolor=color.white, size=size.tiny)



        if showMacroFib and showMacro618

            m618Label := label.new(macroLevelEnd, macro618, "M 61.8", xloc=xloc.bar_time, style=label.style_label_left, color=macroColor, textcolor=color.white, size=size.tiny)



        if showMacroFib and showMacro786

            m786Label := label.new(macroLevelEnd, macro786, "M 78.6", xloc=xloc.bar_time, style=label.style_label_left, color=macroColor, textcolor=color.white, size=size.tiny)



        if showMacroFib and showMacro886

            m886Label := label.new(macroLevelEnd, macro886, "M 88.6", xloc=xloc.bar_time, style=label.style_label_left, color=macroColor, textcolor=color.white, size=size.tiny)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// BIAS OBJECTS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var line bImpulse = na



var line bHighLine = na

var line bLowLine = na



var line b236Line = na

var line b382Line = na

var line b50Line = na

var line b618Line = na

var line b786Line = na

var line b886Line = na



var linefill bFill = na



var label bHighLabel = na

var label bLowLabel = na



var label b236Label = na

var label b382Label = na

var label b50Label = na

var label b618Label = na

var label b786Label = na

var label b886Label = na



if not na(bFill)

    linefill.delete(bFill)

    bFill := na



if not na(bImpulse)

    line.delete(bImpulse)

    bImpulse := na



if not na(bHighLine)

    line.delete(bHighLine)

    bHighLine := na



if not na(bLowLine)

    line.delete(bLowLine)

    bLowLine := na



if not na(b236Line)

    line.delete(b236Line)

    b236Line := na



if not na(b382Line)

    line.delete(b382Line)

    b382Line := na



if not na(b50Line)

    line.delete(b50Line)

    b50Line := na



if not na(b618Line)

    line.delete(b618Line)

    b618Line := na



if not na(b786Line)

    line.delete(b786Line)

    b786Line := na



if not na(b886Line)

    line.delete(b886Line)

    b886Line := na



if not na(bHighLabel)

    label.delete(bHighLabel)

    bHighLabel := na



if not na(bLowLabel)

    label.delete(bLowLabel)

    bLowLabel := na



if not na(b236Label)

    label.delete(b236Label)

    b236Label := na



if not na(b382Label)

    label.delete(b382Label)

    b382Label := na



if not na(b50Label)

    label.delete(b50Label)

    b50Label := na



if not na(b618Label)

    label.delete(b618Label)

    b618Label := na



if not na(b786Label)

    label.delete(b786Label)

    b786Label := na



if not na(b886Label)

    label.delete(b886Label)

    b886Label := na



if showBiasStructure and biasValid

    if showBiasDiagonal

        bImpulse := line.new(biasStartTime, biasStartPrice, biasEndTime, biasEndPrice, xloc=xloc.bar_time, extend=extend.none, color=biasColor, style=line.style_solid, width=biasLineWidth)



    if showBiasHighLow

        bHighLine := line.new(biasLevelStart, biasHigh, biasLevelEnd, biasHigh, xloc=xloc.bar_time, extend=extend.none, color=biasColor, style=line.style_solid, width=biasLineWidth)

        bLowLine := line.new(biasLevelStart, biasLow, biasLevelEnd, biasLow, xloc=xloc.bar_time, extend=extend.none, color=biasColor, style=line.style_solid, width=biasLineWidth)



    if showBiasFib

        if showBias236

            b236Line := line.new(biasLevelStart, bias236, biasLevelEnd, bias236, xloc=xloc.bar_time, extend=extend.none, color=biasColor, style=line.style_dotted, width=biasFibWidth)



        if showBias382

            b382Line := line.new(biasLevelStart, bias382, biasLevelEnd, bias382, xloc=xloc.bar_time, extend=extend.none, color=biasColor, style=line.style_dotted, width=biasFibWidth)



        if showBias50

            b50Line := line.new(biasLevelStart, bias50, biasLevelEnd, bias50, xloc=xloc.bar_time, extend=extend.none, color=biasColor, style=line.style_dotted, width=biasFibWidth)



        if showBias618

            b618Line := line.new(biasLevelStart, bias618, biasLevelEnd, bias618, xloc=xloc.bar_time, extend=extend.none, color=biasColor, style=line.style_dotted, width=biasFibWidth)



        if showBias786

            b786Line := line.new(biasLevelStart, bias786, biasLevelEnd, bias786, xloc=xloc.bar_time, extend=extend.none, color=biasColor, style=line.style_dotted, width=biasFibWidth)



        if showBias886

            b886Line := line.new(biasLevelStart, bias886, biasLevelEnd, bias886, xloc=xloc.bar_time, extend=extend.none, color=biasColor, style=line.style_dotted, width=biasFibWidth)



        if fillBias50618 and showBias50 and showBias618 and not na(b50Line) and not na(b618Line)

            bFill := linefill.new(b50Line, b618Line, biasFillColor)



    if showLevelLabels

        if showBiasHighLow

            bHighLabel := label.new(biasLevelEnd, biasHigh, biasTrend == 1 ? "B HIGH / 0" : "B HIGH / 100", xloc=xloc.bar_time, style=label.style_label_left, color=biasColor, textcolor=color.white, size=size.tiny)

            bLowLabel := label.new(biasLevelEnd, biasLow, biasTrend == 1 ? "B LOW / 100" : "B LOW / 0", xloc=xloc.bar_time, style=label.style_label_left, color=biasColor, textcolor=color.white, size=size.tiny)



        if showBiasFib and showBias236

            b236Label := label.new(biasLevelEnd, bias236, "B 23.6", xloc=xloc.bar_time, style=label.style_label_left, color=biasColor, textcolor=color.white, size=size.tiny)



        if showBiasFib and showBias382

            b382Label := label.new(biasLevelEnd, bias382, "B 38.2", xloc=xloc.bar_time, style=label.style_label_left, color=biasColor, textcolor=color.white, size=size.tiny)



        if showBiasFib and showBias50

            b50Label := label.new(biasLevelEnd, bias50, "B 50", xloc=xloc.bar_time, style=label.style_label_left, color=biasColor, textcolor=color.white, size=size.tiny)



        if showBiasFib and showBias618

            b618Label := label.new(biasLevelEnd, bias618, "B 61.8", xloc=xloc.bar_time, style=label.style_label_left, color=biasColor, textcolor=color.white, size=size.tiny)



        if showBiasFib and showBias786

            b786Label := label.new(biasLevelEnd, bias786, "B 78.6", xloc=xloc.bar_time, style=label.style_label_left, color=biasColor, textcolor=color.white, size=size.tiny)



        if showBiasFib and showBias886

            b886Label := label.new(biasLevelEnd, bias886, "B 88.6", xloc=xloc.bar_time, style=label.style_label_left, color=biasColor, textcolor=color.white, size=size.tiny)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// TABLE TIMEFRAME LABELS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string chartTfLabel = f_tfLabel(timeframe.period)



string macroTfLabel = chartTfLabel + " D" + str.tostring(macroDepth)



string biasTfLabel = f_tfLabel(biasTf)

string biasModeLabel = useConfirmedBias ? " CONFIRMED" : " LIVE"



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// DIRECTION + FIB ZONE

// Two-column table. No extra right tail.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string biasText = biasTfLabel + biasModeLabel + "  " + f_directionText(biasTrend)



if biasValid

    biasText := biasTfLabel + biasModeLabel + "  " + f_directionText(biasTrend) + "  |  " + (biasTrend == 1 ? "BUY " : "SELL ") + f_price(biasZoneLow) + "-" + f_price(biasZoneHigh)



string macroText = macroTfLabel + "  " + f_directionText(macroTrend)



if macroValid

    macroText := macroTfLabel + "  " + f_directionText(macroTrend) + "  |  " + (macroTrend == 1 ? "BUY " : "SELL ") + f_price(macroZoneLow) + "-" + f_price(macroZoneHigh)



string localText = chartTfLabel + "  " + f_directionText(localTrend)



if localValid

    localText := chartTfLabel + "  " + f_directionText(localTrend) + "  |  " + (localTrend == 1 ? "BUY " : "SELL ") + f_price(localZoneLow) + "-" + f_price(localZoneHigh)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ALIGNMENT

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string alignmentText = "WAIT"



color alignmentBg = color.new(color.gray, 82)



bool allStructuresValid = biasValid and macroValid and localValid

bool fullBullishAlignment = allStructuresValid and biasTrend == 1 and macroTrend == 1 and localTrend == 1

bool fullBearishAlignment = allStructuresValid and biasTrend == -1 and macroTrend == -1 and localTrend == -1



if allStructuresValid

    if biasTrend == 1 and macroTrend == 1 and localTrend == 1

        alignmentText := "FULL BULLISH ALIGNMENT"

        alignmentBg := color.new(color.lime, 70)



    else if biasTrend == -1 and macroTrend == -1 and localTrend == -1

        alignmentText := "FULL BEARISH ALIGNMENT"

        alignmentBg := color.new(color.red, 70)



    else if biasTrend == macroTrend and localTrend != macroTrend

        alignmentText := "BIAS + MACRO ALIGNED / LOCAL OPPOSITE"

        alignmentBg := color.new(color.yellow, 75)



    else if macroTrend == localTrend and biasTrend != macroTrend

        alignmentText := "MACRO + LOCAL ALIGNED / BIAS OPPOSITE"

        alignmentBg := color.new(color.orange, 73)



    else if biasTrend == localTrend and macroTrend != biasTrend

        alignmentText := "BIAS + LOCAL ALIGNED / MACRO OPPOSITE"

        alignmentBg := color.new(color.orange, 77)



    else

        alignmentText := "MIXED"

        alignmentBg := color.new(color.gray, 76)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STATE

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string stateText = "WAITING FOR STRUCTURE"



color stateBg = color.new(color.gray, 82)



if allStructuresValid

    if biasTrend == 1 and macroTrend == 1 and localTrend == 1

        stateText := "BULLISH CONTINUATION"

        stateBg := color.new(color.lime, 80)



    else if biasTrend == -1 and macroTrend == -1 and localTrend == -1

        stateText := "BEARISH CONTINUATION"

        stateBg := color.new(color.red, 80)



    else if biasTrend == macroTrend and localTrend != macroTrend

        stateText := biasTrend == 1 ? "BEARISH LOCAL PULLBACK IN UPTREND" : "BULLISH LOCAL PULLBACK IN DOWNTREND"

        stateBg := color.new(color.yellow, 80)



    else if macroTrend == localTrend and biasTrend != macroTrend

        stateText := macroTrend == 1 ? "BULLISH COUNTER-BIAS MOVE" : "BEARISH COUNTER-BIAS MOVE"

        stateBg := color.new(color.orange, 78)



    else if biasTrend == localTrend and macroTrend != biasTrend

        stateText := localTrend == 1 ? "BULLISH LOCAL REACTION WITHIN BEARISH MACRO" : "BEARISH LOCAL REACTION WITHIN BULLISH MACRO"

        stateBg := color.new(color.orange, 80)



    else

        stateText := "MIXED STRUCTURE"



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STATUS

// Shows the live/short notice first, then remembers the latest qualified
// zone touch until its active impulse reaches a target or is invalidated.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string statusText = "OUTSIDE ACTIVE ZONES"



color statusBg = color.new(color.gray, 84)



if inLocalTradeZone and inMacroTradeZone and inBiasTradeZone

    statusText := "IN LOCAL + MACRO + BIAS ZONES"

    statusBg := color.new(color.orange, 65)



else if inLocalTradeZone and inMacroTradeZone

    statusText := "IN LOCAL + MACRO ZONES"

    statusBg := color.new(color.orange, 65)



else if inLocalTradeZone and inBiasTradeZone

    statusText := "IN LOCAL + BIAS ZONES"

    statusBg := color.new(color.orange, 65)



else if inMacroTradeZone and inBiasTradeZone

    statusText := "IN MACRO + BIAS ZONES"

    statusBg := color.new(color.orange, 65)



else if inLocalTradeZone

    statusText := localTrend == 1 ? "IN LOCAL BUY ZONE" : "IN LOCAL SELL ZONE"

    statusBg := localTrend == 1 ? color.new(color.lime, 60) : color.new(color.red, 60)



else if inMacroTradeZone

    statusText := macroTrend == 1 ? "IN MACRO BUY ZONE" : "IN MACRO SELL ZONE"

    statusBg := macroTrend == 1 ? color.new(color.lime, 60) : color.new(color.red, 60)



else if inBiasTradeZone

    statusText := biasTrend == 1 ? "IN BIAS BUY ZONE" : "IN BIAS SELL ZONE"

    statusBg := biasTrend == 1 ? color.new(color.lime, 60) : color.new(color.red, 60)

else if localTouchActive or macroTouchActive or biasTouchActive

    // When price is no longer interacting with a zone, keep the most recent
    // qualified touch visible until that impulse reaches its structural target
    // or is invalidated. A newer layer touch replaces the older status message.
    int latestTouchLayer = 0
    int latestTouchBar = -1
    int latestTouchSide = 0

    if localTouchActive and not na(localTouchBar) and localTouchBar > latestTouchBar
        latestTouchLayer := 1
        latestTouchBar := localTouchBar
        latestTouchSide := localTouchSide

    if macroTouchActive and not na(macroTouchBar) and macroTouchBar >= latestTouchBar
        latestTouchLayer := 2
        latestTouchBar := macroTouchBar
        latestTouchSide := macroTouchSide

    if biasTouchActive and not na(biasTouchBar) and biasTouchBar >= latestTouchBar
        latestTouchLayer := 3
        latestTouchBar := biasTouchBar
        latestTouchSide := biasTouchSide

    string latestLayerName = latestTouchLayer == 1 ? "LOCAL" : latestTouchLayer == 2 ? "MACRO" : "BIAS"
    string latestSideName = latestTouchSide == 1 ? "BUY" : "SELL"
    statusText := "LAST TOUCH: " + latestLayerName + " " + latestSideName + " ZONE"
    statusBg := latestTouchSide == 1 ? color.new(color.lime, 72) : color.new(color.red, 72)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// LOCAL PLAN

//

// Local + Macro same:

// Local 50-61.8 -> Local High/Low

//

// Local against Macro:

// Local 50-61.8 -> Local High/Low

// -> opposite Macro 50-61.8 zone

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string localPlan = "WAIT FOR LOCAL"



color localPlanBg = color.new(color.gray, 82)



if localValid

    string localZoneString = f_price(localZoneLow) + "-" + f_price(localZoneHigh)



    if macroValid

        string macroZoneString = f_price(macroZoneLow) + "-" + f_price(macroZoneHigh)



        if localTrend == 1 and macroTrend == 1

            localPlan := "BUY " + localZoneString + " -> L HIGH " + f_price(localHigh)

            localPlanBg := color.new(color.lime, 77)



        else if localTrend == -1 and macroTrend == -1

            localPlan := "SELL " + localZoneString + " -> L LOW " + f_price(localLow)

            localPlanBg := color.new(color.red, 77)



        else if localTrend == -1 and macroTrend == 1

            localPlan := "SELL " + localZoneString + " -> L LOW " + f_price(localLow) + " -> " + macroTfLabel + " BUY ZONE " + macroZoneString

            localPlanBg := color.new(color.yellow, 76)



        else if localTrend == 1 and macroTrend == -1

            localPlan := "BUY " + localZoneString + " -> L HIGH " + f_price(localHigh) + " -> " + macroTfLabel + " SELL ZONE " + macroZoneString

            localPlanBg := color.new(color.yellow, 76)



    else

        if localTrend == 1

            localPlan := "BUY " + localZoneString + " -> L HIGH " + f_price(localHigh)

            localPlanBg := color.new(color.lime, 77)



        else if localTrend == -1

            localPlan := "SELL " + localZoneString + " -> L LOW " + f_price(localLow)

            localPlanBg := color.new(color.red, 77)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MACRO PLAN

//

// Macro trades from its own 50-61.8 zone

// toward its own extreme.

//

// If Macro is counter Bias,

// Bias 50-61.8 is the larger destination.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string macroPlan = "WAIT FOR MACRO"



color macroPlanBg = color.new(color.gray, 82)



if macroValid

    string macroZoneString = f_price(macroZoneLow) + "-" + f_price(macroZoneHigh)



    if macroTrend == 1

        macroPlan := "BUY " + macroZoneString + " -> M HIGH " + f_price(macroHigh)

        macroPlanBg := color.new(color.lime, 80)



        if biasValid and biasTrend == -1

            macroPlan := "BUY " + macroZoneString + " -> M HIGH " + f_price(macroHigh) + " -> " + biasTfLabel + " SELL ZONE " + f_price(biasZoneLow) + "-" + f_price(biasZoneHigh)



    else if macroTrend == -1

        macroPlan := "SELL " + macroZoneString + " -> M LOW " + f_price(macroLow)

        macroPlanBg := color.new(color.red, 80)



        if biasValid and biasTrend == 1

            macroPlan := "SELL " + macroZoneString + " -> M LOW " + f_price(macroLow) + " -> " + biasTfLabel + " BUY ZONE " + f_price(biasZoneLow) + "-" + f_price(biasZoneHigh)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// BIAS PLAN

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string biasPlan = "WAIT FOR BIAS"



color biasPlanBg = color.new(color.gray, 82)



if biasValid

    string biasZoneString = f_price(biasZoneLow) + "-" + f_price(biasZoneHigh)



    if biasTrend == 1

        biasPlan := "BUY " + biasZoneString + " -> B HIGH " + f_price(biasHigh)

        biasPlanBg := color.new(color.lime, 82)



    else if biasTrend == -1

        biasPlan := "SELL " + biasZoneString + " -> B LOW " + f_price(biasLow)

        biasPlanBg := color.new(color.red, 82)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// TABLE

// 2 columns only

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color neutralBg = color.new(color.gray, 84)



tablePos = tablePositionInput == "Top Left" ? position.top_left : tablePositionInput == "Bottom Right" ? position.bottom_right : tablePositionInput == "Bottom Left" ? position.bottom_left : position.top_right



tableTextSize = tableSizeInput == "Tiny" ? size.tiny : tableSizeInput == "Normal" ? size.normal : size.small



var table decisionTable = table.new(tablePos, 2, 9, border_width=1)



if barstate.islast

    if showDecisionTable

        table.cell(decisionTable, 0, 0, "BIAS", bgcolor=neutralBg, text_color=color.white, text_size=tableTextSize)

        table.cell(decisionTable, 1, 0, biasText, bgcolor=f_directionColor(biasTrend), text_color=color.white, text_size=tableTextSize)



        table.cell(decisionTable, 0, 1, "MACRO", bgcolor=neutralBg, text_color=color.white, text_size=tableTextSize)

        table.cell(decisionTable, 1, 1, macroText, bgcolor=f_directionColor(macroTrend), text_color=color.white, text_size=tableTextSize)



        table.cell(decisionTable, 0, 2, "LOCAL", bgcolor=neutralBg, text_color=color.white, text_size=tableTextSize)

        table.cell(decisionTable, 1, 2, localText, bgcolor=f_directionColor(localTrend), text_color=color.white, text_size=tableTextSize)



        table.cell(decisionTable, 0, 3, "ALIGNMENT", bgcolor=neutralBg, text_color=color.white, text_size=tableTextSize)

        table.cell(decisionTable, 1, 3, alignmentText, bgcolor=alignmentBg, text_color=color.white, text_size=tableTextSize)



        table.cell(decisionTable, 0, 4, "MARKET STATE", bgcolor=neutralBg, text_color=color.white, text_size=tableTextSize)

        table.cell(decisionTable, 1, 4, stateText, bgcolor=stateBg, text_color=color.white, text_size=tableTextSize)



        table.cell(decisionTable, 0, 5, "STATUS", bgcolor=neutralBg, text_color=color.white, text_size=tableTextSize)

        table.cell(decisionTable, 1, 5, statusText, bgcolor=statusBg, text_color=color.white, text_size=tableTextSize)



        table.cell(decisionTable, 0, 6, "LOCAL PLAN", bgcolor=neutralBg, text_color=color.white, text_size=tableTextSize)

        table.cell(decisionTable, 1, 6, localPlan, bgcolor=localPlanBg, text_color=color.white, text_size=tableTextSize)



        table.cell(decisionTable, 0, 7, "MACRO PLAN", bgcolor=neutralBg, text_color=color.white, text_size=tableTextSize)

        table.cell(decisionTable, 1, 7, macroPlan, bgcolor=macroPlanBg, text_color=color.white, text_size=tableTextSize)



        table.cell(decisionTable, 0, 8, "BIAS PLAN", bgcolor=neutralBg, text_color=color.white, text_size=tableTextSize)

        table.cell(decisionTable, 1, 8, biasPlan, bgcolor=biasPlanBg, text_color=color.white, text_size=tableTextSize)



    else

        table.clear(decisionTable, 0, 0, 1, 8)



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ALERTS

// Alignment alerts are confirmed at chart close.
// Retracement alerts react immediately when High-Low first touches the zone.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool newBullishAlignment = barstate.isconfirmed and fullBullishAlignment and not fullBullishAlignment[1]

bool newBearishAlignment = barstate.isconfirmed and fullBearishAlignment and not fullBearishAlignment[1]

bool enteredLocalRetracement = localEntryPulse

bool enteredMacroRetracement = macroEntryPulse

bool enteredBiasRetracement = biasEntryPulse



alertcondition(newBullishAlignment, "Full Bullish Alignment", "{{ticker}} {{interval}}: Full bullish Fibonacci structure alignment.")

alertcondition(newBearishAlignment, "Full Bearish Alignment", "{{ticker}} {{interval}}: Full bearish Fibonacci structure alignment.")

alertcondition(enteredLocalRetracement, "Local Golden Zone Touched", "{{ticker}} {{interval}}: Price touched the active Local 50-61.8 Golden Zone.")

alertcondition(enteredMacroRetracement, "Macro Golden Zone Touched", "{{ticker}} {{interval}}: Price touched the active Macro 50-61.8 Golden Zone.")

alertcondition(enteredBiasRetracement, "Bias Golden Zone Touched", "{{ticker}} {{interval}}: Price touched the active Bias 50-61.8 Golden Zone.")
````
