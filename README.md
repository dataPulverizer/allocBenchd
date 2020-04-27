# Memory allocation benchmark in D

Benchmarks `malloc` and `free`. In `main`, `ntrials` is the number of times each allocation is to be executed and meaured `nmax` is the maximum array length, so total number of measurements is `ntrials*nmax`. In `main`, a chart is generated with `chartName.writePlot(benchFile, nPoints, 60_000, 1000);`, the last two numbers are the maximum value of `time (ns)` on the vertical axis in each chart for `malloc` and `free` respectively, they default to `-1` to accept maximum chart range.

The function `auto memoryBench(alias x, string units = "nsecs", uint mask = GC.BlkAttr.NO_SCAN)(long ntrials, long nmax)` is the benchmarking function. The `mask` template parameter determines how D's garbage collection executes and defaults to a fast mode; `units` is the time unit described [here](https://dlang.org/phobos/std_datetime_stopwatch.html), the template parameter `x` is an instance of what the array should be filled with, it can be of any type.

At the moment the chart is plotted using R's base graphic, here is an example of what the chart looks like: <img class="plot" src="https://github.com/dataPulverizer/allocBenchd/blob/master/allocBench.jpeg">

The plot sampes data from the created benchmark table, the number of points to sample in the plot is `nPoints` in main. Set to -1 if you want all the data to be plotted.

## Prerequisites

You'll need an installation of [D](https://dlang.org/) and [R](https://cran.r-project.org/), also you need the `data.table` R package installable on the R interpreter with:

```
install.packages("data.table")
```

Compile and run with (linux):
```
dmd allocBench.d -version=verbose && ./allocBench
```
`-version=verbose` shows progress messages.

**The maximum array size (nmax) is very large by default which will take time, so you might want to change it to something like `10_000` for demo.**


Enjoy!


<style>
.plot {
   width: 50vw;
}
</style>
