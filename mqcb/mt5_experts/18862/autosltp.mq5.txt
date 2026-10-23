//+------------------------------------------------------------------+
//|                                                     AutoSLTP.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Management of stop loss and take profit levels. The settings are taken from the file"
#property description "File format:"
#property description "name_symbol*position_type*sl*tp"
#property description "Example:"
#property description "AUDCAD*POSITION_TYPE_BUY*50*96"
#property description "AUDCAD*POSITION_TYPE_SELL*40*46"
#property description "USDJPY*POSITION_TYPE_SELL*80*38"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Files\FileTxt.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CFileTxt       m_file_txt;                   // file txt object
//+------------------------------------------------------------------+
//| Struct SLTP                                                      |
//+------------------------------------------------------------------+
struct STRUCT_SLTP
  {
   string            symbol_name;   // symbol name
   ENUM_POSITION_TYPE pos_type;     // position type
   ushort            stop_loss;     // stop loss (in pips)
   ushort            take_profit;   // take profit(in pips)
  };
STRUCT_SLTP arr_struct_sltp[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- It frees up a buffer of any dynamic array and sets the size of the zero dimension to 0.
   ArrayFree(arr_struct_sltp);
//---
   if(!m_file_txt.Open("AutoSLTP//AutoSLTP.txt",FILE_READ))
     {
      Print("Error open \"AutoSLTP//AutoSLTP.txt\" #",GetLastError());
      return(INIT_FAILED);
     }
   Print("Tell: ",m_file_txt.Tell());

   string sep="*";                // A separator as a character 
   ushort u_sep;                  // The code of the separator character 

//--- Get the separator code 
   u_sep=StringGetCharacter(sep,0);
   while(!m_file_txt.IsEnding())
     {
      //--- read and print the string 
      string to_split=m_file_txt.ReadString();
      Print(to_split);

      string result[];               // An array to get strings 
      //--- Split the string to substrings 
      int k=StringSplit(to_split,u_sep,result);
      if(k!=4)
        {
         Print("Error: Wrong number of parameters");
         return(INIT_FAILED);
        }
      //--- Show a comment  
      PrintFormat("Strings obtained: %d. Used separator '%s' with the code %d",k,sep,u_sep);
      //--- Now output all obtained strings 
      if(k>0)
        {
         for(int i=0;i<k;i++)
           {
            PrintFormat("result[%d]=\"%s\"",i,result[i]);
           }
        }
      string temp_symbol_name=result[0];
      if(!m_symbol.Name(temp_symbol_name)) // sets symbol name
        {
         Print("Error: Wrong parameter \"Symbol Name\"");
         return(INIT_FAILED);
        }

      ENUM_POSITION_TYPE   temp_pos_type=-1;
      string txt=result[1];
      if(txt=="POSITION_TYPE_BUY")
         temp_pos_type=POSITION_TYPE_BUY;
      else if(txt=="POSITION_TYPE_SELL")
         temp_pos_type=POSITION_TYPE_SELL;
      else
        {
         Print("Error: Wrong parameter \"Position Type\"");
         return(INIT_FAILED);
        }

      ushort temp_stop_loss=0;
      long sl_long=StringToInteger(result[2]);
      if(sl_long<0 || sl_long==0)
        {
         Print("Error: Wrong parameter \"Stop Loss\"");
         return(INIT_FAILED);
        }
      temp_stop_loss=(ushort)sl_long;

      ushort temp_take_profit=0;
      long tp_long=StringToInteger(result[3]);

      if(tp_long<0 || tp_long==0)
        {
         Print("Error: Wrong parameter \"Take Profit\"");
         return(INIT_FAILED);
        }
      temp_take_profit=(ushort)tp_long;
      //---
      int size=ArraySize(arr_struct_sltp);
      ArrayResize(arr_struct_sltp,size+1);
      arr_struct_sltp[size].symbol_name=temp_symbol_name;
      arr_struct_sltp[size].pos_type=temp_pos_type;
      arr_struct_sltp[size].stop_loss=temp_stop_loss;
      arr_struct_sltp[size].take_profit=temp_take_profit;
     }
   m_file_txt.Close();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   m_file_txt.Close();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   static datetime prev_time=0;
   datetime time_current=TimeCurrent();
   if(time_current-prev_time<10)
      return;
   prev_time=time_current;
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
        {
         string               symbol_name=m_position.Symbol();
         ENUM_POSITION_TYPE   pos_type=m_position.PositionType();
         ushort               stop_loss=0;      // stop loss (in pips)
         ushort               take_profit=0;    // take profit(in pips)

         bool search=false;
         for(int j=0;j<ArraySize(arr_struct_sltp);j++)
           {
            if(symbol_name==arr_struct_sltp[j].symbol_name)
              {
               stop_loss   =arr_struct_sltp[j].stop_loss;
               take_profit =arr_struct_sltp[j].take_profit;

               search=true;
               break;
              }
           }
         if(!search)
            continue;

         if(m_position.PositionType()==POSITION_TYPE_BUY)
            Trailing(symbol_name,stop_loss,take_profit);

         if(m_position.PositionType()==POSITION_TYPE_SELL)
            Trailing(symbol_name,stop_loss,take_profit);
        }
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing(const string symbol,const ushort sl,const ushort tp)
  {
   double m_adjusted_point;   // point value adjusted for 3 or 5 points
   if(!m_symbol.Name(symbol)) // sets symbol name
      return;
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   double ExtStopLoss   =sl*m_adjusted_point;
   double ExtTakeProfit =tp*m_adjusted_point;

   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      double new_sl=m_position.StopLoss();
      double new_tp=m_position.TakeProfit();
      if(m_position.StopLoss()<m_position.PriceCurrent()-ExtStopLoss)
         new_sl=m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtStopLoss);
      if(m_position.TakeProfit()<m_position.PriceCurrent()+ExtTakeProfit)
         new_tp=m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTakeProfit);

      if(!m_trade.PositionModify(m_position.Ticket(),new_sl,new_tp))
         Print("Modify ",m_position.Ticket(),
               " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
     }
   else
     {
      double new_sl=m_position.StopLoss();
      double new_tp=m_position.TakeProfit();
      if(m_position.StopLoss()>m_position.PriceCurrent()+ExtStopLoss || m_position.StopLoss()==0)
         new_sl=m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtStopLoss);
      if(m_position.TakeProfit()>m_position.PriceCurrent()-ExtTakeProfit)
         new_tp=m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTakeProfit);

      if(!m_trade.PositionModify(m_position.Ticket(),new_sl,new_tp))
         Print("Modify ",m_position.Ticket(),
               " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
     }
  }
//+------------------------------------------------------------------+
