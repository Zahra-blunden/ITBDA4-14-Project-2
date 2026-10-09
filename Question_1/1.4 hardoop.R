// ==========================================
  // 1.4 HADOOP MAPREDUCE CONFIGURATION
// ==========================================
  
  Configuration conf = new Configuration();
  
  Job job = Job.getInstance(conf, "Keyword Search");
  
  
  // Set the main driver class
  job.setJarByClass(KeywordSearch.class);
  
  
  // Set Mapper and Reducer
  job.setMapperClass(KeywordMapper.class);
  job.setReducerClass(KeywordReducer.class);
  
  
  // Set Mapper output types
  job.setMapOutputKeyClass(Text.class);
  job.setMapOutputValueClass(Text.class);
  
  
  // Set final Reducer output types
  job.setOutputKeyClass(Text.class);
  job.setOutputValueClass(Text.class);
  
  
  // Set input and output paths
  FileInputFormat.addInputPath(
    job,
    new Path("map_reduce_test_docs")
  );
  
  FileOutputFormat.setOutputPath(
    job,
    new Path("mapreduce_output")
  );
  
  
  // Submit the MapReduce job
  System.exit(
    job.waitForCompletion(true) ? 0 : 1
  );