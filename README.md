# Memory allocation benchmark in D

Benchmarks `malloc` and `free`. In `main`, `ntrials` is the number of times each allocation is to be executed and meaured `nmax` is the maximum array length, so total number of measurements is `ntrials*nmax`. In `main`, a chart is generated with `chartName.writePlot(benchFile, nPoints, 60_000, 1000);`, the last two numbers are the maximum value of `time (ns)` in each chart, `malloc` and `free` respectively, they default to `-1` to accept maximum chart range.

Compile with
```
dmd allocBench.d -version=verbose
```
to see messages.

The maximum array size (nmax) is very large by default which will take time, so you might want to turn it to `10_000`.

Enjoy!
