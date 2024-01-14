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
| ruby single thread 1000 slice   | 1.22599   | 12.482648  | 64.479745  |             |           |
| ruby single thread 10_000 slice |           |            | 77.639337  |             |           |
|                                 |           |            |            |             |           |
