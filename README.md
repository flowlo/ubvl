# ubvl

This repository contains my work for [Compilers (_Übersetzerbau_)](http://www.complang.tuwien.ac.at/ubvl/) at Vienna University of Technology (summer semester of 2013).

## Tasks

Over the semester we had to do accomplish 8 tasks. The first two (`asm?`) focused on writing AMD64 assembly, whereas the following six constructed a compiler for a primitive language.


## Tests

We tested our compiler against specific cases which can be found [here](https://github.com/flowlo/ubvl-test).

## Results

   task |      % | _w_ | weighted | effective | max
--------|--------|-----|----------|-----------|----
   asma | 100.00 | 1.0 |  100.00  |  10.000   |  10
   asmb | 115.00 | 1.0 |  115.00  |  11.500   |  10
scanner | 100.00 | 1.0 |  100.00  |  10.000   |  10
 parser | 100.00 | 1.0 |  100.00  |  10.000   |  10
     ag |  80.00 | 1.0 |   80.00  |  16.000   |  20
  codea | 118.00 | 0.7 |   82.60  |  16.520   |  20
  codeb | 116.00 | 1.0 |  116.00  |  23.200   |  20
 gesamt |  89.00 | 1.0 |   89.00  |  17.800   |  20
    sum |        |     |          | 115.020   | 100
