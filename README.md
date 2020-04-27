# Memory allocation benchmark in D

Benchmarks `malloc` and `free`. In `main`, `ntrials` is the number of times each allocation is to be executed and meaured `nmax` is the maximum array length, so total number of measurements is `ntrials*nmax`. In `main`, a chart is generated with `chartName.writePlot(benchFile, nPoints, 60_000, 1000);`, the last two numbers are the maximum value of `time (ns)` in each chart, `malloc` and `free` respectively, they default to `-1` to accept maximum chart range.

At the moment the chart is plotted using R's base graphic, here is an example of what the chart looks like: <img class="plot" src="https://github.com/dataPulverizer/allocBenchd/blob/master/allocBench.jpeg">

The plot sampes data from the created benchmark table, the number of points to sample in the plot is `nPoints` in main. Set to -1 if you want all the data to be plotted.

## Prerequisites

You'll need an installation of D and R, also you need the `data.table` R package installable on the R interpreter with:

```
install.packages("data.table")
```

Compile and run with
```
dmd allocBench.d -version=verbose && ./allocBench
```
to see messages.

The maximum array size (nmax) is very large by default which will take time, so you might want to turn it to `10_000`.

Enjoy!


<style>
.plot {
   width: 50vw;
}
</style>
