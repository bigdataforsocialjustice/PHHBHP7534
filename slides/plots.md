There are several packages in R that handle plotting. Plotting in R can
be very sophisticated and can be a very useful tool to visualize data.
One example to showcase the plotting capability of R is this graph,
which was created with about 150 lines of R code by Paul Butler, showing
the facebook friendship connections around the world.

Here we will introduce bar plots, box plots and scatter plots in the
base graphics system. Then we will briefly mention the lattice graphics.
Because of the complexity of R’s plotting system, we can only scratch
the surface on this topic here. You can learn more about plotting in R
from resources listed at the end of this page. While we will mostly
focus on the base graphics system in this course, you are strongly
recommended to look into the ggplot2 system. These days, more and more
people are using ggplot2 instead of the base graphics system.

# Introduction

This script demonstrates basic plotting in R base

## Creating a dataset

This demonstrates how to create a dataset in R. This will be the only
time we do this, from now on we will import data in the form of .csv,
.sav, .dta, .xlsx, or .sasbat.

``` r
sex_at_birth <- c("male", "male", "female", "male", "female", "female")
age <- c(10, 12, 3, 0, 1, 16)
cbl_score <- c(50, 39, 48, 54, 70, 55)
dep_score <- c(40, 29, 37, 44, 60, 45)
total_score <- cbl_score + dep_score
mydat <- data.frame(sex_at_birth, age, cbl_score, dep_score, total_score)
View(mydat)
```

## Boxplots

The boxplot() function can be used to create box plots.

The following command generates a box plot for age in our data:

``` r
boxplot(mydat$age)
```

![](plots_files/figure-markdown_github/box-1.png)

Now, we change the x-axis label:

``` r
boxplot(mydat$age, xlab = "Age")
```

![](plots_files/figure-markdown_github/boxlabel-1.png)

Now, we change the color

``` r
boxplot(mydat$age, xlab = "Age", col = "steelblue")
```

![](plots_files/figure-markdown_github/boxcolor-1.png)

We can also split the box plots by groups. For example, the command

``` r
boxplot(mydat$age ~ mydat$sex_at_birth,  ylab="Age")
```

![](plots_files/figure-markdown_github/boxbysex-1.png)

Now we can use the boxplot() attributes to make a nice looking boxplot:
Below we - first remove the data$ from the labels and add the data
attribute explicitly - then we change the color - then we change the
color by **sex_at_birth** - then we relabel the boxes by color of
**sex_at_birth**

*Note* Please do NOT think you will understand all of this immediately.
If you want to learn it, take it step-by-step and understand what each
command is doing before moving on!

``` r
boxplot(age ~ sex_at_birth, data=mydat, ylab="Age")
```

![](plots_files/figure-markdown_github/boxbetter-1.png)

``` r
boxplot(age ~ sex_at_birth, data=mydat, ylab="Age", col="steelblue")
```

![](plots_files/figure-markdown_github/boxbetter-2.png)

``` r
boxplot(age ~ sex_at_birth, data=mydat, ylab="Age", col=c("indianred", "steelblue"))
```

![](plots_files/figure-markdown_github/boxbetter-3.png)

``` r
boxplot(age ~ sex_at_birth, 
        data=mydat, 
        ylab="Age", xlab = "Sex at Birth",
        col=c("indianred", "steelblue"),
        names = c("Female", "Male"),
        main = "Boxplot Example")
```

![](plots_files/figure-markdown_github/boxbetter-4.png)

# Scatterplots

Another commonly-used plot is a scatter plot. It is a plot of data
points of one variable versus another. To plot the cbl scores versus
depressive symptoms scores, we use the command:

``` r
plot(mydat$cbl_score, mydat$dep_score)
```

![](plots_files/figure-markdown_github/scatter-1.png)

### Point-Type Parameter pch

By default, each point is represented by an open circle. This can be
changed by setting the pch parameter. We can also change the axis labels
using the xlab and ylab commands:

``` r
plot(cbl_score ~ dep_score, data=mydat, pch=19, ylab="Depressive Symptoms", 
     xlab="Child Behavior Symptoms", las=1)
```

![](plots_files/figure-markdown_github/scatlab-1.png)

We see that the pch=19 option sets the points to be filled circles, and
the las=1 option makes the y-axis numeric labels perpendicular to the
y-axis. Other pch values correspond to other point types, and you can
look them up
[here](https://www.ling.upenn.edu/~joseff/rstudy/week4.html#pch).
Actually, there is an easy way to look it up. Just type the command

``` r
plot(1:25,rep(1,25),pch=1:25)
```

![](plots_files/figure-markdown_github/unnamed-chunk-1-1.png)

It plots the points (1,1), (2,1), (3,1), …, (25,1), with the first point
having pch=1, second point with pch=2 and so on.

Now we can add color and other options as above. Note, the options are
the same for ALL Base R plots (i.e., histograms, barcharts, plots,
boxplots, etc.)

``` r
plot(cbl_score ~ dep_score, 
     data=mydat, pch=19, col="blue", 
     ylab="Depressive Symptoms", 
     xlab="Child Behavior Symptoms", 
     las=3, 
     main = "Scatterplot Example")
```

![](plots_files/figure-markdown_github/scatcol-1.png)

Now let’s color the scatterplot by sex at birth. To do so, R requires
the categorical data to be represented as a factor. We can transform the
variable in the plot itself (as I do below).

``` r
plot(cbl_score ~ dep_score, data=mydat, pch=19, 
     col=as.factor(sex_at_birth), 
     ylab="Depressive Symptoms", 
     xlab="Child Behavior Symptoms", las=1)  
```

![](plots_files/figure-markdown_github/scatshape-1.png)

We can also change the variable in the dataset from character to factor
and then plot it (this is easier).

``` r
(mydat$sex_at_birth <- as.factor(mydat$sex_at_birth))
```

    ## [1] male   male   female male   female female
    ## Levels: female male

``` r
plot(cbl_score ~ dep_score, data=mydat, pch=19, 
     col=sex_at_birth, 
     ylab="Depressive Symptoms", 
     xlab="Child Behavior Symptoms", las=1)  
```

![](plots_files/figure-markdown_github/unnamed-chunk-2-1.png)

## CHALLENGE

Finally, we want to create a legend that shows the color scheme for the
variable sex_at_birth. We also include horizontal lines representing the
averages for each score (i.e., cbl and depressive symptoms). Follow
along –\>

``` r
plot(cbl_score ~ dep_score, data=mydat, pch=19, 
     col = c("violet", "blue")[as.factor(mydat$sex_at_birth)], 
     ylab="Depressive Symptoms", 
     xlab="Child Behavior Symptoms", las=1, 
     main = "Scatterplot Example")  
legend(30,70,c("Female","Male"),col=c("violet", "blue"),pch=19)
abline(h=mean(mydat$cbl_score),v=mean(mydat$dep_score))
```

![](plots_files/figure-markdown_github/scatfinal-1.png)

``` r
plot(cbl_score ~ dep_score, data=mydat, pch=19, 
     col = c("blue", "violet")[mydat$sex_at_birth], 
     ylab="Depressive Symptoms", 
     xlab="Child Behavior Symptoms", las=1, cex = 1.5,
     main = "Scatterplot Example")  
legend(30,70,c("Female","Male"),col=c("blue", "violet"),pch=19)
abline(h=mean(mydat$cbl_score),v=mean(mydat$dep_score))
```

![](plots_files/figure-markdown_github/scatfinalbigger-1.png)

``` r
c("blue", "violet")[mydat$sex_at_birth]
```

    ## [1] "violet" "violet" "blue"   "violet" "blue"   "blue"

``` r
mydat$sex_at_birth
```

    ## [1] male   male   female male   female female
    ## Levels: female male

``` r
hist(mydat$age) 
```

![](plots_files/figure-markdown_github/boxbetter2-1.png)

``` r
# in the R console type ?hist to bring up the help screen
# fancy the hist of age

table(mydat$sex_at_birth)
```

    ## 
    ## female   male 
    ##      3      3

``` r
barplot(table(mydat$sex_at_birth),ylim=c(0,5), ylab="percent",main="Barplot of Gender")
```

![](plots_files/figure-markdown_github/boxbetter2-2.png)

## Writing and Reading Data

We can save the datafile to the computer for later as follows:

``` r
write.csv(mydat, "mydat.csv")
```

The default is to save the file to the working directory. So, it is
useful to set the working directory at the outset. My working directory
is

``` r
getwd()
```

    ## [1] "C:/Users/barboza-salerno.1/evalsp23.classes.andrewheiss.com/slides"

Now, let’s read the csv file and re-run all charts…

``` r
mydat <- read.csv("mydat.csv")
```
