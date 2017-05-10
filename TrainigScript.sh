hadoop fs -rmr /ProjectData/NewMailProbability /ProjectData/NewDictionary
pig Training.pig
hadoop fs -rmr /ProjectData/MailProbability/* /ProjectData/Dictionary/*
hadoop fs -mv /ProjectData/NewMailProbability/* /ProjectData/MailProbability
hadoop fs -mv /ProjectData/NewDictionary/* /ProjectData/Dictionary
hadoop fs -rmr /ProjectData/NewMailProbability /ProjectData/NewDictionary

