#property copyright "Evgeniy Chumakov | © Copyright 2024"
#property description "Candle range forecast based on statistics."
#property version "1.0"
#property link "https://www.mql5.com/en/users/jack857752"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_label1 "Current Range (%)"
#property indicator_label2 "Forecast Range (%)"

input int InpPeriod = 120; // Averaging Period
input int InpStatPeriod = 5760; // Number Of Bars For Statistics
input int InpShift = 24;// Shifting Start Of Statistics Calculation

input int InpHistogramSize = 2; // Histogram Size
input int InpLineSize = 1; // Line Size

input color InpHistogramColor = clrSlateGray; // Histogram Color
input color InpLineColor = clrYellow; // Line Color

double ActualBuffer[]; // Current Value Buffer
double StatisticBuffer[]; // Forecast Value Buffer

double ARRAY_STAT[]; // Array of statistical data

//+------------------------------------------------------------------+
int OnInit(){

IndicatorSetString(INDICATOR_SHORTNAME,"Range_Forecast_H1");

SetIndexBuffer(0,ActualBuffer,INDICATOR_DATA);
SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,InpHistogramSize,InpHistogramColor);
   
SetIndexBuffer(1,StatisticBuffer,INDICATOR_DATA);
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,InpLineSize,InpLineColor);

// Checking The Necessary Conditions For The Indicator To Work
if(iBars(Symbol(),PERIOD_H1) < (InpPeriod + InpStatPeriod + InpShift)){Comment("Not enough data! Load symbol history!"); return(1);}else{Comment("");}
if(Period() != 60){Comment("The indicator is designed to work only on the hourly period!"); return(1);}else{Comment("");}
//-------------------------------------------------------------------/

// Checking Statistics Data
ArrayResize(ARRAY_STAT,24,0);
ArrayInitialize(ARRAY_STAT,0);

fStatisticsCalculation();
//-------------------------------------------------------------------/

return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Start Calculate                                                  |
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

int total = rates_total - InpPeriod - 2;
int limit = rates_total - IndicatorCounted();

if(limit > 1){limit = total;}

// Calculating The Indicator
for(int i = limit; i >= 0 && !IsStopped(); i--){

// Calculating Average Percentage Range
double Average_Percentage_Range = 0;

for(int y = i; y < (i + InpPeriod); y++){

Average_Percentage_Range += fRangeP(y + 1); // we take data from the previous bar
}

Average_Percentage_Range = Average_Percentage_Range/(double)InpPeriod;
//-------------------------------------------------------------------/

int Time_H = TimeHour(iTime(Symbol(),PERIOD_H1,i)); // candle hour

StatisticBuffer[i] = (ARRAY_STAT[Time_H] * Average_Percentage_Range ) + Average_Percentage_Range; // Calculation of the forecast range based on statistics
ActualBuffer[i] = fRangeP(i); // Current range

} // i end

return(rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Statistics Calculation Function                                  |
//+------------------------------------------------------------------+
void fStatisticsCalculation(){

int ARRAY_N[]; 
ArrayResize(ARRAY_N,24,0);
ArrayInitialize(ARRAY_N,0);


for(int i = InpShift; i < (InpShift + InpStatPeriod); i++){

// Calculating Average Percentage Range
double Average_Percentage_Range = 0;

for(int y = i; y < (i + InpPeriod); y++){

Average_Percentage_Range += fRangeP(y + 1); // we take data from the previous bar
}

Average_Percentage_Range = Average_Percentage_Range/(double)InpPeriod;
//-------------------------------------------------------------------/

double Current_Range = fRangeP(i); // current range
double Relative = (Current_Range - Average_Percentage_Range)/Average_Percentage_Range; // relative indicator of the current range to the average

int Time_H = TimeHour(iTime(Symbol(),PERIOD_H1,i)); // candle hour

// Write the result to the statistics array
for(int t = 0; t < 24; t++){

if(Time_H == t){ArrayFill(ARRAY_STAT,t,1,ARRAY_STAT[t] + Relative); ArrayFill(ARRAY_N,t,1,ARRAY_N[t] + 1);}
}
//-------------------------------------------------------------------/

} 

// Processing Of Received Data
for(int offset = 0; offset < 24; offset++){

if(ARRAY_N[offset] != 0){ ArrayFill(ARRAY_STAT,offset,1,ARRAY_STAT[offset]/(double)ARRAY_N[offset]); }
}

return;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Range Percentage Function                                        |
//+------------------------------------------------------------------+
double fRangeP(int pos){

double Rp = ((iHigh(Symbol(),PERIOD_H1,pos) - iLow(Symbol(),PERIOD_H1,pos))/iLow(Symbol(),PERIOD_H1,pos)) * 100.0;

return(Rp);
}
//+------------------------------------------------------------------+