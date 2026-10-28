//+------------------------------------------------------------------+
//|                                                  SuperZigZag.mq5 |
//|                                                     Stasikusssss |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1
#property indicator_type1 DRAW_COLOR_ZIGZAG
#property indicator_color1 Blue,Red

// indicator operation mode
// 0 "significative movement" specified in points
// 1 "significative movement" is calculated as high-low in bars for a certain period which multiplied by the "significative movement" coefficient
input int Mode=0;
input int ImportantPoint=600;    // "significative movement" in points
input int RangeBars=35;          // "significative movement" period in bars
input double RangeKoeff=0.45;    // "significative movement" coefficient
input int width=2;

double szz_up[];
double szz_dn[];
double color_buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,szz_up,INDICATOR_DATA);
   SetIndexBuffer(1,szz_dn,INDICATOR_DATA);
   SetIndexBuffer(2,color_buffer,INDICATOR_COLOR_INDEX);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   PlotIndexSetString(0,PLOT_LABEL,"SZZ "+Name());
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
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
   int i,j,prev,extr=0;
   if(prev_calculated==0)
    {
     ArrayInitialize(szz_up,0.0);
     ArrayInitialize(szz_dn,0.0);
     ArrayInitialize(color_buffer,0.0);
     prev=0;
     if(Mode==0) i=0;
     if(Mode==1) i=RangeBars;
    }
   if(prev_calculated>0)
    {
     for(j=rates_total-1; j>=0; j--)
      {
       if(szz_up[j]==high[j]) { i=j; prev=1; break; }
       if(szz_dn[j]==low[j]) { i=j; prev=2; break; }
      }
    }
   
   j=i+1;
   while(j<=rates_total-1 && i<=rates_total-1 && extr<=rates_total-1)
    {
     while(prev==0 && j<=rates_total-1 && i<=rates_total-1 && extr<=rates_total-1)
      {
       if(NormalizeDouble((high[Highest(high,i+1,j)]-low[i])/_Point,0)>=GetImpPoint(i,high,low)) // up beam
        {
         szz_up[j]=high[Highest(high,i+1,j)]; color_buffer[j]=0;
         szz_dn[Lowest(low,i,j)]=low[Lowest(low,i,j)]; color_buffer[Lowest(low,i,j)]=1;
         prev=1;
         i=j;
         extr=j;
         j++;
         break;
        }
       if(NormalizeDouble((high[i]-low[Lowest(low,i+1,j)])/_Point,0)>=GetImpPoint(i,high,low)) // down beam
        {
         szz_dn[j]=low[Lowest(low,i+1,j)]; color_buffer[j]=1;
         szz_up[Highest(high,i,j)]=high[Highest(high,i,j)]; color_buffer[Highest(high,i,j)]=0;
         prev=2;
         i=j;
         extr=j;
         j++;
         break;
        }
       j++;
      }
     
     while(prev==1 && j<=rates_total-1 && i<=rates_total-1 && extr<=rates_total-1) // last up beam
      {  
       if(NormalizeDouble((high[extr]-low[Lowest(low,i+1,j)])/_Point,0)>=GetImpPoint(i,high,low)) // look to see if there is already the down beam
        {
         szz_dn[j]=low[Lowest(low,i+1,j)]; color_buffer[j]=1;
         prev=2;
         i=j;
         extr=j;
         j++;
         break;
        }
       if(high[Highest(high,i,j)]>high[extr]) // update extremum of up beem if necessary
        {
         szz_up[j]=high[Highest(high,i,j)]; color_buffer[j]=0;
         szz_up[extr]=0.0;
         extr=j;
         i=j;
         j++;
         continue;
        }
       j++;
      }
     
     while(prev==2 && j<=rates_total-1 && i<=rates_total-1 && extr<=rates_total-1) // last down beam
      {   
       if(NormalizeDouble((high[Highest(high,i+1,j)]-low[extr])/_Point,0)>=GetImpPoint(i,high,low)) // look to see if there is already the up beam
        {
         szz_up[j]=high[Highest(high,i+1,j)]; color_buffer[j]=0;
         prev=1;
         i=j;
         extr=j;
         j++;
         break;
        }
       if(low[Lowest(low,i,j)]<low[extr]) // update extremum of down beem if necessary
        {
         szz_dn[j]=low[Lowest(low,i,j)]; color_buffer[j]=1;
         szz_dn[extr]=0.0;
         extr=j;
         i=j;
         j++;
         continue;
        }
       j++;
      }
    }
   return(rates_total);
  }
//+------------------------------------------------------------------+
double GetImpPoint(int i,const double &arrhigh[],const double &arrlow[])
 {
  if(Mode==0) return ImportantPoint;
  if(Mode==1)
   {
    return (arrhigh[Highest(arrhigh,i-RangeBars+1,i)]-arrlow[Lowest(arrlow,i-RangeBars+1,i)])/_Point*RangeKoeff;
   }
  return 0.0;
 }
//+------------------------------------------------------------------+
int Highest(const double &array[],int start,int finish)
 {
  int res=start;
  for(int i=start; i<=finish; i++)
   {
    if(array[i]>array[res]) res=i;
   }
  return res;
 }
//+------------------------------------------------------------------+
int Lowest(const double &array[],int start,int finish)
 {
  int res=start;
  for(int i=start; i<=finish; i++)
   {
    if(array[i]<array[res]) res=i;
   }
  return res;
 }
//+------------------------------------------------------------------+
string Name()
 {
  string text;
  if(Mode==0) text="("+IntegerToString(ImportantPoint)+")";
  if(Mode==1) text="( "+IntegerToString(RangeBars)+","+DoubleToString(RangeKoeff,2)+")";
  return text;
 }
//+------------------------------------------------------------------+