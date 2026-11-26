//+------------------------------------------------------------------+
//|                                                      ATRNorm.mq5 |
//|                                  Copyright © 2012, Ivan Kornilov |
//|                                  excelf@gmail.com, skype: excelf |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2012, Ivan Kornilov"
//---- author of the indicator
#property link      "excelf@gmail.com"
//---- Indicator Version Number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for calculation and drawing of the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Sinewave indicator drawing parameters       |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used for the indicator bullish line
#property indicator_color1  Red
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- bullish indicator label display
#property indicator_label1  "ATRNorm"
//+----------------------------------------------+
//|  LeadSinewave indicator drawing parameters   |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator bearish line
#property indicator_color2  Blue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- bearish indicator label display
#property indicator_label2  "LeadATRNorm"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 0.25
#property indicator_level1 0.50
#property indicator_level1 0.75
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Indicator window parameters                  |
//+----------------------------------------------+
//#property indicator_minimum -1
//#property indicator_maximum 1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
enum IndType
  {
   ATR=0,          // ATR
   Volume_,        // Volume
   TrueRange,      // TrueRange
   TrueRangeVolume,// TrueRange Volume
   Log,            // Log
   stdDev          // stdDev
  };
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint period=12;                              // Indicator period
input uint ma=12;                                  // Smoothing period
input IndType ValueType=ATR;                       // Normalized indicator type
input uint normLimit=24;                           // Normalizing period
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Volume
input int Shift=0;                                 // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- Declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double AtrBuffer[];
double FlatBuffer[];
//---- Declaration of variables for the indicators handles
int Handle;
//---- Declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- Declaration of dynamic arrays that further 
//---- will be used as ring buffers
int Count[];
double SMABuffer[];
//+------------------------------------------------------------------+
//|  Recalculation of position of a newest element in the array      |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos
(
 int &CoArr[],// Return the current value of the price series by the link
 int Size
 )
// Recount_ArrayZeroPos(count, DcPeriod)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(period+ma+1,normLimit));

//---- getting handle of the iBearsPower indicator
   if(ValueType==ATR)
     {
      Handle=iATR(NULL,0,int(period));
      if(Handle==INVALID_HANDLE) Print(" Failed to get handle of the indicator!");
     }

   if(ValueType==stdDev)
     {
      Handle=iStdDev(NULL,0,int(period),0,MODE_SMA,PRICE_CLOSE);
      if(Handle==INVALID_HANDLE) Print(" Failed to get handle of the indicator!");
     }

//---- Memory distribution for variables' arrays  
   ArrayResize(Count,normLimit);
   ArrayResize(SMABuffer,normLimit);
   ArrayInitialize(Count,0.0);
   ArrayInitialize(SMABuffer,0.0);

//---- set AtrBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,AtrBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- set FlatBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,FlatBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"ATRNorm(",period,",",ma,",",normLimit," ",EnumToString(ValueType),")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
   if(ValueType==ATR || ValueType==stdDev)if(BarsCalculated(Handle)<rates_total) return(RESET);

//---- declarations of local variables 
   int first,bar;
   double val;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=1;                                           // starting index for calculation of all bars
   else first=prev_calculated-1;                         // starting index for calculation of new bars

//---- main loop of the indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      val=getValue(ValueType,rates_total-1,high,low,close,tick_volume,volume,bar);

      if(ValueType!=ATR || ValueType!=stdDev)
         SMABuffer[Count[0]]=XMA1.XMASeries(period+1,prev_calculated,rates_total,MODE_SMA_,0,period,val,bar,false);
      else SMABuffer[Count[0]]=val;

      AtrBuffer[bar]=normValue(SMABuffer,normLimit,Count[0]);
      if(AtrBuffer[bar]==EMPTY_VALUE) return(RESET);

      FlatBuffer[bar]=XMA2.XMASeries(period+1+period+normLimit,prev_calculated,rates_total,MODE_SMA_,0,ma,AtrBuffer[bar],bar,false);
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,normLimit);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+    
//| normValue()                                                      | 
//+------------------------------------------------------------------+
double normValue(double &buffer[],int count,int i)
  {
//----
   double max = buffer[ArrayMaximum(buffer,0,WHOLE_ARRAY)]; 
   double min = buffer[ArrayMinimum(buffer,0,WHOLE_ARRAY)];
   double value;

   if(max-min == 0) value = 1;
   else value =(buffer[i] - min) /(max - min);

   if(value>1) value=1;
   else if(value<0) value=0;
//----
   return(value);
  }

double getValue(IndType valueType,int MaxBar,const double &High[],const double &Low[],
                const double &Close[],const long &TcVolume[],const long &Volume[],int shift)
  {
//----
   double Arr[1],value=0;

   switch(valueType)
     {
      case ATR:
         //---- copy newly appeared data in the array  
         if(CopyBuffer(Handle,0,MaxBar-shift,1,Arr)<=0) return(EMPTY_VALUE);
         return(Arr[0]);
      case Volume_:
        {
         long vol;
         if(VolumeType==VOLUME_TICK) vol=TcVolume[shift];
         else                        vol=Volume[shift];
         return(double(vol));
        }

      case TrueRange:
         if(shift==1) value=High[shift]-Low[shift];
         else value=MathMax(High[shift],High[shift-1])-MathMin(Low[shift],Low[shift-1]);
         return(value);

      case TrueRangeVolume:
        {
         if(shift==1) value=High[shift]-Low[shift];
         else value=MathMax(High[shift],Close[shift-1])-MathMin(Low[shift],Close[shift-1]);
         long vol;
         if(VolumeType==VOLUME_TICK) vol=TcVolume[shift];
         else                        vol=Volume[shift];
         return(value/_Point*vol);
        }

      case Log:
         if(Close[shift-1]==0) value=0;
         else value=MathLog(MathMax(Close[shift-1],Close[shift])/MathMin(Close[shift-1],Close[shift]));
         return(value);
         
      case stdDev:
         //---- copy newly appeared data in the array  
         if(CopyBuffer(Handle,0,MaxBar-shift,1,Arr)<=0) return(EMPTY_VALUE);
         return(Arr[0]);
      default: return(0);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
