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
%% @copyright 1999-2002 Richard Carlsson
%% @author Richard Carlsson <carlsson.richard@gmail.com>
%% @doc Core Erlang abstract syntax trees.
%%
%% <p> This module defines an abstract data type for representing Core
%% Erlang source code as syntax trees.</p>
%%
%% <p>A recommended starting point for the first-time user is the
%% documentation of the function <a
%% href="#type-1"><code>type/1</code></a>.</p>
%%
%% <h3><b>NOTES:</b></h3>
%%
%% <p>This module deals with the composition and decomposition of
%% <em>syntactic</em> entities (as opposed to semantic ones); its
%% purpose is to hide all direct references to the data structures
%% used to represent these entities. With few exceptions, the
%% functions in this module perform no semantic interpretation of
%% their inputs, and in general, the user is assumed to pass
%% type-correct arguments - if this is not done, the effects are not
%% defined.</p>
%%
%% <p>Currently, the internal data structure used is the same as
%% the record-based data structures used traditionally in the Beam
%% compiler.</p>
%% 
%% <p>The internal representations of abstract syntax trees are
%% subject to change without notice, and should not be documented
%% outside this module. Furthermore, we do not give any guarantees on
%% how an abstract syntax tree may or may not be represented, <em>with
%% the following exceptions</em>: no syntax tree is represented by a
%% single atom, such as <code>none</code>, by a list constructor
%% <code>[X | Y]</code>, or by the empty list <code>[]</code>. This
%% can be relied on when writing functions that operate on syntax
%% trees.</p>
%%
%% @type cerl(). An abstract Core Erlang syntax tree.
%%
%% <p>Every abstract syntax tree has a <em>type</em>, given by the
%% function <a href="#type-1"><code>type/1</code></a>.  In addition,
%% each syntax tree has a list of <em>user annotations</em> (cf.  <a
%% href="#get_ann-1"><code>get_ann/1</code></a>), which are included
%% in the Core Erlang syntax.</p>

-module(cerl).

-export([abstract/1, add_ann/2, alias_pat/1, alias_var/1,
	 ann_abstract/2, ann_c_alias/3, ann_c_apply/3, ann_c_atom/2,
	 ann_c_call/4, ann_c_case/3, ann_c_catch/2, ann_c_char/2,
	 ann_c_clause/3, ann_c_clause/4, ann_c_cons/3, ann_c_float/2,
	 ann_c_fname/3, ann_c_fun/3, ann_c_int/2, ann_c_let/4,
	 ann_c_letrec/3, ann_c_module/4, ann_c_module/5, ann_c_nil/1,
	 ann_c_cons_skel/3, ann_c_tuple_skel/2, ann_c_primop/3,
	 ann_c_receive/2, ann_c_receive/4, ann_c_seq/3, ann_c_string/2,
	 ann_c_try/6, ann_c_tuple/2, ann_c_values/2, ann_c_var/2,
	 ann_make_data/3, ann_make_list/2, ann_make_list/3,
	 ann_make_data_skel/3, ann_make_tree/3, apply_args/1,
	 apply_arity/1, apply_op/1, atom_lit/1, atom_name/1, atom_val/1,
	 c_alias/2, c_apply/2, c_atom/1, c_call/3, c_case/2, c_catch/1,
	 c_char/1, c_clause/2, c_clause/3, c_cons/2, c_float/1,
	 c_fname/2, c_fun/2, c_int/1, c_let/3, c_letrec/2, c_module/3,
	 c_module/4, c_nil/0, c_cons_skel/2, c_tuple_skel/1, c_primop/2,
	 c_receive/1, c_receive/3, c_seq/2, c_string/1, c_try/5,
	 c_tuple/1, c_values/1, c_var/1, call_args/1, call_arity/1,
	 call_module/1, call_name/1, case_arg/1, case_arity/1,
	 case_clauses/1, catch_body/1, char_lit/1, char_val/1,
	 clause_arity/1, clause_body/1, clause_guard/1, clause_pats/1,
	 clause_vars/1, concrete/1, cons_hd/1, cons_tl/1, copy_ann/2,
	 data_arity/1, data_es/1, data_type/1, float_lit/1, float_val/1,
	 fname_arity/1, fname_id/1, fold_literal/1, from_records/1,
	 fun_arity/1, fun_body/1, fun_vars/1, get_ann/1, int_lit/1,
	 int_val/1, is_c_alias/1, is_c_apply/1, is_c_atom/1,
	 is_c_call/1, is_c_case/1, is_c_catch/1, is_c_char/1,
	 is_c_clause/1, is_c_cons/1, is_c_float/1, is_c_fname/1,
	 is_c_fun/1, is_c_int/1, is_c_let/1, is_c_letrec/1, is_c_list/1,
	 is_c_module/1, is_c_nil/1, is_c_primop/1, is_c_receive/1,
	 is_c_seq/1, is_c_string/1, is_c_try/1, is_c_tuple/1,
	 is_c_values/1, is_c_var/1, is_data/1, is_leaf/1, is_literal/1,
	 is_literal_term/1, is_print_char/1, is_print_string/1,
	 let_arg/1, let_arity/1, let_body/1, let_vars/1, letrec_body/1,
	 letrec_defs/1, letrec_vars/1, list_elements/1, list_length/1,
	 make_data/2, make_list/1, make_list/2, make_data_skel/2,
	 make_tree/2, meta/1, module_attrs/1, module_defs/1,
	 module_exports/1, module_name/1, module_vars/1,
	 pat_list_vars/1, pat_vars/1, primop_args/1, primop_arity/1,
	 primop_name/1, receive_action/1, receive_clauses/1,
	 receive_timeout/1, seq_arg/1, seq_body/1, set_ann/2,
	 string_lit/1, string_val/1, subtrees/1, to_records/1,
	 try_arg/1, try_body/1, try_vars/1, try_evars/1, try_handler/1,
	 tuple_arity/1, tuple_es/1, type/1, unfold_literal/1,
	 update_c_alias/3, update_c_apply/3, update_c_call/4,
	 update_c_case/3, update_c_catch/2, update_c_clause/4,
	 update_c_cons/3, update_c_cons_skel/3, update_c_fname/2,
	 update_c_fname/3, update_c_fun/3, update_c_let/4,
	 update_c_letrec/3, update_c_module/5, update_c_primop/3,
	 update_c_receive/4, update_c_seq/3, update_c_try/6,
	 update_c_tuple/2, update_c_tuple_skel/2, update_c_values/2,
	 update_c_var/2, update_data/3, update_list/2, update_list/3,
	 update_data_skel/3, update_tree/2, update_tree/3,
	 values_arity/1, values_es/1, var_name/1, c_binary/1,
	 update_c_binary/2, ann_c_binary/2, is_c_binary/1,
	 binary_segments/1, c_bitstr/3, c_bitstr/4, c_bitstr/5,
	 update_c_bitstr/5, update_c_bitstr/6, ann_c_bitstr/5,
	 ann_c_bitstr/6, is_c_bitstr/1, bitstr_val/1, bitstr_size/1,
	 bitstr_bitsize/1, bitstr_unit/1, bitstr_type/1,
	 bitstr_flags/1,

	 %% keep map exports here for now
	 c_map_pattern/1,
	 is_c_map/1,
	 is_c_map_pattern/1,
	 map_es/1,
	 map_arg/1,
	 update_c_map/3,
	 c_map/1, is_c_map_empty/1,
	 ann_c_map/2, ann_c_map/3,
	 ann_c_map_pattern/2,
	 map_pair_op/1,map_pair_key/1,map_pair_val/1,
	 update_c_map_pair/4,
	 c_map_pair/2, c_map_pair_exact/2,
	 ann_c_map_pair/4
     ]).

-export_type([c_binary/0, c_bitstr/0, c_call/0, c_clause/0, c_cons/0, c_fun/0,
	      c_let/0, c_literal/0, c_map/0, c_map_pair/0,
	      c_module/0, c_tuple/0,
	      c_values/0, c_var/0, cerl/0, var_name/0]).

-include("core_parse.hrl").

-type c_alias()   :: #c_alias{}.
-type c_apply()   :: #c_apply{}.
-type c_binary()  :: #c_binary{}.
-type c_bitstr()  :: #c_bitstr{}.
-type c_call()    :: #c_call{}.
-type c_case()    :: #c_case{}.
-type c_catch()   :: #c_catch{}.
-type c_clause()  :: #c_clause{}.
-type c_cons()    :: #c_cons{}.
-type c_fun()     :: #c_fun{}.
-type c_let()     :: #c_let{}.
-type c_letrec()  :: #c_letrec{}.
-type c_literal() :: #c_literal{}.
-type c_map()     :: #c_map{}.
-type c_map_pair() :: #c_map_pair{}.
-type c_module()  :: #c_module{}.
-type c_primop()  :: #c_primop{}.
-type c_receive() :: #c_receive{}.
-type c_seq()     :: #c_seq{}.
-type c_try()     :: #c_try{}.
-type c_tuple()   :: #c_tuple{}.
-type c_values()  :: #c_values{}.
-type c_var()     :: #c_var{}.

-type cerl() :: c_alias()  | c_apply()  | c_binary()  | c_bitstr()
              | c_call()   | c_case()   | c_catch()   | c_clause()  | c_cons()
              | c_fun()    | c_let()    | c_letrec()  | c_literal()
	      | c_map()    | c_map_pair()
	      | c_module() | c_primop() | c_receive() | c_seq()
              | c_try()    | c_tuple()  | c_values()  | c_var().

-type var_name() :: integer() | atom() | {atom(), integer()}.

%% =====================================================================
%% Representation (general)
%%
%% All nodes are represented by tuples of arity 2 or (generally)
%% greater, whose first element is an atom which uniquely identifies the
%% type of the node, and whose second element is a (proper) list of
%% annotation terms associated with the node - this is by default empty.
%%
%% For most node constructor functions, there are analogous functions
%% named 'ann_...', taking one extra argument 'As' (always the first
%% argument), specifying an annotation list at node creation time.
%% Similarly, there are also functions named 'update_...', taking one
%% extra argument 'Old', specifying a node from which all fields not
%% explicitly given as arguments should be copied (generally, this is
%% the annotation field only).
%% =====================================================================

%% @spec type(Node::cerl()) -> atom()
%%
%% @doc Returns the type tag of <code>Node</code>. Current node types
%% are:
%%	    
%% <p><center><table border="1">
%%  <tr>
%%    <td>alias</td>
%%    <td>apply</td>
%%    <td>binary</td>
%%    <td>bitstr</td>
%%    <td>call</td>
%%    <td>case</td>
%%    <td>catch</td>
%%    <td>clause</td>
%%  </tr><tr>
%%    <td>cons</td>
%%    <td>fun</td>
%%    <td>let</td>
%%    <td>letrec</td>
%%    <td>literal</td>
%%    <td>map</td>
%%    <td>map_pair</td>
%%    <td>module</td>
%%  </tr><tr>
%%    <td>primop</td>
%%    <td>receive</td>
%%    <td>seq</td>
%%    <td>try</td>
%%    <td>tuple</td>
%%    <td>values</td>
%%    <td>var</td>
%%  </tr>
%% </table></center></p>
%%
%% <p>Note: The name of the primary constructor function for a node
%% type is always the name of the type itself, prefixed by
%% "<code>c_</code>"; recognizer predicates are correspondingly
%% prefixed by "<code>is_c_</code>". Furthermore, to simplify
%% preservation of annotations (cf. <code>get_ann/1</code>), there are
%% analogous constructor functions prefixed by "<code>ann_c_</code>"
%% and "<code>update_c_</code>", for setting the annotation list of
%% the new node to either a specific value or to the annotations of an
%% existing node, respectively.</p>
%%
%% @see abstract/1
%% @see c_alias/2
%% @see c_apply/2
%% @see c_binary/1
%% @see c_bitstr/5
%% @see c_call/3
%% @see c_case/2
%% @see c_catch/1
%% @see c_clause/3
%% @see c_cons/2
%% @see c_fun/2
%% @see c_let/3
%% @see c_letrec/2
%% @see c_module/3
%% @see c_primop/2
%% @see c_receive/1
%% @see c_seq/2
%% @see c_try/5
%% @see c_tuple/1
%% @see c_values/1
%% @see c_var/1
%% @see get_ann/1
%% @see to_records/1
%% @see from_records/1
%% @see data_type/1
%% @see subtrees/1
%% @see meta/1

-type ctype() :: 'alias'   | 'apply'  | 'binary' | 'bitstr' | 'call' | 'case'
               | 'catch'   | 'clause' | 'cons'   | 'fun'    | 'let'  | 'letrec'
               | 'literal' | 'map'  | 'map_pair' | 'module' | 'primop'
               | 'receive' | 'seq'    | 'try'    | 'tuple'  | 'values' | 'var'.

-spec type(cerl()) -> ctype().

type(#c_alias{}) -> alias;
type(#c_apply{}) -> apply;
type(#c_binary{}) -> binary;
type(#c_bitstr{}) -> bitstr;
type(#c_call{}) -> call;
type(#c_case{}) -> 'case';
type(#c_catch{}) -> 'catch';
type(#c_clause{}) -> clause;
type(#c_cons{}) -> cons;
type(#c_fun{}) -> 'fun';
type(#c_let{}) -> 'let';
type(#c_letrec{}) -> letrec;
type(#c_literal{}) -> literal;
type(#c_map{}) -> map;
type(#c_map_pair{}) -> map_pair;
type(#c_module{}) -> module;
type(#c_primop{}) -> primop;
type(#c_receive{}) -> 'receive';
type(#c_seq{}) -> seq;
type(#c_try{}) -> 'try';
type(#c_tuple{}) -> tuple;
type(#c_values{}) -> values;
type(#c_var{}) -> var.


%% @spec is_leaf(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is a leaf node,
%% otherwise <code>false</code>. The current leaf node types are
%% <code>literal</code> and <code>var</code>.
%%
%% <p>Note: all literals (cf. <code>is_literal/1</code>) are leaf
%% nodes, even if they represent structured (constant) values such as
%% <code>{foo, [bar, baz]}</code>. Also note that variables are leaf
%% nodes but not literals.</p>
%%
%% @see type/1
%% @see is_literal/1

-spec is_leaf(cerl()) -> boolean().

is_leaf(Node) ->
    case type(Node) of
	literal -> true;
	var -> true;
	_ -> false
    end.


%% @spec get_ann(cerl()) -> [term()]
%%
%% @doc Returns the list of user annotations associated with a syntax
%% tree node. For a newly created node, this is the empty list. The
%% annotations may be any terms.
%%
%% @see set_ann/2

-spec get_ann(cerl()) -> [term()].

get_ann(Node) ->
    element(2, Node).


%% @spec set_ann(Node::cerl(), Annotations::[term()]) -> cerl()
%%
%% @doc Sets the list of user annotations of <code>Node</code> to
%% <code>Annotations</code>.
%%
%% @see get_ann/1
%% @see add_ann/2
%% @see copy_ann/2

-spec set_ann(cerl(), [term()]) -> cerl().

set_ann(Node, List) ->
    setelement(2, Node, List).


%% @spec add_ann(Annotations::[term()], Node::cerl()) -> cerl()
%%
%% @doc Appends <code>Annotations</code> to the list of user
%% annotations of <code>Node</code>.
%%
%% <p>Note: this is equivalent to <code>set_ann(Node, Annotations ++
%% get_ann(Node))</code>, but potentially more efficient.</p>
%%
%% @see get_ann/1
%% @see set_ann/2

-spec add_ann([term()], cerl()) -> cerl().

add_ann(Terms, Node) ->
    set_ann(Node, Terms ++ get_ann(Node)).


%% @spec copy_ann(Source::cerl(), Target::cerl()) -> cerl()
%%
%% @doc Copies the list of user annotations from <code>Source</code>
%% to <code>Target</code>.
%%
%% <p>Note: this is equivalent to <code>set_ann(Target,
%% get_ann(Source))</code>, but potentially more efficient.</p>
%%
%% @see get_ann/1
%% @see set_ann/2

-spec copy_ann(cerl(), cerl()) -> cerl().

copy_ann(Source, Target) ->
    set_ann(Target, get_ann(Source)).


%% @spec abstract(Term::term()) -> cerl()
%%
%% @doc Creates a syntax tree corresponding to an Erlang term.
%% <code>Term</code> must be a literal term, i.e., one that can be
%% represented as a source code literal. Thus, it may not contain a
%% process identifier, port, reference, binary or function value as a
%% subterm.
%%
%% <p>Note: This is a constant time operation.</p>
%%
%% @see ann_abstract/2
%% @see concrete/1
%% @see is_literal/1
%% @see is_literal_term/1

-spec abstract(term()) -> c_literal().

abstract(T) ->
    #c_literal{val = T}.


%% @spec ann_abstract(Annotations::[term()], Term::term()) -> cerl()
%% @see abstract/1

-spec ann_abstract([term()], term()) -> c_literal().

ann_abstract(As, T) ->
    #c_literal{val = T, anno = As}.


%% @spec is_literal_term(Term::term()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Term</code> can be
%% represented as a literal, otherwise <code>false</code>. This
%% function takes time proportional to the size of <code>Term</code>.
%%
%% @see abstract/1

-spec is_literal_term(term()) -> boolean().

is_literal_term(T) when is_integer(T) -> true;
is_literal_term(T) when is_float(T) -> true;
is_literal_term(T) when is_atom(T) -> true;
is_literal_term([]) -> true;
is_literal_term([H | T]) ->
    is_literal_term(H) andalso is_literal_term(T);
is_literal_term(T) when is_tuple(T) ->
    is_literal_term_list(tuple_to_list(T));
is_literal_term(B) when is_bitstring(B) -> true;
is_literal_term(M) when is_map(M) ->
    is_literal_term_list(maps:to_list(M));
is_literal_term(F) when is_function(F) ->
    erlang:fun_info(F, type) =:= {type,external};
is_literal_term(_) ->
    false.

-spec is_literal_term_list([term()]) -> boolean().

is_literal_term_list([T | Ts]) ->
    case is_literal_term(T) of
	true ->
	    is_literal_term_list(Ts);
	false ->
	    false
    end;
is_literal_term_list([]) ->
    true.


%% @spec concrete(Node::cerl()) -> term()
%%
%% @doc Returns the Erlang term represented by a syntax tree.  An
%% exception is thrown if <code>Node</code> does not represent a
%% literal term.
%%
%% <p>Note: This is a constant time operation.</p>
%%
%% @see abstract/1
%% @see is_literal/1

%% Because the normal tuple and list constructor operations always
%% return a literal if the arguments are literals, 'concrete' and
%% 'is_literal' never need to traverse the structure.

-spec concrete(c_literal()) -> term().

concrete(#c_literal{val = V}) ->
    V.


%% @spec is_literal(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> represents a
%% literal term, otherwise <code>false</code>. This function returns
%% <code>true</code> if and only if the value of
%% <code>concrete(Node)</code> is defined.
%%
%% <p>Note: This is a constant time operation.</p>
%%
%% @see abstract/1
%% @see concrete/1
%% @see fold_literal/1

-spec is_literal(cerl()) -> boolean().

is_literal(#c_literal{}) ->
    true;
is_literal(_) ->
    false.


%% @spec fold_literal(Node::cerl()) -> cerl()
%%
%% @doc Assures that literals have a compact representation. This is
%% occasionally useful if <code>c_cons_skel/2</code>,
%% <code>c_tuple_skel/1</code> or <code>unfold_literal/1</code> were
%% used in the construction of <code>Node</code>, and you want to revert
%% to the normal "folded" representation of literals. If
%% <code>Node</code> represents a tuple or list constructor, its
%% elements are rewritten recursively, and the node is reconstructed
%% using <code>c_cons/2</code> or <code>c_tuple/1</code>, respectively;
%% otherwise, <code>Node</code> is not changed.
%%
%% @see is_literal/1
%% @see c_cons_skel/2
%% @see c_tuple_skel/1
%% @see c_cons/2
%% @see c_tuple/1
%% @see unfold_literal/1

-spec fold_literal(cerl()) -> cerl().

fold_literal(Node) ->
    case type(Node) of
	tuple ->
	    update_c_tuple(Node, fold_literal_list(tuple_es(Node)));
	cons ->
	    update_c_cons(Node, fold_literal(cons_hd(Node)),
			  fold_literal(cons_tl(Node)));
	_ ->
	    Node    
    end.

fold_literal_list([E | Es]) ->
    [fold_literal(E) | fold_literal_list(Es)];
fold_literal_list([]) ->
    [].


%% @spec unfold_literal(Node::cerl()) -> cerl()
%%
%% @doc Assures that literals have a fully expanded representation. If
%% <code>Node</code> represents a literal tuple or list constructor, its
%% elements are rewritten recursively, and the node is reconstructed
%% using <code>c_cons_skel/2</code> or <code>c_tuple_skel/1</code>,
%% respectively; otherwise, <code>Node</code> is not changed. The {@link
%% fold_literal/1} can be used to revert to the normal compact
%% representation.
%%
%% @see is_literal/1
%% @see c_cons_skel/2
%% @see c_tuple_skel/1
%% @see c_cons/2
%% @see c_tuple/1
%% @see fold_literal/1

-spec unfold_literal(cerl()) -> cerl().

unfold_literal(Node) ->
    case type(Node) of
	literal ->
	    copy_ann(Node, unfold_concrete(concrete(Node)));
	_ ->
	    Node
    end.

unfold_concrete(Val) ->
    case Val of
	_ when is_tuple(Val) ->
	    c_tuple_skel(unfold_concrete_list(tuple_to_list(Val)));
	[H|T] ->
	    c_cons_skel(unfold_concrete(H), unfold_concrete(T));
	_ ->
	    abstract(Val)
    end.

unfold_concrete_list([E | Es]) ->
    [unfold_concrete(E) | unfold_concrete_list(Es)];
unfold_concrete_list([]) ->
    [].


%% ---------------------------------------------------------------------

%% @spec c_module(Name::cerl(), Exports, Definitions) -> cerl()
%%
%%     Exports = [cerl()]
%%     Definitions = [{cerl(), cerl()}]
%%
%% @equiv c_module(Name, Exports, [], Definitions)

-spec c_module(cerl(), [cerl()], [{cerl(), cerl()}]) -> c_module().

c_module(Name, Exports, Es) ->
    #c_module{name = Name, exports = Exports, attrs = [], defs = Es}.


%% @spec c_module(Name::cerl(), Exports, Attributes, Definitions) ->
%%           cerl()
%%
%%     Exports = [cerl()]
%%     Attributes = [{cerl(), cerl()}]
%%     Definitions = [{cerl(), cerl()}]
%%
%% @doc Creates an abstract module definition. The result represents
%% <pre>
%%   module <em>Name</em> [<em>E1</em>, ..., <em>Ek</em>]
%%     attributes [<em>K1</em> = <em>T1</em>, ...,
%%                 <em>Km</em> = <em>Tm</em>]
%%     <em>V1</em> = <em>F1</em>
%%     ...
%%     <em>Vn</em> = <em>Fn</em>
%%   end</pre>
%%
%% if <code>Exports</code> = <code>[E1, ..., Ek]</code>,
%% <code>Attributes</code> = <code>[{K1, T1}, ..., {Km, Tm}]</code>,
%% and <code>Definitions</code> = <code>[{V1, F1}, ..., {Vn,
%% Fn}]</code>.
%%
%% <p><code>Name</code> and all the <code>Ki</code> must be atom
%% literals, and all the <code>Ti</code> must be constant literals. All
%% the <code>Vi</code> and <code>Ei</code> must have type
%% <code>var</code> and represent function names. All the
%% <code>Fi</code> must have type <code>'fun'</code>.</p>
%%
%% @see c_module/3
%% @see module_name/1
%% @see module_exports/1
%% @see module_attrs/1
%% @see module_defs/1
%% @see module_vars/1
%% @see ann_c_module/4
%% @see ann_c_module/5
%% @see update_c_module/5
%% @see c_atom/1
%% @see c_var/1
%% @see c_fun/2
%% @see is_literal/1

-spec c_module(cerl(), [cerl()], [{cerl(), cerl()}], [{cerl(), cerl()}]) ->
        c_module().

c_module(Name, Exports, Attrs, Es) ->
    #c_module{name = Name, exports = Exports, attrs = Attrs, defs = Es}.


%% @spec ann_c_module(As::[term()], Name::cerl(), Exports,
%%                    Definitions) -> cerl()
%%
%%     Exports = [cerl()]
%%     Definitions = [{cerl(), cerl()}]
%%
%% @see c_module/3
%% @see ann_c_module/5

-spec ann_c_module([term()], cerl(), [cerl()], [{cerl(), cerl()}]) ->
        c_module().

ann_c_module(As, Name, Exports, Es) ->
    #c_module{name = Name, exports = Exports, attrs = [], defs = Es,
	      anno = As}.


%% @spec ann_c_module(As::[term()], Name::cerl(), Exports,
%%                    Attributes, Definitions) -> cerl()
%%
%%     Exports = [cerl()]
%%     Attributes = [{cerl(), cerl()}]
%%     Definitions = [{cerl(), cerl()}]
%%
%% @see c_module/4
%% @see ann_c_module/4

-spec ann_c_module([term()], cerl(), [cerl()],
		   [{cerl(), cerl()}], [{cerl(), cerl()}]) -> c_module().

ann_c_module(As, Name, Exports, Attrs, Es) ->
    #c_module{name = Name, exports = Exports, attrs = Attrs, defs = Es,
	      anno = As}.


%% @spec update_c_module(Old::cerl(), Name::cerl(), Exports,
%%                       Attributes, Definitions) -> cerl()
%%
%%     Exports = [cerl()]
%%     Attributes = [{cerl(), cerl()}]
%%     Definitions = [{cerl(), cerl()}]
%%
%% @see c_module/4

-spec update_c_module(c_module(), cerl(), [cerl()],
		      [{cerl(), cerl()}], [{cerl(), cerl()}]) -> c_module().

update_c_module(Node, Name, Exports, Attrs, Es) ->
    #c_module{name = Name, exports = Exports, attrs = Attrs, defs = Es,
	      anno = get_ann(Node)}.


%% @spec is_c_module(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% module definition, otherwise <code>false</code>.
%%
%% @see type/1

-spec is_c_module(cerl()) -> boolean().

is_c_module(#c_module{}) ->
    true;
is_c_module(_) ->
    false.


%% @spec module_name(Node::cerl()) -> cerl()
%%
%% @doc Returns the name subtree of an abstract module definition.
%%
%% @see c_module/4

-spec module_name(c_module()) -> cerl().

module_name(Node) ->
    Node#c_module.name.


%% @spec module_exports(Node::cerl()) -> [cerl()]
%%
%% @doc Returns the list of exports subtrees of an abstract module
%% definition.
%%
%% @see c_module/4

-spec module_exports(c_module()) -> [cerl()].

module_exports(Node) ->
    Node#c_module.exports.


%% @spec module_attrs(Node::cerl()) -> [{cerl(), cerl()}]
%%
%% @doc Returns the list of pairs of attribute key/value subtrees of
%% an abstract module definition.
%%
%% @see c_module/4

-spec module_attrs(c_module()) -> [{cerl(), cerl()}].

module_attrs(Node) ->
    Node#c_module.attrs.


%% @spec module_defs(Node::cerl()) -> [{cerl(), cerl()}]
%%
%% @doc Returns the list of function definitions of an abstract module
%% definition.
%%
%% @see c_module/4

-spec module_defs(c_module()) -> [{cerl(), cerl()}].

module_defs(Node) ->
    Node#c_module.defs.


%% @spec module_vars(Node::cerl()) -> [cerl()]
%%
%% @doc Returns the list of left-hand side function variable subtrees
%% of an abstract module definition.
%%
%% @see c_module/4

-spec module_vars(c_module()) -> [cerl()].

module_vars(Node) ->
    [F || {F, _} <- module_defs(Node)].


%% ---------------------------------------------------------------------

%% @spec c_int(Value::integer()) -> cerl()
%%
%% @doc Creates an abstract integer literal. The lexical
%% representation is the canonical decimal numeral of
%% <code>Value</code>.
%%
%% @see ann_c_int/2
%% @see is_c_int/1
%% @see int_val/1
%% @see int_lit/1
%% @see c_char/1

-spec c_int(integer()) -> c_literal().

c_int(Value) ->
    #c_literal{val = Value}.


%% @spec ann_c_int(As::[term()], Value::integer()) -> cerl()
%% @see c_int/1

-spec ann_c_int([term()], integer()) -> c_literal().

ann_c_int(As, Value) ->
    #c_literal{val = Value, anno = As}.


%% @spec is_c_int(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> represents an
%% integer literal, otherwise <code>false</code>.
%% @see c_int/1

-spec is_c_int(cerl()) -> boolean().

is_c_int(#c_literal{val = V}) when is_integer(V) ->
    true;
is_c_int(_) ->
    false.


%% @spec int_val(cerl()) -> integer()
%%
%% @doc Returns the value represented by an integer literal node.
%% @see c_int/1

-spec int_val(c_literal()) -> integer().

int_val(Node) ->
    Node#c_literal.val.


%% @spec int_lit(cerl()) -> string()
%%
%% @doc Returns the numeral string represented by an integer literal
%% node.
%% @see c_int/1

-spec int_lit(c_literal()) -> string().

int_lit(Node) ->
    integer_to_list(int_val(Node)).


%% ---------------------------------------------------------------------

%% @spec c_float(Value::float()) -> cerl()
%%
%% @doc Creates an abstract floating-point literal.  The lexical
%% representation is the decimal floating-point numeral of
%% <code>Value</code>.
%%
%% @see ann_c_float/2
%% @see is_c_float/1
%% @see float_val/1
%% @see float_lit/1

%% Note that not all floating-point numerals can be represented with
%% full precision.

-spec c_float(float()) -> c_literal().

c_float(Value) ->
    #c_literal{val = Value}.


%% @spec ann_c_float(As::[term()], Value::float()) -> cerl()
%% @see c_float/1

-spec ann_c_float([term()], float()) -> c_literal().

ann_c_float(As, Value) ->
    #c_literal{val = Value, anno = As}.


%% @spec is_c_float(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> represents a
%% floating-point literal, otherwise <code>false</code>.
%% @see c_float/1

-spec is_c_float(cerl()) -> boolean().

is_c_float(#c_literal{val = V}) when is_float(V) ->
    true;
is_c_float(_) ->
    false.


%% @spec float_val(cerl()) -> float()
%%
%% @doc Returns the value represented by a floating-point literal
%% node.
%% @see c_float/1

-spec float_val(c_literal()) -> float().

float_val(Node) ->
    Node#c_literal.val.


%% @spec float_lit(cerl()) -> string()
%%
%% @doc Returns the numeral string represented by a floating-point
%% literal node.
%% @see c_float/1

-spec float_lit(c_literal()) -> string().

float_lit(Node) ->
    float_to_list(float_val(Node)).


%% ---------------------------------------------------------------------

%% @spec c_atom(Name) -> cerl()
%%	    Name = atom() | string()
%%
%% @doc Creates an abstract atom literal.  The print name of the atom
%% is the character sequence represented by <code>Name</code>.
%%
%% <p>Note: passing a string as argument to this function causes a
%% corresponding atom to be created for the internal representation.</p>
%%
%% @see ann_c_atom/2
%% @see is_c_atom/1
%% @see atom_val/1
%% @see atom_name/1
%% @see atom_lit/1

-spec c_atom(atom() | string()) -> c_literal().

c_atom(Name) when is_atom(Name) ->
    #c_literal{val = Name};
c_atom(Name) ->
    #c_literal{val = list_to_atom(Name)}.


%% @spec ann_c_atom(As::[term()], Name) -> cerl()
%%	    Name = atom() | string()
%% @see c_atom/1

-spec ann_c_atom([term()], atom() | string()) -> c_literal().

ann_c_atom(As, Name) when is_atom(Name) ->
    #c_literal{val = Name, anno = As};
ann_c_atom(As, Name) ->
    #c_literal{val = list_to_atom(Name), anno = As}.


%% @spec is_c_atom(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> represents an
%% atom literal, otherwise <code>false</code>.
%%
%% @see c_atom/1

-spec is_c_atom(cerl()) -> boolean().

is_c_atom(#c_literal{val = V}) when is_atom(V) ->
    true;
is_c_atom(_) ->
    false.

%% @spec atom_val(cerl()) -> atom()
%%
%% @doc Returns the value represented by an abstract atom.
%%
%% @see c_atom/1

-spec atom_val(c_literal()) -> atom().

atom_val(Node) ->
    Node#c_literal.val.


%% @spec atom_name(cerl()) -> string()
%%
%% @doc Returns the printname of an abstract atom.
%%
%% @see c_atom/1

-spec atom_name(c_literal()) -> string().

atom_name(Node) ->
    atom_to_list(atom_val(Node)).


%% @spec atom_lit(cerl()) -> string()
%%
%% @doc Returns the literal string represented by an abstract
%% atom. This always includes surrounding single-quote characters.
%%
%% <p>Note that an abstract atom may have several literal
%% representations, and that the representation yielded by this
%% function is not fixed; e.g.,
%% <code>atom_lit(c_atom("a\012b"))</code> could yield the string
%% <code>"\'a\\nb\'"</code>.</p>
%%
%% @see c_atom/1

%% TODO: replace the use of the unofficial 'write_string/2'.

-spec atom_lit(cerl()) -> nonempty_string().

atom_lit(Node) ->
    io_lib:write_string(atom_name(Node), $'). %' stupid Emacs.


%% ---------------------------------------------------------------------

%% @spec c_char(Value) -> cerl()
%%
%%    Value = char() | integer()
%%
%% @doc Creates an abstract character literal. If the local
%% implementation of Erlang defines <code>char()</code> as a subset of
%% <code>integer()</code>, this function is equivalent to
%% <code>c_int/1</code>. Otherwise, if the given value is an integer,
%% it will be converted to the character with the corresponding
%% code. The lexical representation of a character is
%% "<code>$<em>Char</em></code>", where <code>Char</code> is a single
%% printing character or an escape sequence.
%%
%% @see c_int/1
%% @see c_string/1
%% @see ann_c_char/2
%% @see is_c_char/1
%% @see char_val/1
%% @see char_lit/1
%% @see is_print_char/1

-spec c_char(non_neg_integer()) -> c_literal().

c_char(Value) when is_integer(Value), Value >= 0 ->
    #c_literal{val = Value}.


%% @spec ann_c_char(As::[term()], Value::char()) -> cerl()
%% @see c_char/1

-spec ann_c_char([term()], char()) -> c_literal().

ann_c_char(As, Value) ->
    #c_literal{val = Value, anno = As}.


%% @spec is_c_char(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> may represent a
%% character literal, otherwise <code>false</code>.
%%
%% <p>If the local implementation of Erlang defines
%% <code>char()</code> as a subset of <code>integer()</code>, then
%% <code>is_c_int(<em>Node</em>)</code> will also yield
%% <code>true</code>.</p>
%%
%% @see c_char/1
%% @see is_print_char/1

-spec is_c_char(c_literal()) -> boolean().

is_c_char(#c_literal{val = V}) when is_integer(V), V >= 0 ->
    is_char_value(V);
is_c_char(_) ->
    false.


%% @spec is_print_char(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> may represent a
%% "printing" character, otherwise <code>false</code>. (Cf.
%% <code>is_c_char/1</code>.)  A "printing" character has either a
%% given graphical representation, or a "named" escape sequence such
%% as "<code>\n</code>". Currently, only ISO 8859-1 (Latin-1)
%% character values are recognized.
%%
%% @see c_char/1
%% @see is_c_char/1

-spec is_print_char(cerl()) -> boolean().

is_print_char(#c_literal{val = V}) when is_integer(V), V >= 0 ->
    is_print_char_value(V);
is_print_char(_) ->
    false.


%% @spec char_val(cerl()) -> char()
%%
%% @doc Returns the value represented by an abstract character literal.
%%
%% @see c_char/1

-spec char_val(c_literal()) -> char().

char_val(Node) ->
    Node#c_literal.val.


%% @spec char_lit(cerl()) -> string()
%%
%% @doc Returns the literal string represented by an abstract
%% character. This includes a leading <code>$</code>
%% character. Currently, all characters that are not in the set of ISO
%% 8859-1 (Latin-1) "printing" characters will be escaped.
%%
%% @see c_char/1

-spec char_lit(c_literal()) -> nonempty_string().

char_lit(Node) ->
    io_lib:write_char(char_val(Node)).


%% ---------------------------------------------------------------------

%% @spec c_string(Value::string()) -> cerl()
%%
%% @doc Creates an abstract string literal. Equivalent to creating an
%% abstract list of the corresponding character literals
%% (cf. <code>is_c_string/1</code>), but is typically more
%% efficient. The lexical representation of a string is
%% "<code>"<em>Chars</em>"</code>", where <code>Chars</code> is a
%% sequence of printing characters or spaces.
%%
%% @see c_char/1
%% @see ann_c_string/2
%% @see is_c_string/1
%% @see string_val/1
%% @see string_lit/1
%% @see is_print_string/1

-spec c_string(string()) -> c_literal().

c_string(Value) ->
    #c_literal{val = Value}.


%% @spec ann_c_string(As::[term()], Value::string()) -> cerl()
%% @see c_string/1

-spec ann_c_string([term()], string()) -> c_literal().

ann_c_string(As, Value) ->
    #c_literal{val = Value, anno = As}.


%% @spec is_c_string(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> may represent a
%% string literal, otherwise <code>false</code>. Strings are defined
%% as lists of characters; see <code>is_c_char/1</code> for details.
%%
%% @see c_string/1
%% @see is_c_char/1
%% @see is_print_string/1

-spec is_c_string(cerl()) -> boolean().

is_c_string(#c_literal{val = V}) ->
    is_char_list(V);
is_c_string(_) ->
    false.


%% @spec is_print_string(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> may represent a
%% string literal containing only "printing" characters, otherwise
%% <code>false</code>. See <code>is_c_string/1</code> and
%% <code>is_print_char/1</code> for details. Currently, only ISO
%% 8859-1 (Latin-1) character values are recognized.
%%
%% @see c_string/1
%% @see is_c_string/1
%% @see is_print_char/1

-spec is_print_string(cerl()) -> boolean().

is_print_string(#c_literal{val = V}) ->
    is_print_char_list(V);
is_print_string(_) ->
    false.


%% @spec string_val(cerl()) -> string()
%%
%% @doc Returns the value represented by an abstract string literal.
%%
%% @see c_string/1

-spec string_val(c_literal()) -> string().

string_val(Node) ->
    Node#c_literal.val.


%% @spec string_lit(cerl()) -> string()
%%
%% @doc Returns the literal string represented by an abstract string.
%% This includes surrounding double-quote characters
%% <code>"..."</code>. Currently, characters that are not in the set
%% of ISO 8859-1 (Latin-1) "printing" characters will be escaped,
%% except for spaces.
%%
%% @see c_string/1

-spec string_lit(c_literal()) -> nonempty_string().

string_lit(Node) ->
    io_lib:write_string(string_val(Node)).


%% ---------------------------------------------------------------------

%% @spec c_nil() -> cerl()
%%
%% @doc Creates an abstract empty list. The result represents
%% "<code>[]</code>". The empty list is traditionally called "nil".
%%
%% @see ann_c_nil/1
%% @see is_c_list/1
%% @see c_cons/2

-spec c_nil() -> c_literal().

c_nil() ->
    #c_literal{val = []}.


%% @spec ann_c_nil(As::[term()]) -> cerl()
%% @see c_nil/0

-spec ann_c_nil([term()]) -> c_literal().

ann_c_nil(As) ->
    #c_literal{val = [], anno = As}.


%% @spec is_c_nil(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% empty list, otherwise <code>false</code>.

-spec is_c_nil(cerl()) -> boolean().

is_c_nil(#c_literal{val = []}) ->
    true;
is_c_nil(_) ->
    false.


%% ---------------------------------------------------------------------

%% @spec c_cons(Head::cerl(), Tail::cerl()) -> cerl()
%%
%% @doc Creates an abstract list constructor. The result represents
%% "<code>[<em>Head</em> | <em>Tail</em>]</code>". Note that if both
%% <code>Head</code> and <code>Tail</code> have type
%% <code>literal</code>, then the result will also have type
%% <code>literal</code>, and annotations on <code>Head</code> and
%% <code>Tail</code> are lost.
%%
%% <p>Recall that in Erlang, the tail element of a list constructor is
%% not necessarily a list.</p>
%%
%% @see ann_c_cons/3
%% @see update_c_cons/3
%% @see c_cons_skel/2
%% @see is_c_cons/1
%% @see cons_hd/1
%% @see cons_tl/1
%% @see is_c_list/1
%% @see c_nil/0
%% @see list_elements/1
%% @see list_length/1
%% @see make_list/2

%% *Always* collapse literals.

-spec c_cons(cerl(), cerl()) -> c_literal() | c_cons().

c_cons(#c_literal{val = Head}, #c_literal{val = Tail}) ->
    #c_literal{val = [Head | Tail]};
c_cons(Head, Tail) ->
    #c_cons{hd = Head, tl = Tail}.


%% @spec ann_c_cons(As::[term()], Head::cerl(), Tail::cerl()) -> cerl()
%% @see c_cons/2

-spec ann_c_cons([term()], cerl(), cerl()) -> c_literal() | c_cons().

ann_c_cons(As, #c_literal{val = Head}, #c_literal{val = Tail}) ->
    #c_literal{val = [Head | Tail], anno = As};
ann_c_cons(As, Head, Tail) ->
    #c_cons{hd = Head, tl = Tail, anno = As}.


%% @spec update_c_cons(Old::cerl(), Head::cerl(), Tail::cerl()) ->
%%           cerl()
%% @see c_cons/2

-spec update_c_cons(c_literal() | c_cons(), cerl(), cerl()) ->
        c_literal() | c_cons().

update_c_cons(Node, #c_literal{val = Head}, #c_literal{val = Tail}) ->
    #c_literal{val = [Head | Tail], anno = get_ann(Node)};
update_c_cons(Node, Head, Tail) ->
    #c_cons{hd = Head, tl = Tail, anno = get_ann(Node)}.


%% @spec c_cons_skel(Head::cerl(), Tail::cerl()) -> cerl()
%%
%% @doc Creates an abstract list constructor skeleton. Does not fold
%% constant literals, i.e., the result always has type
%% <code>cons</code>, representing "<code>[<em>Head</em> |
%% <em>Tail</em>]</code>".
%%
%% <p>This function is occasionally useful when it is necessary to have
%% annotations on the subnodes of a list constructor node, even when the
%% subnodes are constant literals. Note however that
%% <code>is_literal/1</code> will yield <code>false</code> and
%% <code>concrete/1</code> will fail if passed the result from this
%% function.</p>
%%
%% <p><code>fold_literal/1</code> can be used to revert a node to the
%% normal-form representation.</p>
%%
%% @see ann_c_cons_skel/3
%% @see update_c_cons_skel/3
%% @see c_cons/2
%% @see is_c_cons/1
%% @see is_c_list/1
%% @see c_nil/0
%% @see is_literal/1
%% @see fold_literal/1
%% @see concrete/1

%% *Never* collapse literals.

-spec c_cons_skel(cerl(), cerl()) -> c_cons().

c_cons_skel(Head, Tail) ->
    #c_cons{hd = Head, tl = Tail}.


%% @spec ann_c_cons_skel(As::[term()], Head::cerl(), Tail::cerl()) ->
%%           cerl()
%% @see c_cons_skel/2

-spec ann_c_cons_skel([term()], cerl(), cerl()) -> c_cons().

ann_c_cons_skel(As, Head, Tail) ->
    #c_cons{hd = Head, tl = Tail, anno = As}.


%% @spec update_c_cons_skel(Old::cerl(), Head::cerl(), Tail::cerl()) ->
%%           cerl()
%% @see c_cons_skel/2

-spec update_c_cons_skel(c_cons() | c_literal(), cerl(), cerl()) -> c_cons().

update_c_cons_skel(Node, Head, Tail) ->
    #c_cons{hd = Head, tl = Tail, anno = get_ann(Node)}.


%% @spec is_c_cons(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% list constructor, otherwise <code>false</code>.

-spec is_c_cons(cerl()) -> boolean().

is_c_cons(#c_cons{}) ->
    true;
is_c_cons(#c_literal{val = [_ | _]}) ->
    true;
is_c_cons(_) ->
    false.


%% @spec cons_hd(cerl()) -> cerl()
%%
%% @doc Returns the head subtree of an abstract list constructor.
%%
%% @see c_cons/2

-spec cons_hd(c_cons() | c_literal()) -> cerl().

cons_hd(#c_cons{hd = Head}) ->
    Head;
cons_hd(#c_literal{val = [Head | _]}) ->
    #c_literal{val = Head}.


%% @spec cons_tl(cerl()) -> cerl()
%%
%% @doc Returns the tail subtree of an abstract list constructor.
%%
%% <p>Recall that the tail does not necessarily represent a proper
%% list.</p>
%%
%% @see c_cons/2

-spec cons_tl(c_cons() | c_literal()) -> cerl().

cons_tl(#c_cons{tl = Tail}) ->
    Tail;
cons_tl(#c_literal{val = [_ | Tail]}) ->
    #c_literal{val = Tail}.


%% @spec is_c_list(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> represents a
%% proper list, otherwise <code>false</code>. A proper list is either
%% the empty list <code>[]</code>, or a cons cell <code>[<em>Head</em> |
%% <em>Tail</em>]</code>, where recursively <code>Tail</code> is a
%% proper list.
%% 
%% <p>Note: Because <code>Node</code> is a syntax tree, the actual
%% run-time values corresponding to its subtrees may often be partially
%% or completely unknown. Thus, if <code>Node</code> represents e.g.
%% "<code>[... | Ns]</code>" (where <code>Ns</code> is a variable), then
%% the function will return <code>false</code>, because it is not known
%% whether <code>Ns</code> will be bound to a list at run-time. If
%% <code>Node</code> instead represents e.g. "<code>[1, 2, 3]</code>" or
%% "<code>[A | []]</code>", then the function will return
%% <code>true</code>.</p>
%%
%% @see c_cons/2
%% @see c_nil/0
%% @see list_elements/1
%% @see list_length/1

-spec is_c_list(cerl()) -> boolean().

is_c_list(#c_cons{tl = Tail}) ->
    is_c_list(Tail);
is_c_list(#c_literal{val = V}) ->
    is_proper_list(V);
is_c_list(_) ->
    false.

is_proper_list([_ | Tail]) ->
    is_proper_list(Tail);
is_proper_list([]) ->
    true;
is_proper_list(_) ->
    false.

%% @spec list_elements(cerl()) -> [cerl()]
%%
%% @doc Returns the list of element subtrees of an abstract list.
%% <code>Node</code> must represent a proper list. E.g., if
%% <code>Node</code> represents "<code>[<em>X1</em>, <em>X2</em> |
%% [<em>X3</em>, <em>X4</em> | []]</code>", then
%% <code>list_elements(Node)</code> yields the list <code>[X1, X2, X3,
%% X4]</code>.
%%
%% @see c_cons/2
%% @see c_nil/0
%% @see is_c_list/1
%% @see list_length/1
%% @see make_list/2

-spec list_elements(c_cons() | c_literal()) -> [cerl()].

list_elements(#c_cons{hd = Head, tl = Tail}) ->
    [Head | list_elements(Tail)];
list_elements(#c_literal{val = V}) ->
    abstract_list(V).

abstract_list([X | Xs]) ->
    [abstract(X) | abstract_list(Xs)];
abstract_list([]) ->
    [].


%% @spec list_length(Node::cerl()) -> integer()
%%
%% @doc Returns the number of element subtrees of an abstract list.
%% <code>Node</code> must represent a proper list. E.g., if
%% <code>Node</code> represents "<code>[X1 | [X2, X3 | [X4, X5,
%% X6]]]</code>", then <code>list_length(Node)</code> returns the
%% integer 6.
%%
%% <p>Note: this is equivalent to
%% <code>length(list_elements(Node))</code>, but potentially more
%% efficient.</p>
%%
%% @see c_cons/2
%% @see c_nil/0
%% @see is_c_list/1
%% @see list_elements/1

-spec list_length(c_cons() | c_literal()) -> non_neg_integer().

list_length(L) ->
    list_length(L, 0).

list_length(#c_cons{tl = Tail}, A) ->
    list_length(Tail, A + 1);
list_length(#c_literal{val = V}, A) ->
    A + length(V).


%% @spec make_list(List) -> Node
%% @equiv make_list(List, none)

-spec make_list([cerl()]) -> cerl().

make_list(List) ->
    ann_make_list([], List).


%% @spec make_list(List::[cerl()], Tail) -> cerl()
%%
%%	    Tail = cerl() | none
%%
%% @doc Creates an abstract list from the elements in <code>List</code>
%% and the optional <code>Tail</code>. If <code>Tail</code> is
%% <code>none</code>, the result will represent a nil-terminated list,
%% otherwise it represents "<code>[... | <em>Tail</em>]</code>".
%%
%% @see c_cons/2
%% @see c_nil/0
%% @see ann_make_list/3
%% @see update_list/3
%% @see list_elements/1

-spec make_list([cerl()], cerl() | 'none') -> cerl().

make_list(List, Tail) ->
    ann_make_list([], List, Tail).


%% @spec update_list(Old::cerl(), List::[cerl()]) -> cerl()
%% @equiv update_list(Old, List, none)

-spec update_list(cerl(), [cerl()]) -> cerl().

update_list(Node, List) ->
    ann_make_list(get_ann(Node), List).


%% @spec update_list(Old::cerl(), List::[cerl()], Tail) -> cerl()
%%
%%	    Tail = cerl() | none
%%
%% @see make_list/2
%% @see update_list/2

-spec update_list(cerl(), [cerl()], cerl() | 'none') -> cerl().

update_list(Node, List, Tail) ->
    ann_make_list(get_ann(Node), List, Tail).


%% @spec ann_make_list(As::[term()], List::[cerl()]) -> cerl()
%% @equiv ann_make_list(As, List, none)

-spec ann_make_list([term()], [cerl()]) -> cerl().

ann_make_list(As, List) ->
    ann_make_list(As, List, none).


%% @spec ann_make_list(As::[term()], List::[cerl()], Tail) -> cerl()
%%
%%	    Tail = cerl() | none
%%
%% @see make_list/2
%% @see ann_make_list/2

-spec ann_make_list([term()], [cerl()], cerl() | 'none') -> cerl().

ann_make_list(As, [H | T], Tail) ->
    ann_c_cons(As, H, make_list(T, Tail));    % `c_cons' folds literals
ann_make_list(As, [], none) ->
    ann_c_nil(As);
ann_make_list(_, [], Node) ->
    Node.


%% ---------------------------------------------------------------------
%% maps

%% @spec is_c_map(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% map constructor, otherwise <code>false</code>.

-type map_op() :: #c_literal{val::'assoc'} | #c_literal{val::'exact'}.

-spec is_c_map(cerl()) -> boolean().

is_c_map(#c_map{}) ->
    true;
is_c_map(#c_literal{val = V}) when is_map(V) ->
    true;
is_c_map(_) ->
    false.

-spec map_es(c_map() | c_literal()) -> [c_map_pair()].

map_es(#c_literal{anno=As,val=M}) when is_map(M) ->
    [ann_c_map_pair(As,
                    #c_literal{anno=As,val='assoc'},
                    #c_literal{anno=As,val=K},
                    #c_literal{anno=As,val=V}) || {K,V} <- maps:to_list(M)];
map_es(#c_map{es = Es}) ->
    Es.

-spec map_arg(c_map() | c_literal()) -> c_map() | c_literal().

map_arg(#c_literal{anno=As,val=M}) when is_map(M) ->
    #c_literal{anno=As,val=#{}};
map_arg(#c_map{arg=M}) ->
    M.

-spec c_map([c_map_pair()]) -> c_map().

c_map(Pairs) ->
    ann_c_map([], Pairs).

-spec c_map_pattern([c_map_pair()]) -> c_map().

c_map_pattern(Pairs) ->
    #c_map{es=Pairs, is_pat=true}.

-spec ann_c_map_pattern([term()], [c_map_pair()]) -> c_map().

ann_c_map_pattern(As, Pairs) ->
    #c_map{anno=As, es=Pairs, is_pat=true}.

-spec is_c_map_empty(c_map() | c_literal()) -> boolean().

is_c_map_empty(#c_map{ es=[] }) -> true;
is_c_map_empty(#c_literal{val=M}) when is_map(M),map_size(M) =:= 0 -> true;
is_c_map_empty(_) -> false.

-spec is_c_map_pattern(c_map()) -> boolean().

is_c_map_pattern(#c_map{is_pat=IsPat}) ->
    IsPat.

-spec ann_c_map([term()], [c_map_pair()]) -> c_map() | c_literal().

ann_c_map(As, Es) ->
    ann_c_map(As, #c_literal{val=#{}}, Es).

-spec ann_c_map([term()], c_map() | c_literal(), [c_map_pair()]) -> c_map() | c_literal().

ann_c_map(As, #c_literal{val=M0}=Lit, Es) when is_map(M0) ->
    case update_map_literal(Es, M0) of
        none ->
            #c_map{arg=Lit, es=Es, anno=As};
        M1 ->
            #c_literal{anno=As, val=M1}
    end;
ann_c_map(As, M, Es) ->
    #c_map{arg=M, es=Es, anno=As}.

update_map_literal([#c_map_pair{op=#c_literal{val=assoc},key=Ck,val=Cv}|Es], M) ->
    %% M#{K => V}
    case is_lit_list([Ck,Cv]) of
	true ->
	    [K,V] = lit_list_vals([Ck,Cv]),
	    update_map_literal(Es, M#{K => V});
	false ->
	    none
    end;
update_map_literal([#c_map_pair{op=#c_literal{val=exact},key=Ck,val=Cv}|Es], M) ->
    %% M#{K := V}
    case is_lit_list([Ck,Cv]) of
	true ->
	    [K,V] = lit_list_vals([Ck,Cv]),
	    case is_map_key(K, M) of
		true ->
                    update_map_literal(Es, M#{K => V});
		false ->
		    none
	    end;
	false ->
            none
    end;
update_map_literal([], M) ->
    M.

-spec update_c_map(c_map(), cerl(), [cerl()]) -> c_map() | c_literal().

update_c_map(#c_map{is_pat=true}=Old, M, Es) ->
    Old#c_map{arg=M, es=Es};
update_c_map(#c_map{is_pat=false}=Old, M, Es) ->
    ann_c_map(get_ann(Old), M, Es).

-spec map_pair_key(c_map_pair()) -> cerl().

map_pair_key(#c_map_pair{key=K}) -> K.

-spec map_pair_val(c_map_pair()) -> cerl().

map_pair_val(#c_map_pair{val=V}) -> V.

-spec map_pair_op(c_map_pair()) -> map_op().

map_pair_op(#c_map_pair{op=Op}) -> Op.

-spec c_map_pair(cerl(), cerl()) -> c_map_pair().

c_map_pair(Key,Val) ->
    #c_map_pair{op=#c_literal{val=assoc},key=Key,val=Val}.

-spec c_map_pair_exact(cerl(), cerl()) -> c_map_pair().

c_map_pair_exact(Key,Val) ->
    #c_map_pair{op=#c_literal{val=exact},key=Key,val=Val}.

-spec ann_c_map_pair([term()], cerl(), cerl(), cerl()) ->
        c_map_pair().

ann_c_map_pair(As,Op,K,V) ->
    #c_map_pair{op=Op, key = K, val=V, anno = As}.

-spec update_c_map_pair(c_map_pair(), map_op(), cerl(), cerl()) -> c_map_pair().

update_c_map_pair(Old,Op,K,V) ->
    #c_map_pair{op=Op, key=K, val=V, anno = get_ann(Old)}.


%% ---------------------------------------------------------------------

%% @spec c_tuple(Elements::[cerl()]) -> cerl()
%%
%% @doc Creates an abstract tuple. If <code>Elements</code> is
%% <code>[E1, ..., En]</code>, the result represents
%% "<code>{<em>E1</em>, ..., <em>En</em>}</code>".  Note that if all
%% nodes in <code>Elements</code> have type <code>literal</code>, or if
%% <code>Elements</code> is empty, then the result will also have type
%% <code>literal</code> and annotations on nodes in
%% <code>Elements</code> are lost.
%%
%% <p>Recall that Erlang has distinct 1-tuples, i.e., <code>{X}</code>
%% is always distinct from <code>X</code> itself.</p>
%%
%% @see ann_c_tuple/2
%% @see update_c_tuple/2
%% @see is_c_tuple/1
%% @see tuple_es/1
%% @see tuple_arity/1
%% @see c_tuple_skel/1

%% *Always* collapse literals.

-spec c_tuple([cerl()]) -> c_tuple() | c_literal().

c_tuple(Es) ->
    case is_lit_list(Es) of
	false ->
	    #c_tuple{es = Es};
	true ->
	    #c_literal{val = list_to_tuple(lit_list_vals(Es))}
    end.


%% @spec ann_c_tuple(As::[term()], Elements::[cerl()]) -> cerl()
%% @see c_tuple/1

-spec ann_c_tuple([term()], [cerl()]) -> c_tuple() | c_literal().

ann_c_tuple(As, Es) ->
    case is_lit_list(Es) of
	false ->
	    #c_tuple{es = Es, anno = As};
	true ->
	    #c_literal{val = list_to_tuple(lit_list_vals(Es)), anno = As}
    end.


%% @spec update_c_tuple(Old::cerl(),  Elements::[cerl()]) -> cerl()
%% @see c_tuple/1

-spec update_c_tuple(c_tuple() | c_literal(), [cerl()]) -> c_tuple() | c_literal().

update_c_tuple(Node, Es) ->
    case is_lit_list(Es) of
	false ->
	    #c_tuple{es = Es, anno = get_ann(Node)};
	true ->
	    #c_literal{val = list_to_tuple(lit_list_vals(Es)),
		       anno = get_ann(Node)}
    end.


%% @spec c_tuple_skel(Elements::[cerl()]) -> cerl()
%%
%% @doc Creates an abstract tuple skeleton. Does not fold constant
%% literals, i.e., the result always has type <code>tuple</code>,
%% representing "<code>{<em>E1</em>, ..., <em>En</em>}</code>", if
%% <code>Elements</code> is <code>[E1, ..., En]</code>.
%% 
%% <p>This function is occasionally useful when it is necessary to have
%% annotations on the subnodes of a tuple node, even when all the
%% subnodes are constant literals. Note however that
%% <code>is_literal/1</code> will yield <code>false</code> and
%% <code>concrete/1</code> will fail if passed the result from this
%% function.</p>
%%
%% <p><code>fold_literal/1</code> can be used to revert a node to the
%% normal-form representation.</p>
%%
%% @see ann_c_tuple_skel/2
%% @see update_c_tuple_skel/2
%% @see c_tuple/1
%% @see tuple_es/1
%% @see is_c_tuple/1
%% @see is_literal/1
%% @see fold_literal/1
%% @see concrete/1

%% *Never* collapse literals.

-spec c_tuple_skel([cerl()]) -> c_tuple().

c_tuple_skel(Es) ->
    #c_tuple{es = Es}.


%% @spec ann_c_tuple_skel(As::[term()], Elements::[cerl()]) -> cerl()
%% @see c_tuple_skel/1

-spec ann_c_tuple_skel([term()], [cerl()]) -> c_tuple().

ann_c_tuple_skel(As, Es) ->
    #c_tuple{es = Es, anno = As}.


%% @spec update_c_tuple_skel(Old::cerl(), Elements::[cerl()]) -> cerl()
%% @see c_tuple_skel/1

-spec update_c_tuple_skel(c_tuple(), [cerl()]) -> c_tuple().

update_c_tuple_skel(Old, Es) ->
    #c_tuple{es = Es, anno = get_ann(Old)}.


%% @spec is_c_tuple(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% tuple, otherwise <code>false</code>.
%%
%% @see c_tuple/1

-spec is_c_tuple(cerl()) -> boolean().

is_c_tuple(#c_tuple{}) ->
    true;
is_c_tuple(#c_literal{val = V}) when is_tuple(V) ->
    true;
is_c_tuple(_) ->
    false.


%% @spec tuple_es(cerl()) -> [cerl()]
%%
%% @doc Returns the list of element subtrees of an abstract tuple.
%%
%% @see c_tuple/1

-spec tuple_es(c_tuple() | c_literal()) -> [cerl()].

tuple_es(#c_tuple{es = Es}) ->
    Es;
tuple_es(#c_literal{val = V}) ->
    make_lit_list(tuple_to_list(V)).


%% @spec tuple_arity(Node::cerl()) -> integer()
%%
%% @doc Returns the number of element subtrees of an abstract tuple.
%%
%% <p>Note: this is equivalent to <code>length(tuple_es(Node))</code>,
%% but potentially more efficient.</p>
%%
%% @see tuple_es/1
%% @see c_tuple/1

-spec tuple_arity(c_tuple() | c_literal()) -> non_neg_integer().

tuple_arity(#c_tuple{es = Es}) ->
    length(Es);
tuple_arity(#c_literal{val = V}) when is_tuple(V) ->
    tuple_size(V).


%% ---------------------------------------------------------------------

%% @spec c_var(Name::var_name()) -> cerl()
%%
%%     var_name() = integer() | atom() | {atom(), integer()}
%%
%% @doc Creates an abstract variable. A variable is identified by its
%% name, given by the <code>Name</code> parameter.
%%
%% <p>If a name is given by a single atom, it should either be a
%% "simple" atom which does not need to be single-quoted in Erlang, or
%% otherwise its print name should correspond to a proper Erlang
%% variable, i.e., begin with an uppercase character or an
%% underscore. Names on the form <code>{A, N}</code> represent
%% function name variables "<code><em>A</em>/<em>N</em></code>"; these
%% are special variables which may be bound only in the function
%% definitions of a module or a <code>letrec</code>.  They may not be
%% bound in <code>let</code> expressions and cannot occur in clause
%% patterns. The atom <code>A</code> in a function name may be any
%% atom; the integer <code>N</code> must be nonnegative. The functions
%% <code>c_fname/2</code> etc. are utilities for handling function
%% name variables.</p>
%%
%% <p>When printing variable names, they must have the form of proper
%% Core Erlang variables and function names. E.g., a name represented
%% by an integer such as <code>42</code> could be formatted as
%% "<code>_42</code>", an atom <code>'Xxx'</code> simply as
%% "<code>Xxx</code>", and an atom <code>foo</code> as
%% "<code>_foo</code>". However, one must assure that any two valid
%% distinct names are never mapped to the same strings.  Tuples such
%% as <code>{foo, 2}</code> representing function names can simply by
%% formatted as "<code>'foo'/2</code>", with no risk of conflicts.</p>
%%
%% @see ann_c_var/2
%% @see update_c_var/2
%% @see is_c_var/1
%% @see var_name/1
%% @see c_fname/2
%% @see c_module/4
%% @see c_letrec/2

-spec c_var(var_name()) -> c_var().

c_var(Name) ->
    #c_var{name = Name}.


%% @spec ann_c_var(As::[term()], Name::var_name()) -> cerl()
%%
%% @see c_var/1

-spec ann_c_var([term()], var_name()) -> c_var().

ann_c_var(As, Name) ->
    #c_var{name = Name, anno = As}.

%% @spec update_c_var(Old::cerl(), Name::var_name()) -> cerl()
%%
%% @see c_var/1

-spec update_c_var(c_var(), var_name()) -> c_var().

update_c_var(Node, Name) ->
    #c_var{name = Name, anno = get_ann(Node)}.


%% @spec is_c_var(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% variable, otherwise <code>false</code>.
%%
%% @see c_var/1

-spec is_c_var(cerl()) -> boolean().

is_c_var(#c_var{}) ->
    true;
is_c_var(_) ->
    false.


%% @spec c_fname(Name::atom(), Arity::arity()) -> cerl()
%% @equiv c_var({Name, Arity})
%% @see fname_id/1
%% @see fname_arity/1
%% @see is_c_fname/1
%% @see ann_c_fname/3
%% @see update_c_fname/3

-spec c_fname(atom(), arity()) -> c_var().

c_fname(Atom, Arity) ->
    c_var({Atom, Arity}).


%% @spec ann_c_fname(As::[term()], Name::atom(), Arity::arity()) ->
%%           cerl()
%% @equiv ann_c_var(As, {Atom, Arity})
%% @see c_fname/2

-spec ann_c_fname([term()], atom(), arity()) -> c_var().

ann_c_fname(As, Atom, Arity) ->
    ann_c_var(As, {Atom, Arity}).


%% @spec update_c_fname(Old::cerl(), Name::atom()) -> cerl()
%% @doc Like <code>update_c_fname/3</code>, but takes the arity from
%% <code>Node</code>.
%% @see update_c_fname/3
%% @see c_fname/2

-spec update_c_fname(c_var(), atom()) -> c_var().

update_c_fname(#c_var{name = {_, Arity}, anno = As}, Atom) ->
    #c_var{name = {Atom, Arity}, anno = As}.


%% @spec update_c_fname(Old::cerl(), Name::atom(), Arity::arity()) ->
%%           cerl()
%% @equiv update_c_var(Old, {Atom, Arity})
%% @see update_c_fname/2
%% @see c_fname/2

-spec update_c_fname(c_var(), atom(), arity()) -> c_var().

update_c_fname(Node, Atom, Arity) ->
    update_c_var(Node, {Atom, Arity}).


%% @spec is_c_fname(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% function name variable, otherwise <code>false</code>.
%%
%% @see c_fname/2
%% @see c_var/1
%% @see var_name/1

-spec is_c_fname(cerl()) -> boolean().

is_c_fname(#c_var{name = {A, N}}) when is_atom(A), is_integer(N), N >= 0 ->
    true;
is_c_fname(_) ->
    false.


%% @spec var_name(cerl()) -> var_name()
%%
%% @doc Returns the name of an abstract variable.
%%
%% @see c_var/1

-spec var_name(c_var()) -> var_name().

var_name(Node) ->
    Node#c_var.name.


%% @spec fname_id(cerl()) -> atom()
%%
%% @doc Returns the identifier part of an abstract function name
%% variable.
%% 
%% @see fname_arity/1
%% @see c_fname/2

-spec fname_id(c_var()) -> atom().

fname_id(#c_var{name={A,_}}) ->
    A.


%% @spec fname_arity(cerl()) -> arity()
%%
%% @doc Returns the arity part of an abstract function name variable.
%%
%% @see fname_id/1
%% @see c_fname/2

-spec fname_arity(c_var()) -> arity().

fname_arity(#c_var{name={_,N}}) ->
    N.


%% ---------------------------------------------------------------------

%% @spec c_values(Elements::[cerl()]) -> cerl()
%%
%% @doc Creates an abstract value list. If <code>Elements</code> is
%% <code>[E1, ..., En]</code>, the result represents
%% "<code>&lt;<em>E1</em>, ..., <em>En</em>&gt;</code>".
%%
%% @see ann_c_values/2
%% @see update_c_values/2
%% @see is_c_values/1
%% @see values_es/1
%% @see values_arity/1

-spec c_values([cerl()]) -> c_values().

c_values(Es) ->
    #c_values{es = Es}.


%% @spec ann_c_values(As::[term()], Elements::[cerl()]) -> cerl()
%% @see c_values/1

-spec ann_c_values([term()], [cerl()]) -> c_values().

ann_c_values(As, Es) ->
    #c_values{es = Es, anno = As}.


%% @spec update_c_values(Old::cerl(), Elements::[cerl()]) -> cerl()
%% @see c_values/1

-spec update_c_values(c_values(), [cerl()]) -> c_values().

update_c_values(Node, Es) ->
    #c_values{es = Es, anno = get_ann(Node)}.


%% @spec is_c_values(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% value list; otherwise <code>false</code>.
%%
%% @see c_values/1

-spec is_c_values(cerl()) -> boolean().

is_c_values(#c_values{}) ->
    true;
is_c_values(_) ->
    false.


%% @spec values_es(cerl()) -> [cerl()]
%%
%% @doc Returns the list of element subtrees of an abstract value
%% list.
%%
%% @see c_values/1
%% @see values_arity/1

-spec values_es(c_values()) -> [cerl()].

values_es(Node) ->
    Node#c_values.es.


%% @spec values_arity(Node::cerl()) -> integer()
%%
%% @doc Returns the number of element subtrees of an abstract value
%% list.
%% 
%% <p>Note: This is equivalent to
%% <code>length(values_es(Node))</code>, but potentially more
%% efficient.</p>
%%
%% @see c_values/1
%% @see values_es/1

-spec values_arity(c_values()) -> non_neg_integer().

values_arity(Node) ->
    length(values_es(Node)).


%% ---------------------------------------------------------------------

%% @spec c_binary(Segments::[cerl()]) -> cerl()
%%

%% @doc Creates an abstract binary-template. A binary object is in
%% this context a sequence of an arbitrary number of bits. (The number
%% of bits used to be evenly divisible by 8, but after the
%% introduction of bit strings in the Erlang language, the choice was
%% made to use the binary template for all bit strings.) It is
%% specified by zero or more bit-string template <em>segments</em> of
%% arbitrary lengths (in number of bits). If <code>Segments</code> is
%% <code>[S1, ..., Sn]</code>, the result represents
%% "<code>#{<em>S1</em>, ..., <em>Sn</em>}#</code>". All the
%% <code>Si</code> must have type <code>bitstr</code>.
%%
%% @see ann_c_binary/2
%% @see update_c_binary/2
%% @see is_c_binary/1
%% @see binary_segments/1
%% @see c_bitstr/5

-spec c_binary([cerl()]) -> c_binary().

c_binary(Segments) ->
    #c_binary{segments = Segments}.


%% @spec ann_c_binary(As::[term()], Segments::[cerl()]) -> cerl()
%% @see c_binary/1

-spec ann_c_binary([term()], [cerl()]) -> c_binary().

ann_c_binary(As, Segments) ->
    #c_binary{segments = Segments, anno = As}.


%% @spec update_c_binary(Old::cerl(), Segments::[cerl()]) -> cerl()
%% @see c_binary/1

-spec update_c_binary(c_binary(), [cerl()]) -> c_binary().

update_c_binary(Node, Segments) ->
    #c_binary{segments = Segments, anno = get_ann(Node)}.


%% @spec is_c_binary(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% binary-template; otherwise <code>false</code>.
%%
%% @see c_binary/1

-spec is_c_binary(cerl()) -> boolean().

is_c_binary(#c_binary{}) ->
    true;
is_c_binary(_) ->
    false.


%% @spec binary_segments(cerl()) -> [cerl()]
%%
%% @doc Returns the list of segment subtrees of an abstract
%% binary-template.
%%
%% @see c_binary/1
%% @see c_bitstr/5

-spec binary_segments(c_binary()) -> [cerl()].

binary_segments(Node) ->
    Node#c_binary.segments.


%% @spec c_bitstr(Value::cerl(), Size::cerl(), Unit::cerl(),
%%                Type::cerl(), Flags::cerl()) -> cerl()
%%
%% @doc Creates an abstract bit-string template. These can only occur as
%% components of an abstract binary-template (see {@link c_binary/1}).
%% The result represents "<code>#&lt;<em>Value</em>&gt;(<em>Size</em>,
%% <em>Unit</em>, <em>Type</em>, <em>Flags</em>)</code>", where
%% <code>Unit</code> must represent a positive integer constant,
%% <code>Type</code> must represent a constant atom (one of
%% <code>'integer'</code>, <code>'float'</code>, or
%% <code>'binary'</code>), and <code>Flags</code> must represent a
%% constant list <code>"[<em>F1</em>, ..., <em>Fn</em>]"</code> where
%% all the <code>Fi</code> are atoms.
%% 
%% @see c_binary/1
%% @see ann_c_bitstr/6
%% @see update_c_bitstr/6
%% @see is_c_bitstr/1
%% @see bitstr_val/1
%% @see bitstr_size/1
%% @see bitstr_unit/1
%% @see bitstr_type/1
%% @see bitstr_flags/1

-spec c_bitstr(cerl(), cerl(), cerl(), cerl(), cerl()) -> c_bitstr().

c_bitstr(Val, Size, Unit, Type, Flags) ->
    #c_bitstr{val = Val, size = Size, unit = Unit, type = Type,
	      flags = Flags}.


%% @spec c_bitstr(Value::cerl(), Size::cerl(), Type::cerl(),
%%                Flags::cerl()) -> cerl()
%% @equiv c_bitstr(Value, Size, abstract(1), Type, Flags)

-spec c_bitstr(cerl(), cerl(), cerl(), cerl()) -> c_bitstr().

c_bitstr(Val, Size, Type, Flags) ->
    c_bitstr(Val, Size, abstract(1), Type, Flags).


%% @spec c_bitstr(Value::cerl(), Type::cerl(),
%%                Flags::cerl()) -> cerl()
%% @equiv c_bitstr(Value, abstract(all), abstract(1), Type, Flags)

-spec c_bitstr(cerl(), cerl(), cerl()) -> c_bitstr().

c_bitstr(Val, Type, Flags) ->
    c_bitstr(Val, abstract(all), abstract(1), Type, Flags).


%% @spec ann_c_bitstr(As::[term()], Value::cerl(), Size::cerl(),
%%                    Unit::cerl(), Type::cerl(), Flags::cerl()) -> cerl()
%% @see c_bitstr/5
%% @see ann_c_bitstr/5

-spec ann_c_bitstr([term()], cerl(), cerl(), cerl(), cerl(), cerl()) ->
        c_bitstr().

ann_c_bitstr(As, Val, Size, Unit, Type, Flags) ->
    #c_bitstr{val = Val, size = Size, unit = Unit, type = Type,
	      flags = Flags, anno = As}.

%% @spec ann_c_bitstr(As::[term()], Value::cerl(), Size::cerl(),
%%                    Type::cerl(), Flags::cerl()) -> cerl()
%% @equiv ann_c_bitstr(As, Value, Size, abstract(1), Type, Flags)

-spec ann_c_bitstr([term()], cerl(), cerl(), cerl(), cerl()) -> c_bitstr().

ann_c_bitstr(As, Value, Size, Type, Flags) ->
    ann_c_bitstr(As, Value, Size, abstract(1), Type, Flags).


%% @spec update_c_bitstr(Old::cerl(), Value::cerl(), Size::cerl(),
%%           Unit::cerl(), Type::cerl(), Flags::cerl()) -> cerl()
%% @see c_bitstr/5
%% @see update_c_bitstr/5

-spec update_c_bitstr(c_bitstr(), cerl(), cerl(), cerl(), cerl(), cerl()) ->
        c_bitstr().

update_c_bitstr(Node, Val, Size, Unit, Type, Flags) ->
    #c_bitstr{val = Val, size = Size, unit = Unit, type = Type,
	     flags = Flags, anno = get_ann(Node)}.


%% @spec update_c_bitstr(Old::cerl(), Value::cerl(), Size::cerl(),
%%                       Type::cerl(), Flags::cerl()) -> cerl()
%% @equiv update_c_bitstr(Node, Value, Size, abstract(1), Type, Flags)

-spec update_c_bitstr(c_bitstr(), cerl(), cerl(), cerl(), cerl()) -> c_bitstr().

update_c_bitstr(Node, Value, Size, Type, Flags) ->
    update_c_bitstr(Node, Value, Size, abstract(1), Type, Flags).

%% @spec is_c_bitstr(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% bit-string template; otherwise <code>false</code>.
%%
%% @see c_bitstr/5

-spec is_c_bitstr(cerl()) -> boolean().

is_c_bitstr(#c_bitstr{}) ->
    true;
is_c_bitstr(_) ->
    false.


%% @spec bitstr_val(cerl()) -> cerl()
%%
%% @doc Returns the value subtree of an abstract bit-string template.
%%
%% @see c_bitstr/5

-spec bitstr_val(c_bitstr()) -> cerl().

bitstr_val(Node) ->
    Node#c_bitstr.val.


%% @spec bitstr_size(cerl()) -> cerl()
%%
%% @doc Returns the size subtree of an abstract bit-string template.
%%
%% @see c_bitstr/5

-spec bitstr_size(c_bitstr()) -> cerl().

bitstr_size(Node) ->
    Node#c_bitstr.size.


%% @spec bitstr_bitsize(cerl()) -> any | all | utf | integer()
%%
%% @doc Returns the total size in bits of an abstract bit-string
%% template. If the size field is an integer literal, the result is the
%% product of the size and unit values; if the size field is the atom
%% literal <code>all</code>, the atom <code>all</code> is returned.
%% If the size is not a literal, the atom <code>any</code> is returned.
%%
%% @see c_bitstr/5

-spec bitstr_bitsize(c_bitstr()) -> 'all' | 'any' | 'utf' | non_neg_integer().

bitstr_bitsize(Node) ->
    Size = Node#c_bitstr.size,
    case is_literal(Size) of
	true ->
	    case concrete(Size) of
		all ->
		    all;
		undefined ->
		     %% just an assertion below
		    "utf" ++ _ = atom_to_list(concrete(Node#c_bitstr.type)),
		    utf;
		S when is_integer(S) ->
		    S * concrete(Node#c_bitstr.unit)
	    end;
	false ->
	    any
    end.


%% @spec bitstr_unit(cerl()) -> cerl()
%%
%% @doc Returns the unit subtree of an abstract bit-string template.
%%
%% @see c_bitstr/5

-spec bitstr_unit(c_bitstr()) -> cerl().

bitstr_unit(Node) ->
    Node#c_bitstr.unit.


%% @spec bitstr_type(cerl()) -> cerl()
%%
%% @doc Returns the type subtree of an abstract bit-string template.
%%
%% @see c_bitstr/5

-spec bitstr_type(c_bitstr()) -> cerl().

bitstr_type(Node) ->
    Node#c_bitstr.type.


%% @spec bitstr_flags(cerl()) -> cerl()
%%
%% @doc Returns the flags subtree of an abstract bit-string template.
%%
%% @see c_bitstr/5

-spec bitstr_flags(c_bitstr()) -> cerl().

bitstr_flags(Node) ->
    Node#c_bitstr.flags.


%% ---------------------------------------------------------------------

%% @spec c_fun(Variables::[cerl()], Body::cerl()) -> cerl()
%%
%% @doc Creates an abstract fun-expression. If <code>Variables</code>
%% is <code>[V1, ..., Vn]</code>, the result represents "<code>fun
%% (<em>V1</em>, ..., <em>Vn</em>) -> <em>Body</em></code>". All the
%% <code>Vi</code> must have type <code>var</code>.
%%
%% @see ann_c_fun/3
%% @see update_c_fun/3
%% @see is_c_fun/1
%% @see fun_vars/1
%% @see fun_body/1
%% @see fun_arity/1

-spec c_fun([cerl()], cerl()) -> c_fun().

c_fun(Variables, Body) ->
    #c_fun{vars = Variables, body = Body}.


%% @spec ann_c_fun(As::[term()], Variables::[cerl()], Body::cerl()) ->
%%           cerl()
%% @see c_fun/2

-spec ann_c_fun([term()], [cerl()], cerl()) -> c_fun().

ann_c_fun(As, Variables, Body) ->
    #c_fun{vars = Variables, body = Body, anno = As}.


%% @spec update_c_fun(Old::cerl(), Variables::[cerl()],
%%                    Body::cerl()) -> cerl()
%% @see c_fun/2

-spec update_c_fun(c_fun(), [cerl()], cerl()) -> c_fun().

update_c_fun(Node, Variables, Body) ->
    #c_fun{vars = Variables, body = Body, anno = get_ann(Node)}.


%% @spec is_c_fun(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% fun-expression, otherwise <code>false</code>.
%%
%% @see c_fun/2

-spec is_c_fun(cerl()) -> boolean().

is_c_fun(#c_fun{}) ->
    true;		% Now this is fun!
is_c_fun(_) ->
    false.


%% @spec fun_vars(cerl()) -> [cerl()]
%%
%% @doc Returns the list of parameter subtrees of an abstract
%% fun-expression.
%%
%% @see c_fun/2
%% @see fun_arity/1

-spec fun_vars(c_fun()) -> [cerl()].

fun_vars(Node) ->
    Node#c_fun.vars.


%% @spec fun_body(cerl()) -> cerl()
%%
%% @doc Returns the body subtree of an abstract fun-expression.
%%
%% @see c_fun/2

-spec fun_body(c_fun()) -> cerl().

fun_body(Node) ->
    Node#c_fun.body.


%% @spec fun_arity(Node::cerl()) -> arity()
%%
%% @doc Returns the number of parameter subtrees of an abstract
%% fun-expression.
%% 
%% <p>Note: this is equivalent to <code>length(fun_vars(Node))</code>,
%% but potentially more efficient.</p>
%%
%% @see c_fun/2
%% @see fun_vars/1

-spec fun_arity(c_fun()) -> arity().

fun_arity(Node) ->
    length(fun_vars(Node)).


%% ---------------------------------------------------------------------

%% @spec c_seq(Argument::cerl(), Body::cerl()) -> cerl()
%%
%% @doc Creates an abstract sequencing expression. The result
%% represents "<code>do <em>Argument</em> <em>Body</em></code>".
%%
%% @see ann_c_seq/3
%% @see update_c_seq/3
%% @see is_c_seq/1
%% @see seq_arg/1
%% @see seq_body/1

-spec c_seq(cerl(), cerl()) -> c_seq().

c_seq(Argument, Body) ->
    #c_seq{arg = Argument, body = Body}.


%% @spec ann_c_seq(As::[term()], Argument::cerl(), Body::cerl()) ->
%%           cerl()
%% @see c_seq/2

-spec ann_c_seq([term()], cerl(), cerl()) -> c_seq().

ann_c_seq(As, Argument, Body) ->
    #c_seq{arg = Argument, body = Body, anno = As}.


%% @spec update_c_seq(Old::cerl(), Argument::cerl(), Body::cerl()) ->
%%           cerl()
%% @see c_seq/2

-spec update_c_seq(c_seq(), cerl(), cerl()) -> c_seq().

update_c_seq(Node, Argument, Body) ->
    #c_seq{arg = Argument, body = Body, anno = get_ann(Node)}.


%% @spec is_c_seq(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% sequencing expression, otherwise <code>false</code>.
%%
%% @see c_seq/2

-spec is_c_seq(cerl()) -> boolean().

is_c_seq(#c_seq{}) ->
    true;
is_c_seq(_) ->
    false.


%% @spec seq_arg(cerl()) -> cerl()
%%
%% @doc Returns the argument subtree of an abstract sequencing
%% expression.
%%
%% @see c_seq/2

-spec seq_arg(c_seq()) -> cerl().

seq_arg(Node) ->
    Node#c_seq.arg.


%% @spec seq_body(cerl()) -> cerl()
%%
%% @doc Returns the body subtree of an abstract sequencing expression.
%%
%% @see c_seq/2

-spec seq_body(c_seq()) -> cerl().

seq_body(Node) ->
    Node#c_seq.body.


%% ---------------------------------------------------------------------

%% @spec c_let(Variables::[cerl()], Argument::cerl(), Body::cerl()) ->
%%           cerl()
%%
%% @doc Creates an abstract let-expression. If <code>Variables</code>
%% is <code>[V1, ..., Vn]</code>, the result represents "<code>let
%% &lt;<em>V1</em>, ..., <em>Vn</em>&gt; = <em>Argument</em> in
%% <em>Body</em></code>".  All the <code>Vi</code> must have type
%% <code>var</code>.
%%
%% @see ann_c_let/4
%% @see update_c_let/4
%% @see is_c_let/1
%% @see let_vars/1
%% @see let_arg/1
%% @see let_body/1
%% @see let_arity/1

-spec c_let([cerl()], cerl(), cerl()) -> c_let().

c_let(Variables, Argument, Body) ->
    #c_let{vars = Variables, arg = Argument, body = Body}.


%% ann_c_let(As, Variables, Argument, Body) -> Node
%% @see c_let/3

-spec ann_c_let([term()], [cerl()], cerl(), cerl()) -> c_let().

ann_c_let(As, Variables, Argument, Body) ->
    #c_let{vars = Variables, arg = Argument, body = Body, anno = As}.


%% update_c_let(Old, Variables, Argument, Body) -> Node
%% @see c_let/3

-spec update_c_let(c_let(), [cerl()], cerl(), cerl()) -> c_let().

update_c_let(Node, Variables, Argument, Body) ->
    #c_let{vars = Variables, arg = Argument, body = Body,
	   anno = get_ann(Node)}.


%% @spec is_c_let(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% let-expression, otherwise <code>false</code>.
%%
%% @see c_let/3

-spec is_c_let(cerl()) -> boolean().

is_c_let(#c_let{}) ->
    true;
is_c_let(_) ->
    false.


%% @spec let_vars(cerl()) -> [cerl()]
%%
%% @doc Returns the list of left-hand side variables of an abstract
%% let-expression.
%%
%% @see c_let/3
%% @see let_arity/1

-spec let_vars(c_let()) -> [cerl()].

let_vars(Node) ->
    Node#c_let.vars.


%% @spec let_arg(cerl()) -> cerl()
%%
%% @doc Returns the argument subtree of an abstract let-expression.
%%
%% @see c_let/3

-spec let_arg(c_let()) -> cerl().

let_arg(Node) ->
    Node#c_let.arg.


%% @spec let_body(cerl()) -> cerl()
%%
%% @doc Returns the body subtree of an abstract let-expression.
%%
%% @see c_let/3

-spec let_body(c_let()) -> cerl().

let_body(Node) ->
    Node#c_let.body.


%% @spec let_arity(Node::cerl()) -> integer()
%%
%% @doc Returns the number of left-hand side variables of an abstract
%% let-expression.
%% 
%% <p>Note: this is equivalent to <code>length(let_vars(Node))</code>,
%% but potentially more efficient.</p>
%%
%% @see c_let/3
%% @see let_vars/1

-spec let_arity(c_let()) -> non_neg_integer().

let_arity(Node) ->
    length(let_vars(Node)).


%% ---------------------------------------------------------------------

%% @spec c_letrec(Definitions::[{cerl(), cerl()}], Body::cerl()) ->
%%           cerl()
%%
%% @doc Creates an abstract letrec-expression. If
%% <code>Definitions</code> is <code>[{V1, F1}, ..., {Vn, Fn}]</code>,
%% the result represents "<code>letrec <em>V1</em> = <em>F1</em>
%% ... <em>Vn</em> = <em>Fn</em> in <em>Body</em></code>.  All the
%% <code>Vi</code> must have type <code>var</code> and represent
%% function names.  All the <code>Fi</code> must have type
%% <code>'fun'</code>.
%%
%% @see ann_c_letrec/3
%% @see update_c_letrec/3
%% @see is_c_letrec/1
%% @see letrec_defs/1
%% @see letrec_body/1
%% @see letrec_vars/1

-spec c_letrec([{cerl(), cerl()}], cerl()) -> c_letrec().

c_letrec(Defs, Body) ->
    #c_letrec{defs = Defs, body = Body}.


%% @spec ann_c_letrec(As::[term()], Definitions::[{cerl(), cerl()}],
%%                    Body::cerl()) -> cerl()
%% @see c_letrec/2

-spec ann_c_letrec([term()], [{cerl(), cerl()}], cerl()) -> c_letrec().

ann_c_letrec(As, Defs, Body) ->
    #c_letrec{defs = Defs, body = Body, anno = As}.


%% @spec update_c_letrec(Old::cerl(),
%%                       Definitions::[{cerl(), cerl()}],
%%                       Body::cerl()) -> cerl()
%% @see c_letrec/2

-spec update_c_letrec(c_letrec(), [{cerl(), cerl()}], cerl()) -> c_letrec().

update_c_letrec(Node, Defs, Body) ->
    #c_letrec{defs = Defs, body = Body, anno = get_ann(Node)}.


%% @spec is_c_letrec(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% letrec-expression, otherwise <code>false</code>.
%%
%% @see c_letrec/2

-spec is_c_letrec(cerl()) -> boolean().

is_c_letrec(#c_letrec{}) ->
    true;
is_c_letrec(_) ->
    false.


%% @spec letrec_defs(Node::cerl()) -> [{cerl(), cerl()}]
%%
%% @doc Returns the list of definitions of an abstract
%% letrec-expression. If <code>Node</code> represents "<code>letrec
%% <em>V1</em> = <em>F1</em> ... <em>Vn</em> = <em>Fn</em> in
%% <em>Body</em></code>", the returned value is <code>[{V1, F1}, ...,
%% {Vn, Fn}]</code>.
%%
%% @see c_letrec/2

-spec letrec_defs(c_letrec()) -> [{cerl(), cerl()}].

letrec_defs(Node) ->
    Node#c_letrec.defs.


%% @spec letrec_body(cerl()) -> cerl()
%%
%% @doc Returns the body subtree of an abstract letrec-expression.
%%
%% @see c_letrec/2

-spec letrec_body(c_letrec()) -> cerl().

letrec_body(Node) ->
    Node#c_letrec.body.


%% @spec letrec_vars(cerl()) -> [cerl()]
%%
%% @doc Returns the list of left-hand side function variable subtrees
%% of a letrec-expression. If <code>Node</code> represents
%% "<code>letrec <em>V1</em> = <em>F1</em> ... <em>Vn</em> =
%% <em>Fn</em> in <em>Body</em></code>", the returned value is
%% <code>[V1, ..., Vn]</code>.
%%
%% @see c_letrec/2

-spec letrec_vars(c_letrec()) -> [cerl()].

letrec_vars(Node) ->
    [F || {F, _} <- letrec_defs(Node)].


%% ---------------------------------------------------------------------

%% @spec c_case(Argument::cerl(), Clauses::[cerl()]) -> cerl()
%%
%% @doc Creates an abstract case-expression. If <code>Clauses</code>
%% is <code>[C1, ..., Cn]</code>, the result represents "<code>case
%% <em>Argument</em> of <em>C1</em> ... <em>Cn</em>
%% end</code>". <code>Clauses</code> must not be empty.
%%
%% @see ann_c_case/3
%% @see update_c_case/3
%% @see is_c_case/1
%% @see c_clause/3
%% @see case_arg/1
%% @see case_clauses/1
%% @see case_arity/1

-spec c_case(cerl(), [cerl()]) -> c_case().

c_case(Expr, Clauses) ->
    #c_case{arg = Expr, clauses = Clauses}.


%% @spec ann_c_case(As::[term()], Argument::cerl(),
%%                  Clauses::[cerl()]) -> cerl()
%% @see c_case/2

-spec ann_c_case([term()], cerl(), [cerl()]) -> c_case().

ann_c_case(As, Expr, Clauses) ->
    #c_case{arg = Expr, clauses = Clauses, anno = As}.


%% @spec update_c_case(Old::cerl(), Argument::cerl(),
%%                     Clauses::[cerl()]) -> cerl()
%% @see c_case/2

-spec update_c_case(c_case(), cerl(), [cerl()]) -> c_case().

update_c_case(Node, Expr, Clauses) ->
    #c_case{arg = Expr, clauses = Clauses, anno = get_ann(Node)}.


%% is_c_case(Node) -> boolean()
%%
%%	    Node = cerl()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% case-expression; otherwise <code>false</code>.
%%
%% @see c_case/2

-spec is_c_case(cerl()) -> boolean().

is_c_case(#c_case{}) ->
    true;
is_c_case(_) ->
    false.


%% @spec case_arg(cerl()) -> cerl()
%%
%% @doc Returns the argument subtree of an abstract case-expression.
%%
%% @see c_case/2

-spec case_arg(c_case()) -> cerl().

case_arg(Node) ->
    Node#c_case.arg.


%% @spec case_clauses(cerl()) -> [cerl()]
%%
%% @doc Returns the list of clause subtrees of an abstract
%% case-expression.
%%
%% @see c_case/2
%% @see case_arity/1

-spec case_clauses(c_case()) -> [cerl()].

case_clauses(Node) ->
    Node#c_case.clauses.


%% @spec case_arity(Node::cerl()) -> integer()
%%
%% @doc Equivalent to
%% <code>clause_arity(hd(case_clauses(Node)))</code>, but potentially
%% more efficient.
%%
%% @see c_case/2
%% @see case_clauses/1
%% @see clause_arity/1

-spec case_arity(c_case()) -> non_neg_integer().

case_arity(Node) ->
    clause_arity(hd(case_clauses(Node))).


%% ---------------------------------------------------------------------

%% @spec c_clause(Patterns::[cerl()], Body::cerl()) -> cerl()
%% @equiv c_clause(Patterns, c_atom(true), Body)
%% @see c_atom/1

-spec c_clause([cerl()], cerl()) -> c_clause().

c_clause(Patterns, Body) ->
    c_clause(Patterns, c_atom(true), Body).


%% @spec c_clause(Patterns::[cerl()], Guard::cerl(), Body::cerl()) ->
%%           cerl()
%%
%% @doc Creates an an abstract clause. If <code>Patterns</code> is
%% <code>[P1, ..., Pn]</code>, the result represents
%% "<code>&lt;<em>P1</em>, ..., <em>Pn</em>&gt; when <em>Guard</em> ->
%% <em>Body</em></code>".
%%
%% @see c_clause/2
%% @see ann_c_clause/4
%% @see update_c_clause/4
%% @see is_c_clause/1
%% @see c_case/2
%% @see c_receive/3
%% @see clause_pats/1
%% @see clause_guard/1
%% @see clause_body/1
%% @see clause_arity/1
%% @see clause_vars/1

-spec c_clause([cerl()], cerl(), cerl()) -> c_clause().

c_clause(Patterns, Guard, Body) ->
    #c_clause{pats = Patterns, guard = Guard, body = Body}.


%% @spec ann_c_clause(As::[term()], Patterns::[cerl()],
%%                    Body::cerl()) -> cerl()
%% @equiv ann_c_clause(As, Patterns, c_atom(true), Body)
%% @see c_clause/3

-spec ann_c_clause([term()], [cerl()], cerl()) -> c_clause().

ann_c_clause(As, Patterns, Body) ->
    ann_c_clause(As, Patterns, c_atom(true), Body).


%% @spec ann_c_clause(As::[term()], Patterns::[cerl()], Guard::cerl(),
%%                    Body::cerl()) -> cerl()
%% @see ann_c_clause/3
%% @see c_clause/3

-spec ann_c_clause([term()], [cerl()], cerl(), cerl()) -> c_clause().

ann_c_clause(As, Patterns, Guard, Body) ->
    #c_clause{pats = Patterns, guard = Guard, body = Body, anno = As}.


%% @spec update_c_clause(Old::cerl(), Patterns::[cerl()],
%%                       Guard::cerl(), Body::cerl()) -> cerl()
%% @see c_clause/3

-spec update_c_clause(c_clause(), [cerl()], cerl(), cerl()) -> c_clause().

update_c_clause(Node, Patterns, Guard, Body) ->
    #c_clause{pats = Patterns, guard = Guard, body = Body,
	      anno = get_ann(Node)}.


%% @spec is_c_clause(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% clause, otherwise <code>false</code>.
%%
%% @see c_clause/3

-spec is_c_clause(cerl()) -> boolean().

is_c_clause(#c_clause{}) ->
    true;
is_c_clause(_) ->
    false.


%% @spec clause_pats(cerl()) -> [cerl()]
%%
%% @doc Returns the list of pattern subtrees of an abstract clause.
%%
%% @see c_clause/3
%% @see clause_arity/1

-spec clause_pats(c_clause()) -> [cerl()].

clause_pats(Node) ->
    Node#c_clause.pats.


%% @spec clause_guard(cerl()) -> cerl()
%%
%% @doc Returns the guard subtree of an abstract clause.
%% 
%% @see c_clause/3

-spec clause_guard(c_clause()) -> cerl().

clause_guard(Node) ->
    Node#c_clause.guard.


%% @spec clause_body(cerl()) -> cerl()
%%
%% @doc Returns the body subtree of an abstract clause.
%%
%% @see c_clause/3

-spec clause_body(c_clause()) -> cerl().

clause_body(Node) ->
    Node#c_clause.body.


%% @spec clause_arity(Node::cerl()) -> integer()
%%
%% @doc Returns the number of pattern subtrees of an abstract clause.
%%
%% <p>Note: this is equivalent to
%% <code>length(clause_pats(Node))</code>, but potentially more
%% efficient.</p>
%%
%% @see c_clause/3
%% @see clause_pats/1

-spec clause_arity(c_clause()) -> non_neg_integer().

clause_arity(Node) ->
    length(clause_pats(Node)).


%% @spec clause_vars(cerl()) -> [cerl()]
%%
%% @doc Returns the list of all abstract variables in the patterns of
%% an abstract clause. The order of listing is not defined.
%%
%% @see c_clause/3
%% @see pat_list_vars/1

-spec clause_vars(c_clause()) -> [cerl()].

clause_vars(Clause) ->
    pat_list_vars(clause_pats(Clause)).


%% @spec pat_vars(Pattern::cerl()) -> [cerl()]
%%
%% @doc Returns the list of all abstract variables in a pattern. An
%% exception is thrown if <code>Node</code> does not represent a
%% well-formed Core Erlang clause pattern. The order of listing is not
%% defined.
%%
%% @see pat_list_vars/1
%% @see clause_vars/1

-spec pat_vars(cerl()) -> [cerl()].

pat_vars(Node) ->
    pat_vars(Node, []).

pat_vars(Node, Vs) ->
    case type(Node) of
	var ->
	    [Node | Vs];
	literal ->
	    Vs;
	cons ->
	    pat_vars(cons_hd(Node), pat_vars(cons_tl(Node), Vs));
	tuple ->
	    pat_list_vars(tuple_es(Node), Vs);
	map ->
	    pat_list_vars(map_es(Node), Vs);
	map_pair ->
	    %% map_pair_key is not a pattern var, excluded
	    pat_list_vars([map_pair_op(Node),map_pair_val(Node)],Vs);
	binary ->
	    pat_list_vars(binary_segments(Node), Vs);
	bitstr ->
	    %% bitstr_size is not a pattern var, excluded
	    pat_vars(bitstr_val(Node), Vs);
	alias ->
	    pat_vars(alias_pat(Node), [alias_var(Node) | Vs])
    end.


%% @spec pat_list_vars(Patterns::[cerl()]) -> [cerl()]
%%
%% @doc Returns the list of all abstract variables in the given
%% patterns. An exception is thrown if some element in
%% <code>Patterns</code> does not represent a well-formed Core Erlang
%% clause pattern. The order of listing is not defined.
%%
%% @see pat_vars/1
%% @see clause_vars/1

-spec pat_list_vars([cerl()]) -> [cerl()].

pat_list_vars(Ps) ->
    pat_list_vars(Ps, []).

pat_list_vars([P | Ps], Vs) ->
    pat_list_vars(Ps, pat_vars(P, Vs));
pat_list_vars([], Vs) ->
    Vs.


%% ---------------------------------------------------------------------

%% @spec c_alias(Variable::cerl(), Pattern::cerl()) -> cerl()
%%
%% @doc Creates an abstract pattern alias. The result represents
%% "<code><em>Variable</em> = <em>Pattern</em></code>".
%%
%% @see ann_c_alias/3
%% @see update_c_alias/3
%% @see is_c_alias/1
%% @see alias_var/1
%% @see alias_pat/1
%% @see c_clause/3

-spec c_alias(c_var(), cerl()) -> c_alias().

c_alias(Var, Pattern) ->
    #c_alias{var = Var, pat = Pattern}.


%% @spec ann_c_alias(As::[term()], Variable::cerl(),
%%                   Pattern::cerl()) -> cerl()
%% @see c_alias/2

-spec ann_c_alias([term()], c_var(), cerl()) -> c_alias().

ann_c_alias(As, Var, Pattern) ->
    #c_alias{var = Var, pat = Pattern, anno = As}.


%% @spec update_c_alias(Old::cerl(), Variable::cerl(),
%%                      Pattern::cerl()) -> cerl()
%% @see c_alias/2

-spec update_c_alias(c_alias(), cerl(), cerl()) -> c_alias().

update_c_alias(Node, Var, Pattern) ->
    #c_alias{var = Var, pat = Pattern, anno = get_ann(Node)}.


%% @spec is_c_alias(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% pattern alias, otherwise <code>false</code>.
%%
%% @see c_alias/2

-spec is_c_alias(cerl()) -> boolean().

is_c_alias(#c_alias{}) ->
    true;
is_c_alias(_) ->
    false.


%% @spec alias_var(cerl()) -> cerl()
%%
%% @doc Returns the variable subtree of an abstract pattern alias.
%%
%% @see c_alias/2

-spec alias_var(c_alias()) -> c_var().

alias_var(Node) ->
    Node#c_alias.var.


%% @spec alias_pat(cerl()) -> cerl()
%%
%% @doc Returns the pattern subtree of an abstract pattern alias.
%%
%% @see c_alias/2

-spec alias_pat(c_alias()) -> cerl().

alias_pat(Node) ->
    Node#c_alias.pat.


%% ---------------------------------------------------------------------

%% @spec c_receive(Clauses::[cerl()]) -> cerl()
%% @equiv c_receive(Clauses, c_atom(infinity), c_atom(true))
%% @see c_atom/1

-spec c_receive([cerl()]) -> c_receive().

c_receive(Clauses) ->
    c_receive(Clauses, c_atom(infinity), c_atom(true)).


%% @spec c_receive(Clauses::[cerl()], Timeout::cerl(),
%%                 Action::cerl()) -> cerl()
%%
%% @doc Creates an abstract receive-expression. If
%% <code>Clauses</code> is <code>[C1, ..., Cn]</code>, the result
%% represents "<code>receive <em>C1</em> ... <em>Cn</em> after
%% <em>Timeout</em> -> <em>Action</em> end</code>".
%%
%% @see c_receive/1
%% @see ann_c_receive/4
%% @see update_c_receive/4
%% @see is_c_receive/1
%% @see receive_clauses/1
%% @see receive_timeout/1
%% @see receive_action/1

-spec c_receive([cerl()], cerl(), cerl()) -> c_receive().

c_receive(Clauses, Timeout, Action) ->
    #c_receive{clauses = Clauses, timeout = Timeout, action = Action}.


%% @spec ann_c_receive(As::[term()], Clauses::[cerl()]) -> cerl()
%% @equiv ann_c_receive(As, Clauses, c_atom(infinity), c_atom(true))
%% @see c_receive/3
%% @see c_atom/1

-spec ann_c_receive([term()], [cerl()]) -> c_receive().

ann_c_receive(As, Clauses) ->
    ann_c_receive(As, Clauses, c_atom(infinity), c_atom(true)).


%% @spec ann_c_receive(As::[term()], Clauses::[cerl()],
%%                     Timeout::cerl(), Action::cerl()) -> cerl()
%% @see ann_c_receive/2
%% @see c_receive/3

-spec ann_c_receive([term()], [cerl()], cerl(), cerl()) -> c_receive().

ann_c_receive(As, Clauses, Timeout, Action) ->
    #c_receive{clauses = Clauses, timeout = Timeout, action = Action,
	       anno = As}.


%% @spec update_c_receive(Old::cerl(), Clauses::[cerl()],
%%                        Timeout::cerl(), Action::cerl()) -> cerl()
%% @see c_receive/3

-spec update_c_receive(c_receive(), [cerl()], cerl(), cerl()) -> c_receive().

update_c_receive(Node, Clauses, Timeout, Action) ->
    #c_receive{clauses = Clauses, timeout = Timeout, action = Action,
	       anno = get_ann(Node)}.


%% @spec is_c_receive(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% receive-expression, otherwise <code>false</code>.
%%
%% @see c_receive/3

-spec is_c_receive(cerl()) -> boolean().

is_c_receive(#c_receive{}) ->
    true;
is_c_receive(_) ->
    false.


%% @spec receive_clauses(cerl()) -> [cerl()]
%%
%% @doc Returns the list of clause subtrees of an abstract
%% receive-expression.
%%
%% @see c_receive/3

-spec receive_clauses(c_receive()) -> [cerl()].

receive_clauses(Node) ->
    Node#c_receive.clauses.


%% @spec receive_timeout(cerl()) -> cerl()
%%
%% @doc Returns the timeout subtree of an abstract receive-expression.
%%
%% @see c_receive/3

-spec receive_timeout(c_receive()) -> cerl().

receive_timeout(Node) ->
    Node#c_receive.timeout.


%% @spec receive_action(cerl()) -> cerl()
%%
%% @doc Returns the action subtree of an abstract receive-expression.
%%
%% @see c_receive/3

-spec receive_action(c_receive()) -> cerl().

receive_action(Node) ->
    Node#c_receive.action.


%% ---------------------------------------------------------------------

%% @spec c_apply(Operator::cerl(), Arguments::[cerl()]) -> cerl()
%%
%% @doc Creates an abstract function application. If
%% <code>Arguments</code> is <code>[A1, ..., An]</code>, the result
%% represents "<code>apply <em>Operator</em>(<em>A1</em>, ...,
%% <em>An</em>)</code>".
%%
%% @see ann_c_apply/3
%% @see update_c_apply/3
%% @see is_c_apply/1
%% @see apply_op/1
%% @see apply_args/1
%% @see apply_arity/1
%% @see c_call/3
%% @see c_primop/2

-spec c_apply(cerl(), [cerl()]) -> c_apply().

c_apply(Operator, Arguments) ->
    #c_apply{op = Operator, args = Arguments}.


%% @spec ann_c_apply(As::[term()], Operator::cerl(),
%%                   Arguments::[cerl()]) -> cerl()
%% @see c_apply/2

-spec ann_c_apply([term()], cerl(), [cerl()]) -> c_apply().

ann_c_apply(As, Operator, Arguments) ->
    #c_apply{op = Operator, args = Arguments, anno = As}.


%% @spec update_c_apply(Old::cerl(), Operator::cerl(),
%%                      Arguments::[cerl()]) -> cerl()
%% @see c_apply/2

-spec update_c_apply(c_apply(), cerl(), [cerl()]) -> c_apply().

update_c_apply(Node, Operator, Arguments) ->
    #c_apply{op = Operator, args = Arguments, anno = get_ann(Node)}.


%% @spec is_c_apply(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% function application, otherwise <code>false</code>.
%%
%% @see c_apply/2

-spec is_c_apply(cerl()) -> boolean().

is_c_apply(#c_apply{}) ->
    true;
is_c_apply(_) ->
    false.


%% @spec apply_op(cerl()) -> cerl()
%%
%% @doc Returns the operator subtree of an abstract function
%% application.
%%
%% @see c_apply/2

-spec apply_op(c_apply()) -> cerl().

apply_op(Node) ->
    Node#c_apply.op.


%% @spec apply_args(cerl()) -> [cerl()]
%%
%% @doc Returns the list of argument subtrees of an abstract function
%% application.
%%
%% @see c_apply/2
%% @see apply_arity/1

-spec apply_args(c_apply()) -> [cerl()].

apply_args(Node) ->
    Node#c_apply.args.


%% @spec apply_arity(Node::cerl()) -> arity()
%%
%% @doc Returns the number of argument subtrees of an abstract
%% function application.
%%
%% <p>Note: this is equivalent to
%% <code>length(apply_args(Node))</code>, but potentially more
%% efficient.</p>
%%
%% @see c_apply/2
%% @see apply_args/1

-spec apply_arity(c_apply()) -> arity().

apply_arity(Node) ->
    length(apply_args(Node)).


%% ---------------------------------------------------------------------

%% @spec c_call(Module::cerl(), Name::cerl(), Arguments::[cerl()]) ->
%%           cerl()
%%
%% @doc Creates an abstract inter-module call. If
%% <code>Arguments</code> is <code>[A1, ..., An]</code>, the result
%% represents "<code>call <em>Module</em>:<em>Name</em>(<em>A1</em>,
%% ..., <em>An</em>)</code>".
%%
%% @see ann_c_call/4
%% @see update_c_call/4
%% @see is_c_call/1
%% @see call_module/1
%% @see call_name/1
%% @see call_args/1
%% @see call_arity/1
%% @see c_apply/2
%% @see c_primop/2

-spec c_call(cerl(), cerl(), [cerl()]) -> c_call().

c_call(Module, Name, Arguments) ->
    #c_call{module = Module, name = Name, args = Arguments}.


%% @spec ann_c_call(As::[term()], Module::cerl(), Name::cerl(),
%%                  Arguments::[cerl()]) -> cerl()
%% @see c_call/3

-spec ann_c_call([term()], cerl(), cerl(), [cerl()]) -> c_call().

ann_c_call(As, Module, Name, Arguments) ->
    #c_call{module = Module, name = Name, args = Arguments, anno = As}.


%% @spec update_c_call(Old::cerl(), Module::cerl(), Name::cerl(),
%%                  Arguments::[cerl()]) -> cerl()
%% @see c_call/3

-spec update_c_call(cerl(), cerl(), cerl(), [cerl()]) -> c_call().

update_c_call(Node, Module, Name, Arguments) ->
    #c_call{module = Module, name = Name, args = Arguments,
	    anno = get_ann(Node)}.


%% @spec is_c_call(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% inter-module call expression; otherwise <code>false</code>.
%%
%% @see c_call/3

-spec is_c_call(cerl()) -> boolean().

is_c_call(#c_call{}) ->
    true;
is_c_call(_) ->
    false.


%% @spec call_module(cerl()) -> cerl()
%%
%% @doc Returns the module subtree of an abstract inter-module call.
%%
%% @see c_call/3

-spec call_module(c_call()) -> cerl().

call_module(Node) ->
    Node#c_call.module.


%% @spec call_name(cerl()) -> cerl()
%%
%% @doc Returns the name subtree of an abstract inter-module call.
%%
%% @see c_call/3

-spec call_name(c_call()) -> cerl().

call_name(Node) ->
    Node#c_call.name.


%% @spec call_args(cerl()) -> [cerl()]
%%
%% @doc Returns the list of argument subtrees of an abstract
%% inter-module call.
%%
%% @see c_call/3
%% @see call_arity/1

-spec call_args(c_call()) -> [cerl()].

call_args(Node) ->
    Node#c_call.args.


%% @spec call_arity(Node::cerl()) -> arity()
%%
%% @doc Returns the number of argument subtrees of an abstract
%% inter-module call.
%%
%% <p>Note: this is equivalent to
%% <code>length(call_args(Node))</code>, but potentially more
%% efficient.</p>
%%
%% @see c_call/3
%% @see call_args/1

-spec call_arity(c_call()) -> arity().

call_arity(Node) ->
    length(call_args(Node)).


%% ---------------------------------------------------------------------

%% @spec c_primop(Name::cerl(), Arguments::[cerl()]) -> cerl()
%%
%% @doc Creates an abstract primitive operation call. If
%% <code>Arguments</code> is <code>[A1, ..., An]</code>, the result
%% represents "<code>primop <em>Name</em>(<em>A1</em>, ...,
%% <em>An</em>)</code>". <code>Name</code> must be an atom literal.
%%
%% @see ann_c_primop/3
%% @see update_c_primop/3
%% @see is_c_primop/1
%% @see primop_name/1
%% @see primop_args/1
%% @see primop_arity/1
%% @see c_apply/2
%% @see c_call/3

-spec c_primop(cerl(), [cerl()]) -> c_primop().

c_primop(Name, Arguments) ->
    #c_primop{name = Name, args = Arguments}.


%% @spec ann_c_primop(As::[term()], Name::cerl(),
%%                    Arguments::[cerl()]) -> cerl()
%% @see c_primop/2

-spec ann_c_primop([term()], cerl(), [cerl()]) -> c_primop().

ann_c_primop(As, Name, Arguments) ->
    #c_primop{name = Name, args = Arguments, anno = As}.


%% @spec update_c_primop(Old::cerl(), Name::cerl(),
%%                       Arguments::[cerl()]) -> cerl()
%% @see c_primop/2

-spec update_c_primop(cerl(), cerl(), [cerl()]) -> c_primop().

update_c_primop(Node, Name, Arguments) ->
    #c_primop{name = Name, args = Arguments, anno = get_ann(Node)}.


%% @spec is_c_primop(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% primitive operation call, otherwise <code>false</code>.
%%
%% @see c_primop/2

-spec is_c_primop(cerl()) -> boolean().

is_c_primop(#c_primop{}) ->
    true;
is_c_primop(_) ->
    false.


%% @spec primop_name(cerl()) -> cerl()
%%
%% @doc Returns the name subtree of an abstract primitive operation
%% call.
%%
%% @see c_primop/2

-spec primop_name(c_primop()) -> cerl().

primop_name(Node) ->
    Node#c_primop.name.


%% @spec primop_args(cerl()) -> [cerl()]
%%
%% @doc Returns the list of argument subtrees of an abstract primitive
%% operation call.
%%
%% @see c_primop/2
%% @see primop_arity/1

-spec primop_args(c_primop()) -> [cerl()].

primop_args(Node) ->
    Node#c_primop.args.


%% @spec primop_arity(Node::cerl()) -> arity()
%%
%% @doc Returns the number of argument subtrees of an abstract
%% primitive operation call.
%%
%% <p>Note: this is equivalent to
%% <code>length(primop_args(Node))</code>, but potentially more
%% efficient.</p>
%%
%% @see c_primop/2
%% @see primop_args/1

-spec primop_arity(c_primop()) -> arity().

primop_arity(Node) ->
    length(primop_args(Node)).


%% ---------------------------------------------------------------------

%% @spec c_try(Argument::cerl(), Variables::[cerl()], Body::cerl(),
%%             ExceptionVars::[cerl()], Handler::cerl()) -> cerl()
%%
%% @doc Creates an abstract try-expression. If <code>Variables</code> is
%% <code>[V1, ..., Vn]</code> and <code>ExceptionVars</code> is
%% <code>[X1, ..., Xm]</code>, the result represents "<code>try
%% <em>Argument</em> of &lt;<em>V1</em>, ..., <em>Vn</em>&gt; ->
%% <em>Body</em> catch &lt;<em>X1</em>, ..., <em>Xm</em>&gt; ->
%% <em>Handler</em></code>". All the <code>Vi</code> and <code>Xi</code>
%% must have type <code>var</code>.
%%
%% @see ann_c_try/6
%% @see update_c_try/6
%% @see is_c_try/1
%% @see try_arg/1
%% @see try_vars/1
%% @see try_body/1
%% @see c_catch/1

-spec c_try(cerl(), [cerl()], cerl(), [cerl()], cerl()) -> c_try().

c_try(Expr, Vs, Body, Evs, Handler) ->
    #c_try{arg = Expr, vars = Vs, body = Body,
	   evars = Evs, handler = Handler}.


%% @spec ann_c_try(As::[term()], Expression::cerl(),
%%                 Variables::[cerl()], Body::cerl(),
%%                 EVars::[cerl()], Handler::cerl()) -> cerl()
%% @see c_try/5

-spec ann_c_try([term()], cerl(), [cerl()], cerl(), [cerl()], cerl()) ->
        c_try().

ann_c_try(As, Expr, Vs, Body, Evs, Handler) ->
    #c_try{arg = Expr, vars = Vs, body = Body,
	   evars = Evs, handler = Handler, anno = As}.


%% @spec update_c_try(Old::cerl(), Expression::cerl(),
%%                    Variables::[cerl()], Body::cerl(),
%%                    EVars::[cerl()], Handler::cerl()) -> cerl()
%% @see c_try/5

-spec update_c_try(c_try(), cerl(), [cerl()], cerl(), [cerl()], cerl()) ->
        c_try().

update_c_try(Node, Expr, Vs, Body, Evs, Handler) ->
    #c_try{arg = Expr, vars = Vs, body = Body,
	   evars = Evs, handler = Handler, anno = get_ann(Node)}.


%% @spec is_c_try(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% try-expression, otherwise <code>false</code>.
%%
%% @see c_try/5

-spec is_c_try(cerl()) -> boolean().

is_c_try(#c_try{}) ->
    true;
is_c_try(_) ->
    false.


%% @spec try_arg(cerl()) -> cerl()
%%
%% @doc Returns the expression subtree of an abstract try-expression.
%%
%% @see c_try/5

-spec try_arg(c_try()) -> cerl().

try_arg(Node) ->
    Node#c_try.arg.


%% @spec try_vars(cerl()) -> [cerl()]
%%
%% @doc Returns the list of success variable subtrees of an abstract
%% try-expression.
%%
%% @see c_try/5

-spec try_vars(c_try()) -> [cerl()].

try_vars(Node) ->
    Node#c_try.vars.


%% @spec try_body(cerl()) -> cerl()
%%
%% @doc Returns the success body subtree of an abstract try-expression.
%%
%% @see c_try/5

-spec try_body(c_try()) -> cerl().

try_body(Node) ->
    Node#c_try.body.


%% @spec try_evars(cerl()) -> [cerl()]
%%
%% @doc Returns the list of exception variable subtrees of an abstract
%% try-expression.
%%
%% @see c_try/5

-spec try_evars(c_try()) -> [cerl()].

try_evars(Node) ->
    Node#c_try.evars.


%% @spec try_handler(cerl()) -> cerl()
%%
%% @doc Returns the exception body subtree of an abstract
%% try-expression.
%%
%% @see c_try/5

-spec try_handler(c_try()) -> cerl().

try_handler(Node) ->
    Node#c_try.handler.


%% ---------------------------------------------------------------------

%% @spec c_catch(Body::cerl()) -> cerl()
%%
%% @doc Creates an abstract catch-expression. The result represents
%% "<code>catch <em>Body</em></code>".
%%
%% <p>Note: catch-expressions can be rewritten as try-expressions, and
%% will eventually be removed from Core Erlang.</p>
%%
%% @see ann_c_catch/2
%% @see update_c_catch/2
%% @see is_c_catch/1
%% @see catch_body/1
%% @see c_try/5

-spec c_catch(cerl()) -> c_catch().

c_catch(Body) ->
    #c_catch{body = Body}.


%% @spec ann_c_catch(As::[term()], Body::cerl()) -> cerl()
%% @see c_catch/1

-spec ann_c_catch([term()], cerl()) -> c_catch().

ann_c_catch(As, Body) ->
    #c_catch{body = Body, anno = As}.


%% @spec update_c_catch(Old::cerl(), Body::cerl()) -> cerl()
%% @see c_catch/1

-spec update_c_catch(c_catch(), cerl()) -> c_catch().

update_c_catch(Node, Body) ->
    #c_catch{body = Body, anno = get_ann(Node)}.


%% @spec is_c_catch(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> is an abstract
%% catch-expression, otherwise <code>false</code>.
%%
%% @see c_catch/1

-spec is_c_catch(cerl()) -> boolean().

is_c_catch(#c_catch{}) ->
    true;
is_c_catch(_) ->
    false.


%% @spec catch_body(Node::cerl()) -> cerl()
%%
%% @doc Returns the body subtree of an abstract catch-expression.
%%
%% @see c_catch/1

-spec catch_body(c_catch()) -> cerl().

catch_body(Node) ->
    Node#c_catch.body.


%% ---------------------------------------------------------------------

%% @spec to_records(Tree::cerl()) -> record(record_types())
%%
%% @doc Translates an abstract syntax tree to a corresponding explicit
%% record representation. The records are defined in the file
%% "<code>cerl.hrl</code>".
%%
%% @see type/1
%% @see from_records/1

-spec to_records(cerl()) -> cerl().

to_records(Node) ->
    Node.

%% @spec from_records(Tree::record(record_types())) -> cerl()
%%
%%     record_types() = c_alias | c_apply | c_call | c_case | c_catch |
%%                      c_clause | c_cons | c_fun | c_let |
%%                      c_letrec | c_lit | c_module | c_primop |
%%                      c_receive | c_seq | c_try | c_tuple |
%%                      c_values | c_var
%%
%% @doc Translates an explicit record representation to a
%% corresponding abstract syntax tree.  The records are defined in the
%% file "<code>core_parse.hrl</code>".
%%
%% @see type/1
%% @see to_records/1

-spec from_records(cerl()) -> cerl().

from_records(Node) ->
    Node.


%% ---------------------------------------------------------------------

%% @spec is_data(Node::cerl()) -> boolean()
%%
%% @doc Returns <code>true</code> if <code>Node</code> represents a
%% data constructor, otherwise <code>false</code>. Data constructors
%% are cons cells, tuples, and atomic literals.
%%
%% @see data_type/1
%% @see data_es/1
%% @see data_arity/1

-spec is_data(cerl()) -> boolean().

is_data(#c_literal{}) ->
    true;
is_data(#c_cons{}) ->
    true;
is_data(#c_tuple{}) ->
    true;
is_data(_) ->
    false.


%% @spec data_type(Node::cerl()) -> dtype()
%%
%%     dtype() = cons | tuple | {atomic, Value}
%%     Value = integer() | float() | atom() | []
%%
%% @doc Returns a type descriptor for a data constructor
%% node. (Cf. <code>is_data/1</code>.) This is mainly useful for
%% comparing types and for constructing new nodes of the same type
%% (cf. <code>make_data/2</code>). If <code>Node</code> represents an
%% integer, floating-point number, atom or empty list, the result is
%% <code>{atomic, Value}</code>, where <code>Value</code> is the value
%% of <code>concrete(Node)</code>, otherwise the result is either
%% <code>cons</code> or <code>tuple</code>.
%%
%% <p>Type descriptors can be compared for equality or order (in the
%% Erlang term order), but remember that floating-point values should
%% in general never be tested for equality.</p>
%%
%% @see is_data/1
%% @see make_data/2
%% @see type/1
%% @see concrete/1

-type value() :: integer() | float() | atom() | [].
-type dtype() :: 'cons' | 'tuple' | {'atomic', value()}.
-type c_lct() :: c_literal() | c_cons() | c_tuple().

-spec data_type(c_lct()) -> dtype().

data_type(#c_literal{val = V}) ->
    case V of
	[_ | _] ->
	    cons;
	_ when is_tuple(V) ->
	    tuple;
	_ ->
	    {atomic, V}
    end;
data_type(#c_cons{}) ->
    cons;
data_type(#c_tuple{}) ->
    tuple.

%% @spec data_es(Node::cerl()) -> [cerl()]
%%
%% @doc Returns the list of subtrees of a data constructor node. If
%% the arity of the constructor is zero, the result is the empty list.
%%
%% <p>Note: if <code>data_type(Node)</code> is <code>cons</code>, the
%% number of subtrees is exactly two. If <code>data_type(Node)</code>
%% is <code>{atomic, Value}</code>, the number of subtrees is
%% zero.</p>
%%
%% @see is_data/1
%% @see data_type/1
%% @see data_arity/1
%% @see make_data/2

-spec data_es(c_lct()) -> [cerl()].

data_es(#c_literal{val = V}) ->
    case V of
	[Head | Tail] ->
	    [#c_literal{val = Head}, #c_literal{val = Tail}];
	_ when is_tuple(V) ->
	    make_lit_list(tuple_to_list(V));
	_ ->
	    []
    end;
data_es(#c_cons{hd = H, tl = T}) ->
    [H, T];
data_es(#c_tuple{es = Es}) ->
    Es.

%% @spec data_arity(Node::cerl()) -> integer()
%%
%% @doc Returns the number of subtrees of a data constructor
%% node. This is equivalent to <code>length(data_es(Node))</code>, but
%% potentially more efficient.
%%
%% @see is_data/1
%% @see data_es/1

-spec data_arity(c_lct()) -> non_neg_integer().

data_arity(#c_literal{val = V}) ->
    case V of
	[_ | _] ->
	    2;
	_ when is_tuple(V) ->
	    tuple_size(V);
	_ ->
	    0
    end;
data_arity(#c_cons{}) ->
    2;
data_arity(#c_tuple{es = Es}) ->
    length(Es).


%% @spec make_data(Type::dtype(), Elements::[cerl()]) -> cerl()
%%
%% @doc Creates a data constructor node with the specified type and
%% subtrees. (Cf. <code>data_type/1</code>.)  An exception is thrown
%% if the length of <code>Elements</code> is invalid for the given
%% <code>Type</code>; see <code>data_es/1</code> for arity constraints
%% on constructor types.
%%
%% @see data_type/1
%% @see data_es/1
%% @see ann_make_data/3
%% @see update_data/3
%% @see make_data_skel/2

-spec make_data(dtype(), [cerl()]) -> c_lct().

make_data(CType, Es) ->
    ann_make_data([], CType, Es).


%% @spec ann_make_data(As::[term()], Type::dtype(),
%%                     Elements::[cerl()]) -> cerl()
%% @see make_data/2

-spec ann_make_data([term()], dtype(), [cerl()]) -> c_lct().

ann_make_data(As, {atomic, V}, []) -> #c_literal{val = V, anno = As};
ann_make_data(As, cons, [H, T]) -> ann_c_cons(As, H, T);
ann_make_data(As, tuple, Es) -> ann_c_tuple(As, Es).

%% @spec update_data(Old::cerl(), Type::dtype(),
%%                   Elements::[cerl()]) -> cerl()
%% @see make_data/2

-spec update_data(cerl(), dtype(), [cerl()]) -> c_lct().

update_data(Node, CType, Es) ->
    ann_make_data(get_ann(Node), CType, Es).


%% @spec make_data_skel(Type::dtype(), Elements::[cerl()]) -> cerl()
%%
%% @doc Like <code>make_data/2</code>, but analogous to
%% <code>c_tuple_skel/1</code> and <code>c_cons_skel/2</code>.
%%
%% @see ann_make_data_skel/3
%% @see update_data_skel/3
%% @see make_data/2
%% @see c_tuple_skel/1
%% @see c_cons_skel/2

-spec make_data_skel(dtype(), [cerl()]) -> c_lct().

make_data_skel(CType, Es) ->
    ann_make_data_skel([], CType, Es).


%% @spec ann_make_data_skel(As::[term()], Type::dtype(),
%%                          Elements::[cerl()]) -> cerl()
%% @see make_data_skel/2

-spec ann_make_data_skel([term()], dtype(), [cerl()]) -> c_lct().

ann_make_data_skel(As, {atomic, V}, []) -> #c_literal{val = V, anno = As};
ann_make_data_skel(As, cons, [H, T]) -> ann_c_cons_skel(As, H, T);
ann_make_data_skel(As, tuple, Es) -> ann_c_tuple_skel(As, Es).


%% @spec update_data_skel(Old::cerl(), Type::dtype(),
%%                        Elements::[cerl()]) -> cerl()
%% @see make_data_skel/2

-spec update_data_skel(cerl(), dtype(), [cerl()]) -> c_lct().

update_data_skel(Node, CType, Es) ->
    ann_make_data_skel(get_ann(Node), CType, Es).


%% ---------------------------------------------------------------------

%% @spec subtrees(Node::cerl()) -> [[cerl()]]
%%
%% @doc Returns the grouped list of all subtrees of a node. If
%% <code>Node</code> is a leaf node (cf. <code>is_leaf/1</code>), this
%% is the empty list, otherwise the result is always a nonempty list,
%% containing the lists of subtrees of <code>Node</code>, in
%% left-to-right order as they occur in the printed program text, and
%% grouped by category. Often, each group contains only a single
%% subtree.
%%
%% <p>Depending on the type of <code>Node</code>, the size of some
%% groups may be variable (e.g., the group consisting of all the
%% elements of a tuple), while others always contain the same number
%% of elements - usually exactly one (e.g., the group containing the
%% argument expression of a case-expression). Note, however, that the
%% exact structure of the returned list (for a given node type) should
%% in general not be depended upon, since it might be subject to
%% change without notice.</p>
%%
%% <p>The function <code>subtrees/1</code> and the constructor functions
%% <code>make_tree/2</code> and <code>update_tree/2</code> can be a
%% great help if one wants to traverse a syntax tree, visiting all its
%% subtrees, but treat nodes of the tree in a uniform way in most or all
%% cases. Using these functions makes this simple, and also assures that
%% your code is not overly sensitive to extensions of the syntax tree
%% data type, because any node types not explicitly handled by your code
%% can be left to a default case.</p>
%%
%% <p>For example:
%% <pre>
%%   postorder(F, Tree) ->
%%       F(case subtrees(Tree) of
%%           [] -> Tree;
%%           List -> update_tree(Tree,
%%                               [[postorder(F, Subtree)
%%                                 || Subtree &lt;- Group]
%%                                || Group &lt;- List])
%%         end).
%% </pre>
%% maps the function <code>F</code> on <code>Tree</code> and all its
%% subtrees, doing a post-order traversal of the syntax tree. (Note
%% the use of <code>update_tree/2</code> to preserve annotations.) For
%% a simple function like:
%% <pre>
%%   f(Node) ->
%%       case type(Node) of
%%           atom -> atom("a_" ++ atom_name(Node));
%%           _ -> Node
%%       end.
%% </pre>
%% the call <code>postorder(fun f/1, Tree)</code> will yield a new
%% representation of <code>Tree</code> in which all atom names have
%% been extended with the prefix "a_", but nothing else (including
%% annotations) has been changed.</p>
%%
%% @see is_leaf/1
%% @see make_tree/2
%% @see update_tree/2

-spec subtrees(cerl()) -> [[cerl()]].

subtrees(T) ->
    case is_leaf(T) of
	true ->
	    [];
	false ->
	    case type(T) of
		values ->
		    [values_es(T)];
		binary ->
		    [binary_segments(T)];
		bitstr ->
		    [[bitstr_val(T)], [bitstr_size(T)],
		     [bitstr_unit(T)], [bitstr_type(T)],
		     [bitstr_flags(T)]];
		cons ->
		    [[cons_hd(T)], [cons_tl(T)]];
		tuple ->
		    [tuple_es(T)];
		map ->
		    [map_es(T)];
		map_pair ->
		    [[map_pair_op(T)],[map_pair_key(T)],[map_pair_val(T)]];
		'let' ->
		    [let_vars(T), [let_arg(T)], [let_body(T)]];
		seq ->
		    [[seq_arg(T)], [seq_body(T)]];
		apply ->
		    [[apply_op(T)], apply_args(T)];
		call ->
		    [[call_module(T)], [call_name(T)],
		     call_args(T)];
		primop ->
		    [[primop_name(T)], primop_args(T)];
		'case' ->
		    [[case_arg(T)], case_clauses(T)];
		clause ->
		    [clause_pats(T), [clause_guard(T)],
		     [clause_body(T)]];
		alias ->
		    [[alias_var(T)], [alias_pat(T)]];
		'fun' ->
		    [fun_vars(T), [fun_body(T)]];
		'receive' ->
		    [receive_clauses(T), [receive_timeout(T)],
		     [receive_action(T)]];
		'try' ->
		    [[try_arg(T)], try_vars(T), [try_body(T)],
		     try_evars(T), [try_handler(T)]];
		'catch' ->
		    [[catch_body(T)]];
		letrec ->
		    Es = unfold_tuples(letrec_defs(T)),
		    [Es, [letrec_body(T)]];
		module ->
		    As = unfold_tuples(module_attrs(T)),
		    Es = unfold_tuples(module_defs(T)),
		    [[module_name(T)], module_exports(T), As, Es]
	    end
    end.


%% @spec update_tree(Old::cerl(), Groups::[[cerl()]]) -> cerl()
%%
%% @doc Creates a syntax tree with the given subtrees, and the same
%% type and annotations as the <code>Old</code> node. This is
%% equivalent to <code>ann_make_tree(get_ann(Node), type(Node),
%% Groups)</code>, but potentially more efficient.
%%
%% @see update_tree/3
%% @see ann_make_tree/3
%% @see get_ann/1
%% @see type/1

-spec update_tree(cerl(), [[cerl()],...]) -> cerl().

update_tree(Node, Gs) ->
    ann_make_tree(get_ann(Node), type(Node), Gs).


%% @spec update_tree(Old::cerl(), Type::ctype(), Groups::[[cerl()]]) ->
%%           cerl()
%%
%% @doc Creates a syntax tree with the given type and subtrees, and
%% the same annotations as the <code>Old</code> node. This is
%% equivalent to <code>ann_make_tree(get_ann(Node), Type,
%% Groups)</code>, but potentially more efficient.
%%
%% @see update_tree/2
%% @see ann_make_tree/3
%% @see get_ann/1

-spec update_tree(cerl(), ctype(), [[cerl()],...]) -> cerl().

update_tree(Node, Type, Gs) ->
    ann_make_tree(get_ann(Node), Type, Gs).


%% @spec make_tree(Type::ctype(), Groups::[[cerl()]]) -> cerl()
%%
%% @doc Creates a syntax tree with the given type and subtrees.
%% <code>Type</code> must be a node type name
%% (cf. <code>type/1</code>) that does not denote a leaf node type
%% (cf. <code>is_leaf/1</code>).  <code>Groups</code> must be a
%% <em>nonempty</em> list of groups of syntax trees, representing the
%% subtrees of a node of the given type, in left-to-right order as
%% they would occur in the printed program text, grouped by category
%% as done by <code>subtrees/1</code>.
%%
%% <p>The result of <code>ann_make_tree(get_ann(Node), type(Node),
%% subtrees(Node))</code> (cf. <code>update_tree/2</code>) represents
%% the same source code text as the original <code>Node</code>,
%% assuming that <code>subtrees(Node)</code> yields a nonempty
%% list. However, it does not necessarily have the exact same data
%% representation as <code>Node</code>.</p>
%%
%% @see ann_make_tree/3
%% @see type/1
%% @see is_leaf/1
%% @see subtrees/1
%% @see update_tree/2

-spec make_tree(ctype(), [[cerl()],...]) -> cerl().

make_tree(Type, Gs) ->
    ann_make_tree([], Type, Gs).


%% @spec ann_make_tree(As::[term()], Type::ctype(),
%%                     Groups::[[cerl()]]) -> cerl()
%%
%% @doc Creates a syntax tree with the given annotations, type and
%% subtrees. See <code>make_tree/2</code> for details.
%%
%% @see make_tree/2

-spec ann_make_tree([term()], ctype(), [[cerl()],...]) -> cerl().

ann_make_tree(As, values, [Es]) -> ann_c_values(As, Es);
ann_make_tree(As, binary, [Ss]) -> ann_c_binary(As, Ss);
ann_make_tree(As, bitstr, [[V],[S],[U],[T],[Fs]]) ->
    ann_c_bitstr(As, V, S, U, T, Fs);
ann_make_tree(As, cons, [[H], [T]]) -> ann_c_cons(As, H, T);
ann_make_tree(As, tuple, [Es]) -> ann_c_tuple(As, Es);
ann_make_tree(As, map, [Es]) -> ann_c_map(As, Es);
ann_make_tree(As, map, [[A], Es]) -> ann_c_map(As, A, Es);
ann_make_tree(As, map_pair, [[Op], [K], [V]]) -> ann_c_map_pair(As, Op, K, V);
ann_make_tree(As, 'let', [Vs, [A], [B]]) -> ann_c_let(As, Vs, A, B);
ann_make_tree(As, seq, [[A], [B]]) -> ann_c_seq(As, A, B);
ann_make_tree(As, apply, [[Op], Es]) -> ann_c_apply(As, Op, Es);
ann_make_tree(As, call, [[M], [N], Es]) -> ann_c_call(As, M, N, Es);
ann_make_tree(As, primop, [[N], Es]) -> ann_c_primop(As, N, Es);
ann_make_tree(As, 'case', [[A], Cs]) -> ann_c_case(As, A, Cs);
ann_make_tree(As, clause, [Ps, [G], [B]]) -> ann_c_clause(As, Ps, G, B);
ann_make_tree(As, alias, [[V], [P]]) -> ann_c_alias(As, V, P);
ann_make_tree(As, 'fun', [Vs, [B]]) -> ann_c_fun(As, Vs, B);
ann_make_tree(As, 'receive', [Cs, [T], [A]]) ->
    ann_c_receive(As, Cs, T, A);
ann_make_tree(As, 'try', [[E], Vs, [B], Evs, [H]]) ->
    ann_c_try(As, E, Vs, B, Evs, H);
ann_make_tree(As, 'catch', [[B]]) -> ann_c_catch(As, B);
ann_make_tree(As, letrec, [Es, [B]]) ->
    ann_c_letrec(As, fold_tuples(Es), B);
ann_make_tree(As, module, [[N], Xs, Es, Ds]) ->
    ann_c_module(As, N, Xs, fold_tuples(Es), fold_tuples(Ds)).


%% ---------------------------------------------------------------------

%% @spec meta(Tree::cerl()) -> cerl()
%%
%% @doc Creates a meta-representation of a syntax tree. The result
%% represents an Erlang expression "<code><em>MetaTree</em></code>"
%% which, if evaluated, will yield a new syntax tree representing the
%% same source code text as <code>Tree</code> (although the actual
%% data representation may be different). The expression represented
%% by <code>MetaTree</code> is <em>implementation independent</em>
%% with regard to the data structures used by the abstract syntax tree
%% implementation.
%%
%% <p>Any node in <code>Tree</code> whose node type is
%% <code>var</code> (cf. <code>type/1</code>), and whose list of
%% annotations (cf. <code>get_ann/1</code>) contains the atom
%% <code>meta_var</code>, will remain unchanged in the resulting tree,
%% except that exactly one occurrence of <code>meta_var</code> is
%% removed from its annotation list.</p>
%%
%% <p>The main use of the function <code>meta/1</code> is to transform
%% a data structure <code>Tree</code>, which represents a piece of
%% program code, into a form that is <em>representation independent
%% when printed</em>. E.g., suppose <code>Tree</code> represents a
%% variable named "V". Then (assuming a function <code>print/1</code>
%% for printing syntax trees), evaluating
%% <code>print(abstract(Tree))</code> - simply using
%% <code>abstract/1</code> to map the actual data structure onto a
%% syntax tree representation - would output a string that might look
%% something like "<code>{var, ..., 'V'}</code>", which is obviously
%% dependent on the implementation of the abstract syntax trees. This
%% could e.g. be useful for caching a syntax tree in a file. However,
%% in some situations like in a program generator generator (with two
%% "generator"), it may be unacceptable.  Using
%% <code>print(meta(Tree))</code> instead would output a
%% <em>representation independent</em> syntax tree generating
%% expression; in the above case, something like
%% "<code>cerl:c_var('V')</code>".</p>
%%
%% <p>The implementation tries to generate compact code with respect
%% to literals and lists.</p>
%%
%% @see abstract/1
%% @see type/1
%% @see get_ann/1

-spec meta(cerl()) -> cerl().

meta(Node) ->
    %% First of all we check for metavariables:
    case type(Node) of
	var ->
	    case lists:member(meta_var, get_ann(Node)) of
		false ->
		    meta_0(var, Node);
		true ->
		    %% A meta-variable: remove the first found
		    %% 'meta_var' annotation, but otherwise leave
		    %% the node unchanged.
		    set_ann(Node, lists:delete(meta_var, get_ann(Node)))
	    end;
	Type ->
	    meta_0(Type, Node)
    end.

meta_0(Type, Node) ->
    case get_ann(Node) of
	[] ->
	    meta_1(Type, Node);
	As ->
	    meta_call(set_ann, [meta_1(Type, Node), abstract(As)])
    end.

meta_1(literal, Node) ->
    %% We handle atomic literals separately, to get a bit
    %% more compact code. For the rest, we use 'abstract'.
    case concrete(Node) of
	V when is_atom(V) ->
	    meta_call(c_atom, [Node]);
	V when is_integer(V) ->
	    meta_call(c_int, [Node]);
	V when is_float(V) ->
	    meta_call(c_float, [Node]);
	[] ->
	    meta_call(c_nil, []);
	_ ->
	    meta_call(abstract, [Node])
    end;
meta_1(var, Node) ->
    %% A normal variable or function name.
    meta_call(c_var, [abstract(var_name(Node))]);
meta_1(values, Node) ->
    meta_call(c_values,
	      [make_list(meta_list(values_es(Node)))]);
meta_1(binary, Node) ->
    meta_call(c_binary,
	      [make_list(meta_list(binary_segments(Node)))]);
meta_1(bitstr, Node) ->
    meta_call(c_bitstr,
	      [meta(bitstr_val(Node)),
	       meta(bitstr_size(Node)),
	       meta(bitstr_unit(Node)),
	       meta(bitstr_type(Node)),
	       meta(bitstr_flags(Node))]);
meta_1(cons, Node) ->
    %% The list is split up if some sublist has annotatations. If
    %% we get exactly one element, we generate a 'c_cons' call
    %% instead of 'make_list' to reconstruct the node.
    case split_list(Node) of
	{[H], Node1} ->
	    meta_call(c_cons, [meta(H), meta(Node1)]);
	{L, Node1} ->
	    meta_call(make_list,
		      [make_list(meta_list(L)), meta(Node1)])
    end;
meta_1(tuple, Node) ->
    meta_call(c_tuple,
	      [make_list(meta_list(tuple_es(Node)))]);
meta_1('let', Node) ->
    meta_call(c_let,
	      [make_list(meta_list(let_vars(Node))),
	       meta(let_arg(Node)), meta(let_body(Node))]);
meta_1(seq, Node) ->
    meta_call(c_seq,
	      [meta(seq_arg(Node)), meta(seq_body(Node))]);
meta_1(apply, Node) ->
    meta_call(c_apply,
	      [meta(apply_op(Node)),
	       make_list(meta_list(apply_args(Node)))]);
meta_1(call, Node) ->
    meta_call(c_call,
	      [meta(call_module(Node)), meta(call_name(Node)),
	       make_list(meta_list(call_args(Node)))]);
meta_1(primop, Node) ->
    meta_call(c_primop,
	      [meta(primop_name(Node)),
	       make_list(meta_list(primop_args(Node)))]);
meta_1('case', Node) ->
    meta_call(c_case,
	      [meta(case_arg(Node)),
	       make_list(meta_list(case_clauses(Node)))]);
meta_1(clause, Node) ->
    meta_call(c_clause,
	      [make_list(meta_list(clause_pats(Node))),
	       meta(clause_guard(Node)),
	       meta(clause_body(Node))]);
meta_1(alias, Node) ->
    meta_call(c_alias,
	      [meta(alias_var(Node)), meta(alias_pat(Node))]);
meta_1('fun', Node) ->
    meta_call(c_fun,
	      [make_list(meta_list(fun_vars(Node))),
	       meta(fun_body(Node))]);
meta_1('receive', Node) ->
    meta_call(c_receive,
	      [make_list(meta_list(receive_clauses(Node))),
	       meta(receive_timeout(Node)),
	       meta(receive_action(Node))]);
meta_1('try', Node) ->
    meta_call(c_try,
	      [meta(try_arg(Node)),
	       make_list(meta_list(try_vars(Node))),
	       meta(try_body(Node)),
	       make_list(meta_list(try_evars(Node))),
	       meta(try_handler(Node))]);
meta_1('catch', Node) ->
    meta_call(c_catch, [meta(catch_body(Node))]);
meta_1(letrec, Node) ->
    meta_call(c_letrec,
	      [make_list([c_tuple([meta(N), meta(F)])
			  || {N, F} <- letrec_defs(Node)]),
	       meta(letrec_body(Node))]);
meta_1(module, Node) ->
    meta_call(c_module,
	      [meta(module_name(Node)),
	       make_list(meta_list(module_exports(Node))),
	       make_list([c_tuple([meta(A), meta(V)])
			  || {A, V} <- module_attrs(Node)]),
	       make_list([c_tuple([meta(N), meta(F)])
			  || {N, F} <- module_defs(Node)])]).

meta_call(F, As) ->
    c_call(c_atom(?MODULE), c_atom(F), As).

meta_list([T | Ts]) ->
    [meta(T) | meta_list(Ts)];
meta_list([]) ->
    [].

split_list(Node) ->
    split_list(set_ann(Node, []), []).

split_list(Node, L) ->
    A = get_ann(Node),
    case type(Node) of
	cons when A =:= [] ->
	    split_list(cons_tl(Node), [cons_hd(Node) | L]);
	_ ->
	    {lists:reverse(L), Node}
    end.


%% ---------------------------------------------------------------------

%% General utilities

is_lit_list([#c_literal{} | Es]) ->
    is_lit_list(Es);
is_lit_list([_ | _]) ->
    false;
is_lit_list([]) ->
    true.

lit_list_vals([#c_literal{val = V} | Es]) ->
    [V | lit_list_vals(Es)];
lit_list_vals([]) ->
    [].

-spec make_lit_list([_]) -> [#c_literal{}].  % XXX: cerl() instead of _ ?

make_lit_list([V | Vs]) ->
    [#c_literal{val = V} | make_lit_list(Vs)];
make_lit_list([]) ->
    [].

%% The following tests are the same as done by 'io_lib:char_list' and
%% 'io_lib:printable_list', respectively, but for a single character.

is_char_value(V) when V >= $\000, V =< $\377 -> true;
is_char_value(_) -> false.

is_print_char_value(V) when V >= $\040, V =< $\176 -> true;
is_print_char_value(V) when V >= $\240, V =< $\377 -> true;
is_print_char_value(V) when V =:= $\b -> true;
is_print_char_value(V) when V =:= $\d -> true;
is_print_char_value(V) when V =:= $\e -> true;
is_print_char_value(V) when V =:= $\f -> true;
is_print_char_value(V) when V =:= $\n -> true;
is_print_char_value(V) when V =:= $\r -> true;
is_print_char_value(V) when V =:= $\s -> true;
is_print_char_value(V) when V =:= $\t -> true;
is_print_char_value(V) when V =:= $\v -> true;
is_print_char_value(V) when V =:= $\" -> true;
is_print_char_value(V) when V =:= $\' -> true;
is_print_char_value(V) when V =:= $\\ -> true;
is_print_char_value(_) -> false.

is_char_list([V | Vs]) when is_integer(V) ->
    is_char_value(V) andalso is_char_list(Vs);
is_char_list([]) ->
    true;
is_char_list(_) ->
    false.

is_print_char_list([V | Vs]) when is_integer(V) ->
    is_print_char_value(V) andalso is_print_char_list(Vs);
is_print_char_list([]) ->
    true;
is_print_char_list(_) ->
    false.

unfold_tuples([{X, Y} | Ps]) ->
    [X, Y | unfold_tuples(Ps)];
unfold_tuples([]) ->
    [].

fold_tuples([X, Y | Es]) ->
    [{X, Y} | fold_tuples(Es)];
fold_tuples([]) ->
    [].
