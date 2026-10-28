//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_label1  "SRsi"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_width1  2
#property indicator_label2  "SRsiUp"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumSeaGreen
#property indicator_width2  2
#property indicator_label3  "SRsiUp"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSeaGreen
#property indicator_width3  2
#property indicator_label4  "SRsiDown"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrangeRed
#property indicator_width4  2
#property indicator_label5  "SRsiDown"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrOrangeRed
#property indicator_width5  2

//
//
//

input int    inpRsiPeriod  = 20;   // RSI period
input double inpLevels     = 0.38; // Levels
input double inpNLevels    = 0.05; // Neutral zone

double val[],valda[],valdb[],valua[],valub[],valc[],srsiv[],srsis[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,val  ,INDICATOR_DATA);
   SetIndexBuffer(1,valua,INDICATOR_DATA);
   SetIndexBuffer(2,valub,INDICATOR_DATA);
   SetIndexBuffer(3,valda,INDICATOR_DATA);
   SetIndexBuffer(4,valdb,INDICATOR_DATA);
   SetIndexBuffer(5,valc );
   SetIndexBuffer(6,srsiv);
   SetIndexBuffer(7,srsis);
      IndicatorSetInteger(INDICATOR_LEVELS,4);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0, inpLevels);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-inpLevels);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2, inpNLevels);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-inpNLevels);
      IndicatorSetString(INDICATOR_SHORTNAME,"SRsi ("+(string)inpRsiPeriod+","+(string)inpNLevels+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }
int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1; 
   
   //
   //
   //
   
   if (valc[i]==1) iCleanPoint(i,valua,valub);
   if (valc[i]==2) iCleanPoint(i,valda,valdb);
   for (; i>=0 && !_StopFlag; i--)
   {
      srsiv[i] = (high[i]!=low[i]) ? (close[i]-open[i])/(high[i]-low[i]) : 0;
         if (i<rates_total-inpRsiPeriod)
                srsis[i] = srsis[i+1]-srsiv[i+inpRsiPeriod]+srsiv[i];
         else { srsis[i] = srsiv[i]; for (int k=1; k<inpRsiPeriod && i+k<rates_total; k++) srsis[i] += srsiv[i+k]; }

         //
         //
         //
                           
         val[i]   = srsis[i]/(double)inpRsiPeriod;
         valc[i]  = (val[i]>inpNLevels) ? 1 : (val[i]<-inpNLevels) ? 2 : 0;
         valua[i] = valub[i] = valda[i] = valdb[i] = EMPTY_VALUE;
            if (valc[i] == 1) iPlotPoint(i,valua,valub,val);
            if (valc[i] == 2) iPlotPoint(i,valda,valdb,val);
   }
   return(rates_total);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
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
