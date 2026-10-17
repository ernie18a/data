# Liquidity Sweep Session [TradingFinder] ICT Killzone Times

- url: https://www.tradingview.com/script/kRKo1KlJ-Liquidity-Sweep-Session-TradingFinder-ICT-Killzone-Times/
- type: indicator
- pine_id: PUB;d034e3ad9ab7443780b41523f84baabb
- version: 1.0

## Description

🔵[b]Introduction[/b]

Liquidity sweeps often look obvious only after the move is already finished. Price trades through a previous session high or low, triggers resting liquidity, quickly returns inside the range, and then expands in the opposite direction. The difficult part is not recognizing a liquidity grab in hindsight; it is deciding when a session liquidity sweep, reclaim, and price-action confirmation are strong enough to deserve attention while the market is still developing. This indicator is built around that problem, combining Asia, London, New York AM, and New York PM sessions, their active Kill Zones, and previous-session liquidity levels to identify areas where a potential BUY setup or SELL setup may be forming.

[image]https://www.tradingview.com/x/iBLbwSsl/[/image]

Instead of treating every break of a session high or session low as a reversal signal, the logic follows the sequence of the move. A fresh liquidity sweep first has to penetrate a valid reference range, then price must reclaim the swept level before the setup can progress. The confirmation stage evaluates directional displacement, short-term market structure, candle quality, trend alignment, entry location, and available reward relative to risk. Strong acceptance outside the liquidity level is treated differently from a true liquidity grab, helping separate a developing breakout from a possible reversal. Depending on the selected Fast, Balanced, or Strict confirmation mode, traders can choose how much price confirmation they want before a setup is considered valid.

The output is intentionally different from a conventional buy and sell signal indicator. Rather than telling the trader to enter immediately, each qualified setup creates a large Review Zone around the relevant price area. A REVIEW BUY SETUP highlights a bullish liquidity-reversal opportunity, while a REVIEW SELL SETUP identifies a bearish area that deserves further analysis. These zones are dynamically scaled using ATR volatility, so their size adapts to changing market conditions instead of relying on a fixed number of points or pips. When price remains inside an active Review Zone, the indicator suppresses additional overlapping signals, keeping the chart cleaner and preventing several alerts from describing essentially the same market opportunity.

This structure turns the tool into a liquidity and session analysis framework rather than a standalone entry generator. Traders can use each Review Zone as the starting point for their own execution model, combining it with concepts such as Order Blocks, Fair Value Gaps (FVG), Fibonacci retracements, market structure, support and resistance, or risk-to-reward planning. At the same time, the indicator internally tracks the behavior of completed setups, including target outcomes, failures, timeouts, and maximum favorable excursion. The result is a TradingView tool designed to connect Smart Money Concepts, liquidity sweep trading, session-based analysis, price action confirmation, and structured trade review without reducing a complex market event to a single BUY or SELL label.


🔵[b]How to Use[/b]

The indicator is designed to be used as a session-based liquidity analysis and trade-location tool, not as a direct entry system. Its job is to monitor the selected London, New York AM, and New York PM Kill Zones, track important liquidity around the Asia range and previous-session highs and lows, and identify situations where price sweeps one of those levels and then begins to reject it. When the full sequence is valid, the script creates a REVIEW BUY SETUP or REVIEW SELL SETUP zone. This zone should be read as an area where a potential trading opportunity deserves closer attention, rather than an instruction to immediately open a long or short position.

A practical workflow is therefore to let the indicator locate the broader liquidity sweep setup, then use your own execution method inside or around the Review Zone. As shown in the examples, traders can combine these areas with Fair Value Gaps (FVG), Order Blocks, Fibonacci retracements, market structure, support and resistance, or another price-action entry model to define a more precise entry, stop-loss, and target. The Review Zone automatically adjusts to current market volatility using ATR, which makes the visual area more consistent across markets such as forex, gold, or cryptocurrencies. If price remains inside an existing Review Zone, additional overlapping signals are suppressed, helping prevent several labels from representing essentially the same liquidity event.

🟣[b]Buy Setup[/b]

A bullish setup begins when price attacks liquidity below an important session low. Depending on the selected Swept Range setting, the reference may be the Asia low or the low of the relevant previous session. The first requirement is a fresh liquidity sweep: price must move below the reference low by a minimum amount, while the previous candle must not already have completed the same penetration. This distinction is important because it separates a new liquidity event from price simply remaining below a level that was already broken. The script also limits the maximum sweep extension, so an excessively deep breakdown is less likely to be interpreted as a normal liquidity grab.

[image]https://www.tradingview.com/x/AXTbrX0o/[/image]

After the downside sweep occurs, the market enters the reclaim stage. For a potential BUY setup, price must close back above the swept session low within the permitted reclaim window. A brief penetration followed by a return above the level is consistent with the liquidity-sweep concept: sell-side liquidity has been taken, but price has not been accepted below the reference range. If price continues closing below the level, extends too far below the sweep, or produces a sufficiently strong bearish breakout candle, the setup is cancelled. In that case, the movement is treated more like bearish acceptance or a genuine breakdown than a bullish liquidity reversal.

[image]https://www.tradingview.com/x/Ecb5tviq/[/image]

Once the low has been reclaimed, the indicator waits for bullish confirmation. The exact requirement depends on the selected Confirmation mode. In Fast mode, the reclaim itself can provide the confirmation. Balanced mode requires an additional bullish directional candle after the reclaim, making it less sensitive to small reactions around the swept low. Strict mode goes one step further and requires the bullish confirmation to break the relevant short-term structure captured before the sweep. Counter-trend BUY setups are also treated more cautiously and require evidence of a micro-structure break rather than relying on a small bullish candle against an established bearish move.

[image]https://www.tradingview.com/x/qrliNwB6/[/image]

The bullish confirmation candle is also evaluated for displacement quality. A candle that technically closes higher but has a very small body or closes poorly within its own range is not treated in the same way as a decisive bullish expansion. The engine examines the body relative to ATR, the percentage of the candle occupied by the body, and the location of the close. When the BUY setup is against the detected EMA direction and slope, the required displacement becomes stronger. This helps distinguish an actual response to swept sell-side liquidity from a weak bounce that may simply be part of an ongoing decline.

Entry location matters as well. A valid liquidity sweep can still become unattractive if price has already travelled too far before confirmation appears. For this reason, the BUY setup must still have enough room inside the reference range, must not be excessively far from the original sweep extreme, and must maintain an acceptable reward-to-risk relationship to the available objective. The engine initially considers the midpoint of the swept range as the nearest objective. If that midpoint has already been reached before the setup becomes active, the opposite side of the reference range becomes the next objective. If price has already travelled through the far side as well, the opportunity is considered late and no new setup is displayed.

[image]https://www.tradingview.com/x/erZPFIZw/[/image]

When all of these conditions are satisfied, a green REVIEW BUY SETUP area appears rather than a traditional BUY arrow. The label is positioned along the lower edge of the Review Zone to visually separate bullish and bearish opportunities. At this stage, the trader can inspect the price action inside the highlighted area. For example, a bullish FVG, a suitable Order Block, a Fibonacci retracement into a discount area, or a smaller-timeframe bullish structure shift can be used to refine the actual entry. The Review Zone identifies the context and location of the opportunity; the final execution remains with the trader.


🟣[b]Sell Setup[/b]

A bearish setup is the inverse process and begins when price trades above an important session high. The reference liquidity can come from the Asia high or from the previous relevant session, depending on the chosen Swept Range mode. Price must create a fresh penetration above that high rather than simply continue trading above a level that was previously broken. This initial move represents a potential buy-side liquidity sweep, where stops and breakout orders above the session high may be triggered before the market decides whether to accept higher prices or reject the move.

[image]https://www.tradingview.com/x/mmwCIBlu/[/image]

The next stage is the bearish reclaim. After sweeping the reference high, price must close back below that level within the allowed number of candles. A quick return below the high suggests that the move above the range may have been a liquidity grab rather than a sustained bullish breakout. If price continues to close above the level, extends too far above the sweep, or produces a strong bullish acceptance candle outside the range, the SELL setup is cancelled. The system therefore avoids treating every new session high as a reversal and requires evidence that higher prices have actually been rejected.

[image]https://www.tradingview.com/x/I8EGurhU/[/image]

Following the reclaim, bearish confirmation is evaluated according to the selected Fast, Balanced, or Strict mode. Fast mode can respond directly to the reclaim candle, while Balanced waits for a later bearish displacement candle that closes below the reclaim price. Strict confirmation additionally requires price to break the relevant pre-sweep short-term structure. When the potential SELL setup is running against an established bullish EMA direction and positive EMA slope, the engine demands stronger structural confirmation before displaying the opportunity.

[image]https://www.tradingview.com/x/jMk9JDMI/[/image]

The bearish displacement candle must also demonstrate meaningful selling pressure. Its body needs to satisfy the minimum ATR-based requirement, occupy a sufficient proportion of the full candle range, and close toward the lower side of the candle. These conditions are intended to filter out weak red candles and minor pullbacks that appear after a session high has been swept but do not yet provide convincing evidence of bearish rejection. A counter-trend SELL requires even stronger displacement, making it more difficult for a temporary dip inside a strong bullish trend to qualify as a complete setup.

Before displaying the bearish Review Zone, the indicator also checks whether the opportunity is still positioned appropriately within the reference range. Price cannot already have travelled too far from the sweep high, the available objective must still provide sufficient reward relative to the invalidation distance, and the expected target must not already have been consumed. The midpoint of the reference range is normally considered first. If price has already traded through the midpoint before confirmation, the opposite range low becomes the remaining objective. If that far edge has already been reached, there is no reason to highlight a new SELL opportunity because most of the expected move has already occurred.

[image]https://www.tradingview.com/x/qGrOYhi3/[/image]

When the complete bearish sequence is confirmed, the chart displays a red REVIEW SELL SETUP zone with its label centered along the upper edge of the box. The trader can then use the highlighted region to search for a more precise short entry using FVGs, bearish Order Blocks, Fibonacci retracements, lower-timeframe market structure, or another preferred execution technique. This is particularly useful after a session high sweep because the initial rejection candle can move quickly; rather than chasing that candle, the Review Zone provides a broader area in which a retracement or secondary confirmation can be evaluated.

The important point in both directions is that the displayed area represents a qualified liquidity-sweep environment, not a guaranteed reversal and not a fixed entry price. A REVIEW BUY SETUP means sell-side liquidity has been swept and the subsequent bullish conditions have passed the active filters; a REVIEW SELL SETUP means buy-side liquidity has been swept and bearish confirmation has developed. The trader still determines whether the structure inside that zone offers an acceptable entry and where the trade should be invalidated. This keeps the tool useful as a Smart Money Concepts, liquidity sweep, session trading, and price-action confirmation framework without turning every detected liquidity event into an automatic trade.


🔵[b]Settings[/b]

[i]Signal Sessions[/i]: Defines which Kill Zones are allowed to generate setups. Traders can monitor London, New York AM, New York PM, or a combination of these sessions.

[i]Swept Range[/i]: Selects the liquidity range used as the reference for a sweep. Asia uses the Asian session range, Previous Session uses the most recent relevant session, while Both allows the indicator to evaluate both references.

[i]Confirmation[/i]: Controls how much confirmation is required after the liquidity sweep and reclaim. Fast reacts earlier, Balanced waits for directional displacement, and Strict adds a stronger market-structure confirmation.

[i]Trend Filter[/i]: Filters setups according to the EMA-based market direction. All displays both aligned and counter-trend opportunities, Aligned keeps setups moving with the detected trend, and Counter displays only setups developing against it.

[i]Send Alert[/i]: Enables or disables alerts when a new qualified Review Zone is generated.


🔵[b]Conclusion[/b]

Liquidity Sweep Session is built around a simple idea: important session highs and lows often become areas where liquidity is taken before price reveals its next meaningful direction. Instead of reacting to every breakout, the indicator waits for a fresh liquidity sweep, reclaim, directional confirmation, market-structure validation, and acceptable trade location before highlighting a potential opportunity. By combining Asia range liquidity, previous-session highs and lows, London and New York Kill Zones, ATR-based volatility, EMA trend context, displacement quality, and reward-to-risk filters, it provides a structured way to analyze liquidity-driven price action without turning every sweep into an automatic trade.

The final output is a Review Zone, not a command to enter the market. A REVIEW BUY SETUP or REVIEW SELL SETUP identifies an area where the underlying liquidity and price-action conditions have aligned and where further execution analysis may be worthwhile. Traders can then combine the zone with FVGs, Order Blocks, Fibonacci levels, market structure, support and resistance, or their own entry model to define the actual trade. This approach keeps the indicator focused on what it is designed to do best: locating higher-quality liquidity sweep setups and organizing session-based market analysis into a clear, practical workflow.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingFinder

//@version=6
indicator("Liquidity Sweep Session [TradingFinder] ICT Killzone Times", "Sweep Session", overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)
import TFlab/SessionAndKillZoneLibrary_TradingFinder/1 as Sess
import TFlab/AlertSenderLibrary_TradingFinder/1 as AlertSender

// User settings
SignalZones = input.string("All", "Signal Sessions", options = ["London + NY am", "London", "NY am", "NY pm", "All"], group = "Signal Settings")
ReferenceMode = input.string("Both", "Swept Range", options = ["Both", "Asia", "Previous session"], group = "Signal Settings")
SignalMode = input.string("Fast", "Confirmation", options = ["Fast", "Balanced", "Strict"], group = "Signal Settings")
TrendFilter = input.string("All", "Trend Filter", options = ["All", "Aligned", "Counter"], group = "Signal Settings")

Alert = input.string("On", "Send Alert", options = ["On", "Off"], group = "Alert")


// Session boxes are drawn by the TFlab library. Signal ranges are tracked independently.
type SweepRecord
    int zone
    int side
    int reference
    int targetTier
    int outcome
    float rangeRank
    bool aligned
    float mfeTicks
type SweepSetup
    int stage = 0
    int zone = 0
    int reference = 0
    float level = na
    float farLevel = na
    float midpoint = na
    float extreme = na
    float reclaimClose = na
    float structure = na
    int sweepBar = na
    int reclaimBar = na
    float rangeRank = na
    float sweepAtr = na
    int outsideCloses = 0
    float postReclaimExtreme = na
type ActiveEvent
    int zone
    int side
    int reference
    int targetTier
    int startTime
    float entry
    float target
    float invalidation
    float mfeTicks
    float rangeRank
    bool aligned
// Core display constants
bool ShowMoreInfo = false
color ColorMoreInfo = #0c3299
bool show_AsiaSess = true
string Asia_SessTime = "2300-0600"
color Asia_color = #da6e0a
bool show_AsiaKill = true
string Asia_KillTime = "2300-0355"
bool show_LondonSess = true
string London_SessTime = "0700-1425"
color London_color = #850244
bool show_LondonKill = true
string London_KillTime = "0700-0955"
bool show_amNewyorkSess = true
string amNewyork_SessTime = "1430-1925"
color amNewyork_color = #008b85
bool show_amNewyorkKill = true
string amNewyork_KillTime = "1430-1655"
bool show_pmNewyorkSess = true
string pmNewyork_SessTime = "1930-2255"
color pmNewyork_color = #750cff
bool show_pmNewyorkKill = true
string pmNewyork_KillTime = "1930-2055"
// Fixed engine parameters
int MinSweepTicks = 1
float MinSweepAtr = 0.02
float MaxSweepAtr = 1.5
int ReclaimBars = 3
int ConfirmBars = 3
float ConfirmBodyAtr = 0.20
int StructureBars = 8
int MaxSignalsPerZone = 3
int CooldownBars = 3
int InvalidationTicks = 2
int OutcomeMinutes = 60
int TrendEmaLength = 50
string RangeFilter = "All"
int MaxSignalLabels = 120
int MaxStoredEvents = 300
int RangeLookback = 120
int SwingPivotBars = 2
float ConfirmBodyPct = 0.50
float ConfirmClosePct = 0.70
float BreakoutBodyAtr = 0.60
int MaxOutsideCloses = 1
float MaxEntryProgress = 0.55
float MaxEntryDistanceAtr = 1.50
float MinRewardRisk = 1.00
int TrendSlopeBars = 5
float CounterTrendBodyMult = 1.35
// The same SessionDetector calls and palette used by the supplied TFlab script.
[SessTimeA, KillTimeA, OpenA, HighA, LowA, CloseA, LowTouchAlertA, HighTouchAlertA] = Sess.SessionDetector("Asia", Asia_SessTime, Asia_KillTime, show_AsiaSess, show_AsiaKill, "Kill Zone", ShowMoreInfo, Asia_color, ColorMoreInfo)
[SessTimeL, KillTimeL, OpenL, HighL, LowL, CloseL, LowTouchAlertL, HighTouchAlertL] = Sess.SessionDetector("London", London_SessTime, London_KillTime, show_LondonSess, show_LondonKill, "Kill Zone", ShowMoreInfo, London_color, ColorMoreInfo)
[SessTimeNYa, KillTimeNYa, OpenNYa, HighNYa, LowNYa, CloseNYa, LowTouchAlertNYa, HighTouchAlertNYa] = Sess.SessionDetector("NY am", amNewyork_SessTime, amNewyork_KillTime, show_amNewyorkSess, show_amNewyorkKill, "Kill Zone", ShowMoreInfo, amNewyork_color, ColorMoreInfo)
[SessTimeNYp, KillTimeNYp, OpenNYp, HighNYp, LowNYp, CloseNYp, LowTouchAlertNYp, HighTouchAlertNYp] = Sess.SessionDetector("NY pm", pmNewyork_SessTime, pmNewyork_KillTime, show_pmNewyorkSess, show_pmNewyorkKill, "Kill Zone", ShowMoreInfo, pmNewyork_color, ColorMoreInfo)
f_pct(int numerator, int denominator) =>
    denominator > 0 ? 100.0 * numerator / denominator : na
f_fmt_pct(float value) =>
    na(value) ? "—" : str.tostring(value, "#.0") + "%"
f_range_matches(float rank) =>
    RangeFilter == "All" or (not na(rank) and (RangeFilter == "Low (0–25)" and rank <= 25 or RangeFilter == "Normal (25–75)" and rank > 25 and rank < 75 or RangeFilter == "High (75–100)" and rank >= 75))
f_trend_matches(bool aligned) =>
    TrendFilter == "All" or (TrendFilter == "Aligned" and aligned) or (TrendFilter == "Counter" and not aligned)
f_bull_displacement(float atrValue, float bodyAtrRequirement) =>
    float candleRange = high - low
    float body = close - open
    candleRange > 0 and body > 0 and body >= bodyAtrRequirement * atrValue and body / candleRange >= ConfirmBodyPct and (close - low) / candleRange >= ConfirmClosePct
f_bear_displacement(float atrValue, float bodyAtrRequirement) =>
    float candleRange = high - low
    float body = open - close
    candleRange > 0 and body > 0 and body >= bodyAtrRequirement * atrValue and body / candleRange >= ConfirmBodyPct and (high - close) / candleRange >= ConfirmClosePct
f_strong_breakdown(float level, float atrValue) =>
    close < level and close < open and open - close >= BreakoutBodyAtr * atrValue
f_strong_breakout(float level, float atrValue) =>
    close > level and close > open and close - open >= BreakoutBodyAtr * atrValue
var array<SweepRecord> Records = array.new<SweepRecord>()
var array<ActiveEvent> Active = array.new<ActiveEvent>()
var array<float> AsiaRanges = array.new<float>()
var array<label> SignalLabels = array.new<label>()
var array<box> SignalBoxes = array.new<box>()
f_stats(int wantedZone, int wantedSide, int wantedReference, int wantedTier) =>
    int sampleN = 0
    int targetN = 0
    int failureN = 0
    int timeoutN = 0
    array<float> mfeValues = array.new<float>()
    for rec in Records
        if rec.zone == wantedZone and rec.side == wantedSide and rec.reference == wantedReference and rec.targetTier == wantedTier and f_range_matches(rec.rangeRank) and f_trend_matches(rec.aligned)
            sampleN += 1
            targetN += rec.outcome == 1 ? 1 : 0
            failureN += rec.outcome == -1 ? 1 : 0
            timeoutN += rec.outcome == 0 ? 1 : 0
            array.push(mfeValues, rec.mfeTicks)
    float medianMfe = sampleN > 0 ? array.median(mfeValues) : na
    [sampleN, targetN, failureN, timeoutN, medianMfe]
// Exact :25 and :55 session boundaries require bars that align with 5-minute boundaries.
float TfSeconds = timeframe.in_seconds(timeframe.period)
if not chart.is_standard or not timeframe.isintraday or na(TfSeconds) or TfSeconds > 300.0 or 300.0 % TfSeconds != 0.0
    runtime.error("Use a standard time-based intraday chart aligned to 5-minute boundaries (for example 1m or 5m).")
// The imported TFlab session library interprets these inputs in UTC.
bool InAsia = not na(time(timeframe.period, Asia_SessTime, "Etc/UTC"))
bool InLondon = not na(time(timeframe.period, London_SessTime, "Etc/UTC"))
bool InNYam = not na(time(timeframe.period, amNewyork_SessTime, "Etc/UTC"))
bool InLondonKill = not na(time(timeframe.period, London_KillTime, "Etc/UTC"))
bool InNYamKill = not na(time(timeframe.period, amNewyork_KillTime, "Etc/UTC"))
bool InNYpmKill = not na(time(timeframe.period, pmNewyork_KillTime, "Etc/UTC"))
bool AsiaStarts = InAsia and (bar_index == 0 or not InAsia[1])
bool AsiaEnds = not InAsia and bar_index > 0 and InAsia[1]
bool LondonStarts = InLondon and (bar_index == 0 or not InLondon[1])
bool LondonEnds = not InLondon and bar_index > 0 and InLondon[1]
bool NYamStarts = InNYam and (bar_index == 0 or not InNYam[1])
bool NYamEnds = not InNYam and bar_index > 0 and InNYam[1]
float TrendEma = ta.ema(close, TrendEmaLength)
float Atr = ta.atr(14)
float PriorHigh = ta.highest(high, StructureBars)[1]
float PriorLow = ta.lowest(low, StructureBars)[1]
float PivotHigh = ta.pivothigh(high, SwingPivotBars, SwingPivotBars)
float PivotLow = ta.pivotlow(low, SwingPivotBars, SwingPivotBars)
var float LastSwingHigh = na
var float LastSwingLow = na
var int LastSwingHighBar = na
var int LastSwingLowBar = na
var float AsiaHigh = na
var float AsiaLow = na
var float AsiaRank = na
var bool AsiaReady = false
var float LondonHigh = na
var float LondonLow = na
var bool LondonReady = false
var float NYamHigh = na
var float NYamLow = na
var bool NYamReady = false
var SweepSetup BuySetup = SweepSetup.new()
var SweepSetup SellSetup = SweepSetup.new()
var int PreviousZone = 0
var int SignalsInZone = 0
var int LastSignalBar = na
bool BuySignal = false
bool SellSignal = false
string SignalMessage = ""
if barstate.isconfirmed
    if not na(PivotHigh)
        LastSwingHigh := PivotHigh
        LastSwingHighBar := bar_index - SwingPivotBars
    if not na(PivotLow)
        LastSwingLow := PivotLow
        LastSwingLowBar := bar_index - SwingPivotBars
    if AsiaStarts
        AsiaHigh := high
        AsiaLow := low
        AsiaRank := na
        AsiaReady := false
    else if InAsia and not na(AsiaHigh)
        AsiaHigh := math.max(AsiaHigh, high)
        AsiaLow := math.min(AsiaLow, low)
    // Outcome accounting is conservative. If stop and target are both touched on one bar,
    // the event is a failure and that ambiguous terminal bar is not allowed to inflate MFE.
    if array.size(Active) > 0
        for i = array.size(Active) - 1 to 0
            ActiveEvent ev = array.get(Active, i)
            if time_close > ev.startTime
                int deadline = ev.startTime + OutcomeMinutes * 60000
                int outcome = 99
                if time_close <= deadline
                    bool stopped = ev.side == 1 ? low <= ev.invalidation : high >= ev.invalidation
                    bool targeted = ev.side == 1 ? high >= ev.target : low <= ev.target
                    if stopped
                        outcome := -1
                    else
                        float favorable = ev.side == 1 ? high - ev.entry : ev.entry - low
                        ev.mfeTicks := math.max(ev.mfeTicks, math.max(0.0, favorable / syminfo.mintick))
                        outcome := targeted ? 1 : time_close >= deadline ? 0 : 99
                else
                    outcome := 0
                if outcome != 99
                    array.push(Records, SweepRecord.new(ev.zone, ev.side, ev.reference, ev.targetTier, outcome, ev.rangeRank, ev.aligned, ev.mfeTicks))
                    if array.size(Records) > MaxStoredEvents
                        array.shift(Records)
                    array.remove(Active, i)
    if AsiaEnds and not na(AsiaHigh) and not na(AsiaLow) and AsiaHigh > AsiaLow
        float currentRange = AsiaHigh - AsiaLow
        int priorN = array.size(AsiaRanges)
        int atOrBelow = 0
        for pastRange in AsiaRanges
            atOrBelow += pastRange <= currentRange ? 1 : 0
        AsiaRank := priorN >= 10 ? 100.0 * atOrBelow / priorN : na
        array.push(AsiaRanges, currentRange)
        if array.size(AsiaRanges) > RangeLookback
            array.shift(AsiaRanges)
        AsiaReady := true
    if LondonStarts
        LondonHigh := high
        LondonLow := low
        LondonReady := false
    else if InLondon and not na(LondonHigh)
        LondonHigh := math.max(LondonHigh, high)
        LondonLow := math.min(LondonLow, low)
    if LondonEnds and not na(LondonHigh) and not na(LondonLow) and LondonHigh > LondonLow
        LondonReady := true
    if NYamStarts
        NYamHigh := high
        NYamLow := low
        NYamReady := false
    else if InNYam and not na(NYamHigh)
        NYamHigh := math.max(NYamHigh, high)
        NYamLow := math.min(NYamLow, low)
    if NYamEnds and not na(NYamHigh) and not na(NYamLow) and NYamHigh > NYamLow
        NYamReady := true
    bool useLondon = SignalZones == "London + NY am" or SignalZones == "London" or SignalZones == "All"
    bool useNYam = SignalZones == "London + NY am" or SignalZones == "NY am" or SignalZones == "All"
    bool useNYpm = SignalZones == "NY pm" or SignalZones == "All"
    int activeZone = useLondon and InLondonKill ? 1 : useNYam and InNYamKill ? 2 : useNYpm and InNYpmKill ? 3 : 0
    if activeZone != PreviousZone
        BuySetup := SweepSetup.new()
        SellSetup := SweepSetup.new()
        SignalsInZone := 0
        PreviousZone := activeZone
    bool slotAvailable = activeZone > 0 and SignalsInZone < MaxSignalsPerZone and (na(LastSignalBar) or bar_index - LastSignalBar > CooldownBars)
    if activeZone > 0
        bool buyResetThisBar = false
        bool sellResetThisBar = false
        // Stage 1: swept, waiting for reclaim. The ATR at the original sweep is frozen.
        // Repeated closes outside the level or a strong breakout mean acceptance, not a sweep.
        if BuySetup.stage == 1
            BuySetup.extreme := math.min(BuySetup.extreme, low)
            if close < BuySetup.level
                BuySetup.outsideCloses += 1
            bool buySweepExpired = bar_index - BuySetup.sweepBar > ReclaimBars
            bool buySweepTooDeep = BuySetup.level - BuySetup.extreme > MaxSweepAtr * BuySetup.sweepAtr
            bool buyAcceptedBelow = BuySetup.outsideCloses > MaxOutsideCloses or f_strong_breakdown(BuySetup.level, BuySetup.sweepAtr)
            if buySweepExpired or buySweepTooDeep or buyAcceptedBelow
                BuySetup := SweepSetup.new()
                buyResetThisBar := true
            else if close > BuySetup.level
                BuySetup.stage := 2
                BuySetup.reclaimBar := bar_index
                BuySetup.reclaimClose := close
                BuySetup.postReclaimExtreme := high
        if SellSetup.stage == 1
            SellSetup.extreme := math.max(SellSetup.extreme, high)
            if close > SellSetup.level
                SellSetup.outsideCloses += 1
            bool sellSweepExpired = bar_index - SellSetup.sweepBar > ReclaimBars
            bool sellSweepTooDeep = SellSetup.extreme - SellSetup.level > MaxSweepAtr * SellSetup.sweepAtr
            bool sellAcceptedAbove = SellSetup.outsideCloses > MaxOutsideCloses or f_strong_breakout(SellSetup.level, SellSetup.sweepAtr)
            if sellSweepExpired or sellSweepTooDeep or sellAcceptedAbove
                SellSetup := SweepSetup.new()
                sellResetThisBar := true
            else if close < SellSetup.level
                SellSetup.stage := 2
                SellSetup.reclaimBar := bar_index
                SellSetup.reclaimClose := close
                SellSetup.postReclaimExtreme := low
        // Stage 2: reclaim must hold. Track everything already reached before the entry bar closes.
        if BuySetup.stage == 2
            BuySetup.postReclaimExtreme := na(BuySetup.postReclaimExtreme) ? high : math.max(BuySetup.postReclaimExtreme, high)
            bool buyConfirmExpired = bar_index - BuySetup.reclaimBar > ConfirmBars
            bool buyReclaimFailed = close <= BuySetup.level or low <= BuySetup.extreme - InvalidationTicks * syminfo.mintick
            if buyConfirmExpired or buyReclaimFailed
                BuySetup := SweepSetup.new()
                buyResetThisBar := true
        if SellSetup.stage == 2
            SellSetup.postReclaimExtreme := na(SellSetup.postReclaimExtreme) ? low : math.min(SellSetup.postReclaimExtreme, low)
            bool sellConfirmExpired = bar_index - SellSetup.reclaimBar > ConfirmBars
            bool sellReclaimFailed = close >= SellSetup.level or high >= SellSetup.extreme + InvalidationTicks * syminfo.mintick
            if sellConfirmExpired or sellReclaimFailed
                SellSetup := SweepSetup.new()
                sellResetThisBar := true
        // The last completed session has priority when both references are freshly swept.
        bool previousReady = activeZone == 2 ? LondonReady : activeZone == 3 ? NYamReady : false
        float previousHigh = activeZone == 2 ? LondonHigh : NYamHigh
        float previousLow = activeZone == 2 ? LondonLow : NYamLow
        int previousId = activeZone == 2 ? 2 : 3
        bool allowPrevious = ReferenceMode != "Asia" and previousReady
        bool allowAsia = ReferenceMode != "Previous session" or activeZone == 1
        float sweepMinimum = math.max(MinSweepTicks * syminfo.mintick, MinSweepAtr * Atr)
        // A sweep must be fresh: the previous bar must not already have penetrated the threshold.
        // This prevents an expired setup from instantly re-creating itself while price remains outside.
        bool prevBuy = allowPrevious and not na(previousLow) and low <= previousLow - sweepMinimum and low[1] > previousLow - sweepMinimum and previousLow - low <= MaxSweepAtr * Atr and not f_strong_breakdown(previousLow, Atr)
        bool prevSell = allowPrevious and not na(previousHigh) and high >= previousHigh + sweepMinimum and high[1] < previousHigh + sweepMinimum and high - previousHigh <= MaxSweepAtr * Atr and not f_strong_breakout(previousHigh, Atr)
        bool asiaBuy = allowAsia and AsiaReady and low <= AsiaLow - sweepMinimum and low[1] > AsiaLow - sweepMinimum and AsiaLow - low <= MaxSweepAtr * Atr and not f_strong_breakdown(AsiaLow, Atr)
        bool asiaSell = allowAsia and AsiaReady and high >= AsiaHigh + sweepMinimum and high[1] < AsiaHigh + sweepMinimum and high - AsiaHigh <= MaxSweepAtr * Atr and not f_strong_breakout(AsiaHigh, Atr)
        bool newBuy = BuySetup.stage == 0 and not buyResetThisBar and (prevBuy or asiaBuy)
        bool newSell = SellSetup.stage == 0 and not sellResetThisBar and (prevSell or asiaSell)
        if newBuy and newSell
            newBuy := false
            newSell := false
        if newBuy
            bool usePrevious = prevBuy
            float refLow = usePrevious ? previousLow : AsiaLow
            float refHigh = usePrevious ? previousHigh : AsiaHigh
            bool recentSwingHighValid = not na(LastSwingHigh) and not na(LastSwingHighBar) and bar_index - LastSwingHighBar <= StructureBars * 3 and LastSwingHigh > refLow
            float structureCandidate = recentSwingHighValid and not na(PriorHigh) ? math.max(LastSwingHigh, PriorHigh) : recentSwingHighValid ? LastSwingHigh : PriorHigh
            SweepSetup s = SweepSetup.new()
            s.stage := 1
            s.zone := activeZone
            s.reference := usePrevious ? previousId : 1
            s.level := refLow
            s.farLevel := refHigh
            s.midpoint := (refLow + refHigh) / 2.0
            s.extreme := low
            s.structure := structureCandidate
            s.sweepBar := bar_index
            s.rangeRank := AsiaRank
            s.sweepAtr := Atr
            s.outsideCloses := close < refLow ? 1 : 0
            BuySetup := s
            if close > refLow
                BuySetup.stage := 2
                BuySetup.reclaimBar := bar_index
                BuySetup.reclaimClose := close
                BuySetup.postReclaimExtreme := high
        if newSell
            bool usePrevious = prevSell
            float refHigh = usePrevious ? previousHigh : AsiaHigh
            float refLow = usePrevious ? previousLow : AsiaLow
            bool recentSwingLowValid = not na(LastSwingLow) and not na(LastSwingLowBar) and bar_index - LastSwingLowBar <= StructureBars * 3 and LastSwingLow < refHigh
            float structureCandidate = recentSwingLowValid and not na(PriorLow) ? math.min(LastSwingLow, PriorLow) : recentSwingLowValid ? LastSwingLow : PriorLow
            SweepSetup s = SweepSetup.new()
            s.stage := 1
            s.zone := activeZone
            s.reference := usePrevious ? previousId : 1
            s.level := refHigh
            s.farLevel := refLow
            s.midpoint := (refLow + refHigh) / 2.0
            s.extreme := high
            s.structure := structureCandidate
            s.sweepBar := bar_index
            s.rangeRank := AsiaRank
            s.sweepAtr := Atr
            s.outsideCloses := close > refHigh ? 1 : 0
            SellSetup := s
            if close < refHigh
                SellSetup.stage := 2
                SellSetup.reclaimBar := bar_index
                SellSetup.reclaimClose := close
                SellSetup.postReclaimExtreme := low
        bool emaUp = not na(TrendEma[TrendSlopeBars]) and TrendEma > TrendEma[TrendSlopeBars]
        bool emaDown = not na(TrendEma[TrendSlopeBars]) and TrendEma < TrendEma[TrendSlopeBars]
        bool buyAligned = close > TrendEma and emaUp
        bool sellAligned = close < TrendEma and emaDown
        float buyBodyRequirement = ConfirmBodyAtr * (buyAligned ? 1.0 : CounterTrendBodyMult)
        float sellBodyRequirement = ConfirmBodyAtr * (sellAligned ? 1.0 : CounterTrendBodyMult)
        bool buyStructureBreak = BuySetup.stage == 2 and not na(BuySetup.structure) and close > BuySetup.structure
        bool sellStructureBreak = SellSetup.stage == 2 and not na(SellSetup.structure) and close < SellSetup.structure
        bool buyDirectional = BuySetup.stage == 2 and f_bull_displacement(Atr, buyBodyRequirement)
        bool sellDirectional = SellSetup.stage == 2 and f_bear_displacement(Atr, sellBodyRequirement)
        bool buyModeConfirmed = BuySetup.stage == 2 and (SignalMode == "Fast" ? bar_index == BuySetup.reclaimBar : bar_index > BuySetup.reclaimBar and close > BuySetup.reclaimClose and buyDirectional and (SignalMode != "Strict" or buyStructureBreak))
        bool sellModeConfirmed = SellSetup.stage == 2 and (SignalMode == "Fast" ? bar_index == SellSetup.reclaimBar : bar_index > SellSetup.reclaimBar and close < SellSetup.reclaimClose and sellDirectional and (SignalMode != "Strict" or sellStructureBreak))
        // Even in Fast/Balanced mode, counter-trend trades must prove a real micro structure break.
        bool buyCounterTrendOk = buyAligned or buyStructureBreak
        bool sellCounterTrendOk = sellAligned or sellStructureBreak
        // Do not advertise a target that was already reached before the entry close.
        bool buyMidTaken = BuySetup.stage == 2 and not na(BuySetup.postReclaimExtreme) and BuySetup.postReclaimExtreme >= BuySetup.midpoint
        bool buyFarTaken = BuySetup.stage == 2 and not na(BuySetup.postReclaimExtreme) and BuySetup.postReclaimExtreme >= BuySetup.farLevel
        bool sellMidTaken = SellSetup.stage == 2 and not na(SellSetup.postReclaimExtreme) and SellSetup.postReclaimExtreme <= SellSetup.midpoint
        bool sellFarTaken = SellSetup.stage == 2 and not na(SellSetup.postReclaimExtreme) and SellSetup.postReclaimExtreme <= SellSetup.farLevel
        float buyTargetCandidate = BuySetup.stage == 2 ? (buyMidTaken ? BuySetup.farLevel : BuySetup.midpoint) : na
        float sellTargetCandidate = SellSetup.stage == 2 ? (sellMidTaken ? SellSetup.farLevel : SellSetup.midpoint) : na
        float buyInvalidationCandidate = BuySetup.stage == 2 ? BuySetup.extreme - InvalidationTicks * syminfo.mintick : na
        float sellInvalidationCandidate = SellSetup.stage == 2 ? SellSetup.extreme + InvalidationTicks * syminfo.mintick : na
        float buyRangeSize = BuySetup.stage == 2 ? BuySetup.farLevel - BuySetup.level : na
        float sellRangeSize = SellSetup.stage == 2 ? SellSetup.level - SellSetup.farLevel : na
        float buyProgress = BuySetup.stage == 2 and buyRangeSize > 0 ? (close - BuySetup.level) / buyRangeSize : na
        float sellProgress = SellSetup.stage == 2 and sellRangeSize > 0 ? (SellSetup.level - close) / sellRangeSize : na
        float buyEntryDistance = BuySetup.stage == 2 and BuySetup.sweepAtr > 0 ? (close - BuySetup.extreme) / BuySetup.sweepAtr : na
        float sellEntryDistance = SellSetup.stage == 2 and SellSetup.sweepAtr > 0 ? (SellSetup.extreme - close) / SellSetup.sweepAtr : na
        float buyRisk = BuySetup.stage == 2 ? close - buyInvalidationCandidate : na
        float sellRisk = SellSetup.stage == 2 ? sellInvalidationCandidate - close : na
        float buyReward = BuySetup.stage == 2 ? buyTargetCandidate - close : na
        float sellReward = SellSetup.stage == 2 ? close - sellTargetCandidate : na
        float buyRR = BuySetup.stage == 2 and buyRisk > 0 ? buyReward / buyRisk : na
        float sellRR = SellSetup.stage == 2 and sellRisk > 0 ? sellReward / sellRisk : na
        bool buyLocationOk = BuySetup.stage == 2 and close > BuySetup.level and close < BuySetup.farLevel and not buyFarTaken and not na(buyProgress) and buyProgress <= MaxEntryProgress and not na(buyEntryDistance) and buyEntryDistance <= MaxEntryDistanceAtr
        bool sellLocationOk = SellSetup.stage == 2 and close < SellSetup.level and close > SellSetup.farLevel and not sellFarTaken and not na(sellProgress) and sellProgress <= MaxEntryProgress and not na(sellEntryDistance) and sellEntryDistance <= MaxEntryDistanceAtr
        bool buyObjectiveOk = BuySetup.stage == 2 and not na(buyTargetCandidate) and buyTargetCandidate > close and not na(buyRR) and buyRR >= MinRewardRisk
        bool sellObjectiveOk = SellSetup.stage == 2 and not na(sellTargetCandidate) and sellTargetCandidate < close and not na(sellRR) and sellRR >= MinRewardRisk
        bool buyConfirmed = buyModeConfirmed and buyCounterTrendOk and buyLocationOk and buyObjectiveOk
        bool sellConfirmed = sellModeConfirmed and sellCounterTrendOk and sellLocationOk and sellObjectiveOk
        bool insideReviewZone = false
        if true and array.size(SignalBoxes) > 0
            for i = 0 to array.size(SignalBoxes) - 1
                box existingBox = array.get(SignalBoxes, i)
                bool insideBoxTime = bar_index >= box.get_left(existingBox) and bar_index <= box.get_right(existingBox)
                bool insideBoxPrice = close <= box.get_top(existingBox) and close >= box.get_bottom(existingBox)
                if insideBoxTime and insideBoxPrice
                    insideReviewZone := true
        BuySignal := slotAvailable and not insideReviewZone and buyConfirmed and not sellConfirmed and f_range_matches(BuySetup.rangeRank) and f_trend_matches(buyAligned)
        SellSignal := slotAvailable and not insideReviewZone and sellConfirmed and not buyConfirmed and f_range_matches(SellSetup.rangeRank) and f_trend_matches(sellAligned)
        if BuySignal or SellSignal
            SweepSetup setup = BuySignal ? BuySetup : SellSetup
            int side = BuySignal ? 1 : -1
            bool aligned = BuySignal ? buyAligned : sellAligned
            float target = BuySignal ? buyTargetCandidate : sellTargetCandidate
            int targetTier = target == setup.midpoint ? 1 : 2
            float invalidation = BuySignal ? buyInvalidationCandidate : sellInvalidationCandidate
            float rr = BuySignal ? buyRR : sellRR
            [sampleN, targetN, failureN, timeoutN, medianMfe] = f_stats(activeZone, side, setup.reference, targetTier)
            float targetRate = f_pct(targetN, sampleN)
            string direction = BuySignal ? "BUY" : "SELL"
            string zoneName = activeZone == 1 ? "London" : activeZone == 2 ? "NY AM" : "NY PM"
            string referenceName = setup.reference == 1 ? "Asia" : setup.reference == 2 ? "London" : "NY AM"
            string mfeText = na(medianMfe) ? "—" : str.tostring(medianMfe, "#.0") + " ticks"
            SignalMessage := direction + " • " + zoneName + " • " + referenceName + " " + (BuySignal ? "low" : "high") + " sweep/reclaim • " + SignalMode + " | objective=" + (targetTier == 1 ? "mid" : "far edge") + " | R:R=" + str.tostring(rr, "#.00") + " | prior n=" + str.tostring(sampleN) + " | target=" + f_fmt_pct(targetRate) + " | median MFE=" + mfeText
            string tooltipText = SignalMessage + "\nTarget price=" + str.tostring(target, format.mintick) + "\nFailure=" + f_fmt_pct(f_pct(failureN, sampleN)) + "\nTimeout=" + f_fmt_pct(f_pct(timeoutN, sampleN)) + "\nConfirmed at bar close"
            if true
                color reviewColor = BuySignal ? #22b98e : #e75d72
                string reviewText = BuySignal ? "REVIEW BUY SETUP" : "REVIEW SELL SETUP"
                float zoneHeight = Atr * 4.5
                float zoneCenter = close
                float zoneTop = zoneCenter + zoneHeight * 0.5
                float zoneBottom = zoneCenter - zoneHeight * 0.5
                int zoneLeft = bar_index - 2
                int zoneRight = bar_index + 18
                int labelX = int(math.round((zoneLeft + zoneRight) * 0.5))
                float labelY = BuySignal ? zoneBottom : zoneTop
                box signalBox = box.new(left = zoneLeft, top = zoneTop, right = zoneRight, bottom = zoneBottom, xloc = xloc.bar_index, border_color = color.new(reviewColor, 22), border_width = 1, bgcolor = color.new(reviewColor, 90))
                label signalLabel = label.new(labelX, labelY, reviewText, xloc = xloc.bar_index, style = BuySignal ? label.style_label_up : label.style_label_down, color = reviewColor, textcolor = color.white, size = size.small, tooltip = tooltipText)
                array.push(SignalBoxes, signalBox)
                array.push(SignalLabels, signalLabel)
                if array.size(SignalLabels) > MaxSignalLabels
                    label.delete(array.shift(SignalLabels))
                    box.delete(array.shift(SignalBoxes))
            array.push(Active, ActiveEvent.new(activeZone, side, setup.reference, targetTier, time_close, close, target, invalidation, 0.0, setup.rangeRank, aligned))
            SignalsInZone += 1
            LastSignalBar := bar_index
            BuySetup := SweepSetup.new()
            SellSetup := SweepSetup.new()
        else if SignalMode == "Fast"
            // Fast reclaim is actionable only on its own closing candle. If quality filters reject it,
            // the setup is consumed instead of leaking into later bars.
            if BuySetup.stage == 2 and bar_index == BuySetup.reclaimBar
                BuySetup := SweepSetup.new()
            if SellSetup.stage == 2 and bar_index == SellSetup.reclaimBar
                SellSetup := SweepSetup.new()
alertcondition(BuySignal, "BUY • session low sweep", "TradingFinder BUY: session low sweep/reclaim in a selected kill zone on {{ticker}}.")
alertcondition(SellSignal, "SELL • session high sweep", "TradingFinder SELL: session high sweep/reclaim in a selected kill zone on {{ticker}}.")
AlertSender.AlertSender(BuySignal, Alert, "Liquidity Sweep BUY", "Bullish", "Signal", "Full", "Once Per Bar Close", "UTC", "Off", SignalMessage, open, high, low, close, close, 0, 0, 0, 0)
AlertSender.AlertSender(SellSignal, Alert, "Liquidity Sweep SELL", "Bearish", "Signal", "Full", "Once Per Bar Close", "UTC", "Off", SignalMessage, open, high, low, close, close, 0, 0, 0, 0)
````
