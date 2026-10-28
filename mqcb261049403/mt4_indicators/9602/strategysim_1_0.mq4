/*------------------------------------------------------------------------------

	StrategySim_1.0
	
	Copyright (c) 2010, MQLTools
	All rights reserved.

	Redistribution and use in source and binary forms, with or without modification,
	are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in 
      the documentation and/or other materials provided with the distribution.
    * The name of the MQLTools may not be used to endorse or promote products
      derived from this software without specific prior written permission.
		
	THIS SOFTWARE IS PROVIDED BY THE MQLTOOLS "AS IS" AND ANY EXPRESS
	OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
	OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
	IN NO EVENT SHALL THE MQLTOOLS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
	POSSIBILITY OF SUCH DAMAGE.
	
------------------------------------------------------------------------------*/

#property copyright "© 2010, MQLTools"
#property link      "www.mqltools.com"

#property indicator_chart_window

#include <stdlib.mqh>
#include <WinUser32.mqh>


// EXTERN variables

extern string __1 = "*** Simulator settings ***";
extern string __11 = "MaxLossAtSL - how much loss (in currency) we risk at SL";
extern double MaxLossAtSL = 200.0;
extern color StatisticsColor = Yellow;
extern int BarsBack = 2000;
extern bool WriteToLog = false;

extern string __2 = "*** Trading indicator settings (which matter for simulation) ***";

extern int MAFastBars 	= 10;
extern int MAFastType 	= MODE_EMA;
extern int MAFastPrice 	= PRICE_WEIGHTED;
extern int MASlowBars 	= 30;
extern int MASlowType 	= MODE_SMMA;
extern int MASlowPrice 	= PRICE_WEIGHTED;		
extern int ChandBars 		= 7;				
extern double ChandATRFact = 2.0;	


// CONSTs

#define TRADE_BUY		1
#define TRADE_SELL	-1
#define TRADE_NO_SIG 0


// GLOBAL variables

string	IndName = "StrategySim_1.0";
string	ObjPref = "SS10_";							// prefix for objects
string	CustomIndName = "StrategyIndi_1.0";		// which indicator to use for simulation


color ProfitColor = C'0,100,0';						// profit rect color
color LossColor = C'100,0,0';							// loss rect color
int PLValSize = 10;										// P/L value size

// statistics

double SumTrade=0.0, SumBuyProfit=0.0, SumBuyLoss=0.0, SumSellProfit=0.0, SumSellLoss=0.0;
double SumTotalInCurrency = 0.0;
double MaxLoss=0.0, MaxProfit=0.0;
double MaxLossInCurrency=0.0, MaxProfitInCurrency = 0.0;

int 	CntBuy=0, CntSell=0, CntWeeks=0, CntMonths=0;
int	CntBuyProfit=0, CntBuyLoss=0, CntSellProfit=0, CntSellLoss=0;
datetime StartDT;
datetime TradeDT = 0, TradeExitDT = 0;
double TradeOPrice = 0.0, TradeExitPrice = 0.0;
double TradeStartSL = 0.0;
double TradeResult = 0.0;
double TradeResultInCurrency = 0.0;
int TradeDirection = 0;

// utils

int LogHandle;
double dblPoint;
int iDigits;



//-----------------------------------------------------------------------------
// INIT
//-----------------------------------------------------------------------------

int init()
{	
	IndicatorShortName(IndName);
 
	LogOpen();
	LogWrite(0, "Log for: " + IndName);
	LogWrite(0, "Pair: " + Symbol()+", period: "+Period());
	LogWrite(0, "\n");	
	
	GetPoint();	
	
	RemoveObjects(ObjPref);	
 
	return(0);
}


//-----------------------------------------------------------------------------
// DEINIT
//-----------------------------------------------------------------------------

int deinit()
{
	RemoveObjects(ObjPref);
	
	LogWrite(0, "END log");
	LogClose();

	return(0);
}


//-----------------------------------------------------------------------------
// InitStat
// initializes variables for statistics
//-----------------------------------------------------------------------------

void InitStat()
{
//	LogWrite(0, "---   InitStat");
	
	SumTrade=0.0;
	SumBuyProfit=0.0; SumBuyLoss=0.0;
	SumSellProfit=0.0; SumSellLoss=0.0;
	SumTotalInCurrency = 0.0;
	MaxLoss=0.0; MaxProfit=0.0;
	MaxLossInCurrency=0.0; MaxProfitInCurrency=0.0;

	CntWeeks=0; CntMonths=0;
	
	CntBuy=0; CntSell=0;
	CntBuyProfit=0; CntBuyLoss=0;
	CntSellProfit=0; CntSellLoss=0;

	TradeDT = 0; TradeExitDT = 0;
	TradeOPrice = 0.0; TradeExitPrice = 0.0;
	TradeResult = 0.0; TradeResultInCurrency = 0.0;
	TradeDirection = TRADE_NO_SIG;	
}


//-----------------------------------------------------------------------------
// GetIndiSignals
//-----------------------------------------------------------------------------

void GetIndiSignals(int BarNum, double& BuySignal, double& SellSignal, double& ExitSignal, double& SL)
{
	BuySignal = 0.0; SellSignal = 0.0;
	ExitSignal = 0.0; if (BarNum > 0) SL = 0.0;
		

//	LogWrite(0, "---   GetIndiSignals");
	
	BuySignal = iCustom(	NULL, 0, CustomIndName,
								MAFastBars, MAFastType, MAFastPrice, MASlowBars, MASlowType, MASlowPrice, 
								ChandBars, ChandATRFact,
								1.0, 0, BarsBack, Snow, "", false, false, false,
	  							0, BarNum);
	SellSignal = iCustom(NULL, 0, CustomIndName,
								MAFastBars, MAFastType, MAFastPrice, MASlowBars, MASlowType, MASlowPrice, 
								ChandBars, ChandATRFact,
								1.0, 0, BarsBack, Snow, "", false, false, false,
								1, BarNum);
	
	// here both exits (buy and sell) are taken as one signal, since it is clear at the processing stage which is which
	ExitSignal = iCustom(NULL, 0, CustomIndName,
								MAFastBars, MAFastType, MAFastPrice, MASlowBars, MASlowType, MASlowPrice, 
								ChandBars, ChandATRFact,
								1.0, 0, BarsBack, Snow, "", false, false, false,
							 	2, BarNum);
	ExitSignal += iCustom(NULL, 0, CustomIndName,
								MAFastBars, MAFastType, MAFastPrice, MASlowBars, MASlowType, MASlowPrice, 
								ChandBars, ChandATRFact,
								1.0, 0, BarsBack, Snow, "", false, false, false,
					 			3, BarNum);	
	
	// we want first SL after buy or sell signal
	SL = iCustom(NULL, 0, CustomIndName,
								MAFastBars, MAFastType, MAFastPrice, MASlowBars, MASlowType, MASlowPrice, 
								ChandBars, ChandATRFact,
								1.0, 0, BarsBack, Snow, "", false, false, false,
								4, BarNum-1);
}


//-----------------------------------------------------------------------------
// FindExitSignal
// searches bars from BarNum-1 to 1, if there is an exit signal
//-----------------------------------------------------------------------------

int FindExitSignal(int BarNum, double& ExitSignal)
{
	int i;
	double BuyS, SellS, ExitS, SL;
	

//	LogWrite(0, "---   FindExitSignal");
	
	ExitSignal = 0.0;
	
	i = BarNum-1;
	while (i >= 1)
	{
		GetIndiSignals(i, BuyS, SellS, ExitS, SL);

		if (ExitS > 0.0)
		{
			ExitSignal = ExitS;
			return(i);
		}
						
		i--;
	}
	
	return(-1);
}


//-----------------------------------------------------------------------------
// ProcessIndiSignals
//-----------------------------------------------------------------------------

void ProcessIndiSignals(int LastBar)
{
	int i, j;
	double BuyS, SellS, ExitS, SL;
	
	
//	LogWrite(0, "---   ProcessIndiSignals");
	
	InitStat();			// reset statistics variables

	i = LastBar;
	while (i >= 1)		// closed bars only
	{
		GetIndiSignals(i, BuyS, SellS, ExitS, SL);		// get signals
//		LogWrite(i, "Process: " + i + ", Buy sig: " + P2S(BuyS) + ", Sell sig: " + P2S(SellS) + ", Exit sig: " + P2S(ExitS) + ", SL: " + P2S(SL));
		
		// common for buys and sells
		if (BuyS > 0.0 || SellS > 0.0)
		{
			j = FindExitSignal(i, ExitS);						// where is an exit signal			
			
			if (j > -1)												// if there is one
			{
				TradeDT = Time[i-1];								// trade starts at the beginning of the next bar from the signal
				TradeExitDT = Time[j];							// trade ends at this bar
				TradeExitPrice = ExitS;							// exit price for the trade
								
				// for buys
				if (BuyS > 0.0)
				{
					TradeDirection = TRADE_BUY;								
					TradeOPrice = Open[i-1]+(Ask-Bid);		// buy started at this Ask price
				
					CntBuy++;						

					TradeStartSL = (TradeOPrice - SL)/dblPoint;					// start SL range in pips
					TradeResult = (TradeExitPrice - TradeOPrice)/dblPoint;	// trade result in pips
				}
				// for sells
				else if (SellS > 0.0)
				{
					TradeDirection = TRADE_SELL;								
					TradeOPrice = Open[i-1];											// sell open price (Bid)

					CntSell++;							

					TradeStartSL = (SL - TradeOPrice)/dblPoint;					// start SL range in pips
					TradeResult = (TradeOPrice - TradeExitPrice)/dblPoint;	// trade result in pips
				}
				
				SumTrade+= TradeResult;
				
				TradeResultInCurrency = (TradeResult / TradeStartSL) * MaxLossAtSL;
				SumTotalInCurrency += TradeResultInCurrency;
				
				if (TradeResult >= 0.0)
				{
					if (TradeDirection == TRADE_BUY)
					{
						SumBuyProfit += TradeResult;
						CntBuyProfit++;
					}
					else if (TradeDirection == TRADE_SELL)
					{
						SumSellProfit += TradeResult;
						CntSellProfit++;					
					}
					
					if (MaxProfit < TradeResult)
						MaxProfit = TradeResult;
					if (MaxProfitInCurrency < TradeResultInCurrency)
						MaxProfitInCurrency = TradeResultInCurrency;
				}
				else if (TradeResult < 0.0)
				{
					if (TradeDirection == TRADE_BUY)
					{
						SumBuyLoss += TradeResult;
						CntBuyLoss++;
					}
					else if (TradeDirection == TRADE_SELL)
					{
						SumSellLoss += TradeResult;
						CntSellLoss++;					
					}				
					
					if (MaxLoss > TradeResult)
						MaxLoss = TradeResult;				
					if (MaxLossInCurrency > TradeResultInCurrency)
						MaxLossInCurrency = TradeResultInCurrency;
				}
	
				DrawTrade();
	
				if (TradeDirection == TRADE_BUY)				
					LogWrite(j, "BUY end");
				else if (TradeDirection == TRADE_SELL)
					LogWrite(j, "SELL end");				
				LogWrite(j, "Profit/loss: " + DoubleToStr(TradeResult, 2) + " p.");
				LogWrite(j, "Start SL: " + DoubleToStr(TradeStartSL, 2) + " p.");
				LogWrite(j, "Profit/loss in acc. currency: " + DoubleToStr(TradeResultInCurrency, 2));
				
				i = j;		// i at the end of trade
				continue;	// while		
			}
		}				

		i--;				
	}	// while
}


//-----------------------------------------------------------------------------
// P2S
//-----------------------------------------------------------------------------

string P2S(double P)
{
	return(DoubleToStr(P, iDigits));
}


//=============================================================================
// START
//=============================================================================

int start()
{
   int i = 0;
	static datetime PrevTime = 0;
	static bool FirstIteration = true;
	double TempBuy, TempSell, TempExit, TempSL;	
	

	// --- init
		
	int MinBars = 200;
		
	i = Bars-MinBars-1;
   if (i < 0)
   	return(-1);
	
	if (i > BarsBack-1)
		i = BarsBack-1;
		
	// at first initialization only
	if (PrevTime == 0)
		PrevTime = Time[0];
		
  	StartDT = Time[i];		// time of first bar to process
//  	LogWrite(0, "First bar to process: " + i + ", time: " + TimeToStr(StartDT, TIME_DATE | TIME_SECONDS));

	// here we have to call custom indi at each tick to get all the signals later when needed
	GetIndiSignals(0, TempBuy, TempSell, TempExit, TempSL);		

	// --- processing at first run and after each new bar
	
	if (FirstIteration || PrevTime != Time[0])
	{
		if (FirstIteration)
			FirstIteration = false;
		else
			PrevTime = Time[0];
		
		RemoveObjects(ObjPref);
	
		ProcessIndiSignals(i);
		
		ShowStatistics();
	}


	return(0);
}	// end START


//--------------------------------------------------------------------------------------
// ShowStatistics
//--------------------------------------------------------------------------------------

void ShowStatistics()
{
	int StartY, StartX, Spacing, FSize, LineNum = 0;
	string FName;
	color FColor;
	
//	LogWrite(0, "---   ShowStatistics");
	
	StartX = 10; StartY = 75;
	FName = "Arial"; FColor = StatisticsColor; FSize = 14;

	DrawFixedLbl(ObjPref + "L_Title", "StrategySim", 0, StartX, StartY,
				 		FSize, FName, FColor, false);

	StartY = 100; Spacing = 15;
	FSize = 10;
	
	DrawFixedLbl(ObjPref + "L_TimeFrom", "From: " + TimeToStr(StartDT, TIME_DATE|TIME_MINUTES), 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);		
	LineNum++;
	DrawFixedLbl(ObjPref + "L_TimeTo", "to: " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES), 0, StartX+19, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);
	LineNum++;				 		
	DrawFixedLbl(ObjPref + "L_TimeM", "Months: " + DoubleToStr((TimeCurrent()*1.0 - StartDT)/(PERIOD_MN1*60.0), 1), 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);						 		
	LineNum++;				 		
	DrawFixedLbl(ObjPref + "L_TimeW", "Weeks: " + DoubleToStr((TimeCurrent()*1.0 - StartDT)/(PERIOD_W1*60.0), 1), 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);				 		
	LineNum += 2;

	int CntTrades = CntBuy + CntSell;
	DrawFixedLbl(ObjPref + "L_CntTrades", "Trades: " + CntTrades, 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);
				 		
	if (CntTrades == 0)
		return;
	
	LineNum++;				 		
	DrawFixedLbl(ObjPref + "L_CntBuys", "Buys: " + CntBuy + " (" + DoubleToStr(CntBuy*1.0/CntTrades*100.0, 0) + " %)", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);
	LineNum++;				 		
	DrawFixedLbl(ObjPref + "L_CntSells", "Sells: " + CntSell + " (" + DoubleToStr(CntSell*1.0/CntTrades*100.0, 0) + " %)", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);				
	LineNum++;					 

	int CntTradesProfit = CntBuyProfit + CntSellProfit;
	DrawFixedLbl(ObjPref + "L_CntTradesProfit", "Profit trades: " + CntTradesProfit + " (" + DoubleToStr(CntTradesProfit*1.0/CntTrades*100.0, 0) + " %)", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);	
	LineNum++;	

	int CntTradesLoss = CntBuyLoss + CntSellLoss;
	DrawFixedLbl(ObjPref + "L_CntTradesLoss", "Loss trades: " + CntTradesLoss + " (" + DoubleToStr(CntTradesLoss*1.0/CntTrades*100.0, 0) + " %)", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);			
	LineNum++;				 		

	if (CntBuy != 0)
	{
		DrawFixedLbl(ObjPref + "L_CntBuysProfit", "Profit buys: " + CntBuyProfit + " (" + DoubleToStr(CntBuyProfit*1.0/CntBuy*100.0, 0) + " %)", 0, StartX, StartY + LineNum*Spacing,
					 		FSize, FName, FColor, false);
		LineNum++;				 		
	}

	if (CntSell != 0)
	{
		DrawFixedLbl(ObjPref + "L_CntSellsProfit", "Profit sells: " + CntSellProfit + " (" + DoubleToStr(CntSellProfit*1.0/CntSell*100.0, 0) + " %)", 0, StartX, StartY + LineNum*Spacing,
					 		FSize, FName, FColor, false);				 		
		LineNum++;
	}

	LineNum++;
	double SumPipsProfit = SumBuyProfit + SumSellProfit;
	double SumPipsLoss = SumBuyLoss + SumSellLoss;
	DrawFixedLbl(ObjPref + "L_TotalPips", "Profit/loss total: " + DoubleToStr(SumTrade, 0) + " p.", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);
	LineNum++;				 		
	DrawFixedLbl(ObjPref + "L_TotalCurr", "Profit/loss (currency): " + DoubleToStr(SumTotalInCurrency, 0) + " " + AccountCurrency(), 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);
	LineNum++;
	DrawFixedLbl(ObjPref + "L_ProfitPips", "Total pips profit: " + DoubleToStr(SumPipsProfit, 0) + " p.", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);
	LineNum++;				 		
	DrawFixedLbl(ObjPref + "L_LossPips", "Total pips loss: " + DoubleToStr(SumPipsLoss, 0) + " p.", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);				 		
	LineNum++;				 		

	double SumBuys = SumBuyProfit + SumBuyLoss;
	double SumSells = SumSellProfit + SumSellLoss;	
	DrawFixedLbl(ObjPref + "L_AvgTrade", "Average trade: " + DoubleToStr(SumTrade/CntTrades, 0) + " p.", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);
	LineNum++;				 		

	if (CntBuy != 0)
	{	
		DrawFixedLbl(ObjPref + "L_AvgBuy", "Average buy: " + DoubleToStr(SumBuys/CntBuy, 0) + " p.", 0, StartX, StartY + LineNum*Spacing,
					 		FSize, FName, FColor, false);
		LineNum++;				 		
	}
	
	if (CntSell != 0)
	{	
		DrawFixedLbl(ObjPref + "L_AvgSell", "Average sell: " + DoubleToStr(SumSells/CntSell, 0) + " p.", 0, StartX, StartY + LineNum*Spacing,
					 		FSize, FName, FColor, false);	
		LineNum++;
	}
	
	DrawFixedLbl(ObjPref + "L_MaxProf", "Max profit: " + DoubleToStr(MaxProfit, 0) + " p.", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);
	LineNum++;				 		
	DrawFixedLbl(ObjPref + "L_MaxProfCurr", "Max profit (currency): " + DoubleToStr(MaxProfitInCurrency, 0) + " " + AccountCurrency(), 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);
	LineNum++;				 			
	DrawFixedLbl(ObjPref + "L_MaxLoss", "Max loss: " + DoubleToStr(MaxLoss, 0) + " p.", 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);					 		
	LineNum++;				 		
	DrawFixedLbl(ObjPref + "L_MaxLossCurr", "Max loss (currency): " + DoubleToStr(MaxLossInCurrency, 0) + " " + AccountCurrency(), 0, StartX, StartY + LineNum*Spacing,
				 		FSize, FName, FColor, false);					 		
	LineNum++;				 			
}


//--------------------------------------------------------------------------------------
// SetColor
//--------------------------------------------------------------------------------------

color SetColor()
{
	if (TradeResult >= 0.0)
		return(ProfitColor);				
	else
		return(LossColor);				
}


//--------------------------------------------------------------------------------------
// DrawTrade
//--------------------------------------------------------------------------------------

void DrawTrade()
{
	color TrColor, PLValColor;
	int CntTrades;
	
//	LogWrite(0, "---   DrawTrade");

	if (TradeDirection != TRADE_NO_SIG)
	{
		TrColor = SetColor();
		PLValColor = StatisticsColor;
		
		CntTrades = CntBuy+CntSell;
		DrawRect(ObjPref + "Trade_" + CntTrades, TradeDT, TradeExitDT, TradeOPrice, TradeExitPrice, TrColor, 1, STYLE_SOLID, true);		// filled rect (background)
		DrawRect(ObjPref + "TradeFrame_" + CntTrades, TradeDT, TradeExitDT, TradeOPrice, TradeExitPrice, Gray, 1, STYLE_SOLID, false);	// frame (foreground)
		
		DrawLbl(ObjPref + "TResult_" + CntTrades, DoubleToStr(TradeResult, 0) + " p (" + DoubleToStr(TradeResultInCurrency, 2) + " " + AccountCurrency() + ")",
					 PLValSize, "Arial Black", PLValColor, TradeDT, MathMin(TradeOPrice, TradeExitPrice)-2.0*dblPoint);
					 
		WindowRedraw();
	}
}


//--------------------------------------------------------------------------------------
// GetPoint
//--------------------------------------------------------------------------------------

void GetPoint()
{
	if (Digits == 3 || Digits == 5)   
		dblPoint = Point * 10;
	else
		dblPoint = Point;
      
	if (Digits == 3 || Digits == 2)
		iDigits = 2;
	else
		iDigits = 4;
}


//--------------------------------------------------------------------------------------
// RemoveObjects
//--------------------------------------------------------------------------------------

void RemoveObjects(string Pref)
{   
   int i;
   string OName = "";

   for (i = ObjectsTotal(); i >= 0; i--) 
   {
      OName = ObjectName(i);
      if (StringFind(OName, Pref, 0) > -1)
        	ObjectDelete(OName);
   }
   
   WindowRedraw();
}


//--------------------------------------------------------------------------------------
// DrawLbl
//--------------------------------------------------------------------------------------

void DrawLbl(string OName, string Capt, int FSize, string Font, color FColor, int LTime, double LPrice)
{
   if (ObjectFind(OName) < 0) 
   {
      ObjectCreate(OName, OBJ_TEXT, 0, LTime, LPrice);
   }
	else 
	{
      if (ObjectType(OName) == OBJ_TEXT) 
      {
         ObjectSet(OName, OBJPROP_TIME1, LTime);
         ObjectSet(OName, OBJPROP_PRICE1, LPrice);
      }
   }
   
   ObjectSet(OName, OBJPROP_FONTSIZE, FSize);
   ObjectSetText(OName, Capt, FSize, Font, FColor);
}


//--------------------------------------------------------------------------------------
// DrawFixedLbl
//--------------------------------------------------------------------------------------

void DrawFixedLbl(string OName, string Capt, int Corner, int DX, int DY, int FSize, string Font, color FColor, bool BG)
{
   if (ObjectFind(OName) < 0)
   	ObjectCreate(OName, OBJ_LABEL, 0, 0, 0);
   
   ObjectSet(OName, OBJPROP_CORNER, Corner);
   ObjectSet(OName, OBJPROP_XDISTANCE, DX);
   ObjectSet(OName, OBJPROP_YDISTANCE, DY);
   ObjectSet(OName,OBJPROP_BACK, BG);      
   
   if (Capt == "" || Capt == "Label") Capt = " ";

   ObjectSetText(OName, Capt, FSize, Font, FColor);
}


//--------------------------------------------------------------------------------------
// DrawRect
//--------------------------------------------------------------------------------------

void DrawRect(string OName, double T1, double T2, double P1, double P2, color Col, int Width, int Style, bool BG) 
{
   if (ObjectFind(OName) == -1) 
	   ObjectCreate(OName, OBJ_RECTANGLE, 0, T1, P1, T2, P2);
   else 
   {
		ObjectSet(OName, OBJPROP_TIME1, T1);
		ObjectSet(OName, OBJPROP_TIME2, T2);
		ObjectSet(OName, OBJPROP_PRICE1, P1);
		ObjectSet(OName, OBJPROP_PRICE2, P2);
   }
   
   ObjectSet(OName, OBJPROP_COLOR, Col);
   ObjectSet(OName, OBJPROP_BACK, BG);
   ObjectSet(OName, OBJPROP_WIDTH, Width);
   ObjectSet(OName, OBJPROP_STYLE, Style);
}



// *************************************************************************************
//
//	LOG routines
//
// *************************************************************************************


//--------------------------------------------------------------------------------------
// LogOpen
//--------------------------------------------------------------------------------------

void LogOpen()
{
	if (!WriteToLog)
		return;
	
	string FName = IndName + "_" + Symbol() + "_M" + Period() + ".log";
		
	LogHandle = FileOpen(FName, FILE_WRITE);
	
	if (LogHandle < 1)
	{
		Print("Cannot open LOG file ", FName + "; Error: ", GetLastError(), " : ", ErrorDescription( GetLastError() ) );
		return;
	}	

	FileSeek(LogHandle, 0, SEEK_END);
}


//--------------------------------------------------------------------------------------
// LogClose
//--------------------------------------------------------------------------------------

void LogClose()
{
	if ( (!WriteToLog) || (LogHandle < 1) )
		return;

	FileClose(LogHandle); 
}


//--------------------------------------------------------------------------------------
// LogWrite
//--------------------------------------------------------------------------------------

void LogWrite(int i, string sText) 
{
	if ( (!WriteToLog) || (LogHandle < 1) )
		return;

	if (i == 0)
		FileWrite(LogHandle, "Curr. T (" + TimeToStr(TimeCurrent(), TIME_SECONDS) + ") : " + sText);
	else
		FileWrite(LogHandle, TimeToStr(Time[i], TIME_DATE | TIME_SECONDS) + ": " + sText);  
		
	FileFlush(LogHandle);
}

