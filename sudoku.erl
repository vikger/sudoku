-module(sudoku).

-compile(export_all).

get(Grid, Row, Col) ->
    lists:nth(Col, lists:nth(Row, Grid)).

put(Grid, Row, Col, Value) ->
    set(Grid, Row, set(get_row(Grid, Row), Col, Value)).

set([_ | List], 1, Value) ->
    [Value | List];
set([Item | List], N, Value) ->
    [Item | set(List, N - 1, Value)].

shuffle(List) ->
    shuffle(List, length(List)).

shuffle([], _) ->
    [];
shuffle(List, Len) ->
    {Item, Rest} = value(List, rand:uniform(Len)),
    [Item | shuffle(Rest, Len - 1)].

value(List, N) ->
    value(List, N, []).

value([Item | Rest], 1, First) ->
    {Item, lists:reverse(First) ++ Rest};
value([Item | Rest], N, First) ->
    value(Rest, N - 1, [Item | First]).

empty_grid() ->
    lists:duplicate(9, lists:duplicate(9, 0)).

check_grid([]) ->
    true;
check_grid([Row | Rows]) ->
    check_row(Row) andalso check_grid(Rows).

check_row([]) ->
    true;
check_row([0 | _]) ->
    false;
check_row([_ | Cols]) ->
    check_row(Cols).

possible_values(Grid, Row, Col) ->
    Values1 = filter(lists:seq(1,9), get_row(Grid, Row)),
    Values2 = filter(Values1, get_col(Grid, Col)),
    filter(Values2, get_square(Grid, Row, Col)).

get_row(Grid, N) ->
    lists:nth(N, Grid).

get_col(Grid, Col) ->
    get_col(Grid, Col, []).

get_col([], _, Values) ->
    Values;
get_col([Row | Rows], Col, Values) ->
    get_col(Rows, Col, [lists:nth(Col, Row) | Values]).

get_square(Grid, Row, Col) ->
    [get(Grid, R, C) || R <- square_range(Row), C <- square_range(Col)].

filter(List, []) ->
    List;
filter(List, [Value | Values]) ->
    filter(lists:delete(Value, List), Values).

square_range(1) ->
    [1, 2, 3];
square_range(2) ->
    [1, 2, 3];
square_range(3) ->
    [1, 2, 3];
square_range(4) ->
    [4, 5, 6];
square_range(5) ->
    [4, 5, 6];
square_range(6) ->
    [4, 5, 6];
square_range(7) ->
    [7, 8, 9];
square_range(8) ->
    [7, 8, 9];
square_range(9) ->
    [7, 8, 9].

solve_grid(Grid) ->
    check(Grid, empty(Grid), []).

check(Grid, [{Row, Col} | Empty], Solutions) ->
    solve({Row, Col, possible_values(Grid, Row, Col), Grid}, Empty, Solutions);
check(Grid, [], Solutions) ->
    [Grid | Solutions].

solve({Row, Col, [Value | Values], Grid}, Empty, Solutions) ->
    NewSolutions = check(put(Grid, Row, Col, Value), Empty, Solutions),
    solve({Row, Col, Values, Grid}, Empty, NewSolutions);
solve({_, _, [], _}, _, Solutions) ->
    Solutions.

empty(Grid) ->
    empty(Grid, 1, []).

empty([], _, Empty) ->
    lists:reverse(Empty);
empty([Row | Rows], N, Empty) ->
    empty(Rows, N + 1, empty_row(Row, N, 1, []) ++ Empty).

empty_row([0 | Cols], RowNum, ColNum, Empty) ->
    empty_row(Cols, RowNum, ColNum + 1, [{RowNum, ColNum} | Empty]);
empty_row([_ | Cols], RowNum, ColNum, Empty) ->
    empty_row(Cols, RowNum, ColNum + 1, Empty);
empty_row([], _, _, Empty) ->
    Empty.

test_grid() ->
    [[5,3,0,0,7,0,0,0,0],
     [6,0,0,1,9,5,0,0,0],
     [0,9,8,0,0,0,0,6,0],
     [8,0,0,0,6,0,0,0,3],
     [4,0,0,8,0,3,0,0,1],
     [7,0,0,0,2,0,0,0,6],
     [0,6,0,0,0,0,2,8,0],
     [0,0,0,4,1,9,0,0,5],
     [0,0,0,0,8,0,0,7,9]].
