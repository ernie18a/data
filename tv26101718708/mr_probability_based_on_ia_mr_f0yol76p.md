# MR Probability based on IA MR

- url: https://www.tradingview.com/script/F0Yol76P-MR-Probability-based-on-IA-MR/
- type: indicator
- pine_id: PUB;ca111b7678f84dbcb6b2ba32d65e1b00
- version: 2.0

## Description

MR Probability Companion
Setup guide, backtest reference, and practical workflow notes for the custom TradingView companion indicator.
Version 3 — Updated with Backtest Engine, Probability Engine, and full input reference.
Purpose: This tool adds a historical probability and backtest layer to the existing IA-Mean-Reversion indicator so you can evaluate signal quality and layer into trades more intelligently.
Best use case: Swing and intraday execution where you want more confidence than a simple buy/sell dot alone can provide.

Contents
 
1.	What this indicator does
2.	Setup instructions
3.	How probability is calculated
4.	Backtest engine — what it measures and how to read it
5.	Inputs and what each one does
6.	Visual elements and functions
7.	Suggested workflow
8.	Mobile layout suggestions
9.	Important notes and best practices
10.	Quick reference
1.	What This Indicator Does
 
The MR Probability Companion is a supporting indicator built to work alongside the paid IA-Mean-Reversion script. It does not generate the original mean reversion logic itself.
Instead, it reads the oscillator plot from that script and converts it into an execution aid with two core engines:
•	Probability Engine — calculates how often the oscillator has historically reverted from each threshold level.
•	Backtest Engine — tracks every historical signal per tier and reports wins, losses, win rate, and average bars to revert.
In practice: this gives you a way to compare weak, moderate, strong, and extreme signals instead of treating every dot the same — and now shows you the actual historical track record per level. 
2.	Setup Instructions
 
1.	Add IA-Mean-Reversion [3.6] to your chart.
2.	Add the MR Probability Companion script to the same chart.
3.	Open the settings for the probability script.
4.	Find the input labeled Link to IA-Mean-Reversion [3.6]: Plot.
5.	Select the Plot output from the IA-Mean-Reversion indicator in the dropdown.
6.	Do not select shapes, buy alert output, sell alert output, or signal markers.
7.	After linking correctly, confirm that the oscillator line, labels, tables, or badge begin updating.
Most common mistake: If the script looks blank or probabilities stay empty, the source is almost always linked to the wrong output. The correct source is the IA mean reversion Plot value — not Shapes, not Alerts. 
3.	How Probability Is Calculated
 
The Probability Engine studies historical oscillator values over your selected lookback window.
1.	It checks when the oscillator reached or crossed a threshold level such as 0.5, 1.0,
1.5, or 2.0.
2.	It counts those events as hits.
3.	For each hit, it looks forward a set number of bars using the Reversion Time (Bars) setting.
4.	If the oscillator returns sufficiently back toward the mean (below 50% of the threshold) within that window, it counts as a successful reversion.
5.	The final percentage is the ratio of successful reversions to total hits.
Interpretation: A probability of 78% at Level 3 means that in the sampled history, moves reaching that stretch level reverted within the chosen bar window about 78% of the time. 
This is a historical tendency, not a guaranteed forecast.
4.	Backtest Engine
 
The Backtest Engine is a separate, more detailed study that runs alongside the Probability Engine. While the Probability Engine gives you a single percentage, the Backtest Engine gives you the full breakdown per level.
What It Measures
•	Every time the oscillator crosses a threshold level (L1, L2, L3, L4), it is counted as a signal.
•	The script then checks whether the oscillator reverted back below 50% of that threshold within the Reversion Time (Bars) window.
•	If it did, the signal is counted as a win. If not, it is a loss.
•	For winning trades, the number of bars it took to revert is tracked and averaged.
Backtest Table Columns
Column	Meaning
BACKTEST	The level name and threshold value (e.g. L1 · 0.5, L2 · 1.0).
SIGNALS	Total number of historical threshold crossings found in the lookback window.
WINS	How many of those signals successfully reverted within the bar window.
Shown in green.
LOSSES	How many signals failed to revert. Shown in red/pink.
WIN RATE	Percentage of wins out of total signals. Color coded: green ≥75%, yellow ≥55%, red below 55%.
AVG BARS	Average number of bars it took for winning trades to revert. Helps estimate how long to hold.
How to Use the Backtest Results
•	If L3 shows a 78% win rate with an average of 6 bars, that tells you L3 signals on this symbol and timeframe have historically been reliable and relatively fast.
•	If L1 shows a 52% win rate, it may not be worth acting on L1 signals alone — wait for L2 or higher.
•	Compare win rates across levels to understand which tier gives you the best edge on the current instrument.
•	Use AVG BARS to set realistic expectations for how long a trade may take to play out.
Key insight: The backtest table lets you stop guessing which level is "good enough" and instead use actual historical data to decide where to start layering.  
5.	Inputs and What Each One Does
 
Input	What it does	Why it matters
Link to IA-MeanReversion [3.6]:
Plot	Reads the oscillator value from the original indicator.	Most important setting. Without it, the script cannot function.
Level 1 Threshold	Defines the earliest stretch zone.	Useful for spotting early entries or first layers.
Level 2 Threshold	Defines the moderate stretch zone.	Often more meaningful than Level 1 for execution.
Level 3 Threshold	Defines the strong stretch zone.	Often where higher-conviction opportunities start to appear.
Level 4 Threshold	Defines the extreme stretch zone.	Useful for exhaustion-style mean reversion setups.
Historical Window
(Bars)	Controls how far back the script studies past behavior.	Larger windows provide more examples but may reflect older conditions. Default: 200.
Reversion Time
(Bars)	Controls how many bars are allowed for a reversion to count as a win.	Smaller values are stricter; larger values are more forgiving. Default:
10.
Show % on
Signals	Places labels on qualifying signal points.	Shows direction, probability, and level directly on the oscillator.
Show Oscillator
Line	Displays the live linked mean reversion value as a line.	Helps monitor current extension in real time.
Show Full Table	Toggles the main analytics table on or off.	Useful on desktop when you want deeper stats visible.
Show Backtest
Results Table	Toggles the backtest table on or off.	Shows wins, losses, win rate, and avg bars per level.
Show Mini Badge
(Mobile)	Toggles the compact badge on or off.	Best choice for mobile charting or minimal clutter.
Compact Table
Mode	Shrinks the table by shortening labels.	Helps preserve chart space while keeping core info visible.
Table Position	Moves the full analytics table to a different chart area.	Lets you avoid covering candles or important indicator zones.
Backtest Table
Position	Moves the backtest table independently.	Lets you place both tables without overlap.
Table Text Size	Changes the table text size.	Useful when switching between desktop and mobile screens.
Mini Badge
Position	Moves the compact badge independently.	Lets you place the badge in the least intrusive area.
6.	Visual Elements and Functions
 
Oscillator Line
This line mirrors the linked IA mean reversion value. Color changes based on direction: red when above L1 (sell-side stretch), green when below negative L1 (buy-side stretch), orange when neutral.
Threshold Lines
Horizontal levels mark the defined stretch zones. L4 lines are drawn with a heavier weight to highlight extreme territory. Positive readings represent sell-side stretch; negative readings represent buy-side stretch.
Signal Labels
When a fresh threshold event occurs, labels appear like BUY 64% L2 or SELL 81% L3.
These summarize direction, historical reversion probability, and the tier level in one glance.
•	Buy labels: green tones — brighter green for higher probability.
•	Sell labels: red/pink tones — deeper red for higher probability.
Full Analytics Table
Shows the current state of each level including zone name, threshold value, historical hit count, reversion percentage, and active status indicator.
Backtest Results Table
Shows the full historical track record per level: total signals, wins, losses, win rate (color coded), and average bars to revert on winning trades.
Mini Badge
Compact mobile-friendly summary showing active direction, current tier, and probability estimate. Ideal when the full tables take too much chart space.
Alerts
Four built-in alert conditions:
•	High probability SELL at L3+ (win rate threshold configurable)
•	High probability BUY at L3+
•	Extreme SELL at L4
•	Extreme BUY at L4 
7.	Suggested Workflow
 
If you trade with a top-down process, the indicator fits naturally into that workflow.
1.	Use 1D and 4H charts to identify higher-timeframe reversion bias.
2.	Watch whether the oscillator is reaching L2, L3, or L4 territory.
3.	Check the Backtest Table to see which level has the strongest historical win rate on this symbol and timeframe.
4.	Use the Probability label on the signal dot to confirm the current setup quality.
5.	Drop to lower timeframes for execution when higher-timeframe context and current level align.
6.	Use AVG BARS from the backtest table to set realistic trade duration expectations.
7.	Consider smaller initial size at L1 and L2, then add on stronger or more statistically favorable levels.
Key advantage: You no longer need to wait only for the most extreme level every time. If mid-level signals show strong historical win rates, they become actionable layering opportunities too — and now you have the data to back that decision. 
8.	Mobile Layout Suggestions
 
•	Set Show Full Table = Off for the cleanest chart.
•	Set Show Mini Badge = On for a small at-a-glance summary.
•	Set Show Backtest Results Table = Off on mobile; review it on desktop when planning trades.
•	Use Compact Table Mode if you still want the larger table but need it reduced.
•	Move tables and badge using the position settings so they do not block price action.
•	Use a smaller text size when charting on a phone.
9.	Important Notes and Best Practices
 
•	All percentages and win rates are historical tendencies, not prediction guarantees.
•	If the Signals count in the backtest table is very low (under 10), the win rate is less trustworthy due to small sample size.
•	Thresholds may need to be adjusted depending on the symbol, timeframe, and volatility regime.
•	The script is most useful as a decision-support tool, not a standalone trading system.
•	Always combine the probability score and backtest results with market structure, trend context, key levels, and your own risk rules.
•	If you change the Historical Window or Reversion Time inputs, the backtest results will update to reflect the new parameters.
•	Pine Script has loop limits — if you encounter a "loop too long" error, reduce the Historical Window (Bars) input.
10.	Quick Reference
 
If you want to...	Use this
See detailed stats on every level	Turn on the full analytics table
See historical win rate per level	Turn on the backtest results table
Know how long winning trades typically last	Check AVG BARS in the backtest table
Keep the chart clean on mobile	Use the mini badge and turn off both tables
Make the display smaller	Enable compact mode and reduce table text size
Know if the signal is early or extreme	Watch the current tier and threshold lines
React only to stronger setups	Use alerts for high-probability L3 and L4 events
Decide which level to start layering at	Compare win rates across L1–L4 in the backtest table
Fix blank display or 0% probabilities	Re-link the source input to IA-Mean-Reversion
[3.6]: Plot
This document is a concise operating guide for the MR Probability Companion indicator. Version 3 — includes Backtest Engine, updated input reference, and workflow notes.

## Source Code

````pine
//@version=5
indicator("MR Probability based on IA MR", shorttitle="MR-Prob-Backtester", overlay=false, max_labels_count=500)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────
src        = input.source(close, "🔗 Link to IA-Mean-Reversion [3.6]: Plot")
t1         = input.float(0.5,  "Level 1 Threshold", step=0.1)
t2         = input.float(1.0,  "Level 2 Threshold", step=0.1)
t3         = input.float(1.5,  "Level 3 Threshold", step=0.1)
t4         = input.float(2.0,  "Level 4 Threshold", step=0.1)

lookback   = input.int(100,    "Historical Window (Bars)",
     tooltip="How many bars back to study.\n\n📊 TIMEFRAME GUIDE:\n• 1m–5m  → use 50–80\n• 15m    → use 80–100\n• 1H–1D  → use 100–200\n• Weekly → use 300–400\n\nLower = faster. Higher = more data but may error on low TFs.",
     minval=30, maxval=400)

revBars    = input.int(5,      "Reversion Time (Bars)",
     tooltip="Bars allowed for reversion.\n\n📊 TIMEFRAME GUIDE:\n• 1m–5m  → use 3–5\n• 15m–4H → use 5–10\n• 1D+    → use 10–15",
     minval=2, maxval=30)

showLabels    = input.bool(true,  "Show % on Signals")
showPlot      = input.bool(true,  "Show Oscillator Line")
showFullTable = input.bool(true,  "Show Full Table")
showBacktest  = input.bool(true,  "Show Backtest Results Table")
showBadge     = input.bool(true,  "Show Mini Badge (Mobile)")
compactMode   = input.bool(false, "Compact Table Mode")

tablePos      = input.string("Top Right",    "Table Position",          options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])
tableTxtSize  = input.string("Small",        "Table Text Size",         options=["Tiny","Small","Normal"])
badgePos      = input.string("Bottom Left",  "Mini Badge Position",     options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])
btPos         = input.string("Bottom Right", "Backtest Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])

// ─────────────────────────────
// HELPERS
// ─────────────────────────────
f_pos(p) => 
    p=="Top Right"?position.top_right:p=="Top Left"?position.top_left:p=="Bottom Right"?position.bottom_right:p=="Bottom Left"?position.bottom_left:p=="Middle Right"?position.middle_right:position.middle_left

f_txtSize(s) => 
    s=="Tiny"?size.tiny:s=="Normal"?size.normal:size.small

getProbColor(p, bear) =>
    if na(p)
        color.gray
    else if bear
        p >= 80 ? #ff0055 : p >= 65 ? #ff4d88 : p >= 50 ? #ff99bb : color.new(color.red, 60)
    else
        p >= 80 ? #00ff88 : p >= 65 ? #4dffb3 : p >= 50 ? #99ffdd : color.new(color.green, 60)

// FIXED: Syntax error fix for the color helper
f_wrColor(wr) =>
    na(wr) ? color.gray : (wr >= 75 ? #00ff88 : (wr >= 55 ? #ffdd00 : #ff4d88))

// ─────────────────────────────
// ENGINES
// ─────────────────────────────
f_calcProb(level) =>
    hits = 0
    revs = 0
    maxI = math.min(lookback, bar_index - revBars - 1)
    if maxI > revBars
        for i = revBars to maxI
            a = math.abs(src[i])
            if a >= level and math.abs(src[i + 1]) < level
                hits += 1
                for j = 1 to revBars
                    if math.abs(src[i-j]) <= level * 0.5
                        revs += 1
                        break
    p = hits > 0 ? math.round((revs / hits) * 100) : na
    [hits, p]

f_backtest(level) =>
    ts=0, w=0, l=0, tb=0
    maxI = math.min(lookback, bar_index - revBars - 1)
    if maxI > revBars
        for i = revBars to maxI
            a = math.abs(src[i])
            if a >= level and math.abs(src[i + 1]) < level
                ts += 1
                rev = false
                for j = 1 to revBars
                    if math.abs(src[i-j]) <= level * 0.5
                        rev := true
                        tb  += j
                        break
                if rev
                    w += 1
                else
                    l += 1
    wr = ts > 0 ? math.round((w / ts) * 100) : na
    ab = w > 0 ? math.round(tb / w) : na
    [ts, w, l, wr, ab]

// ─────────────────────────────
// EXECUTION
// ─────────────────────────────
[h1, p1] = f_calcProb(t1)
[h2, p2] = f_calcProb(t2)
[h3, p3] = f_calcProb(t3)
[h4, p4] = f_calcProb(t4)

[bt1_t, bt1_w, bt1_l, bt1_wr, bt1_a] = f_backtest(t1)
[bt2_t, bt2_w, bt2_l, bt2_wr, bt2_a] = f_backtest(t2)
[bt3_t, bt3_w, bt3_l, bt3_wr, bt3_a] = f_backtest(t3)
[bt4_t, bt4_w, bt4_l, bt4_wr, bt4_a] = f_backtest(t4)

absSrc = math.abs(src)
isBear = src > 0
isBull = src < 0
newT1  = absSrc >= t1 and nz(absSrc[1]) < t1
newT2  = absSrc >= t2 and nz(absSrc[1]) < t2
newT3  = absSrc >= t3 and nz(absSrc[1]) < t3
newT4  = absSrc >= t4 and nz(absSrc[1]) < t4
sigTier= newT4 ? 4 : newT3 ? 3 : newT2 ? 2 : newT1 ? 1 : 0
sigP   = sigTier==4?p4:sigTier==3?p3:sigTier==2?p2:sigTier==1?p1:na
curT   = absSrc >= t4 ? 4 : absSrc >= t3 ? 3 : absSrc >= t2 ? 2 : absSrc >= t1 ? 1 : 0
curP   = curT==4?p4:curT==3?p3:curT==2?p2:curT==1?p1:na

// ─────────────────────────────
// VISUALS
// ─────────────────────────────
plot(showPlot ? src : na, "MR Value", color=src>t1?#ff2d55:src<-t1?#00e676:#ff9800, linewidth=2)
hline(0, "Mean", color=color.new(color.white, 70))
hline(t1), hline(t2), hline(t3), hline(t4), hline(-t1), hline(-t2), hline(-t3), hline(-t4)

if showLabels and sigTier > 0 and barstate.isconfirmed
    l4txt = isBear ? "🔴 SELL\nL4 EXTREME" : "🟢 BUY\nL4 EXTREME"
    txt   = sigTier == 4 ? l4txt : (isBear ? "SELL " : "BUY ") + (na(sigP)?"?":str.tostring(int(sigP))+"%") + "\nL" + str.tostring(sigTier)
    l4col = isBear ? #ff0000 : #00cc44
    col   = sigTier == 4 ? l4col : getProbColor(sigP, isBear)
    lsize = sigTier == 4 ? size.normal : size.small
    label.new(bar_index, src, txt, color=col, textcolor=color.white, style=isBear?label.style_label_down:label.style_label_up, size=lsize)

// TABLES
var table tab = table.new(f_pos(tablePos), 5, 5, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)
if showFullTable and barstate.islast
    ts = f_txtSize(tableTxtSize), hdr = #111111
    table.cell(tab, 0, 0, "ZONE", bgcolor=hdr, text_color=color.white, text_size=ts)
    table.cell(tab, 1, 0, "LVL",  bgcolor=hdr, text_color=color.white, text_size=ts)
    table.cell(tab, 2, 0, "HITS", bgcolor=hdr, text_color=color.white, text_size=ts)
    table.cell(tab, 3, 0, "REV %",bgcolor=hdr, text_color=color.white, text_size=ts)
    table.cell(tab, 4, 0, "STAT", bgcolor=hdr, text_color=color.white, text_size=ts)
    
    // Row 1 (L1)
    bg1 = absSrc>=t1 ? (isBear?color.new(color.red,60):color.new(color.green,60)) : color.new(color.black,20)
    table.cell(tab, 0, 1, compactMode?"L1":"L1 Early", bgcolor=bg1, text_color=color.white, text_size=ts)
    table.cell(tab, 1, 1, str.tostring(t1,"#.#"), bgcolor=bg1, text_color=color.yellow, text_size=ts)
    table.cell(tab, 2, 1, str.tostring(h1), bgcolor=bg1, text_color=color.silver, text_size=ts)
    table.cell(tab, 3, 1, (na(p1)?"...":str.tostring(p1)+"%"), bgcolor=bg1, text_color=getProbColor(p1, isBear), text_size=ts)
    table.cell(tab, 4, 1, absSrc>=t1?(isBear?"🔴":"🟢"):"—", bgcolor=bg1, text_size=ts)
    
    // Row 2 (L2)
    bg2 = absSrc>=t2 ? (isBear?color.new(color.red,60):color.new(color.green,60)) : color.new(color.black,20)
    table.cell(tab, 0, 2, compactMode?"L2":"L2 Mod", bgcolor=bg2, text_color=color.white, text_size=ts)
    table.cell(tab, 1, 2, str.tostring(t2, "#.#"), bgcolor=bg2, text_color=color.yellow, text_size=ts)
    table.cell(tab, 2, 2, str.tostring(h2), bgcolor=bg2, text_color=color.silver, text_size=ts)
    table.cell(tab, 3, 2, (na(p2)?"...":str.tostring(p2)+"%"), bgcolor=bg2, text_color=getProbColor(p2, isBear), text_size=ts)
    table.cell(tab, 4, 2, absSrc>=t2?(isBear?"🔴":"🟢"):"—", bgcolor=bg2, text_size=ts)

    // Row 3 (L3)
    bg3 = absSrc>=t3 ? (isBear?color.new(color.red,60):color.new(color.green,60)) : color.new(color.black,20)
    table.cell(tab, 0, 3, compactMode?"L3":"L3 Strong", bgcolor=bg3, text_color=color.white, text_size=ts)
    table.cell(tab, 1, 3, str.tostring(t3, "#.#"), bgcolor=bg3, text_color=color.yellow, text_size=ts)
   // Row 4 (L4 EXTREME)
    bg4     = absSrc>=t4 ? (isBear ? #cc0000 : #006622) : color.new(color.black,20)
    l4name  = compactMode ? "⚡L4" : (isBear ? "🔴 SELL L4" : "🟢 BUY L4")
    table.cell(tab, 0, 4, l4name, bgcolor=bg4, text_color=color.white, text_size=ts)
    table.cell(tab, 1, 4, str.tostring(t4, "#.#"), bgcolor=bg4, text_color=color.yellow, text_size=ts)
    table.cell(tab, 2, 4, str.tostring(h4), bgcolor=bg4, text_color=color.white, text_size=ts)
    table.cell(tab, 3, 4, (na(p4)?"...":str.tostring(p4)+"%"), bgcolor=bg4, text_color=getProbColor(p4, isBear), text_size=ts)
    table.cell(tab, 4, 4, absSrc>=t4?(isBear?"🔴 SELL":"🟢 BUY"):"—", bgcolor=bg4, text_color=color.white, text_size=ts)
    table.cell(tab, 1, 4, str.tostring(t4, "#.#"), bgcolor=bg4, text_color=color.yellow, text_size=ts)
    table.cell(tab, 2, 4, str.tostring(h4), bgcolor=bg4, text_color=color.silver, text_size=ts)
    table.cell(tab, 3, 4, (na(p4)?"...":str.tostring(p4)+"%"), bgcolor=bg4, text_color=getProbColor(p4, isBear), text_size=ts)
    table.cell(tab, 4, 4, absSrc>=t4?(isBear?"🔴":"🟢"):"—", bgcolor=bg4, text_size=ts)

// Backtest Results Table
var table btt = table.new(f_pos(btPos), 6, 5, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)
if showBacktest and barstate.islast
    ts = f_txtSize(tableTxtSize), hdr = #0d0d0d
    table.cell(btt,0,0,"BACKTEST",bgcolor=hdr,text_color=#aaaaaa,text_size=ts)
    table.cell(btt,1,0,"SIGS",bgcolor=hdr,text_color=#aaaaaa,text_size=ts)
    table.cell(btt,2,0,"WINS",bgcolor=hdr,text_color=#aaaaaa,text_size=ts)
    table.cell(btt,3,0,"LOSS",bgcolor=hdr,text_color=#aaaaaa,text_size=ts)
    table.cell(btt,4,0,"WIN %",bgcolor=hdr,text_color=#aaaaaa,text_size=ts)
    table.cell(btt,5,0,"AVG B",bgcolor=hdr,text_color=#aaaaaa,text_size=ts)
    
    nb = color.new(color.black, 20)
    table.cell(btt,0,1,"L1",bgcolor=nb,text_color=color.white,text_size=ts)
    table.cell(btt,1,1,str.tostring(bt1_t),bgcolor=nb,text_color=color.silver,text_size=ts)
    table.cell(btt,2,1,str.tostring(bt1_w),bgcolor=nb,text_color=#00ff88,text_size=ts)
    table.cell(btt,3,1,str.tostring(bt1_l),bgcolor=nb,text_color=#ff4d88,text_size=ts)
    table.cell(btt,4,1,str.tostring(bt1_wr)+"%",bgcolor=nb,text_color=f_wrColor(bt1_wr),text_size=ts)
    table.cell(btt,5,1,str.tostring(bt1_a)+"b",bgcolor=nb,text_color=color.silver,text_size=ts)

    table.cell(btt,0,2,"L2",bgcolor=nb,text_color=color.white,text_size=ts)
    table.cell(btt,1,2,str.tostring(bt2_t),bgcolor=nb,text_color=color.silver,text_size=ts)
    table.cell(btt,2,2,str.tostring(bt2_w),bgcolor=nb,text_color=#00ff88,text_size=ts)
    table.cell(btt,3,2,str.tostring(bt2_l),bgcolor=nb,text_color=#ff4d88,text_size=ts)
    table.cell(btt,4,2,str.tostring(bt2_wr)+"%",bgcolor=nb,text_color=f_wrColor(bt2_wr),text_size=ts)
    table.cell(btt,5,2,str.tostring(bt2_a)+"b",bgcolor=nb,text_color=color.silver,text_size=ts)

    table.cell(btt,0,3,"L3",bgcolor=nb,text_color=color.white,text_size=ts)
    table.cell(btt,1,3,str.tostring(bt3_t),bgcolor=nb,text_color=color.silver,text_size=ts)
// L4 — hardcoded colors to avoid ternary color.new() error
    l4BearBg = #800020
    l4BullBg = #004d1a
    l4bg     = isBear ? l4BearBg : l4BullBg
    table.cell(btt,0,4,"⚡ L4",bgcolor=l4bg,text_color=color.white,text_size=ts)
    table.cell(btt,1,4,str.tostring(bt4_t),bgcolor=l4bg,text_color=color.white,text_size=ts)
    table.cell(btt,2,4,str.tostring(bt4_w),bgcolor=l4bg,text_color=#00ff88,text_size=ts)
    table.cell(btt,3,4,str.tostring(bt4_l),bgcolor=l4bg,text_color=#ff4d88,text_size=ts)
    table.cell(btt,4,4,str.tostring(bt4_wr)+"%",bgcolor=l4bg,text_color=f_wrColor(bt4_wr),text_size=ts)
    table.cell(btt,5,4,str.tostring(bt4_a)+"b",bgcolor=l4bg,text_color=color.white,text_size=ts)
````
