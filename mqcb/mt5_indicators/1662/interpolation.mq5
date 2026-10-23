//+------------------------------------------------------------------+
//|                                                Interpolation.mq4 |
//|                                 Copyright © 2008, Gryb Alexander |
//|                ICQ: 478-923-832 E-mail: alexandergrib@rambler.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Gryb Alexander"
#property link      "ICQ: 478-923-832 E-mail: alexandergrib@rambler.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 1
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_LINE
//---- magenta color is used
#property indicator_color1 clrMagenta
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "Interpolation"

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input uint inumPrognoz=2;  // Number of predicted bars
input uint ibegin=0;       // Starting bar for the analysis
input uint iend=5;         // Last bar for the analysis
//+----------------------------------------------+
double b[];
//---- Declaration of integer variables of data starting point
int min_rates_total,Shift,begin,end,numPrognoz;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[];
//+------------------------------------------------------------------+    
//| Interpolation indicator initialization function                  | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   numPrognoz=int(inumPrognoz);
   begin=int(ibegin);
   end=int(iend);
   Shift=int(MathMax(numPrognoz-begin,0));
   min_rates_total=end+numPrognoz;
   
//----Checking the input variables
   if(end<begin) Print("Incorrect values of the input parameters for the analyzed bars!");

//---- memory allocation for arrays of variables   
   int size=int(end+1+numPrognoz);
   if(ArrayResize(b,size)<size) Print("Failed to distribute the memory for b[] array");
   
//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Interpolation");
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"Interpolation begin");
   ObjectDelete(0,"Interpolation end");
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Interpolation iteration function                                 | 
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
                const int &spread[])
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total || end<begin) return(RESET);
   
   if(prev_calculated<=0) for(int bar=rates_total-1; bar>=0; bar--) IndBuffer[bar]=0.0;

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   
//--- Determine coefficients
   for(int k=end; k>=begin; k--) b[k]=k;
   int start=begin-numPrognoz;
   int finish=end+numPrognoz+1;
   
  for(int bar=0; bar<finish; bar++) IndBuffer[bar]=0.0;
   
//---- main cycle of calculation of the indicator
   for(int bar=start; bar<finish; bar++)
     {
      double a=0;
      for(int k=begin; k<=end; k++)
        {
         double b1=1;
         double d=1;
         //Product from 0 from i-1 elements
         for(int z=begin; z<k; z++)
           {
            b1*=bar-b[z];
            d*=b[k]-b[z];
           }
           
         //Product from i+1 from numBars element
         for(int z=k+1; z<=end; z++)
           {
            b1*=bar-b[z];
            d*=b[k]-b[z];
           }
           
         a+=close[k]*b1/d;
        }

      IndBuffer[bar+Shift]=a;
     }
//----
   SetVline(0,"Interpolation end",0,time[end],clrBlue,0,2,true,"Interpolation end");
   SetVline(0,"Interpolation begin",0,time[begin],clrRed,0,2,true,"Interpolation begin");
//----     
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Vertical line creation                                          |
//+------------------------------------------------------------------+
void CreateVline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // vertical level time
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 bool     background,    // line background display
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_VLINE,nwin,time1,999999999);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n"); // tooltip disabling
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); // background object
//----
  }
//+------------------------------------------------------------------+
//|  Vertical line reinstallation                                    |
//+------------------------------------------------------------------+
void SetVline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // vertical level time
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 bool     background,// line background display
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateVline(chart_id,name,nwin,time1,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,999999999);
     }
//----
  }
//+------------------------------------------------------------------+
