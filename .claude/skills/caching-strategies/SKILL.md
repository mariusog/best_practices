---
name: caching-strategies
description: Implements caching patterns for performance optimization. Principles are language-neutral; examples use Python. Use when adding memoization, precomputation, result caching, or when user mentions caching, performance, cache keys, or memoization.
---

# Caching Strategies

> **Note**: Caching patterns (memoization, precomputation, cache invalidation) apply to any language. Code examples use Python.

## Overview

Focus on these caching layers:
- **Precomputation**: Compute expensive results once at startup
- **Memoization**: Cache function results by arguments
- **Module-level caching**: Global dicts for reusable lookups
- **Disk caching**: Persist results across runs (joblib, shelve)

## Memoization

### functools.lru_cache

Best for pure functions with hashable arguments:

```python
from functools import lru_cache

@lru_cache(maxsize=None)
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

# Check cache stats
print(fibonacci.cache_info())

# Clear if needed
fibonacci.cache_clear()
```

### functools.cache (Python 3.9+)

Shorthand for `lru_cache(maxsize=None)`:

```python
from functools import cache

@cache
def expensive_pure_function(x, y):
    return complex_calculation(x, y)
```

### When lru_cache Won't Work

For unhashable arguments (lists, dicts, sets), convert to hashable:

```python
@lru_cache(maxsize=256)
def find_path(start, goal, blocked_frozenset):
    return search(start, goal, blocked_frozenset)

# Call with frozenset
path = find_path((0, 0), (5, 5), frozenset(blocked_cells))
```

## Module-Level Dict Caching

For caches that need manual management:

```python
_dist_cache: dict[tuple, dict] = {}

def get_distances_from(source, blocked):
    if source not in _dist_cache:
        _dist_cache[source] = compute_all_distances(source, blocked)
    return _dist_cache[source]

def clear_caches():
    """Reset caches between runs/sessions."""
    _dist_cache.clear()
```

## Precomputation Pattern

Compute once at initialization, use many times:

```python
_static_data = None

def init_static(config):
    """Compute static data once -- config never changes within a session."""
    global _static_data
    _static_data = expensive_setup(config)

def get_static():
    assert _static_data is not None, "Call init_static() first"
    return _static_data
```

## Disk Caching

### joblib (for ML/data science)

```python
from joblib import Memory

memory = Memory("./cache", verbose=0)

@memory.cache
def train_model(X, y, params):
    """Cached across runs -- recomputes only if inputs change."""
    model = SomeModel(**params)
    model.fit(X, y)
    return model
```

### shelve (simple key-value persistence)

```python
import shelve

def load_or_compute(key, compute_fn):
    with shelve.open("cache.db") as db:
        if key not in db:
            db[key] = compute_fn()
        return db[key]
```

## Cache Invalidation

### Event-Based

```python
def on_new_session():
    """Clear all caches when starting a new session."""
    _dist_cache.clear()
    fibonacci.cache_clear()
```

### Time-Based

```python
import time

_cache = {}
_cache_time = {}
CACHE_TTL = 300  # 5 minutes

def get_cached(key, compute_fn):
    now = time.time()
    if key in _cache and (now - _cache_time[key]) < CACHE_TTL:
        return _cache[key]
    result = compute_fn()
    _cache[key] = result
    _cache_time[key] = now
    return result
```

## Testing Caching

```python
def test_cache_returns_same_object():
    result1 = get_distances_from((0, 0), blocked)
    result2 = get_distances_from((0, 0), blocked)
    assert result1 is result2  # Same object (cached)

def test_cache_invalidation():
    get_distances_from((0, 0), blocked)
    clear_caches()
    assert (0, 0) not in _dist_cache
```

## Checklist

- [ ] Pure functions use `@lru_cache` or `@cache`
- [ ] Static data precomputed once at initialization
- [ ] Cache keys are hashable (tuples, frozensets, not lists/dicts)
- [ ] Caches cleared between runs/sessions
- [ ] Cache hit rates monitored for key caches (log them)
- [ ] No unbounded caches that could cause memory issues
- [ ] Disk caching for expensive ML training or data processing
