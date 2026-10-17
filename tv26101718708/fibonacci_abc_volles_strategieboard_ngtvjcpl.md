# Fibonacci A-B-C Volles Strategie-Board

- url: https://www.tradingview.com/script/nGTvjCpL/
- type: indicator
- pine_id: PUB;43d3124af0e74c1393039efd295beff8
- version: 1.0

## Description

[b](ENGLISH)[/b]
---
The Fibonacci Betting-Playbook 062026: How to read the Strategy Board

If you want to succeed in the markets, you need more than just a gut feeling, you need a system that delivers crystal-clear odds. This script is your personal bookmaker dashboard directly on the chart. It scans price movements for a highly profitable pattern and shows you exactly when the risk-reward ratio is as good as a massively overpriced underdog quote in La Liga.

Here is the official manual for you and your users, so that everyone knows exactly how to read the signals and when it's better to keep your feet still.
The Game Plan: The A-B-C Formation

In the background, the script constantly scans for a specific market movement, the so-called A-B-C ZigZag. Think of it like the perfect set piece:

[list]
[*]Point A (The Kickoff): The lowest point where the movement begins.
[*]Point B (The First Goal): The first high point. The momentum is here. 
[*]Point C (The Tactical Pause): The price drops back slightly. Exactly here, in this pullback, we calculate our entry before the second half – the next big price breakout – begins.
[/list]

As soon as the script recognizes this formation, it paints your playing field (the boxes) onto the chart.
Your Betting Odds: The Zones on the Board

When the setup is "hot", you will see two distinct boxes on your screen. They take the guesswork out of the equation and tell you exactly where you need to place your chips.

🟢 The Green Zone: The Entry (The Value Bets)

Here is where you build your position. If the price falls into this box, we have a statistical advantage (edge).

[list]
[*]Line 0.500 (Initial Entry): The market has corrected half of its rally. Here you place your first, smaller bet.
[*]Line 0.618 (Ideal Reload): This is the "Golden Ratio". The absolute sweet spot in the Fibonacci system. If the price drops here, you double down. The chance of a bounce is highest here.
[*]Line 0.667 (The Last Bastion / STOP): The red dashed line. If the price falls below this, the setup is busted. The trade is canceled, you pull the ripcord, and accept the small loss. No hoping, no praying – strict bankroll management.
[/list]

🟠 The Orange Zone: The Cashout (Taking Profits)

If the trade plays out and the price shoots up, this box shows you where the bookie opens the register.

[list]
[*]Line 1.618 (Potential Turning Point): Your first target (Take Profit 1). Here you take a portion of your winnings off the table. Ring the register!
[*]Line 1.809 (Trailing Stop-Loss): The price keeps running? Perfect. Trail your stop-loss to your entry price now. You are now riding a risk-free bet.
[*]Line 2.000 (Massive Resistance): The absolute maximum. The air gets extremely thin up here. Take your remaining profit and close the position.
[/list]

🔴 The VAR Signal: The Red Warning Box

Markets are often chaotic. If the script fails to recognize a clear A-B-C pattern, the stop-loss has been hit, or the target has already been reached, the system immediately deletes all lines from the chart.

Instead, a red box appears in the center: "CURRENTLY NO RECOMMENDATION POSSIBLE - WAIT FOR FURTHER CHART SIGNALS".
This is like a suspended betting market during a VAR check. Your only task at this moment: Do not trade. Keep your hands off the buy button. Wait patiently until the system builds the next profitable setup.
What you as a user must absolutely pay attention to (The Golden Rules)
[list=1]
[*]Patience is your best croupier: Do not trade blindly just because the price is moving. Always wait until the boxes appear on the chart and the price dips into the green zone.
[*]Respect the Stop-Loss (0.667): Even in the best Spanish casinos, you don't win every hand. If the red line is breached, close the trade on Trade Republic immediately. Whoever hesitates here gambles away their bankroll.
[*]Split your stakes: Do not wager your entire capital at the 0.500 line. Make a partial entry and keep your powder dry in case the price drops to the golden 0.618 line. This massively improves your average entry price.
[*]Secure your profits: When the price reaches the orange 1.618 line, do not get greedy. Take a partial profit. Nothing is more frustrating than turning a fat paper profit back into a loss.
[/list]

## Source Code

````pine
//@version=6
indicator("Fibonacci A-B-C Volles Strategie-Board", overlay=true, max_boxes_count=100, max_lines_count=100)

// --- EINSTELLUNGEN ---
length = input.int(15, "Pivot Sensitivität (Kerzen)")
ret_500 = 0.500   // Einstieg 1
ret_618 = 0.618   // Haupt-Einstieg
ret_667 = 0.667   // Schmerzgrenze
ext_1618 = 1.618  
ext_1809 = 1.809  
ext_2000 = 2.000  

// --- ZIGZAG SPEICHER ---
ph = ta.pivothigh(high, length, length)
pl = ta.pivotlow(low, length, length)

val_pl1 = ta.valuewhen(not na(pl), pl, 0), idx_pl1 = ta.valuewhen(not na(pl), bar_index[length], 0)
val_ph1 = ta.valuewhen(not na(ph), ph, 0), idx_ph1 = ta.valuewhen(not na(ph), bar_index[length], 0)
val_pl2 = ta.valuewhen(not na(pl), pl, 1), idx_pl2 = ta.valuewhen(not na(pl), bar_index[length], 1)

// --- SETUP ERKENNUNG ---
is_valid_long = (idx_pl1 > idx_ph1) and (idx_ph1 > idx_pl2) and (val_ph1 > val_pl2) and (val_pl1 > val_pl2) and (val_pl1 < val_ph1)

var float pA = na, var int iA = na
var float pB = na, var int iB = na
var float pC = na, var int iC = na
var bool setup_active = false

if is_valid_long
    pA := val_pl2, iA := idx_pl2
    pB := val_ph1, iB := idx_ph1
    pC := val_pl1, iC := idx_pl1
    setup_active := true

// --- SETUP-VALIDIERUNG (Der Hausvorteil) ---
// Setup deaktivieren, wenn der Kurs unter Punkt A fällt (Stop-Loss) 
// oder das maximale Take-Profit-Ziel (2.000) erreicht ist.
if setup_active
    impulse_check = pB - pA
    tp3_check = pC + (impulse_check * ext_2000)
    if low < pA or high > tp3_check
        setup_active := false

// --- BERECHNUNG & VISUALISIERUNG ---
var box b_entry = na, var box b_target = na
var line l_AB = na, var line l_BC = na
var line l_buy1 = na, var line l_buy2 = na, var line l_stop = na
var line l_tp1 = na, var line l_tp2 = na, var line l_tp3 = na
var label labA = na, var label labB = na, var label labC = na

// Der fixierte Kasten für die Warnmeldung
var table tb_no_signal = table.new(position.middle_center, 1, 1, bgcolor=color.new(color.red, 20), border_width=2, border_color=color.red)

if barstate.islast
    // Den Buchmacher-Tisch aufräumen
    box.delete(b_entry), box.delete(b_target)
    line.delete(l_AB), line.delete(l_BC)
    line.delete(l_buy1), line.delete(l_buy2), line.delete(l_stop)
    line.delete(l_tp1), line.delete(l_tp2), line.delete(l_tp3)
    label.delete(labA), label.delete(labB), label.delete(labC)

    if setup_active and not na(pC)
        // Warnkasten leeren, da wir ein gültiges Setup haben
        table.clear(tb_no_signal, 0, 0)
        
        impulse = pB - pA
        
        // Grüne Zonen Werte
        b1_val = pB - (impulse * ret_500)
        b2_val = pB - (impulse * ret_618)
        b3_val = pB - (impulse * ret_667)
        
        // Orange Zonen Werte
        tp1_val = pC + (impulse * ext_1618)
        tp2_val = pC + (impulse * ext_1809)
        tp3_val = pC + (impulse * ext_2000)

        // A-B-C Linien
        l_AB := line.new(iA, pA, iB, pB, color=color.new(color.gray, 50), width=1, style=line.style_dashed)
        l_BC := line.new(iB, pB, iC, pC, color=color.new(color.gray, 50), width=1, style=line.style_dashed)
        
        // GRÜNER KASTEN MARKIERUNGEN
        l_buy1 := line.new(iC, b1_val, bar_index + 35, b1_val, color=color.green, width=1)
        label.new(bar_index + 35, b1_val, "0,500: Erster Einstieg", style=label.style_label_left, color=color.green, size=size.small)

        l_buy2 := line.new(iC, b2_val, bar_index + 35, b2_val, color=color.green, width=1, style=line.style_dashed)
        label.new(bar_index + 35, b2_val, "0,618: Idealer Nachkauf", style=label.style_label_left, color=color.green, size=size.small)

        l_stop := line.new(iC, b3_val, bar_index + 35, b3_val, color=color.red, width=2, style=line.style_dotted)
        label.new(bar_index + 35, b3_val, "0,667: Letzte Bastion / STOP", style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small)

        // ORANGENER KASTEN MARKIERUNGEN
        l_tp1 := line.new(iC, tp1_val, bar_index + 35, tp1_val, color=color.orange, width=1)
        label.new(bar_index + 35, tp1_val, "1,618: Möglicher Wendepunkt", style=label.style_label_left, color=color.orange, size=size.small)
        
        l_tp2 := line.new(iC, tp2_val, bar_index + 35, tp2_val, color=color.orange, width=1, style=line.style_dashed)
        label.new(bar_index + 35, tp2_val, "1,809: Stop-Loss nachziehen", style=label.style_label_left, color=color.orange, size=size.small)

        l_tp3 := line.new(iC, tp3_val, bar_index + 35, tp3_val, color=color.orange, width=2)
        label.new(bar_index + 35, tp3_val, "2,000: Massiver Widerstand", style=label.style_label_left, color=color.orange, size=size.small)

        // Kästen finalisieren
        b_entry := box.new(iC, b1_val, bar_index + 35, b3_val, border_color=color.green, bgcolor=color.new(color.green, 90))
        b_target := box.new(iC, tp3_val, bar_index + 35, tp1_val, border_color=color.orange, bgcolor=color.new(color.orange, 90))

        labA := label.new(iA, pA, "A", style=label.style_circle, color=color.yellow, size=size.small)
        labB := label.new(iB, pB, "B", style=label.style_circle, color=color.yellow, size=size.small)
        labC := label.new(iC, pC, "C", style=label.style_circle, color=color.yellow, size=size.small)
    else
        // Rote Karte auf dem Platz: Kein Signal
        table.cell(tb_no_signal, 0, 0, "AKTUELL KEINE EMPFEHLUNG MÖGLICH - WARTE AUF WEITERE CHARTSIGNALE", text_color=color.white, text_size=size.large)
````
