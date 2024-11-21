import 'dart:collection';

/// 大小计算方式
typedef SizeCalculator = int Function<V>(V value);

/// 有Value被LruCache移出了队列
typedef OnEntryRemovedCallback<K, V> = void Function(
    bool evicted, K key, V value);

///
/// Lru算法的缓存Map，实现指定maxSize情况下，优先清除不常用的缓存数据。
///
class LruCache<K, V> implements Map<K, V> {
  late final LinkedHashMap<K, V> _map;
  late int _maxSize;
  late final SizeCalculator _sizeCalculator;
  late int _size;
  OnEntryRemovedCallback<K, V>? onEntryRemoveCallback;

  ///
  /// [maxSize] 最大缓存
  /// [sizeCalculator] 自定义Size计算，为null时，将会使用默认的sizeCalculator，所有Value的大小都是1，那么此时LruCache就是根据数量来进行策略执行
  ///
  LruCache({
    required int maxSize,
    SizeCalculator? sizeCalculator,
    this.onEntryRemoveCallback,
  }) {
    _sizeCalculator = sizeCalculator ?? <V>(v) => v != null ? 1 : 0;
    _maxSize = maxSize;
    _map = LinkedHashMap<K, V>();
    _size = 0;
  }

  set resize(int max) {
    _maxSize = max;
    _trim2Size(_maxSize);
  }

  @override
  V? operator [](Object? key) {
    if (key is! K) {
      throw UnsupportedError('the type of key must be ${K.runtimeType}');
    }
    return _map[key];
  }

  @override
  void operator []=(K key, V value) {
    V? oldV = _map[key];
    if (oldV != null) {
      _size -= _sizeCalculator(oldV);
      if (onEntryRemoveCallback != null) {
        onEntryRemoveCallback!(false, key, oldV);
      }
    }
    _map[key] = value;
    _size += _sizeCalculator(value);
    _trim2Size(_maxSize);
  }

  @override
  void addAll(Map<K, V> other) {
    other.forEach((key, value) {
      V? oldV = _map[key];
      if (oldV != null) {
        _size -= _sizeCalculator(oldV);
        if (onEntryRemoveCallback != null) {
          onEntryRemoveCallback!(false, key, oldV);
        }
      }
      _map[key] = value;
      _size += _sizeCalculator(value);
      _trim2Size(_maxSize);
    });
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    for (var element in newEntries) {
      V? oldV = _map[element.key];
      if (oldV != null) {
        _size -= _sizeCalculator(oldV);
        if (onEntryRemoveCallback != null) {
          onEntryRemoveCallback!(false, element.key, oldV);
        }
      }
      _map[element.key] = element.value;
      _size += _sizeCalculator(element.value);
      _trim2Size(_maxSize);
    }
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return _map.cast<RK, RV>();
  }

  @override
  void clear() {
    _trim2Size(-1);
    _size = 0;
  }

  @override
  bool containsKey(Object? key) {
    return _map.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return _map.containsValue(value);
  }

  @override
  Iterable<MapEntry<K, V>> get entries => _map.entries;

  @override
  void forEach(void Function(K key, V value) action) {
    _map.forEach(action);
  }

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<K> get keys => _map.keys;

  @override
  Iterable<V> get values => _map.values;

  @override
  int get length => _map.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) {
    return _map.map(convert);
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    V? v = _map[key];
    if (v == null) {
      v = ifAbsent();
      _map[key] = v! as V;
      _size += _sizeCalculator(v);
      _trim2Size(_maxSize);
    }
    return v;
  }

  @override
  V? remove(Object? key) {
    if (key is! K) {
      return null;
    }
    V? v = _map.remove(key);
    _size -= _sizeCalculator(v);
    if (v != null && onEntryRemoveCallback != null) {
      onEntryRemoveCallback!(false, key, v);
    }
    return v;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    _map.removeWhere((key, value) {
      bool ret = test(key, value);
      if (ret) {
        _size -= _sizeCalculator(value);
        if (value != null && onEntryRemoveCallback != null) {
          onEntryRemoveCallback!(false, key, value);
        }
      }
      return ret;
    });
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    V v = _map.update(key, (v) {
      _size -= _sizeCalculator(v);
      if (v != null && onEntryRemoveCallback != null) {
        onEntryRemoveCallback!(false, key, v);
      }
      V newV = update(v);
      _size += _sizeCalculator(newV);
      return newV;
    }, ifAbsent: () {
      V v = ifAbsent!();
      _size += _sizeCalculator(v);
      return v;
    });
    _trim2Size(_maxSize);
    return v;
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    _map.updateAll((key, value) {
      V? oldV = _map[key];
      _size -= _sizeCalculator(oldV);
      if (oldV != null && onEntryRemoveCallback != null) {
        onEntryRemoveCallback!(false, key, oldV);
      }
      V newV = update(key, value);
      _size += _sizeCalculator(newV);
      return newV;
    });
    _trim2Size(_maxSize);
  }

  void _trim2Size(int maxSize) {
    while (true) {
      K key;
      V value;
      if (_size < 0 || (_map.isEmpty && _size != 0)) {
        break;
      }

      if (_size <= maxSize || _map.isEmpty) {
        break;
      }
      MapEntry<K, V> entry = _map.entries.first;
      key = entry.key;
      value = entry.value;
      _map.remove(key);
      _size -= _sizeCalculator(value);
      if (onEntryRemoveCallback != null) {
        onEntryRemoveCallback!(true, key, value);
      }
    }
  }

  @override
  String toString() {
    return _map.toString();
  }
}
