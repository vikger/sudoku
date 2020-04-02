-module(sudoku).

-export([start/0, new_game/0, put/3, value/2, values/2, grid/0]).


%% API

start() ->
    Pid = spawn(fun () -> init() end),
    register(sudoku, Pid),
    ok.

new_game() ->
    send(new_game).

put(Row, Col, Value) ->
    send({put, Row, Col, Value}).

value(Row, Col) ->
    send({value, Row, Col}).

values(Row, Col) ->
    send({values, Row, Col}).

grid() ->
    send(grid).


%% Internal functions

init() ->
    self() ! generate_spare,
    waiting(sudoku_logic:exercise(30)).

waiting(Exercise) ->
    receive
        {Pid, new_game} ->
            Pid ! Exercise,
            loop(Exercise);
        generate_spare ->
            waiting(Exercise, sudoku_logic:exercise(30))
    end.

waiting(Exercise, Spare) ->
    receive
        {Pid, new_game} ->
            Pid ! Exercise,
            loop(Exercise, Spare)
    end.

loop({Grid, Solution} = Exercise) ->
    receive
        {Pid, {put, Row, Col, Value}} ->
            case sudoku_logic:is_valid(Grid, Row, Col, Value) of
                true ->
                    NewGrid = sudoku_logic:put(Grid, Row, Col, Value),
                    Pid ! ok,
                    loop({NewGrid, Solution});
                false ->
                    Pid ! invalid,
                    loop(Exercise)
            end;
        {Pid, {value, Row, Col}} ->
            Pid ! sudoku_logic:get(Solution, Row, Col),
            loop(Exercise);
        {Pid, {values, Row, Col}} ->
            case sudoku_logic:get(Grid, Row, Col) of
                0 ->
                    Pid ! sudoku_logic:possible_values(Grid, Row, Col);
                _ ->
                    Pid ! []
            end,
            loop(Exercise);
        generate_spare ->
            loop(Exercise, sudoku_logic:exercise(30));
        {Pid, grid} ->
            Pid ! Grid,
            loop(Exercise)
    end.

loop({Grid, Solution} = Exercise, Spare) ->
    receive
        {Pid, {put, Row, Col, Value}} ->
            case sudoku_logic:is_valid(Grid, Row, Col, Value) of
                true ->
                    NewGrid = sudoku_logic:put(Grid, Row, Col, Value),
                    Pid ! ok,
                    loop({NewGrid, Solution}, Spare);
                false ->
                    Pid ! invalid,
                    loop(Exercise, Spare)
            end;
        {Pid, {value, Row, Col}} ->
            Pid ! sudoku_logic:get(Solution, Row, Col),
            loop(Exercise, Spare);
        {Pid, {values, Row, Col}} ->
            case sudoku_logic:get(Grid, Row, Col) of
                0 ->
                    Pid ! sudoku_logic:possible_values(Grid, Row, Col);
                _ ->
                    Pid ! []
            end,
            loop(Exercise, Spare);
        {Pid, new_game} ->
            Pid ! Spare,
            self() ! generate_spare,
            loop(Spare);
        {Pid, grid} ->
            Pid ! Grid,
            loop(Exercise, Spare)
    end.

send(Message) ->
    sudoku ! {self(), Message},
    receive
        Response ->
            Response
    end.
