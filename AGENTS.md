# AGENTS.md — psec-tool Development Notes

`psec-tool` provides a CLI over the [`psec`](https://github.com/knovichikhin/psec)
payment-security library. Main object handled: the `psec` Python package.

## Best Learning How to Use psec

The best way to learn `psec` is from its **source modules and their docstrings**.
Every public function carries a NumPy-style docstring with a runnable
`Examples` doctest. Locate the source directory first:

```bash
uv run --with psec python3 -c "import psec ; print(psec.__path__)"
```

Then browse the modules (`tr31`, `cvv`, `des`, `aes`, `mac`, `pin`, `pinblock`,
`tools`) to see real-world usage — parameter validation, key-length rules, and
the exact `bytes`/`str` conventions.

## Toolchain: `uv run --script`

The CLI entry point is a **PEP 723 inline-script** (the `/// script` header
block). uv reads this metadata, creates an ephemeral venv, and auto-installs
dependencies — no `pyproject.toml` or manual `pip install` needed.

```bash
# Add a dependency (writes into the /// script header block)
uv add --script psec-tool psec

# Run (uv manages venv + deps automatically)
uv run --script psec-tool -- <subcommand> ...

# Experiment in isolation (does not touch project files)
uv run --with psec python -c "..."
```

## How to Explore psec's APIs

### Rule: Always Verify in Isolation First

When you need to understand a `psec` function (does it take a hex `str` or raw
`bytes`? what key length is required? what does it return?), **use
`uv run --with psec python -c "..."` to build a minimal reproduction in
memory**. Confirm the behaviour before touching the CLI.

This avoids the cycle of: edit the main file → run → error → edit again.

### Snippet: Run a Function's Own Doctest

Every docstring already contains a working example. Copy it verbatim to confirm
the contract before wiring it to a CLI argument:

```bash
uv run --with psec python -c "
import psec
cvk = bytes.fromhex('0123456789ABCDEFFEDCBA9876543210')
print(psec.cvv.generate_cvv(cvk, '1234567890123456', '9912', '220'))
"
```

### Snippet: Inspect a Module's Public Surface

Each module defines `__all__`. Dump it with signatures to discover callables
instead of guessing:

```bash
uv run --with psec python -c "
import psec.pinblock as m, inspect
for name in m.__all__:
    print(name, inspect.signature(getattr(m, name)))
"
```

### Snippet: Confirm the Type / Error Contract

`psec` is strict: keys/data are **`bytes`** (via `bytes.fromhex(...)`), while
PAN/PIN/expiry are **ASCII digit `str`**. Inputs are validated and raise
`ValueError` (or `tr31`'s `HeaderError`/`KeyBlockError`) with a descriptive
message — trigger it to learn the boundary:

```bash
uv run --with psec python -c "
import psec
try:
    psec.des.encrypt_tdes_ecb(bytes.fromhex('0123456789ABCDEF'), b'123')
except ValueError as e:
    print('caught:', e)
"
```

## Workflow Summary

1. **`uv run --with psec python -c "..."`** — experiment with the API in isolation
2. **Read the target function's docstring** — parameter rules + a doctest
3. **After confirming behaviour** — wire it into the CLI subcommand
4. **`./test.sh`** — run the full regression suite

## File Layout

```
psec-tool          # main entry point (PEP 723 inline-script, provides the CLI)
test/              # per-module test-data generators / fixtures
test.sh            # quick regression suite
```
