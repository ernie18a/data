#property   copyright "BECEMAL"
#property   link      "http://www.becemal.ru/"
// Use Code by Witold Wozniak, www.mqlsoft.com

#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Magenta
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label1  "TPBF"

input int MAPeriod = 24; // period of MA
input int MAShift = 0;   // Horizontal shift of the average in bars 

double BF[];
static   double B1, B2, B3, B4;

bool  TPBF(double InPeriod, double &R1, double &R2, double &R3, double &R4)  {
double   CutOffPeriod = InPeriod;
if(CutOffPeriod < 4.0)   CutOffPeriod = 4.0;
double a1 = MathExp( -1.0 * M_PI / CutOffPeriod);
double b1 = 2.0 * a1 * MathCos(M_PI * MathSqrt(3.0) / CutOffPeriod);
double c1 = a1 * a1;
R2 = b1 + c1;
R3 = -(c1 + b1 * c1);
R4 = c1 * c1;
R1 = 1.0 - R2 - R3 - R4;
return(true);  }

void OnInit()  {
SetIndexBuffer(0,BF,INDICATOR_DATA);
PlotIndexSetInteger(0,PLOT_SHIFT,MAShift);
//---- set the position, from which the indicator drawing starts
PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MAPeriod);
//---- initializations of variable for indicator short name
string shortname;
   StringConcatenate(shortname,"TPBF(", MAPeriod,", ", MAShift,")");
//--- create label to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creating name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- set accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits + 1);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
TPBF((double)MAPeriod, B1, B2, B3, B4);
}

int OnCalculate(const int rates_total,     // number of bars in history at the current tick
                const int prev_calculated, // number of bars in history at the previous tick
                const int begin,           // bars reliable counting beginning index
                const double &price[]      // price array for calculation of the indicator
                ) {
int i,limit;
if(prev_calculated==0)  {
   limit = MAPeriod + begin - 1;
   double   t = price[limit+1];
   for(i = 0;i < limit;i++) BF[i]=t;
   double firstValue=0;
   limit++;
   for(i=begin;i<limit;i++)   firstValue += price[i];
   firstValue /= MAPeriod;
   BF[limit-1]=firstValue;
   BF[limit-2]=firstValue;
   BF[limit-3]=firstValue; }
else limit=prev_calculated-1;
for(i=limit;i<rates_total && !IsStopped();i++)
   BF[i] = B1 * price[i] + B2 * BF[i - 1] + B3 * BF[i - 2] + B4 * BF[i - 3];
if(IsStopped())   return(0);
return(rates_total);
}

