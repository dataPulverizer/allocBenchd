import std.stdio: File, write, writeln;
import core.memory: GC;
import std.typecons: Tuple, tuple;
import std.algorithm.iteration: mean;
import std.algorithm.iteration: sum;
import std.datetime.stopwatch: AutoStart, StopWatch;
import std.conv: to;


/**
  This will be a row in the results table
*/
struct Row
{
  char name; /* malloc (m) or free (f) */
  long id;
  long length;
  double time;
  string toString()
  {
    string _name = name == 'm' ? "\"malloc\"" : "\"free\"";
    return _name ~ ", " ~ to!(string)(id) ~ ", " ~ to!(string)(length) ~ ", " ~ to!(string)(time);
  }
}

/**
  Writes rows to file
*/
auto writeRows(string fileName, Row[] rows)
{
  version(verbose)
  {
    writeln("Writing file: ", fileName);
  }
  auto file = File(fileName, "w");
  file.write("\"name\", \"id\", \"length\", \"time\"\n");
  for(long i = 0; i < rows.length; ++i)
  {
    file.write(rows[i].toString() ~ "\n");
  }
  file.close();
  version(verbose)
  {
    writeln("Finished writing file.");
  }
  return;
}

/**
  Function benchmarks memory allocation and free
  x is the item to fill the array with.
  nmax is maximum length of items to run to
    so the benchmarks tests allocation of 1..nmax items
*/
auto memoryBench(alias x, string units = "nsecs", uint mask = GC.BlkAttr.NO_SCAN)(long ntrials, long nmax)
{
  alias T = typeof(x);
  auto results = new Row[2*ntrials*nmax];
  auto sw = StopWatch(AutoStart.no); long j = 0;
  for(long n = 1; n <= nmax; ++n)
  {
    version(verbose)
    {
      if(n % 10_000 == 0)
        writeln("Running for length = ", n);
    }
    for(long i = 0; i < ntrials; ++i)
    {
      /* Malloc */
      sw.start();
      auto arr = (cast(T*)GC.malloc(T.sizeof*n, mask))[0..n];
      version(verify)
      {
        if(arr == null)
          assert(0, "Array Allocation Failed!");
      }
      sw.stop();
      arr[] = x; // I don't want anything to optimise away the array instantiation
      results[j] = Row('m', i, n, cast(double)sw.peek.total!units);
      sw.reset(); ++j;

      /* Free */
      sw.start();
      GC.free(arr.ptr);
      sw.stop();
      results[j] = Row('f', i, n, cast(double)sw.peek.total!units);
      sw.reset(); ++j;
    }
  }
  version(verbose)
  {
    writeln("Finished benchmark.");
  }
  return results;
}

import std.process: execute, executeShell;
import std.file: getcwd;
/**
  Plots the output in R
  chartFile - where the chart should be written (jpeg)
  dataFile - where the data written by writeRows() is located
  nsamp - number of samples to random select from the data
  maxMallocTime - maximum malloc time to plot in the chart
  maxFreeTime - maximum free time to plot in the chart
*/
auto writePlot(string chartFileName, string dataFile, long nsamp, long maxMallocTime = -1, long maxFreeTime = -1)
{
  string wd = getcwd();
  string mallocYLim = maxMallocTime < 1 ? "" : `, ylim = c(0, ` ~ to!(string)(maxMallocTime) ~ `)`;
  string freeYLim = maxMallocTime < 1 ? "" : `, ylim = c(0, ` ~ to!(string)(maxFreeTime) ~ `)`;
  string sampleString = nsamp < 1 ? "" : `[sample(nrow(dat) - 2, ` ~ to!(string)(nsamp) ~ `),]`;
  string script = `"
  setwd(\"`~ wd ~ `\")
  require(data.table)
  dat = fread(\"` ~ dataFile ~ `\")
  jpeg(\"`~ chartFileName ~ `\", width = 12, height = 6, units = \"in\", res = 200)
  par(mfrow = c(1, 2))
  # Remove the first two rows of data in the plot
  dat[-c(1:2),]` ~ sampleString ~ `[name == \"malloc\", plot(time ~ length, pch = 20, col = rgb(0, 0, 0, 0.3), ylab = \"time (ns)\", xlab = \"array length\", main = name[1]` ~ mallocYLim ~ `)]
  dat[-c(1:2),]` ~ sampleString ~ `[name == \"free\", plot(time ~ length, pch = 20, col = rgb(0, 0, 0, 0.3), ylab = \"time (ns)\", xlab = \"array length\", main = name[1]` ~ freeYLim ~ `)]
  dev.off()"`;
  
  version(verbose)
  {
    writeln("Writing plots to file: ", chartFileName);
  }
  auto output = executeShell("Rscript -e " ~ script);
  if(output.status != 0)
    writeln("Compilation failed:\n", output.output);
  
  version(verbose)
  {
    writeln("output :\n", output.output);
    writeln("Finished writing file.");
  }
  
  return;
}


void main()
{
  // generates ntrails*nmax points
  long ntrials = 10; long nmax = 1000_000;
  // number of points to plot
  long nPoints = 1000_000;
  
  /* if number of points doesn't make sence, all points are plotted */
  if((nPoints > ntrials*nmax))
    nPoints = ntrials*nmax;
  
  string benchFile = "allocBench.csv";
  benchFile.writeRows(memoryBench!('x')(ntrials, nmax));
  string chartName = "allocBench.jpg";
  /* The last two number are the maximum y values on the range of each plot */
  chartName.writePlot(benchFile, nPoints, 60_000, 1000);
}

                                    
