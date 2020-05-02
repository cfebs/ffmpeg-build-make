# ffmpeg-build-make

Builds ffmpeg and dependencies from source on linux according roughly to [the compilation guide](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu)

The goals:
- build with one Makefile
- all sources are pulled at their master/tip version if possible

## How to

Make sure you have pre-reqs.

- **debian/ubuntu**: `apt-get install autoconf automake build-essential cmake curl`
- **arch**: `pacman -S base-devel curl`

Then run:

```
make && ls ./bin
```

## Notes

#### Docker test

```
make docker
docker run --rm -it ffmpeg-make:latest bash
$ make all
```

To itterate without re downloading source, mount the .dl cache like so:

```
make docker
docker run --rm -it -v $PWD/.dl:/app.dl ffmpeg-make:latest bash`
$ make cachedl  # touches dl files so make won't redownload
$ make all
```

#### Parallel jobs

Top level `make` is running several other `make` builds. The `-j` value will be determined by `nproc` output.

Use `JOBS` env var to override.

## References

- https://github.com/markus-perl/ffmpeg-build-script
