//+------------------------------------------------------------------+
//|            Vortex Oscillator System(barabashkakvn's edition).mq5 |
//|This system is based on the Vortex Oscillator indicator           |
//+------------------------------------------------------------------+
#property version   "1.001"
#property description "ATTENTION!"
#property description "For successful operation it is necessary to have the compiled"
#property description "\"Vortex Oscillator indicator\": https://www.mql5.com/ru/code/19460/"
#property description "in the folder [data folder]\\MQL5\\Indicators\\"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
#define  COMMENTARY_LONG      	"Vortex Oscillator Buy"
#define  COMMENTARY_SHORT        "Vortex Oscillator Sell"
#define  MODE_VO                0
//--- input parameters
input int      VI_Length            = 14;       // Vortex indicator: VI_Length
input double   InpLots              = 0.1;      // Lots
input bool     Use_Buy_StopLoss     = false;    // Use Buy Stop Loss or not, default is false
input bool     Use_Buy_TakeProfit   = false;    // Use Buy Take Profit or not, default is false
input bool     Use_Sell_StopLoss    = false;    // Use Sell Stop Loss or not, default is false
input bool     Use_Sell_TakeProfit  = false;    // Use Sell Take Profit or not, default is false
input double   VO_Buy               = -0.75;    // VO value at which a Buy position is initiated
input double   VO_Buy_StopLoss      = -1.00;    // If "Use Buy Stop Loss" = true, if this VO value is hit the Buy position is closed
input double   VO_Buy_TakeProfit    = 0.00;     // If "Use Buy Take Profit" = true, if this VO value is hit the Buy position is closed
input double   VO_Sell              = 0.75;     // VO value at which a Sell position is initiated
input double   VO_Sell_StopLoss     = 1.00;     // If "Use Sell Stop Loss" = true, if this VO value is hit the Sell position is closed
input double   VO_Sell_TakeProfit   = 0.00;     // If "Use Sell Take Profit" = true, if this VO value is hit the Sell position is closed
input ulong    m_magic              = 11478495; // magic number
//---
ulong          m_slippage=30;       // slippage
//---
int            handle_iCustom;                  // variable for storing the handle of the iCustom indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(InpLots<=0.0)
     {
      Print("The \"Lots\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
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
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),Period(),"Vortex Oscillator",VI_Length);
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
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
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   bool LongSetupExists=false;      // flag for Long setups
   bool ShortSetupExists=false;     // flag for Short setups
   double VortexOsc=0.0;            // value of the Vortex Oscillator

   VortexOsc=iCustomGet(MODE_VO,1); // value from the just-closed bar
   Comment("VortexOsc = ",DoubleToString(VortexOsc,m_symbol.Digits()));
   if(Use_Buy_StopLoss)
     {
      if(VortexOsc<=VO_Buy && VortexOsc>VO_Buy_StopLoss) // two conditions must be met if using the stop
        {
         LongSetupExists=true;
         ShortSetupExists=false;
        }
     }
   else // "Use Buy Stop Loss" is false
     {
      if(VortexOsc<=VO_Buy) // only one condition must be met if not using the stop
        {
         LongSetupExists=true;
         ShortSetupExists=false;
        }
     }
   if(Use_Sell_StopLoss)
     {
      if(VortexOsc>=VO_Sell && VortexOsc<VO_Sell_StopLoss) // two conditions must be met if using the stop
        {
         ShortSetupExists= true;
         LongSetupExists = false;
        }
     }
   else // "Use Sell Stop Loss" is false
     {
      if(VortexOsc>=VO_Sell) // only one condition must be met if not using the stop
        {
         ShortSetupExists= true;
         LongSetupExists = false;
        }
     }
   if(VortexOsc>=VO_Buy && VortexOsc<=VO_Sell) // when the oscillator is between the extremes...
     {
      LongSetupExists=false; //...set both flags to false
      ShortSetupExists=false;
     }

   if(LongSetupExists)
      Comment("LongSetupExists is \"true\"");
   else
      Comment("LongSetupExists is \"false\"");
   if(ShortSetupExists)
      Comment("ShortSetupExists is \"true\"");
   else
      Comment("ShortSetupExists is \"false\"");

   if(LongSetupExists)
     {
      ClosePositions(POSITION_TYPE_SELL);
      if(!RefreshRates())
        {
         PrevBars=iTime(m_symbol.Name(),Period(),1);
         return;
        }
      OpenBuy(0.0,0.0,COMMENTARY_LONG);
     }
   else if(ShortSetupExists)
     {
      ClosePositions(POSITION_TYPE_BUY);
      if(!RefreshRates())
        {
         PrevBars=iTime(m_symbol.Name(),Period(),1);
         return;
        }
      OpenSell(0.0,0.0,COMMENTARY_SHORT);
     }
//--- monitoring the open position
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(Use_Buy_StopLoss)
                 {
                  if(VortexOsc<=VO_Buy_StopLoss) // stopped out!
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                 }
               if(Use_Buy_TakeProfit)
                 {
                  if(VortexOsc>=VO_Buy_TakeProfit) // profit target achieved!
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                 }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(Use_Sell_StopLoss)
                 {
                  if(VortexOsc>=VO_Sell_StopLoss) // stopped out!
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                 }
               if(Use_Sell_TakeProfit)
                 {
                  if(VortexOsc<=VO_Sell_TakeProfit) // profit target achieved!
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                 }
              }
           }
//---
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
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
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCustom,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double sl,double tp,const string comment)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,NULL,m_symbol.Ask(),sl,tp,comment))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double sl,double tp,const string comment)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,NULL,m_symbol.Bid(),sl,tp,comment))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
