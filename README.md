importr
=======

Example
-------

```
library(importr)

module <- import({
  library(MASS)
  rnorm <- function() mvrnorm(1, 0, 1)
})

# we can call rnorm
module$rnorm()
# attaching the library MASS in the import did not affect the global environment
# so we can't call it from here
exists("mvrnorm") == FALSE
# assigning mvrnorm does not screw up our import
mvrnorm = "no"
module$rnorm()
```

Why importr?
------------

R has good support for modularity and isolation of code via packaging.
However, the packaging system requires a myriad of files, and is extremely irritable.
Many R projects need to use a set of functions across project scripts, but don't need to go to the work of packaging them.
One solution is to use `source` to load functions you will need.
However, the downside of this approach is that if you reassign a variable that is used by a function from the sourced script, it will break.

For example, suppose I have the file `utils.R` that contains..

```
f <- function() sum(1:3)

```

doing the following may result in unexpected results..

```
source('utils.R')
f()    # 6

sum <- function(x) "no"
f()    # "no"
```

In most cases, relying on one big global workspace for everything is dangerous.
`importr` resolves this by ensuring two things for imported code:

1. global variables won't affect the code.
2. the code won't affect global variables (e.g. via library)

This approach was heavily inspired by Python and Javascript!
