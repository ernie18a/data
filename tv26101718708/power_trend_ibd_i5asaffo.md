# Power Trend IBD 

- url: https://www.tradingview.com/script/i5aSaffO-Power-Trend-IBD/
- type: indicator
- pine_id: PUB;1daece7ed7084472bcc5d1677fd16a62
- version: 1.0

## Description

Power Trend (PT) indicator [b]based on Market School Rules by Investors Business Daily (IBD[/b]).

PT turns [b]ON[/b] only when ALL 4 conditions are met at the same time:
• Low > 21 EMA for 10 or more consecutive days
• 21 EMA > 50 SMA for 5 or more consecutive days
• 50 SMA is rising (higher than the previous day)
• Current bar is up (closes higher than it opens)

PT turns [b]OFF[/b] the moment the 21 EMA crosses below the 50 SMA. 

It is fully stateful — once triggered ON, it remains active until the explicit OFF cross occurs (even if some market conditions weaken temporarily).

## Source Code

````pine
//@version=5
indicator("IBD Power Trend", shorttitle="IBD PT", overlay=true, max_bars_back=500)

// ── Inputs ─────────────────────────────────────
emaLen = input.int(21, "EMA Length", minval=1, group="Power Trend Settings")
smaLen = input.int(50, "SMA Length", minval=1, group="Power Trend Settings")

// ── Moving Averages ────────────────────────────
ema21 = ta.ema(close, emaLen)
sma50 = ta.sma(close, smaLen)

// Plot MAs
plot(ema21, "21 EMA", color=color.new(color.blue, 0), linewidth=2)
plot(sma50, "50 SMA", color=color.new(color.orange, 0), linewidth=2)

// ── ULTRA-ROBUST CONDITIONS (works on 1920s close-only + HLC + full OHLC) ──
lowAboveEMA = na(low) or (low == close) ? close > ema21 : low > ema21
emaAboveSMA = ema21 > sma50
smaUp       = sma50 > sma50[1]
barUp       = na(open) or (open == close) ? (close > close[1]) : (close > open)

// ── Consecutive counters ───────────────────────
int consecLow = 0
consecLow := lowAboveEMA ? nz(consecLow[1]) + 1 : 0

int consecEMA = 0
consecEMA := emaAboveSMA ? nz(consecEMA[1]) + 1 : 0

// ── All 4 ON conditions met on THIS bar ────────
onConditions = consecLow >= 10 and consecEMA >= 5 and smaUp and barUp

// ── OFF condition ──────────────────────────────
offCross = ta.crossunder(ema21, sma50)

// ── Stateful PT logic ──────────────────────────
var bool ptOn = false
if offCross
    ptOn := false
else if onConditions
    ptOn := true

// ── Detect exact start/end of each Power Trend ─
ptTurnOn  = ptOn and not ptOn[1]
ptTurnOff = not ptOn and ptOn[1]

// ── Visuals ────────────────────────────────────

// Light green background when PT is active
bgcolor(ptOn ? color.new(color.green, 85) : na, title="PT Active Background")

// PT ON: Clean Label Up (no text)
plotshape(ptTurnOn, 
     title="PT ON Trigger Label", 
     location=location.belowbar, 
     color=color.new(color.green, 0), 
     style=shape.labelup, 
     size=size.small)

// PT OFF: Clean Label Down (no text)
plotshape(ptTurnOff, 
     title="PT OFF Trigger Label", 
     location=location.abovebar, 
     color=color.new(color.red, 0), 
     style=shape.labeldown, 
     size=size.small)

// ── Alerts ─────────────────────────────────────
alertcondition(ptTurnOn,  title="Power Trend ON",  message="Power Trend (PT) just turned ON")
alertcondition(ptTurnOff, title="Power Trend OFF", message="Power Trend (PT) just turned OFF")
````
