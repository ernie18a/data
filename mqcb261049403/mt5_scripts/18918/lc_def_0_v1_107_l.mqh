//======================================================================================================
//    LibreConver Lite Definition_0 v1.007 MQL4/5
//    Определения переменных и структур
//    LibreCoin (c)2014-2017      
//======================================================================================================
#property strict
//======================================================================================================
//    ENUM
//======================================================================================================
//
//======================================================================================================
//    Global variable definition
//======================================================================================================
MqlDateTime 
   gDateTime,
   sTime;
datetime gDate;  
string
   gDat="2016.12.31",
   gTim="23:59",
   gYear="2016",
   gMoun="12",
   gDay="31"; 
//----- Массивы связок параметров
   string iMounN= "01"+"Jan"+
                  "02"+"Feb"+
                  "03"+"Mar"+
                  "04"+"Apr"+
                  "05"+"May"+
                  "06"+"Jun"+
                  "07"+"Jul"+
                  "08"+"Aug"+
                  "09"+"Sep"+
                  "10"+"Oct"+
                  "11"+"Nov"+
                  "12"+"Dec";
   string iMounthN=  "01"+"January"+
                     "02"+"February"+
                     "03"+"March"+
                     "04"+"April"+
                     "05"+"May"+
                     "06"+"June"+
                     "07"+"July"+
                     "08"+"August"+
                     "09"+"September"+
                     "10"+"October"+
                     "11"+"November"+
                     "12"+"December";
   string iCountryN= "USD"+"United States#"+
                     "EUR"+"European Monetary Union#"+
                     "EUR"+"Germany#"+
                     "EUR"+"Spain#"+
                     "EUR"+"Finland#"+
                     "EUR"+"Austria#"+
                     "EUR"+"Italy#"+
                     "EUR"+"Portugal#"+
                     "EUR"+"France#"+
                     "EUR"+"Greece#"+
                     "EUR"+"Ireland#"+
                     "EUR"+"Slovakia#"+
                     "EUR"+"Netherlands#"+
                     "EUR"+"Belgium#"+
                     "EUR"+"Slovenia#"+
                     "EUR"+"Latvia#"+
                     "EUR"+"Estonia#"+
                     "EUR"+"Lithuania#"+
                     "EUR"+"Cyprus#"+
                     "EUR"+"Luxembourg#"+
                     "EUR"+"Malta#"+
                     "GBP"+"United Kingdom#"+
                     "JPY"+"Japan#"+
                     "CHF"+"Switzerland#"+
                     "CAD"+"Canada#"+
                     "AUD"+"Australia#"+
                     "NZD"+"New Zealand#"+
                     "CNY"+"China#"+
                     "HKD"+"Hong Kong#"                     
                     "TRY"+"Turkey#"+
                     "COP"+"Colombia#"+
                     "NOK"+"Norway#"+
                     "SEK"+"Sweden#"+
                     "DKK"+"Denmark#"+
                     "ISK"+"Iceland#"+
                     "PHP"+"Philippines#"+
                     "PLN"+"Poland#"+
                     "BGN"+"Bulgaria#"+
                     "ZAR"+"South Africa#"+
                     "LKR"+"Sri Lanka#"+
                     "CZK"+"Czech Republic#"+
                     "MYR"+"Malaysia#"+
                     "SGD"+"Singapore#"+
                     "AED"+"United Arab Emirates#"+
                     "KWD"+"Kuwait#"+
                     "CLP"+"Chile#"+
                     "MAD"+"Morocco#"+
                     "HUF"+"Hungary#"+
                     "PEI"+"Peru#"+
                     "KRW"+"South Korea#"+
                     "BRL"+"Brazil#"+
                     "ARS"+"Argentina#"+
                     "HRK"+"Croatia#"+
                     "MXN"+"Mexico#"+
                     "ROL"+"Romania#"+
                     "IDR"+"Indonesia#"+
                     "INR"+"India#"+
                     "BHD"+"Bahrain#"+
                     "EGP"+"Egypt#"+
                     "BAM"+"Bosnia-Herzegovina#"+
                     "KES"+"Kenya#"+
                     "LBP"+"Lebanon#"+
                     "MWK"+"Malawi#"+
                     "BWP"+"Botswana#"+
                     "JOD"+"Jordan#"+
                     "PKR"+"Pakistan#"+
                     "RUB"+"Russia#"+
                     "RWF"+"Rwanda#"+
                     "TZS"+"Tanzania#"+
                     "UGH"+"Uganda#"+
                     "ZWL"+"Zimbabwe#"+
                     "MUR"+"Mauritius#"+
                     "NAD"+"Namibia#"+
                     "ILS"+"Palestinian Territory#"+
                     "CRC"+"Costa Rica#"+
                     "ZMW"+"Zambia#"+
                     "NGN"+"Nigeria#"+
                     "ECS"+"Ecuador#"+
                     "TWD"+"Taiwan#"+
                     "ALL"+"ALL#";
   string iImpactN=  "0"+"N"+
                     "1"+"L"+
                     "2"+"M"+
                     "3"+"H";
   string iImpactLN= "0"+"None"+
                     "1"+"Low"+
                     "2"+"Medium"+
                     "3"+"High";
   string iImpactMN= "0"+"Holiday"+
                     "1"+"Low Volatility Expected"+
                     "2"+"Moderate Volatility Expected"+
                     "3"+"High Volatility Expected";
   string iImpactNN= "0"+"Non-Economic"+
                     "1"+"Low Impact Expected"+
                     "2"+"Medium Impact Expected"+
                     "3"+"High Impact Expected";
   string iImpactON= "0"+"none"+
                     "1"+"low"+
                     "2"+"medium"+
                     "3"+"high";
   string iCountryT= "French"+"France#"+
                     "German"+"Germany#"+
                     "Italian"+"Italy#"+
                     "Spanish"+"Spain#"+
                     "Belgian"+"Belgium#";
