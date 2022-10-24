%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 1997-2018. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%
%%%----------------------------------------------------------------
%%% Purpose: Test suite for the 'maps' module.
%%%-----------------------------------------------------------------

-module(maps_SUITE).

-include_lib("common_test/include/ct.hrl").

-export([all/0, suite/0]).

-export([t_update_with_3/1, t_update_with_4/1,
         t_get_3/1, t_filter_2/1, t_filtermap_2/1,
         t_fold_3/1,t_map_2/1,t_size_1/1, t_foreach_2/1,
         t_iterator_1/1, t_put_opt/1, t_merge_opt/1,
         t_with_2/1,t_without_2/1,
         t_intersect/1, t_intersect_with/1,
         t_merge_with/1, t_from_keys/1,
         error_info/1,
         t_from_list_kill_process/1,
         t_from_list_check_trapping/1]).

%%-define(badmap(V,F,Args), {'EXIT', {{badmap,V}, [{maps,F,Args,_}|_]}}).
%%-define(badarg(F,Args), {'EXIT', {badarg, [{maps,F,Args,_}|_]}}).
%% silly broken hipe
-define(badmap(V,F,_Args), {'EXIT', {{badmap,V}, [{maps,F,_,_}|_]}}).
-define(badkey(K,F,_Args), {'EXIT', {{badkey,K}, [{maps,F,_,_}|_]}}).
-define(badarg(F,_Args), {'EXIT', {badarg, [{maps,F,_,_}|_]}}).

suite() ->
    [{ct_hooks,[ts_install_cth]},
     {timetrap,{minutes,1}}].

all() ->
    [t_update_with_3,t_update_with_4,
     t_get_3,t_filter_2,t_filtermap_2,
     t_fold_3,t_map_2,t_size_1,t_foreach_2,
     t_iterator_1,t_put_opt,t_merge_opt,
     t_with_2,t_without_2,
     t_intersect, t_intersect_with,
     t_merge_with, t_from_keys,
     error_info,
     t_from_list_kill_process,
     t_from_list_check_trapping].

t_from_list_kill_process(Config) when is_list(Config) ->
    Killer = self(),
    {Child, ChildRef} =
        spawn_monitor(
          fun() ->
                  MapSize = 10000,
                  List = [{X, X} || X <- lists:seq(1, MapSize)],
                  (fun Loop(Round) ->
                          io:format("Sarting Round ~p~n", [Round]),
                          case Round =:= 0 of
                              true ->
                                  Killer ! starting;
                              false ->
                                  ok
                          end,
                          Map = maps:from_list(List),
                          io:format("Child survived round ~p ~p~n", [Round, maps:size(Map)]),
                          Loop(Round + 1)
                  end)(0)
          end),
    receive
        starting -> ok
    end,
    exit(Child, kill),
    %wait for exit message
    receive
        {'DOWN', ChildRef, process, _, killed} -> ok
    end,
    ok.

%% Check that maps:from_list/1 is trapping
t_from_list_check_trapping(Config) when is_list(Config) ->
    Tracer = self(),
    {Pid, Mon} =
        spawn_monitor(
          fun () ->
                  ListTmp = [{X,X} || X <- [X || {_,X} <- lists:sort([ {rand:uniform(), N} || N <- lists:seq(1,100000)])]],
                  List = [{-1,-1} | ListTmp],
                  erlang:yield(),
                  erlang:trace(self(),true,[running,{tracer,Tracer}]),
                  M = maps:from_list(List),
                  %% To avoid that compiler optimizes away the call above
                  maps:get(-1, M)
          end),
    receive
	{'DOWN', Mon, process, Pid, Reason} ->
	    normal = Reason
    end,
    TD = erlang:trace_delivered(Pid),
    receive
	{trace_delivered, Pid, TD} ->
	    NoYields = trace_get_number_of_yields(Pid, {maps, from_list, 1}, 0),
	    io:format("No of yields: ~p~n", [NoYields]),
	    true =  NoYields > 2
    end,
    ok.

trace_get_number_of_yields(P, TrapFunc, N) ->
    receive
	{trace, P, out, TrapFunc} ->
	    receive
		{trace, P, in, TrapFunc} ->
                    trace_get_number_of_yields(P, TrapFunc, N+1)
	    after 0 ->
		    exit(trap_sched_mismatch)
	    end;
	{trace, P, out, Func} ->
	    receive
		{trace, P, in, Func} ->
		    trace_get_number_of_yields(P, TrapFunc, N)
	    after 0 ->
		    exit(other_sched_mismatch)
	    end
    after 0 ->
	    N
    end.

t_from_keys(Config) when is_list(Config) ->
    Map0 = maps:from_keys(["a", 2, {three}], value),
    3 = map_size(Map0),
    #{"a":=value,2:=value,{three}:=value} = Map0,

    Map1 = maps:from_keys([1, 2, 2], {complex,value}),
    2 = map_size(Map1),
    #{1:={complex,value},2:={complex,value}} = Map1,

    Map2 = maps:from_keys([], value),
    0 = map_size(Map2),

    ?badarg(from_keys,[[a|b],value]) = (catch maps:from_keys([a|b],value)),
    ?badarg(from_keys,[not_list,value]) = (catch maps:from_keys(not_list,value)),
    ok.

t_update_with_3(Config) when is_list(Config) ->
    V1 = value1,
    V2 = <<"value2">>,
    V3 = "value3",
    Map = #{ key1 => V1, key2 => V2, "key3" => V3 },
    Fun = fun(V) -> [V,V,{V,V}] end,

    #{ key1 := [V1,V1,{V1,V1}] } = maps:update_with(key1,Fun,Map),
    #{ key2 := [V2,V2,{V2,V2}] } = maps:update_with(key2,Fun,Map),
    #{ "key3" := [V3,V3,{V3,V3}] } = maps:update_with("key3",Fun,Map),

    %% error case
    ?badmap(b,update_with,[[a,b],a,b]) = (catch maps:update_with([a,b],id(a),b)),
    ?badarg(update_with,[[a,b],a,#{}]) = (catch maps:update_with([a,b],id(a),#{})),
    ?badkey([a,b],update_with,[[a,b],Fun,#{}]) = (catch maps:update_with([a,b],Fun,#{})),
    ok.

t_update_with_4(Config) when is_list(Config) ->
    V1 = value1,
    V2 = <<"value2">>,
    V3 = "value3",
    Map = #{ key1 => V1, key2 => V2, "key3" => V3 },
    Fun = fun(V) -> [V,V,{V,V}] end,
    Init = 3,

    #{ key1 := [V1,V1,{V1,V1}] } = maps:update_with(key1,Fun,Init,Map),
    #{ key2 := [V2,V2,{V2,V2}] } = maps:update_with(key2,Fun,Init,Map),
    #{ "key3" := [V3,V3,{V3,V3}] } = maps:update_with("key3",Fun,Init,Map),

    #{ key3 := Init } = maps:update_with(key3,Fun,Init,Map),

    %% error case
    ?badmap(b,update_with,[[a,b],a,b]) = (catch maps:update_with([a,b],id(a),b)),
    ?badarg(update_with,[[a,b],a,#{}]) = (catch maps:update_with([a,b],id(a),#{})),
    ok.


t_get_3(Config) when is_list(Config) ->
    Map = #{ key1 => value1, key2 => value2 },
    DefaultValue = "Default value",
    value1 = maps:get(key1, Map, DefaultValue),
    value2 = maps:get(key2, Map, DefaultValue),
    DefaultValue = maps:get(key3, Map, DefaultValue),

    %% error case
    ?badmap(a,get,[[a,b],a,def]) = (catch maps:get([a,b],id(a),def)),
    ok.

t_without_2(_Config) ->
    Ki = [11,22,33,44,55,66,77,88,99],
    M0 = maps:from_list([{{k,I},{v,I}}||I<-lists:seq(1,100)]),
    M1 = maps:from_list([{{k,I},{v,I}}||I<-lists:seq(1,100) -- Ki]),
    M1 = maps:without([{k,I}||I <- Ki],M0),

    %% error case
    ?badmap(a,without,[[a,b],a]) = (catch maps:without([a,b],id(a))),
    ?badmap(a,without,[{a,b},a]) = (catch maps:without({a,b},id(a))),
    ?badmap({0,<<>>,97},without,[[],{0,<<>>,97}]) = (catch maps:without([], {0,<<>>,97})),
    ?badmap({0,<<>>,97},without,[[false, -20, -8],{0,<<>>,97}]) = (catch maps:without([false, -20, -8], {0, <<>>, 97})),
    ?badarg(without,[a,#{}]) = (catch maps:without(a,#{})),
    ok.

t_with_2(_Config) ->
    Ki = [11,22,33,44,55,66,77,88,99],
    M0 = maps:from_list([{{k,I},{v,I}}||I<-lists:seq(1,100)]),
    M1 = maps:from_list([{{k,I},{v,I}}||I<-Ki]),
    M1 = maps:with([{k,I}||I <- Ki],M0),

    %% error case
    ?badmap(a,with,[[a,b],a]) = (catch maps:with([a,b],id(a))),
    ?badmap(a,with,[{a,b},a]) = (catch maps:with({a,b},id(a))),
    ?badmap({0,<<>>,97},with,[[],{0,<<>>,97}]) = (catch maps:with([], {0,<<>>,97})),
    ?badmap({0,<<>>,97},with,[[false, -20, -8],{0,<<>>,97}]) = (catch maps:with([false, -20, -8], {0, <<>>, 97})),
    ?badarg(with,[a,#{}]) = (catch maps:with(a,#{})),
    ok.

t_filter_2(Config) when is_list(Config) ->
    M = #{a => 2, b => 3, c=> 4, "a" => 1, "b" => 2, "c" => 4},
    Pred1 = fun(K,V) -> is_atom(K) andalso (V rem 2) =:= 0 end,
    Pred2 = fun(K,V) -> is_list(K) andalso (V rem 2) =:= 0 end,
    #{a := 2,c := 4} = maps:filter(Pred1,M),
    #{"b" := 2,"c" := 4} = maps:filter(Pred2,M),
    #{a := 2,c := 4} = maps:filter(Pred1,maps:iterator(M)),
    #{"b" := 2,"c" := 4} = maps:filter(Pred2,maps:iterator(M)),
    %% error case
    ?badmap(a,filter,[_,a]) = (catch maps:filter(fun(_,_) -> ok end,id(a))),
    ?badarg(filter,[<<>>,#{}]) = (catch maps:filter(id(<<>>),#{})),
    ok.

t_fold_3(Config) when is_list(Config) ->
    Vs = lists:seq(1,200),
    M0 = maps:from_list([{{k,I},I}||I<-Vs]),
    #{ {k,1} := 1, {k,200} := 200} = M0,
    Tot0 = lists:sum(Vs),
    Tot1 = maps:fold(fun({k,_},V,A) -> A + V end, 0, M0),
    true = Tot0 =:= Tot1,
    Tot2 = maps:fold(fun({k,_},V,A) -> A + V end, 0, maps:iterator(M0)),
    true = Tot0 =:= Tot2,

    %% error case
    ?badmap(a,fold,[_,0,a]) = (catch maps:fold(fun(_,_,_) -> ok end,0,id(a))),
    ?badarg(fold,[<<>>,0,#{}]) = (catch maps:fold(id(<<>>),0,#{})),
    ok.

t_map_2(Config) when is_list(Config) ->
    Vs = lists:seq(1,200),
    M0 = maps:from_list([{{k,I},I}||I<-Vs]),
    #{ {k,1} := 1, {k,200} := 200} = M0,
    M1 = maps:map(fun({k,_},V) -> V + 42 end, M0),
    #{ {k,1} := 43, {k,200} := 242} = M1,
    M2 = maps:map(fun({k,_},V) -> V + 42 end, maps:iterator(M0)),
    #{ {k,1} := 43, {k,200} := 242} = M2,

    %% error case
    ?badmap(a,map,[_,a]) = (catch maps:map(fun(_,_) -> ok end, id(a))),
    ?badarg(map,[<<>>,#{}]) = (catch maps:map(id(<<>>),#{})),
    ok.

t_iterator_1(Config) when is_list(Config) ->

    %% Small map test
    M0 = #{ a => 1, b => 2 },
    I0 = maps:iterator(M0),
    {K1,V1,I1} = maps:next(I0),
    {K2,V2,I2} = maps:next(I1),
    none = maps:next(I2),

    KVList = lists:sort([{K1,V1},{K2,V2}]),
    KVList = lists:sort(maps:to_list(M0)),

    %% Large map test

    Vs2 = lists:seq(1,200),
    M2 = maps:from_list([{{k,I},I}||I<-Vs2]),
    KVList2 = lists:sort(iter_kv(maps:iterator(M2))),
    KVList2 = lists:sort(maps:to_list(M2)),

    %% Larger map test

    Vs3 = lists:seq(1,10000),
    M3 = maps:from_list([{{k,I},I}||I<-Vs3]),
    KVList3 = lists:sort(iter_kv(maps:iterator(M3))),
    KVList3 = lists:sort(maps:to_list(M3)),
    ok.

iter_kv(I) ->
    case maps:next(I) of
        none ->
            [];
        {K,V,NI} ->
            [{K,V} | iter_kv(NI)]
    end.

t_size_1(Config) when is_list(Config) ->
      0 = maps:size(#{}),
     10 = maps:size(maps:from_list([{{"k",I},I}||I<-lists:seq(1,10)])),
     20 = maps:size(maps:from_list([{{"k",I},I}||I<-lists:seq(1,20)])),
     30 = maps:size(maps:from_list([{{"k",I},I}||I<-lists:seq(1,30)])),
     40 = maps:size(maps:from_list([{{"k",I},I}||I<-lists:seq(1,40)])),
     50 = maps:size(maps:from_list([{{"k",I},I}||I<-lists:seq(1,50)])),
     60 = maps:size(maps:from_list([{{"k",I},I}||I<-lists:seq(1,60)])),
    600 = maps:size(maps:from_list([{{"k",I},I}||I<-lists:seq(1,600)])),

    %% error case
    ?badmap(a,size,[a]) = (catch maps:size(id(a))),
    ?badmap(<<>>,size,[<<>>]) = (catch maps:size(id(<<>>))),
    ok.

id(I) -> I.
