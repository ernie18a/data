#property copyright "Evgeniy Chumakov | © Copyright 2025"
#property description "Graphs the price levels for simulated trades, including the defined TP and SL, for the selected trading direction. Brief statistics are also shown, including hourly entry breakdowns."
#property version "1.0"
#property link "https://www.mql5.com/ru/users/jack857752"
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_label1 "Points"

input double TAKE_STEP = 1.0; // Take Step, %
input double STOP_STEP = 0.5; // Stop Step, %
input int DirectionSim = 1; // Direction, 1 = Buy | -1 = Sell

input int StepLineWidth = 2; // Line Width
input color InpColor_1 = clrYellow; // Color 1
input color InpColor_2 = clrMediumSeaGreen; // Color 2

double ArrayStepPrice[]; // Step price
double ArrayTypeStep[]; // Direction buffer
double ArrayStepLast[]; // Last price value

// TRANSACTION DATA STRUCTURE
struct TradeResult
{
    datetime OpenTime;
    double   OpenPrice;
    datetime CloseTime;
    double   ClosePrice;
    int      ResultType; // 1 = TP, -1 = SL, 0 = Unknown/In Progress
    double   ProfitPercent;
    int      TimeHeldSeconds; 
};

// STRUCTURE FOR HOURLY STATISTICS
struct HourlyStats
{
    int      Hour;       
    int      TotalTrades; 
    int      Wins;       
    double   WinRate;    
};

// GLOBAL VARIABLES
TradeResult ResultsArray[];
int SequenceArray[]; 

// CONSTANTS
#define TYPE_TP 1
#define TYPE_SL -1

// FUNCTION PROTOTYPES
string GenerateTradeReport(
    const double& Prices[],          
    const datetime& Times[],         
    const int TotalBars,             
    const double TakeProfitPercent,  
    const double StopLossPercent,    
    const int TradeDirection         
);

bool SortHourlyData(const HourlyStats& a, const HourlyStats& b);

//+------------------------------------------------------------------+
int OnInit(){

ArraySetAsSeries(ArrayStepPrice,true);
ArraySetAsSeries(ArrayTypeStep,true);
ArraySetAsSeries(ArrayStepLast,true);

SetIndexBuffer(0,ArrayStepPrice,INDICATOR_DATA);
SetIndexStyle(0,DRAW_SECTION,STYLE_SOLID,StepLineWidth,InpColor_1);
   
SetIndexBuffer(1,ArrayTypeStep,INDICATOR_CALCULATIONS);
SetIndexStyle(1,DRAW_NONE,STYLE_SOLID,0,clrNONE);
  
SetIndexBuffer(2,ArrayStepLast,INDICATOR_CALCULATIONS);
SetIndexStyle(2,DRAW_NONE,STYLE_SOLID,0,clrNONE);

IndicatorSetInteger(INDICATOR_DIGITS,Digits());
IndicatorSetString(INDICATOR_SHORTNAME,"TakeStop");

return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnDeinit(const int reason){

ObjectDelete("OPEN_STEP");
ObjectDelete("TAKE_STEP");
ObjectDelete("STOP_STEP");

Comment("");

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]){

// Checking for the minimum number of bars to calculate
if(rates_total < 3){return(0);}

// Setting array indexing as in timeseries
ArraySetAsSeries(open,true);
ArraySetAsSeries(high,true);
ArraySetAsSeries(low,true);
ArraySetAsSeries(close,true);

// Checking and calculating the number of calculated bars
int total = rates_total - 2;
int limit = rates_total - IndicatorCounted();

if(limit > 1){

limit = total;

ArrayInitialize(ArrayStepPrice,EMPTY_VALUE);
ArrayInitialize(ArrayTypeStep,EMPTY_VALUE);
ArrayInitialize(ArrayStepLast,EMPTY_VALUE);

if(DirectionSim == 1){CalcStartingExtremes_Buy(limit,high,low);} // Let's get the starting point
if(DirectionSim == -1){CalcStartingExtremes_Sell(limit,high,low);} // Let's get the starting point
}
//+------------------------------------------------------------------+

// Calculating the indicator
for(int i = limit; i >= 0; i--){

if(DirectionSim == 1){
if(ArrayTypeStep[i + 1] != EMPTY_VALUE && ArrayTypeStep[i + 1] > 0){HighStepPoint_Buy(i,high,low);}
if(ArrayTypeStep[i + 1] != EMPTY_VALUE && ArrayTypeStep[i + 1] < 0){LowStepPoint_Buy(i,high,low);}
}

if(DirectionSim == -1){
if(ArrayTypeStep[i + 1] != EMPTY_VALUE && ArrayTypeStep[i + 1] > 0){HighStepPoint_Sell(i,high,low);}
if(ArrayTypeStep[i + 1] != EMPTY_VALUE && ArrayTypeStep[i + 1] < 0){LowStepPoint_Sell(i,high,low);}
}
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| COLLECTING DATA FROM THE BUFFER INTO AN ARRAY FOR WORK           |
//+------------------------------------------------------------------+
double ARRAY_STEP[];
ArrayResize(ARRAY_STEP,0,0);

datetime ARRAY_TIME[];
ArrayResize(ARRAY_TIME,0,0);

// let's write it to the array
for(int bar_pos = 0; bar_pos < iBars(Symbol(),PERIOD_CURRENT); bar_pos++){

double Buf_Step = ArrayStepPrice[bar_pos];

if(Buf_Step != EMPTY_VALUE ){

ArrayResize(ARRAY_STEP,ArraySize(ARRAY_STEP) + 1,0);
ArrayFill(ARRAY_STEP,ArraySize(ARRAY_STEP) - 1,1,Buf_Step); 

ArrayResize(ARRAY_TIME,ArraySize(ARRAY_TIME) + 1,0);
ArrayFill(ARRAY_TIME,ArraySize(ARRAY_TIME) - 1,1,iTime(Symbol(),PERIOD_CURRENT,bar_pos)); 
}

}

// we will draw lines of expected future levels
double TakeStepDev = MathAbs( ((TAKE_STEP/100.0) * ARRAY_STEP[0]));
double StopStepDev = MathAbs( ((STOP_STEP/100.0) * ARRAY_STEP[0]));

double TakeStepLevel = 0;
double StopStepLevel = 0;

if(DirectionSim == 1){
TakeStepLevel = NormalizeDouble(ARRAY_STEP[0] + TakeStepDev,Digits);
StopStepLevel = NormalizeDouble(ARRAY_STEP[0] - StopStepDev,Digits);
}

if(DirectionSim == -1){
TakeStepLevel = NormalizeDouble(ARRAY_STEP[0] - TakeStepDev,Digits);
StopStepLevel = NormalizeDouble(ARRAY_STEP[0] + StopStepDev,Digits);
}

string P1_Name = "OPEN_STEP";

bool P1_Line = ObjectCreate(ChartID(),P1_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),P1_Name,OBJPROP_COLOR,InpColor_1);
ObjectSetInteger(ChartID(),P1_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),P1_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),P1_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),P1_Name,OBJPROP_PRICE1,ARRAY_STEP[0]);

string P2_Name = "TAKE_STEP";

bool P2_Line = ObjectCreate(ChartID(),P2_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),P2_Name,OBJPROP_COLOR,InpColor_2);
ObjectSetInteger(ChartID(),P2_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),P2_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),P2_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),P2_Name,OBJPROP_PRICE1,TakeStepLevel);

string P3_Name = "STOP_STEP";

bool P3_Line = ObjectCreate(ChartID(),P3_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),P3_Name,OBJPROP_COLOR,InpColor_2);
ObjectSetInteger(ChartID(),P3_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),P3_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),P3_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),P3_Name,OBJPROP_PRICE1,StopStepLevel);

ChartRedraw();

string GenerateTradeReport_ = GenerateTradeReport(ARRAY_STEP,ARRAY_TIME,ArraySize(ARRAY_STEP),TAKE_STEP,STOP_STEP,DirectionSim);
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// DISPLAYING INFORMATION ON THE SCREEN                              |
//+------------------------------------------------------------------+
Comment("OPEN: ",ARRAY_STEP[0]," | TAKE ( ",TAKE_STEP," %): ",TakeStepLevel," | STOP ( ",STOP_STEP," %): ",StopStepLevel,
   "\n",GenerateTradeReport_
  );
//+------------------------------------------------------------------+

return(rates_total);
}
//+------------------------------------------------------------------+
//| Calculation High Step Point Buy                                  |
//+------------------------------------------------------------------+
void HighStepPoint_Buy(const int index, const double &high[], const double &low[]){

double EventHigh = False; // High point Step update event
double EventLow = False; // Low point Step update event

// we will draw lines of expected future levels
double TakeStepDev = MathAbs( ((TAKE_STEP/100.0) * ArrayStepLast[index + 1]));
double StopStepDev = MathAbs( ((STOP_STEP/100.0) * ArrayStepLast[index + 1]));

double TakeStepLevel = NormalizeDouble(ArrayStepLast[index + 1] + TakeStepDev,Digits);
double StopStepLevel = NormalizeDouble(ArrayStepLast[index + 1] - StopStepDev,Digits);

// Updating and drawing the maximum extremum
if(high[index] >= TakeStepLevel){

EventHigh = True;
ArrayTypeStep[index] = 1;
ArrayStepPrice[index] = high[index];
ArrayStepLast[index] = high[index];
}
//--------------------------------------------------------//

// Creating and drawing the minimum extremum
if(low[index] <= StopStepLevel){

EventLow = True;
ArrayTypeStep[index] = -1;
ArrayStepPrice[index] = low[index];
ArrayStepLast[index] = low[index];
}
//--------------------------------------------------------//

// No events for forming extremes. Copying past data.
if(!EventHigh && !EventLow){

ArrayTypeStep[index] = ArrayTypeStep[index + 1];
ArrayStepLast[index] = ArrayStepLast[index + 1];
}
//--------------------------------------------------------//

return;
}
//+------------------------------------------------------------------+
//| Calculation Low Step Point Buy                                   |
//+------------------------------------------------------------------+
void LowStepPoint_Buy(const int index, const double &high[], const double &low[]){

double EventHigh = False; // Low point Step update event
double EventLow = False; // High point Step update event

// we will draw lines of expected future levels
double TakeStepDev = MathAbs( ((TAKE_STEP/100.0) * ArrayStepLast[index + 1]));
double StopStepDev = MathAbs( ((STOP_STEP/100.0) * ArrayStepLast[index + 1]));

double TakeStepLevel = NormalizeDouble(ArrayStepLast[index + 1] + TakeStepDev,Digits);
double StopStepLevel = NormalizeDouble(ArrayStepLast[index + 1] - StopStepDev,Digits);

// Updating and drawing the minimum extremum
if(low[index] <= StopStepLevel){

EventLow = True;
ArrayTypeStep[index] = -1;
ArrayStepPrice[index] = low[index];
ArrayStepLast[index] = low[index];
}
//--------------------------------------------------------//     

// Creating and drawing the maximum extremum
if(high[index] >= TakeStepLevel){

EventHigh = True;
ArrayTypeStep[index] = 1;
ArrayStepPrice[index] = high[index];
ArrayStepLast[index] = high[index];
}
//--------------------------------------------------------//

// No events for forming extremes. Copying past data.
if(!EventHigh && !EventLow){

ArrayTypeStep[index] = ArrayTypeStep[index + 1];
ArrayStepLast[index] = ArrayStepLast[index + 1];
}
//--------------------------------------------------------//
      
return;
}
//+------------------------------------------------------------------+
//| Calculation Of Starting Extremes Buy                             |
//+------------------------------------------------------------------+
int CalcStartingExtremes_Buy(const int index, const double &high[], const double &low[]){

int init_index = 0;

for(int period = 2; period < index; period++){

int period_start = index - period;

int MaxBar = ArrayMaximum(high,period,period_start);
int MinBar = ArrayMinimum(low,period,period_start);

double MaximumLev = high[MaxBar]; 
double MinimumLev = low[MinBar];

double R_Step = MathAbs((MaximumLev - MinimumLev)/MinimumLev) * 100.0;

// formation of the maximum extremum
if(MaxBar != MinBar && MaxBar < MinBar && R_Step >= TAKE_STEP){

ArrayTypeStep[period_start] = 1;
ArrayStepPrice[MaxBar] = MaximumLev;
ArrayStepPrice[MinBar] = MinimumLev;
ArrayStepLast[period_start] = MaximumLev;
init_index = period_start;
}

if(init_index != 0){break;}
//--------------------------------------------------------//

// formation of a minimum extremum
if(MaxBar != MinBar && MinBar < MaxBar && R_Step >= STOP_STEP){

ArrayTypeStep[period_start] = -1;
ArrayStepPrice[MaxBar] = MaximumLev;
ArrayStepPrice[MinBar] = MinimumLev;
ArrayStepLast[period_start] = MinimumLev;
init_index = period_start;
}

if(init_index != 0){break;}
//--------------------------------------------------------//

}

return(init_index);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculation High Step Point Sell                                 |
//+------------------------------------------------------------------+
void HighStepPoint_Sell(const int index, const double &high[], const double &low[]){

double EventHigh = False; // High point Step update event
double EventLow = False; // Low point Step update event

// we will draw lines of expected future levels
double TakeStepDev = MathAbs( ((TAKE_STEP/100.0) * ArrayStepLast[index + 1]));
double StopStepDev = MathAbs( ((STOP_STEP/100.0) * ArrayStepLast[index + 1]));

double TakeStepLevel = NormalizeDouble(ArrayStepLast[index + 1] - TakeStepDev,Digits);
double StopStepLevel = NormalizeDouble(ArrayStepLast[index + 1] + StopStepDev,Digits);

// Updating and drawing the maximum extremum
if(high[index] >= StopStepLevel){

EventHigh = True;
ArrayTypeStep[index] = 1;
ArrayStepPrice[index] = high[index];
ArrayStepLast[index] = high[index];
}
//--------------------------------------------------------//

// Creating and drawing the minimum extremum
if(low[index] <= TakeStepLevel){

EventLow = True;
ArrayTypeStep[index] = -1;
ArrayStepPrice[index] = low[index];
ArrayStepLast[index] = low[index];
}
//--------------------------------------------------------//

// No events for forming extremes. Copying past data.
if(!EventHigh && !EventLow){

ArrayTypeStep[index] = ArrayTypeStep[index + 1];
ArrayStepLast[index] = ArrayStepLast[index + 1];
}
//--------------------------------------------------------//

return;
}
//+------------------------------------------------------------------+
//| Calculation Low Step Point Sell                                  |
//+------------------------------------------------------------------+
void LowStepPoint_Sell(const int index, const double &high[], const double &low[]){

double EventHigh = False; // Low point Step update event
double EventLow = False; // High point Step update event

// we will draw lines of expected future levels
double TakeStepDev = MathAbs( ((TAKE_STEP/100.0) * ArrayStepLast[index + 1]));
double StopStepDev = MathAbs( ((STOP_STEP/100.0) * ArrayStepLast[index + 1]));

double TakeStepLevel = NormalizeDouble(ArrayStepLast[index + 1] - TakeStepDev,Digits);
double StopStepLevel = NormalizeDouble(ArrayStepLast[index + 1] + StopStepDev,Digits);

// Updating and drawing the minimum extremum
if(low[index] <= TakeStepLevel){

EventLow = True;
ArrayTypeStep[index] = -1;
ArrayStepPrice[index] = low[index];
ArrayStepLast[index] = low[index];
}
//--------------------------------------------------------//     

// Creating and drawing the maximum extremum
if(high[index] >= StopStepLevel){

EventHigh = True;
ArrayTypeStep[index] = 1;
ArrayStepPrice[index] = high[index];
ArrayStepLast[index] = high[index];
}
//--------------------------------------------------------//

// No events for forming extremes. Copying past data.
if(!EventHigh && !EventLow){

ArrayTypeStep[index] = ArrayTypeStep[index + 1];
ArrayStepLast[index] = ArrayStepLast[index + 1];
}
//--------------------------------------------------------//
      
return;
}
//+------------------------------------------------------------------+
//| Calculation Of Starting Extremes Sell                            |
//+------------------------------------------------------------------+
int CalcStartingExtremes_Sell(const int index, const double &high[], const double &low[]){

int init_index = 0;

for(int period = 2; period < index; period++){

int period_start = index - period;

int MaxBar = ArrayMaximum(high,period,period_start);
int MinBar = ArrayMinimum(low,period,period_start);

double MaximumLev = high[MaxBar]; 
double MinimumLev = low[MinBar];

double R_Step = MathAbs((MaximumLev - MinimumLev)/MinimumLev) * 100.0;

// formation of the maximum extremum
if(MaxBar != MinBar && MaxBar < MinBar && R_Step >= STOP_STEP){

ArrayTypeStep[period_start] = 1;
ArrayStepPrice[MaxBar] = MaximumLev;
ArrayStepPrice[MinBar] = MinimumLev;
ArrayStepLast[period_start] = MaximumLev;
init_index = period_start;
}

if(init_index != 0){break;}
//--------------------------------------------------------//

// formation of a minimum extremum
if(MaxBar != MinBar && MinBar < MaxBar && R_Step >= TAKE_STEP){

ArrayTypeStep[period_start] = -1;
ArrayStepPrice[MaxBar] = MaximumLev;
ArrayStepPrice[MinBar] = MinimumLev;
ArrayStepLast[period_start] = MinimumLev;
init_index = period_start;
}

if(init_index != 0){break;}
//--------------------------------------------------------//

}

return(init_index);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// REPORT GENERATION                                                 |
//+------------------------------------------------------------------+
string GenerateTradeReport(
    const double& Prices[],          
    const datetime& Times[],         
    const int TotalBars,             
    const double TakeProfitPercent,  
    const double StopLossPercent,    
    const int TradeDirection         
)
{
    // --- ARRAYS INITIALIZATION ---
    ArrayResize(ResultsArray, 0);
    ArrayResize(SequenceArray, 0);

    // --- 1. SIMULATION ---
    
    int trade_id = -1; 
    
    for (int i = TotalBars - 1; i >= 0; i--) // i is the index of the old bar (the smaller i is, the newer it is)
    {
        // Checking whether the previous trade is closed (or this is the first iteration)
        if (trade_id == -1 || ResultsArray[trade_id].ResultType != 0) 
        {
            // Opening a new trade: Change the size and add
            int new_index = ArraySize(ResultsArray);
            ArrayResize(ResultsArray, new_index + 1);
            trade_id = new_index;
            
            ResultsArray[trade_id].OpenTime = Times[i];
            ResultsArray[trade_id].OpenPrice = Prices[i];
            ResultsArray[trade_id].ResultType = 0; // In process
            
            double target_tp, target_sl;
            
            if (TradeDirection == 1) // BUY
            {
                target_tp = Prices[i] * (1.0 + TakeProfitPercent / 100.0);
                target_sl = Prices[i] * (1.0 - StopLossPercent / 100.0);
            }
            else // SELL
            {
                target_tp = Prices[i] * (1.0 - TakeProfitPercent / 100.0);
                target_sl = Prices[i] * (1.0 + StopLossPercent / 100.0);
            }

            // Looking for a close on subsequent bars (j < i, i.e. j moves from i-1 to 0)
            for (int j = i - 1; j >= 0; j--) 
            {
                bool closed = false;
                
                if (TradeDirection == 1) // BUY
                {
                    if (Prices[j] >= target_tp)
                    {
                        ResultsArray[trade_id].ResultType = TYPE_TP;
                        ResultsArray[trade_id].ClosePrice = Prices[j];
                        ResultsArray[trade_id].CloseTime = Times[j];
                        ResultsArray[trade_id].ProfitPercent = TakeProfitPercent;
                        // TIME CALCULATION: CloseTime (Times[j]) - OpenTime (Times[i])
                        ResultsArray[trade_id].TimeHeldSeconds = (int)(Times[j] - Times[i]); 
                        closed = true;
                    }
                    else if (Prices[j] <= target_sl)
                    {
                        ResultsArray[trade_id].ResultType = TYPE_SL;
                        ResultsArray[trade_id].ClosePrice = Prices[j];
                        ResultsArray[trade_id].CloseTime = Times[j];
                        ResultsArray[trade_id].ProfitPercent = -StopLossPercent;
                        // TIME CALCULATION
                        ResultsArray[trade_id].TimeHeldSeconds = (int)(Times[j] - Times[i]); 
                        closed = true;
                    }
                }
                else // SELL
                {
                    if (Prices[j] <= target_tp)
                    {
                        ResultsArray[trade_id].ResultType = TYPE_TP;
                        ResultsArray[trade_id].ClosePrice = Prices[j];
                        ResultsArray[trade_id].CloseTime = Times[j];
                        ResultsArray[trade_id].ProfitPercent = TakeProfitPercent;
                        // TIME CALCULATION
                        ResultsArray[trade_id].TimeHeldSeconds = (int)(Times[j] - Times[i]);
                        closed = true;
                    }
                    else if (Prices[j] >= target_sl)
                    {
                        ResultsArray[trade_id].ResultType = TYPE_SL;
                        ResultsArray[trade_id].ClosePrice = Prices[j];
                        ResultsArray[trade_id].CloseTime = Times[j];
                        ResultsArray[trade_id].ProfitPercent = -StopLossPercent;
                        // TIME CALCULATION
                        ResultsArray[trade_id].TimeHeldSeconds = (int)(Times[j] - Times[i]);
                        closed = true;
                    }
                }
                
                if (closed) 
                {
                    // Adding the outcome to the sequence
                    int seq_idx = ArraySize(SequenceArray);
                    ArrayResize(SequenceArray, seq_idx + 1);
                    SequenceArray[seq_idx] = ResultsArray[trade_id].ResultType;
                    break; 
                }
            }
        }
    } 

    // --- 2. AGGREGATION ---
    
    int total_trades = ArraySize(ResultsArray);
    if (total_trades == 0) return "There is no data for analysis.";

    int wins = 0;
    double total_profit = 0.0;
    double total_loss = 0.0;
    
    HourlyStats hourly_data[]; 
    
    // Collecting statistics and time
    int total_time_tp = 0;
    int total_time_sl = 0;
    int trades_tp_count = 0;
    int trades_sl_count = 0;
    
    for (int i = 0; i < total_trades; i++)
    {
        if (ResultsArray[i].ResultType == TYPE_TP) 
        {
            wins++;
            total_profit += ResultsArray[i].ProfitPercent;
            total_time_tp += ResultsArray[i].TimeHeldSeconds;
            trades_tp_count++;
        }
        else if (ResultsArray[i].ResultType == TYPE_SL) 
        {
            total_loss += MathAbs(ResultsArray[i].ProfitPercent);
            total_time_sl += ResultsArray[i].TimeHeldSeconds;
            trades_sl_count++;
        }
        
        // Collecting data on opening hours
        int open_hour = TimeHour(ResultsArray[i].OpenTime);
        bool found = false;
        for (int h = 0; h < ArraySize(hourly_data); h++)
        {
            if (hourly_data[h].Hour == open_hour)
            {
                hourly_data[h].TotalTrades++;
                if (ResultsArray[i].ResultType == TYPE_TP) hourly_data[h].Wins++;
                found = true;
                break;
            }
        }
        if (!found)
        {
            HourlyStats temp_stat;
            temp_stat.Hour = open_hour;
            temp_stat.TotalTrades = 1;
            temp_stat.Wins = (ResultsArray[i].ResultType == TYPE_TP) ? 1 : 0;
            temp_stat.WinRate = 0.0; 
            
            int hr_idx = ArraySize(hourly_data);
            ArrayResize(hourly_data, hr_idx + 1);
            hourly_data[hr_idx] = temp_stat;
        }
    }
    
    // Final recalculation of WR and average time
    for (int h = 0; h < ArraySize(hourly_data); h++)
    {
        if (hourly_data[h].TotalTrades > 0)
        {
            hourly_data[h].WinRate = (double)hourly_data[h].Wins / hourly_data[h].TotalTrades * 100.0;
        }
    }

    // Final calculation of WR and EX
    double final_wr = (double)wins / total_trades * 100.0;
    double expectancy = (final_wr / 100.0 * TakeProfitPercent) - ((1.0 - final_wr / 100.0) * StopLossPercent);
    
    double avg_time_tp_h = (trades_tp_count > 0) ? (double)total_time_tp / trades_tp_count / 3600.0 : 0.0;
    double avg_time_sl_h = (trades_sl_count > 0) ? (double)total_time_sl / trades_sl_count / 3600.0 : 0.0;


    // --- 3. CREATING A REPORT IN THE FORM OF A TABLE ---
    string report = "==============================================================\n";
    report += StringFormat("TP/SL Scheme: %.1f%% / %.1f%%. Direction: %s", TakeProfitPercent, StopLossPercent, (TradeDirection==1?"BUY":"SELL"));
    report += StringFormat(" | Total simulated transactions: %d\n", total_trades);

    // --- Basic metrics ---
    report += StringFormat("Win Rate (WR): %.2f%%", final_wr);
    report += StringFormat(" | Mathematical Expectation (EX): %.4f %%\n", expectancy);
    
    // --- Time analysis ---
    report += StringFormat("Average time to TP: %.2f h. (%d trades)", avg_time_tp_h, trades_tp_count);
    report += StringFormat("| Average time to SL: %.2f h. (%d trades)\n\n", avg_time_sl_h, trades_sl_count);
    
    // --- Hourly analysis ---
    report += "--- OPENING HOURS STATISTICS (H1) ---\n";
    report += StringFormat("%-10s | %-10s | %-10s | %-10s\n","Hour","Transactions", "Winnings", "WR (%)");
    report += "------------------------------------------------------\n";
    for (int h = 0; h < ArraySize(hourly_data); h++)
    {
        report += StringFormat("%-10d | %-10d | %-10d | %-10.2f\n", 
                               hourly_data[h].Hour, 
                               hourly_data[h].TotalTrades, 
                               hourly_data[h].Wins, 
                               hourly_data[h].WinRate);
    }
    report += "\n";

    return report;
}
//+------------------------------------------------------------------+