# Elixir

## Commands

```bash
# run docker container
docker run -it --rm -w /app -v (pwd):/app elixir /bin/bash

mix run --no-mix-exs 9a.exs

# usage without mix
iex
# iex> c("4b.exs") # now you can use the module
# iex> Sleep.asleep?(nil, 0)
```
