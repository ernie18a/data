//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   5
#property indicator_label1  "upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'207,243,207'
#property indicator_label2  "lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'255,230,183'
#property indicator_label3  "Upper band"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_label4  "Lower band"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_label5  "Middle value"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_width5  4

//
//
//
//
//

input int             QPeriod           = 32; // Quantile period
input int             HLPeriod          = 1;  // Period for high/low finding
input double          UpperBandPercent  = 90; // Upper band percent
input double          MedianBandPercent = 50; // Middle band percent
input double          LowerBandPercent  = 10; // Lower band percent

//
//
//
//
//

double bufferUp[],bufferUpc[],bufferDn[],bufferDnc[],bufferMe[],bufferMec[],fupu[],fupd[],fdnd[],fdnu[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer( 0,fupu,INDICATOR_DATA);      SetIndexBuffer(1,fupd,INDICATOR_DATA); PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   SetIndexBuffer( 2,fdnu,INDICATOR_DATA);      SetIndexBuffer(3,fdnd,INDICATOR_DATA); PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   SetIndexBuffer( 4,bufferUp ,INDICATOR_DATA); SetIndexBuffer(5,bufferUpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 6,bufferDn ,INDICATOR_DATA); SetIndexBuffer(7,bufferDnc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 8,bufferMe ,INDICATOR_DATA); SetIndexBuffer(9,bufferMec,INDICATOR_COLOR_INDEX);
      IndicatorSetString(INDICATOR_SHORTNAME,"Quantile bands ("+(string)QPeriod+","+(string)HLPeriod+")");

   return(0);
}
void OnDeinit(const int reason) { return; }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const int begin,
                 const double& price[])
{
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
   //
   //
   //
   //
   //
   
   
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
   {
      double prices[3];
             prices[0] = price[i];
             prices[1] = price[i];
             prices[2] = price[i];
             for (int k=0; k<HLPeriod && (i-k)>=0; k++)
             {
               prices[0] = MathMax(prices[0],price[i-k]);
               prices[1] = MathMin(prices[0],price[i-k]);
             }
                     ArraySort(prices);
      bufferUp[i]  = iQuantile(prices[2],QPeriod,UpperBandPercent ,i,rates_total,0);
      bufferMe[i]  = iQuantile(prices[1],QPeriod,MedianBandPercent,i,rates_total,2);
      bufferDn[i]  = iQuantile(prices[0],QPeriod,LowerBandPercent ,i,rates_total,1);
      fupd[i]      = bufferMe[i]; fupu[i] = bufferUp[i]; 
      fdnu[i]      = bufferMe[i]; fdnd[i] = bufferDn[i]; 
      bufferUpc[i] = (i>0) ? (bufferUp[i]>bufferUp[i-1]) ? 1 : (bufferUp[i]<bufferUp[i-1])? 2 : bufferUpc[i-1] : 0;
      bufferDnc[i] = (i>0) ? (bufferDn[i]>bufferDn[i-1]) ? 1 : (bufferDn[i]<bufferDn[i-1])? 2 : bufferDnc[i-1] : 0;
      bufferMec[i] = (bufferUpc[i]==1 && bufferDnc[i]==1) ? 1 : (bufferUpc[i]==2 && bufferDnc[i]==2) ? 2 : 0;
   }         
   return(rates_total);         
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define quantileInstances 3
double quantileValues[][quantileInstances];
double quantileArray[];
double iQuantile(double value, int period, double qp, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(quantileArray ,0)!=period) ArrayResize(quantileArray ,period);
   if (ArrayRange(quantileValues,0)!=bars)   ArrayResize(quantileValues,bars);
                  quantileValues[i][instanceNo] = value;
                        for(int k=0; k<period && (i-k)>=0; k++) quantileArray[k] = quantileValues[i-k][instanceNo];
       ArraySort(quantileArray);

   //
   //
   //
   //
   //
   
   double index = (period-1)*MathMax(MathMin(qp,100),0)/100.00;
   int    ind   = (int)index;
   double delta = index - ind;
   if (ind == NormalizeDouble(index,5))
         return(            quantileArray[ind]);
         return((1.0-delta)*quantileArray[ind]+delta*quantileArray[ind+1]);
}