//+------------------------------------------------------------------+
//|                                         Bollinger_Squeeze_v9.mq5 |
//|                                      Original code by Nick Bilak |
//|                                         Modifications by Akuma99 |
//|                                                                  |
//|            For help on this indicator, tutorials and information | 
//|            visit http://www.beginnertrader.com                   |
//|                                                                  |
//|   Trigger types: 1-stochastic, 2-cci, 3-rsi, 4-macd, 5-momentum  |
//|                                                                  |
//|                                        Copyright © 2006  Akuma99 |
//|                                    http://www.beginnertrader.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Akuma99"
#property link      "http://www.beginnertrader.com "
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 3
#property indicator_buffers 3
//---- two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrRed,clrOrchid,clrGray,clrDodgerBlue,clrLime
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 4
#property indicator_width1 4
//---- displaying the indicator label
#property indicator_label1 "Bollinger_Squeeze_v9 HISTOGRAM"

//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- color is used for the color of the indicator line
#property indicator_color2 clrBlueViolet
//---- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//---- indicator line width is 1
#property indicator_width2 1
//---- displaying the indicator label
#property indicator_label2 "Bollinger_Squeeze_v9 LINE"
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Mode //Type of constant
  {
   ENAME_STOCHASTIC = 1,     //stochastic
   ENAME_CCI,                //cci
   ENAME_RSI,                //rsi
   ENAME_MACD,               //macd
   ENAME_MOMENTUM            //momentum
  };
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Mode triggerType=ENAME_MACD;
input uint stochPeriod_trigger1=14;
input uint cciPeriod_trigger2=50;
input uint rsiPeriod_trigger3=10;
input uint macd_fastEMA_trigger4=5;
input uint macd_slowEMA_trigger4=13;
input uint macd_macdEMA_trigger4=1;
input uint momentumPeriod_trigger5=14;
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that 
// will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[],LineBuffer[];
//---- declaration of variables
int       bolPrd=20;
double    bolDev=2.0;
int       keltPrd=20;
double    keltFactor=1.5;
//---- Declaration of integer variables for the indicator handles
int Ind_Handle,ATR_Handle,Std_Handle;
//+------------------------------------------------------------------+    
//| Bollinger_Squeeze_v9 indicator initialization function           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   switch(triggerType)
     {
      case 1: min_rates_total=int(stochPeriod_trigger1+3+3); break;
      case 2: min_rates_total=int(cciPeriod_trigger2); break;
      case 3: min_rates_total=int(rsiPeriod_trigger3); break;
      case 4: min_rates_total=int(5+13+1); break;
      case 5: min_rates_total=int(momentumPeriod_trigger5); break;
     }
   min_rates_total=MathMax(MathMax(min_rates_total,bolPrd),keltPrd);

//---- getting the indicator handle
   switch(triggerType)
     {
      case 1: Ind_Handle=iStochastic(NULL,0,stochPeriod_trigger1,3,3,MODE_SMA,STO_CLOSECLOSE); break;
      case 2: Ind_Handle=iCCI(NULL,0,cciPeriod_trigger2,PRICE_CLOSE); break;
      case 3: Ind_Handle=iRSI(NULL,0,rsiPeriod_trigger3,PRICE_CLOSE); break;
      case 4: Ind_Handle=iMACD(NULL,0,5,13,1,PRICE_CLOSE); break;
      case 5: Ind_Handle=iMomentum(NULL,0,momentumPeriod_trigger5,PRICE_CLOSE); break;
     }
   if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get the indicator handle!");

   ATR_Handle=iATR(NULL,0,keltPrd);
   if(ATR_Handle==INVALID_HANDLE) Print(" Failed to get the indicator handle!");

   Std_Handle=iStdDev(NULL,0,bolPrd,0,MODE_SMA,PRICE_CLOSE);
   if(Std_Handle==INVALID_HANDLE) Print(" Failed to get the indicator handle!");

//---- Setting levels   
   switch(triggerType)
     {
      case 1:
         //---- the number of the indicator horizontal levels   
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         //---- Values of the indicator horizontal levels   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+30);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-30);
         //---- gray and magenta colors are used for horizontal levels lines  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         //---- Short dot-dash is used for the horizontal level line  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         break;
      case 2:
         //---- the number of the indicator horizontal levels   
         IndicatorSetInteger(INDICATOR_LEVELS,4);
         //---- Values of the indicator horizontal levels   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+200);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,+100);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-100);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-200);
         //---- gray and magenta colors are used for horizontal levels lines  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
         //---- Short dot-dash is used for the horizontal level line  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
         break;
      case 3:
         //---- the number of the indicator horizontal levels   
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         //---- Values of the indicator horizontal levels   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+20);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-20);
         //---- gray and magenta colors are used for horizontal levels lines  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         //---- Short dot-dash is used for the horizontal level line  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         break;
      case 4:
         //---- the number of the indicator horizontal levels   
         IndicatorSetInteger(INDICATOR_LEVELS,0);
         break;
      case 5:
         //---- the number of the indicator horizontal levels   
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         //---- Values of the indicator horizontal levels   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-1);
         //---- gray and magenta colors are used for horizontal levels lines  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         //---- Short dot-dash is used for the horizontal level line  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         break;
     }

//---- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);

//---- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,LineBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(LineBuffer,true);

//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   switch(triggerType)
     {
      case 1: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with Stochastic ("+string(stochPeriod_trigger1)+",3,3)"); break;
      case 2: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with CCI ("+string(cciPeriod_trigger2)+",CLOSE)"); break;
      case 3: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with RSI ("+string(rsiPeriod_trigger3)+",CLOSE)"); break;
      case 4: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with MACD (5,13,1,CLOSE)"); break;
      case 5: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with Momentum ("+string(momentumPeriod_trigger5)+",CLOSE)"); break;
     }
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Bollinger_Squeeze_v9 iteration function                          | 
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
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(Ind_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(Std_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,clr;
   double d,Value[],ATR[],STD[];

//---- Calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(Ind_Handle,0,0,to_copy,Value)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(Std_Handle,0,0,to_copy,STD)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(Value,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(STD,true);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      switch(triggerType)
        {
         case 1: d=Value[bar]-50; break;
         case 2: d=Value[bar]; break;
         case 3: d=Value[bar]-50; break;
         case 4: d=Value[bar]; break;
         case 5: d=Value[bar]-100; break;
        }
        
      IndBuffer[bar]=d;
      LineBuffer[bar]=d;
      clr=2;
      
     // if(d>0) clr=4;
      //else if(d<0) clr=0;

      double bbs=bolDev*STD[bar]/(ATR[bar]*keltFactor);

      if(bbs<1)
        {
         if(d>0) clr=3;
         else clr=1;
        }
      else
        {
         if(d>0) clr=4;
         else clr=0;
        }
        
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
