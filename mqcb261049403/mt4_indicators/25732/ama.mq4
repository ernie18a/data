//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_label1  "AMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_width1  2
#property indicator_label2  "AMA - slope down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
#property indicator_label3  "AMA - slope down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_width3  2

//
//
//

input int                inpPeriod     = 14;          // Period
input int                inpFastPeriod =  2;          // Fast end period
input int                inpSlowPeriod = 30;          // Slow end period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price

double val[],valda[],valdb[],valc[],prices[];
int _hlPeriod; double _fastEnd,_slowEnd;

//------------------------------------------------------------------
//
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,val  ,INDICATOR_DATA);
   SetIndexBuffer(1,valda,INDICATOR_DATA);
   SetIndexBuffer(2,valdb,INDICATOR_DATA);
   SetIndexBuffer(3,valc  );
   SetIndexBuffer(4,prices);
            _fastEnd  = 2.0/(inpFastPeriod+1.0);   
            _slowEnd  = 2.0/(inpSlowPeriod+1.0);   
            _hlPeriod = inpPeriod+1;
      IndicatorSetString(INDICATOR_SHORTNAME,"AMA ("+(string)inpPeriod+","+(string)inpFastPeriod+","+(string)inpSlowPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//
//
//

int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=rates_total-prev_calculated; if (i>=rates_total) i=rates_total-1; 
      static datetime prev_t=-1;
      static double   prev_max,prev_min;
   
   //
   //
   //
   
   if (valc[i]==-1) iCleanPoint(i,valda,valdb);
   for (; i>=0 && !_StopFlag; i--)
   {
      prices[i] = iMA(NULL,0,1,0,MODE_SMA,inpPrice,i);
         if (prev_t!=time[i])
         {
            prev_t = time[i]; 
                prev_max = prices[ArrayMaximum(prices,_hlPeriod,i)];
                prev_min = prices[ArrayMinimum(prices,_hlPeriod,i)];
         }
         double max = (prices[i]>prev_max) ? prices[i] : prev_max;
         double min = (prices[i]<prev_min) ? prices[i] : prev_min;

         //
         //---
         //

         if (i<rates_total-1)
         {
            double mltp = (max!=min) ? ((prices[i]-min)-(max-prices[i]))/(max-min) : 1; if (mltp<0) mltp *= -1;
            double ssc  = mltp * ( _fastEnd-_slowEnd) + _slowEnd;	
                val[i]  = val[i+1]+(ssc*ssc)*(prices[i]-val[i+1]);
                valc[i] = (val[i]>val[i+1]) ? 1 :(val[i]<val[i+1]) ? 2 : valc[i+1];
         }   
         else { val[i] = prices[i]; valc[i] = 0; }
         valda[i] = valdb[i] = EMPTY_VALUE; if (valc[i] == 2) iPlotPoint(i,valda,valdb,val);
   }
   
   //
   //
   //
   
   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

void iCleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
void iPlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}


