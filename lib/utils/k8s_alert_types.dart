class K8sAlertType {
  final String name;
  final String description;
  final String icon;
  final String defaultSeverity;

  const K8sAlertType({
    required this.name,
    required this.description,
    required this.icon,
    required this.defaultSeverity,
  });
}

class K8sAlertTypes {
  static const List<K8sAlertType> all = [
    K8sAlertType(
      name: 'CrashLoopBackOff',
      description: 'Pod is repeatedly crashing and restarting',
      icon: 'loop',
      defaultSeverity: 'P0',
    ),
    K8sAlertType(
      name: 'OOMKilled',
      description: 'Container killed due to out-of-memory condition',
      icon: 'memory',
      defaultSeverity: 'P0',
    ),
    K8sAlertType(
      name: 'NodeNotReady',
      description: 'Node is in NotReady state and cannot schedule pods',
      icon: 'dns',
      defaultSeverity: 'P1',
    ),
    K8sAlertType(
      name: 'PodEvicted',
      description: 'Pod evicted due to resource pressure on node',
      icon: 'eject',
      defaultSeverity: 'P1',
    ),
    K8sAlertType(
      name: 'HighCPUUsage',
      description: 'CPU utilization exceeds threshold on node or pod',
      icon: 'speed',
      defaultSeverity: 'P2',
    ),
    K8sAlertType(
      name: 'HighMemoryUsage',
      description: 'Memory utilization approaching limits',
      icon: 'data_usage',
      defaultSeverity: 'P2',
    ),
    K8sAlertType(
      name: 'PVCPending',
      description: 'PersistentVolumeClaim stuck in Pending state',
      icon: 'storage',
      defaultSeverity: 'P2',
    ),
    K8sAlertType(
      name: 'ImagePullBackOff',
      description: 'Failed to pull container image from registry',
      icon: 'cloud_download',
      defaultSeverity: 'P1',
    ),
    K8sAlertType(
      name: 'DeploymentReplicasMismatch',
      description: 'Desired replicas do not match available replicas',
      icon: 'content_copy',
      defaultSeverity: 'P2',
    ),
    K8sAlertType(
      name: 'EndpointNotReady',
      description: 'Service endpoint has no ready addresses',
      icon: 'link_off',
      defaultSeverity: 'P1',
    ),
    K8sAlertType(
      name: 'CertificateExpiring',
      description: 'TLS certificate approaching expiration date',
      icon: 'lock_clock',
      defaultSeverity: 'P2',
    ),
    K8sAlertType(
      name: 'DiskPressure',
      description: 'Node disk usage exceeds threshold',
      icon: 'disc_full',
      defaultSeverity: 'P1',
    ),
  ];

  static IconMapping getIcon(String iconName) {
    return _iconMap[iconName] ?? IconMapping.fallback;
  }

  static final Map<String, IconMapping> _iconMap = {
    'loop': const IconMapping(0xe863),
    'memory': const IconMapping(0xe322),
    'dns': const IconMapping(0xe32f),
    'eject': const IconMapping(0xe8fb),
    'speed': const IconMapping(0xe9e4),
    'data_usage': const IconMapping(0xe1af),
    'storage': const IconMapping(0xe1db),
    'cloud_download': const IconMapping(0xe2c0),
    'content_copy': const IconMapping(0xe14d),
    'link_off': const IconMapping(0xe16f),
    'lock_clock': const IconMapping(0xef57),
    'disc_full': const IconMapping(0xe610),
  };
}

class IconMapping {
  final int codePoint;
  const IconMapping(this.codePoint);
  static const fallback = IconMapping(0xe88e); // info
}
