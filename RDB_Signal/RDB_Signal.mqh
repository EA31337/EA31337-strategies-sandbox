//+------------------------------------------------------------------+
//|                                                      Elliott.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property version   "1.00"
#property strict

//#include  <Convert.mqh>

extern string  MA1_Input            = "Parameter untuk MA1";
extern int     MA1_Period           = 6;
extern int     MA1_Shift            = 0;
extern int     MA1_Method           = 0;
extern int     MA1_Apply            = 1;
extern color   MA1_Color            = Red;

extern string  MA2_Input            = "Parameter untuk MA2";
extern int     MA2_Period           = 12;
extern int     MA2_Shift            = 0;
extern int     MA2_Method           = 0;
extern int     MA2_Apply            = 1;
extern color   MA2_Color            = Green;

extern string  MA3_Input            = "Parameter untuk MA3";
extern int     MA3_Period           = 48;
extern int     MA3_Shift            = 0;
extern int     MA3_Method           = 0;
extern int     MA3_Apply            = 1;
extern color   MA3_Color            = Blue;

extern double  Overbought           = 0.9;
extern double  Oversold             = 0.1;
extern int     TF                   = 15;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EA
  {

public:

   int               Sign_BS;

   void Update(int tf=PERIOD_M1)
     {

      double Percen_Lot1=0,Percen_Lot2=0;
      string  trend_bs="",trend_bs1="",level_bs="";
      double  order_lot=0,my_lot10=0;
      color   color_bs;

      double close=iClose(NULL,tf,0);

      double DM5        = iDeMarker (NULL,PERIOD_M5  ,14,0);
      double DM15       = iDeMarker (NULL,PERIOD_M15 ,14,0);
      double NL_BS      = iCustom   (NULL,PERIOD_M5  ,"NonLagMA_v7",0,9,0,0,1,1,0,0,0,0,0);

      double BB2_M1   =iCustom(NULL, tf, "BBands_Stop_v1", 20, 1, 0.5, 1, 1, 500,false,"","", 4,0); //UpTrendLine
      double BB1_M1   =iCustom(NULL, tf, "BBands_Stop_v1", 20, 1, 0.5, 1, 1, 500,false,"","", 5,0); //DownTrendLine

      double BB2_M5   =iCustom(NULL, PERIOD_M5, "BBands_Stop_v1", 20, 1, 0.5, 1, 1, 500,false,"","", 4,0); //UpTrendLine
      double BB1_M5   =iCustom(NULL, PERIOD_M5, "BBands_Stop_v1", 20, 1, 0.5, 1, 1, 500,false,"","", 5,0); //DownTrendLine

      double MA1_M1   = iMA   (Symbol(),tf,MA1_Period,MA1_Shift,MA1_Method,MA1_Apply,0);
      double MA2_M1   = iMA   (Symbol(),tf,MA2_Period,MA2_Shift,MA2_Method,MA2_Apply,0);
      double MA3_M1   = iMA   (Symbol(),tf,MA3_Period,MA3_Shift,MA3_Method,MA3_Apply,0);

      double MA1      = iMA   (Symbol(),tf,MA1_Period,MA1_Shift,MA1_Method,MA1_Apply,0);
      double MA2      = iMA   (Symbol(),tf,MA2_Period,MA2_Shift,MA2_Method,MA2_Apply,0);
      double MA3      = iMA   (Symbol(),tf,MA3_Period,MA3_Shift,MA3_Method,MA3_Apply,0);
      //+---------------------------------------------------------------------------------------------------------------------------
      //+----------------- 
      //+------------------------------------------------------------------+

      //+------------------------------------------------------------------+

      //+------------------------------------------------------------------+
      //+----------------- Signal BUY_SELL
      // BUY  EXECUTOR--------------------------------------------------------------------------------------------------------------  +
      //+----------------- 
      // BUY  EXECUTOR--------------------------------------------------------------------------------------------------------------  +
      if((close>MA1) && (close>MA2) && (close>MA3) && (MA1>MA2) && (close>MA3_M1) && (close>MA2_M1) && (BB1_M1>BB2_M1) && (BB1_M5>BB2_M5) && ((DM15<Overbought) || (DM5<Overbought))) //Buy Double
        {Sign_BS=11;}
      else
      if((close>MA1) && (close>MA2) && ((close<MA3) || (close>MA3)) && ((MA1>MA2) || (MA1<MA2)) && ((MA1>MA3) || (MA1<MA3)) && (BB1_M1>BB2_M1) && (BB1_M5>BB2_M5) && ((DM15<Overbought) || (DM5<Overbought))) //Buy
        {Sign_BS=12;}
      else
      if((close<MA1) && (close>MA2) && ((close<MA3) || (close>MA3)) && ((MA1>MA2) || (MA1<MA2)) && ((MA1>MA3) || (MA1<MA3)) && (BB1_M1>BB2_M1) && ((DM15<Overbought) || (DM5<Overbought))) //Buy Kuning
        {Sign_BS=15;}
      else
      if((DM15>Overbought) || (DM5>Overbought))
        {Sign_BS=14;} // buy Overbought
      else
      // SELL EXECUTOR--------------------------------------------------------------------------------------------------------------  +
      if((close<MA1) && (close<MA2) && (close<MA3) && (MA1<MA2) && (close<MA3_M1) && (close<MA2_M1) && (BB1_M1<BB2_M1) && (BB1_M5<BB2_M5) && ((DM15>Oversold) || (DM5>Oversold))) //Sell Double
        {Sign_BS=21;}
      else
      if((close<MA1) && (close<MA2) && ((close<MA3) || (close>MA3)) && ((MA1<MA2) || (MA1>MA2)) && ((MA1<MA3) || (MA1>MA3)) && (BB1_M1<BB2_M1) && (BB1_M5<BB2_M5) && ((DM15>Oversold) || (DM5>Oversold))) //Sell
        {Sign_BS=22;}
      else
      if((close>MA1) && (close<MA2) && ((close>MA3) || (close<MA3)) && ((MA1<MA2) || (MA1>MA2)) && ((MA1<MA3) || (MA1>MA3)) && (BB1_M1<BB2_M1) && ((DM15>Oversold) || (DM5>Oversold))) //Sell Kuning
        {Sign_BS=25;}
      else
      if((DM15<Oversold) || (DM5<Oversold))
        {Sign_BS=24;} // sell Oversold

      else  {Sign_BS=3;}    //Sideway

      //+------------------------------------------------------------------+

     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

      
      
      //+- TREND UP BS
      if(Sign_BS==11 && cmd==OP_BUY)
        {return true;}
      else
      if(Sign_BS==12 && cmd==OP_BUY)
        {return true;}   else
      if(Sign_BS==15 && cmd==OP_BUY)
        {return true;}   else
 

      //+- TREND DN BS
      if(Sign_BS==21 && cmd==OP_SELL)
        {return true;}   else
      if(Sign_BS==22 && cmd==OP_SELL)
        {return true;}  else
      if(Sign_BS==25 && cmd==OP_SELL)
        {return true;}    
 

      return false;

     }
  };
//+------------------------------------------------------------------+
