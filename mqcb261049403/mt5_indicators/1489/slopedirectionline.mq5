//+---------------------------------------------------------------------+ 
//|                                              SlopeDirectionLine.mq5 | 
//|                                        Copyright © 2006, WizardSerg | 
//|                                                  wizardserg@mail.ru | 
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, WizardSerg"
#property link "wizardserg@mail.ru"
//--- indicator version number
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers
#property indicator_buffers 2 
//--- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//--- drawing the indicator as a multicolored line
#property indicator_type1   DRAW_COLOR_LINE
//--- colors of the three-color line are
#property indicator_color1  clrDeepPink,clrGray,clrDarkViolet
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- Indicator line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "SlopeDirectionLine"

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_LWMA; // First smoothing method
input uint Length1=12;                    // First smoothing depth                
input int Phase1=15;                      // First smoothing parameter
//--- Phase1: for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
//--- Phase1: for VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Smooth_Method MA_Method2=MODE_SMA;  // Second smoothing averaging method
input int Phase2=15;                      // Second smoothing parameter
//---Phase2: for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
//---Phase2: for VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_CLOSE;     // Price constant
input int Shift=0;                        // Horizontal shift of the indicator in bars
input int PriceShift=0;                   // Vertical shift of the indicator in pointsх
input bool On_Push = false;                           // Allow to send push-messages
input bool On_Email = false;                          // Allow to send e-mail messages
input bool On_Alert = true;                           // Allow to put alert
input bool On_Play_Sound = false;                     // Allow to put sound signal
input string NameFileSound = "expert.wav";            // Name of the file with sound
input string  CommentSirName="SlopeDirectionLine: ";  // The first part of the allert comment
input uint SignalBar=1;                               // Bar index for getting an entry signal
//+-----------------------------------+
//--- declaration of dynamic arrays that will further be used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//--- declaration of variables for the averaging periods values
int LengthX,LengthR;
//--- declaration of the average vertical shift value variable
double dPriceShift;
//--- declaration of integer variables of data starting point
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+   
//| SlopeDirectionLine indicator initialization function             | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   LengthX=int(Length1/2);
   LengthR=int(MathMax(MathSqrt(Length1),1));
   min_rates_=+XMA1.GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_total=min_rates_+XMA1.GetStartBars(MA_Method2,LengthR,Phase2);
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- Create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"IndBuffer");
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- initializations of variable for indicator short name
   string shortname;
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"SlopeDirectionLine(",Length1,", ",LengthR,", ",Smooth2,")");
//--- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- end of initialization
  }
//+------------------------------------------------------------------+ 
//| SlopeDirectionLine iteration function                            | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);
//--- declaration of variables with a floating point  
   double price,line,xline;
//--- declaration of integer variables and getting the bars already calculated
   int first,bar,clr;
//--- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=0; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars
//--- main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);

      line=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price,bar,false);
      line=2*XMA2.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,LengthX,price,bar,false)-line;
      xline=XMA3.XMASeries(min_rates_,prev_calculated,rates_total,MA_Method2,Phase2,LengthR,line,bar,false);
      //---       
      IndBuffer[bar]=xline+dPriceShift;
     }
//--- correction of the first variable value
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=min_rates_total-1; // starting index for calculation of all bars
//--- main loop of the signal line coloring
   for(bar=first; bar<rates_total; bar++)
     {
      clr=1;
      ColorIndBuffer[bar]=1;
      if(IndBuffer[bar-1]<IndBuffer[bar]) clr=2;
      if(IndBuffer[bar-1]>IndBuffer[bar]) clr=0;
      ColorIndBuffer[bar]=clr;

      if(bar==rates_total-1-SignalBar)
        {
         if(ColorIndBuffer[bar-1]!=2 && clr==2)
           {
            datetime SignalTime=TimeCurrent();
            if(On_Play_Sound) PlaySound(NameFileSound);
            string period=GetStringTimeframe(Period());
            string comment,sTime=" CurrTime="+TimeToString(SignalTime,TIME_MINUTES);
            StringConcatenate(comment,CommentSirName,Symbol(),period," ",sTime," Buy signal!");
            if(On_Alert) Alert(comment);
            if(On_Push) SendNotification(comment);
            if(On_Email) SendMail(CommentSirName+Symbol()+period,comment);
           }
           
         if(ColorIndBuffer[bar-1]!=0 && clr==0)
           {
            datetime SignalTime=TimeCurrent();
            if(On_Play_Sound) PlaySound(NameFileSound);
            string period=GetStringTimeframe(Period());
            string comment,sTime=" CurrTime="+TimeToString(SignalTime,TIME_MINUTES);
            StringConcatenate(comment,CommentSirName,Symbol(),period," ",sTime," Sell signal!");
            if(On_Alert) Alert(comment);
            if(On_Push) SendNotification(comment);
            if(On_Email) SendMail(CommentSirName+Symbol()+period,comment);
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
