//+------------------------------------------------------------------+
//|                                                 StepRSI_v5.2.mq5 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
#property description ""
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  StepRSI indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used for the indicator line
#property indicator_color1  clrDeepSkyBlue,clrDeepPink
//---- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying of the the indicator label
#property indicator_label1  "Step RSI"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  80
#property indicator_level2  50
#property indicator_level3  20
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Indicator window size limitation             |
//+----------------------------------------------+
#property indicator_minimum   0
#property indicator_maximum 100
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint RSIPeriod=14;
input double StepSize=5;
input uint MAPeriod=1;
input  ENUM_MA_METHOD   MAType=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;
input bool Mode=true;
input int Shift=0;                       // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that 
//---- will be used as indicator buffers
double RSIBuffer[];
double FastBuffer[];
//---- Declaration of integer variables for indicators handles
int MA_Handle,RSI_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(RSIPeriod+MAPeriod)+1;

//---- getting handle of the RSI indicator
   if(!Mode)
     {
      RSI_Handle=iRSI(NULL,0,RSIPeriod,PRICE_CLOSE);
      if(RSI_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the RSI indicator");
         return(INIT_FAILED);
        }
     }

//---- Getting the handle of the iMA indicator
   MA_Handle=iMA(NULL,0,MAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iMA");
      return(INIT_FAILED);
     }

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,RSIBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Indexing buffer elements as timeseries   
   ArraySetAsSeries(RSIBuffer,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,FastBuffer,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Indexing buffer elements as timeseries   
   ArraySetAsSeries(FastBuffer,true);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"StepRSI(",RSIPeriod,", ",StepSize,", ",MAPeriod,", ",Shift,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//----
   return(INIT_SUCCEEDED);
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
//---- checking the number of bars to be enough for calculation
   if((!Mode && BarsCalculated(RSI_Handle)<rates_total)
      || BarsCalculated(MA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,to_copy,bar,trend0;
   double smin0,smax0,RSI[],MA[],result;
   static double smin1,smax1;
   static int trend1;

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(RSI,true);

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
      smin1=+999999;
      smax1=-999999;
      trend1=0;
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(!Mode) if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);
   to_copy+=int(RSIPeriod);
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Mode)
        {
         double sumn=0.0;
         double sump=0.0;

         for(int kkk=0; kkk<int(RSIPeriod); kkk++)
           {
            double rel=MA[bar+kkk]-MA[bar+kkk+1];
            if(rel>0) sump+=rel;
            else      sumn-=rel;
           }
         double positive=sump/RSIPeriod;
         double negative=sumn/RSIPeriod;

         if(!negative) RSIBuffer[bar]=100.0;
         else RSIBuffer[bar]=100.0-100.0/(1.0+positive/negative);
        }
      else RSIBuffer[bar]=RSI[bar];

      //----
      smax0=RSIBuffer[bar]+2.0*StepSize;
      smin0=RSIBuffer[bar]-2.0*StepSize;
      trend0=trend1;
      //----
      if(trend1<=0 && RSIBuffer[bar]>smax1) trend0=+1;
      if(trend1>=0 && RSIBuffer[bar]<smin1) trend0=-1;
      if(trend0>0)
        {
         if(smin0<smin1) smin0=smin1;
         result=smin0+StepSize;
        }
      else
      if(trend0<0)
        {
         if(smax0>smax1) smax0=smax1;
         result=smax0-StepSize;
        }

      FastBuffer[bar]=result;

      if(bar>0)
        {
         smin1=smin0;
         smax1=smax0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
