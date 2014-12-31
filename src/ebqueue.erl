-module(ebqueue).

-behaviour(gen_server).

%% API functions
-export([start_link/0, in/2, out/1]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {
          waiters :: queue:queue(_),
          elements :: queue:queue(_)
         }).

%%%===================================================================
%%% API functions
%%%===================================================================

in(Element, Pid) -> gen_server:cast(Pid, {enqueue, Element}).

out(Pid) -> gen_server:call(Pid, dequeue).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, #state{waiters=queue:new(), elements=queue:new()}}.

handle_call(dequeue, From, State) ->
    case queue:out(State#state.elements) of
        {empty, _} ->
            NewW = queue:in(State#state.waiters, From),
            {noreply, State#state{waiters=NewW}};
        {{value, E}, NewQ} ->
            {reply, E, State#state{elements=NewQ}}
    end.

handle_cast({enqueue, Element}, State) ->
    case queue:out(State#state.waiters) of
        {empty, _} -> %% no waiters we just save the item
            Q = State#state.elements,
            NewQ = queue:in(Element, Q),
            {noreply, State#state{elements=NewQ}};
        {{value, W}, NewW} -> %% feed next waiter
            gen_server:reply(W, {ok, Element}),
            {noreply, State#state{waiters=NewW}}
    end.

handle_info(_Info, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.
