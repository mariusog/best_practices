---
name: performance-optimization
description: Identifies and fixes performance issues including algorithmic complexity, memory usage, and profiling. Principles are language-neutral; examples use Python. Use when optimizing code, fixing slow functions, improving response times, or when user mentions performance, slow, optimization, or profiling.
---

# Performance Optimization

> **Note**: The algorithmic patterns (set for O(1) lookup, dict for matching, caching repeated work) apply to any language. Code examples use Python.

## Overview

Performance optimization focuses on:
- Algorithmic complexity reduction
- Data structure selection
- Memory management
- CPU profiling and hot path optimization
- Caching and precomputation

## Quick Start

Useful profiling tools:
- `cProfile` / `profile` -- Built-in CPU profiling
- `timeit` -- Micro-benchmarking
- `memory_profiler` -- Memory usage analysis
- `line_profiler` -- Line-by-line timing
- `py-spy` -- Sampling profiler (no code changes)

## Algorithmic Complexity

### Common Fixes

```python
# BAD: O(n^2) -- checking membership in a list
if item in large_list:  # O(n) per lookup

# GOOD: O(1) -- use a set
large_set = set(large_list)
if item in large_set:  # O(1) per lookup
```

```python
# BAD: O(n^2) -- nested loop for matching
for a in list_a:
    for b in list_b:
        if a.id == b.id:
            process(a, b)

# GOOD: O(n) -- index one side with a dict
b_by_id = {b.id: b for b in list_b}
for a in list_a:
    if a.id in b_by_id:
        process(a, b_by_id[a.id])
```

```python
# BAD: Repeated expensive computation
for target in targets:
    path = search(start, target, blocked)  # Recomputes from scratch

# GOOD: Single computation, cache results
distances = search_all(start, blocked)  # One search, all distances
for target in targets:
    d = distances.get(target, float("inf"))  # O(1) lookup
```

### When to Optimize

| Signal | Action |
|--------|--------|
| Function called 1000+ times per decision | Profile and optimize |
| O(n^2) in a hot loop | Reduce to O(n log n) or O(n) |
| Same computation repeated | Cache or precompute |
| Large data copied unnecessarily | Use views or generators |

## Data Structure Selection

| Need | Use | Not |
|------|-----|-----|
| Fast membership test | `set`, `frozenset` | `list` |
| Key-value lookup | `dict` | list of tuples |
| FIFO queue | `collections.deque` | `list` (pop(0) is O(n)) |
| Counting | `collections.Counter` | manual dict |
| Default values | `collections.defaultdict` | `dict.setdefault()` |
| Sorted access | `heapq` or `sortedcontainers` | repeated `sorted()` |
| Immutable record | `tuple` or `NamedTuple` | `dict` |

## Caching Patterns

### functools.lru_cache

```python
from functools import lru_cache

@lru_cache(maxsize=1024)
def expensive_computation(x, y):
    return complex_calculation(x, y)
```

### Manual Caching with Dicts

```python
_cache: dict[tuple, dict] = {}

def get_distances(source, blocked_key):
    if source not in _cache:
        _cache[source] = compute_distances(source)
    return _cache[source]
```

### Precomputation

```python
def init_static(config):
    """Precompute static data once at startup."""
    global _blocked, _adjacency
    _blocked = compute_blocked_cells(config)
    _adjacency = {pos: get_neighbors(pos) for pos in all_positions}
```

## Memory Optimization

### Generators Over Lists

```python
# BAD: Creates entire list in memory
squares = [x**2 for x in range(1_000_000)]

# GOOD: Generates values on demand
squares = (x**2 for x in range(1_000_000))
```

### __slots__ for Many Instances

```python
class Point:
    __slots__ = ("x", "y")
    def __init__(self, x, y):
        self.x = x
        self.y = y
```

## Profiling

### cProfile

```python
import cProfile
cProfile.run("main_function(data)", sort="cumulative")
```

### timeit for Micro-benchmarks

```python
import timeit
t1 = timeit.timeit(lambda: approach_a(data), number=10000)
t2 = timeit.timeit(lambda: approach_b(data), number=10000)
print(f"A: {t1:.4f}s, B: {t2:.4f}s")
```

## Testing for Performance

### Timing Assertions

```python
import time

def test_function_within_budget():
    """Function must complete within 100ms."""
    state = make_large_state()
    start = time.perf_counter()
    process(state)
    elapsed = time.perf_counter() - start
    assert elapsed < 0.1, f"Too slow: {elapsed:.3f}s"
```

### Complexity Assertions

```python
def test_search_scales_linearly():
    """Search should scale with input size, not quadratically."""
    times = []
    for size in [100, 200, 400]:
        data = make_data(size=size)
        start = time.perf_counter()
        search(data)
        times.append(time.perf_counter() - start)

    ratio = times[2] / times[1]
    assert ratio < 8, f"Scaling too fast: {ratio:.1f}x"
```

## Performance Checklist

- [ ] Hot paths profiled and optimized
- [ ] Sets used for membership testing (not lists)
- [ ] Dicts used for key-value lookups
- [ ] Expensive computations cached or precomputed
- [ ] No unnecessary data copies in loops
- [ ] Generators used for large sequences
- [ ] Algorithm complexity documented for critical functions

## Quick Fixes Reference

| Problem | Solution |
|---------|----------|
| Slow membership test | Convert list to set |
| Repeated computation from same input | Cache results |
| O(n^2) matching | Index one side with dict |
| Large list built then iterated | Use generator |
| Repeated sorting | Use heapq or sorted container |
| String concatenation in loop | Use `"".join()` or list append |
