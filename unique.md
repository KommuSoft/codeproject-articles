# A linear algorithm to generate (uniform) unique subsets

In some applications, like for instance social media, one needs to generate a subset of items out of a larger set of items. On *Facebook* for instance, people can enroll to a certain event. The social network then displays some of the people enlisted.

Several methods have been developed. A simple one is to create an empty set and keep adding items to the set until the required number has been achieved. If duplicates are added, the size of the set simply remains the same. A problem with this approach is that it can take long to generate such subsets. Especially if the number of items to pick is close to the total number of items. Furthermore sets are either implemented as a binary tree, or as a hash set. Although the lookup operation is on average case logarithmic or constant respectively, in the case of a hash set it can turn out to be linear. Furthermore it requires one to define a good order relation or hash function. An aspect many programmers lack. The worst case time complexity is thus either *O(k log k)* or *O(k^2)* at least, with *k* the number of items to pick. Finally some datastructures don't allow random access (in the literal sense): one cannot query an `ISet<T>` for a the *i*-th element or a random element.

In this article, we propose a method that scales linearly with the number of items in the original collection. If the number of items to pick *k* is small, this algorithm will, given the original `ICollection<T>` allows random access not outperform the algorithm. If however the datastructure holding the original collection of elements only allows sequential access, or the number of items to pick *k* is close to the number of items in the collection *n*, our algorithm can outperform this.

# Algorithm overview

# Probabilistic model

# Weighted items

The social network application will generally not pick the items uniformly: if one observers the subsets closely, one will notice *friends* pop up more often than total strangers. Social networks in other words give *weights* to items. Friends you frequently contact will have a higher weight than someone you only added a few years ago.