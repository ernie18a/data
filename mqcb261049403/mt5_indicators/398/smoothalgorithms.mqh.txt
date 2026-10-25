//MQL5 Version  June 21, 2010 Final
//+------------------------------------------------------------------+
//|                                             SmoothAlgorithms.mqh |
//|                               Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//+------------------------------------------------------------------+
//|  Classes for averaging of prices series                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  Functional utilities for the classes of averaging algorithms    |
//+------------------------------------------------------------------+
class CMovSeriesTools
  {
public:
   void              MALengthCheck(string LengthName,int    ExternLength);
   void              MALengthCheck(string LengthName,double ExternLength);

protected:
   bool              BarCheck1(int begin,int bar,bool Set);
   bool              BarCheck2(int begin,int bar,bool Set,int Length);
   bool              BarCheck3(int begin,int bar,bool Set,int Length);

   bool              BarCheck4(int rates_total,int bar,bool Set);
   bool              BarCheck5(int rates_total,int bar,bool Set);
   bool              BarCheck6(int rates_total,int bar,bool Set);

   void              LengthCheck(int    &ExternLength);
   void              LengthCheck(double &ExternLength);

   void              Recount_ArrayZeroPos(int &count,
                                          int Length,
                                          int prev_calculated,
                                          double series,
                                          int bar,
                                          double &Array[]
                                          );

   int               Recount_ArrayNumber(int count,int Length,int Number);

   bool              SeriesArrayResize(string FunctionsName,
                                       int Length,
                                       double &Array[],
                                       int &Size_
                                       );

   bool              ArrayResizeErrorPrint(string FunctionsName,int &Size_);
  };
//+------------------------------------------------------------------+
//|  The function for the classic averaging of price series          |
//+------------------------------------------------------------------+
class CMoving_Average : public CMovSeriesTools
  {
public:
   double            MASeries(uint begin,              // Number of beginning of bars for reliable calculation
                              uint prev_calculated,    // Amount of history in bars at previous tick
                              uint rates_total,        // Amount of history in bars at the current tick
                              int Length,              // Period of averaging
                              ENUM_MA_METHOD MA_Method,// Method of averaging (MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA)
                              double series,           // Value of the price series calculated for the new bar with number 'bar'
                              uint bar,                // Bar number
                              bool set                 // Direction of indexing arrays.
                              );

   double            SMASeries(uint begin,             // Number of beginning of bars for reliable calculation
                               uint prev_calculated,   // Amount of history in bars at previous tick
                               uint rates_total,       // Amount of history in bars at the current tick
                               int Length,             // Period of averaging
                               double series,          // Value of the price series calculated for the new bar with number 'bar'
                               uint bar,               // Bar number
                               bool set                // Direction of indexing arrays.
                               );

   double            EMASeries(uint begin,             // Number of beginning of bars for reliable calculation
                               uint prev_calculated,   // Amount of history in bars at previous tick
                               uint rates_total,       // Amount of history in bars at the current tick
                               double Length,          // Period of averaging
                               double series,          // Value of the price series calculated for the new bar with number 'bar'
                               uint bar,               // Bar number
                               bool set                // Direction of indexing arrays.
                               );

   double            SMMASeries(uint begin,            // Number of beginning of bars for reliable calculation
                                uint prev_calculated,  // Amount of history in bars at previous tick
                                uint rates_total,      // Amount of history in bars at the current tick
                                int Length,            // Period of averaging
                                double series,         // Value of the price series calculated for the new bar with number 'bar'
                                uint bar,              // Bar number
                                bool set               // Direction of indexing arrays.
                                );

   double            LWMASeries(uint begin,            // Number of beginning of bars for reliable calculation
                                uint prev_calculated,  // Amount of history in bars at previous tick
                                uint rates_total,      // Amount of history in bars at the current tick
                                int Length,            // Period of averaging
                                double series,         // Value of the price series calculated for the new bar with number 'bar'
                                uint bar,              // Bar number
                                bool set               // Direction of indexing arrays.
                                );

protected:
   double            m_SeriesArray[];
   int               m_Size_,m_count,m_weight;
   double            m_Moving,m_MOVING,m_Pr;
   double            m_sum,m_SUM,m_lsum,m_LSUM;
  };
//+------------------------------------------------------------------+
//|  The algorithm of getting the standard deviation                 |
//+------------------------------------------------------------------+
class CStdDeviation : public CMovSeriesTools
  {
public:
   double            StdDevSeries(uint begin,            // Number of beginning of bars for reliable calculation
                                  uint prev_calculated,  // Amount of history in bars at previous tick
                                  uint rates_total,      // Amount of history in bars at the current tick
                                  int Length,            // Period of averaging
                                  double deviation,      // Deviation
                                  double series,         // Value of the price series calculated for the new bar with number 'bar'
                                  double MovSeries,      // Value of a moving average, on which basis the StdDeviation is calculated
                                  uint bar,              // Bar number
                                  bool set               // Direction of indexing arrays.
                                  );
protected:
   int               m_Size_,m_count;
   double            m_Sum,m_SUM,m_Sum2,m_SUM2;
   double            m_SeriesArray[];
  };
//+------------------------------------------------------------------+
//| The JMA algorithm of averaging of price series                   |
//+------------------------------------------------------------------+
class CJJMA : public CMovSeriesTools
  {
public:
   double            JJMASeries(uint begin,              // Number of beginning of bars for reliable calculation
                                uint prev_calculated,    // Amount of history in bars at previous tick
                                uint rates_total,        // Amount of history in bars at the current tick
                                int  Din,                // Permission to change the parameters Length and Phase at every bar. 
                                // 0 - prohibition to change the parameters, any other values means permission.
                                double Phase,            // Parameter that can change within the range -100 ... +100, it depends on the quality of intermediate process of averaging
                                double Length,           // Depth of smoothing
                                double series,           // Value of the price series calculated for the new bar with number 'bar'
                                uint bar,                // Bar number
                                bool set                 // Direction of indexing arrays.
                                );

   void              JJMALengthCheck(string LengthName,int ExternLength);
   void              JJMAPhaseCheck(string PhaseName,int ExternPhase);

protected:
   void              JJMAInit(uint begin,int Din,double Phase,double Length,double series,uint bar);

   //---- Declaration of global variables
   bool              m_start;
   //----
   double            m_array[62];
   //----
   double            m_degree,m_Phase,m_sense;
   double            m_Krx,m_Kfd,m_Krj,m_Kct;
   double            m_var1,m_var2;
   //----
   int               m_pos2,m_pos1;
   int               m_Loop1,m_Loop2;
   int               m_midd1,m_midd2;
   int               m_count1,m_count2,m_count3;
   //----
   double            m_ser1,m_ser2;
   double            m_Sum1,m_Sum2,m_JMA;
   double            m_storage1,m_storage2,m_djma;
   double            m_hoop1[128],m_hoop2[11],m_data[128];

   //---- Variables for restoring calculations of an unclosed bar
   int               m_pos2_,m_pos1_;
   int               m_Loop1_,m_Loop2_;
   int               m_midd1_,m_midd2_;
   int               m_count1_,m_count2_,m_count3_;
   //----
   double            m_ser1_,m_ser2_;
   double            m_Sum1_,m_Sum2_,m_JMA_;
   double            m_storage1_,m_storage2_,m_djma_;
   double            m_hoop1_[128],m_hoop2_[11],m_data_[128];
   //----
   bool              m_bhoop1[128],m_bhoop2[11],m_bdata[128];
  };
//+------------------------------------------------------------------+
//| The Tilson's algorithm of averaging of price series              |
//+------------------------------------------------------------------+
class CT3 : public CMovSeriesTools
  {
public:
   double            T3Series(uint begin,             // Number of beginning of bars for reliable calculation
                              uint prev_calculated,   // Amount of history in bars at previous tick
                              uint rates_total,       // Amount of history in bars at the current tick
                              int  Din,               // Permission to change the parameter Length at every bar. 
                              // 0 - prohibition to change the parameters, any other values means permission.
                              double Curvature,       // Coefficient (its value is increased 100 times for convenience!)
                              double Length,          // Depth of smoothing
                              double series,          // Value of the price series calculated for the new bar with number 'bar'
                              uint bar,               // Bar number
                              bool set                // Direction of indexing arrays.
                              );
protected:
   void              T3Init(uint begin,
                            int Din,
                            double Curvature,
                            double Length,
                            double series,
                            uint bar
                            );

   //---- Declaration of global variables
   double            m_b2,m_b3;
   //----
   double            m_e1,m_e2,m_e3,m_e4,m_e5,m_e6;
   double            m_E1,m_E2,m_E3,m_E4,m_E5,m_E6;
   double            m_c1,m_c2,m_c3,m_c4,m_w1,m_w2;
  };
//+------------------------------------------------------------------+
//| The algorithm of ultralinear averaging of price series           |
//+------------------------------------------------------------------+
class CJurX : public CMovSeriesTools
  {
public:
   double            JurXSeries(uint begin,            // Number of beginning of bars for reliable calculation
                                uint prev_calculated,  // Amount of history in bars at previous tick
                                uint rates_total,      // Amount of history in bars at the current tick
                                int  Din,              // Permission to change the parameter Length at every bar. 
                                // 0 - prohibition to change the parameters, any other values means permission.
                                double Length,         // Depth of smoothing
                                double series,         // Value of the price series calculated for the new bar with number 'bar'
                                uint bar,              // Bar number
                                bool set               // Direction of indexing arrays.
                                );
protected:
   void              JurXInit(uint begin,
                              int Din,
                              double Length,
                              double series,
                              uint bar
                              );

   //---- Declaration of global variables
   double            m_AB,m_AC;
   double            m_f1,m_f2,m_f3,m_f4,m_f5;
   double            m_f6,m_Kg,m_Hg,m_F1,m_F2;
   double            m_F3,m_F4,m_F5,m_F6,m_w;
  };
//+------------------------------------------------------------------+
//| Tushar Chande's algorithms of averaging for any prices series    |
//+------------------------------------------------------------------+
class CCMO : public CMovSeriesTools
  {
public:
   double            VIDYASeries(uint begin,           // Number of beginning of bars for reliable calculation
                                 uint prev_calculated, // Amount of history in bars at the previous tick
                                 uint rates_total,     // Amount of history in bars at the current tick
                                 int CMO_Length,       // CMO period
                                 double EMA_Length,
                                 double series,        // Value of the price series calculated for the new bar with number 'bar'
                                 uint bar,             // Bar number
                                 bool set              // Direction of indexing arrays.
                                 );

   double            CMOSeries(uint begin,             // Number of beginning of bars for reliable calculation
                               uint prev_calculated,   // Amount of history in bars at the previous tick
                               uint rates_total,       // Amount of history in bars at the current tick
                               int CMO_Length,         // CMO period
                               double series,
                               uint bar,               // Bar number
                               bool set                // Direction of indexing arrays.
                               );

protected:
   double            m_dSeriesArray[];
   int               m_Size_,m_count;
   double            m_UpSum_,m_UpSum,m_DnSum_,m_DnSum,m_Vidya,m_Vidya_;
   double            m_AbsCMO_,m_AbsCMO,m_series1,m_series1_,m_SmoothFactor;
  };
//+------------------------------------------------------------------+
//| The algorithm of getting the AMA indicator calculated on the basis of optional price series  |
//+------------------------------------------------------------------+
class CAMA : public CMovSeriesTools
  {
public:
   double            AMASeries(uint begin,            // Number of beginning of bars for reliable calculation
                               uint prev_calculated,  // Amount of history in bars at previous tick
                               uint rates_total,      // Amount of history in bars at the current tick
                               int Length,            // AMA period
                               int Fast_Length,       // Period of fast moving average
                               int Slow_Length,       // Period of slow moving average
                               double Rate,           // Rate of the smoothing constant
                               double series,         // Value of the price series calculated for the new bar with number 'bar'
                               uint bar,              // Bar number
                               bool set               // Direction of indexing arrays.
                               );
protected:
   //----  
   double            m_SeriesArray[];
   double            m_dSeriesArray[];
   double            m_NOISE,m_noise;
   double            m_Ama,m_AMA_,m_slowSC,m_fastSC,m_dSC;
   int               m_Size_1,m_Size_2,m_count;
  };
//+------------------------------------------------------------------+
//| The algorithm of parabolic averaging of price series             |
//+------------------------------------------------------------------+
class CParMA : public CMovSeriesTools
  {
public:
   double            ParMASeries(uint begin,           // Number of beginning of bars for reliable calculation
                                 uint prev_calculated, // Amount of history in bars at the previous tick
                                 uint rates_total,     // Amount of history in bars at the current tick
                                 int Length,           // Period of averaging
                                 double series,        // Value of the price series calculated for the new bar with number 'bar'
                                 uint bar,             // Bar number
                                 bool set              // Direction of indexing arrays.
                                 );
protected:
   void              ParMAInit(double Length);

   double            m_SeriesArray[];
   int               m_Size_,m_count;
   int               m_sum_x,m_sum_x2,m_sum_x3,m_sum_x4;
  };
//+------------------------------------------------------------------+
//| The momentum algorithm (Murphy's version!) of averaging price series |
//+------------------------------------------------------------------+
class CMomentum : public CMovSeriesTools
  {
public:
   double            MomentumSeries(uint begin,           // Number of beginning of bars for reliable calculation
                                    uint prev_calculated, // Amount of history in bars at the previous tick
                                    uint rates_total,     // Amount of history in bars at the current tick
                                    int Length,           // Period of averaging
                                    double series,        // Value of the price series calculated for the new bar with number 'bar'
                                    uint bar,             // Bar number
                                    bool set              // Direction of indexing arrays.
                                    );
protected:

   double            m_SeriesArray[];
   int               m_Size_,m_count;
  };
//+------------------------------------------------------------------+
//| The algorithm of normalized momentum calculated on price series  |
//+------------------------------------------------------------------+
class CnMomentum : public CMovSeriesTools
  {
public:
   double            nMomentumSeries(uint begin,            // Number of beginning of bars for reliable calculation
                                     uint prev_calculated,  // Amount of history in bars at previous tick
                                     uint rates_total,      // Amount of history in bars at the current tick
                                     int Length,            // Period of averaging
                                     double series,         // Value of the price series calculated for the new bar with number 'bar'
                                     uint bar,              // Bar number
                                     bool set               // Direction of indexing arrays.
                                     );
protected:

   double            m_SeriesArray[];
   int               m_Size_,m_count;
  };
//+------------------------------------------------------------------+
//| The algorithm Speed of changing of price series                  |
//+------------------------------------------------------------------+
class CROC : public CMovSeriesTools
  {
public:
   double            ROCSeries(uint begin,            // Number of beginning of bars for reliable calculation
                               uint prev_calculated,  // Amount of history in bars at previous tick
                               uint rates_total,      // Amount of history in bars at the current tick
                               int Length,            // Period of averaging
                               double series,         // Value of the price series calculated for the new bar with number 'bar'
                               uint bar,              // Bar number
                               bool set               // Direction of indexing arrays.
                               );
protected:

   double            m_SeriesArray[];
   int               m_Size_,m_count;
  };
//Version  May 1, 2010
//+------------------------------------------------------------------+
//|                                                 iPriceSeries.mqh |
//|                        Copyright © 2010,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
/* 
 * The function iPriceSeries() returns the input price of a bar by its number
 * bar and by the number of the price 'applied_price':
 * 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 5-MEDIAN, 6-TYPICAL, 7-WEIGHTED,
 * 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.
 * 
 * Example: 
 * double dPrice = iPriceSeries("GBPJPY", 240, 5, bar, true)
 *                - iPriceSeries("GBPJPY", 240, 5, bar + 1, true);
 */
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
/*
//---- declaration and initialization of the enumeration of type of price constants
enum Applied_price_ //Type of constant
 {
  PRICE_CLOSE_ = 1,     // 1
  PRICE_OPEN_,          // 2
  PRICE_HIGH_,          // 3
  PRICE_LOW_,           // 4
  PRICE_MEDIAN_,        // 5
  PRICE_TYPICAL_,       // 6
  PRICE_WEIGHTED_,      // 7
  PRICE_SIMPLE_,        // 8
  PRICE_QUARTER_,       // 9
  PRICE_TRENDFOLLOW0_,  // 10
  PRICE_TRENDFOLLOW1_   // 11
 };
*/
//+------------------------------------------------------------------+   
//| PriceSeries() function                                           |
//+------------------------------------------------------------------+ 
double PriceSeries
(
 uint applied_price,// Price constant
 uint   bar,        // Index of shift relative to the current bar for a specified number of periods back or forward).
 const double &Open[],
 const double &Low[],
 const double &High[],
 const double &Close[]
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Price constant from the enumeration ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+   
//| iPriceSeries() function                                          |
//+------------------------------------------------------------------+ 
double iPriceSeries
(
 string          symbol,        // Symbol name. NULL means current symbol.
 ENUM_TIMEFRAMES timeframe,     // Period. Can be one of the chart periods. 0 means period of the current chart.
 uint            applied_price, // Price constant
 uint            bar,           // Index of shift relative to the current bar for a specified number of periods back or forward).
 bool            set            // Direction of indexing arrays.
 )
//iPriceSeries(symbol, timeframe, applied_price, bar, set)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   uint Bar;
   double diPriceSeries,price[1];
//----
   if(!set)
      Bar=Bars(symbol,timeframe)-1-bar;
   else Bar=bar;
//----
   switch(applied_price)
     {
      case  1: CopyClose(symbol, timeframe, Bar, 1, price); diPriceSeries = price[0]; break;
      case  2: CopyOpen (symbol, timeframe, Bar, 1, price); diPriceSeries = price[0]; break;
      case  3: CopyHigh (symbol, timeframe, Bar, 1, price); diPriceSeries = price[0]; break;
      case  4: CopyLow  (symbol, timeframe, Bar, 1, price); diPriceSeries = price[0]; break;
      //----
      case  5: CopyHigh(symbol,timeframe,Bar,1,price); diPriceSeries=price[0];
      CopyLow(symbol,timeframe,Bar,1,price); diPriceSeries+=price[0];
      diPriceSeries/=2.0;
      break;
      //----
      case  6: CopyClose(symbol,timeframe,Bar,1,price); diPriceSeries=price[0];
      CopyHigh (symbol, timeframe, Bar, 1, price); diPriceSeries += price[0];
      CopyLow  (symbol, timeframe, Bar, 1, price); diPriceSeries += price[0];
      diPriceSeries/=3.0;
      break;
      //----                                                                  
      case  7: CopyClose(symbol,timeframe,Bar,1,price); diPriceSeries=price[0]*2;
      CopyHigh (symbol, timeframe, Bar, 1, price); diPriceSeries += price[0];
      CopyLow  (symbol, timeframe, Bar, 1, price); diPriceSeries += price[0];
      diPriceSeries/=4.0;
      break;

      //----                                 
      case  8: CopyClose(symbol,timeframe,Bar,1,price); diPriceSeries=price[0];
      CopyOpen(symbol,timeframe,Bar,1,price); diPriceSeries+=price[0];
      diPriceSeries/=2.0;
      break;
      //----
      case  9: CopyClose(symbol,timeframe,Bar,1,price); diPriceSeries=price[0];
      CopyOpen (symbol, timeframe, Bar, 1, price); diPriceSeries += price[0];
      CopyHigh (symbol, timeframe, Bar, 1, price); diPriceSeries += price[0];
      CopyLow  (symbol, timeframe, Bar, 1, price); diPriceSeries += price[0];
      diPriceSeries/=4.0;
      break;
      //----                                
      case 10:
        {
         double Open_[1],Low_[1],High_[1],Close_[1];
         //----
         CopyClose(symbol,timeframe,Bar,1,Close_);
         CopyOpen(symbol,timeframe,Bar,1,Open_);
         CopyHigh(symbol,timeframe,Bar,1,High_);
         CopyLow(symbol,timeframe,Bar,1,Low_);
         //----
         if(Close_[0]>Open_[0])diPriceSeries=High_[0];
         else
           {
            if(Close_[0]<Open_[0])
               diPriceSeries=Low_[0];
            else diPriceSeries=Close_[0];
           }
         break;
        }
      //----         
      case 11:
        {
         double Open_[1],Low_[1],High_[1],Close_[1];
         //----
         CopyClose(symbol,timeframe,Bar,1,Close_);
         CopyOpen(symbol,timeframe,Bar,1,Open_);
         CopyHigh(symbol,timeframe,Bar,1,High_);
         CopyLow(symbol,timeframe,Bar,1,Low_);
         //----
         if(Close_[0]>Open_[0])diPriceSeries=(High_[0]+Close_[0])/2.0;
         else
           {
            if(Close_[0]<Open_[0])
               diPriceSeries=(Low_[0]+Close_[0])/2.0;
            else diPriceSeries=Close_[0];
           }
         break;
        }
      //----
      default: CopyClose(symbol,timeframe,Bar,1,price); diPriceSeries=price[0]; break;
     }
//----
   return(diPriceSeries);
  }
//+------------------------------------------------------------------+   
//| bPriceSeries() function                                          |
//+------------------------------------------------------------------+ 
bool bPriceSeries
(
 string          symbol,        // Symbol name. NULL means current symbol.
 ENUM_TIMEFRAMES timeframe,     // Period. Can be one of the chart periods. 0 means period of the current chart.
 int             rates_total,   // mount of history in bars at the current tick (if the parameter 'set' is equal to 'true', 
 // then value of the parameter is not needed in the function calculation and can be equal to 0)
 uint            applied_price, // Price constant
 uint            bar,           // Index of shift relative to the current bar for a specified number of periods back or forward).
 bool            set,           // Direction of indexing arrays.
 double         &Price_         // Return the obtained value by the link
 )
//bPriceSeries(symbol, timeframe, int rates_total, applied_price, bar, set, Price_)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   uint Bar;
   double series[1];
   ArraySetAsSeries(series,true);
//----
   if(!set)
      Bar=rates_total-1-bar;
   else Bar=bar;
//----
   switch(applied_price)
     {
      case  1: if(CopyClose(symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ = series[0]; break;
      case  2: if(CopyOpen (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ = series[0]; break;
      case  3: if(CopyHigh (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ = series[0]; break;
      case  4: if(CopyLow  (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ = series[0]; break;
      //----
      case  5: if(CopyHigh(symbol,timeframe,Bar,1,series)<0) return(false); Price_=series[0];
      if(CopyLow(symbol,timeframe,Bar,1,series)<0) return(false); Price_+=series[0];
      Price_/=2.0;
      break;
      //----
      case  6: if(CopyClose(symbol,timeframe,Bar,1,series)<0) return(false); Price_=series[0];
      if(CopyHigh (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ += series[0];
      if(CopyLow  (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ += series[0];
      Price_/=3.0;
      break;
      //----                                                                  
      case  7: if(CopyClose(symbol,timeframe,Bar,1,series)<0) return(false); Price_=series[0]*2;
      if(CopyHigh (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ += series[0];
      if(CopyLow  (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ += series[0];
      Price_/=4.0;
      break;

      //----                                 
      case  8: if(CopyClose(symbol,timeframe,Bar,1,series)<0) return(false); Price_=series[0];
      if(CopyOpen(symbol,timeframe,Bar,1,series)<0) return(false); Price_+=series[0];
      Price_/=2.0;
      break;
      //----
      case  9: if(CopyClose(symbol,timeframe,Bar,1,series)<0) return(false); Price_=series[0];
      if(CopyOpen (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ += series[0];
      if(CopyHigh (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ += series[0];
      if(CopyLow  (symbol, timeframe, Bar, 1, series) < 0) return(false); Price_ += series[0];
      Price_/=4.0;
      break;
      //----                                
      case 10:
        {
         double Open_[1],Low_[1],High_[1],Close_[1];
         //----
         if(CopyClose(symbol, timeframe, Bar, 1, Close_) < 0) return(false);
         if(CopyOpen (symbol, timeframe, Bar, 1, Open_ ) < 0) return(false);
         if(CopyHigh (symbol, timeframe, Bar, 1, High_ ) < 0) return(false);
         if(CopyLow  (symbol, timeframe, Bar, 1, Low_  ) < 0) return(false);
         //----
         if(Close_[0]>Open_[0])Price_=High_[0];
         else
           {
            if(Close_[0]<Open_[0])
               Price_=Low_[0];
            else Price_=Close_[0];
           }
         break;
        }
      //----         
      case 11:
        {
         double Open_[1],Low_[1],High_[1],Close_[1];
         //----
         if(CopyClose(symbol, timeframe, Bar, 1, Close_) < 0) return(false);
         if(CopyOpen (symbol, timeframe, Bar, 1, Open_ ) < 0) return(false);
         if(CopyHigh (symbol, timeframe, Bar, 1, High_ ) < 0) return(false);
         if(CopyLow  (symbol, timeframe, Bar, 1, Low_  ) < 0) return(false);
         //----
         if(Close_[0]>Open_[0])Price_=(High_[0]+Close_[0])/2.0;
         else
           {
            if(Close_[0]<Open_[0])
               Price_=(Low_[0]+Close_[0])/2.0;
            else Price_=Close_[0];
           }
         break;
        }
      //----
      default: if(CopyClose(symbol,timeframe,Bar,1,series)<0) return(false); Price_=series[0]; break;
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+   
//| bPriceSeriesOnArray() function                                   |
//+------------------------------------------------------------------+ 
bool bPriceSeriesOnArray
(
 string          symbol,        // Symbol name. NULL means current symbol.
 ENUM_TIMEFRAMES timeframe,     // Period. Can be one of the chart periods. 0 means period of the current chart.
 uint            applied_price, // Price constant
 int             start_pos,     // Number of the first copied element
 int             count,         // Number of the elements to be copied
 double         &series[]       // Array, to which the information is copied
 )
//bPriceSeriesOnArray(symbol, timeframe, applied_price, start_pos, count, Array)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   ArraySetAsSeries(series,true);

   switch(applied_price)
     {
      case  1: if(CopyClose(symbol, timeframe, start_pos, count, series) < 0) return(false); break;
      case  2: if(CopyOpen (symbol, timeframe, start_pos, count, series) < 0) return(false); break;
      case  3: if(CopyHigh (symbol, timeframe, start_pos, count, series) < 0) return(false); break;
      case  4: if(CopyLow  (symbol, timeframe, start_pos, count, series) < 0) return(false); break;
      //----
      case  5:
        {
         double Low_[];
         ArraySetAsSeries(Low_,true);
         if(CopyHigh(symbol, timeframe, start_pos, count, series) < 0) return(false);
         if(CopyLow (symbol, timeframe, start_pos, count,  Low_ ) < 0) return(false);

         for(int kkk=start_pos; kkk<start_pos+count; kkk++)
            series[kkk]=(series[kkk]+Low_[kkk])/2.0;
         break;
        }
      //----
      case  6:
        {
         double Low_[],High_[];
         ArraySetAsSeries(Low_,true);
         ArraySetAsSeries(High_,true);
         if(CopyClose(symbol, timeframe, start_pos, count, series) < 0) return(false);
         if(CopyHigh (symbol, timeframe, start_pos, count, High_ ) < 0) return(false);
         if(CopyLow  (symbol, timeframe, start_pos, count, Low_  ) < 0) return(false);

         for(int kkk=start_pos; kkk<start_pos+count; kkk++)
            series[kkk]=(series[kkk]+High_[kkk]+Low_[kkk])/3.0;
         break;
        }
      //----                                                                  
      case  7:
        {
         double Low_[],High_[];
         ArraySetAsSeries(Low_,true);
         ArraySetAsSeries(High_,true);
         if(CopyClose(symbol, timeframe, start_pos, count, series) < 0) return(false);
         if(CopyHigh (symbol, timeframe, start_pos, count, High_ ) < 0) return(false);
         if(CopyLow  (symbol, timeframe, start_pos, count, Low_  ) < 0) return(false);

         for(int kkk=start_pos; kkk<start_pos+count; kkk++)
            series[kkk]=(2*series[kkk]+High_[kkk]+Low_[kkk])/4.0;
         break;
        }
      //----                                 
      case  8:
        {
         double Open_[];
         ArraySetAsSeries(Open_,true);
         if(CopyClose(symbol, timeframe, start_pos, count, series) < 0) return(false);
         if(CopyOpen (symbol, timeframe, start_pos, count, Open_ ) < 0) return(false);

         for(int kkk=start_pos; kkk<start_pos+count; kkk++)
            series[kkk]=(series[kkk]+Open_[kkk])/2.0;
         break;
        }
      //----
      case  9:
        {
         double Open_[],Low_[],High_[];
         ArraySetAsSeries(Open_,true);
         ArraySetAsSeries(Low_,true);
         ArraySetAsSeries(High_,true);
         if(CopyOpen (symbol, timeframe, start_pos, count, Open_ ) < 0) return(false);
         if(CopyClose(symbol, timeframe, start_pos, count, series) < 0) return(false);
         if(CopyHigh (symbol, timeframe, start_pos, count, High_ ) < 0) return(false);
         if(CopyLow  (symbol, timeframe, start_pos, count, Low_  ) < 0) return(false);

         for(int kkk=start_pos; kkk<start_pos+count; kkk++)
            series[kkk]=(Open_[kkk]+series[kkk]+High_[kkk]+Low_[kkk])/4.0;
         break;
        }
      //----                                
      case 10:
        {
         double Open_[],Low_[],High_[];
         ArraySetAsSeries(Open_,true);
         ArraySetAsSeries(Low_,true);
         ArraySetAsSeries(High_,true);
         if(CopyClose(symbol, timeframe, start_pos, count, series) < 0) return(false);
         if(CopyOpen (symbol, timeframe, start_pos, count, Open_ ) < 0) return(false);
         if(CopyHigh (symbol, timeframe, start_pos, count, High_ ) < 0) return(false);
         if(CopyLow  (symbol, timeframe, start_pos, count, Low_  ) < 0) return(false);
         //----
         for(int kkk=start_pos; kkk<start_pos+count; kkk++)
           {
            if(series[kkk]>Open_[kkk]) series[kkk]=High_[kkk];
            else
              {
               if(series[kkk]<Open_[kkk])
                  series[kkk]=Low_[kkk];
              }
           }
         break;
        }
      //----         
      case 11:
        {
         double Open_[],Low_[],High_[];
         ArraySetAsSeries(Open_,true);
         ArraySetAsSeries(Low_,true);
         ArraySetAsSeries(High_,true);
         if(CopyClose(symbol, timeframe, start_pos, count, series) < 0) return(false);
         if(CopyOpen (symbol, timeframe, start_pos, count, Open_ ) < 0) return(false);
         if(CopyHigh (symbol, timeframe, start_pos, count, High_ ) < 0) return(false);
         if(CopyLow  (symbol, timeframe, start_pos, count, Low_  ) < 0) return(false);
         //----
         for(int kkk=start_pos; kkk<start_pos+count; kkk++)
           {
            if(series[kkk]>Open_[kkk]) series[kkk]=(High_[kkk]+series[kkk])/2.0;
            else
              {
               if(series[kkk]<Open_[kkk])
                  series[kkk]=(Low_[kkk]+series[kkk])/2.0;
              }
           }
         break;
        }
      //----
      default: if(CopyClose(symbol,timeframe,start_pos,count,series)<0) return(false);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+   
//| iPriceSeriesAlert() function                                     |
//+------------------------------------------------------------------+
/*
 * iPriceSeriesAlert() function is intended for indicating an unacceptable 
 * value of the parameter applied_price passed to the function iPriceSeries().
 */
void iPriceSeriesAlert(uchar applied_price)
  {
//----
   if(applied_price<1)
      Alert("Parameter applied_price must less than 1. You specified incorrect value",
            applied_price," value 1 will be used");
//----                     
   if(applied_price>11)
      Alert("The parameter applied_price must not exceed 11. You specified incorrect value",
            applied_price," value 1 will be used");
//---- 
  }
//+------------------------------------------------------------------+
//|  The classic algorithms of averaging                               |
//+------------------------------------------------------------------+    
double CMoving_Average::MASeries
(
 uint begin,               // Number of beginning of bars for reliable calculation
 uint prev_calculated,     // Amount of history in bars at previous tick
 uint rates_total,         // Amount of history in bars at the current tick
 int Length,               // Period of averaging
 ENUM_MA_METHOD MA_Method, // Method of averaging (MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA)
 double series,            // Value of the price series calculated for the new bar with number 'bar'
 uint bar,                 // Bar number
 bool set                  // Direction of indexing arrays.
 )
// MASeries(begin, prev_calculated, Length, MA_Method, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----   
   switch(MA_Method)
     {
      case MODE_SMA:  return(SMASeries (begin, prev_calculated, rates_total, Length, series, bar, set));
      case MODE_EMA:  return(EMASeries (begin, prev_calculated, rates_total, Length, series, bar, set));
      case MODE_SMMA: return(SMMASeries(begin, prev_calculated, rates_total, Length, series, bar, set));
      case MODE_LWMA: return(LWMASeries(begin, prev_calculated, rates_total, Length, series, bar, set));
      default:
        {
         if(bar==begin)
           {
            string word;
            StringConcatenate(word,__FUNCTION__,"():",
                              " The parameter MA_Method must be within the range from MODE_SMA to MODE_LWMA.",
                              " You specified unacceptable value ",MA_Method," value MODE_SMA will be used!");
            Print(word);
           }
         return(SMASeries(begin,prev_calculated,rates_total,Length,series,bar,set));
        }
     }
//----
  }
//+------------------------------------------------------------------+
//|  Simple averaging                                              |
//+------------------------------------------------------------------+    
double CMoving_Average::SMASeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int Length,           // Period of averaging
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays
 )
// SMASeries(begin, prev_calculated, rates_total, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   int iii,kkk;
   double sma;

//---- Checking for correctness the external parameter Length
   LengthCheck(Length);

//---- Changing the size of the array of variables
   if(bar==begin && !SeriesArrayResize(__FUNCTION__,Length,m_SeriesArray,m_Size_))
      return(EMPTY_VALUE);

//---- Rearrangement and initialization of cells of the array m_SeriesArray
   Recount_ArrayZeroPos(m_count,Length,prev_calculated,series,bar,m_SeriesArray);

//---- Initialization of zero
   if(BarCheck2(begin,bar,set,Length))
     {
      m_sum=0.0;

      for(iii=1; iii<Length; iii++)
        {
         kkk=Recount_ArrayNumber(m_count,Length,iii);
         m_sum+=m_SeriesArray[kkk];
        }
     }
   else if(BarCheck3(begin,bar,set,Length)) return(EMPTY_VALUE);

//---- Calculation of SMA
   m_sum+=series;
   sma = m_sum / Length;
   kkk = Recount_ArrayNumber(m_count, Length, Length - 1);
   m_sum-=m_SeriesArray[kkk];

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_SUM=m_sum;
     }

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_sum=m_SUM;
     }
//----
   return(sma);
  }
//+------------------------------------------------------------------+
//|  Exponential averaging                                           |
//+------------------------------------------------------------------+    
double CMoving_Average::EMASeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 double Length,        // Period of averaging
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays
 )
// EMASeries(begin, prev_calculated, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   double ema;

//---- Checking for correctness of the external parameter Length
   LengthCheck(Length);

//---- Initialization of zero
   if(bar==begin)
     {
      m_Pr=2.0/(Length+1.0);
      m_Moving=series;
     }

//---- Calculation of EMA 
   m_Moving=series*m_Pr+m_Moving *(1-m_Pr);
   ema=m_Moving;

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_MOVING=m_Moving;
     }

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_Moving=m_MOVING;
     }
//----
   return(ema);
  }
//+------------------------------------------------------------------+
//|  Smoothed averaging                                              |
//+------------------------------------------------------------------+
double CMoving_Average::SMMASeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int Length,           // Period of averaging
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays
 )
// SMMASeries(begin, prev_calculated, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   int iii;
   double smma;

//---- Checking for correctness of the external parameter Length
   LengthCheck(Length);

//---- Changing the size of array of variables
   if(bar==begin && !SeriesArrayResize(__FUNCTION__,Length,m_SeriesArray,m_Size_))
      return(EMPTY_VALUE);

//---- Rearrangement and initialization of cells of the array m_SeriesArray
   Recount_ArrayZeroPos(m_count,Length,prev_calculated,series,bar,m_SeriesArray);

//---- Initialization of zero
   if(BarCheck2(begin,bar,set,Length))
     {
      m_sum=0.0;
      for(iii=0; iii<Length; iii++)
         m_sum+=m_SeriesArray[iii];

      m_Moving=(m_sum-series)/(Length-1);
     }
   else if(BarCheck3(begin,bar,set,Length)) return(EMPTY_VALUE);

//---- Calculation of SMMA
   m_sum=m_Moving *(Length-1)+series;
   m_Moving=m_sum/Length;
   smma=m_Moving;

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_SUM=m_sum;
      m_MOVING=m_Moving;
     }

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_sum=m_SUM;
      m_Moving=m_MOVING;
     }
//----
   return(smma);
  }
//+------------------------------------------------------------------+
//|  Linear weighted averaging                                       |
//+------------------------------------------------------------------+
double CMoving_Average::LWMASeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int Length,           // Period of averaging
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays
 )
// LWMASeries(begin, prev_calculated, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   double lwma;
   int iii,kkk,Length_=Length+1;

//---- Checking for correctness of the external parameter Length
   LengthCheck(Length);

//---- Changing the size of array of variables
   if(bar==begin && !SeriesArrayResize(__FUNCTION__,Length_,m_SeriesArray,m_Size_))
      return(EMPTY_VALUE);

//---- Rearrangement and initialization of cells of the array m_SeriesArray
   Recount_ArrayZeroPos(m_count,Length_,prev_calculated,series,bar,m_SeriesArray);

//---- Initialization of zero
   if(BarCheck2(begin,bar,set,Length_))
     {
      m_sum=0.0;
      m_lsum=0.0;
      m_weight=0;
      int rrr=Length;

      for(iii=1; iii<=Length; iii++,rrr--)
        {
         kkk=Recount_ArrayNumber(m_count,Length_,iii);
         m_sum+=m_SeriesArray[kkk]*rrr;
         m_lsum+=m_SeriesArray[kkk];
         m_weight+=iii;
        }
     }
   else if(BarCheck3(begin,bar,set,Length_)) return(EMPTY_VALUE);

//---- Calculation of LWMA
   m_sum+=series*Length-m_lsum;
   kkk=Recount_ArrayNumber(m_count,Length_,Length);
   m_lsum+=series-m_SeriesArray[kkk];
   lwma=m_sum/m_weight;

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_SUM  = m_sum;
      m_LSUM = m_lsum;
     }

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_sum=m_SUM;
      m_lsum=m_LSUM;
     }
//----
   return(lwma);
  }
//+------------------------------------------------------------------+
//|  Calculation of the standard deviation                           |
//+------------------------------------------------------------------+    
double CStdDeviation::StdDevSeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int Length,           // Period of averaging
 double deviation,     // Deviation
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 double MovSeries,     // Value of a moving average, on which basis the StdDeviation is calculated
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays.
 )
// StdDevSeries(begin, prev_calculated, rates_total, period, deviation, Series, MovSeries, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   int iii,kkk;
   double StdDev,m_SumX2;

//---- Changing the size of array of variables
   if(bar==begin && !SeriesArrayResize(__FUNCTION__,Length,m_SeriesArray,m_Size_))
      return(EMPTY_VALUE);

//---- Checking for correctness of the external parameter Length
   LengthCheck(Length);

//---- Rearrangement and initialization of cells of the array m_SeriesArray
   Recount_ArrayZeroPos(m_count,Length,prev_calculated,series,bar,m_SeriesArray);

//---- Initialization of zero
   if(BarCheck2(begin,bar,set,Length))
     {
      m_Sum=0.0;
      m_Sum2=0.0;
      for(iii=1; iii<Length; iii++)
        {
         kkk=Recount_ArrayNumber(m_count,Length,iii);
         m_Sum+=m_SeriesArray[kkk];
         m_Sum2+=MathPow(m_SeriesArray[kkk],2);
        }
     }
   else if(BarCheck3(begin,bar,set,Length)) return(EMPTY_VALUE);

//---- Calculation of StdDev
   m_Sum+=series;
   m_Sum2 += MathPow(series, 2);
   m_SumX2 = Length * MathPow(MovSeries, 2) - 2 * MovSeries * m_Sum + m_Sum2;

   kkk=Recount_ArrayNumber(m_count,Length,Length-1);
   m_Sum2-=MathPow(m_SeriesArray[kkk],2);
   m_Sum -=m_SeriesArray[kkk];

   StdDev=deviation*MathSqrt(m_SumX2/Length);

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_Sum=m_SUM;
      m_Sum2=m_SUM2;
     }

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_SUM=m_Sum;
      m_SUM2=m_Sum2;
     }
//----
   return(StdDev);
  }
//+------------------------------------------------------------------+
//| JMA Averaging                                                    |
//+------------------------------------------------------------------+
double CJJMA::JJMASeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int  Din,             // Permission to change the parameters Length and Phase at every bar. 
 // 0 - prohibition to change the parameters, any other values means permission.
 double Phase,         // Parameter that can change within the range -100 ... +100, it depends on the quality of intermediate process of averaging
 double Length,        // Depth of smoothing
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays.
 )
// JMASeries(begin, prev_calculated, rates_total, Din, Phase, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Initialization of coefficients
   JJMAInit(begin,Din,Phase,Length,series,bar);

//---- Declaration of local variables
   int posA,posB,back;
   int shift2,shift1,numb;
//----
   double Res,ResPow;
   double dser3,dser4,jjma;
   double ratio,Extr,ser0,resalt;
   double newvel,dSupr,Pow1,hoop1,SmVel;
   double Pow2,Pow2x2,Suprem1,Suprem2;
   double dser1,dser2,extent=0,factor;

//----
   if(m_Loop1<61)
     {
      m_Loop1++;
      m_array[m_Loop1]=series;
     }
//-x-x-x-x-x-x-x-+  <<< Calculation of the function JMASeries() >>> 
   if(m_Loop1>30)
     {
      if(!m_start)
        {
         m_start= true;
         shift1 = 1;
         back=29;
         //----
         m_ser2 = m_array[1];
         m_ser1 = m_ser2;
        }
      else back=0;
      //-S-S-S-S-+
      for(int rrr=back; rrr>=0; rrr--)
        {
         if(rrr==0)
            ser0=series;
         else ser0=m_array[31-rrr];
         //----
         dser1 = ser0 - m_ser1;
         dser2 = ser0 - m_ser2;
         //----
         if(MathAbs(dser1)>MathAbs(dser2))
            m_var2=MathAbs(dser1);
         else m_var2=MathAbs(dser2);
         //----
         Res=m_var2;
         newvel=Res+0.0000000001;

         if(m_count1<=1)
            m_count1=127;
         else m_count1--;
         //----
         if(m_count2<=1)
            m_count2=10;
         else m_count2--;
         //----
         if(m_count3<128) m_count3++;
         //----      
         m_Sum1+=newvel-m_hoop2[m_count2];
         //----
         m_hoop2[m_count2]=newvel;
         m_bhoop2[m_count2]=true;
         //----
         if(m_count3>10)
            SmVel=m_Sum1/10.0;
         else SmVel=m_Sum1/m_count3;
         //----
         if(m_count3>127)
           {
            hoop1=m_hoop1[m_count1];
            m_hoop1[m_count1]=SmVel;
            m_bhoop1[m_count1]=true;
            numb = 64;
            posB = numb;
            //----
            while(numb>1)
              {
               if(m_data[posB]<hoop1)
                 {
                  numb /= 2.0;
                  posB += numb;
                 }
               else
                  if(m_data[posB]<=hoop1) numb=1;
               else
                 {
                  numb /= 2.0;
                  posB -= numb;
                 }
              }
           }
         else
           {
            m_hoop1[m_count1]=SmVel;
            m_bhoop1[m_count1]=true;
            //----
            if(m_midd1+m_midd2>127)
              {
               m_midd2--;
               posB=m_midd2;
              }
            else
              {
               m_midd1++;
               posB=m_midd1;
              }
            //----
            if(m_midd1>96)
               m_pos2=96;
            else m_pos2=m_midd1;
            //----
            if(m_midd2<32)
               m_pos1=32;
            else m_pos1=m_midd2;
           }
         //----
         numb = 64;
         posA = numb;
         //----
         while(numb>1)
           {
            if(m_data[posA]>=SmVel)
              {
               if(m_data[posA-1]<=SmVel) numb=1;
               else
                 {
                  numb /= 2.0;
                  posA -= numb;
                 }
              }
            else
              {
               numb /= 2.0;
               posA += numb;
              }
            //----
            if(posA==127)
               if(SmVel>m_data[127]) posA=128;
           }
         //----
         if(m_count3>127)
           {
            if(posB>=posA)
              {
               if(m_pos2+1>posA)
                  if(m_pos1-1<posA) m_Sum2+=SmVel;
               //----     
               else if(m_pos1+0>posA)
               if(m_pos1-1<posB)
                  m_Sum2+=m_data[m_pos1-1];
              }
            else
            if(m_pos1>=posA)
              {
               if(m_pos2+1<posA)
                  if(m_pos2+1>posB)
                     m_Sum2+=m_data[m_pos2+1];
              }
            else if(m_pos2+2>posA) m_Sum2+=SmVel;
            //----           
            else if(m_pos2+1<posA)
            if(m_pos2+1>posB)
               m_Sum2+=m_data[m_pos2+1];
            //----    
            if(posB>posA)
              {
               if(m_pos1-1<posB)
                  if(m_pos2+1>posB)
                     m_Sum2-=m_data[posB];
               //----
               else if(m_pos2<posB)
               if(m_pos2+1>posA)
                  m_Sum2-=m_data[m_pos2];
              }
            else
              {
               if(m_pos2+1>posB && m_pos1-1<posB)
                  m_Sum2-=m_data[posB];
               //----                
               else if(m_pos1+0>posB)
               if(m_pos1-0<posA)
                  m_Sum2-=m_data[m_pos1];
              }
           }
         //----
         if(posB<=posA)
           {
            if(posB==posA)
              {
               m_data[posA]=SmVel;
               m_bdata[posA]=true;
              }
            else
              {
               for(numb=posB+1; numb<=posA-1; numb++)
                 {
                  m_data[numb-1]=m_data[numb];
                  m_bdata[numb-1]=true;
                 }
               //----             
               m_data[posA-1]=SmVel;
               m_bdata[posA-1]=true;
              }
           }
         else
           {
            for(numb=posB-1; numb>=posA; numb--)
              {
               m_data[numb+1]=m_data[numb];
               m_bdata[numb+1]=true;
              }
            //----                
            m_data[posA]=SmVel;
            m_bdata[posA]=true;
           }
         //---- 
         if(m_count3<=127)
           {
            m_Sum2=0;
            for(numb=m_pos1; numb<=m_pos2; numb++)
               m_Sum2+=m_data[numb];
           }
         //---- 
         resalt=m_Sum2/(m_pos2-m_pos1+1.0);
         //----
         if(m_Loop2>30)
            m_Loop2=31;
         else m_Loop2++;
         //----
         if(m_Loop2<=30)
           {
            if(dser1>0.0)
               m_ser1=ser0;
            else m_ser1=ser0-dser1*m_Kct;
            //----
            if(dser2<0.0)
               m_ser2=ser0;
            else m_ser2=ser0-dser2*m_Kct;
            //----
            m_JMA=series;
            //----
            if(m_Loop2!=30) continue;
            else
              {
               m_storage1=series;
               if(MathCeil(m_Krx)>=1)
                  dSupr=MathCeil(m_Krx);
               else dSupr=1.0;
               //----
               if(dSupr>0) Suprem2=MathFloor(dSupr);
               else
                 {
                  if(dSupr<0)
                     Suprem2=MathCeil(dSupr);
                  else Suprem2=0.0;
                 }
               //----
               if(MathFloor(m_Krx)>=1)
                  m_var2=MathFloor(m_Krx);
               else m_var2=1.0;
               //----
               if(m_var2>0) Suprem1=MathFloor(m_var2);
               else
                 {
                  if(m_var2<0)
                     Suprem1=MathCeil(m_var2);
                  else Suprem1=0.0;
                 }
               //----
               if(Suprem2==Suprem1) factor=1.0;
               else
                 {
                  dSupr=Suprem2-Suprem1;
                  factor=(m_Krx-Suprem1)/dSupr;
                 }
               //---- 
               if(Suprem1<=29)
                  shift1=(int)Suprem1;
               else shift1=29;
               //----
               if(Suprem2<=29)
                  shift2=(int)Suprem2;
               else shift2=29;

               dser3 = series - m_array[m_Loop1 - shift1];
               dser4 = series - m_array[m_Loop1 - shift2];
               //----
               m_djma=dser3 *(1.0-factor)/Suprem1+dser4*factor/Suprem2;
              }
           }
         else
           {
            ResPow=MathPow(Res/resalt,m_degree);
            //----
            if(m_Kfd>=ResPow)
               m_var1= ResPow;
            else m_var1=m_Kfd;
            //----
            if(m_var1<1.0)m_var2=1.0;
            else
              {
               if(m_Kfd>=ResPow)
                  m_sense=ResPow;
               else m_sense=m_Kfd;

               m_var2=m_sense;
              }
            //---- 
            extent=m_var2;
            Pow1=MathPow(m_Kct,MathSqrt(extent));
            //----
            if(dser1>0.0)
               m_ser1=ser0;
            else m_ser1=ser0-dser1*Pow1;
            //----
            if(dser2<0.0)
               m_ser2=ser0;
            else m_ser2=ser0-dser2*Pow1;
           }
        }
      //---- 
      if(m_Loop2>30)
        {
         Pow2=MathPow(m_Krj,extent);
         //----
         m_storage1 *= Pow2;
         m_storage1 += (1.0 - Pow2) * series;
         m_storage2 *= m_Krj;
         m_storage2 += (series - m_storage1) * (1.0 - m_Krj);
         //----
         Extr=m_Phase*m_storage2+m_storage1;
         //----
         Pow2x2= Pow2 * Pow2;
         ratio = Pow2x2-2.0 * Pow2+1.0;
         m_djma *= Pow2x2;
         m_djma += (Extr - m_JMA) * ratio;
         //----
         m_JMA+=m_djma;
        }
     }
//-x-x-x-x-x-x-x-+

   if(m_Loop1<=30) return(EMPTY_VALUE);
   jjma=m_JMA;

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      //---- Restoring modified cells of arrays from memory
      for(numb = 0; numb < 128; numb++) if(m_bhoop1[numb]) m_hoop1[numb] = m_hoop1_[numb];
      for(numb = 0; numb < 11;  numb++) if(m_bhoop2[numb]) m_hoop2[numb] = m_hoop2_[numb];
      for(numb = 0; numb < 128; numb++) if(m_bdata [numb]) m_data [numb] = m_data_ [numb];

      //---- Zeroing numbers of modified cells of arrays
      ArrayInitialize(m_bhoop1,false);
      ArrayInitialize(m_bhoop2,false);
      ArrayInitialize(m_bdata,false);

      //---- Writing values of variables from the memory 
      m_JMA=m_JMA_;
      m_djma = m_djma_;
      m_ser1 = m_ser1_;
      m_ser2 = m_ser2_;
      m_Sum2 = m_Sum2_;
      m_pos1 = m_pos1_;
      m_pos2 = m_pos2_;
      m_Sum1  = m_Sum1_;
      m_Loop1 = m_Loop1_;
      m_Loop2 = m_Loop2_;
      m_count1 = m_count1_;
      m_count2 = m_count2_;
      m_count3 = m_count3_;
      m_storage1 = m_storage1_;
      m_storage2 = m_storage2_;
      m_midd1 = m_midd1_;
      m_midd2 = m_midd2_;
     }

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      //---- Writing modified cells of arrays to the memory
      for(numb = 0; numb < 128; numb++) if(m_bhoop1[numb]) m_hoop1_[numb] = m_hoop1[numb];
      for(numb = 0; numb < 11;  numb++) if(m_bhoop2[numb]) m_hoop2_[numb] = m_hoop2[numb];
      for(numb = 0; numb < 128; numb++) if(m_bdata [numb]) m_data_ [numb] = m_data [numb];

      //---- Zeroing numbers of modified cells of arrays
      ArrayInitialize(m_bhoop1,false);
      ArrayInitialize(m_bhoop2,false);
      ArrayInitialize(m_bdata,false);

      //---- Writing values of variables to the memory
      m_JMA_=m_JMA;
      m_djma_ = m_djma;
      m_Sum2_ = m_Sum2;
      m_ser1_ = m_ser1;
      m_ser2_ = m_ser2;
      m_pos1_ = m_pos1;
      m_pos2_ = m_pos2;
      m_Sum1_  = m_Sum1;
      m_Loop1_ = m_Loop1;
      m_Loop2_ = m_Loop2;
      m_count1_ = m_count1;
      m_count2_ = m_count2;
      m_count3_ = m_count3;
      m_storage1_ = m_storage1;
      m_storage2_ = m_storage2;
      m_midd1_ = m_midd1;
      m_midd2_ = m_midd2;
     }

//----  End of calculations of the function JMASeries()
   return(jjma);
  }
//+------------------------------------------------------------------+
//|  Initialization of variables of the JMA algorithm                |
//+------------------------------------------------------------------+    
void CJJMA::JJMAInit
(
 uint begin,
 int  Din,
 double Phase,
 double Length,
 double series,
 uint bar
 )
// JMAInit(begin, Din, Phase, Length, series, bar) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----  
//---- <<< Calculation of coefficients  >>> 
   if(bar==begin || Din!=0)
     {
      if(bar==begin)
        {
         m_midd1 = 63;
         m_midd2 = 64;
         m_start = false;

         //----
         for(int numb = 0;       numb <= m_midd1; numb++) m_data[numb] = -1000000.0;
         for(int numb = m_midd2; numb <= 127;     numb++) m_data[numb] = +1000000.0;

         //---- All cells of arrays must be overwritten
         ArrayInitialize(m_bhoop1,true);
         ArrayInitialize(m_bhoop2,true);
         ArrayInitialize(m_bdata,true);

         //---- Deleting trash from arrays at repeated initializations 
         ArrayInitialize(m_hoop1_, 0.0);
         ArrayInitialize(m_hoop2_, 0.0);
         ArrayInitialize(m_hoop1,  0.0);
         ArrayInitialize(m_hoop2,  0.0);
         ArrayInitialize(m_array,  0.0);
         //----
         m_djma = 0.0;
         m_Sum1 = 0.0;
         m_Sum2 = 0.0;
         m_ser1 = 0.0;
         m_ser2 = 0.0;
         m_pos1 = 0.0;
         m_pos2 = 0.0;
         m_Loop1 = 0.0;
         m_Loop2 = 0.0;
         m_count1 = 0.0;
         m_count2 = 0.0;
         m_count3 = 0.0;
         m_storage1 = 0.0;
         m_storage2 = 0.0;
         m_JMA=series;
        }

      if(Phase>=-100 && Phase<=100)
         m_Phase=Phase/100.0+1.5;
      //----        
      if(Phase > +100) m_Phase = 2.5;
      if(Phase < -100) m_Phase = 0.5;
      //----
      double velA,velB,velC,velD;
      //----
      if(Length>=1.0000000002)
         velA=(Length-1.0)/2.0;
      else velA=0.0000000001;
      //----
      velA *= 0.9;
      m_Krj = velA / (velA + 2.0);
      velC = MathSqrt(velA);
      velD = MathLog(velC);
      m_var1= velD;
      m_var2= m_var1;
      //----
      velB=MathLog(2.0);
      m_sense=(m_var2/velB)+2.0;
      if(m_sense<0.0) m_sense=0.0;
      m_Kfd=m_sense;
      //----
      if(m_Kfd>=2.5)
         m_degree=m_Kfd-2.0;
      else m_degree=0.5;
      //----
      m_Krx = velC * m_Kfd;
      m_Kct = m_Krx / (m_Krx + 1.0);
     }
//----
  }
//+------------------------------------------------------------------+
//| Checking the depth of averaging Length for correctness           |
//+------------------------------------------------------------------+
void CJJMA::JJMALengthCheck(string LengthName,int ExternLength)

// Jm_JMALengthCheck(LengthName, ExternLength)
  {
//----
//---- Writing messages about unacceptable values of input parameters  
   if(ExternLength<1)
     {
      string word;
      StringConcatenate
      (word,__FUNCTION__," (): Parameter ",LengthName,
       " must be no less than 1. You specified incorrect value",
       ExternLength," value 1 will be used");
      Print(word);
      return;
     }
//----
  }
//+------------------------------------------------------------------+
//| Checking the correctness of the Phase parameter of averaging     |
//+------------------------------------------------------------------+
void CJJMA::JJMAPhaseCheck(string PhaseName,int ExternPhase)

// Jm_JMAPhaseCheck(PhaseName, ExternPhase)
  {
//----
//---- writing messages about unacceptable values of input parameters 
   if(ExternPhase<-100)
     {
      string word;
      StringConcatenate
      (word,__FUNCTION__," (): Parameter ",PhaseName,
       " must be no less than -100. You specified incorrect value",
       ExternPhase," value  -100 will be used");
      Print(word);
      return;
     }
//----
   if(ExternPhase>+100)
     {
      string word;
      StringConcatenate
      (word,__FUNCTION__," (): Parameter ",PhaseName,
       " must not exceed +100. You specified incorrect value",
       ExternPhase," value  +100 will be used");
      Print(word);
      return;
     }
//----
  }
//+------------------------------------------------------------------+
//|  T3 averaging                                                    |
//+------------------------------------------------------------------+
double CT3::T3Series
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int  Din,             // Permission to change the parameter Length at every bar. 
 // 0 - prohibition to change the parameters, any other values means permission.
 double Curvature,     // Coefficient (its value is increased 100 times for convenience!)
 double Length,        // Depth of smoothing
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays.
 )
// T3Series(begin, prev_calculated, rates_total, Din, Curvature, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   double e0,T3_;

//---- Checking for correctness the external parameter Length
   LengthCheck(Length);

//---- Calculation of coefficients
   T3Init(begin,Din,Curvature,Length,series,bar);

   e0=series;
//---- <<< Calculation of T3 >>> 
   m_e1 = m_w1 * e0 + m_w2 * m_e1;
   m_e2 = m_w1 * m_e1 + m_w2 * m_e2;
   m_e3 = m_w1 * m_e2 + m_w2 * m_e3;
   m_e4 = m_w1 * m_e3 + m_w2 * m_e4;
   m_e5 = m_w1 * m_e4 + m_w2 * m_e5;
   m_e6 = m_w1 * m_e5 + m_w2 * m_e6;
//----  
   T3_=m_c1*m_e6+m_c2*m_e5+m_c3*m_e4+m_c4*m_e3;

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_e1 = m_E1;
      m_e2 = m_E2;
      m_e3 = m_E3;
      m_e4 = m_E4;
      m_e5 = m_E5;
      m_e6 = m_E6;
     }

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_E1 = m_e1;
      m_E2 = m_e2;
      m_E3 = m_e3;
      m_E4 = m_e4;
      m_E5 = m_e5;
      m_E6 = m_e6;
     }

//---- End of calculation of value of the function T3Series()
   return(T3_);
  }
//+------------------------------------------------------------------+
//|  Initialization of variables of the T3 algorithm                 |
//+------------------------------------------------------------------+    
void CT3::T3Init
(
 uint begin,
 int Din,
 double Curvature,
 double Length,
 double series,
 uint bar
 )
// T3InitInit(begin, Din, Curvature, Length, series, bar) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----  
//---- <<< Calculation of coefficients >>>
   if(bar==begin || Din!=0)
     {
      double b=Curvature/100.0;
      m_b2 = b * b;
      m_b3 = m_b2 * b;
      m_c1 = -m_b3;
      m_c2 = (3 * (m_b2 + m_b3));
      m_c3 = -3 * (2 * m_b2 + b + m_b3);
      m_c4 = (1 + 3 * b + m_b3 + 3 * m_b2);
      double n=1+0.5 *(Length-1);
      m_w1 = 2 / (n + 1);
      m_w2 = 1 - m_w1;

      if(bar==begin)
        {
         m_e1 = series;
         m_e2 = series;
         m_e3 = series;
         m_e4 = series;
         m_e5 = series;
         m_e6 = series;
        }
     }
//----
  }
//+------------------------------------------------------------------+
//| Ultralinear averaging                                            |
//+------------------------------------------------------------------+    
double CJurX::JurXSeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int  Din,             // Permission to change the parameter Length at every bar. 
 // 0 - prohibition to change the parameters, any other values means permission.
 double Length,        // Depth of smoothing
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays.
 )
// JurXSeries(begin, prev_calculated, rates_total, Din, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   double V1,V2,JurX_;

//---- Checking for correctness the external parameter Length
   LengthCheck(Length);

//---- Initialization of coefficients
   JurXInit(begin,Din,Length,series,bar);

//---- <<< Calculation of JurX >>> 
   m_f1   =  m_Hg * m_f1 + m_Kg * series;
   m_f2   =  m_Kg * m_f1 + m_Hg * m_f2;
   V1     =  m_AC * m_f1 - m_AB * m_f2;
   m_f3   =  m_Hg * m_f3 + m_Kg * V1;
   m_f4   =  m_Kg * m_f3 + m_Hg * m_f4;
   V2     =  m_AC * m_f3 - m_AB * m_f4;
   m_f5   =  m_Hg * m_f5 + m_Kg * V2;
   m_f6   =  m_Kg * m_f5 + m_Hg * m_f6;
   JurX_  =  m_AC * m_f5 - m_AB * m_f6;

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_f1 = m_F1;
      m_f2 = m_F2;
      m_f3 = m_F3;
      m_f4 = m_F4;
      m_f5 = m_F5;
      m_f6 = m_F6;
     }

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_F1 = m_f1;
      m_F2 = m_f2;
      m_F3 = m_f3;
      m_F4 = m_f4;
      m_F5 = m_f5;
      m_F6 = m_f6;
     }

//---- End of calculation of value of the functions JurX.Series
   return(JurX_);

  }
//+------------------------------------------------------------------+
//|  Initialization of variables of the algorithm JurX               |
//+------------------------------------------------------------------+    
void CJurX::JurXInit
(
 uint begin,
 int Din,
 double Length,
 double series,
 uint bar
 )
// JurXInit(begin, Din, Length, series, bar) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----  
   if(bar==begin || Din!=0)
     {
      if(Length>=6)
         m_w=Length-1;
      else m_w=5;

      m_Kg = 3 / (Length + 2.0);
      m_Hg = 1.0 - m_Kg;
      //----
      if(bar==begin)
        {
         m_f1 = series;
         m_f2 = series;
         m_f3 = series;
         m_f4 = series;
         m_f5 = series;
         m_f6 = series;

         m_AB = 0.5;
         m_AC = 1.5;
        }
     }
//----
  }
//+------------------------------------------------------------------+
//|  CMOSeries() function                                            |
//+------------------------------------------------------------------+    
double CCMO::CMOSeries
(
 uint begin,// Number of beginning of bars for reliable calculation
 uint prev_calculated,// Amount of history in bars at the previous tick
 uint rates_total,// Amount of history in bars at the current tick
 int CMO_Length, // CMO period
 double series,  // Value of the price series calculated for the new bar with number 'bar'
 uint bar,// Bar number
 bool set // Direction of indexing arrays
 )
// CMOSeries(begin, prev_calculated, rates_total, CMO_Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables;
   double dseries,abcmo;
   int iii,rrr,size=CMO_Length+1;

//---- Changing the size of array of variables
   if(bar==begin && !SeriesArrayResize(__FUNCTION__,size,m_dSeriesArray,m_Size_))
      return(EMPTY_VALUE);

//---- Checking the external parameter CMO_Length for correctness
   LengthCheck(CMO_Length);

//---- Checking whether there are enough bars 
   if(BarCheck1(begin+1,bar,set)) return(EMPTY_VALUE);

//---- Rearrangement of cells of the array SeriesArray
   Recount_ArrayZeroPos(m_count,size,prev_calculated,series-m_series1,bar,m_dSeriesArray);

//---- Initialization of zero
   if(BarCheck2(begin,bar,set,CMO_Length+3))
     {
      m_UpSum = 0.0;
      m_DnSum = 0.0;

      for(iii=1; iii<CMO_Length; iii++)
        {
         rrr=Recount_ArrayNumber(m_count,size,iii);
         dseries=m_dSeriesArray[rrr];

         if(dseries > 0) m_UpSum += dseries;
         if(dseries < 0) m_DnSum -= dseries;
        }

      m_AbsCMO=0.000000001;
     }
   else if(BarCheck3(begin,bar,set,CMO_Length+3))
     {
      m_series1=series;
      return(EMPTY_VALUE);
     }

   dseries=m_dSeriesArray[m_count];
   if(dseries > 0) m_UpSum += dseries;
   if(dseries < 0) m_DnSum -= dseries;
   if(m_UpSum+m_DnSum>0)
      m_AbsCMO=MathAbs((m_UpSum-m_DnSum)/(m_UpSum+m_DnSum));
   abcmo=m_AbsCMO;
//----
   rrr=Recount_ArrayNumber(m_count,size,CMO_Length-1);
   dseries=m_dSeriesArray[rrr];
   if(dseries > 0) m_UpSum -= dseries;
   if(dseries < 0) m_DnSum += dseries;

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_AbsCMO= m_AbsCMO_;
      m_UpSum = m_UpSum_;
      m_DnSum = m_DnSum_;
      m_series1=m_series1_;
     }
   else m_series1=series;

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_AbsCMO_=m_AbsCMO;
      m_UpSum_ = m_UpSum;
      m_DnSum_ = m_DnSum;
      m_series1_=m_series1;
     }
//----
   return(abcmo);
  }
//+------------------------------------------------------------------+
//|  VIDYASeries() function                                          |
//+------------------------------------------------------------------+    
double CCMO::VIDYASeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int CMO_Length,       // CMO period
 double EMA_Length,    // EMA period
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set               // Direction of indexing arrays
 )
// VIDYASeries(begin, prev_calculated, rates_total, CMO_Length, EMA_Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
//---- Declaration of local variables
   double vidya,CMO_=CMOSeries(begin,prev_calculated,rates_total,CMO_Length,series,bar,set);

//---- Initialization of zero
   if(BarCheck2(begin,bar,set,CMO_Length+3))
     {
      m_Vidya=series;
      //---- Initialization of the factor of smoothing of ЕМА
      m_SmoothFactor=2.0/(EMA_Length+1.0);
     }
   else if(BarCheck3(begin,bar,set,CMO_Length+3)) return(EMPTY_VALUE);

//----
   CMO_*=m_SmoothFactor;
   m_Vidya=CMO_*series+(1-CMO_)*m_Vidya;
   vidya=m_Vidya;

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_Vidya=m_Vidya_;
     }

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_Vidya_=m_Vidya;
     }
//----
   return(vidya);
  }
//+------------------------------------------------------------------+
//|  Kaufman's averaging                                             |
//+------------------------------------------------------------------+    
double CAMA::AMASeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int Length,           // AMA period
 int Fast_Length,      // Period of fast moving average
 int Slow_Length,      // Period of slow moving average
 double Rate,          // Rate of the smoothing constant
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays.
 )
// AMASeries(symbol, timeframe, begin, limit, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   double signal,ER,ERSC,SSC,dprice,ama;
   int iii,kkk,rrr,size=Length+1;

//---- Change size of variables arrays
   if(bar==begin)
      if(!SeriesArrayResize(__FUNCTION__,size,m_SeriesArray,m_Size_1)
         || !SeriesArrayResize(__FUNCTION__,size,m_dSeriesArray,m_Size_2))
         return(EMPTY_VALUE);

//---- Checking for correctness of the external parameter Length
   LengthCheck(Length);

//---- Rearrangement and initialization of cells of the array m_SeriesArray
   Recount_ArrayZeroPos(m_count,size,prev_calculated,series,bar,m_SeriesArray);

//---- Checking whether there are enough bars 
   if(BarCheck1(begin+1,bar,set)) return(EMPTY_VALUE);

   kkk=Recount_ArrayNumber(m_count,size,1);
   dprice=series-m_SeriesArray[kkk];
   m_dSeriesArray[m_count]=dprice;

//---- Initialization of zero
   if(BarCheck2(begin,bar,set,Length+3))
     {
      //---- Initialization of constants
      rrr=Recount_ArrayNumber(m_count,size,1);
      m_Ama=m_SeriesArray[rrr];
      m_slowSC = (2.0 / (Slow_Length + 1));
      m_fastSC = (2.0 / (Fast_Length + 1));
      m_dSC=m_fastSC-m_slowSC;
      m_noise=0.000000001;

      for(iii=1; iii<Length; iii++)
        {
         rrr=Recount_ArrayNumber(m_count,size,iii);
         m_noise+=MathAbs(m_dSeriesArray[rrr]);
        }
     }
   else if(BarCheck3(begin,bar,set,Length+3)) return(EMPTY_VALUE);

//----
   m_noise+=MathAbs(dprice);
   rrr=Recount_ArrayNumber(m_count,size,Length);
   signal=MathAbs(series-m_SeriesArray[rrr]);
//----                     
   ER=signal/m_noise;
   ERSC= ER *  m_dSC;
   SSC = ERSC+m_slowSC;
   m_Ama=m_Ama+(MathPow(SSC,Rate) *(series-m_Ama));
   ama =  m_Ama;
   kkk = Recount_ArrayNumber( m_count, size, Length - 1);
   m_noise-=MathAbs(m_dSeriesArray[kkk]);

//---- Restoring values of variables
   if(BarCheck5(rates_total,bar,set))
     {
      m_noise=m_NOISE;
      m_Ama=m_AMA_;
     }

//---- Saving values of variables
   if(BarCheck4(rates_total,bar,set))
     {
      m_AMA_=m_Ama;
      m_NOISE=m_noise;
     }
//----
   return(ama);
  }
//+------------------------------------------------------------------+
//| Parabolic averaging                                              |
//+------------------------------------------------------------------+    
double CParMA::ParMASeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int Length,           // Period of averaging
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays
 )
// SMASeries(Number, symbol, timeframe, begin, limit, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   int iii,kkk;
//----
   double S,B0,B1,B2,parma;
   double A,B,C,D,E,F;
   double K,L,M,P,Q,R;
   double sum_y,sum_xy,sum_x2y,var_tmp;

//---- Changing the size of array of variables
   if(bar==begin && !SeriesArrayResize(__FUNCTION__,Length,m_SeriesArray,m_Size_))
      return(EMPTY_VALUE);

//---- Checking for correctness of the external parameter Length
   LengthCheck(Length);

//---- Rearrangement and initialization of cells of the array m_SeriesArray
   Recount_ArrayZeroPos(m_count,Length,prev_calculated,series,bar,m_SeriesArray);

//---- Initialization of zero
   if(BarCheck2(begin,bar,set,Length)) ParMAInit(Length);
   else if(BarCheck3(begin,bar,set,Length)) return(EMPTY_VALUE);

//---- ParMA calculation
   sum_y   = 0.0;
   sum_xy  = 0.0;
   sum_x2y = 0.0;
//----
   for(iii=1; iii<=Length; iii++)
     {
      kkk=Recount_ArrayNumber(m_count,Length,Length-iii);
      var_tmp  = m_SeriesArray[kkk];
      sum_y   += var_tmp;
      sum_xy  += iii * var_tmp;
      sum_x2y += iii * iii * var_tmp;
     }

// the difference between two adjacent bars for sum_x2y: Sum(i=0; i<Length){(2*Length* - 1)*Series[i] + 2*i*Series[i]}

// initialization
   A = Length;
   B = m_sum_x;
   C = m_sum_x2;
   F = m_sum_x3;
   M = m_sum_x4;
   P = sum_y;
   R = sum_xy;
   S = sum_x2y;
// intermediates
   D = B;
   E = C;
   K = C;
   L = F;
   Q = D / A;
   E = E - Q * B;
   F = F - Q * C;
   R = R - Q * P;
   Q = K / A;
   L = L - Q * B;
   M = M - Q * C;
   S = S - Q * P;
   Q = L / E;
// calculate regression coefficients
   B2 = (S - R * Q) / (M - F * Q);
   B1 = (R - F * B2) / E;
   B0 = (P - B * B1 - C * B2) / A;
// value to be returned - parabolic MA
   parma=B0+(B1+B2*A)*A;
//----
   return(parma);
  }
//+------------------------------------------------------------------+
//|  Initialization of variables of the algorithm of parabolic averaging  |
//+------------------------------------------------------------------+    
void CParMA::ParMAInit(double Length)
// ParMAInit(Length)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int var_tmp;
   m_sum_x=0;
   m_sum_x2 = 0;
   m_sum_x3 = 0;
   m_sum_x4 = 0;

   for(int iii=1; iii<=Length; iii++)
     {
      var_tmp=iii;
      m_sum_x+=var_tmp;
      var_tmp *= iii;
      m_sum_x2+= var_tmp;
      var_tmp *= iii;
      m_sum_x3+= var_tmp;
      var_tmp *= iii;
      m_sum_x4+= var_tmp;
     }
//----
  }
//+------------------------------------------------------------------+
//|  Rate of price changing                                          |
//+------------------------------------------------------------------+    
double CMomentum::MomentumSeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int Length,           // Period of averaging
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays
 )
// MomentumSeries(begin, prev_calculated, rates_total, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   int kkk,Length_=Length+1;
   double Momentum;

//---- Checking for correctness of the external parameter Length
   LengthCheck(Length);

//---- Changing the size of array of variables
   if(bar==begin && !SeriesArrayResize(__FUNCTION__,Length_,m_SeriesArray,m_Size_))
      return(EMPTY_VALUE);

//---- Rearrangement and initialization of cells of the array m_SeriesArray
   Recount_ArrayZeroPos(m_count,Length_,prev_calculated,series,bar,m_SeriesArray);

//---- Initialization of zero
   if(BarCheck3(begin,bar,set,Length_)) return(EMPTY_VALUE);

//---- Calculation of rate of price changing
   kkk=Recount_ArrayNumber(m_count,Length_,Length);
   Momentum=series-m_SeriesArray[kkk];
//----
   return(Momentum);
  }
//+------------------------------------------------------------------+
//|  Normalized rate of price changing                               |
//+------------------------------------------------------------------+    
double CnMomentum::nMomentumSeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int Length,           // Period of averaging
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays
 )
// nMomentumSeries(begin, prev_calculated, rates_total, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   int kkk,Length_=Length+1;
   double nMomentum;

//---- Checking for correctness the external parameter Length
   LengthCheck(Length);

//---- Changing the size of array of variables
   if(bar==begin && !SeriesArrayResize(__FUNCTION__,Length_,m_SeriesArray,m_Size_))
      return(EMPTY_VALUE);

//---- Rearrangement and initialization of cells of the array m_SeriesArray
   Recount_ArrayZeroPos(m_count,Length_,prev_calculated,series,bar,m_SeriesArray);

//---- Initialization of zero
   if(BarCheck3(begin,bar,set,Length_)) return(EMPTY_VALUE);

//---- Calculation of rate of price changing
   kkk=Recount_ArrayNumber(m_count,Length_,Length);
   nMomentum=(series-m_SeriesArray[kkk])/m_SeriesArray[kkk];
//----
   return(nMomentum);
  }
//+------------------------------------------------------------------+
//|  Rate of price changing                                          |
//+------------------------------------------------------------------+    
double CROC::ROCSeries
(
 uint begin,           // Number of beginning of bars for reliable calculation
 uint prev_calculated, // Amount of history in bars at the previous tick
 uint rates_total,     // Amount of history in bars at the current tick
 int Length,           // Period of averaging
 double series,        // Value of the price series calculated for the new bar with number 'bar'
 uint bar,             // Bar number
 bool set              // Direction of indexing arrays
 )
// MomentumSeries(begin, prev_calculated, rates_total, Length, series, bar, set) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//---- Checking the beginning of bars for reliable calculation 
   if(BarCheck1(begin,bar,set)) return(EMPTY_VALUE);

//---- Declaration of local variables
   int kkk,Length_=Length+1;
   double ROC;

//---- Checking for correctness of the external parameter Length
   LengthCheck(Length);

//---- Changing the size of array of variables
   if(bar==begin && !SeriesArrayResize(__FUNCTION__,Length_,m_SeriesArray,m_Size_))
      return(EMPTY_VALUE);

//---- Rearrangement and initialization of cells of the array m_SeriesArray
   Recount_ArrayZeroPos(m_count,Length_,prev_calculated,series,bar,m_SeriesArray);

//---- Initialization of zero
   if(BarCheck3(begin,bar,set,Length_)) return(EMPTY_VALUE);

//---- Calculation of rate of price changing
   kkk = Recount_ArrayNumber(m_count, Length_, Length);
   ROC = 100 * series / m_SeriesArray[kkk];
//----
   return(ROC);
  }
//+------------------------------------------------------------------+
//| Checking correctness of the period of averaging                  |
//+------------------------------------------------------------------+
void CMovSeriesTools::MALengthCheck(string LengthName,int ExternLength)

// MALengthCheck(LengthName, ExternLength)
  {
//---- 
   if(ExternLength<1)
     {
      string word;
      StringConcatenate
      (word,__FUNCTION__," (): Parameter ",LengthName,
       " must be no less than 1. You specified incorrect value",
       ExternLength," value 1 will be used");
      Print(word);
      return;
     }
//----
  }
//+------------------------------------------------------------------+
//| Checking correctness of the period of averaging                  |
//+------------------------------------------------------------------+
void CMovSeriesTools::MALengthCheck(string LengthName,double ExternLength)

// MALengthCheck(LengthName, ExternLength)
  {
//---- 
   if(ExternLength<1)
     {
      string word;
      StringConcatenate
      (word,__FUNCTION__," (): Parameter ",LengthName,
       " must be no less than 1. You specified incorrect value",
       ExternLength," value 1 will be used");
      Print(word);
      return;
     }
//----
  }
//+------------------------------------------------------------------+
//| Checking if a bar withing the range of calculation               |
//+------------------------------------------------------------------+
bool CMovSeriesTools::BarCheck1(int begin,int bar,bool Set)

// BarCheck1(begin, bar, Set)
  {
//----
   if(!Set && bar<begin || Set && bar>begin) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Checking bar for the start of calculation                        |
//+------------------------------------------------------------------+
bool CMovSeriesTools::BarCheck2(int begin,int bar,bool Set,int Length)

// BarCheck2(begin, bar, Set, Length)
  {
//----
   if(!Set && bar==begin+Length-1 || Set && bar==begin-Length+1)
      return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Checking bar for absence of bars for averaging                   |
//+------------------------------------------------------------------+
bool CMovSeriesTools::BarCheck3(int begin,int bar,bool Set,int Length)

// BarCheck3(begin, bar, Set, Length)
  {
//----
   if(!Set && bar<begin+Length-1 || Set && bar>begin-Length+1)
      return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Checking bar at the moment of saving information                 |
//+------------------------------------------------------------------+
bool CMovSeriesTools::BarCheck4(int rates_total,int bar,bool Set)

// BarCheck4(rates_total, bar, Set)
  {
//----
//---- Saving values of variables
   if(!Set && bar==rates_total-2 || Set && bar==1) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Checking bar at the moment of restoring information              |
//+------------------------------------------------------------------+
bool CMovSeriesTools::BarCheck5(int rates_total,int bar,bool Set)

// BarCheck5(rates_total, begin, bar, set)
  {
//----
//---- Restoring values of variables
   if(!Set && bar==rates_total-1 || Set && bar==0) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Changing incorrect period of averaging                           |
//+------------------------------------------------------------------+
void CMovSeriesTools::LengthCheck(int &ExternLength)

// LengthCheck(LengthName, ExternLength)
  {
//----
   if(ExternLength<1) ExternLength=1;
//----
  }
//+------------------------------------------------------------------+
//| Changing incorrect period of averaging                           |
//+------------------------------------------------------------------+
void CMovSeriesTools::LengthCheck(double &ExternLength)

// LengthCheck(ExternLength)
  {
//----
   if(ExternLength<1) ExternLength=1;
//----
  }
//+------------------------------------------------------------------+
//|  Recalculation of position of a newest element in the array      |
//+------------------------------------------------------------------+    
void CMovSeriesTools::Recount_ArrayZeroPos
(
 int &count,// Return the current value of the price series by the link
 int Length,
 int prev_calculated,
 double series,// Value of the price series calculated for the new bar with number 'bar'
 int bar,
 double &Array[]
 )
// Recount_ArrayZeroPos(count, Length, prev_calculated, series, bar, Array[])
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   if(bar!=prev_calculated-1)
     {
      count--;
      if(count<0) count=Length-1;
     }

   Array[count]=series;
//----
  }
//+------------------------------------------------------------------+
//|  Transformation of a timeseries number into an array position    |
//+------------------------------------------------------------------+    
int CMovSeriesTools::Recount_ArrayNumber
(
 int count,// Number of the current value of the price series
 int Length,
 int Number // Position of the requested value relatively to the current bar 'bar'
 )
// Recount_ArrayNumber(count, Length, Number)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int ArrNumber=Number+count;

   if(ArrNumber>Length-1) ArrNumber-=Length;
//----
   return(ArrNumber);
  }
//+------------------------------------------------------------------+
//|  Changing size of the array Array[]                              |
//+------------------------------------------------------------------+    
bool CMovSeriesTools::SeriesArrayResize
(
 string FunctionsName,// Name of function, in which the size is changed
 int Length,// new size of array
 double &Array[],// Array that is changed
 int &Size_ // New size of the array
 )
// SeriesArrayResize(FunctionsName, Length, Array, Size_) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----    

//---- Changing the size of array of variables
   if(Length>Size_)
     {
      int Size=Length+1;

      if(ArrayResize(Array,Size)==-1)
        {
         ArrayResizeErrorPrint(FunctionsName,Size_);
         return(false);
        }

      Size_=Size;
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//|  Writing the error of changing size of the array into log file   |
//+------------------------------------------------------------------+    
bool CMovSeriesTools::ArrayResizeErrorPrint
(
 string FunctionsName,
 int &Size_
 )
// ArrayResizeErrorPrint(FunctionsName, Size_) 
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----    
   string lable,word;
   StringConcatenate(lable,FunctionsName,"():");
   StringConcatenate(word,lable," Error!!! Failed to change",
                     " the size of array of variables of the function ",FunctionsName,"()!");
   Print(word);
//----             
   int error=GetLastError();
   ResetLastError();
//----
   if(error>4000)
     {
      StringConcatenate(word,lable,"(): Error code ",error);
      Print(word);
     }

   Size_=-2;
   return(false);
//----
   return(true);
  }
//+----------------------+ <<< The End >>> +-----------------------+
