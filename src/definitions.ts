declare module '@capacitor/core' {
  interface PluginRegistry {
    FileTransfer: FileTransferPlugin;
  }
}

export interface FileTransferPlugin {
  download(options: {source: string, target: string}): Promise<void>;
}
