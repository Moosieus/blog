%{
  title: "Intentional Elixir",
  description: ""
}
---
## Preface
In this post, I'd like to bring awareness to what Joe called [Intentional programming](https://erlang.org/download/armstrong_thesis_2003.pdf#page=121), which I consider vital to effectively utilizing many of Elixir's code patterns. Most Elixir devs already do this in some form, I think there's more benefit to practicing it expressly.

For those uninitiated in Erlang lore, Joe Armstrong published a [PhD thesis](https://erlang.org/download/armstrong_thesis_2003.pdf) in 2003 that's written as a very approachable presentation of well established practices in Erlang.

I'd also like to note that "Intentional programming" here nothing to do with Microsoft's [ill-fated research project](https://en.wikipedia.org/wiki/Intentional_programming) of the same name.

## Intentional Elixir Code
For the purposes of SEO and accessibility, I'm going to directly quote the relevant section here, minimally substituting the Erlang code for Elixir. After that, I'll explore just how well intentional code composes with modern Elixir idioms like the `with` clause.

*Note: Joe references dictionaries, which were supplanted by maps in OTP 17. The code will use "dict" by name here and maps by type.*

First, Joe summarizes what exactly "Intentional programming" means: 

> - Intentional programming — this is a programming style where the programmer can easily see from the code exactly what the programmer intended, rather than by guessing at the meaning from a superficial analysis of the code.

Later he expands on it precisely:

> ### 4.5 Intentional programming
> Intentional programming is a name I give to a style of programming where the reader of a program can easily see what the programmer intended by their code. The intention of the code should be obvious from the names of the functions involved and not be inferred by analysing the structure of the code. This is best explained by an example: In the early days of Erlang the library module `dict` exported a function `lookup/2` which had the following interface:
> ```elixir
> @spec lookup(key::any(), dict::map()) :: {:ok, value::any()} | :not_found
> ```
> Given this definition `lookup/2` was used in three different contexts:
> 
> #### 1. For data retrieval—the programmer would write:
> ```elixir
> {:ok, value} = lookup(key, dict)
> ```
> here `lookup/2` is used for to extract an item with a known key from the dictionary. `key` should be in the dictionary, it is a programming error if this is not the case, so an exception in generated if the key is not found.
> 
> #### 2. For searching — the code fragment:
> ```elixir
> case lookup(key, dict) do
>   {:ok, value} ->
>     # do something with value
>   :not_found ->
>     # do something else
> end
> ```
> searches the dictionary and we do not know if `key` is present or not—it is not a programming error if the key is not in the dictionary.
> #### 3. For testing the presence of a key—the code fragment:
> ```elixir
> case lookup(key, dict) do
>   {:ok, _} ->
>     # do something
>   :not_found ->
>     # do something else
> end
> ```
> tests to see if a specific key `key` is in the dictionary.
>
> When reading thousands of lines of code like this we begin to worry about intentionality—we ask ourselves the question “what did the programmer intend by this line of code?”—by analysing the above three usages of the code we arrive at one of the answers data retrieval, a search or a test. There are a number of dicerent contexts in which keys can be looked up in a dictionary. In one situation a programmer knows that a specific key should be present in the dictionary and it is a programming error if the key is not in the dictionary and the program should terminate. In another situation the programmer does not know if the keyed item is in the dictionary and their program must allow for the two cases where the key is present or not.
>
> Instead of guessing the programmer’s intentions and analyzing the code, a better set of library routines is:
> ```elixir
> @spec fetch!(key::any(), dict::map()) :: value
> @spec search(key::any(), dict::map()) :: {:ok, value} | :not_found
> @spec is_key(key::any(), dict::map()) :: boolean()
> ```
> Which precisely expresses the intention of the programmer—here no guesswork or program analysis is involved, we clearly read what was in-tended.
>
> It might be noted that `fetch!` can be implemented in terms of `search` and vice versa. If `fetch!` is assumed primitive we can write:
> ```elixir
> def search(key, dict) do
>   try do
>     value = fetch!(key, dict)
>     {:found, value}
>   rescue
>     e ->
>       :not_found
>   end
> end
> ```
> This is not really good code, since first we generate an exception (which should signal that the program is in error) and then we correct the error.
> 
> Better is:
> ```elixir
> def find!(key, dict) do
>   case search(key, dict) do
>     {:ok, value} ->
>       value
>     :not_found -> 
>       raise # NotFoundError...
>   end
> end
> ```
> Now precisely one exception is generated which represents an error.

### Takeaways

#### Granularity
I think it's important to highlight just how granularly intentional programming can be effectively applied, even for something as fundamental as data access. Elixir's standard library has many functions that reflect this, including direct workalikes to the examples above:
```elixir
# here's some placeholder data
x = %{
  "foo" => "bar",
  :pi => 3.14,
  :expiration_date => Date.utc_today()
}
```

For *data retrieval* where an absent key is exceptional (unlikely and/or dramatically wrong), there's `Enum.fetch!/2`. With this function, we can forego handling the error and fall back on "let it crash":
```elixir
value = Enum.fetch!(x, :pi) # or x.pi
```

For *searching*, `Enum.fetch/2` lets us neatly handle the not found case:
```elixir
case Enum.fetch(x, "foo") do
  {:ok, value} ->
    # do something with value
  :error ->
    # do something else
end
```

For *testing the presence of a key* there's respective functions for different collection types such as `Map.has_key?/2`, `Keyword.has_key/2`, and, `List.key_member?/3`:
```elixir
if Map.has_key?(x, :expiration_date) do
  # x is perishable
else
  # x is non-perishable
end
```

Even these small variations on map access go a long way. (Write a conclusion here, dovetail into applying intentional functions in our own code).

### Intentional functions in with clauses and pipes
