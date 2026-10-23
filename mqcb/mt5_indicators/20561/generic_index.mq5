//+------------------------------------------------------------------+
//|                                                Generic_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Generic Index"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot GI
#property indicator_label1  "GIndex"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,                      // Yes
   INPUT_NO    =  0                       // No
  };
//--- input parameters
input string            InpIndex          =  "USD";      // Index
input ENUM_INPUT_YES_NO InpInverse        =  INPUT_NO;   // Inverse
input string            InpInstrument1    =  "EURUSD";   // Instrument 1
input ENUM_INPUT_YES_NO InpUseInstrument1 =  INPUT_YES;  // Use instrument 1
input string            InpInstrument2    =  "USDJPY";   // Instrument 2
input ENUM_INPUT_YES_NO InpUseInstrument2 =  INPUT_YES;  // Use instrument 2
input string            InpInstrument3    =  "GBPUSD";   // Instrument 3
input ENUM_INPUT_YES_NO InpUseInstrument3 =  INPUT_YES;  // Use instrument 3
input string            InpInstrument4    =  "USDCHF";   // Instrument 4
input ENUM_INPUT_YES_NO InpUseInstrument4 =  INPUT_YES;  // Use instrument 4
input string            InpInstrument5    =  "USDCAD";   // Instrument 5
input ENUM_INPUT_YES_NO InpUseInstrument5 =  INPUT_YES;  // Use instrument 5
input string            InpInstrument6    =  "NZDUSD";   // Instrument 6
input ENUM_INPUT_YES_NO InpUseInstrument6 =  INPUT_YES;  // Use instrument 6
input string            InpInstrument7    =  "AUDUSD";   // Instrument 7
input ENUM_INPUT_YES_NO InpUseInstrument7 =  INPUT_YES;  // Use instrument 7
input string            InpInstrument8    =  "USDSEK";   // Instrument 8
input ENUM_INPUT_YES_NO InpUseInstrument8 =  INPUT_YES;  // Use instrument 8
input string            InpInstrument9    =  "USDRUB";   // Instrument 9
input ENUM_INPUT_YES_NO InpUseInstrument9 =  INPUT_YES;  // Use instrument 9
input string            InpInstrument10   =  "XAUUSD";   // Instrument 10
input ENUM_INPUT_YES_NO InpUseInstrument10=  INPUT_YES;  // Use instrument 10
//--- indicator buffers
double         BufferGI[];
//--- includes
#include <Arrays\ArrayObj.mqh>
//--- global variables
double      scale_factor;
CArrayObj   list_instruments;
//+------------------------------------------------------------------+
//| Класс объекта инструмент                                         |
//+------------------------------------------------------------------+
class CInstrument : public CObject
  {
private:
   string            m_symbol_main;             // Main symbol name
   string            m_symbol_name;             // Symbol name
   double            m_weight;                  // Symbol weight
   int               m_bars;                    // Symbol Bars
public:
   string            Symbol(void)            const { return this.m_symbol_name;  }
   void              SetSignOfWeight(void);
   double            GetSignOfWeight(void)   const { return this.m_weight; }
   void              Bars(const int bars)          { this.m_bars=bars;     }
   int               Bars(void)              const { return this.m_bars;   }
   bool              Refresh(void);
                     CInstrument(const string main_symbol,const string symbol_name);
                    ~CInstrument(void) {;}
  };
CInstrument::CInstrument(const string main_symbol,const string symbol_name) : m_weight(0),m_bars(0)
              {
               this.m_symbol_main=main_symbol;
               this.m_symbol_name=symbol_name;
              }
//+------------------------------------------------------------------+
//| CInstrument Расчёт инструмента                                   |
//+------------------------------------------------------------------+
void CInstrument::SetSignOfWeight(void)
  {
   string first=::StringSubstr(this.m_symbol_name,0,3);
   string second=::StringSubstr(this.m_symbol_name,3,3);
   this.m_weight=(m_symbol_main==first ? 1 : -1);
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
//--- set timer
   EventSetTimer(90);
//--- set global variables
   list_instruments.Sort();
   scale_factor=InitInstruments();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferGI,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Generic Index "+InpIndex);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferGI,true);
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
   int min_bars=4;
   if(rates_total<min_bars || !CheckBars(rates_total,min_bars)) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferGI,EMPTY_VALUE);
     }
   int limit_min=fmin(rates_total,MinBars())-1;
//--- Расчёт индикатора
   int total=(limit==0 ? limit : limit_min);
   int count=list_instruments.Total();
   for(int i=total; i>=0 && !IsStopped(); i--)
     {
      double X=1;
      for(int j=0; j<count; j++)
        {
         CInstrument* instr=list_instruments.At(j);
         if(instr==NULL)
            continue;
         string symbol=instr.Symbol();
         int IndexBar=BarShift(symbol,0,time[i]);
         int index_bars=(limit_min<instr.Bars() ? limit_min : instr.Bars());
         int IndexBar0=BarShift(symbol,0,time[index_bars-1]);
         if(IndexBar==WRONG_VALUE || IndexBar0==WRONG_VALUE)
            continue;
         double Close1=Close(symbol,IndexBar);
         double Close0=Close(symbol,IndexBar0);
         X=X*pow(Close1/(Close0>0 ? Close0 : DBL_MIN),instr.GetSignOfWeight());
        }
      BufferGI[i]=X*scale_factor;
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
      instr.Refresh();
     }
   ChartRedraw();
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
//| Проверка количества баров                                        |
//+------------------------------------------------------------------+
bool CheckBars(const int rates_total,int min_bars)
  {
   bool res=true;
   int total=list_instruments.Total();
   for(int i=0; i<total; i++)
     {
      CInstrument* instr=list_instruments.At(i);
      if(instr==NULL)
         continue;
      string symbol=instr.Symbol();
      instr.Bars(symbol==Symbol() ? rates_total : Bars(symbol,PERIOD_CURRENT));
      instr.Refresh();
      if(instr.Bars()<min_bars)
         res=false;
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Возвращает наименьшее количество bars                             |
//+------------------------------------------------------------------+
int MinBars(void)
  {
   int total=list_instruments.Total(), min_bars=INT_MAX;
   for(int i=0; i<total; i++)
     {
      CInstrument* instr=list_instruments.At(i);
      if(instr==NULL)
         continue;
      if(instr.Bars()<min_bars)
         min_bars=instr.Bars();
     }
   return(min_bars==INT_MAX ? WRONG_VALUE : min_bars);
  }
//+------------------------------------------------------------------+
//| Инициализация инструментов                                       |
//+------------------------------------------------------------------+
double InitInstruments(void)
  {
   string array_names[10][2];
   array_names[0][0]=InpInstrument1;   array_names[0][1]=(InpUseInstrument1 ? "u" : NULL);
   array_names[1][0]=InpInstrument2;   array_names[1][1]=(InpUseInstrument2 ? "u" : NULL);
   array_names[2][0]=InpInstrument3;   array_names[2][1]=(InpUseInstrument3 ? "u" : NULL);
   array_names[3][0]=InpInstrument4;   array_names[3][1]=(InpUseInstrument4 ? "u" : NULL);
   array_names[4][0]=InpInstrument5;   array_names[4][1]=(InpUseInstrument5 ? "u" : NULL);
   array_names[5][0]=InpInstrument6;   array_names[5][1]=(InpUseInstrument6 ? "u" : NULL);
   array_names[6][0]=InpInstrument7;   array_names[6][1]=(InpUseInstrument7 ? "u" : NULL);
   array_names[7][0]=InpInstrument8;   array_names[7][1]=(InpUseInstrument8 ? "u" : NULL);
   array_names[8][0]=InpInstrument9;   array_names[8][1]=(InpUseInstrument9 ? "u" : NULL);
   array_names[9][0]=InpInstrument10;  array_names[9][1]=(InpUseInstrument10? "u" : NULL);
   //---
   double x=1.0;
   int total=10;
   for(int i=0; i<total; i++)
     {
      if(array_names[i][1]==NULL)
         continue;
      string name=array_names[i][0];
      if(!SymbolCheck(name))
         continue;
      CInstrument* instr=new CInstrument(InpIndex,name);
      if(instr==NULL)
         continue;
      list_instruments.Add(instr);
      instr.SetSignOfWeight();
      instr.Refresh();
     }
   return CalcWeights();
  }
//+------------------------------------------------------------------+
//| Расчёт веса                                                      |
//+------------------------------------------------------------------+
double CalcWeights(void)
  {
   int total=list_instruments.Total();
   double x=1.0;
   for(int i=0; i<total; i++)
     {
      CInstrument* instr=list_instruments.At(i);
      if(instr==NULL)
         continue;
      double wt=instr.GetSignOfWeight();
      wt/=total*(InpInverse ? -1.0 : 1.0);
      x=x*pow(total,wt);
     }
   return 100.0/x;
  }
//+------------------------------------------------------------------+
//| Возвращает Close                                                 |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const int shift)
  {
   double array[];
   if(CopyClose(symbol_name,PERIOD_CURRENT,shift,1,array)==1)
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
