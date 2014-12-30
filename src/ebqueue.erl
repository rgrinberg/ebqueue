-module(ebqueue).

-export ([make/0, pop/1, push/2]).

make() -> {[], []}.

pop(_) -> empty.

push(q, e) -> {[q], e}.
