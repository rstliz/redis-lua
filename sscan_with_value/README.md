# sscan_with_value 
iterates elements of Sets types with mget keys.

## usage
```
evalsha <sha1> 2 <key of sets> V_PREFIX <prefix of key> COUNT <num of needs> MATCH <pattern of sets members>
```

### Preparation
```
127.0.0.1:6379> sadd var_set foo bar baz
(integer) 3
127.0.0.1:6379> smembers var_set
1) "foo"
2) "bar"
3) "baz"
127.0.0.1:6379> set var_key_foo 11
OK
127.0.0.1:6379> set var_key_bar 22
OK
127.0.0.1:6379> set var_key_baz 35
OK
```
### Load a script into the scripts cache
```
redis-cli SCRIPT LOAD "$(cat <path to script>/sscan_with_value.lua)"
"8c8aa307d98cac08d36807814a206f1f491510c2"
```
### execute
```
127.0.0.1:6379> evalsha 8c8aa307d98cac08d36807814a206f1f491510c2 2 var_set 0 V_PREFIX var_key_ COUNT 2
1) "3"
2) 1) 1) "foo"
      2) "11"
   2) 1) "bar"
      2) "22"
127.0.0.1:6379> evalsha 8c8aa307d98cac08d36807814a206f1f491510c2 2 var_set 3 V_PREFIX var_key_ COUNT 2
1) "0"
2) 1) 1) "baz"
      2) "35""
```

