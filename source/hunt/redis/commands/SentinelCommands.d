module hunt.redis.commands;

import hunt.collection.List;
import hunt.collection.Map;

public interface SentinelCommands {
  List<Map<String, String>> sentinelMasters();

  List<String> sentinelGetMasterAddrByName(String masterName);

  Long sentinelReset(String pattern);

  List<Map<String, String>> sentinelSlaves(String masterName);

  String sentinelFailover(String masterName);

  String sentinelMonitor(String masterName, String ip, int port, int quorum);

  String sentinelRemove(String masterName);

  String sentinelSet(String masterName, Map<String, String> parameterMap);
}
