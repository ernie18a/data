//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrPaleVioletRed,clrLimeGreen

//
//
//

input double             inpSARStep    = 0.02;        // SAR step
input double             inpSARMaximum = 0.2;         // SAR maximum
input int                inpMaPeriod   =  14;         // Average period
input ENUM_MA_METHOD     inpMaMethod   = MODE_EMA;    // Average method
input ENUM_APPLIED_PRICE inpMahPrice   = PRICE_HIGH;  // Price for high
input ENUM_APPLIED_PRICE inpMalPrice   = PRICE_LOW;   // Price for low

double val[],valc[],avgh[],avgl[];
int _mahHandle,_malHandle;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA); 
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,avgh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,avgl,INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(0,PLOT_ARROW,159);
      
         //
         //
         //
         
            _mahHandle  = iMA(_Symbol,0,inpMaPeriod,0,inpMaMethod,inpMahPrice); if (!_checkHandle(_mahHandle,"average of high")) return(INIT_FAILED);
            _malHandle  = iMA(_Symbol,0,inpMaPeriod,0,inpMaMethod,inpMalPrice); if (!_checkHandle(_malHandle,"average of low"))  return(INIT_FAILED);
      
         //
         //
         //
         
      iParabolic.init(inpSARStep,inpSARMaximum);
   return(INIT_SUCCEEDED);      
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

double sarOpen;
double sarPosition;
double sarChange;
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
{
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(_mahHandle,0,0,_copyCount,avgh)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(_malHandle,0,0,_copyCount,avgl)!=_copyCount) return(prev_calculated);

   //
   //---
   //

   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
         val[i]  = iParabolic.calculate(avgh[i],avgl[i],sarOpen,sarPosition,sarChange,i,rates_total);
         valc[i] = (sarPosition==1) ? 1 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//
//

class CParabolic
{
   private :
      double m_step;
      double m_maximum;
      struct sParabolicStruct
      {
         double open;
         double high;
         double low;
         double ohigh;
         double olow;
         double position;
         double af;
      };
      sParabolicStruct m_array[];
      int              m_arraySize;
   
   public :
      CParabolic() : m_step(0.02), m_maximum(0.2), m_arraySize(-1) {                     };
     ~CParabolic()                                                 { ArrayFree(m_array); };
     
     bool init(double step, double maximum)
     {
         m_step    = step;
         m_maximum = maximum;
            return(true);
     }
     double calculate(double high, double low, double& pOpen, double& pPosition, double& pChange, int i, int bars)
     {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
   
         //
         //
         //
         
         if (high<low) { double temp = high; high = low; low  = temp;}             
         double pClose  = high;
                pChange = 0;
                     m_array[i].ohigh = high;
                     m_array[i].olow  = low;
                     if (i<1)
                     {
                        m_array[i].high     = high;
                        m_array[i].low      = low;
                        m_array[i].open     = high;
                        m_array[i].position = -1;
                           return(EMPTY_VALUE);
                     }
                     m_array[i].open     = m_array[i-1].open;
                     m_array[i].af       = m_array[i-1].af;
                     m_array[i].position = m_array[i-1].position;
                     m_array[i].high     = MathMax(m_array[i-1].high,high);
                     m_array[i].low      = MathMin(m_array[i-1].low ,low );
      
            //
            //
            //
   
            if (m_array[i].position == 1)
               if (low<=m_array[i].open)
               {
                  m_array[i].position = -1;
                     pChange = -1;
                     pClose  = m_array[i].high;
                               m_array[i].high = high;
                               m_array[i].low  = low;
                               m_array[i].af   = m_step;
                               m_array[i].open = pClose + m_array[i].af*(m_array[i].low-pClose);
                                  if (m_array[i].open<m_array[i  ].ohigh) m_array[i].open = m_array[i  ].ohigh;
                                  if (m_array[i].open<m_array[i-1].ohigh) m_array[i].open = m_array[i-1].ohigh;
               }
               else
               {
                  pClose = m_array[i].open;
                       if (m_array[i].high>m_array[i-1].high && m_array[i].af<m_maximum) m_array[i].af = MathMin(m_array[i].af+m_step,m_maximum);
                           m_array[i].open = pClose + m_array[i].af*(m_array[i].high-pClose);
                               if (m_array[i].open>m_array[i  ].olow) m_array[i].open = m_array[i  ].olow;
                               if (m_array[i].open>m_array[i-1].olow) m_array[i].open = m_array[i-1].olow;
               }
         else
            if (high>=m_array[i].open)
            {
               m_array[i].position = 1;
                  pChange = 1;
                  pClose  = m_array[i].low;
                            m_array[i].low  = low;
                            m_array[i].high = high;
                            m_array[i].af   = m_step;
                            m_array[i].open = pClose + m_array[i].af*(m_array[i].high-pClose);
                               if (m_array[i].open>m_array[i  ].olow) m_array[i].open = m_array[i  ].olow;
                               if (m_array[i].open>m_array[i-1].olow) m_array[i].open = m_array[i-1].olow;
            }
            else
            {
               pClose = m_array[i].open;
               if (m_array[i].low<m_array[i-1].low && m_array[i].af<m_maximum) m_array[i].af = MathMin(m_array[i].af+m_step,m_maximum);
                   m_array[i].open = pClose + m_array[i].af*(m_array[i].low-pClose);
                            if (m_array[i].open<m_array[i  ].ohigh) m_array[i].open = m_array[i  ].ohigh;
                            if (m_array[i].open<m_array[i-1].ohigh) m_array[i].open = m_array[i-1].ohigh;
            }

         //
         //
         //
   
         pOpen     = m_array[i].open;
         pPosition = m_array[i].position;
         return(pClose);
     }
};
CParabolic iParabolic;

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