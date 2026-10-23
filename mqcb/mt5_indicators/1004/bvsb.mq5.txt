#property description "Bears vs Bulls"
#property   copyright "Copyright © 2012, VladMsk"
#property   link      "vlad@rosfi.ru"
#property version   "1.4"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Bears"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Bulls"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input int                  MAPeriod = 14; //MA Period 
input ENUM_MA_METHOD       MAMethod = MODE_SMMA;   // MA Method
input ENUM_APPLIED_PRICE   AppliedPrice = PRICE_CLOSE; //Applied Price
input int                  NeedBars = 4096;

double         Bears[], Bulls[];
int   PlotDrawBegin = 0;

int OnInit()   {
SetIndexBuffer(0,Bears,INDICATOR_DATA);
SetIndexBuffer(1,Bulls,INDICATOR_DATA);
IndicatorSetString(INDICATOR_SHORTNAME,"BvsB(" + IntegerToString(MAPeriod) + ")");
if(!ArraySetAsSeries(Bears, false) ||
   !ArraySetAsSeries(Bulls, false)) {
   Print("ArraySetAsSeries for Main Calcutions, Error ",GetLastError());
         return(-1);  }
IndicatorSetInteger(INDICATOR_DIGITS,0);
return(0);  }

int   hMA = INVALID_HANDLE;

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])   {

if(!ArraySetAsSeries(low, false) ||
   !ArraySetAsSeries(high, false)) {
   Print("ArraySetAsSeries for low[] or high[], Error ",GetLastError());
         return(0);  }
         
if(hMA == INVALID_HANDLE)  {
   hMA = iMA(
   _Symbol,            // the name of the symbol
   _Period,            // period
   MAPeriod,         // period of averaging
   0,          // horizontal shift of the indicator
   MAMethod,         // type of smoothing
   AppliedPrice      // type of price or handle
   );
   if(hMA == INVALID_HANDLE)  {
      Print("No MA! Error # ", GetLastError());
      return(0);  }  }

int   i, limit;

if((prev_calculated > rates_total || prev_calculated <= 0))   { // Firs Calc
   int   begin = MAPeriod + 1;
   PlotDrawBegin = begin;
   if(PlotDrawBegin < rates_total - NeedBars)
      PlotDrawBegin = rates_total - NeedBars;
   if(PlotDrawBegin <= 0 || PlotDrawBegin >= rates_total)  {
      Print("No DATA!");
      return(0);  }
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,PlotDrawBegin);
   int   nbegin = PlotDrawBegin - begin;
   if(nbegin > begin)   begin = nbegin;
   limit = begin;
   }
else limit = prev_calculated - 1;

for(i = limit;i < rates_total;i++) {
      if(IsStopped())   return(0);
      double   MA[1] = {0.0};
      if(CopyBuffer(hMA, 0, rates_total - i, 1, MA) < 1) return(i - 1);
      double   tMA = MA[0];
      Bears[i] = (tMA - low[i])/_Point;
      Bulls[i] = (high[i] -tMA)/_Point;
      }

return(rates_total);
}

