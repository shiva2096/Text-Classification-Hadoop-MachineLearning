hadoop fs -rmr /MRInput /Input /HotelBookingMails /OtherMails
hadoop fs -mkdir /Input
hadoop fs -put Input.txt /Input
pig BeforeMR.pig
hadoop jar Multiplication.jar MDriver /MRInput/part-r* /MROutput
pig AfterMR.pig
hadoop fs -rmr /MRInput /MROutput

