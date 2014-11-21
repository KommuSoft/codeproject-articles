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

This article is structured as follows: we fist give an overview of the algorithm in pseudo-code and work out the probabilistic model. Next we consider weighted items, such that some items have a higher probability getting selected. Finally we look how we can speed up the algorithm given the collection provides an `Enumerator<T>` that can skip an arbitrary number of elements in constant time. We conclude this article by providing benchmark results for the discussed approach and the popular method using a `ISet<T>`.

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
                pi *= (n-k-i)/(n-i-1);//get the probability of the i-th item being selected
                i++;
            }
            yield return colenum.Current;
            colenum.MoveNext();
            n -= i+1;
        }
    }


### Weighted items

The social network application will generally not pick the items uniformly: if one observers the subsets closely, one will notice *friends* pop up more often than total strangers. Social networks in other words give *weights* to items. Friends you frequently contact will have a higher weight than someone you only added a few years ago.

### Repeated selection

### `IJumpEnumerator<T>` instances

Some `ICollection<T>` instances allow fast access: for instance a `List<T>` allows one to access element `5` in constant time. This is a useful feature 

### Dynamic programming implementation

## Micro-advantages

Our algorithm has some extra advantages over the `ISet<T>` approach we discussed earlier. In this section we give an overview. Most of the advantages are not firm: there are scenarios where this can work in the opposite direction.

### Cache

If one iterates over an `Array` or `List<T>`, the elements are located consecutive in the program's memory. Most processors facilitate this behavior by providing *cache*: a fast memory that maintains a copy of certain regions of the real memory. When an item is not in the cache, it is copied to the cache as well as surrounding memory cells.

It is thus more efficient to iterate over a collection left to right than accessing element in a random order.

### Maintaining order (stable algorithm)

The algorithm will enumerate items in the same order as how they are enumerated by the given collection. This is a trivial feature since the `IEnumerator<T>` can only move forward in the `ICollection<T>`. 

Sometimes the data is given in an order that is important: for instance the `Friend` instances are sorted alphabetically. If one uses the earlier discussed `ISet<T>` approach, but want's to sort the resulting subset, it can be necessary to sort the items again. 

Furthermore in some cases, the order in the original collection does not depend on a property of the items itself: the friends are for instance sorted on the date the people became friends, a property not encoded in a `Friend` instance. This can be tackled by storing the index explicitly, but our method provides a more efficient way to handle this.

### Constant memory laziness

## Tests

### Empirical evidence of correctness

### Benchmarks
