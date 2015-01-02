-module(ebqueue_tests).
-include_lib("eunit/include/eunit.hrl").

in_out_test() ->
    {ok, Q} = ebqueue:start_link(),
    ebqueue:in(testing, Q),
    {ok, V} = ebqueue:out(Q),
    ?assertEqual(testing, V).

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
