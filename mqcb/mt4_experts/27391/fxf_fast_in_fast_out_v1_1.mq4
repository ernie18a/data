#property copyright "FXNode"
#property link      "http://fxnode.ir"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|  Main Variable                                                   |
//+------------------------------------------------------------------+
extern int									EnterPoint           =  22;               // Points for Order entry
extern int									MaxSpread				=  15;               // Max spread
extern int									TakeProfit				=  250;					// Take profit
extern int									StopLoss					=  500;			   	// Stop loss
extern int 									Magic						=  124578;           // Magic number
extern int									Slippage					=  15;               // Slippage
extern int									VolatilitySize			=  220; 					// Volatility size
extern bool									TrailMyOrders        =  true;					// Trailing stop
extern bool									MoneyManagment       =  true;					// Manage Money for Auto Order lot
extern int									TrailingStop         =  1;						// Trailing distance
extern double 								Risk                 =  5;                // Risk percent
extern double 								MaxOrder             =  10;               // Risk percent
input  ENUM_TIMEFRAMES              TimeFrame            =  PERIOD_M15;       // Working time frame
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//|  GloBalariable                                                   |
//+------------------------------------------------------------------+
string   signal = "";
int      MaxTakeOrder=0;
//====================================================================
//==================================================================== 
//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   ChartSetSymbolPeriod(0,NULL,TimeFrame);
   if (Risk > 100) Risk = 100; if (Risk < 0)   Risk = 1;
   return(INIT_SUCCEEDED);
  }
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//| OnTick Function                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
	if( IsNewCandle() ) MaxTakeOrder=0;
	Signal(); // Signal
	OpenOrders(); // Open orders
   OrderModifyFnct(); // Modify orders
}
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//| Signal Function                                                  |
//+------------------------------------------------------------------+
void Signal()
{
	signal = ""; 
	RefreshRates();
	
	int bardistance   =  int((High[0]-Low[0])/Point()); 
	double   AskBid   =  (Ask+Bid)/2,
	         open     =  Open[0];
	
	if(bardistance>=VolatilitySize)
	{
		// Buy
		if(AskBid<open)signal = "sell";
		
		// Sell
		if(AskBid>open)signal = "buy";
	}
}
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//| OpenOrders Function                                              |
//+------------------------------------------------------------------+
void OpenOrders()
{
	RefreshRates();
	int spread = (int)SymbolInfoInteger(Symbol(),SYMBOL_SPREAD),digits = Digits();
	double point = Point(),ask = Ask,bid = Bid;
	
	// Open orders
	if(spread <= MaxSpread && CountMyOrders("all")==0 && MaxTakeOrder <= MaxOrder)
	{
		// Buy
		if(signal=="buy")
		{
			MaxTakeOrder++;
			double price = NormalizeDouble(ask+EnterPoint*point,digits);
			double sl 	 = (StopLoss==0 ? 0: NormalizeDouble(price-(StopLoss+spread)*point,digits));
			double tp 	 = (TakeProfit==0 ? 0: NormalizeDouble(price+TakeProfit*point,digits));
		
			if(OrderSend(Symbol(),OP_BUYSTOP,CheckLots(Symbol(),Risk, StopLoss, 0.01, MoneyManagment),price,Slippage,sl,tp,"BUY Gravity",Magic)==-1)
				Print("OrderSend - BuyStop error #",GetLastError());
		}
		
		// Sell
		if(signal=="sell")
		{
			MaxTakeOrder++;
			double price = NormalizeDouble(bid-EnterPoint*point,digits);
			double sl = (StopLoss==0 ? 0: NormalizeDouble(price+(StopLoss+spread)*point,digits));
			double tp = (TakeProfit==0 ? 0: NormalizeDouble(price-TakeProfit*point,digits));
		
			if(OrderSend(Symbol(),OP_SELLSTOP,CheckLots(Symbol(),Risk, StopLoss, 0.01, MoneyManagment),price,Slippage,sl,tp,"SELL Gravity",Magic)==-1)
				Print("OrderSend - SellStop error #",GetLastError());
		}
	}
}
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//| CountMyOrders Function                                           |
//+------------------------------------------------------------------+
int CountMyOrders(string type)
{
   int count = 0;
   
    for (int i = OrdersTotal() - 1; i >= 0; i--)
	 {
	 	RefreshRates();
	 	
	   if(OrderSelect(i,SELECT_BY_POS))
	   {
	      if(OrderMagicNumber() == Magic)
	      {
	         if(type=="all")
	            count ++;
	         if(type=="allorders" && OrderType()>1)
	            count ++;
	         if(type=="buy" && OrderType()==0)
	            count ++;
	         if(type=="sell" && OrderType()==1)
	            count ++;
	      }
	   }	
	}
   
   return count;
}
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//| OrderModifyFnct Function                                         |
//+------------------------------------------------------------------+
void OrderModifyFnct()
{
	RefreshRates();
	
	// Delete orders
	if((SymbolInfoInteger(Symbol(),SYMBOL_SPREAD) > MaxSpread))DeleteOrders();
	
	// Modify orders
	for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
   	RefreshRates();
   	
   	if(OrderSelect(i,SELECT_BY_POS))
   	{
	   	int ticket = OrderTicket(),type = OrderType(),spread = (int)SymbolInfoInteger(Symbol(),SYMBOL_SPREAD),digits = Digits();
	   	double openprice = OrderOpenPrice(),ask = Ask,bid = Bid,point = Point();
	   	
	      if(OrderMagicNumber() == Magic) 
	      {
	         if (type == OP_BUYSTOP && (openprice-ask)/point > EnterPoint)
	         {
	         	double price = NormalizeDouble(ask+EnterPoint*point,digits);
					double sl 	 = (StopLoss==0 ? 0: NormalizeDouble(price-(StopLoss+spread)*point,digits));
					double tp 	 = (TakeProfit==0 ? 0: NormalizeDouble(price+TakeProfit*point,digits));
	         	
	         	if(openprice!=price)
	         	{
	               if(!OrderModify(ticket,price,sl,tp,0))
	                  Print("OrderModify - BuyStop has been ended with an error #",GetLastError()); 
               }
	         }
	         
	        if (type == OP_SELLSTOP && (bid-openprice)/point > EnterPoint)
	        {
		        	double price = NormalizeDouble(bid-EnterPoint*point,digits);
					double sl    = (StopLoss==0 ? 0: NormalizeDouble(price+(StopLoss+spread)*point,digits));
					double tp    = (TakeProfit==0 ? 0: NormalizeDouble(price-TakeProfit*point,digits));
					
					if(openprice!=price)
					{
	               if(!OrderModify(ticket,price,sl,tp,0))
	                  Print("OrderModify - SellStop has been ended with an error #",GetLastError()); 
               }
	        } 
	      }
      }
   }
	
	// Trailing stop
	if(TrailMyOrders)
	{
		for (int i = OrdersTotal() - 1; i >= 0; i--)
	   {
	   	RefreshRates();
	   	
	   	if(OrderSelect(i,SELECT_BY_POS))
	   	{
		   	double digits = Digits(),sl  = OrderStopLoss(),open = NormalizeDouble(OrderOpenPrice(),(int)digits),ask = Ask,bid = Bid,point = Point(),tp = NormalizeDouble(OrderTakeProfit(),(int)digits);
		   	int ticket = OrderTicket(),type = OrderType(),spread = (int)SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
		   	
		     if(OrderMagicNumber() == Magic) 
		      {
		         if (type == OP_BUY)
		         {
	               if(sl < NormalizeDouble(bid - (TrailingStop + spread)*point,(int)digits) || sl == 0)
	               {
	                  if(!OrderModify(ticket,open,NormalizeDouble(bid - (TrailingStop + spread)*point,(int)digits),tp,0))
	                     Print("OrderModify - Buy has been ended with an error #",GetLastError()); 
	               }
		         }
		         
		        if (type == OP_SELL)
		        {
	               if(sl > NormalizeDouble(ask + (TrailingStop + spread)*point,(int)digits) || sl == 0)
	               {
	                  if(!OrderModify(ticket,open,NormalizeDouble(ask + (TrailingStop + spread)*point,(int)digits),tp,0))
	                     Print("OrderModify - Sell has been ended with an error #",GetLastError()); 
	               }
		        } 
		      }
	      }
	   }
   }
}
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//| DeleteOrders Function                                            |
//+------------------------------------------------------------------+
void DeleteOrders()
{
	if(CountMyOrders("allorders")>0)
	{
		for (int i = OrdersTotal() - 1; i >= 0; i--)
		 {
		 	RefreshRates();
		 	
		   if(OrderSelect(i,SELECT_BY_POS))
		   {
		      if(OrderMagicNumber() == Magic && OrderType()>1)
		      {
		         if(!OrderDelete(OrderTicket()))
					   Print("OrderDelete has been ended with an error #",GetLastError());	
		      }
		   }	
		}
	}
}	
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//| GetMyLot Function                                                |
//+------------------------------------------------------------------+
double CheckLots (string symbol, double FXrisk,double stopSize, double staticlot, bool AutoLot) 
 {
   double   lots=0;
   double   Margin_required = MarketInfo(symbol, MODE_MARGINREQUIRED),
            MinLot          = MarketInfo(symbol, MODE_MINLOT),
            MaxLot          = MarketInfo(symbol, MODE_MAXLOT),
            Lot_step        = MarketInfo(symbol, MODE_LOTSTEP), 
            Tick_value      = MarketInfo(symbol, MODE_TICKVALUE);      
   if (Lot_step==0) Lot_step=0.01; 
   
   if ( AutoLot == false ) // if money managment is off 
   {
      if (staticlot*Margin_required > AccountFreeMargin()) staticlot=0;
      if (staticlot>0)
       {
         staticlot=MathFloor(staticlot/Lot_step + 0.5)* Lot_step;   
         if (staticlot < MinLot)   staticlot = MinLot;
         if (staticlot > MaxLot)   staticlot = MaxLot;
       }
      return(staticlot);
   }
                        
   if(Tick_value!=0 && stopSize!=0 && FXrisk>0) 
   {
      lots=NormalizeDouble( (AccountBalance()*FXrisk) / (Tick_value*stopSize*150), 2 );
      if (lots < 0.01) lots = 0.01;
   }
   else
     return(0);
   
   if (lots>0)
    {
      lots=MathFloor(lots/Lot_step + 0.5)* Lot_step;   
      if (lots < MinLot)   lots = MinLot;
      if (lots > MaxLot)   lots = MaxLot;
    }
   if ( (lots > 0) && (lots*Margin_required > AccountFreeMargin()) ) 
    {
      Print ("There is not enough margine to take position with",DoubleToStr(lots,2)," lots.");
      lots=0;
    } 
   
   if (lots==0) Print ("There is not enough money to take position.");
    
   return(lots);
 }
 
 datetime NewCandleTime=TimeCurrent();
bool IsNewCandle()
   {
      if(NewCandleTime==iTime(Symbol(),0,0)) return false;
      else
      {
         NewCandleTime=iTime(Symbol(),0,0);
         return true;
      }
   }