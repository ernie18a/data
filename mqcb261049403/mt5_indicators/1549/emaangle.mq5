//+------------------------------------------------------------------+
//|                                                     EMAAngle.mq5 |
//|                                         Copyright © 2008, jpkfox |
//|                                                                  |
//| You can use this indicator to measure when the EMA angle is      |
//| "near zero". AngleTreshold determines when the angle for the     |
//| EMA is "about zero": This is when the value is between           |
//| [-AngleTreshold, AngleTreshold] (or when the histogram is red).  |
//|   EMAPeriod: EMA period                                          |
//|   AngleTreshold: The angle value is "about zero" when it is      |
//|     between the values [-AngleTreshold, AngleTreshold].          |      
//|   StartEMAShift: The starting point to calculate the             |   
//|     angle. This is a shift value to the left from the            |
//|     observation point. Should be StartEMAShift > EndEMAShift.    | 
//|   StartEMAShift: The ending point to calculate the               |
//|     angle. This is a shift value to the left from the            | 
//|     observation point. Should be StartEMAShift > EndEMAShift.    |
//|                                                                  |
//|   Modified by MrPip                                              |
//|       Red for down                                               |
//|       Yellow for near zero                                       |
//|       Green for up                                               |
//|  10/15/05  MrPip                                                 |
//|            Corrected problem with USDJPY and optimized code      |   
//|                                                                  |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2008, jpkfox"
#property  link      "http://www.strategybuilderfx.com/forums/showthread.php?t=15274&page=1&pp=8"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the five-color histogram are as follows
#property indicator_color1 clrMagenta,clrPurple,clrGray,clrTeal,clrChartreuse
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1  "EMAAngle"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0       // The constant for getting the command for the indicator recalculation back to the terminal
#define PI     3.14159 // Pi character value
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint EMAPeriod=34;
input  ENUM_MA_METHOD   MAType=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;
input double AngleTreshold=3.0;
input uint StartEMAShift=6;
input uint EndEMAShift=0;
//+-----------------------------------+

//---- Declaration of integer variables of data starting point
int  min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//---- Declaration of integer variables for the indicator handles
int MA_Handle;
double dFactor,mFactor;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   if(StartEMAShift<=EndEMAShift)
     {
      Print("Invalid values of the StartEMAShift and EndEMAShift input parameters!!!");
      return;
     }
   min_rates_total=int(EMAPeriod +MathMax(StartEMAShift,EndEMAShift));
   
//---- getting the iMA indicator handle
   MA_Handle=iMA(NULL,0,EMAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");
//----  
   dFactor=3.14159/180.0;
   mFactor=10000.0;
   if (Symbol()=="USDJPY") mFactor=100.0;
   double ShiftDif=StartEMAShift-EndEMAShift;
   mFactor/=ShiftDif;
   
//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorIndBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"EMAAngle("+string(EMAPeriod)+")");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
    
//---- the number of the indicator 2 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,2);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+AngleTreshold);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-AngleTreshold);
//---- magenta and blue colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrBlue);
//---- short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(MA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
      
//---- declaration of local variables 
   int to_copy,limit,bar,clr;
   double fEndMA,fStartMA,fAngle,MA[];

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
        limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for calculation of new bars only

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);  
   ArraySetAsSeries(MA,true); 
   
   to_copy=limit+min_rates_total+1;
   
//---- copy newly appeared data into the arrays
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
   
//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      fEndMA=MA[bar+EndEMAShift];
      fStartMA=MA[bar+StartEMAShift];
      //---- 10000.0 : Multiply by 10000 so that the fAngle is not too small
      //---- for the indicator Window.
      fAngle=mFactor*(fEndMA-fStartMA);
      //---- fAngle = MathArctan(fAngle)/dFactor;
      IndBuffer[bar]=fAngle;
//----
      clr=2;

      if(fAngle>0)
        {
         if(fAngle>+AngleTreshold) clr=4;
         else clr=3;
        }
        
      if(fAngle<0)
        {
         if(fAngle<-AngleTreshold) clr=0;
         else clr=1;
        }
        
      ColorIndBuffer[bar]=clr;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
