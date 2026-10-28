//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   7
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
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkGray
#property indicator_style5  STYLE_DOT
#property indicator_label6  "Break up"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrGreen
#property indicator_label7  "Break down"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrDarkOrange

//
//---
//

enum enDevType
{
   dev_sample,  // Standard deviation of a sample
   dev_regular  // Standard deviation
};
input int                 inpPeriod       = 20;          // Bollinger bands period
input ENUM_APPLIED_PRICE  inpPrice        = PRICE_CLOSE; // Price
input double              inpDeviations   = 2.5;         // Bollinger bands deviations
input double              inpZonesPercent = 20;          // Zones percent
input enDevType           inpDevType      = dev_regular; // Standard deviations type

//
//---
//

double bufferUp[],bufferDn[],bufferMe[],fupu[],fupd[],fdnd[],fdnu[],breakup[],breakdn[],_bandsFillZone;
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
   SetIndexBuffer(0,fupu    ,INDICATOR_DATA);      
   SetIndexBuffer(1,fupd    ,INDICATOR_DATA);
   SetIndexBuffer(2,fdnu    ,INDICATOR_DATA);      
   SetIndexBuffer(3,fdnd    ,INDICATOR_DATA);
   SetIndexBuffer(4,bufferUp,INDICATOR_DATA);
   SetIndexBuffer(5,bufferDn,INDICATOR_DATA);
   SetIndexBuffer(6,bufferMe,INDICATOR_DATA);
   SetIndexBuffer(7,breakup ,INDICATOR_DATA); PlotIndexSetInteger(5,PLOT_ARROW,217); PlotIndexSetInteger(5,PLOT_ARROW_SHIFT,-10); 
   SetIndexBuffer(8,breakdn ,INDICATOR_DATA); PlotIndexSetInteger(6,PLOT_ARROW,218); PlotIndexSetInteger(6,PLOT_ARROW_SHIFT, 10); 
      iStdDeviation.init(inpPeriod,inpDevType==dev_sample);
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

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

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
      double price; _setPrice(inpPrice,price,i);
      double deviation = iStdDeviation.calculate(price,i,rates_total);
      
      //
      //---
      //

      bufferUp[i] = bufferMe[i]+deviation*inpDeviations;
      bufferDn[i] = bufferMe[i]-deviation*inpDeviations;
      fupd[i]     = bufferMe[i]+deviation*inpDeviations*_bandsFillZone; fupu[i] = bufferUp[i]; 
      fdnu[i]     = bufferMe[i]-deviation*inpDeviations*_bandsFillZone; fdnd[i] = bufferDn[i]; 
      breakup[i]  = (close[i]>bufferUp[i]) ? high[i] : EMPTY_VALUE;
      breakdn[i]  = (close[i]<bufferDn[i]) ? low[i]  : EMPTY_VALUE;
   }         
   return(i);         
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cStdDeviation
{
   private :
      int    m_period;
      double m_periodDiv;
      int    m_arraySize;
      bool   m_isSample;
         struct sStdStruct
         {
            double price;
            double price2;
            double sum;
            double sum2;
         };
      sStdStruct m_array[];
   public:
      cStdDeviation() : m_arraySize(-1) {  }
     ~cStdDeviation()                   { ArrayFree(m_array); }

      ///
      ///
      ///

      void init(int period, bool isSample)
      {
         m_period    = (period>1) ? period : 1;
         m_isSample  = isSample;
         m_periodDiv = MathMax(m_period-m_isSample,1);
      }
      
      double calculate(double price, int i, int bars)
      {
         if (m_arraySize<bars) {m_arraySize=ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

            //
            //
            //
            
            m_array[i].price =price;
            m_array[i].price2=price*price;
            
            //
            //---
            //
            
            if (i>m_period)
            {
               m_array[i].sum  = m_array[i-1].sum +m_array[i].price -m_array[i-m_period].price;
               m_array[i].sum2 = m_array[i-1].sum2+m_array[i].price2-m_array[i-m_period].price2;
            }
            else  
            {
               m_array[i].sum  = m_array[i].price;
               m_array[i].sum2 = m_array[i].price2; 
               for(int k=1; k<m_period && i>=k; k++) 
               {
                  m_array[i].sum  += m_array[i-k].price; 
                  m_array[i].sum2 += m_array[i-k].price2; 
               }                  
            }         
            return (MathSqrt((m_array[i].sum2-m_array[i].sum*m_array[i].sum/(double)m_period)/m_periodDiv));
      }
};
cStdDeviation iStdDeviation;

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