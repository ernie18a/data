//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trend continuation factor of average"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Trend continuation factor level up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_width2  0
#property indicator_label3  "Trend continuation factor level down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_width3  0

//
//---
//

input int                inpPeriod     = 15;            // Period
input int                inpAvgPeriod  = 5;             // Pre-smoothing period
input ENUM_MA_METHOD     inpAvgMethod  = MODE_LWMA;     // Pre-smoothing method
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;   // Price

double valu[],vald[],fup[],fdn[],avg[]; 
string ª_maNames[] = {"SMA","EMA","SMMA","LWMA"};
int    ª_avgHandle,ª_maPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,fup ,INDICATOR_DATA);     
         SetIndexBuffer(1,fdn ,INDICATOR_DATA);
         SetIndexBuffer(2,valu,INDICATOR_DATA); 
         SetIndexBuffer(3,vald,INDICATOR_DATA); 
         SetIndexBuffer(4,avg ,INDICATOR_CALCULATIONS);
         
         ª_maPeriod  = (inpAvgPeriod>1) ? inpAvgPeriod : 1;
         ª_avgHandle = iMA(_Symbol,0,ª_maPeriod ,0,inpAvgMethod,inpPrice); if (!_checkHandle(ª_avgHandle,ª_maNames[inpAvgMethod])) return(INIT_FAILED);
         
   //
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend continuation factor "+ª_maNames[inpAvgMethod]+" ("+(string)inpPeriod+","+(string)ª_maPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------ 
//
//
//

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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_avgHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);
         
         //
         //---
         //
         
         struct sTcfStruct
         {
            double plus_ch;
            double plus_cf;
            double minus_ch;
            double minus_cf;
            double up_dif;
            double dn_dif;
            double sum_up;
            double sum_dn;
         };
         static sTcfStruct m_array[];
         static int        m_arraySize=-1;
                       if (m_arraySize<rates_total) {  m_arraySize = ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(0); }
         
   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (avg[i]==EMPTY_VALUE) avg[i]=close[i];
      if (i>0)
      {
         double _roc = avg[i]-avg[i-1];
             if(_roc>0) { m_array[i].plus_ch  =  _roc;  m_array[i].plus_cf  =  m_array[i].plus_ch +m_array[i-1].plus_cf;  m_array[i].minus_ch = m_array[i].minus_cf = 0;}
             else       { m_array[i].minus_ch = -_roc;  m_array[i].minus_cf =  m_array[i].minus_ch+m_array[i-1].minus_cf; m_array[i].plus_ch  = m_array[i].plus_cf  = 0;}
      }
      else m_array[i].plus_ch = m_array[i].minus_ch = m_array[i].plus_cf = m_array[i].minus_cf =  0;

      //
      //
      //
           
      m_array[i].up_dif = m_array[i].plus_ch-m_array[i].minus_cf;
      m_array[i].dn_dif = m_array[i].minus_ch-m_array[i].plus_cf;
      if (i>inpPeriod)
      {
         m_array[i].sum_up = m_array[i-1].sum_up+m_array[i].up_dif-m_array[i-inpPeriod].up_dif;
         m_array[i].sum_dn = m_array[i-1].sum_dn+m_array[i].dn_dif-m_array[i-inpPeriod].dn_dif;
      }               
      else
      {
         m_array[i].sum_up = m_array[i].up_dif;
         m_array[i].sum_dn = m_array[i].dn_dif;
         for (int k=1; k<inpPeriod && i>=k; k++)
         {
            m_array[i].sum_up += m_array[i-k].up_dif;
            m_array[i].sum_dn += m_array[i-k].dn_dif;
         }            
      }         
      valu[i] =  fup[i] = (m_array[i].sum_up>m_array[i].sum_dn) ? -m_array[i].sum_dn : m_array[i].sum_up;
      vald[i] =  fdn[i] = (m_array[i].sum_up<m_array[i].sum_dn) ? -m_array[i].sum_dn : m_array[i].sum_up;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

bool _checkHandle(int _handle, string _description)
{
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}  
//------------------------------------------------------------------

