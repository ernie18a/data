//+------------------------------------------------------------------+
//|                                                   Fractal_TL.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
//--- to calculate and draw the indicator, zero buffers are used
#property indicator_buffers 0
//--- used only zero graphical constructions
#property indicator_plots   0
input ENUM_TIMEFRAMES base_tf;
input color Resistance_Color=Red;       // color of the resistance line
input ENUM_LINE_STYLE Resistance_Style; // line style of the resistance
input int Resistance_Width=1;           // width of the resistance line
input color Support_Color=Red;          // color of the support line
input ENUM_LINE_STYLE Support_Style;    // style of the support line
input int Support_Width=1;              // width of the support line
input bool Remove_TL=false;             // Remove_TL
int Fractal_base; 
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//get the handle of the iFractals indicator
   Fractal_base=iFractals(Symbol(),base_tf);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- declaration of variables
   int n,UpperFractal_1_base,LowerFractal_1_base,UpperFractal_2_base,LowerFractal_2_base;
//--- declaration of arrays for writing the values of the buffers of the indicator iFractal
   double FractalDown_base[],FractalUp_base[];
   double UpFractal_1_base,LowFractal_1_base,UpFractal_2_base,LowFractal_2_base;
// --- first you need to write the arrays of the values of the Fractal
// --- filling with the data of the buffer
   CopyBuffer(Fractal_base,0,TimeCurrent(),Bars(Symbol(),base_tf),FractalUp_base);
   CopyBuffer(Fractal_base,1,TimeCurrent(),Bars(Symbol(),base_tf),FractalDown_base);
// --- indexing as in timeseries
   ArraySetAsSeries(FractalUp_base,true);
   ArraySetAsSeries(FractalDown_base,true);
//+------------------------------------------------------------------+
//| Search for fractal values                                        |
//+------------------------------------------------------------------+
// --- Search for the first upper fractal
   for(n=0; n<Bars(Symbol(),base_tf); n++)
     {
      // --- if a non-empty value, terminate the loop
      if(FractalUp_base[n]!=EMPTY_VALUE)
         break;
     }
   UpFractal_1_base=FractalUp_base[n];// --- write the price value of the first fractal in the variable
   UpperFractal_1_base=n;// --- write the index of the first fractal in the variable
                         // ---   
// --- Search for the second upper fractal
   for(n=UpperFractal_1_base+1; n<Bars(Symbol(),base_tf); n++)
     {
      // --- if a non-empty value, terminate the loop
      if(FractalUp_base[n]!=EMPTY_VALUE)
         break;
     }
   UpFractal_2_base=FractalUp_base[n]; // --- write the price value of the second fractal in the variable
   UpperFractal_2_base=n;// --- write the index of the second fractal in the variable
                         // ---
// --- Search for the first lower fractal
   for(n=0; n<Bars(Symbol(),base_tf); n++)
     {
      // --- if a non-empty value, terminate the loop
      if(FractalDown_base[n]!=EMPTY_VALUE)
         break;
     }
   LowFractal_1_base=FractalDown_base[n];// --- write the price value of the first fractal in the variable
   LowerFractal_1_base=n;// --- write the index of the first fractal in the variable
                         // ---   
// --- Search for the second lower fractal
   for(n=LowerFractal_1_base+1; n<Bars(Symbol(),base_tf); n++)
     {
      // --- if a non-empty value, terminate the loop
      if(FractalDown_base[n]!=EMPTY_VALUE)
         break;
     }
   LowFractal_2_base=FractalDown_base[n];// --- write the price value of the second fractal in the variable
   LowerFractal_2_base=n;// --- write the index of the second fractal in the variable
//--- 
//+------------------------------------------------------------------+
//|Search of time values of fractals                                 |
//+------------------------------------------------------------------+
// --- declaration of an array for storing the time of the corresponding bar index
   datetime UpFractalTime_1_base[],LowFractalTime_1_base[],UpFractalTime_2_base[],LowFractalTime_2_base[];
// --- indexing as in timeseries   
   ArraySetAsSeries(UpFractalTime_1_base,true);
   ArraySetAsSeries(LowFractalTime_1_base,true);
   ArraySetAsSeries(UpFractalTime_2_base,true);
   ArraySetAsSeries(LowFractalTime_2_base,true);
// --- search of time of fractals
   CopyTime(Symbol(),base_tf,UpperFractal_1_base,1,UpFractalTime_1_base);
   CopyTime(Symbol(),base_tf,LowerFractal_1_base,1,LowFractalTime_1_base);
   CopyTime(Symbol(),base_tf,UpperFractal_2_base,1,UpFractalTime_2_base);
   CopyTime(Symbol(),base_tf,LowerFractal_2_base,1,LowFractalTime_2_base);
// ---
//+------------------------------------------------------------------+
//|Drawing fractals
//+------------------------------------------------------------------+
ObjectCreate(0,"UpperFractal_1",OBJ_ARROW,0,UpFractalTime_1_base[0], UpFractal_1_base);
ObjectCreate(0,"UpperFractal_2",OBJ_ARROW,0,UpFractalTime_2_base[0], UpFractal_2_base);
ObjectSetInteger(0,"UpperFractal_1",OBJPROP_COLOR,Resistance_Color);
ObjectSetInteger(0,"UpperFractal_2",OBJPROP_COLOR,Resistance_Color);
ObjectSetInteger(0,"UpperFractal_1",OBJPROP_ARROWCODE,217);
ObjectSetInteger(0,"UpperFractal_2",OBJPROP_ARROWCODE,217);
ObjectSetInteger(0,"UpperFractal_1",OBJPROP_ANCHOR,ANCHOR_BOTTOM);
ObjectSetInteger(0,"UpperFractal_2",OBJPROP_ANCHOR,ANCHOR_BOTTOM);
//----
ObjectCreate(0,"LowerFractal_1",OBJ_ARROW,0,LowFractalTime_1_base[0], LowFractal_1_base);
ObjectCreate(0,"LowerFractal_2",OBJ_ARROW,0,LowFractalTime_2_base[0], LowFractal_2_base);
ObjectSetInteger(0,"LowerFractal_1",OBJPROP_COLOR,Support_Color);
ObjectSetInteger(0,"LowerFractal_2",OBJPROP_COLOR,Support_Color);
ObjectSetInteger(0,"LowerFractal_1",OBJPROP_ARROWCODE,218);
ObjectSetInteger(0,"LowerFractal_2",OBJPROP_ARROWCODE,218);
ObjectSetInteger(0,"LowerFractal_1",OBJPROP_ANCHOR,ANCHOR_TOP);
ObjectSetInteger(0,"LowerFractal_2",OBJPROP_ANCHOR,ANCHOR_TOP);
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Drawing trend lines                                |
//+------------------------------------------------------------------+
//--- rewrite tl
if (ObjectGetInteger(0,"TL_Support",OBJPROP_TIME)!=LowFractalTime_2_base[0])
   {
      ObjectDelete(0,"TL_Support");
      ObjectDelete(0,"LowerFractal_1");
      ObjectDelete(0,"LowerFractal_2");
   }
if (ObjectGetInteger(0,"TL_Resistance",OBJPROP_TIME)!=UpFractalTime_2_base[0])
   {
      ObjectDelete(0,"TL_Resistance");
      ObjectDelete(0,"UpperFractal_1");
      ObjectDelete(0,"UpperFractal_2");
   }
//--- Create support line
   ObjectCreate(0,"TL_Support",OBJ_TREND,0,LowFractalTime_2_base[0],LowFractal_2_base,LowFractalTime_1_base[0],LowFractal_1_base);
   ObjectSetInteger(0,"TL_Support",OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,"TL_Support",OBJPROP_COLOR,Support_Color);
   ObjectSetInteger(0,"TL_Support",OBJPROP_STYLE,Support_Style);
   ObjectSetInteger(0,"TL_Support",OBJPROP_WIDTH,Support_Width);
//--- Create resistance line
   ObjectCreate(0,"TL_Resistance",OBJ_TREND,0,UpFractalTime_2_base[0],UpFractal_2_base,UpFractalTime_1_base[0],UpFractal_1_base);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_COLOR,Resistance_Color);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_STYLE,Resistance_Style);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_WIDTH,Resistance_Width);
//--- Delete trendlines
if (Remove_TL==true)
{
   ObjectDelete(0,"TL_Support");
   ObjectDelete(0,"TL_Resistance");
   ObjectDelete(0,"LowerFractal_1");
   ObjectDelete(0,"LowerFractal_2");
   ObjectDelete(0,"UpperFractal_1");
   ObjectDelete(0,"UpperFractal_2");
       
}
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
