# Ebqueue - Simplest Blocking Unbounded Queue in Erlang

## Usage

```
% create a queue
{ok, Q} = ebqueue:start_link().

% add some elements

ebqueue:in({xxx, 123}, Q).
ebqueue:in({yyy, 456}, Q).

% read from the queue
{ok, Element} = ebqueue:out(Q).

% read from queue with timeout
case ebqueue:out(Q, 1000) of
    timeout -> io:format("Timed out.");
    {ok, E} -> io:format("Got element ~p", [E])
end.
```
