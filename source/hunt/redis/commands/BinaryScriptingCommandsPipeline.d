module hunt.redis.commands;

import hunt.redis.Response;

import hunt.collection.List;

public interface BinaryScriptingCommandsPipeline {

  Response<Object> eval(byte[] script, byte[] keyCount, byte[]... params);

  Response<Object> eval(byte[] script, int keyCount, byte[]... params);

  Response<Object> eval(byte[] script, List<byte[]> keys, List<byte[]> args);

  Response<Object> eval(byte[] script);

  Response<Object> evalsha(byte[] sha1);

  Response<Object> evalsha(byte[] sha1, List<byte[]> keys, List<byte[]> args);

  Response<Object> evalsha(byte[] sha1, int keyCount, byte[]... params);
}
