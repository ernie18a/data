//+---------------------------------------------------------------------+
//|                                                  ColorParabolic.mq5 | 
//|                         Copyright © 2010, Nikolay Kositsin + lukas1 | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin + lukas1"
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----four buffers are used for calculation of drawing of the indicator
#property indicator_buffers 4
//---- four plots are used in total
#property indicator_plots   4
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- Magenta color is used for the indicator
#property indicator_color1  clrMagenta
//---- indicator 1 width is equal to 1
#property indicator_width1  4
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Lower Parabolic"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- DodgerBlue color is used for the indicator
#property indicator_color2  clrDodgerBlue
//---- indicator 2 width is equal to 1
#property indicator_width2  4
//---- displaying of the bearish label of the indicator
#property indicator_label2 "Upper Parabolic"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- Magenta color is used for the indicator
#property indicator_color3  clrMagenta
//---- indicator 3 width is equal to 4
#property indicator_width3  4
//---- displaying of the bullish label of the indicator
#property indicator_label3  "Parabolic Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- DodgerBlue color is used for the indicator
#property indicator_color4  clrDodgerBlue
//---- indicator 4 width is equal to 4
#property indicator_width4  4
//---- displaying of the bearish label of the indicator
#property indicator_label4 "Parabolic Buy"
//+----------------------------------------------+
//| Parabolic indicator input parameters         |
//+----------------------------------------------+
input double StepH_=0.02;//Step for high points
input double MaximumH=0.5;//Maximum for high points
input double StepL_=0.02;//Step for low points
input double MaximumL=0.5;//Maximum for low points
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double BuyBuffer[],SellBuffer[];
double UpSarBuffer[],DnSarBuffer[];
//---- 
bool dirlong_,first_;
double ep_,start_,last_high_,last_low_,prev_sar_;
double StepH,StepL;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| Parabolic indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;
   StepH=MathMin(StepH_,MaximumH);
   StepL=MathMin(StepL_,MaximumL);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpSarBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,158);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnSarBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,158);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- creating name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Parabolic");

//---- set accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| Parabolic iteration function                                     | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of variables with a floating point
   double price_low,price_high,sar;
   double ep,start,last_high,last_low,prev_sar;
//---- Declaration of integer variables and getting already calculated bars
   int gfirst,bar;
   bool dirlong,first;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      gfirst=begin+min_rates_total; // starting index for calculation of all bars
      first_=false;
      dirlong_=false;
      last_high_=0.0;
      last_low_=999999999.0;
      ep_=price[min_rates_total-1];
      prev_sar_=ep_;
      start_=0.0;

      //---- performing the shift of beginning of indicator drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+min_rates_total);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,begin+min_rates_total);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,begin+min_rates_total);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,begin+min_rates_total);
     }
   else gfirst=prev_calculated-1; // starting index for calculation of new bars

//---- restore values of the variables
   ep=ep_;
   start=start_;
   last_high=last_high_;
   last_low=last_low_;
   dirlong=dirlong_;
   first=first_;
   prev_sar=prev_sar_;

//---- main cycle of calculation of the Parabolic indicator
   for(bar=gfirst; bar<rates_total; bar++)
     {
      price_low=price[bar];
      price_high=price[bar];
      sar=prev_sar+start*(ep-prev_sar);
      //----
      if(dirlong)
        {
         if(ep<price_high && start+StepL<=MaximumL) start+=StepL;
         if(sar>=price_low)
           {
            start=StepL;
            dirlong=false;
            ep=price_low;
            last_low=price_low;

            if(price_high<last_high) sar=last_high;
            else sar=price_high;
           }
         else
           {
            if(ep<price_low && start+StepL<=MaximumL) start+=StepL;

            if(ep<price_high)
              {
               last_high=price_high;
               ep=price_high;
              }
           }
        }
      //----
      else
        {
         if(ep>price_low && start+StepH<=MaximumH) start+=StepH;
         if(sar<=price_high)
           {
            start=StepH;
            dirlong=true;
            ep=price_high;
            last_high=price_high;
            if(price_low>last_low) sar=last_low;
            else sar=price_low;
           }
         else
           {
            if(ep>price_high && start+StepH<=MaximumH) start+=StepH;

            if(ep>price_low)
              {
               last_low=price_low;
               ep=price_low;
              }
           }
        }

      //---- zero out the contents of the indicator buffers for calculation
      DnSarBuffer[bar]=EMPTY_VALUE;
      UpSarBuffer[bar]=EMPTY_VALUE;

      if(price[bar]<sar) UpSarBuffer[bar]=sar;
      else               DnSarBuffer[bar]=sar;

      //---- save values of the variables
      if(bar==rates_total-2)
        {
         ep_=ep;
         start_=start;
         last_high_=last_high;
         last_low_=last_low;
         dirlong_=dirlong;
         first_=first;
         prev_sar_=sar;
        }
        
        if(bar<rates_total-1) prev_sar=sar;
     }

//---- recalculation of the starting index for calculation of all bars
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator     
      gfirst++;

//---- second cycle of calculation of the Parabolic indicator
   for(bar=gfirst; bar<rates_total; bar++)
     {
      //---- zero out the contents of the indicator buffers for calculation
      BuyBuffer[bar]=EMPTY_VALUE;
      SellBuffer[bar]=EMPTY_VALUE;
      
      if(UpSarBuffer[bar-1]==EMPTY_VALUE&&UpSarBuffer[bar]!=EMPTY_VALUE) SellBuffer[bar]=UpSarBuffer[bar];
      if(DnSarBuffer[bar-1]==EMPTY_VALUE&&DnSarBuffer[bar]!=EMPTY_VALUE) BuyBuffer[bar]=DnSarBuffer[bar];
     }
//----      
   return(rates_total);
  }
//+------------------------------------------------------------------+
