//+------------------------------------------------------------------+
//|                                                      AFS.mqh |
//|                                                           kenorb |
//+------------------------------------------------------------------+

#property version   "1.00"
#property strict

#include  <Convert.mqh>



extern string     GeneralSettings         = "===== General Settings ============================";
extern int        PhoenixMode             = 2;

extern bool       MM                      = true;
extern bool       AccountIsMicro          = false;

extern bool       PrefSettings=true;

extern int        CloseAfterHours         = 0;
extern int        BreakEvenAfterPips      = 0;

extern string     Mode1                   = "====== AFS Mode 1 (Classic) ==================";
extern int        TakeProfit              = 0;
extern int        StopLoss                = 0;
extern int        TrailingStop            = 0;

extern string     Mode2                   = "====== AFS Mode 2 (Second trade)==============";
extern int        Mode2_OpenTrade_2       = 0;
extern int        Mode2_TakeProfit        = 0;
extern int        Mode2_StopLoss          = 0;
extern bool       Mode2_CloseFirstTrade   = false;

extern string     Mode3                   = "====== AFS Mode 3 (Three trades at once) =====";
extern int        Mode3_CloseTrade2_3     = 0;
extern int        Mode3_TakeProfit        = 0;
extern int        Mode3_StopLoss          = 0;

extern string     Signal1                 = "====== Signal 1 ===================================";
extern bool       UseSignal1              = true;
extern double     Percent                 = 0;
extern int        EnvelopePeriod          = 0;

extern string     Signal2                 = "====== Signal 2 ==================================";
extern bool       UseSignal2              = true;
extern int        SMAPeriod               = 0;
extern int        SMA2Bars                = 0;

extern string     Signal3                 = "====== Signal 3 ==================================";
extern bool       UseSignal3              = true;
extern int        OSMAFast                = 0;
extern int        OSMASlow                = 0;
extern double     OSMASignal              = 0;

extern string     Signal4                 = "====== Signal 4 ==================================";
extern bool       UseSignal4              = true;
extern int        Fast_Period             = 0;
extern int        Fast_Price              = PRICE_OPEN;
extern int        Slow_Period             = 0;
extern int        Slow_Price              = PRICE_OPEN;
extern double     DVBuySell               = 0;
extern double     DVStayOut               = 0;

extern string     Signal5                 = "====== Signal 5 =================================";
extern bool       UseSignal5              = true;
extern int        TradeFrom1              = 0;
extern int        TradeUntil1             = 24;
extern int        TradeFrom2              = 0;
extern int        TradeUntil2             = 0;
extern int        TradeFrom3              = 0;
extern int        TradeUntil3             = 0;
extern int        TradeFrom4              = 0;
extern int        TradeUntil4             = 0;

double Poin;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AFS
  {

public:

   bool              BuySignal1,SellSignal1;
   bool              BuySignal2,SellSignal2;
   bool              BuySignal3,SellSignal3;
   bool              BuySignal4,SellSignal4;
   bool              BuySignal5,SellSignal5;

   int Update(int tf=PERIOD_M1)
     {


      int tframe=Convert::TfToIndex(tf);

      double HighEnvelope1 = iEnvelopes(NULL,tframe,EnvelopePeriod,MODE_SMA,0,PRICE_CLOSE,Percent,MODE_UPPER,1);
      double LowEnvelope1  = iEnvelopes(NULL,tframe,EnvelopePeriod,MODE_SMA,0,PRICE_CLOSE,Percent,MODE_LOWER,1);
      double CloseBar1     = iClose(NULL,0,1);

      //Print("a ",HighEnvelope1,"b ",LowEnvelope1);

      if(UseSignal1)
        {
         if(CloseBar1 > HighEnvelope1) {SellSignal1 = true;}
         if(CloseBar1 < LowEnvelope1)  {BuySignal1  = true;}
        }
      else {SellSignal1=true;BuySignal1=true;}

      //=====================SIGNAL2========================

      BuySignal2=false;SellSignal2=false;

      double SMA1=iMA(NULL,tframe,SMAPeriod,0,MODE_SMA,PRICE_CLOSE,1);
      double SMA2=iMA(NULL,tframe,SMAPeriod,0,MODE_SMA,PRICE_CLOSE,SMA2Bars);

      if(UseSignal2)
        {
         if(SMA2-SMA1>0) {BuySignal2  = true;}
         if(SMA2-SMA1<0) {SellSignal2 = true;}
        }
      else {SellSignal2=true;BuySignal2=true;}

      //=====================SIGNAL3========================

      BuySignal3=false;SellSignal3=false;

      double OsMABar2=iOsMA(NULL,tframe,OSMASlow,OSMAFast,OSMASignal,PRICE_CLOSE,2);
      double OsMABar1=iOsMA(NULL,tframe,OSMASlow,OSMAFast,OSMASignal,PRICE_CLOSE,1);

      if(UseSignal3)
        {
         if(OsMABar2 > OsMABar1)  {SellSignal3 = true;}
         if(OsMABar2 < OsMABar1)  {BuySignal3  = true;}
        }
      else {SellSignal3=true;BuySignal3=true;}

      //=====================SIGNAL4========================  

      double diverge;
      BuySignal4=false;SellSignal4=false;

      diverge=divergence(Fast_Period,Slow_Period,Fast_Price,Slow_Price,0,tframe);

      if(UseSignal4)
        {
         if(diverge>=DVBuySell && diverge<=DVStayOut)
           {BuySignal4=true;}
         if(diverge<=(DVBuySell*(-1)) && diverge>=(DVStayOut*(-1)))
           {SellSignal4=true;}
        }
      else {SellSignal4=true;BuySignal4=true;}

      //=====================SIGNAL5=======================  

      BuySignal5=false;SellSignal5=false;

      if(UseSignal5)
        {
         int iHour=TimeHour(LocalTime());
         int ValidTradeTime=F_ValidTradeTime(iHour);
         if(ValidTradeTime==true)
           {
            BuySignal5=true;
            SellSignal5=true;
           }
        }
      else {SellSignal5=true;BuySignal5=true;}

      return true;
     }
   double divergence(int F_Period,int S_Period,int F_Price,int S_Price,int mypos,int tframe)
     {
      double maF2,maS2;

      maF2 = iMA(Symbol(), tframe, F_Period, 0, MODE_SMA, F_Price, mypos + 1);
      maS2 = iMA(Symbol(), tframe, S_Period, 0, MODE_SMA, S_Price, mypos + 1);

      return(maF2-maS2);
     }
   bool F_ValidTradeTime(int iHour)
     {
      if(((iHour>=TradeFrom1) && (iHour<=(TradeUntil1-1))) || ((iHour>=TradeFrom2) && (iHour<=(TradeUntil2-1))) || ((iHour>=TradeFrom3) && (iHour<=(TradeUntil3-1))) || ((iHour>=TradeFrom4) && (iHour<=(TradeUntil4-1))))
        {
         return (true);
        }
      else
         return (false);
     }
   bool Signal(int cmd=EMPTY,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

       

      Mode2_OpenTrade_2    = 0;
      Mode2_TakeProfit     = 50;
      Mode2_StopLoss       = 60;


      Mode3_CloseTrade2_3  = 30;
      Mode3_TakeProfit     = 100;
      Mode3_StopLoss       = 55;

      Percent              = 0.0032;
      EnvelopePeriod       = 2;

      TakeProfit           = 42;
      StopLoss             = 84;
      TrailingStop         = 0;
      SMAPeriod            = 2;
      SMA2Bars             = 18;
      OSMAFast             = 5;
      OSMASlow             = 22;
      OSMASignal           = 2;

      Fast_Period          = 25;
      Slow_Period          = 15;
      DVBuySell            = 0.0029;
      DVStayOut            = 0.024;




      if((SellSignal1==true) && (SellSignal2==true) && (SellSignal3==true) && (SellSignal4==true) && (SellSignal5==true) && (cmd==OP_SELL)) return(1);
      if((BuySignal1==true) && (BuySignal2==true) && (BuySignal3==true) && (BuySignal4==true) && (BuySignal5==true) && (cmd==OP_BUY)) return(1);
      return(0);
     }

  };
//+------------------------------------------------------------------+
