#property copyright "Evgeniy Chumakov | © Copyright 2024"
#property description "The indicator draws the nearest levels of the specified range."
#property version "1.0"
#property link "https://www.mql5.com/en/users/jack857752"
#property strict

#property indicator_chart_window

//------------------------
enum units_of_calculation
{
Points = 0,  // Points
Percent = 1  // Percent
};

input units_of_calculation type_calc = 0; // Units of Calculation
//------------------------

input double InputRange = 500; // Specified Range
input color InputColor = clrYellow; // Color Levels

string MaxStr = "Range Max" + "\n"; // Max Level label when hovering over it
string MinStr = "Range Min" + "\n"; // Min Level label when hovering over it

double Level_Max = 0; // Level Value Max
double Level_Min = 0; // Level Value Min

//+------------------------------------------------------------------+
int OnInit(){

IndicatorSetString(INDICATOR_SHORTNAME,"Range Levels");

// Let's sign the levels completely
string type_calc_str = "";

if(type_calc == 0){type_calc_str = " Points";}
if(type_calc == 1){type_calc_str = " Percent";}

MaxStr = MaxStr + DoubleToStr(InputRange,2) + type_calc_str;
MinStr = MinStr + DoubleToStr(InputRange,2) + type_calc_str;
//-----------------------------------------------------------//

// Let's reset the level values
Level_Max = 0;
Level_Min = 0;
//-----------------------------------------------------------//
    
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnDeinit(const int reason){

// Remove levels from the chart when deinitializing the indicator 
ObjectDelete(MaxStr);
ObjectDelete(MinStr);
//-----------------------------------------------------------//
   
return;
}
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

// Let's check if the current Maximum and Minimum levels have gone beyond a certain range. 
// If so, we'll reset the level values.

if( (Level_Max != 0 || Level_Min != 0) && (high[0] > Level_Max || low[0] < Level_Min)){Level_Max = 0; Level_Min = 0;}

//-----------------------------------------------------------//
   
// Let's find the levels of the specified range.
// First, let's check if there are levels, so as not to overload the system. 
// If there aren't any, then we'll search for levels.
if(Level_Max == 0 || Level_Min == 0){

int depth = iBars(Symbol(),PERIOD_CURRENT); // Scanning depth
bool RangeFound = False; // Event trigger / Range defined

for(int period = 1; period < depth; period++){

double Max = iHigh(Symbol(),PERIOD_CURRENT,iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,period,0)); // Maximum on interval
double Min = iLow(Symbol(),PERIOD_CURRENT,iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,period,0)); // Minimum on interval

double point_value = MathAbs(Max - Min)/Point(); // The range between levels in points.
double percentage_value = ((Max - Min)/Min) * 100.0; // The range between levels in percent.

if(type_calc == 0 && point_value >= InputRange){RangeFound = True; Level_Max = Max; Level_Min = Min; break;}
if(type_calc == 1 && percentage_value >= InputRange){RangeFound = True; Level_Max = Max; Level_Min = Min; break;}
if(period > depth - 2 && RangeFound == False){return(rates_total);} // There is not enough history to determine the specified range.
}
//-----------------------------------------------------------//
   
// Let's display the levels on the chart
string LevMax_Name = MaxStr;

bool LevMax_Line = ObjectCreate(ChartID(),LevMax_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),LevMax_Name,OBJPROP_COLOR,InputColor);
ObjectSetInteger(ChartID(),LevMax_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),LevMax_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),LevMax_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),LevMax_Name,OBJPROP_PRICE1,Level_Max);

string LevMin_Name = MinStr;

bool LevMin_Line = ObjectCreate(ChartID(),LevMin_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),LevMin_Name,OBJPROP_COLOR,InputColor);
ObjectSetInteger(ChartID(),LevMin_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),LevMin_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),LevMin_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),LevMin_Name,OBJPROP_PRICE1,Level_Min);
}
//-----------------------------------------------------------//
   
return(rates_total);
}
//+------------------------------------------------------------------+