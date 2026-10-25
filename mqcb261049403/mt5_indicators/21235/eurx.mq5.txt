//+------------------------------------------------------------------+
//|                                                         EURX.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "EUR Index"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot USDX
#property indicator_label1  "EUR Index"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input ENUM_INPUT_YES_NO    InpReverse        =  INPUT_NO;      // Reverse
//--- indicator buffers
double         BufferUSDX[];
//--- includes
#include <Arrays\ArrayObj.mqh>
//--- global variables
double      scale_factor;
CArrayObj   list_instruments;
//---
string symbols[]={"EURUSD","EURGBP","EURJPY","EURSEK","EURCHF"};
double weights[]={0.3155,0.3056,0.1891,0.0785,0.1113};
//+------------------------------------------------------------------+
//| Класс объекта инструмент                                         |
//+------------------------------------------------------------------+
class CInstrument : public CObject
  {
private:
   string            m_symbol_name;                      // Symbol name
   double            m_weight;                           // Symbol weight
   int               m_bars;                             // Symbol Bars
   int               m_handle;                           // Handle MA
public:
   double            m_buffer[];                         // BufferMA[]
   void              Handle(const int handle)            { this.m_handle=handle;       }
   int               Handle(void)                  const { return this.m_handle;       }
   void              Symbol(const string symbol)         { this.m_symbol_name=symbol;  }
   string            Symbol(void)                  const { return this.m_symbol_name;  }
   void              Weight(const double weight)         { this.m_weight=weight;       }   
   double            Weight(void)                  const { return this.m_weight;       }
   void              Bars(const int bars)                { this.m_bars=bars;           }
   int               Bars(void)                    const { return this.m_bars;         }
   bool              Refresh(void);
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
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUSDX,INDICATOR_DATA);
   int total=ArraySize(symbols);
   list_instruments.Clear();
   int index_buffer=0;
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
      int handle=iMA(symbol,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
      if(handle==INVALID_HANDLE)
        {
         Print("The ",symbol," iMA(1) object was not created: Error ",GetLastError());
         continue;
        }
      instr.Handle(handle);
      index_buffer++;
      SetIndexBuffer(index_buffer,instr.m_buffer,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(instr.m_buffer,true);
      list_instruments.Add(instr);
     }
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"EUR Index");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUSDX,true);
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
      ArrayInitialize(BufferUSDX,EMPTY_VALUE);
      for(int j=0; j<total; j++)
        {
         CInstrument* instr=list_instruments.At(j);
         if(instr==NULL)
            continue;
         ArrayInitialize(instr.m_buffer,0);
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
      copied=CopyBuffer(instr.Handle(),0,0,count,instr.m_buffer);
      if(copied<=0) return 0;
     }
   int limit1=(limit>1 ? min_bars-1 : 0);
//--- Расчёт индикатора
   for(int i=limit1; i>=0 && !IsStopped(); i--)
     {
      double x=34.38805726;
      for(int j=0; j<total; j++)
        {
         CInstrument* instr=list_instruments.At(j);
         if(instr==NULL)
            continue;
         string symbol=instr.Symbol();
         int bar=BarShift(symbol,PERIOD_CURRENT,Time(symbol,i));
         if(bar==WRONG_VALUE || bar>instr.Bars()-1)
            continue;
         double price_ma=instr.m_buffer[bar];
         double power=instr.Weight();
         double coeff=pow(price_ma,power);
         x*=coeff;
        }
      BufferUSDX[i]=(InpReverse ? 1/x : x);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
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
