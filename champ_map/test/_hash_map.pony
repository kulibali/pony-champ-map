
use c = "collections"
use "itertools"
use "ponytest"
use "random"
use ".."

class iso _TestHashMapLookupEmpty is UnitTest
  fun name(): String => "hash_map/lookup_empty"

  fun apply(h: TestHelper) =>
    let map = Map[USize, USize]
    try
      let v = map(123)?
      h.fail("map lookup succeeded on an empty map")
    else
      h.complete(true)
    end

class iso _TestHashMapLookupSingleExisting is UnitTest
  fun name(): String => "hash_map/lookup_single_existing"

  fun apply(h: TestHelper) ? =>
    var map = Map[USize, USize]
    map = map.update(USize(1234), USize(5678))?
    h.assert_eq[USize](5678, map(USize(1234))?)

class iso _TestHashMapLookupSingleNonexistent is UnitTest
  fun name(): String => "hash_map/lookup_single_nonexistent"

  fun apply(h: TestHelper) ? =>
    var map = Map[USize, USize]
    map = map.update(USize(1234), USize(5678))?
    try
      let v = map(USize(9876))?
      h.fail("map lookup succeeded on the wrong key")
    else
      h.complete(true)
    end

class iso _TestHashMapInsertMultiple is UnitTest
  fun name(): String => "hash_map/insert_multiple"

  fun apply(h: TestHelper) ? =>
    let num: USize = 10_000

    let rng = Rand
    let arr = Array[(USize,USize)](num)

    let not_in_map = rng.next().usize()
    var map = Map[USize, USize]
    for i in c.Range(0, num) do
      var k = rng.next().usize()
      while k == not_in_map do k = rng.next().usize() end
      let v = rng.next().usize()
      arr.push((k, v))
      map = map.update(k, v)?
    end

    for (k, expected) in arr.values() do
      let actual = map(k)?
      h.assert_eq[USize](expected, actual)
    end

    var num_found: USize = 0
    for i in c.Range(0, 10_000) do
      try
        let actual = map(not_in_map)?
        num_found = num_found + 1
      end
    end
    h.assert_eq[USize](0, num_found, "found " + num_found.string() +
      " collisions")