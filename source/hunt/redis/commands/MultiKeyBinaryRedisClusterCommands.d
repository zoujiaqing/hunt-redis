module hunt.redis.commands;

import hunt.redis.BinaryRedisPubSub;
import hunt.redis.BitOP;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.ZParams;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

public interface MultiKeyBinaryRedisClusterCommands {
  Long del(byte[]... keys);

  Long unlink(byte[]... keys);

  Long exists(byte[]... keys);

  List<byte[]> blpop(int timeout, byte[]... keys);

  List<byte[]> brpop(int timeout, byte[]... keys);

  List<byte[]> mget(byte[]... keys);

  String mset(byte[]... keysvalues);

  Long msetnx(byte[]... keysvalues);

  String rename(byte[] oldkey, byte[] newkey);

  Long renamenx(byte[] oldkey, byte[] newkey);

  byte[] rpoplpush(byte[] srckey, byte[] dstkey);

  Set<byte[]> sdiff(byte[]... keys);

  Long sdiffstore(byte[] dstkey, byte[]... keys);

  Set<byte[]> sinter(byte[]... keys);

  Long sinterstore(byte[] dstkey, byte[]... keys);

  Long smove(byte[] srckey, byte[] dstkey, byte[] member);

  Long sort(byte[] key, SortingParams sortingParameters, byte[] dstkey);

  Long sort(byte[] key, byte[] dstkey);

  Set<byte[]> sunion(byte[]... keys);

  Long sunionstore(byte[] dstkey, byte[]... keys);

  Long zinterstore(byte[] dstkey, byte[]... sets);

  Long zinterstore(byte[] dstkey, ZParams params, byte[]... sets);

  Long zunionstore(byte[] dstkey, byte[]... sets);

  Long zunionstore(byte[] dstkey, ZParams params, byte[]... sets);

  byte[] brpoplpush(byte[] source, byte[] destination, int timeout);

  Long publish(byte[] channel, byte[] message);

  void subscribe(BinaryRedisPubSub jedisPubSub, byte[]... channels);

  void psubscribe(BinaryRedisPubSub jedisPubSub, byte[]... patterns);

  Long bitop(BitOP op, byte[] destKey, byte[]... srcKeys);

  String pfmerge(byte[] destkey, byte[]... sourcekeys);

  Long pfcount(byte[]... keys);

  Long touch(byte[]... keys);

  ScanResult<byte[]> scan(byte[] cursor, ScanParams params);

  Set<byte[]> keys(byte[] pattern);
  
  List<byte[]> xread(final int count, final long block, final Map<byte[], byte[]> streams);
  
  List<byte[]> xreadGroup(byte[] groupname, byte[] consumer, int count, long block, boolean noAck, Map<byte[], byte[]> streams);
}
