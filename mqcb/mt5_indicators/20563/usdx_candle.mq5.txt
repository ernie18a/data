//+------------------------------------------------------------------+
//|                                                  USDX_Candle.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "USD Index Candle"
#property indicator_separate_window
#property indicator_buffers 29   // 5
#property indicator_plots   1
//--- plot USDXc
#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMediumSeaGreen,clrOrange,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_INPUT_YES_NO InpReverse  =  INPUT_NO;   // Reverse
//--- indicator buffers
double         BufferUSDX_O[];
double         BufferUSDX_H[];
double         BufferUSDX_L[];
double         BufferUSDX_C[];
double         BufferColors[];
//--- includes
#include <Arrays\ArrayObj.mqh>
//--- global variables
double      scale_factor;
CArrayObj   list_instruments;
//---
string symbols[]={"EURUSD","USDJPY","GBPUSD","USDCAD","USDSEK","USDCHF"};
double weights[]={-0.576,0.136,-0.119,0.091,0.042,0.036};
int    timeframes[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
//+------------------------------------------------------------------+
//| Класс объекта инструмент                                         |
//+------------------------------------------------------------------+
class CInstrument : public CObject
  {
private:
   string            m_symbol_name;                      // Symbol name
   double            m_weight;                           // Symbol weight
   int               m_bars;                             // Symbol Bars
   int               m_handle_o;                         // Handle MA Open
   int               m_handle_h;                         // Handle MA High
   int               m_handle_l;                         // Handle MA Low
   int               m_handle_c;                         // Handle MA Close
public:
   double            m_buffer_o[];                       // Buffer[] MA Open
   double            m_buffer_h[];                       // Buffer[] MA High
   double            m_buffer_l[];                       // Buffer[] MA Low
   double            m_buffer_c[];                       // Buffer[] MA Close
   void              HandleO(const int handle)           { this.m_handle_o=handle;     }
   int               HandleO(void)                 const { return this.m_handle_o;     }
   void              HandleH(const int handle)           { this.m_handle_h=handle;     }
   int               HandleH(void)                 const { return this.m_handle_h;     }
   void              HandleL(const int handle)           { this.m_handle_l=handle;     }
   int               HandleL(void)                 const { return this.m_handle_l;     }
   void              HandleC(const int handle)           { this.m_handle_c=handle;     }
   int               HandleC(void)                 const { return this.m_handle_c;     }
   void              Symbol(const string symbol)         { this.m_symbol_name=symbol;  }
   string            Symbol(void)                  const { return this.m_symbol_name;  }
   void              Weight(const double weight)         { this.m_weight=weight;       }   
   double            Weight(void)                  const { return this.m_weight;       }
   void              Bars(const int bars)                { this.m_bars=bars;           }
   int               Bars(void)                    const { return this.m_bars;         }
   bool              Refresh(void);
   void              Refresh(const ENUM_TIMEFRAMES timeframe);
                     CInstrument(const string symbol_name);
                    ~CInstrument(void) {;}
  };
CInstrument::CInstrument(const string symbol_name) : m_weight(0),m_bars(0)
              {
               this.m_symbol_name=symbol_name;
              }
//+------------------------------------------------------------------+
//| CInstrument обновление данных                                    |
//+------------------------------------------------------------------+
bool CInstrument::Refresh(void)
  {
   datetime array[];
   return(::CopyTime(m_symbol_name,PERIOD_CURRENT,0,1,array)==1);
  }
void CInstrument::Refresh(const ENUM_TIMEFRAMES timeframe)
  {
   datetime array[];
   ::CopyTime(m_symbol_name,timeframe,0,1,array);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUSDX_O,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUSDX_H,INDICATOR_DATA);
   SetIndexBuffer(2,BufferUSDX_L,INDICATOR_DATA);
   SetIndexBuffer(3,BufferUSDX_C,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   //---
   EventSetTimer(90);
   //---
   int total=ArraySize(symbols);
   list_instruments.Clear();
   int index_buffer=1;
   for(int i=0; i<total; i++)
     {
      string symbol=symbols[i];
      if(!SymbolCheck(symbol))
         continue;
      CInstrument* instr=new CInstrument(symbol);
      if(instr==NULL)
         continue;
      instr.Weight(weights[i]);
      ResetLastError();
      int handle_o=iMA(symbol,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_OPEN);
      if(handle_o==INVALID_HANDLE)
        {
         Print("The ",symbol," iMA(1) by PRICE_OPEN object was not created: Error ",GetLastError());
         continue;
        }
      int handle_h=iMA(symbol,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_HIGH);
      if(handle_h==INVALID_HANDLE)
        {
         Print("The ",symbol," iMA(1) by PRICE_HIGH object was not created: Error ",GetLastError());
         continue;
        }
      int handle_l=iMA(symbol,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_LOW);
      if(handle_l==INVALID_HANDLE)
        {
         Print("The ",symbol," iMA(1) by PRICE_LOW object was not created: Error ",GetLastError());
         continue;
        }
      int handle_c=iMA(symbol,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_CLOSE);
      if(handle_c==INVALID_HANDLE)
        {
         Print("The ",symbol," iMA(1) by PRICE_CLOSE object was not created: Error ",GetLastError());
         continue;
        }
      instr.HandleO(handle_o);
      instr.HandleH(handle_h);
      instr.HandleL(handle_l);
      instr.HandleC(handle_c);
      index_buffer+=4;
      SetIndexBuffer(index_buffer,instr.m_buffer_o,INDICATOR_CALCULATIONS);
      SetIndexBuffer(index_buffer+1,instr.m_buffer_h,INDICATOR_CALCULATIONS);
      SetIndexBuffer(index_buffer+2,instr.m_buffer_l,INDICATOR_CALCULATIONS);
      SetIndexBuffer(index_buffer+3,instr.m_buffer_c,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(instr.m_buffer_o,true);
      ArraySetAsSeries(instr.m_buffer_h,true);
      ArraySetAsSeries(instr.m_buffer_l,true);
      ArraySetAsSeries(instr.m_buffer_c,true);
      list_instruments.Add(instr);
     }
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"USD Index Candle");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUSDX_O,true);
   ArraySetAsSeries(BufferUSDX_H,true);
   ArraySetAsSeries(BufferUSDX_L,true);
   ArraySetAsSeries(BufferUSDX_C,true);
   ArraySetAsSeries(BufferColors,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int total=list_instruments.Total();
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferUSDX_O,EMPTY_VALUE);
      ArrayInitialize(BufferUSDX_H,EMPTY_VALUE);
      ArrayInitialize(BufferUSDX_L,EMPTY_VALUE);
      ArrayInitialize(BufferUSDX_C,EMPTY_VALUE);
      for(int j=0; j<total; j++)
        {
         CInstrument* instr=list_instruments.At(j);
         if(instr==NULL)
            continue;
         ArrayInitialize(instr.m_buffer_o,0);
         ArrayInitialize(instr.m_buffer_h,0);
         ArrayInitialize(instr.m_buffer_l,0);
         ArrayInitialize(instr.m_buffer_c,0);
         int bars=(instr.Symbol()==Symbol() ? rates_total : Bars(instr.Symbol(),PERIOD_CURRENT));
         instr.Bars(bars);
        }
     }
//--- Подготовка данных
   int min_bars=rates_total;
   for(int j=0; j<total; j++)
     {
      CInstrument* instr=list_instruments.At(j);
      if(instr==NULL)
         continue;
      instr.Refresh();
      int bars=(instr.Symbol()==Symbol() ? rates_total : Bars(instr.Symbol(),PERIOD_CURRENT));
      if(bars<min_bars) min_bars=bars;
      int copied=0,count=(limit==0 ? 1 : (instr.Symbol()==Symbol() ? rates_total : instr.Bars()));
      copied=CopyBuffer(instr.HandleO(),0,0,count,instr.m_buffer_o);
      if(copied<=0) return 0;
      copied=CopyBuffer(instr.HandleH(),0,0,count,instr.m_buffer_h);
      if(copied<=0) return 0;
      copied=CopyBuffer(instr.HandleL(),0,0,count,instr.m_buffer_l);
      if(copied<=0) return 0;
      copied=CopyBuffer(instr.HandleC(),0,0,count,instr.m_buffer_c);
      if(copied<=0) return 0;
     }
   int limit1=(limit>1 ? min_bars-1 : 0);
//--- Расчёт индикатора
   for(int i=limit1; i>=0 && !IsStopped(); i--)
     {
      double xO=50.14348112;
      double xH=50.14348112;
      double xL=50.14348112;
      double xC=50.14348112;
      for(int j=0; j<total; j++)
        {
         CInstrument* instr=list_instruments.At(j);
         if(instr==NULL)
            continue;
         string symbol=instr.Symbol();
         int bar=BarShift(symbol,PERIOD_CURRENT,Time(symbol,i));
         if(bar==WRONG_VALUE || bar>instr.Bars()-1)
            continue;
         double power=instr.Weight();
         double price_ma_o=instr.m_buffer_o[bar];
         double coeff_o=pow(price_ma_o,power);
         xO*=coeff_o;
         double price_ma_h=instr.m_buffer_h[bar];
         double coeff_h=pow(price_ma_h,power);
         xH*=coeff_h;
         double price_ma_l=instr.m_buffer_l[bar];
         double coeff_l=pow(price_ma_l,power);
         xL*=coeff_l;
         double price_ma_c=instr.m_buffer_c[bar];
         double coeff_c=pow(price_ma_c,power);
         xC*=coeff_c;
        }
      BufferUSDX_O[i]=(InpReverse ? 1/xO : xO);
      BufferUSDX_H[i]=(InpReverse ? 1/xH : xH);
      BufferUSDX_L[i]=(InpReverse ? 1/xL : xL);
      BufferUSDX_C[i]=(InpReverse ? 1/xC : xC);
      //---
      BufferColors[i]=(BufferUSDX_O[i]<BufferUSDX_C[i] ? 0 : BufferUSDX_O[i]>BufferUSDX_C[i] ? 1 : 2);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   int total=list_instruments.Total();
   for(int i=0;i<total;i++)
     {
      CInstrument* instr=list_instruments.At(i);
      if(instr==NULL)
         continue;
      int count=9;
      for(int j=0;j<count;j++)
        {
         ENUM_TIMEFRAMES timeframe=(ENUM_TIMEFRAMES)timeframes[j];
         instr.Refresh(timeframe);
        }
     }
  }
//+------------------------------------------------------------------+
//| Проверка символа                                                 |
//+------------------------------------------------------------------+
bool SymbolCheck(const string symbol_name)
  {
   long select=0;
   ResetLastError();
   if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT,select))
     {
      int err=GetLastError();
      Print("Error: ",err," Symbol ",symbol_name," does not exist");
      return false;
     }
   else
     {
      if(select) return true;
      ResetLastError();
      if(!SymbolSelect(symbol_name,true))
        {
         int err=GetLastError();
         Print("Error selected ",symbol_name,": ",err);
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Возвращает Time                                                  |
//+------------------------------------------------------------------+
datetime Time(const string symbol_name,const int shift)
  {
   datetime array[];
   if(CopyTime(symbol_name,PERIOD_CURRENT,shift,1,array)==1)
      return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/forum/743/page11#comment_7010041         |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   int res=Bars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==Bars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(WRONG_VALUE);
   return res;
  } 
//+------------------------------------------------------------------+
