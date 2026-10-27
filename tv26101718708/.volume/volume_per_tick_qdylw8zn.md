# Volume Per Tick

- url: https://www.tradingview.com/script/QdYlW8zN-Volume-Per-Tick/
- type: indicator
- pine_id: PUB;9b3e3c00cc7641809dda6bb03dcfbf5a
- version: 1.0

## Description

[b]Volume Per Tick[/b]

The [b]Volume Per Tick[/b] indicator is an advanced volume analysis tool designed to uncover hidden market dynamics by analyzing the relationship between volume and price spread. By calculating the Volume Per Tick (VPT) and comparing it to historical time-specific averages, this indicator highlights exact moments of unusual market participation, absorption, and exhaustion.

[b]🧠 Core Concepts[/b]

[b]1. Volume Per Tick (VPT):[/b]
Traditional volume only tells you [i]how much[/i] was traded, but VPT tells you [i]how much effort[/i] was required to move the price. VPT is calculated by dividing the volume of a candle by its price range (High - Low). 
[list]
[*] [b]High VPT[/b] means a lot of volume was transacted within a tight price range (heavy resistance/absorption).
[*] [b]Low VPT[/b] means price moved easily with very little volume (efficient movement).
[/list]

[b]2. Time-Specific Average:[/b]
Volume naturally fluctuates throughout the trading day (e.g., the open has higher volume than the lunchtime lull). This indicator calculates a dynamic historical average of VPT for the [i]exact time of day[/i] (e.g., comparing 10:00 AM today to the average of 10:00 AM over the last 20 days). This eliminates false signals caused by natural intraday volume variations.

[b]🎨 Color-Coded Signals[/b]

The VPT columns are color-coded to instantly identify significant shifts in order flow:
[list]
[*] 🔵 [b]Blue (Big Increase):[/b] The current bar's VPT has surged significantly compared to the previous bar. Indicates a sudden influx of participation or a major clash between buyers and sellers.
[*] 🟢 [b]Green (High Volume Node):[/b] The current VPT is exceptionally higher than the historical Time-Specific Average for this exact time of day. Highlights abnormal, standout volume nodes.
[*] 🟠 [b]Orange (Big Drop):[/b] The VPT has dropped significantly compared to the previous bar. Indicates a sudden lack of interest or a highly "efficient" price move with no resistance.
[*] ⚪ [b]Silver (Default):[/b] Normal VPT activity.
[/list]

[b]💡 Example Scenarios & Trading Use Cases[/b]

[b]Scenario 1: Identifying Absorption at Key Levels[/b]
Absorption occurs when aggressive market orders are completely filled by passive limit orders, keeping the price range tight despite heavy volume. 
[list]
[*] [b]The Setup:[/b] Price approaches a known resistance level. 
[*] [b]The Signal:[/b] As price hits the level, the candle closes with a small body/tight range, but the indicator prints a massive [b]Blue[/b] or [b]Green[/b] VPT column. 
[*] [b]The Meaning:[/b] The high volume (effort) resulted in very little price movement (result). If at support, sellers are aggressively selling, but strong limit buyers are absorbing all the pressure. This is a classic hallmark of accumulation and often precedes a sharp reversal away from the level.
[/list]
[image]https://www.tradingview.com/x/C1y8w9xI/[/image]

[b]Scenario 2: Spotting Efficient Reversals[/b]
Markets often move toward liquidity efficiently, only to violently reverse when the liquidity is tapped.
[list]
[*] [b]The Setup:[/b] Price makes a strong push in one direction with completely normal or low VPT (often printing [b]Orange[/b] columns). This means the price is moving easily because there is no opposing liquidity blocking its path (an efficient move).
[*] [b]The Signal:[/b] Suddenly, a [b]Blue[/b] or [b]Green[/b] column appears, interrupting the efficient move, often resulting in a wick or rejection candle.
[*] [b]The Meaning:[/b] The "easy" move has abruptly hit a wall of liquidity. The sudden spike in VPT confirms that the opposing side has stepped in with heavy volume. Traders can use this sudden shift from low VPT to high VPT as a trigger to enter a reversal trade.
[/list]
https://www.tradingview.com/x/fjUyEbKW/

[b]⚙️ Features & Alerts[/b]
[list]
[*] [b]Dynamic Asset Support:[/b] Automatically pulls appropriate ETF volume data for major futures indices (e.g., uses QQQ volume for NQ, SPY for ES, DIA for YM, IWM for RTY) to ensure the most accurate volume readings.
[*] [b]Customizable Time Windows:[/b] Set specific alert sessions (e.g., 0930-1100) to ensure you are only notified during high-probability trading hours.
[*] [b]Targeted Alerts:[/b] Receive real-time alerts whenever a Blue (Big Increase) or Green (High Volume Node) condition is met during your predefined session.
[*] [b]Testing Mode:[/b] Visualize your alert timeframes and triggers directly on the chart using background highlights and visual markers to fine-tune your strategy.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Combined by Gemini

//@version=5
indicator("Time-Specific Volume Per Tick Average [Alerts]", shorttitle="TS-VPT Alerts", format=format.volume, dynamic_requests=true)

// ───────────────────────────────────── Inputs ──────────────────────────────────────
string group_avg = "Average Calculation Settings"
lookbackDays = input.int(20, 'Lookback Days for Average', minval=1, group=group_avg)
avgLineColor = input.color(color.orange, 'Average Line Color', group=group_avg)
tf = input.timeframe('5', 'Average Line Timeframe', group=group_avg)

string group_vpt = "VPT Column Settings"
vptColumnColor = input.color(color.new(color.silver, 25), 'VPT Column Base Color', group=group_vpt)
big_drop_color = input.color(color.orange, "Big Drop Color", group=group_vpt)
big_increase_color = input.color(color.new(color.blue, 40), "Big Increase Color", group=group_vpt)
big_drop_pct = (100 - input.int(30, "Percent Diff for Color Change", group=group_vpt, minval = 0, maxval = 100)) / 100

big_vol_pct_color = input.color(color.new(color.green, 40), "Big Volume Node Color", group=group_vpt)
big_vol_pct = input.float(100, "Percent Diff for Big Volume Node") / 100

// ───────────────────────────────────── Alert Inputs ────────────────────────────────
string group_alerts = "Alert Settings"
alert_session = input.session("0930-1600", "Alert Time Session", group=group_alerts, tooltip="Format: HHMM-HHMM (e.g., 0930-1100)")
alert_timezone = input.string("America/New_York", "Timezone", group=group_alerts)
testing_mode = input.bool(false, "Testing Mode (Show Alerts/Background)", group=group_alerts)
show_all_vpt = input.bool(false, "Show All VPT", group=group_alerts)

// ────────────────────────────── Volume Per Tick (VPT) Calculation ───────────────────────────────
string ticker = syminfo.ticker
float sourceVolume = switch ticker
    "NQ1!"  => (request.security("QQQ", timeframe.period, volume)) 
    "YM1!"  => (request.security("DIA", timeframe.period, volume)) 
    "ES1!"  => (request.security("SPY", timeframe.period, volume)) 
    "RTY1!" => (request.security("IWM", timeframe.period, volume)) 
    => volume

float adjustedRange = math.max(high - low, syminfo.mintick) // high - low + math.abs(open - close)
float volumePerTick = adjustedRange > 0 ? sourceVolume / adjustedRange : 0
bool isMarketHours = not show_all_vpt ? not na(time(timeframe.period, "0930-1600", "America/New_York")) : true

// ─────────────────── Time-Specific Average Calculation (Manual Accumulation) ─────────────────────
is_new_htf_bar = ta.change(time(tf))

var float vpt_sum_htf = 0.0
var int bars_in_htf = 0

if isMarketHours
    vpt_sum_htf += volumePerTick
    bars_in_htf += 1

var avgVptByMinute = array.new<float>(1440, na)
var countByMinute = array.new<int>(1440, 0)

if is_new_htf_bar
    // Calculate the average for the bar that just completed
    float completed_avg_vpt = bars_in_htf[1] > 0 ? vpt_sum_htf[1] / bars_in_htf[1] : na
    
    // Use the start time of the completed HTF bar as the key for the array
    int barMinute = hour(time(tf)[1], 'America/New_York') * 60 + minute(time(tf)[1], 'America/New_York')

    if not na(completed_avg_vpt)
        float prevAvg = array.get(avgVptByMinute, barMinute)
        int prevCnt = array.get(countByMinute, barMinute)
        int newCnt = math.min(prevCnt + 1, lookbackDays)
        float newAvg = na(prevAvg) ? completed_avg_vpt : (prevAvg * math.min(prevCnt, lookbackDays - 1) + completed_avg_vpt) / newCnt
        array.set(avgVptByMinute, barMinute, newAvg)
        array.set(countByMinute, barMinute, newCnt)

    // Reset the sum and count for the new bar
    vpt_sum_htf := isMarketHours ? volumePerTick : 0.0
    bars_in_htf := isMarketHours ? 1 : 0

// Retrieve the average using the start time of the current HTF bar
int currentHtfMinute = hour(time(tf), 'America/New_York') * 60 + minute(time(tf), 'America/New_York')
float avgVpt = array.get(avgVptByMinute, currentHtfMinute)

// ───────────────────────────────────── Logic & Colors ─────────────────────────────────────────

// define logic for colors first so we can use it in alerts
bool is_blue_increase = (volumePerTick * big_drop_pct > volumePerTick[1])
bool is_orange_drop = (volumePerTick < volumePerTick[1] * big_drop_pct) and not is_blue_increase
bool is_green = volumePerTick >= avgVpt * (1 + big_vol_pct) and not is_blue_increase

// Determine final color
color vptBarColor = is_blue_increase ? big_increase_color : is_orange_drop ? big_drop_color : is_green ? big_vol_pct_color : vptColumnColor

// ───────────────────────────────────── Alerts ─────────────────────────────────────────

// Check if we are inside the user defined alert session
bool in_alert_time = not na(time(timeframe.period, alert_session, alert_timezone))

// Condition: Green OR Blue, inside market hours, inside user alert session
bool alert_condition_green = (is_green) and not (is_green or is_blue_increase)[1] and isMarketHours and in_alert_time

bool alert_condition_blue = (is_blue_increase) and not (is_blue_increase)[1] and isMarketHours and in_alert_time


// Trigger Alert
if alert_condition_green or alert_condition_blue
    alert("Significant VPT Detected: " + (is_green ? "High Volume Node (Green)" : "Big Increase (Blue)") + " | VPT: " + str.tostring(volumePerTick, "#.##"), alert.freq_once_per_bar_close)



alertcondition(alert_condition_green, title="Green VPT Alert", message="Significant VPT Activity Detected within allowed time window")

alertcondition(alert_condition_blue, title="Blue VPT Alert", message="Significant VPT Activity Detected within allowed time window")


// ───────────────────────────────────── Plots ─────────────────────────────────────────

// Background Highlight (Testing Mode Only)
bgcolor(testing_mode and in_alert_time ? color.new(color.yellow, 90) : na, title="Alert Session Background")

// Visual Markers for Alerts (Testing Mode Only) - Changed location to location.top
plotshape(testing_mode and alert_condition_green, title="Alert Marker Green", style=shape.labeldown, location=location.top, color=color.green, text="ALERT", textcolor=color.white, size=size.tiny)
plotshape(testing_mode and alert_condition_blue, title="Alert Marker Blue", style=shape.labeldown, location=location.top, color=color.blue, text="ALERT", textcolor=color.white, size=size.tiny)


// // Main Plots
plot(isMarketHours ? volumePerTick : na, "Volume Per Tick", style=plot.style_columns, color=vptBarColor)
plot(isMarketHours ? avgVpt : na, "Average VPT", color=avgLineColor, linewidth=1, style=plot.style_steplinebr)

// plot(volumePerTick, "Volume Per Tick", style=plot.style_columns, color=vptBarColor)
// plot(avgVpt, "Average VPT", color=avgLineColor, linewidth=1, style=plot.style_steplinebr)
````
