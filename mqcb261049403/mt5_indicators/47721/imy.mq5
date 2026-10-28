#property strict
#property version "1.1"
//#property indicator_separate_window
//#property indicator_buffers    2
//#property indicator_plots 2
//#property indicator_type1   DRAW_FILLING
//#property indicator_color1  clrRed
//#property indicator_style1  STYLE_SOLID
//#property indicator_width1  1
//#property indicator_separate_window
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
double Plus[],Op[],op;
int i,indBars,shiftBars,win;
string IndName;
//datetime tm,tm0,tm1,tm2,tm3;
long chartBars=-1,handle;
//input bool mySCREEN=false;
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //ObjectDelete(handle,"BID");
   //ObjectDelete(handle,"_BID");
   //ObjectDelete(handle,"_ASK");
}
//+------------------------------------------------------------------+
int OnInit()
{
   handle=ChartID();
   IndName="iMy";
   IndicatorSetString(INDICATOR_SHORTNAME,IndName);
   win=ChartWindowFind(handle,IndName);
   SetIndexBuffer(0,Op,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrWhite);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,1);
   //PlotIndexSetString(0,PLOT_LABEL,SYM[2]);
   
   SetIndexBuffer(1,Plus,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrDodgerBlue);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,1);
   //PlotIndexSetString(1,PLOT_LABEL,SYM[1]); 
   PlotIndexSetInteger(1,PLOT_SHIFT,1);
   //---
   ArraySetAsSeries(Op,true);
   ArraySetAsSeries(Plus,true);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   ChartRedraw();
   indBars=10000;
   if(iBars(Symbol(),Period())-10<indBars)indBars=iBars(Symbol(),Period())-2;
   //ArrayInitialize(Op,EMPTY_VALUE);
   //ArrayInitialize(Plus,EMPTY_VALUE);
   for(i=indBars; i>=0; i--)
   {
      //Op[i]=(iOpen(Symbol(),Period(),i)+iClose(Symbol(),Period(),i))/2.0;
      Op[i]=iOpen(Symbol(),Period(),i);
      Plus[i]=Op[i];
      //if(i==0)Op[i]=iClose(Symbol(),Period(),i);
   }
    //Op[0]=iClose(Symbol(),Period(),0);
   return(rates_total);
}