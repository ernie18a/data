//+------------------------------------------------------------------+
//|                                                   New Random.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.002"
#property description "Three modes of selecting the type of the opened position:" 
#property description "based on the random number generator; BUY-SELL-BUY sequence; SELL-BUY-SELL sequence"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
enum ENUM_RANDOM_TYPE
  {
   RANDOM_TYPE_GENERATOR         =0,         // Random number generator
   RANDOM_TYPE_BUY_SELL_BUY      =1,         // The sequence BUY - SELL - BUY ... 
   RANDOM_TYPE_SELL_BUY_SELL     =2,         // The sequence SELL - BUY - SELL ...  
  };
//--- input parameters
input ENUM_RANDOM_TYPE  InpRandom= 0;        // Random type
input ushort   InpCountMinLots   = 1;        // Count minimal lots
input ushort   InpStopLoss       = 50;       // Stop Loss (in pips)
input ushort   InpTakeProfit     = 50;       // Take Profit (in pips)
//---
ulong          m_ticket;
ulong          m_magic=8263500;              // magic number
ulong          m_slippage=30;                // slippage

double         ExtStopLoss=0;
double         ExtTakeProfit=0;
double         ExtTrailingStop=0;
double         ExtTrailingStep=0;
//--- prefix to store the type of the generator
string prefix_random_type="New Random Random Type";
//--- prefix to store the type of the last opened position (BUY - "0", SELL "1")
string prefix_last_open_type="New Random Last Open Type";

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string text="";
   if(InpRandom==RANDOM_TYPE_GENERATOR)
     {
      //--- initialize the generator of random numbers 
      MathSrand(GetTickCount());

      GlobalVariableDel(prefix_last_open_type);       // unconditional removal global variable "prefix_last_open_type"
      if(!GlobalVariableCheck(prefix_random_type))
         GlobalVariableSet(prefix_random_type,InpRandom);
      else
         GlobalVariableSetOnCondition(prefix_random_type,RANDOM_TYPE_GENERATOR,RANDOM_TYPE_BUY_SELL_BUY || RANDOM_TYPE_SELL_BUY_SELL);
     }
   else
     {
      if(!GlobalVariableCheck(prefix_random_type))
        {
         GlobalVariableSet(prefix_random_type,InpRandom);
         if(!GlobalVariableCheck(prefix_last_open_type))
           {
            if(InpRandom==RANDOM_TYPE_BUY_SELL_BUY)
               GlobalVariableSet(prefix_last_open_type,1);
            else if(InpRandom==RANDOM_TYPE_SELL_BUY_SELL)
               GlobalVariableSet(prefix_last_open_type,0);
           }
        }
      else
        {
         if(GlobalVariableGet(prefix_random_type)!=InpRandom)
           {
            GlobalVariableSet(prefix_random_type,InpRandom);
            if(InpRandom==RANDOM_TYPE_BUY_SELL_BUY)
               GlobalVariableSet(prefix_last_open_type,1);
            else if(InpRandom==RANDOM_TYPE_SELL_BUY_SELL)
               GlobalVariableSet(prefix_last_open_type,0);
           }
         else
           {
            if(!GlobalVariableCheck(prefix_last_open_type))
              {
               if(InpRandom==RANDOM_TYPE_BUY_SELL_BUY)
                  GlobalVariableSet(prefix_last_open_type,1);
               else if(InpRandom==RANDOM_TYPE_SELL_BUY_SELL)
                  GlobalVariableSet(prefix_last_open_type,0);
              }
           }
        }
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpCountMinLots*m_symbol.LotsMin(),err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss    = InpStopLoss*m_adjusted_point;
   ExtTakeProfit  = InpTakeProfit*m_adjusted_point;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   if(total>0)
      return;

   if(!RefreshRates())
      return;

   switch(InpRandom)
     {
      case  RANDOM_TYPE_GENERATOR:
         //--- BUY - "1", SELL "2"
         if(MathRand()%2==0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            m_trade.Sell((double)InpCountMinLots*m_symbol.LotsMin(),m_symbol.Name(),
                         m_symbol.Bid(),
                         m_symbol.NormalizePrice(sl),
                         m_symbol.NormalizePrice(tp));
           }
         else
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            m_trade.Buy((double)InpCountMinLots*m_symbol.LotsMin(),m_symbol.Name(),
                        m_symbol.Ask(),
                        m_symbol.NormalizePrice(sl),
                        m_symbol.NormalizePrice(tp));
           }
         break;
      default:
         //--- BUY - "0", SELL "1"
         if(GlobalVariableGet(prefix_last_open_type)==0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            m_trade.Buy((double)InpCountMinLots*m_symbol.LotsMin(),m_symbol.Name(),
                        m_symbol.Ask(),
                        m_symbol.NormalizePrice(sl),
                        m_symbol.NormalizePrice(tp));
           }
         if(GlobalVariableGet(prefix_last_open_type)==1)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            m_trade.Buy((double)InpCountMinLots*m_symbol.LotsMin(),m_symbol.Name(),
                        m_symbol.Ask(),
                        m_symbol.NormalizePrice(sl),
                        m_symbol.NormalizePrice(tp));
           }
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
// double min_volume=m_symbol.LotsMin();
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
// double max_volume=m_symbol.LotsMax();
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
// double volume_step=m_symbol.LotsStep();
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
