enum MediaDownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
  failed,
}

class MediaDownloadState {
  final MediaDownloadStatus status;
  final double progress;
  final String? localFilePath;

  const MediaDownloadState({
    required this.status,
    this.progress = 0.0,
    this.localFilePath,
  });

  factory MediaDownloadState.notDownloaded() => const MediaDownloadState(status: MediaDownloadStatus.notDownloaded);

  factory MediaDownloadState.downloading(double progress) => MediaDownloadState(
        status: MediaDownloadStatus.downloading,
        progress: progress,
      );

  factory MediaDownloadState.downloaded(String path) => MediaDownloadState(
        status: MediaDownloadStatus.downloaded,
        localFilePath: path,
        progress: 1.0,
      );

  factory MediaDownloadState.failed() => const MediaDownloadState(status: MediaDownloadStatus.failed);
}
