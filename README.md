# 1brc-ruby

### System Info

```sh
$ ruby --version
ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [arm64-darwin21]

uname -r
22.6.0

sysctl -a | grep machdep.cpu
machdep.cpu.cores_per_package: 8
machdep.cpu.core_count: 8
machdep.cpu.logical_per_package: 8
machdep.cpu.thread_count: 8
machdep.cpu.brand_string: Apple M1

memory
16GB
```

### Stats

| Implementation                  | 1 million | 10 million | 50 million | 100 million | 1 billion |
| ------------------------------- | --------- | ---------- | ---------- | ----------- | --------- |
| Java Baseline                   |           |            | 15.78s     |             | 319.81s   |
| ruby single thread 1000 slice   | 1.22599s  | 12.482648s | 64.479745s |             |           |
| ruby single thread 10_000 slice |           |            | 77.639337s |             |           |
| ruby async 1000 slice           | 1.315956s | 13.364678s | 65.457532s |             |           |
|                                 |           |            |            |             |           |
