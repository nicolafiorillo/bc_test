# bc_test

## Running the server

In a terminal shell:

```bash
git clone https://github.com/nicolafiorillo/bc_test
cd checksum
mix deps.get
mix compile
mix test
```

Run the server:
```bash
iex -S mix
```

## Running the test client

Test client requires python3.

In another terminal shell:

```bash
cd bc_test/tester
python3 run.py
```
