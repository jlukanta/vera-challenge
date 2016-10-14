[CHALLENGE]

Write a function that takes two parameters:
(1) a String representing the contents of a text document
(2) an integer providing the number of items to return

- Implement the function such that it returns a list of Strings ordered by word frequency, the most frequently occurring word first. 
- Use your best judgement to decide how words are separated.
- Implement this function as you would for a production / commercial system
- You may use any standard data structures.
- We prefer Java, but feel free to use your choice of language for the solution.

Performance Constraints:
- Your solution should run in O(n) time where n is the number of characters in the document. 
- Please provide reasoning on how the solution obeys the O(n) constraint. 

======================================================================================================

[Usage]
Usage: ./popularWords <n> <text>
n has to be more than 0
Example: ./PopularWords 1 "test tEst TEST Text"

======================================================================================================

[EXPLANATION]

The algorithm accepts a text and integer x as inputs. It parses the text and returns an array of k words. Then it analyzes the words to get x most frequent words.

I am using a string parser from the standard framework library which will perform in O(n). That leaves us to solve analyzing the array of words in O(n).

To tackle this, I sort the words and return the x most frequent words. I use some ideas from Bucket Sort algorithm which runs in O(n)

There are 4 steps in this strategy:
(1) Given k words, find out how many times each unique words appear (word frequency), store information in wordToFrequency hashmap
(2) Create buckets indexed by frequency to words. Fill each bucket with words that have the same frequency. (eg. bucket with frequency = 2 has all words that appears twice in the text)
(3) Sort the buckets using Bucket Sort algorithm
(4) Return x most frequent words

Keep in mind that 0 <= k <= n/2 < n. In the worst case scenario, the input text has unique words with length one, each separated by one delimiter (eg. “a,b,c,d”)
So O(k) = O(n/2) = O(n)

Step (1) - Find word frequency
A hashmap to track word to frequency is needed, let’s call it wordToFrequency.
Iterate for each given word and increase the word frequency in wordToFrequency hashmap accordingly. For each iteration, Insertion and data update/access in hashmap can be done in O(1). So for k words, it will take O(n)

Step (2) - Fill frequency to words buckets
A buckets indexed by frequency is needed. The bucket is an array of size (maximum frequency + 1). Maximum frequency can be obtained easily in step (1).
To fill the buckets, iterate for each unique word in wordToFrequency hashmap and put each word in the appropriate bucket, where bucketIndex = word frequency.
Each bucket has a linked list of WordNode that stores a pair of word and a pointer to the next WordNode. If there is more than one word that have the same frequency, there will be collision. To solve this, insert the new node at the beginning of the linked list. Therefore, insertion can be done in O(1) regardless of collision.
If there are m unique words where 0 <= m <= k (unique words cannot be more than k words in text), then part (2) can be done in O(n)

Step (3) - Sort the word frequency buckets
An array to store sortedWords of size m is needed.
Iterate for each bucket and store each word in the bucket into sorted words array.
The words need to be sorted by the most frequent first so iterate from the end to the beginning of FrequencyToWords buckets.
Although there are m unique words, there are k words in total so sorting only takes O(n)

Step (4) - Return x most popular words
Return subarray of sorted words from index 0 to (x-1). If x > sorted words array size, then return sorted words array.
This operation should take O(n)

======================================================================================================

[SUMMARY]

Overall run time complexity is

	Parsing text                          O(n)
	Building wordToFrequency hashmap      O(n)
	Filling frequencyToWords buckets      O(n)
	Bucket sort frequencyToWords buckets  O(n)
	Return x most frequent words          O(n)
	——————————————————————————————————————————
	Overall performance                   O(n)

Overall extra space

	Words array                           O(n)
	wordToFrequency hashmap               O(n)
	frequencyToWords buckets              O(n)
	sortedWords array                     O(n)
	x most frequentWords array     O(x) = O(n)
	——————————————————————————————————————————
	Overall extra space                   O(n)
