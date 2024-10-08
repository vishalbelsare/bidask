# Pseudocode

This file provides the pseudocode to simplify implementations of the estimator in any programming language. 

### Input

Vectors of `open`, `high`, `low`, and `close` prices. The vectors must be sorted in ascending order of the timestamp. The function should also accept the argument `sign` specifying whether signed estimates should be returned.

### Output

Numeric spread estimate. A value of 0.01 corresponds to a spread of 1%.

### Algorithm

```python
# convert prices to logs
o = log(open)
h = log(high)
l = log(low)
c = log(close)
m = (h + l) / 2.

# lag prices by one period 
h1 = lag(h)
l1 = lag(l)
c1 = lag(c)
m1 = lag(m)

# compute indicator variables
tau = h != l OR l != c1 
phi1 = o != h AND tau
phi2 = o != l AND tau
phi3 = c1 != h1 AND tau
phi4 = c1 != l1 AND tau

# compute means
pt = mean(tau)
po = mean(phi1) + mean(phi2)
pc = mean(phi3) + mean(phi4)

# compute returns
r1 = m-o
r2 = o-m1
r3 = m-c1
r4 = c1-m1
r5 = o-c1

# demean returns
d1 = r1 - tau * mean(r1) / pt
d3 = r3 - tau * mean(r3) / pt
d5 = r5 - tau * mean(r5) / pt

# compute the following vectors
x1 = -4./po*d1*r2 -4./pc*d3*r4 
x2 = -4./po*d1*r5 -4./pc*d5*r4 

# compute expectations
e1 = mean(x1)
e2 = mean(x2)

# compute variances
v1 = mean(x1*x1) - e1*e1
v2 = mean(x2*x2) - e2*e2

# compute square spread
s2 = (v2*e1 + v1*e2) / (v1 + v2)

# compute square root
s = sqrt(abs(s2))
if sign AND s2 < 0: 
    s = -s

# return the spread
return s
```

### Testing

To test your implementation, import the data available [here](https://raw.githubusercontent.com/eguidotti/bidask/main/pseudocode/ohlc.csv). The file contains sample OHLC simulated price data to simplify testing. The data have been generated by simulating a price process as described in [Ardia, Guidotti, & Kroencke (2024)](https://doi.org/10.1016/j.jfineco.2024.103916) with 390 trades per day and a 1% probability to observe a trade. The simulation uses a constant spread of 1%. By running the estimation, you should obtain a spread estimate of **0.0101849034905478**. If you obtain a different results, you may use the following table to check and debug the intermediate steps.

| variable | value        |
| -------- | ------------ |
| `pt`     | 0.9820982    |
| `po`     | 1.227923     |
| `pc`     | 1.205221     |
| `e1`     | 0.0001070243 |
| `e2`     | 0.0001015958 |
| `v1`     | 2.074216e-06 |
| `v2`     | 1.346128e-06 |
| `s2`     | 0.0001037323 |

### Contribute

Have you implemented the estimator in a new programming language? If you want your implementation to be included in this repository, please open a [pull request](https://github.com/eguidotti/bidask/pulls) 