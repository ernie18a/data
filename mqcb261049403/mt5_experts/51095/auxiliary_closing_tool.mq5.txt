//+------------------------------------------------------------------+
//|                                       Auxiliary closing tool.mq5 |
//|                                                             YANG |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "YANG"
#property link      "https://forge.mql5.io"
#property version   "1.00"

input double      InpProfit=0;  // How much of a loss is off must enter a negative number
input int         InStop   =10; //How many times the stop loss automatically stop profit
//---
string  label="M_1";     
double  pro_2 = 0;       //Set the earnings value to pass
double  cor_1 = 0;       //Closing price passthrough
int     K_1   =0;        //Bill of sale sign
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
     ObjectCreate(0, label, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, label, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, label, OBJPROP_XDISTANCE, 100);
   ObjectSetInteger(0, label, OBJPROP_YDISTANCE, 400);
   ObjectSetInteger(0, label, OBJPROP_COLOR, clrGoldenrod);
   ObjectSetString(0, label, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, label, OBJPROP_FONTSIZE, 16);
   ObjectSetInteger(0, label, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, label, OBJPROP_BACK, false);
   ObjectSetInteger(0, label, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, label, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, label, OBJPROP_ZORDER, 0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      ObjectDelete(0, label);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
        if(InpProfit>=0) return;   //Does not work without entering a loss value
   double    Stop=0,
       pros=0;
   
   Stop -= InpProfit;
   Stop *= InStop;
   
   pros=ProfitAllPositions();
   if(pros<=InpProfit)           //The stop loss is closed
      CloseAllPositions();
   
   if(K_1 == 1 && pro_2 <= cor_1)  CloseAllPositions();        //Set profit to close position
   else if(K_1 == 2 && pro_2 >= cor_1)  CloseAllPositions();   //Set profit to close position
   else if(K_1 == 0 && pros >= Stop)  CloseAllPositions();                //Close a position at the specified multiple
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Closing function                                            |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   //--- Declares and initializes trade requests and trade request results
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal();   

   for(int i=total-1; i>=0; i--)
     {
      if(ChartSymbol(0) != PositionGetSymbol(i) || PositionGetDouble(POSITION_SL) >0)continue;
      
    
      ulong  position_ticket=PositionGetTicket(i);                                     
      string position_symbol=PositionGetString(POSITION_SYMBOL);                        
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);              
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  
      double volume=PositionGetDouble(POSITION_VOLUME);                                 
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    
      
         
         ZeroMemory(request);
         ZeroMemory(result);
         
         request.action   =TRADE_ACTION_DEAL;        
         request.position =position_ticket;          
         request.symbol   =position_symbol;           
         request.volume   =volume;                   
         request.deviation=20;                        
         request.magic    =0;                        
         
         if(type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         
         if(!OrderSend(request,result))    
            PrintFormat("OrderSend error %d",GetLastError()); 
         
     }
     ObjectSetString(0, label, OBJPROP_TEXT, " ");
  }
//------------------------------------------------------------------ 
//  Calculating profit function
//-----------------------------------------------------------------
double ProfitAllPositions()
  {
   double profit=0.0;
   int x=0;
   pro_2=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
       //This article is mainly to filter the set of stop losses to hold long-term orders
      if(ChartSymbol(0) != PositionGetSymbol(i) || PositionGetDouble(POSITION_SL) > 0)continue;  //Skips with different currencies or stops
      if(PositionGetDouble(POSITION_TP) >0)   //Use a single stop profit value to guide the remaining order stop profit clearance line
      {
            pro_2 = PositionGetDouble(POSITION_TP);  
            
            if(pro_2 > PositionGetDouble(POSITION_PRICE_OPEN))  K_1 =1;   //Pay by judgment  
            else K_1 =2;                                                  //Judgment is a sell order
      }
      cor_1=PositionGetDouble(POSITION_PRICE_CURRENT);
      
      profit += PositionGetDouble(POSITION_PROFIT);
      
      
      if(profit <= 0)  ObjectSetInteger(0, label, OBJPROP_COLOR, Blue);
      else             ObjectSetInteger(0, label, OBJPROP_COLOR, Gold);
         
      x++;  
      ObjectSetString(0, label, OBJPROP_TEXT, DoubleToString(profit,2));
   }
   
   if(pro_2==0) K_1=0;
   if(x==0)
   {
         ObjectSetString(0, label, OBJPROP_TEXT, " ");
   }
//---
   return(profit);
  }