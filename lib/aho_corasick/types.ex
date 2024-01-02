defmodule AhoCorasick.Types do
  @moduledoc """
  Types used in the AhoCorasick module.
  """

  @typedoc """
  A reference to an AhoCorasick automata.

  This is a reference to a uniquly identifable AhoCorasick automata in the NIF memory space.
  """
  @type automata :: reference()

  @typedoc """
  Ther are several common errors and failure modes that can occur when using the NIFs.

  `:unsupported_type` - The type of the argument passed to the NIF is not supported. Try to validate
  the passed args. (The library should manage this for you, so this is a bug in the library.)
  `:lock_fail` - The NIF was unable to acquire a lock on the automata. This indicates that the
  automata is being used by another process. You can try again... but you should try to figure out
  how you shared the reference to the automata in the first place.

  `String.t()` - The NIF returned a string. This is likely a bug in the library related to the way
    patterns are being passed to the NIF.
  """
  @type errors :: :unsupported_type | :lock_fail | String.t()

  @typedoc """
  A match is a tuple of the form `{pattern, match, start, end}`.

  `pattern` - The pattern that originated the match.
  `match` - The substring of the haystack that matched the pattern.
  `start` - The index of the haystack where the match started.
  `end` - The index of the haystack where the match ended.

  `pattern` and `match` are both utf8 encoded strings. `start` and `end` are both non-negative
  """
  @type match :: {pattern :: String.t(), match :: String.t(), start :: non_neg_integer(), end_ :: non_neg_integer()}
end
