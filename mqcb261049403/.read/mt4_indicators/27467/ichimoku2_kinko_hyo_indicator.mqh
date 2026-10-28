//+------------------------------------------------------------------+
//|      This is the wrapper(case) for Ichimoku2.mq4 indicator       |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Powered by the people."
#property link      "https://www.everybody.com"
#property strict
#property strict
#include <BreakPoint.mqh>
//+------------------------------------------------------------------+
// iIchimoku2                                                             
//+------------------------------------------------------------------+
/*
 This returns the indicator values of the bands(tenkansen,kijunsen...).
 The Ichimoku chart is composed of five (5) separate indicator lines. These lines work together to form the
 complete "Ichimoku picture"..
 KumoIV(Kumo Implied Volatility): 0 means normal, 1 means fat(thicker than normal), -1 means thinner than normal.
 KumoShape: flat-top means flat top, flat-bottom means flat bottom.
 KumoSentiment: bullish means bullish sentiment, bearish means bearish sentiment.
 ichikShift: 0 represents the most recent indicator values or indicator values which is occurring while the newest unformed bar is forming. 1 means the previous indicator values.
*/
void iIchimoku2(string ichiSymbol, ENUM_TIMEFRAMES ichiChartTimeframe, int ichiKumoPeriod, double& Tenkansen_value, double& Kijunsen_value, double& Chikou_value, double& SpanA_value, double& SpanB_value, string& KumoIV_value, string& KumoShape_value, string& KumoSentiment_value, int ichiMagic, int ichikShift, string ichiEcoMode="no", string ichiDisplayText="no", int ichiTenkanPeriod=9, int ichiKijunPeriod=26, int ichiSenkouPeriod=52)
{ 
 string magicstr=IntegerToString(ichiMagic);
 int kshape=0,ksentiment=0,kiv=0;
 iCustom(ichiSymbol, ichiChartTimeframe, "Ichimoku2", ichiSymbol, ichiChartTimeframe, ichiKumoPeriod, Tenkansen_value, Kijunsen_value, Chikou_value, SpanA_value, SpanB_value, KumoIV_value, KumoShape_value, KumoSentiment_value, magicstr, ichikShift, ichiEcoMode, ichiDisplayText, ichiTenkanPeriod,ichiKijunPeriod,ichiSenkouPeriod, 0,0); // Shift 1 when ichikShift=1
 Tenkansen_value = GlobalVariableGet("ichiGlobalTenkan"+"_"+magicstr);
 Kijunsen_value = GlobalVariableGet("ichiGlobalKijun"+"_"+magicstr);
 Chikou_value = GlobalVariableGet("ichiGlobalChikou"+"_"+magicstr);
 SpanA_value = GlobalVariableGet("ichiGlobalSpanA"+"_"+magicstr);   
 SpanB_value = GlobalVariableGet("ichiGlobalSpanB"+"_"+magicstr); 
 kiv = (int)GlobalVariableGet("ichiGlobalKumoThickness"+"_"+magicstr);
 kshape = (int)GlobalVariableGet("ichiGlobalKumoShape"+"_"+magicstr);
 ksentiment = (int)GlobalVariableGet("ichiGlobalKumoSentiment"+"_"+magicstr);
    if(IsStopped()==true)//when in Visual tester draw indicator lines. 
    {
     // iCustom(ichiSymbol, ichiChartTimeframe, "Ichimoku2", ichiSymbol, ichiChartTimeframe, ichiKumoPeriod, Tenkansen_value, Kijunsen_value, Chikou_value, SpanA_value, SpanB_value, KumoIV_value, KumoShape_value, KumoSentiment_value, ichikShift,"yes",ichiTenkanPeriod,ichiKijunPeriod,ichiSenkouPeriod,0,0); // Shift 1 when ichikShift=1    
    }
    if(kiv == 1)KumoIV_value = "thick";
    else if(kiv == -1)KumoIV_value = "thin"; 
    else KumoIV_value = "normal";
                      
    if(kshape == 1)KumoShape_value = "flat-top";
    else if(kshape == 2)KumoShape_value = "flat-bottom"; 
    else KumoShape_value = "abstract";
    
    if(ksentiment == 1)KumoSentiment_value = "bullish";
    else if(ksentiment == 2)KumoSentiment_value = "bearish"; 

}
//+------------------------------------------------------------------+
// End of iIchimoku2                                                             
//+------------------------------------------------------------------+

