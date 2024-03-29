module hunt.redis;

import hunt.redis.exceptions.RedisAskDataException;
import hunt.redis.exceptions.RedisClusterMaxAttemptsException;
import hunt.redis.exceptions.RedisClusterOperationException;
import hunt.redis.exceptions.RedisConnectionException;
import hunt.redis.exceptions.RedisMovedDataException;
import hunt.redis.exceptions.RedisNoReachableClusterNodeException;
import hunt.redis.exceptions.RedisRedirectionException;
import hunt.redis.util.RedisClusterCRC16;

public abstract class RedisClusterCommand<T> {

  private final RedisClusterConnectionHandler connectionHandler;
  private final int maxAttempts;

  public RedisClusterCommand(RedisClusterConnectionHandler connectionHandler, int maxAttempts) {
    this.connectionHandler = connectionHandler;
    this.maxAttempts = maxAttempts;
  }

  public abstract T execute(Redis connection);

  public T run(String key) {
    return runWithRetries(RedisClusterCRC16.getSlot(key), this.maxAttempts, false, null);
  }

  public T run(int keyCount, String... keys) {
    if (keys == null || keys.length == 0) {
      throw new RedisClusterOperationException("No way to dispatch this command to Redis Cluster.");
    }

    // For multiple keys, only execute if they all share the same connection slot.
    int slot = RedisClusterCRC16.getSlot(keys[0]);
    if (keys.length > 1) {
      for (int i = 1; i < keyCount; i++) {
        int nextSlot = RedisClusterCRC16.getSlot(keys[i]);
        if (slot != nextSlot) {
          throw new RedisClusterOperationException("No way to dispatch this command to Redis "
              + "Cluster because keys have different slots.");
        }
      }
    }

    return runWithRetries(slot, this.maxAttempts, false, null);
  }

  public T runBinary(byte[] key) {
    return runWithRetries(RedisClusterCRC16.getSlot(key), this.maxAttempts, false, null);
  }

  public T runBinary(int keyCount, byte[]... keys) {
    if (keys == null || keys.length == 0) {
      throw new RedisClusterOperationException("No way to dispatch this command to Redis Cluster.");
    }

    // For multiple keys, only execute if they all share the same connection slot.
    int slot = RedisClusterCRC16.getSlot(keys[0]);
    if (keys.length > 1) {
      for (int i = 1; i < keyCount; i++) {
        int nextSlot = RedisClusterCRC16.getSlot(keys[i]);
        if (slot != nextSlot) {
          throw new RedisClusterOperationException("No way to dispatch this command to Redis "
              + "Cluster because keys have different slots.");
        }
      }
    }

    return runWithRetries(slot, this.maxAttempts, false, null);
  }

  public T runWithAnyNode() {
    Redis connection = null;
    try {
      connection = connectionHandler.getConnection();
      return execute(connection);
    } catch (RedisConnectionException e) {
      throw e;
    } finally {
      releaseConnection(connection);
    }
  }

  private T runWithRetries(final int slot, int attempts, boolean tryRandomNode, RedisRedirectionException redirect) {
    if (attempts <= 0) {
      throw new RedisClusterMaxAttemptsException("No more cluster attempts left.");
    }

    Redis connection = null;
    try {

      if (redirect != null) {
        connection = this.connectionHandler.getConnectionFromNode(redirect.getTargetNode());
        if (redirect instanceof RedisAskDataException) {
          // TODO: Pipeline asking with the original command to make it faster....
          connection.asking();
        }
      } else {
        if (tryRandomNode) {
          connection = connectionHandler.getConnection();
        } else {
          connection = connectionHandler.getConnectionFromSlot(slot);
        }
      }

      return execute(connection);

    } catch (RedisNoReachableClusterNodeException jnrcne) {
      throw jnrcne;
    } catch (RedisConnectionException jce) {
      // release current connection before recursion
      releaseConnection(connection);
      connection = null;

      if (attempts <= 1) {
        //We need this because if node is not reachable anymore - we need to finally initiate slots
        //renewing, or we can stuck with cluster state without one node in opposite case.
        //But now if maxAttempts = [1 or 2] we will do it too often.
        //TODO make tracking of successful/unsuccessful operations for node - do renewing only
        //if there were no successful responses from this node last few seconds
        this.connectionHandler.renewSlotCache();
      }

      return runWithRetries(slot, attempts - 1, tryRandomNode, redirect);
    } catch (RedisRedirectionException jre) {
      // if MOVED redirection occurred,
      if (jre instanceof RedisMovedDataException) {
        // it rebuilds cluster's slot cache recommended by Redis cluster specification
        this.connectionHandler.renewSlotCache(connection);
      }

      // release current connection before recursion
      releaseConnection(connection);
      connection = null;

      return runWithRetries(slot, attempts - 1, false, jre);
    } finally {
      releaseConnection(connection);
    }
  }

  private void releaseConnection(Redis connection) {
    if (connection != null) {
      connection.close();
    }
  }

}
