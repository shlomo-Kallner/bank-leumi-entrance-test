
from functools import cache
from typing import Any

from parglare import Parser, Grammar
from typer import Typer


def getExprGrammerDef() -> str:
    grammar = r"""
E: E '+' E  {left, 1}
 | E '-' E  {left, 1}
 | E '*' E  {left, 2}
 | E '/' E  {left, 2}
 | E '%' E  {left, 2}
 | E '^' E  {right, 3}
 | '(' E ')'
 | number;

terminals
number: /\d+(\.\d+)?/;
"""
    return grammar

@cache
def getGrammarActionsDef() -> dict:
    actions = {
        "E": [lambda _, n: n[0] + n[2],
            lambda _, n: n[0] - n[2],
            lambda _, n: n[0] * n[2],
            lambda _, n: n[0] / n[2],
            lambda _, n: n[0] % n[2],
            lambda _, n: n[0] ** n[2],
            lambda _, n: n[1],
            lambda _, n: n[0]],
        "number": lambda _, value: float(value),
    }
    return actions

@cache
def genGrammar(**kwargs: Any) -> Grammar:
    grammarText = getExprGrammerDef()
    grammarRes = Grammar.from_string(
        grammarText,
        **kwargs
    )
    return grammarRes

@cache
def genParser(*, debug:bool = False, grammarKwargs: dict = {}, **kwargs: Any) -> Parser:
    g = genGrammar(**grammarKwargs)
    actions = getGrammarActionsDef()
    parser = Parser(g, debug=debug, actions=actions, **kwargs)
    return parser


def calculate(expr: str, *, debug:bool = False) -> float:
    try:
        parser = genParser(debug=debug)

        res = parser.parse(expr)

        return res

    except Exception:
        raise


def genCLIMain() -> Typer:
    from typer import Argument, Option, Exit
    from rich import print as pprint, print_json


    app = Typer(name="Simple Expression Calculator")

    @app.command()
    def main(expr: str = Argument(...), debug: bool = Option(False)):
        try:
            res = calculate(expr, debug=debug)
            pprint(f"{expr=}\nexpr = [bold green]{res}[/bold green] :grinning:")

        except Exception as e:
            pprint(f":no_entry: Error! [yellow]`{expr=}`[/yellow] had an error :grimacing: :\n {str(e)}")
            raise Exit(code=1) from e
        
    return app()
