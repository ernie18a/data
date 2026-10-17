# Random Entry Benchmark

- url: https://www.tradingview.com/script/ObbtMmcy-Random-Entry-Benchmark/
- type: indicator
- pine_id: PUB;59b5b27644594585b48b6984343091e4
- version: 1.0

## Description

[b]Can Your Strategy Beat Random Entries?[/b]

Most traders spend countless hours searching for the perfect entry signal. But what if random entries could achieve similar results?
[b]Random Entry Benchmark [/b]is designed to put your strategy's edge to the test. Instead of relying on indicators, patterns, or market predictions, it generates completely random long-only entries and manages trades using realistic risk controls, including stop losses, risk-reward targets, and position sizing.
In strong markets, even random entries can produce surprisingly respectable returns. A profitable backtest alone does not prove that a strategy has a genuine edge. By running [i]multiple independent simulations[/i] and analyzing the distribution of outcomes, this indicator establishes a statistical benchmark for what can be achieved without any predictive entry logic.
If your strategy cannot consistently outperform randomness, does it really have an edge?
The simulator reports key metrics including net return, win rate, average trade return, maximum drawdown, and percentile outcomes, helping separate skill from luck.

[b]Key Features[/b]

[b]1. Multiple Simulations Instead of a Single Test[/b]
A single random backtest tells very little because luck plays a large role. The simulator performs multiple independent random-entry runs and aggregates the results, providing a Monte Carlo-style view of potential outcomes.
Review key performance metrics across all simulations:
- Net Return
- Win Rate
- Average Trade Return
- Maximum Drawdown
[b]2. Percentile-Based Results[/b]
Understand the full distribution of outcomes rather than relying on averages alone.
Typical statistics include:
- 25th Percentile
- Median (50th Percentile)
- 75th Percentile
This helps distinguish normal outcomes from exceptionally lucky or unlucky runs.
[b]3. Realistic Trading Rules[/b]
The simulator incorporates common risk management techniques used in actual trading:
- Configurable Stop Loss
- Configurable Risk-Reward Ratio
- Risk-Based Position Sizing
This creates a more realistic benchmark for swing trading and day trading strategies.

[b]How to Use[/b]
1.	Configure stop-loss and risk-reward settings that closely match your own strategy.
2.	Run the simulation and review the statistical results.
3.	Compare your strategy's performance against the random-entry benchmark.
4.	Determine whether your entry methodology produces results that are meaningfully better than chance.
[i]Note:[/i] The simulator currently generates long-only entries, and only one position can be open at a time. The strategy compounds returns by sizing positions based on current account equity (initial capital plus net profit/loss), while limiting risk on each trade according to the Max Risk % setting.

[b]Important![/b]
This indicator does not generate trading signals and is not intended as a trading strategy.
Its purpose is to provide a statistical benchmark against which traders can evaluate the effectiveness of their own entry techniques.

[b]Input Parameters[/b]

[b]Execution Period[/b]
[b]Start Year / Month[/b] – Beginning of the simulation period.
[b]End Year / Month[/b] – End of the simulation period.
Only for intraday timeframes:
[b]Trading Hours[/b] – Time window during which random entries can be generated.
[b]Time Zone[/b] – Timezone used for the trading session.
[b]Close @ COB[/b] – Forces all open positions to be closed at the end of the regular trading session.

[b]Strategy Parameters[/b]
[b]Initial Capital[/b] – Starting account balance used for the simulation.
[b]Max Risk %[/b] – Maximum percentage of account equity risked per trade.
[b]STP Type[/b] – Method used to calculate stop-loss distance (e.g., ATR-based or fixed % change).
[b]Parameter (M)[/b] – Value used by the selected stop-loss method.
ATR: Stop Loss = Entry Candle Low − M × ATR(14)
Change %: Stop Loss = Entry Price × (1 − M/100)
[b]PL Ratio[/b] – Profit target expressed as a multiple of the stop-loss distance (Risk/Reward ratio).
[b]Max Bars[/b] – Maximum number of bars a trade can remain open before being closed.

[b]Simulation Parameters[/b]
[b]Random Seed[/b] – Controls the random number sequence used for the first simulation run. Using the same seed reproduces identical results.
[b]Entry Frequency[/b] – Average number of random trade entries generated during the simulation period.
[b]Runs #[/b] – Number of independent simulation runs. Higher values produce more statistically reliable results.
[b]Low-High %[/b] – Lower and upper percentiles displayed in the results. Median values are always shown.

[b]Visuals[/b]
[b]Dashboard Position and Size[/b] – Position and text size of the results output.
[b]Plot[/b] – Selects the performance metric to visualize (Equity, Net Profit, Win Rate, etc.). Trade markers are displayed only for the first simulation run.

[b]Output Results[/b]
[b]Total Trades[/b] – Number of trades executed during the simulation.
[b]Net Return[/b] – Total percentage return generated over the simulation period (Net Profit / Initial Capital).
[b]Win Rate[/b] – Percentage of profitable trades.
[b]Avg Return[/b] – Average percentage net return per trade.
[b]Max Drawdown[/b] – Largest peak-to-trough decline in account equity during the simulation.
[b]Percentiles (25%, 50%, 75%)[/b] – Results are reported across all simulation runs:
- [b]25%[/b] – Conservative outcome (75% of runs performed better)
- [b]50%[/b] – Median outcome
- [b]75%[/b] – Favorable outcome (25% of runs performed better)

[b]Known Issues[/b]
[b]1. TradingView Execution Limits[/b]
Due to TradingView's script execution time limits, the indicator may occasionally fail to complete all simulations, especially when using a long execution period and/or a large number of simulation runs.
In most cases, reducing the amount of historical data or the number of runs will resolve the issue.
[b]2. Intraday Close at COB[/b]
On some symbols and timeframes, TradingView does not always allow reliable identification of the final bar of the regular trading session. As a result, positions configured to close at the end of the session may occasionally remain open beyond the intended close and be exited on a later bar.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hermes_trisme

//@version=6
indicator("Random Entry Benchmark", max_labels_count = 500 )
import hermes_trisme/Functions/3 as fn

START_YEAR = 	  input (2023,"Start Year       ",inline="start_date", group = "Execution Period")
START_MONTH = 	  input (01,"Month        ",inline="start_date", group = "Execution Period")
END_YEAR =	  	  input (2026,"End Year         ", inline="end_date", group = "Execution Period")
END_MONTH =	  	  input (12,"Month        ", inline="end_date", group = "Execution Period")
TRADING_HOURS =   input.session("1530-2100", "Trading Hours ",inline="opt0", group = "Execution Period")
TIME_ZONE =       input.string("GMT+2", "",inline="opt0", group = "Execution Period", display = display.none, tooltip = "only for intraday timeframes; timezone - e.g. GMT+1")
CLOSE_COB = 	  input.bool(true, "Close @COB", group = "Execution Period", tooltip = "for intraday timeframes: forces trades to be closed at end of RTH")

INITIAL_CAPITAL = input.int(1000000,"Initial Capital   ", inline = "opt1", group = "Strategy Parameters")
MAX_RISK =      input.float(1,"Max Risk %    ", minval = 0.1, step = 0.1, inline = "opt1", group = "Strategy Parameters", tooltip = "max risk per trade as % of account balance")
STP_TYPE = 		input.string("ATR", "STP Type          ",options = ["ATR", "CHANGE"], inline="opt2", group = "Strategy Parameters")
STP_VALUE =  	input.float(1, "Parameter(M)", minval = 0, step=0.5, inline="opt2", group = "Strategy Parameters", tooltip = "ATR: Stop Loss = Entry Candle Low − M × ATR(14); Change %: Stop Loss = Entry Price × (1 − M/100)")
MIN_PL =      	input.float(2,"PL Ratio           ", minval = 0.5, step = 0.1, inline = "opt3", group = "Strategy Parameters")
MAX_BARS = 		input.int(10, "Max Bars     ", inline="opt3", group = "Strategy Parameters", tooltip = "max duration of trade after which it is automatically closed")

RANDOM_SEED = input.int(1,"Random Seed",minval = 1, inline="show3", group = "Simulation Parameters")
RANDOM_THRES = input.int(20,"Entry Frequency",minval = 1, maxval = 100, inline="show3", group = "Simulation Parameters")
RANDOM_RUNS = input.int(100,"Runs #            ", group = "Simulation Parameters")
LOW_PERC = input.int(25, "Low-High %     ", inline="show4", group = "Simulation Parameters")
HIGH_PERC = input.int(75, "-----", inline="show4", group = "Simulation Parameters")


DASHBOARD_POS  = input.string('Top Right', 'Dashboard Position', group = "Visuals", options = ['Top Right', 'Top Center', 'Top Left', 'Middle Right', 'Middle Center', 'Middle Left', 'Bottom Right', 'Bottom Center', 'Bottom Left'], inline="show 2")
DASHBOARD_SIZE     = input.string('Small', 'Size', group = "Visuals", options = ['Auto', 'Nano', 'Micro', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], inline="show 2")
SHOW_PLOT = input.string("NONE", "Plot                                  ",options = ["NONE","WR","EQUITY", "NP"], inline="show 1", tooltip = "shows KPI plot only for the first run", group = "Visuals")		

var DASHBOARD_POS_parsed = switch DASHBOARD_POS
    'Top Right'       => position.top_right
    'Top Center'      => position.top_center
    'Top Left'        => position.top_left
    'Middle Right'    => position.middle_right
    'Middle Center'   => position.middle_center
    'Middle Left'     => position.middle_left
    'Bottom Right'    => position.bottom_right
    'Bottom Center'   => position.bottom_center
    'Bottom Left'     => position.bottom_left

var int DASHBOARD_SIZE_parsed = switch DASHBOARD_SIZE
    'Auto'            => 0
    'Nano'            => 5
    'Micro'           => 6
    'Tiny'            => 8
    'Small'           => 10
    'Normal'          => 14
    'Large'           => 20
    'Huge'            => 36



type position_info 
	int direction = 1
	float open_price = 0
	float profit_target = 0
	float stop_loss =0
	int bar_num = 0
	int qty = 0
    bool active = false

type candle_info
	float close = close
	float high = high
	float low = low
	int bar_index = bar_index
	float atr
	bool allowed = true
	bool session_last_bar = false

enter_trade(position_info trade_, candle_info candle_, float capital_)=>
	float stop_loss = 0
	switch STP_TYPE 
		"ATR" => stop_loss := candle_.low-STP_VALUE*candle_.atr
		"CHANGE" => stop_loss := candle_.close*(1-STP_VALUE/100)
	if candle_.allowed 
		trade_.active  := true
		trade_.open_price := candle_.close
		trade_.stop_loss := stop_loss
		trade_.profit_target := candle_.close + MIN_PL*(candle_.close-stop_loss)
		max_risk = capital_*MAX_RISK/100
		qty1 = int(math.floor(max_risk/(math.abs(candle_.close-stop_loss)*syminfo.pointvalue)))
		qty2 = int(math.floor(capital_/(candle_.close*syminfo.pointvalue)))
		trade_.qty := math.min(qty1,qty2)
		trade_.bar_num := candle_.bar_index
	trade_


process_trade(position_info trade_, candle_info candle_)=>
	float net_profit = 0
	bool win_flag = false
	bool closed_flag = false
	if trade_.active
		if candle_.high>=trade_.profit_target
			win_flag := true
			net_profit := trade_.qty * (trade_.profit_target - trade_.open_price) * syminfo.pointvalue
			closed_flag  := true
		else if candle_.low<=trade_.stop_loss
			net_profit -= trade_.qty * (trade_.open_price - trade_.stop_loss) * syminfo.pointvalue
			closed_flag  := true
		else if (candle_.bar_index - trade_.bar_num)>=MAX_BARS or (candle_.session_last_bar and CLOSE_COB)
			net_profit := trade_.qty * (candle_.close-trade_.open_price) *syminfo.pointvalue
			if (candle_.close-trade_.open_price)>0
				win_flag := true
			closed_flag  := true
	[closed_flag, net_profit, win_flag]

OPEN_TIME = str.substring(TRADING_HOURS,0,2)+":"+str.substring(TRADING_HOURS,2,4)
CLOSE_TIME = str.substring(TRADING_HOURS,5,7)+":"+str.substring(TRADING_HOURS,7,9)

time_period = fn.is_date_between(time, START_YEAR,START_MONTH, END_YEAR, END_MONTH, TIME_ZONE) 
trading_hours =  (timeframe.isintraday ? fn.is_time_between(time,OPEN_TIME,CLOSE_TIME,TIME_ZONE) and not session.islastbar_regular: true)
session_last_bar_ = timeframe.isintraday and (session.islastbar_regular or fn.is_time_between(time, "16:00","18:00","America/New_York"))

atr_ = ta.atr(14)

var chart_candles = array.new<candle_info>()
new_candle = candle_info.new(atr=atr_, allowed = trading_hours, session_last_bar = session_last_bar_) 
if time_period
	chart_candles.push(new_candle)

p = math.random(0, 100, RANDOM_SEED)
var trade_random = position_info.new()
var float random_np = 0
var random_wins = 0
var random_trades_cnt = 0

[closed_flag, net_profit, win_flag] = process_trade(trade_random, new_candle)
if closed_flag
	random_np += net_profit
	random_wins := random_wins + (win_flag ? 1 : 0 )
	trade_random.active := false
	if SHOW_PLOT != "NONE"
		label.new(bar_index, close, "Close", yloc = yloc.abovebar, size = size.small, color = color.rgb(120, 123, 134, 77), force_overlay = true)


if p < RANDOM_THRES and trade_random.active  == false and time_period and trading_hours and closed_flag == false
	trade_random := enter_trade(trade_random, new_candle, INITIAL_CAPITAL+random_np)
	random_trades_cnt := random_trades_cnt + (trade_random.active ? 1 : 0)
	if trade_random.active and SHOW_PLOT != "NONE"
		label.new(bar_index, close, "Buy ", yloc = yloc.belowbar, size = size.small, color = color.rgb(76, 175, 79, 71), style = label.style_label_up, force_overlay = true)
	 
random_return = math.round(100*random_np/INITIAL_CAPITAL)
plot(random_np,"random NP", display = display.data_window)
plot(random_return,"random NP, %", display = display.data_window)
plot(random_trades_cnt,"random CNT", display = display.data_window)
plot(math.round(random_return/random_trades_cnt,1),"random AVG NP", display = display.data_window, precision = 2)
plot(random_wins/random_trades_cnt,"Win rate", display = SHOW_PLOT == "WR" ? display.all : display.data_window, precision = 2, color = color.gray)
plot(INITIAL_CAPITAL+random_np,"Equity", display = SHOW_PLOT == "EQUITY" ? display.all : display.data_window, precision = 0, color = color.gray)
plot(random_np,"Net Profit", display = SHOW_PLOT == "NP" ? display.all : display.data_window, precision = 0, color = random_np >0 ? color.green : color.red)


//Monte carlo simulations

var data_display = table.new(DASHBOARD_POS_parsed,4,10,na,force_overlay = true)
var simulations = matrix.new<float>(5,0,0)

calc_stats(array<float> data_vector_)=>
	median = data_vector_.median()
	perc25 = data_vector_.percentile_linear_interpolation(LOW_PERC)
	perc75 = data_vector_.percentile_linear_interpolation(HIGH_PERC)
	[perc25, median, perc75]

display_stats(string name_,int id_, string format_, is_perc=true)=>
	[perc_25, perc_50, perc_75] = calc_stats(simulations.row(id_))
	data_display.cell(0,id_+1,name_, text_size=DASHBOARD_SIZE_parsed, text_halign = text.align_left )
	data_display.cell(1,id_+1,str.tostring(perc_25,format_) + (is_perc ? "%" : na), text_size=DASHBOARD_SIZE_parsed)
	data_display.cell(2,id_+1,str.tostring(perc_50, format_) + (is_perc ? "%" : na), text_size=DASHBOARD_SIZE_parsed)
	data_display.cell(3,id_+1,str.tostring(perc_75, format_) + (is_perc ? "%" : na), text_size=DASHBOARD_SIZE_parsed)

if barstate.islastconfirmedhistory and chart_candles.size()>0
	for run_n = 1 to RANDOM_RUNS
		trade = position_info.new()
		float total_net_profit=0
		int trades_cnt = 0
		int wins_cnt = 0
		float max_equity = 0
		float max_drawdown = 0

		for k=0 to chart_candles.size()-1
			candle = chart_candles.get(k)
			[closed_flag, net_profit, win_flag] = process_trade(trade, candle)
			if closed_flag
				trade.active := false
				total_net_profit += net_profit
				wins_cnt := wins_cnt + (net_profit > 0 ? 1 : 0)
				max_equity := math.max(max_equity, INITIAL_CAPITAL + total_net_profit)
				if  (INITIAL_CAPITAL + total_net_profit) < max_equity
					max_drawdown := math.max(max_drawdown, 100*(1-(INITIAL_CAPITAL + total_net_profit)/max_equity))
			rn = math.random(0, 100, run_n)
			if rn < RANDOM_THRES and trade.active == false
				trade := enter_trade(trade, candle, INITIAL_CAPITAL+total_net_profit)				
				trades_cnt := trades_cnt + (trade.active ? 1 : 0)
		
		win_rate = math.round(100*wins_cnt / trades_cnt)
		net_return = math.round(100*total_net_profit/INITIAL_CAPITAL)
		avg_return =  net_return / trades_cnt

		simulations.add_col(array_id = array.from(trades_cnt, net_return, win_rate, avg_return, max_drawdown))

	data_display.cell(0,0,"PERCENTILE", text_size=DASHBOARD_SIZE_parsed, text_halign = text.align_left )
	data_display.cell(1,0,str.tostring(LOW_PERC)+"%", text_size=DASHBOARD_SIZE_parsed)
	data_display.cell(2,0,"50%", text_size=DASHBOARD_SIZE_parsed)
	data_display.cell(3,0,str.tostring(HIGH_PERC)+"%", text_size=DASHBOARD_SIZE_parsed)

	display_stats("Total Trades", 0, "0", false)
	display_stats("Net Return", 1, "0.0")
	display_stats("Win Rate", 2, "0.0")
	display_stats("Avg Return", 3,  "0.0")
	display_stats("Max Drawdown", 4, "0.0")
````
