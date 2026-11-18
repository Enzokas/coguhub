from __future__ import annotations

import json
import re
import ssl
import sys
import urllib.request
from collections import OrderedDict
from pathlib import Path

API_URL = "https://docs.sunc.io/api/jumbo.json"

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "Definitions" / "sUNC.d.luau"

TIMEOUT = 30
USER_AGENT = "sUNC-TypeGenerator/3.0"

TYPE_PATTERN = re.compile(r"^(?:export\s+)?type\s+([A-Za-z_]\w*)\s*=")

FUNCTION_PATTERN = re.compile(
    r"^(?:declare\s+)?function\s+"
    r"([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)"
)

DECLARE_PATTERN = re.compile(r"^declare\s+([A-Za-z_]\w*)\s*:")

QUALIFIED_FUNCTION_PATTERN = re.compile(
    r"^(?:declare\s+)?function\s+"
    r"([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)(.*)$",
    re.DOTALL,
)

SUPPLEMENTAL_TYPES = {
    "FunctionFilterOptions": """export type FunctionFilterOptions = {
    Name: string?,
    IgnoreExecutor: boolean?,
    Hash: string?,
    Constants: { any }?,
    Upvalues: { any }?
}""",
    "TableFilterOptions": """export type TableFilterOptions = {
    Keys: { [any]: any }?,
    Values: { [any]: any }?,
    KeyValuePairs: { [any]: any }?,
    Metatable: { [any]: any }?
}""",
    "Connection": """export type Connection = {
    Enabled: boolean,
    ForeignState: boolean,
    LuaConnection: boolean,
    Function: ((...any) -> (...any))?,
    Thread: thread?,

    Fire: (self: Connection, ...any) -> (),
    Defer: (self: Connection, ...any) -> (),
    Disconnect: (self: Connection) -> (),
    Disable: (self: Connection) -> (),
    Enable: (self: Connection) -> ()
}""",
    "Drawing": """export type Drawing = {
    Visible: boolean,
    ZIndex: number,
    Transparency: number,
    Color: Color3,
    __OBJECT_EXISTS: boolean,

    Destroy: (self: Drawing) -> ()
}""",
}


def fetch_metadata() -> dict:
    """Download the sUNC API metadata."""

    print("Fetching sUNC metadata...")

    request = urllib.request.Request(
        API_URL,
        headers={
            "User-Agent": USER_AGENT,
            "Accept": "application/json",
        },
    )

    context = ssl.create_default_context()

    with urllib.request.urlopen(
        request,
        timeout=TIMEOUT,
        context=context,
    ) as response:
        if response.status != 200:
            raise RuntimeError(f"HTTP request failed: {response.status}")

        data = json.loads(response.read().decode("utf-8"))

    if not isinstance(data, dict):
        raise ValueError("Unexpected API response format.")

    return data


def collect_signatures(
    data: dict,
) -> list[tuple[str, str]]:
    """Recursively collect signature strings from the API."""

    signatures = []

    def walk(value, path=""):
        if isinstance(value, dict):
            signature = value.get("signature")

            if isinstance(signature, str) and signature.strip():
                title = value.get("title", path)
                signatures.append((str(title), signature))

            for key, child in value.items():
                if key == "signature":
                    continue

                child_path = f"{path}.{key}" if path else str(key)

                walk(child, child_path)

        elif isinstance(value, list):
            for index, child in enumerate(value):
                walk(child, f"{path}[{index}]")

    walk(data)

    return signatures


def split_declarations(signature: str) -> list[str]:
    """Split a signature into top-level declarations."""

    declarations = []
    current = []

    start_patterns = (
        TYPE_PATTERN,
        FUNCTION_PATTERN,
        DECLARE_PATTERN,
    )

    for line in signature.strip().splitlines():
        stripped = line.strip()

        if not stripped:
            if current:
                current.append("")
            continue

        is_start = not line[:1].isspace() and any(
            pattern.match(stripped) for pattern in start_patterns
        )

        if is_start:
            if current:
                declarations.append("\n".join(current).strip())

            current = [stripped]

        elif current:
            current.append(line.rstrip())

        else:
            raise ValueError(f"Unrecognized declaration:\n{signature}")

    if current:
        declarations.append("\n".join(current).strip())

    return declarations


def normalize_declaration(declaration: str) -> str:
    """Convert API declarations into Luau definition syntax."""

    lines = declaration.splitlines()

    if not lines:
        raise ValueError("Empty declaration.")

    first = lines[0].strip()

    if re.match(r"^type\s+", first):
        first = "export " + first

    if first.startswith("function "):
        first = "declare " + first

    lines[0] = first

    declaration = "\n".join(lines).strip()

    declaration = re.sub(
        r"(:\s*)\(\.\.\.any\)\s*->\s*\(\.\.\.any\)\s*\|\s*nil$",
        r"\1((...any) -> (...any))?",
        declaration,
    )

    return declaration


def find_matching_parenthesis(
    source: str,
    opening: int,
) -> int:
    """Find the closing parenthesis, ignoring quoted strings."""

    depth = 0
    quote = None
    escaped = False

    for index in range(opening, len(source)):
        char = source[index]

        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None

            continue

        if char in ('"', "'"):
            quote = char
        elif char == "(":
            depth += 1
        elif char == ")":
            depth -= 1

            if depth == 0:
                return index

    raise ValueError(f"Unclosed function parameter list:\n{source}")


def function_to_type(
    declaration: str,
) -> tuple[str, str]:
    """Convert a function declaration into a function type."""

    match = QUALIFIED_FUNCTION_PATTERN.match(declaration)

    if not match:
        raise ValueError(f"Invalid function declaration:\n{declaration}")

    name, tail = match.groups()

    opening = tail.find("(")

    if opening == -1:
        raise ValueError(f"Missing parameter list:\n{declaration}")

    generic = tail[:opening].strip()

    closing = find_matching_parenthesis(
        tail,
        opening,
    )

    parameters = tail[opening : closing + 1]
    return_type = tail[closing + 1 :].strip()

    if return_type:
        if not return_type.startswith(":"):
            raise ValueError(f"Invalid return type:\n{declaration}")

        return_type = return_type[1:].strip()
    else:
        return_type = "()"

    function_type = f"{generic}{parameters} -> {return_type}"

    return name, function_type


def add_type(
    types: OrderedDict,
    declaration: str,
) -> None:
    """Add a type while avoiding duplicate definitions."""

    match = TYPE_PATTERN.match(declaration)

    if not match:
        raise ValueError(f"Invalid type declaration:\n{declaration}")

    name = match.group(1)
    previous = types.get(name)

    if previous is not None:
        if previous != declaration:
            raise ValueError(f"Conflicting type declaration: {name}")

        return

    types[name] = declaration


def add_function(
    functions: OrderedDict,
    name: str,
    declaration: str,
) -> None:
    """Add a global function declaration."""

    key = (name, declaration)
    functions.setdefault(key, declaration)


def add_namespace_function(
    namespaces: OrderedDict,
    name: str,
    function_type: str,
) -> None:
    """Group namespaced functions into a global table."""

    namespace, member = name.split(".", 1)

    members = namespaces.setdefault(
        namespace,
        OrderedDict(),
    )

    overloads = members.setdefault(
        member,
        [],
    )

    if function_type not in overloads:
        overloads.append(function_type)


def render_namespaces(
    namespaces: OrderedDict,
) -> list[str]:
    """Render namespaced functions as global table declarations."""

    output = []

    for namespace, members in namespaces.items():
        output.append(f"declare {namespace}: {{")

        member_lines = []

        for member, overloads in members.items():
            if len(overloads) == 1:
                function_type = overloads[0]
            else:
                function_type = " & ".join(f"({item})" for item in overloads)

            member_lines.append(f"    {member}: {function_type},")

        output.extend(member_lines)
        output.append("}")

    return output


def build_definitions(
    signatures: list[tuple[str, str]],
) -> tuple[str, int, int]:
    """Build the final .d.luau content."""

    types = OrderedDict()
    functions = OrderedDict()
    namespaces = OrderedDict()

    for declaration in SUPPLEMENTAL_TYPES.values():
        add_type(types, declaration)

    for title, signature in signatures:
        for raw_declaration in split_declarations(signature):
            declaration = normalize_declaration(raw_declaration)

            type_match = TYPE_PATTERN.match(declaration)

            if type_match:
                add_type(types, declaration)
                continue

            function_match = FUNCTION_PATTERN.match(declaration)

            if function_match:
                name = function_match.group(1)

                if "." in name:
                    qualified_name, function_type = function_to_type(declaration)

                    add_namespace_function(
                        namespaces,
                        qualified_name,
                        function_type,
                    )

                else:
                    add_function(
                        functions,
                        name,
                        declaration,
                    )

                continue

            declare_match = DECLARE_PATTERN.match(declaration)

            if declare_match:
                name = declare_match.group(1)

                key = (name, declaration)
                functions.setdefault(
                    key,
                    declaration,
                )

                continue

            raise ValueError(f"Unsupported declaration in {title}:\n{declaration}")

    output = [
        "-- Generated automatically from sUNC documentation.",
        "-- Do not edit manually.",
        "",
        "-- Types",
    ]

    output.extend(types.values())

    output.extend(
        [
            "",
            "-- Declarations",
        ]
    )

    output.extend(functions.values())

    if namespaces:
        output.append("")
        output.append("-- Namespaced libraries")
        output.extend(render_namespaces(namespaces))

    output.append("")

    declaration_count = len(functions) + sum(
        len(members) for members in namespaces.values()
    )

    return (
        "\n".join(output),
        len(types),
        declaration_count,
    )


def write_output(content: str) -> None:
    """Write the generated definitions atomically."""

    OUTPUT.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    temporary = OUTPUT.with_suffix(OUTPUT.suffix + ".tmp")

    temporary.write_text(
        content,
        encoding="utf-8",
        newline="\n",
    )

    temporary.replace(OUTPUT)


def main() -> int:
    try:
        metadata = fetch_metadata()
        signatures = collect_signatures(metadata)

        if not signatures:
            raise RuntimeError("No signatures were found in the API response.")

        print(f"Found {len(signatures)} signatures.")

        content, type_count, function_count = build_definitions(signatures)

        write_output(content)

        print(f"Generated {OUTPUT}")
        print(f"Types: {type_count}")
        print(f"Declarations: {function_count}")

        return 0

    except KeyboardInterrupt:
        print(
            "\nGeneration cancelled.",
            file=sys.stderr,
        )
        return 130

    except Exception as error:
        print(
            f"\nGeneration failed: {error}",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
