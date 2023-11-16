# *This is a draft.*
*I've shared this so I can ask others for feedback.*

## What "technical debt" articles miss

Everyone knows about technical debt: Hasty work today makes work more difficult in the future and often compoundingly so. However most tech writers don't explore how debtors respond to the pressures of debt.

Often when debtors are struggling under payments of compounding interest, they face outsized incentive to further finance their debt in order to net short term reprieves and sense of normalcy. I find a similar phenomenon occurs in writing and maintaining software systems.

I'm going to drop the analogy financial debt here though. Code isn't fungible like money - you can't bail software systems out of "debt" overnight by throwing a bunch of "developer bux" at it.

## The problem from first principles

> Bodging is a wonderful British word that means to patch together, to make temporary repairs. A bodge is clumsy, it's inelegant, it'll fall apart, but it'll work. And it'll keep working as long as there's someone around to bodge it again if it breaks.

*- [The Art of the Bodge](https://www.youtube.com/watch?v=lIFE7h3m40U) by Tom Scott*

Committing bodges in codebases shifts the path of least resistance for future work towards further bodging.

This is because the fastest and most aparent way to fix shortfalls in bodges is usually to wrap them in further bodges. As layers of bodges accumulate, it becomes more difficult to understand how the code functions: Cyclomatic complexity explodes, side effects proliferate, and interstitial steps sprout.

These issues cross-multiply *making proper solutions significantly more expensive, making the further application of bodges the only sustainable option.*

## Back of the envelope example

You're tasked with resolving issued and adding features to a bodge-ridden codebase. Your options are as follows:

1. Expend more time and effort untangling the bodges, identifying better solutions, and implementing them.
2. Expend less time and effort by applying a quick ad-hoc fix.

Option 2 is often favored for being less mentally taxing and solving immediate problems much faster. 

In month 1 of your involvement with a project, the average time to fix an issue with a bodge is 1 hour. To fix it properly would take 2x as long, or 2 hours. This leaves a marginal difference of 1 hour. At this point issues are already piling up, as they often are in the real world. Hence at the behest of your environmental pressures, solve all problems using bodges.

In month 2, the average "bodge time" is 2 hours. The average proper fix is 2x as long or 4 hours. The marginal difference is now 2 hours.

In month 3, "bodge time" is 3 hours, proper is x3 at 9 hours, marginal difference of 6 hours (almost a work-day).

In month 4, "bodge time" is 4 hours, proper is x4 at 16 hours, marginal difference of 12 hours (>1 work-day).

In month 5, "bodge time" is 5 hours, proper is x5 at 25 hours, marginal difference of 20 hours (1/2 a work-week).

In month 6, "bodge time" is 6 hours, proper is x6 at 36 hours, marginal difference of 30 hours (3/4 a work-week).

Here we see the shifting path of least resistance illustrated; successive bodges have increased the baseline difficulty while also pushing proper fixes further out of reach.

While this model's **x** vs **x<sup>2</sup>** for sake of simple illustration, I'd argue real world systems face *magnitudes worse scaling*.

## Conclusion
Try your best to get things 80% right the first time. *You won't be able to shed your bodge.*

## Further Reading
[eXtreme Go Horse Methodology](https://medium.com/@dekaah/22-axioms-of-the-extreme-go-horse-methodology-xgh-9fa739ab55b4) 🇧🇷
