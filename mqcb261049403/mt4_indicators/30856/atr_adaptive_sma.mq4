//------------------------------------------------------------------
#property copyright   "© mladen, 2020"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "ATR adaptive SMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_label1  "SMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "ATR adaptive SMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_width2  3
#property indicator_label3  "ATR adaptive SMA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_width3  3
#property indicator_label4  "ATR adaptive SMA"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_width4  3
#property strict

//
//
//

input int                inpMaPeriod = 25;          // SMA period
input ENUM_APPLIED_PRICE inpPrice    = PRICE_CLOSE; // Price
      enum enColorMode
      {
         col_onSlope, // Change color on slope change
         col_onCross, // Change color on two sma cross
      };
input enColorMode        inpColorMode = col_onCross; // Color change mode

//
//
//

double val[],valda[],valdb[],valc[],sma[],atr[];

//------------------------------------------------------------------ 
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0,sma  ,INDICATOR_DATA);
   SetIndexBuffer(1,val  ,INDICATOR_DATA);
   SetIndexBuffer(2,valda,INDICATOR_DATA);
   SetIndexBuffer(3,valdb,INDICATOR_DATA);
   SetIndexBuffer(4,valc ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,atr  ,INDICATOR_CALCULATIONS);

      //
      //
      //

   IndicatorSetString(INDICATOR_SHORTNAME,"ATR adaptive SMA ("+(string)inpMaPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit = rates_total-prev_calculated; if (limit>=rates_total-1) limit = rates_total-1;
   
   //
   //
   //
   
      struct sWorkStruct
            {
               double price;
               double tr;
               double sumtr;
               double min;
               double max;
               double sum;
               double sumSma;
               int    period;
               int    prevBar;
                  sWorkStruct() : prevBar(-1), period(INT_MIN) {};
            };
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<=rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

   //
   //---
   //
   
   if (valc[limit]==1) CleanPoint(limit,valda,valdb);
   for (int i=limit, r=rates_total-i-1; i>=0 && !_StopFlag; i--,r++)
   {
      m_work[r].price = iMA(_Symbol,_Period,1,0,MODE_SMA,inpPrice,i);;
      m_work[r].tr    = (r>0) ? (high[i]>close[i+1] ? high[i] : close[i+1]) -(low[i]<close[i+1] ? low[i] : close[i+1]) : high[i]-low[i];
         if (r>inpMaPeriod)
               {
                  m_work[r].sumSma = m_work[r-1].sumSma + m_work[r].price - m_work[r-inpMaPeriod].price;
                  m_work[r].sumtr  = m_work[r-1].sumtr  + m_work[r].tr    - m_work[r-inpMaPeriod].tr;
               }                  
         else  { 
                  m_work[r].sumSma = m_work[r].price; for (int k=1; k<inpMaPeriod && r>=k; k++) m_work[r].sumSma += m_work[r-k].price;
                  m_work[r].sumtr  = m_work[r].tr;    for (int k=1; k<inpMaPeriod && r>=k; k++) m_work[r].sumtr  += m_work[r-k].tr;
               }            
               atr[i] = m_work[r].sumtr/(double)inpMaPeriod;
               sma[i] = NormalizeDouble(m_work[r].sumSma/(double)inpMaPeriod,_Digits);

      //
      //
      //
         
         if (m_work[r  ].prevBar !=r ||
             m_work[r+1].prevBar > r)
             {
                  if (inpMaPeriod>1)
                  {
                        m_work[r].max = atr[ArrayMaximum(atr,inpMaPeriod-1,i)];            
                        m_work[r].min = atr[ArrayMinimum(atr,inpMaPeriod-1,i)];            
                  }
                  else { m_work[r].max = -DBL_MAX; m_work[r].min = DBL_MAX; }
            }
             
         double _max   = m_work[r].max > atr[i] ? m_work[r].max : atr[i];            
         double _min   = m_work[r].min < atr[i] ? m_work[r].min : atr[i];            
         double _coeff = (_min!=_max) ? 1-(atr[i]-_min)/(_max-_min) : 0.5;
      
         int _period = int(inpMaPeriod*(_coeff+1.0)/2.0);
         if (m_work[r  ].prevBar !=r ||
             m_work[r+1].prevBar > r ||
             m_work[r+1].period != _period)
             {
                  m_work[r  ].prevBar = r;
                  m_work[r+1].prevBar = -1;
                  m_work[r+1].period  = _period;
                  m_work[r].sum       = 0; 
                     for (int k=1; k<_period && r>=k; k++) m_work[r].sum += m_work[r-k].price; 
             }            

         //
         //
         //
               
         val[i]  = (_period>0) ? NormalizeDouble((m_work[r].sum+m_work[r].price)/(double)_period,_Digits) : m_work[r].price;
         if (inpColorMode==col_onSlope)
               valc[i] = (r>0) ? (val[i]>val[i+1]) ? 2 : (val[i]<val[i+1]) ? 1 : valc[i+1]: 0;
         else  valc[i] = (val[i]>sma[i]) ? 2 :(val[i]<sma[i]) ? 1 : (r>0) ? valc[i+1]: 0;
         if (valc[i]==1) PlotPoint(i,valda,valdb,val); else valda[i] = valdb[i] = EMPTY_VALUE;
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

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}
