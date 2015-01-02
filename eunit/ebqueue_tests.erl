-module(ebqueue_tests).
-include_lib("eunit/include/eunit.hrl").

in_out_test() ->
    {ok, Q} = ebqueue:start_link(),
    ebqueue:in(testing, Q),
    ?assertEqual({ok, testing}, ebqueue:out(Q)).

blocking_test() ->
    {ok, Q} = ebqueue:start_link(),
    Pid = spawn(
            fun () ->
                    receive
                        Pid -> Pid ! ebqueue:out(Q)
                    end
            end),
    ebqueue:in(testing, Q),
    Pid ! self (),
    receive E -> ?assertEqual({ok, testing}, E)
    after 1000 -> ?assertEqual(1, 2)
    end.

timeout_test() ->
    {ok, Q} = ebqueue:start_link(),
    ?assertEqual(timeout, ebqueue:out(Q, 1000)).

few_elements_test() ->
    {ok, Q} = ebqueue:start_link(),
    ok = lists:foreach(fun (X) -> ebqueue:in(X, Q) end, [1, 2, 3]),
    {ok, V1} = ebqueue:out(Q),
    {ok, V2} = ebqueue:out(Q, 1000),
    {ok, V3} = ebqueue:out(Q, 2000),
    ?assertEqual({1,2,3}, {V1, V2, V3}).
