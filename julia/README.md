# Efficient Estimation of Bid-Ask Spreads from Open, High, Low, and Close Prices

Implements the efficient estimator of bid-ask spreads from open, high, low, and close prices described in Ardia, Guidotti, & Kroencke (JFE, 2024): [https://doi.org/10.1016/j.jfineco.2024.103916](https://doi.org/10.1016/j.jfineco.2024.103916)

## Installation

Install this package with:

```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/eguidotti/bidask.git", subdir="julia/"))
```

## Usage

Import the package:

```julia
using BidAsk
```

Arguments:

```julia
edge(open, high, low, close, sign=false)
```

| field   | description                         |
| ------- | ----------------------------------- |
| `open`  | AbstractVector of open prices.      |
| `high`  | AbstractVector of high prices.      |
| `low`   | AbstractVector of low prices.       |
| `close` | AbstractVector of close prices.     |
| `sign`  | Whether to return signed estimates. |

The input prices must be sorted in ascending order of the timestamp.

The output value is the spread estimate. A value of 0.01 corresponds to a spread of 1%.

## Example

```julia
using BidAsk
using CSV

df = CSV.File(download("https://raw.githubusercontent.com/eguidotti/bidask/main/pseudocode/ohlc.csv"))
edge(df.:Open, df.:High, df.:Low, df.:Close)    
```

## Cite as

> Ardia, D., Guidotti, E., Kroencke, T.A. (2024). Efficient Estimation of Bid-Ask Spreads from Open, High, Low, and Close Prices. *Journal of Financial Economics*, 161, 103916. [doi: 10.1016/j.jfineco.2024.103916](https://doi.org/10.1016/j.jfineco.2024.103916)

A BibTex  entry for LaTeX users is:

```bibtex
@article{edge,
  title = {Efficient estimation of bid–ask spreads from open, high, low, and close prices},
  journal = {Journal of Financial Economics},
  volume = {161},
  pages = {103916},
  year = {2024},
  doi = {https://doi.org/10.1016/j.jfineco.2024.103916},
  author = {David Ardia and Emanuele Guidotti and Tim A. Kroencke},
}
```

