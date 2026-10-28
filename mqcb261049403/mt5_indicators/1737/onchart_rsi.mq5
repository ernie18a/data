//+---------------------------------------------------------------------+
//|                                                     OnChart_RSI.mq5 | 
//|                                            Copyright © 2007, mladen | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, mladen"
#property link ""
#property description ""
//---- Indicator version
#property version   "1.00"
//---- The indicator is drawn in the main window
#property indicator_chart_window 
//---- 4 indicator buffers
#property indicator_buffers 4 
//---- 4 graphical constructions are used
#property indicator_plots   4
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- The indicator is drawn as a line
#property indicator_type1   DRAW_LINE
//---- MediumPurple is used for the color of the indicator line
#property indicator_color1 clrMediumPurple
//---- The indicator line is a dot-dash curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- The width of the indicator line is 1
#property indicator_width1  1
//---- The label of the indicator
#property indicator_label1  "Middle Ma Line"

//+-----------------------------------------+
//|  Parameters for the indicator levels    |
//+-----------------------------------------+
//---- The levels are drawn as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- Selecting colors for the levels
#property indicator_color2  clrMediumPurple
#property indicator_color3  clrMediumPurple
//---- Levels are dot-dash lines
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//---- The width of the level lines is 1
#property indicator_width2  1
#property indicator_width3  1
//---- Labels of the levels
#property indicator_label2  "Upper Ma Line"
#property indicator_label3  "Lower Ma Line"

//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- The indicator is drawn as a line
#property indicator_type4   DRAW_LINE
//---- Orange is used for the color of the indicator line
#property indicator_color4 clrOrange
//---- The indicator line is solid
#property indicator_style4  STYLE_SOLID
//---- The width of th indicator line is 2
#property indicator_width4  2
//---- The label of the indicator
#property indicator_label4  "Main RSI"

//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // A constant for returning an indicator recalculation command to the terminal
//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
//---- Parameters of RSI
input uint RSIPeriod=14;
input ENUM_APPLIED_PRICE RSIPrice=PRICE_CLOSE;

//---- Parameters of the moving average
input uint   MAPeriod=20;
input  ENUM_MA_METHOD   MAType=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;

input uint overBought=80;
input uint overSold=20;
//+-----------------------------------+

//---- Declaring dynamic arrays that will be further used as indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];

//---- Declaring integer variables of the start of data calculation
int min_rates_total;
//---- Declaring integer variables for the indicator handles
int MA_Handle,ATR_Handle,RSI_Handle;
//+------------------------------------------------------------------+   
//| OnChart_RSI indicator initialization function                    | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax( RSIPrice,MAPeriod));

//---- Getting the handle of the iMA indicator
   MA_Handle=iMA(NULL,0,MAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the iMA indicator");
//---- Getting the handle of the iRSI indicator
   RSI_Handle=iRSI(NULL,0,RSIPeriod,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the iRSI indicator");
//---- Getting the handle of iATR
   ATR_Handle=iATR(NULL,0,MAPeriod);
   if(ATR_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the iATR indicator");

//----   
   Init(0,min_rates_total,0,ExtLineBuffer1);
   Init(1,min_rates_total,0,ExtLineBuffer2);
   Init(2,min_rates_total,0,ExtLineBuffer3);
   Init(3,min_rates_total,0,ExtLineBuffer4);

//---- Creating a name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"OnChart_RSI");

//---- Set accuracy of displaying for the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+   
//| OnChart_RSI indicator initialization function                    | 
//+------------------------------------------------------------------+ 
void Init(uint Number,uint Draw_Begin,long Empty_Value,double &IndArray[])
  {
//---- Set a dynamic array as an indicator buffer
   SetIndexBuffer(Number,IndArray,INDICATOR_DATA);
//---- Shift the beginning of indicator drawing
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- Set the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndArray,true);
//----
  }
//+------------------------------------------------------------------+ 
//| OnChart_RSI iteration function                                   | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- Checking if the number of bars is enough for the calculation
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double MA[],RSI[],ATR[];

//---- Calculations of the necessary number of copied data
//and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-2; // Starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle,MAIN_LINE,0,to_copy,RSI)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(RSI,true);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtLineBuffer1[bar]=MA[bar];
      ExtLineBuffer2[bar]=MA[bar]+(ATR[bar]*(overBought-50)/100);
      ExtLineBuffer3[bar]=MA[bar]-(ATR[bar]*(50-overSold)/100);
      ExtLineBuffer4[bar]=MA[bar]+(RSI[bar]-50)/100*ATR[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
