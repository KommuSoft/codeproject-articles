    Title:       A linear algorithm to generate (uniform) unique subsets
    Author:      KommuSoft
    Email:       Willem.VanOnsem@cs.kuleuven.be
    Language:    C# 3.0, but applicable to any programming language
    Platform:    Any platform
    Technology:  Algorithms
    Level:       Intermediate
    Description: Enter a brief description of your article
    Section      Enter the Code Project Section you Wish the Article to Appear
    SubSection   Enter the Code Project SubSection you Wish the Article to Appear
    License:     Enter the license (<a href="http://www.codeproject.com/info/licenses.aspx">CPOL, CPL, MIT, etc</a>)

 - [algorithm source code]()
 - [article source code](https://github.com/KommuSoft/codeproject-articles/blob/master/unique.md)

In some applications, like for instance social media, one needs to generate a subset of items out of a larger set of items. On *Facebook* for instance, people can enroll to a certain event. The social network then displays some of the people enlisted.

Several methods have been developed. A simple one is to create an empty set and keep adding items to the set until the required number has been achieved. If duplicates are added, the size of the set simply remains the same. A problem with this approach is that it can take long to generate such subsets. Especially if the number of items to pick is close to the total number of items. Furthermore sets are either implemented as a binary tree, or as a hash set. Although the lookup operation is on average case logarithmic or constant respectively, in the case of a hash set it can turn out to be linear. Furthermore it requires one to define a good order relation or hash function. An aspect many programmers lack. The worst case time complexity is thus either *O(k log k)* or *O(k^2)* at least, with *k* the number of items to pick. Finally some datastructures don't allow random access (in the literal sense): one cannot query an `ISet<T>` for a the *i*-th element or a random element.

In this article, we propose a method that scales linearly with the number of items in the original collection. If the number of items to pick *k* is small, this algorithm will, given the original `ICollection<T>` allows random access not outperform the algorithm. If however the datastructure holding the original collection of elements only allows sequential access, or the number of items to pick *k* is close to the number of items in the collection *n*, our algorithm can outperform this.

This article is structured as follows: we fist give an overview of the algorithm in pseudo-code and work out the probabilistic model. Next we consider weighted items, such that some items have a higher probability getting selected. Finally we look how we can speed up the algorithm given the collection provides an `Enumerator<T>` that can skip an arbitrary number of elements in constant time using *Stirling approximation*. We conclude this article by providing benchmark results for the discussed approach and the popular method using a `ISet<T>`.

## Algorithm overview

The algorithm iterates over the entire collection of items. *k* times, the algorithm select a random number between zero and one. Based on the position in the set and the number of items still to generate, a probability is determined in constant time for each element. Using the well known *Roulette-wheel selection* mechanism, one can guarantee *k* items are selected out of a set of *n* items uniformly.

Our algorithm has thus the following form:

    private static Random random = new Random();

    public static IEnumerable<T> pickK<T> (this ICollection<T> collection, int k) {
        int n = collection.Count;
        IEnumerator<T> colenum = collection.GetEnumerator();
        colenum.MoveNext();
        for(; k > 0; k--) {
            double pi = getProbability(n,k,0);//get the probability of the first item being selected
            int i = 0;
            double r = random.NextDouble();
            while(r > pi) {
                r -= pi;
                colenum.MoveNext();
                pi = getProbability(n,k,i);//get the probability of the i-th item being
                i++; selected
            }
            yield return colenum.Current;
            colenum.MoveNext();
            n -= i+1;
        }
    }

We only need to work out the `getProbability(int n, int k, int i);` function. This function will turn out to scale linear with *i*. This is however not a problem: *i* is incremented each time and we can thus use *dynamic programming* to calculate the probability in constant time given we already know the result of `getProbability(n,k,i-1)`. Later we will provide a method to calculate the method in constant time regardless of the value of *i*.

## Probabilistic model

In this section, we will discuss probabilistic models to select *k* elements out of a collection of *n* elements with uniform and weighted probability as well as a scenario where picking the same element again is allowed as well.

### Uniform selection

One calculates the probability of including the *i*-th element in the set given the original collection contains *n* elements and we pick *k*, by counting the number of subsets one can generate given the 

$p\left(n,k,i\right)=\frac{{{n-i-1} \choose {k-1}}}{{n \choose k}}$

Where choosing *n* out of *k* is the number of subsets and choosing *k-1* out of *n-i-1* is the number of subsets that start with *i* since this means we will need to pick the remaining *k-1* elements out of the remaining elements in the set.

A more simplified version of this formula is:

$p\left(n,k,i\right)=\frac{k\cdot\left(n-k\right)!\cdot\left(n-i-1\right)!}{n!\cdot\left(n-i-k\right)!}$

although the formula may look more complicated, it has the advantage one can easily turn it into an incremental formula: given $p\left(n,k,i)$ is known, what is the value for $p\left(n,k,i+1)$:

$p\left(n,k,i+1\right)=\frac{p\left(n,k,i\right)\cdot\left(n-k-i\right)}{n-i-1}$

And furthermore, evidently the value for $i=0$ is equal to:

$p\left(n,k,0\right)=\frac{n}{k}$

Note that the probabilities decrease with *i* increasing. Indeed, if we decide not to pick the first element, that choice is definitive. The probability of picking the first item must thus be larger than picking for instance the fifth one.

The algorithm to pick *k* elements uniformly out of the collection is thus:

    public static IEnumerable<T> pickKUniform<T> (this ICollection<T> collection, int k) {
        int n = collection.Count;
        IEnumerator<T> colenum = collection.GetEnumerator();
        colenum.MoveNext();
        for(; k > 0; k--) {
            double pi = (double) k/n;//get the probability of the first item being selected
            int i = 0;
            double r = random.NextDouble();
            while(r > pi) {
                r -= pi;
                colenum.MoveNext();
                pi *= (double) (n-k-i)/(n-i-1);//get the probability of the i-th item being selected
                i++;
            }
            yield return colenum.Current;
            colenum.MoveNext();
            n -= i+1;
        }
    }


### Weighted items

The social network application will generally not pick the items uniformly: if one observers the subsets closely, one will notice *friends* pop up more often than total strangers. Social networks in other words give *weights* to items. Friends you frequently contact will have a higher weight than someone you only added a few years ago.

We provided an interface to assign weight to an item called the `IWeight` interface:

    public interface IWeight {

        double Weight {
            get;
        }

    }

Where `IWeight.Weight` must be a **positive** value ($0\leq w_i$).

We now need to redefine our probability function `getProbability(int n, int k,int i)` such that it takes into account a vector of weights $\vec{w}$.

We first make an assumption we will eventually relax: the sum of the weights sum up to one:

$\displaystyle\sum_{i=1}^n{w_i}=1$

In that case the probability of selecting the *i*-th value as the first value in the subset is:

$p\left(n,k,i,\vec{w}\right)=\frac{{{n-i-1} \choose {k-1}}\cdot w_i}{{n \choose k}}$

### Repeated selection

### Approximation algorithm for `IJumpEnumerator<T>` instances

Some `ICollection<T>` instances allow fast access: for instance a `List<T>` allows one to access element `5` in constant time. This is a useful feature if the number of items to select *k* is small compared to *n*.

We first describe the `IJumpEnumerator<T>` interface:

    public interface IJumpEnumerator<out T> : IEnumerator<T> {
    
        bool Jump (int delta);
    
    }

This is simply an interface that provides an additional method `bool Jump(int delta)` that has the same behavior as calling `IEnumerator<T>.MoveNext()`, `delta` times.

The *Stirling approximation* is a method to approximate a factorial using the sum over a logarithm and then, approximate that sum by using an integral:

$\log\left(n!\right)=\log\left(\prod_{i=1}^{n}i\right)=\sum_{i=1}^n\log\left(i\right)\approx\int_{1}^{n}\log{x}\ dx=n\cdot\log\left(n\right)-n$

The problem with the Stirling approximation is however that for small values, the relative error is quite large. A more advanced approximation is the *Gosper approximation*:

$\log\left(n!\right)\approx\log\left(\sqrt{\frac{\left(6\cdot n+2\right)\cdot\pi}{3}}\right)+n\cdot\log\left(n\right)-n$

or in a more useful form for the remainder of this section:

$\log\left(\frac{n!}{\left(n-k\right)!}\right)\approx\log\left(\sqrt{\frac{6\cdot n+1}{6\cdot n-6\cdot k+1}}\right)+n\cdot\log\left(\frac{n}{n-k}\right)+k\cdot\log\left(n-k\right)+k$

We can use these approximations, to approximate the value for $p\left(n,k,i\right)$ in constant time with:

p\left(n,k,i\right)=

### Dynamic programming implementation

## Advantages

Our algorithm has some extra advantages over the `ISet<T>` approach we discussed earlier. In this section we give an overview. Most of the advantages are not firm: there are scenarios where this can work in the opposite direction.

### Cache

If one iterates over an `Array` or `List<T>`, the elements are located consecutive in the program's memory. Most processors facilitate this behavior by providing *cache*: a fast memory that maintains a copy of certain regions of the real memory. When an item is not in the cache, it is copied to the cache as well as surrounding memory cells.

It is thus more efficient to iterate over a collection left to right than accessing element in a random order.

### Maintaining order (stable algorithm)

The algorithm will enumerate items in the same order as how they are enumerated by the given collection. This is a trivial feature since the `IEnumerator<T>` can only move forward in the `ICollection<T>`. 

Sometimes the data is given in an order that is important: for instance the `Friend` instances are sorted alphabetically. If one uses the earlier discussed `ISet<T>` approach, but want's to sort the resulting subset, it can be necessary to sort the items again. 

Furthermore in some cases, the order in the original collection does not depend on a property of the items itself: the friends are for instance sorted on the date the people became friends, a property not encoded in a `Friend` instance. This can be tackled by storing the index explicitly, but our method provides a more efficient way to handle this.

### Real-time systems

Average performance is not always the best metric. In *real-time systems*, one aims to guarantee the user that a task will be carried out within a certain time bound. An implementation with an `ISet<T>` cannot guarantee such bound: it is possible, although the probability decreases exponentially, that the algorithm keeps selecting numbers that are already in the set. Although the average performance is not that bad, the distribution of the run time has an infinite tail to the right that makes the algorithm impracticable for real time systems. The proposed algorithm has a random component in it as well, but guarantees progress: there is a moment where it is guaranteed the algorithm has finished its job.

A classic example for this algorithm is an SQL database where the rows are in many cases generated on the fly (thus the additional linear overhead is limited) and where one certainly doesn't want to use a Las Vegas algorithm.

### Constant memory laziness

As one can see, our algorithm uses the `yield` keyword: it is implemented as a co-routine. This is useful if there is any chance, one for instance wants to generate a subset of length *k*, but for instance, is only interested in the first $l<k$ items. Or when for instance the first items don't satisfy a certain criterion.

In the *LINQ* library, many algorithm are implemented as co-routines to enable such behavior. A problem with some of the algorithms is that as more items are generated, the tend to build up memory. In cases where *LINQ* queries are combined in a long chain, this can result in a large amount of memory building up, that is released after a significant amount of time.

Our algorithm doesn't allocate more memory each time. The number and size of local variables  is constant. The only possible way memory is allocated during the evaluation is the algorithm hidden in the `IEnumerator<T>`, no algorithm can have control on the behavior of encapsulated methods.

## Tests

### Empirical evidence of correctness

In order to verify the correctness of our algorithm, we ran three types of tests:

 - Verifying that the number of enumerated items is always equal to *k*;
 - Verify that the original order of the items is maintained; and
 - Running the test several times, counting the number of times a certain item is enumerated and comparing this number with the confidence interval.
 
The tests are all implemented in the `ProbabilityUtilsTest.cs` file and all past several times. We can thus assume that our algorithm is correct.

### Benchmarks

## Context

This research was conducted in the context of the [NUtils](https://github.com/KommuSoft/NUtils) library, a utility library I'm developing in my spare time. The library aims to make my (real) research work more convenient.

## History