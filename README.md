**c'est fini**: Work on this compiler is discontinued. Feel free to reuse it :smiley:

---

# ubvl
This repository contains my work for [Compilers (german: _Übersetzerbau_)](http://www.complang.tuwien.ac.at/ubvl/) at Vienna University of Technology (summer semester of 2013).

## Tasks
Throughout the semester we were to accomplish eight tasks. The first two (`asm?`) focused on writing AMD64 assembly, whereas the following six constructed a compiler for a primitive language. Refer to the original assignments (German) in the corresponding subdirectories.

## Tests
We tested our compilers against specific cases which can be found [here](https://github.com/flowlo/ubvl-test).

## Similar repositories

* [bountin](https://github.com/bountin/uebersetzerbau)
* [Mononofu](https://github.com/Mononofu/Uebersetzerbau)
* [schuay](https://github.com/schuay/compilerconstruction)
* [lewurm](http://wien.tomnetworks.com/gitweb/?p=uebersetzerbau-ss10.git;a=summary)

## Results
Optimized code earned me some bonus points.

   task |      % | weight | weighted | max | effective
--------|--------|--------|----------|-----|--------
asma    | 100.00 |    1.0 |  100.00  |  10 |  10.000
asmb    | 115.00 |    1.0 |  115.00  |  10 |  11.500
scanner | 100.00 |    1.0 |  100.00  |  10 |  10.000
parser  | 100.00 |    1.0 |  100.00  |  10 |  10.000
ag      |  80.00 |    1.0 |   80.00  |  20 |  16.000
codea   | 118.00 |    0.7 |   82.60  |  20 |  16.520
codeb   | 116.00 |    1.0 |  116.00  |  20 |  23.200
gesamt  |  89.00 |    1.0 |   89.00  |  20 |  17.800
sum     |    n/a |    n/a |     n/a  | 120 | 115.020
