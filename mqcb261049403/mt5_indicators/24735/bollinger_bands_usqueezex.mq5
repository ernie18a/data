//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   5
#property indicator_label1  "upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'207,243,207'
#property indicator_label2  "lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'252,225,205'
#property indicator_label3  "Upper band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSeaGreen
#property indicator_label4  "Lower band"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_label5  "Average"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrSilver,clrMediumSeaGreen,clrSandyBrown
#property indicator_width5  2

//
//---
//

input int                 inpPeriod        = 20;          // Bollinger bands period
input ENUM_APPLIED_PRICE  inpPrice         = PRICE_CLOSE; // Price
input double              inpDeviations    = 2.0;         // Bollinger bands deviations multiplier
input double              inpAtrMultiplier = 1.5;         // ATR multiplier
input double              inpZonesPercent  = 20;          // Zones percent

//
//---
//

double bufferUp[],bufferDn[],bufferMe[],bufferMec[],fupu[],fupd[],fdnd[],fdnu[],prices[],_bandsFillZone;
int _maHandle;

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
   SetIndexBuffer(0,fupu     ,INDICATOR_DATA);      
   SetIndexBuffer(1,fupd     ,INDICATOR_DATA);
   SetIndexBuffer(2,fdnu     ,INDICATOR_DATA);      
   SetIndexBuffer(3,fdnd     ,INDICATOR_DATA);
   SetIndexBuffer(4,bufferUp ,INDICATOR_DATA);
   SetIndexBuffer(5,bufferDn ,INDICATOR_DATA);
   SetIndexBuffer(6,bufferMe ,INDICATOR_DATA);
   SetIndexBuffer(7,bufferMec,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,prices   ,INDICATOR_CALCULATIONS);
      iBbSqueeze.init(inpPeriod,inpDeviations,inpAtrMultiplier);
      _bandsFillZone = (inpZonesPercent<100 &&  inpZonesPercent>0) ? (1.0-inpZonesPercent/100.0) : 0;
      _maHandle      = iMA(_Symbol,_Period,inpPeriod,0,MODE_SMA,inpPrice); if (!_checkHandle(_maHandle,"Average")) return(INIT_FAILED);
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(_maHandle,0,0,_copyCount,bufferMe)!=_copyCount) return(prev_calculated);

   //
   //---
   //

   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      prices[i] = getPrice(inpPrice,open,high,low,close,i);
      double deviation; 
      double state = iBbSqueeze.calculate(prices,close,high,low,deviation,i,rates_total);
      
      //
      //---
      //

      bufferUp[i] = bufferMe[i]+deviation*inpDeviations;
      bufferDn[i] = bufferMe[i]-deviation*inpDeviations;
      fupd[i]     = (state!=0) ? bufferMe[i]+deviation*inpDeviations*_bandsFillZone : bufferUp[i]; fupu[i] = bufferUp[i]; 
      fdnu[i]     = (state!=0) ? bufferMe[i]-deviation*inpDeviations*_bandsFillZone : bufferDn[i]; fdnd[i] = bufferDn[i]; 
      bufferMec[i] = (state==1) ? 1 : (state==-1) ? 2 : 0;
   }         
   return(i);         
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cSqueeze
{
   private :
      int    m_period;
      int    m_arraySize;
      double m_devMultiplier;
      double m_atrMultiplier;
         struct sSqueezeStruct
         {
            public :
               double price;
               double price2;
               double sum;
               double sum2;
               double tr;
               double sumtr;
         };
      sSqueezeStruct m_array[];
   public:
      cSqueeze() : m_period(1), m_arraySize(-1), m_devMultiplier(2) {                     }
     ~cSqueeze()                                                    { ArrayFree(m_array); }

      ///
      ///
      ///

      void init(int period, double devMultiplier, double atrMultiplier)
      {
         m_period        = (period>1) ? period : 1;
         m_devMultiplier = devMultiplier;
         m_atrMultiplier = atrMultiplier;
      }
      
      template <typename T1,typename T2>
      double calculate(T1& price[], T2& close[], T2& high[], T2& low[], double& devs, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize=ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
         
            m_array[i].price  = price[i];
            m_array[i].price2 = price[i]*price[i];
            m_array[i].tr     = (i>0) ? (close[i-1] < high[i] ? high[i] : close[i-1]) - (close[i-1] > low[i] ? low[i] : close[i-1]) : high[i]-low[i];
            
            //
            //---
            //
            
            if (i>m_period)
            {
               m_array[i].sum   = m_array[i-1].sum  +m_array[i].price -m_array[i-m_period].price;
               m_array[i].sum2  = m_array[i-1].sum2 +m_array[i].price2-m_array[i-m_period].price2;
               m_array[i].sumtr = m_array[i-1].sumtr+m_array[i].tr    -m_array[i-m_period].tr;
            }
            else  
            {
               m_array[i].sum   = m_array[i].price;
               m_array[i].sum2  = m_array[i].price2; 
               m_array[i].sumtr = m_array[i].tr; 
               for(int k=1; k<m_period && i>=k; k++) 
               {
                  m_array[i].sum   += m_array[i-k].price; 
                  m_array[i].sum2  += m_array[i-k].price2; 
                  m_array[i].sumtr += m_array[i-k].tr; 
               }                  
            }       
            devs = MathSqrt((m_array[i].sum2-m_array[i].sum*m_array[i].sum/(double)m_period)/(double)m_period);
            double _atr = m_array[i].sumtr/(double)m_period;
            double _avg = m_array[i].sum  /(double)m_period;
            return ((m_devMultiplier*devs)>(m_atrMultiplier*_atr) ? (high[i]+low[i])/2.0>_avg ? 1 : -1 : 0);
      }
};
cSqueeze iBbSqueeze;

//
//---
//

template <typename T> 
double getPrice(ENUM_APPLIED_PRICE tprice, T& open[], T& high[], T& low[], T& close[], int i)
{
   switch(tprice)
   {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
   }
   return(0);
}

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