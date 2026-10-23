//------------------------------------------------------------------
#property copyright "© mladen, 2017"
#property link      "www.forex-station.com"
#property link      "mladenfx@gmail.com"
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

input int Periodv = 25; // Vidya period
input int Periods =  9; // Smoothing period

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
   SetIndexBuffer( 0,fupu,INDICATOR_DATA);      
   SetIndexBuffer( 1,fupd,INDICATOR_DATA);
   SetIndexBuffer( 2,fdnu,INDICATOR_DATA);
   SetIndexBuffer( 3,fdnd,INDICATOR_DATA);
   SetIndexBuffer( 4,bufferUp ,INDICATOR_DATA); 
   SetIndexBuffer( 5,bufferUpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 6,bufferDn ,INDICATOR_DATA); 
   SetIndexBuffer( 7,bufferDnc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 8,bufferMe ,INDICATOR_DATA); 
   SetIndexBuffer( 9,bufferMec,INDICATOR_COLOR_INDEX);
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
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
   if (Bars(_Symbol,_Period)<rates_total) return(-1);

   //
   //
   //
   //
   //
      
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      double median = (high[i]+low[i])/2.0;
            bufferUp[i] = iVidya(high[i],median,Periodv,Periods,i,rates_total,0);
            bufferMe[i] = iVidya(median ,median,Periodv,Periods,i,rates_total,1);
            bufferDn[i] = iVidya(low[i] ,median,Periodv,Periods,i,rates_total,2);
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

#define _vidyaInstances     3
#define _vidyaInstancesSize 3
double  vidya_work[][_vidyaInstances*_vidyaInstancesSize];
#define vidya_price 0
#define vidya_pricc 1
#define vidya_value 2

double iVidya(double price, double pricc, int cmoPeriods, int smoothPeriod, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(vidya_work,0)!=bars) ArrayResize(vidya_work,bars); int s = instanceNo*_vidyaInstancesSize;
   
   //
   //
   // using two prices prevents errors when zone indicator is calculated
   //
   //
   
   vidya_work[r][s+vidya_price] = price;
   vidya_work[r][s+vidya_pricc] = pricc;
          double sumUp = 0, sumDo = 0;
          for (int k=0; k<cmoPeriods && (r-k-1)>=0; k++)
          {
               double diff = vidya_work[r-k][s+vidya_pricc]-vidya_work[r-k-1][s+vidya_pricc];
                  if (diff > 0)
                        sumUp += diff;
                  else  sumDo -= diff;
          }      
          vidya_work[r][s+vidya_value] = (r>0) ? vidya_work[r-1][s+vidya_value]+((((sumUp+sumDo)!=0)?MathAbs((sumUp-sumDo)/(sumUp+sumDo)):1)*2.00/(1.00+MathMax(smoothPeriod,1)))*(vidya_work[r][s+vidya_price]-vidya_work[r-1][s+vidya_value]) : price;
   return(vidya_work[r][s+vidya_value]);
}