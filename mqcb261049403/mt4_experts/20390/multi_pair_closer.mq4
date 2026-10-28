//+------------------------------------------------------------------+
//|                                                Multi Pair Closer |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Closes all positions on watched pairs when net profit hits the target."
#property strict

input string WatchedPairs="GBPUSDpro,USDCADpro,USDCHFpro,USDSEKpro";// Currency basket
input double ProfitTarget=60; // Profit target in account currency
input double MaxLoss=60; // Maximum allowed loss in account currency
input int Slippage=10; // Allowed slippage when closing orders
input int MinAge=60; // Minimum age of order in seconds
string watchedPairs=WatchedPairs;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidateSettings()
  {
   bool out=true;
   string message="";
   if(watchedPairs=="")
     {
      message=("Your watched pairs is empty, using current symbol only.");
      watchedPairs=Symbol();
     }
   else if(!ValidateWatchedPairsExist())
     {
      message=("One of your watched symbols could not be found on the server.");
      out=false;
     }
   else if(ProfitTarget<0)
     {
      message=("The ProfitTarget must be greater than or equal to zero.");
      out=false;
     }
   else if(MaxLoss<0)
     {
      message=("The MaxLoss must be greater than or equal to zero.");
      out=false;
     }
   else if(Slippage<0)
     {
      message=("The Slippage must be greater than or equal to zero.");
      out=false;
     }
   else if(MinAge<0)
     {
      message=("The MinAge must be greater than or equal to zero.");
      out=false;
     }

   if(out==false)
     {
      Print("");
      Print("!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~");
      Print("");
      Print("User Settings validation failed.");
      Print(message);
      Print("");
      Print("!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~");
      Print("");
      ExpertRemove();
     }

   return out;
  }
//+------------------------------------------------------------------+
//|Rules to stop the bot from even trying to trade                   |
//+------------------------------------------------------------------+
bool CanTrade()
  {
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrders(string symbol,datetime minimumAge)
  {
   int ticket,i;
//----
   while(PairOpenPositionCount(symbol,minimumAge)>0)
     {
      for(i=0;i<OrdersTotal();i++)
        {
         ticket=OrderSelect(i,SELECT_BY_POS);
         if(OrderType()==OP_BUY && OrderSymbol()==symbol && (OrderOpenTime()<=minimumAge))
           {
            if(OrderClose(OrderTicket(),OrderLots(),Bid,Slippage)==false)
              {
               Print(GetLastError());
              }
           }
         if(OrderType()==OP_SELL && OrderSymbol()==symbol && (OrderOpenTime()<=minimumAge))
           {
            if(OrderClose(OrderTicket(),OrderLots(),Ask,Slippage)==false)
              {
               Print(GetLastError());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|Gets the highest price paid for any order on the given pair.      |
//+------------------------------------------------------------------+
double PairOpenPositionCount(string symbol,datetime minimumAge)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)
         && (OrderType()==OP_BUY || OrderType()==OP_SELL)
         && OrderSymbol()==symbol
         && (OrderOpenTime()<=minimumAge))
        {
         num=num+1;
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ParseCsv(string str,string &result[])
  {
   string sep=",";
   ushort u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(str,u_sep,result);
   return k;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DoesSymbolExist(string symbol,bool useMarketWatchOnly)
  {
   bool out=false;
   int ct=SymbolsTotal(useMarketWatchOnly);
   for(int i=0; i<ct; i++)
     {
      if(symbol==SymbolName(i,useMarketWatchOnly))
        {
         out=true;
        }
     }
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidateWatchedPairsExist()
  {
   bool out=true;
   string result[];
   int k=ParseCsv(watchedPairs,result);

   if(k>0)
     {
      for(int i=0;i<k;i++)
        {
         //PrintFormat("Checking Symbol %s",result[i]);
         if(!DoesSymbolExist(result[i],false))
           {
            out=false;
            PrintFormat("Symbol %s does not exist.",result[i]);
           }
         else
           {
            //PrintFormat("Symbol %s exists.",result[i]);
           }
        }
     }
   return out;
  }
//+------------------------------------------------------------------+
//|Gets the current net profit of open positions on the given        |
//|currency pair.                                                    |
//+------------------------------------------------------------------+
double PairProfit(string symbol)
  {
   double sum=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && (OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderSymbol()==symbol)
        {
         sum=sum+OrderProfit();
        }
     }
   return sum;
  }
//for testing
//datetime time=Time[0];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   /**
    * For Testing
    * if(Time[0]==time) return;
    * time=Time[0];
    * OrderSend(Symbol(),OP_SELL,0.01,Bid,10,0,0);
    */
   if(!ValidateSettings())
     {
      return;
     }
   if(!CanTrade())
     {
      return;
     }

   string result[];
   int k=ParseCsv(watchedPairs,result);

   string comment="";
   string symbol="";
   double p=0;
   double netProfit=0;
   if(k>0)
     {
      for(int i=0;i<k;i++)
        {
         symbol=result[i];
         p=PairProfit(symbol);
         netProfit+=p;
         comment+=StringFormat("%s : %f\r\n",symbol,p);
         p=0;
         symbol="";
        }
     }
   comment+=StringFormat("Net : %f\r\n",netProfit);
   Comment(comment);
   if(ProfitTarget>0 && netProfit>=ProfitTarget)
     {
      Print("Profit target reached, closing orders.");
      for(int j=0;j<k;j++)
        {
         symbol=result[j];
         CloseOrders(symbol,((datetime)TimeCurrent()-MinAge));
        }
     }
   if(MaxLoss>0 && netProfit<=(MaxLoss*-1))
     {
      Print("Maximum loss reached, closing orders.");
      for(int j=0;j<k;j++)
        {
         symbol=result[j];
         CloseOrders(symbol,((datetime)TimeCurrent()-MinAge));
        }
     }
  }
//+------------------------------------------------------------------+
