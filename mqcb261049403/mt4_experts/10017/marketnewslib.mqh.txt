//+------------------------------------------------------------------+
//|                                                MarketNewsLib.mqh |
//|                       Copyright © 2010, Tamter Trading Programs. |
//|                                            http://www.tamter.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Tamter Trading Programs."
#property link      "http://www.tamter.com"

#import "MarketNewsLib.ex4"

bool GetNewsToTrade(string& news[][],string& newsToTrade[], bool newsHigh, bool newsMedium, bool newsLow, string currency, int alertSecs);
void InitNews(string& news[][], int timeZone, string newsUrl);
void DrawNewsLines(string news[][], bool showLineText, color high_color=Red,color medium_color=Yellow,color low_color=Orange);
void ShowNewsCountDown(string& news[][],int alertMinsBeforeNews,int startRow=1, color high_color=Red,color medium_color=Yellow,color low_color=Orange, color past_color=Gray, color title_color= White);
int  DeleteNewsObjects();
//+------------------------------------------------------------------+