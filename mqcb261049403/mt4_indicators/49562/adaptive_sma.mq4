#property indicator_chart_window
#property indicator_buffers 1
#property indicator_label1  "Adaptive SMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrange
#property indicator_width1  1
#property strict

input int                  inpMaPeriod          = 25;          // Period
input ENUM_APPLIED_PRICE   inpPrice             = PRICE_CLOSE; // Price
input int                  inpLevel2Smothing    = 7;           // Smothing

double ext_val[],
       ext_sma[],
       ext_val_sma[],
       ext_atr[];

//---
int OnInit() {
   IndicatorBuffers(6);
   SetIndexBuffer(0,ext_val_sma,  INDICATOR_DATA);
   SetIndexBuffer(1,ext_sma,      INDICATOR_DATA);
   SetIndexBuffer(2,ext_val,      INDICATOR_DATA);
   SetIndexBuffer(3,ext_atr,      INDICATOR_CALCULATIONS);

   IndicatorSetString(INDICATOR_SHORTNAME,"ATR adaptive MA ("+(string)inpMaPeriod+")");
   return (INIT_SUCCEEDED);
}
//---
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
   int limit = rates_total-prev_calculated; if (limit>=rates_total-1) limit = rates_total-1;


   struct sWorkStruct {
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
   if (m_workSize<=rates_total) 
      m_workSize = ArrayResize(m_work,rates_total+500,2000);

   for (int i=limit, r=rates_total-i-1; i>=0 && !_StopFlag; i--,r++) {
      m_work[r].price = iMA(_Symbol,_Period,1,0,MODE_SMA,inpPrice,i);;
      m_work[r].tr    = (r>0) ? (high[i]>close[i+1] ? high[i] : close[i+1]) -(low[i]<close[i+1] ? low[i] : close[i+1]) : high[i]-low[i];
      if (r>inpMaPeriod) {
         m_work[r].sumSma = m_work[r-1].sumSma + m_work[r].price - m_work[r-inpMaPeriod].price;
         m_work[r].sumtr  = m_work[r-1].sumtr  + m_work[r].tr    - m_work[r-inpMaPeriod].tr;
      } else  { 
         m_work[r].sumSma = m_work[r].price; for (int k=1; k<inpMaPeriod && r>=k; k++) m_work[r].sumSma += m_work[r-k].price;
         m_work[r].sumtr  = m_work[r].tr;    for (int k=1; k<inpMaPeriod && r>=k; k++) m_work[r].sumtr  += m_work[r-k].tr;
      }            
      ext_atr[i] = m_work[r].sumtr/(double)inpMaPeriod;
      ext_sma[i] = NormalizeDouble(m_work[r].sumSma/(double)inpMaPeriod,_Digits);

      if (m_work[r  ].prevBar !=r || m_work[r+1].prevBar > r) {
         if (inpMaPeriod>1) {
            m_work[r].max = ext_atr[ArrayMaximum(ext_atr,inpMaPeriod-1,i)];            
            m_work[r].min = ext_atr[ArrayMinimum(ext_atr,inpMaPeriod-1,i)];            
         } else { 
            m_work[r].max = -DBL_MAX; 
            m_work[r].min = DBL_MAX; 
         }
      }       

      double _max   = m_work[r].max > ext_atr[i] ? m_work[r].max : ext_atr[i];            
      double _min   = m_work[r].min < ext_atr[i] ? m_work[r].min : ext_atr[i];            
      double _coeff = (_min!=_max) ? 1-(ext_atr[i]-_min)/(_max-_min) : 0.5;
      
      int _period = int(inpMaPeriod*(_coeff+1.0)/2.0);
      if (m_work[r  ].prevBar !=r || m_work[r+1].prevBar > r || m_work[r+1].period != _period) {
         m_work[r  ].prevBar = r;
         m_work[r+1].prevBar = -1;
         m_work[r+1].period  = _period;
         m_work[r].sum       = 0; 
         for (int k=1; k<_period && r>=k; k++) 
            m_work[r].sum += m_work[r-k].price; 
     }            
          
      ext_val[i]  = (_period>0) ? NormalizeDouble((m_work[r].sum+m_work[r].price)/(double)_period,_Digits) : m_work[r].price;
      double avg = 0;
      for(int s=0; s<inpLevel2Smothing; s++) {
         if(i+s >= rates_total) break;
         avg += ext_val[i+s] / inpLevel2Smothing;
      }
      ext_val_sma[i] = avg;
   }
   return(rates_total);
}

//---
void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
//---
